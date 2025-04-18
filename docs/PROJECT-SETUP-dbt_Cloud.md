## Setting up dbt Cloud for the project ##

 1. Set up a dbt Cloud account with Team plan. You shall a trial period of 13 days. Team plan allows API access.

  ![alt text](/images/project-setup/image-10.png)


 2. Follow the dbt Cloud account configuration process and integration process with the BigQuery datawarehouse as described [here](https://github.com/ManuelGuerra1987/data-engineering-zoomcamp-notes/blob/main/4_Analytics-Engineering/README.md).


 3. The sequential steps which I followed as described above can be seen as follows:

    ![alt text](/images/project-setup/image-a.png)


    ![alt text](/images/project-setup/image-b.png)


    ![alt text](/images/project-setup/image-c.png)


    ![alt text](/images/project-setup/image-d.png)


    ![alt text](/images/project-setup/image-e.png)


    ![alt text](/images/project-setup/image-f.png)


    ![alt text](/images/project-setup/image-g.png)



    ![alt text](/images/project-setup/image-h.png)


    |                                                   |                                                 |
    |---------------------------------------------------|-------------------------------------------------|
    | ![alt text](/images/project-setup/image-i1.png)   | ![alt text](/images/project-setup/image-i2.png) |



 4. After setting up the dbt Cloud environment, development ensued. The dbt mmodels have been successfully built and resulting tables in the BigQuery dataset.

     

    |                                                   |                                                              |
    |---------------------------------------------------|--------------------------------------------------------------|
    | ![alt text](/images/project-setup/dbt-build.png)  | ![alt text](/images/project-setup/bq-dataset-dbt-build.png)  |


 5. After successfull build, the dbt project needs to be deployed at dbt Cloud in a Production Environment. We create a new environment __Production__. Sunsequently we  create Job named __kestra_trigger_job__. But before running the manually, with scheduler or with API trigger, we need to create a dataset in BigQuery which we specified during the Production environment creation. In my case, it is __prod_air_quality_assam_dataset__ in the same location (_us-central-1_ in my case)

 6. For certainity of seamless operations, I tried a manual run and it was successful resulting in the population of the production dataset with requisite tables and views.

    |                                                        |                                                                        |
    |--------------------------------------------------------|------------------------------------------------------------------------|
    | ![alt text](/images/project-setup/dbt-prod-build.png)  | ![alt text](/images/project-setup/prod-dataset-dbt-populate.png)       |
  
   
  
   


