
# Data Warehouse and Analytics Project
Welcome to the Data Warehouse and Analytics Project repository! 🚀 This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

<img width="2015" height="1699" alt="data_architecture" src="https://github.com/user-attachments/assets/c4ffa761-7c96-4707-baff-c34a0903afe6" />

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

