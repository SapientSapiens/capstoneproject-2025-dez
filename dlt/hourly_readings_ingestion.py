import dlt
import time
from datetime import datetime
from zoneinfo import ZoneInfo
from kestra import Kestra
from dlt.destinations import filesystem
from dlt.sources.helpers.rest_client import RESTClient
# import logging


API_KEY = dlt.secrets.get("api_secret_key") # fetching the API key from dlt secrets.toml
location_lst = dlt.secrets.get("location_list")  # This is already a string
locations = location_lst.strip("[]").split(",")
# Convert each string to an integer
location_list = [int(num.strip()) for num in locations]
BASE_URL = dlt.secrets.get("base_url") 

headers = {"X-API-Key": API_KEY}
client = RESTClient(
    base_url = BASE_URL, # fetching the base url of the endpoint.
    headers=headers 
)

current_ist_timestamp = datetime.now(ZoneInfo("Asia/Kolkata")).strftime('%Y-%m-%d_%H-%M-%S')

# Set up logging to log to a file and console
#logging.basicConfig(level=logging.INFO, 
                    #format='%(asctime)s - %(levelname)s - %(message)s',
                    #handlers=[
                        #logging.FileHandler("ingestion_hourly.log"),
                        #logging.StreamHandler()
                    #])
#I HAVE TO SHUT OFF THE LOGGING AS KESTRA IS THROWING ERRO/WARNING ON THIS. PROBABLY AS KESTRA HAVE ITS OWN LOGGING SYSTEM, 
# IT MAY BE CONFLICTING WITH IT. USED KESTRA LOGGER INSTEAD
logger = Kestra.logger()
logger.info(f"Fetching data for the following OpenAQ location ids  {location_list}")


# Define a custom callback to return the current timestamp in your format.
def custom_timestamp(schema_name: str, table_name: str, load_id: str, file_id: str, ext: str) -> str:
    custom_ts = current_ist_timestamp
    #print(custom_ts)
    return custom_ts


@dlt.resource(
    table_name="location_info",
    write_disposition="merge",
    primary_key="id",
)
def get_location_info():
    #logging.info(f"getting location info.....")
    logger.info(f"getting location info.....")
    for loc_id in location_list:
        response = client.get(f"locations/{loc_id}")
        response.raise_for_status()  # USseful for explicit error checking
        yield response.json()
        time.sleep(1) # Avoid API rate limits


@dlt.resource(
    table_name="latest_airquality_measurements",
    write_disposition="append",
    primary_key="sensorsId",
)
def get_latest_info():
    #logging.info(f"getting latest info.....")
    logger.info(f"getting latest info.....")
    for loc_id in location_list:
        response = client.get(f"locations/{loc_id}/latest")
        response.raise_for_status()
        yield response.json()
        time.sleep(1) # Avoid API rate limits


@dlt.transformer(columns=[{"name": "timestamp", "data_type": "text"}])
def latest_measurements(latest_readings):
    # Using the location info
    location_data = list(get_location_info)
    
    #  transformer logic :  Combine all location_info results into one combined dictionary.
    combined_locations = {"results": []}
    for data in location_data:
        if "results" in data:
            combined_locations["results"].extend(data["results"])

    # Build a sensor mapping keyed by (location id, sensor id). This is based on the structure of the response from the API.
    sensor_map = {}
    for location in combined_locations["results"]:
        loc_id = location.get("id")
        loc_name = location.get("name", "unknown")
        for sensor in location.get("sensors", []):
            sensor_id = sensor.get("id")
            sensor_map[(loc_id, sensor_id)] = {
                "name": sensor["parameter"]["name"].upper(),
                "unit": sensor["parameter"]["units"],
                "location_name": loc_name,
            }

    # Use the latest_readings passed into the transformer. For each sensor reading in latest_readings["results"], yield a flattened record
    for reading in latest_readings["results"]:
        key = (reading.get("locationsId"), reading.get("sensorsId"))
        sensor_info = sensor_map.get(key, {"name": "UNKNOWN", "unit": "unknown", "location_name": "unknown"})
        yield {
            "location_id": reading.get("locationsId"),
            "location_name": sensor_info.get("location_name"),
            "timestamp": current_ist_timestamp,
            "sensor_id": reading.get("sensorsId"),
            "sensor_name": sensor_info.get("name"),
            "value": reading.get("value"),
            "unit": sensor_info.get("unit")
        }


# create a pipeline
pipeline = dlt.pipeline(
    pipeline_name="source_to_gcs_dlt_pipeline",
    destination=filesystem(
        layout="{table_name}_{custom_ts}.{ext}",
        extra_placeholders={
            "custom_ts": custom_timestamp  # formatted timestamp.
        }
    ),
    dataset_name="hourly_data",
)


def run_pipeline():
    try:
        # Run the pipeline with latest_measurements resource through the transformer.
        load_info = pipeline.run(get_latest_info | latest_measurements, loader_file_format="csv")
        logger.info(f"dlt pipeline for hourly data ingestion ran successfully at {current_ist_timestamp} with message {load_info}")  
        #logging.info(f"dlt pipeline for hourly data ingestion ran successfully at {current_ist_timestamp} with message {load_info}")  
    except Exception as e:
        logger.error(f"Error running dlt pipeline : {e}")


if __name__ == "__main__":
    run_pipeline()


