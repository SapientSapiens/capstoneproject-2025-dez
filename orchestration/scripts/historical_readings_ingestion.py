import boto3
import time
import os
from google.cloud import storage
from botocore.config import Config
from botocore import UNSIGNED
from kestra import Kestra
import argparse
import json

# AWS S3 parameters
SOURCE_BUCKET = "openaq-data-archive"
# YEAR = 2025
LOCATION_LIST = [3409411, 3409391, 3409390, 3409360, 3409375, 3409376, 363601, 42240, 10903]  # OpenAQ location ids for my region under consideration

# GCS parameters
GCS_BUCKET_NAME = "air-quality-assam-bucket"  # You can name your own bucket as desired
# Get credentials path from the environment variable
# CREDENTIALS_FILE = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS") ---changed for incorporating into Kestra

CHUNK_SIZE = 262144  # 256 KB chunk size (adjust if needed)

# Set up logging 
logger = Kestra.logger()

# Initialize the AWS S3 client (using unsigned config for public buckets)
s3 = boto3.client("s3", config=Config(signature_version=UNSIGNED))

# Initialize storage client with explicit credentials
# gcs_client  = storage.Client.from_service_account_json(CREDENTIALS_FILE) --changed for incorporating into Kestra
# gcs_bucket = gcs_client.get_bucket(GCS_BUCKET_NAME) --changed for incorporating into Kestra
# logger.info(f"Initialized GCS client and accessed bucket: {GCS_BUCKET_NAME}")

# Initialize storage client using JSON from environment variable
credentials_json = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
if not credentials_json:
    raise ValueError("GOOGLE_APPLICATION_CREDENTIALS environment variable is not set.")

gcs_client = storage.Client.from_service_account_info(json.loads(credentials_json))
gcs_bucket = gcs_client.get_bucket(GCS_BUCKET_NAME)
logger.info(f"Initialized GCS client and accessed bucket: {GCS_BUCKET_NAME}")

def upload_to_gcs_from_memory(data, blob_name, max_retries=3):
    """
    Uploads in-memory data (bytes) to GCS with retry logic.
    
    Args:
        data (bytes): The file content.
        blob_name (str): The target blob name in GCS.
        max_retries (int): Maximum number of attempts.
        
    Returns:
        bool: True if the upload and verification succeed, False otherwise.
    """
    blob = gcs_bucket.blob(blob_name)
    blob.chunk_size = CHUNK_SIZE
    for attempt in range(max_retries):
        try:
            logger.info(f"Uploading {blob_name} to GCS (Attempt {attempt + 1})...")
            blob.upload_from_string(data)
            logger.info(f"Uploaded: gs://{GCS_BUCKET_NAME}/{blob_name}")
            return True
        except Exception as e:
            logger.error(f"Error uploading {blob_name} to GCS: {e}", exc_info=True)
        time.sleep(5)
    logger.error(f"Giving up on {blob_name} after {max_retries} attempts.")
    return False

def process_and_transfer(year):
    """
    For each location, list S3 objects under the specified prefix, remove the common prefix 
    to preserve folder structure, download each object into memory, and upload it to GCS.
    """

    # First, purge the historical_data folder inside the bucket if it exists.
    purge_existing_historical_records(prefix="historical_data/")

    for loc_id in LOCATION_LIST:
        # Define the source prefix used to list objects.
        source_prefix = f"records/csv.gz/locationid={loc_id}/year={year}/"
        logger.info(f"Processing location {loc_id} with source prefix '{source_prefix}'...")
        response = s3.list_objects_v2(Bucket=SOURCE_BUCKET, Prefix=source_prefix)
        if "Contents" not in response:
            logger.info(f"No objects found for location {loc_id}")
            continue

        for obj in response["Contents"]:
            source_key = obj["Key"]
            # Remove the source prefix to get the relative path (e.g., "month=3/file.csv.gz")
            relative_path = source_key[len(source_prefix):]
            # Construct the GCS blob name to preserve the original structure
            gcs_blob_name = f"historical_data/{loc_id}/{relative_path}" #  file path in the GCS Bucket
            try:
                logger.info(f"Downloading s3://{SOURCE_BUCKET}/{source_key} into memory...")
                s3_obj = s3.get_object(Bucket=SOURCE_BUCKET, Key=source_key)
                data = s3_obj["Body"].read()  # Read file content into memory
                logger.info(f"Downloaded {source_key} successfully.")
                
                # Upload the file to GCS
                if upload_to_gcs_from_memory(data, gcs_blob_name):
                    logger.info(f"Successfully transferred {source_key} to GCS as {gcs_blob_name}.")
                else:
                    logger.error(f"Failed to transfer {source_key} after retries.")
            except Exception as e:
                logger.error(f"Error processing {source_key}: {e}", exc_info=True)

    logger.info("Data transfer from S3 to GCS completed.")


def purge_existing_historical_records(prefix="historical_data/"):
    logger.info(f"Purging all blobs with prefix '{prefix}' from bucket '{GCS_BUCKET_NAME}'...")
    blobs = list(gcs_bucket.list_blobs(prefix=prefix))
    if not blobs:
        logger.info("No blobs found with that prefix.")
        return
    # Using a batch context to perform deletes in a single HTTP call (where supported)
    with gcs_client.batch():
        for blob in blobs:
            logger.info(f"Deleting blob: {blob.name}")
            blob.delete()
    logger.info("Purge complete.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Transfer historical air quality data from S3 to GCS")
    parser.add_argument("--year", type=int, default=2025,
                        help="Year for which to process data (default: 2025)")
    args = parser.parse_args()
    process_and_transfer(args.year)