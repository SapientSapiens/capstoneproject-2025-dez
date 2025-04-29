## Setting the project up on your VM ##

 1. Clone my project from my Github repository

        git clone https://github.com/SapientSapiens/capstoneproject-2025-dez.git

    ![alt text](/images/project-setup/image.png)

 2. Install the project dependeccies from the requirements.txt (although most of them shall be catered to by containers when running the Kestra orchestration flows.)

        cd capstoneproject-2025-dez
        
        pip install -r requirements.txt

    ![alt text](/images/project-setup/image-1.png)

 3. Inside the orchestration directory under the project directory, set the enviroment variables to your appropriate values.

        cd orchestration

    ![alt text](/images/project-setup/image-2.png) 

 
 4. Subsequently, you need run the shell script _encode-base64.sh_ to encode the environment variables from the __.env__ file to base64 and place them in the __.env_encoded__ file, to be used for Kestra secrets. Ensure first the script is executable, if not already.

         chmod +x encode-base64.sh

         ./encode-base64.sh
    
   ![alt text](/images/project-setup/image-3.png)


 5. After that, please run the docker-compose.yml file.

        docker-compose up
      
   |                                                  |                                                 |
   |--------------------------------------------------|-------------------------------------------------|
   | ![alt text](/images/project-setup/image-4.png)   | ![alt text](/images/project-setup/image-5.png)  |


 6. Now we can access Kestra orchestration tool running in the cloud (GCP VM server)

   ![alt text](/images/project-setup/image-6.png)


 7. We login to the Kestra tool with the username and password specified in the __.env__ and __docker-compose.yml__ In the dashboard, we can monitor our orchesrration flows. Since we just __set up__ the project and __started__ orchestrating the pipeline, we got 1 successfull executions for the __hourly_air_quality__ flow and this shall continue running every hour.

  
   |                                                  |                                                            |
   |--------------------------------------------------|------------------------------------------------------------|
   | ![alt text](/images/project-setup/image-7.png)   | ![alt text](/images/project-setup/image-logs-success.png)  |


 8. We can see the GCS bucket (datalake)has been ingested with the csv file containing hourly data from sensors. Also, we can see the data from the csv loaded into the BigqQuey (datawarehouse) dataset. 

   |                                                  |                                                 |
   |--------------------------------------------------|-------------------------------------------------|
   | ![alt text](/images/project-setup/image-8.png)   | ![alt text](/images/project-setup/image-9.png)  |


 9. Further, a few hours later, we can see that the __hourly_air_quality__ flow is running successfully as scheduled.


   ![alt text](/images/project-setup/image-trigger-success.png)


 10. Now let us backfill the historical data (take 2025 as 6 out of 9 sensors were fitted in Feb 2025 and the ramaining 3 were fixed for data anomaly by Central Pollution Control Board also in Feb 2025). So we now execute the __historical_air_quality__ flow

   |                                                             |                                                              |
   |-------------------------------------------------------------|--------------------------------------------------------------|
   | ![alt text](/images/project-setup/execute-historical.png)   | ![alt text](/images/project-setup/executing-historical.png)  |


 11. We can see the GCS bucket (datalake)has been ingested with the csv file containing historical sensors data. Also, we can see the historical data from the csv loaded into the BigqQuey (datawarehouse) dataset. 

   |                                                         |                                                         |
   |---------------------------------------------------------|---------------------------------------------------------|
   | ![alt text](/images/project-setup/history-bucket.png)   | ![alt text](/images/project-setup/history-dataset.png)  |



 #### 12. The final part or task of the scheduled flow, i.e.,  __hourly_air_quality__  is to run the data transformation in the BigQuery dataset with dbt Cloud via the API trigger. The flow is executing sucessfully. 

  
   ![alt text](/images/project-setup/gantt-api-dbt.png)



 13. Please cross reference with [__this__](/docs/PROJECT-SETUP-dbt_Cloud.md#8-after-setting-up-the-trigger-in-the-orcehstrration-tool-kestra-when-the-flow-is-executed-we-can-see-the-job-is-running-triggered-via-the-api-from-one-of-the-tasks-in-the-orchestration-flow) for more clarity.