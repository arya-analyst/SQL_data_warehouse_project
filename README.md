
# Data Warehouse and Analytics Project
Welcome to the Data Warehouse and Analytics Project repository! 🚀 This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---

## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

<img width="2015" height="1699" alt="data_architecture" src="https://github.com/user-attachments/assets/c4ffa761-7c96-4707-baff-c34a0903afe6" />

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:
- SQL Development
- Data Architect
- Data Engineering  
- ETL Pipeline Developer  
- Data Modeling  
- Data Analytics  

---

## 🚀 Project Walkthrough

1. **Bronze Layer**: We need to load/ingest the system in our sytem before we start working on it. We can write a script for it or can directly ingest the data with the help of built-in functions available in all the modern databases now. Instead of writing codes to create the tables manually and ingest the data in it manually, I've directly ingested the data with the built-in functions available in **OracleSQL**.

2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis - the script for which is available in this repository.

3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics. You can ask questions and work on the cleaned dataset to add another layer to this project and finally load the data in a BI tool to prepare a business-ready dashboard and KPI cards.
