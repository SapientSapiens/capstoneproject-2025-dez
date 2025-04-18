# Air Quality Analysis Data Pipeline #

![alt text](/images/cover-pic.png)



## 🟠 Problem Description ##


The northeastern Indian state of Assam has witnessed a significant deterioration in air quality over the past few years. This concerning trend is primarily driven by a combination of factors:

Large-scale deforestation, resulting from rapid urban expansion.

A surge in vehicular traffic, especially in key urban centers.

Massive construction activities, both governmental and private, that release dust and pollutants into the air.

Although the Central Pollution Control Board (CPCB) has installed air quality sensors in 9 locations across Assam as of February 2025 (with 3 older sensors repaired and expanded since then), the state currently lacks a centralized and automated system to:

Collect real-time air quality data.

Analyze pollution patterns.

Visualize historical and current trends.

Provide actionable insights for policymakers, researchers, and the public.

The absence of such an end-to-end data infrastructure means that critical air quality insights remain buried in raw sensor feeds or siloed reports, inaccessible to most stakeholders.


## 🟢 Solution Overview ##


To address this gap, I designed and implemented a state-specific, smart air quality monitoring pipeline for Assam that provides an automated, scalable, and intelligent solution. Key components include:

 __🔹1. Data Ingestion__

   Automated data fetching from CPCB sensor across the 9 stations in Assam routed through [OpenAQ](https://openaq.org/). I have used 2 APIs from OpenAQ: one for the latest  hourly measurement and one for the historical data fetch from Feb 2025 (date sensors were installed in the locations)

 __🔹2. Data Load__

   Data fetched from the sources are loaded into a datalake in the form of hourly data for all pollutants of  each location in csv format and for the hsitorical data, it is per day(date) record of all pollutants - location wise compresses csv for all locations.

 __🔹3. Data Storage__

   The data from the datalake for both historical and latest measurements are loaded into a datawarehouse where the data goes transformation from raw crude bronze level to analytics usable golden level. This transformation is handled through a cloud based (although locally installable version is available ) data build tool.

 __🔹4. Automation and orchestration__

   These activities right from data ingestion to loading to storage and transformation are fully automated and each activity executes in sequential sync with the next in a seamlessly orchestrated way. An orchestration tool handled this right from loading data into datalake, getting and storing it into the datawarehouse and transformaing it to be analytics ready.

 __🔹4. Visualization__

   So fianlly with the cleaned and curated data, became ready for gettign visual insights out of them that reveal trends and patterns not very forthcoming in tabulat data. The visualization tool automatically picked up the data in the datawarehouse and responds to changes in the data through charts and other visual widgets.



## ⚙️🔧 Technical Overview ##

 ### Technology Stack I have used ###

 - Google Cloud Platform as the main cloud platform

 - Google Cloud Storage Bucket as the data lake

 - Google BigQuery as the data warehouse

 - Terraform as Infrastructure as Code (IaC) tool.

 - Kestra as the orchestratool tool

 - dbt Cloud as the cloud based data transformation tool

 - Google Looker Studio ads the visualizaation tool.


 ### Architechure and interplay of these components for running the pipeline with batch-porcessing ###

                ----------------architecutre image to go here -----------------------------


## ☁️ Cloud and Terraform ##

  - After getting my GCP account, I had created the Project and the Serive account for this project. 

  - The from my local machine I used, Terraform as the IaC tool to create resources at the Google Cloud Platform. Apart from mandatory associated firewall rules and API enablement, etc. Terraform created : the compute engine VM, the BigQuery dataset and the GCS bucket.

  - The VM was then set up for the project. The entire project is  developed on that VM. 

  - All details regarding this can be found  👉  [here](/docs/PLATFORM-SETUP.md) 