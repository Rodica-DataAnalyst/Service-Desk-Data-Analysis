# Service-Desk-Data-Analysis
End-to-end Service Desk data analysis project using Excel , Python , SQL Server and Power BI.

## Project Overview
This is an end-to-end Data Analyst portfolio project focused on analyzing Service Desk ticket data.

The project follows a complete data analysis workflow using Excel, Python (Pandas), SQL Server and Power BI, from data quality checks and cleaning to analysis, KPI creation and interactive dashboard development.

## Tools Used
- Excel – Data exploration and initial data quality checks
- Python (Pandas) – Data cleaning, transformation and validation
- SQL Server – Data modeling, validation and analysis
- Power BI – Data visualization and dashboard development

## Project Workflow

### 1. Excel – Data Quality
- Identified missing values and duplicate records
- Checked data consistency and temporal rules
- Validated categories and subcategories
- Checked data types and potential data quality issues
  
- Pivot Table & Metrics :
Created dynamic pivot summaries to analyze ticket distribution across different statuses (Closed , In Progress , Resolved , Pending) and tracked the overall breakdown of 50000+ total records. 

- Monthly Volume Trends :
Built a monthly tracking matrix with calculated percentage contribution to identify seasonal peaks and fluctuation in ticket volumes from 2024 to 2026.

- Visual Annotation:
Developed line and combo charts to visualize internal patterns ,helping establish a baseline for deeper data modeling in SQL Server and Power BI .

  <img width="1827" height="654" alt="AdobeExpressPhotos_8cdee7fecda34081aaf7bf4d9969fc58_CopyEdited" src="https://github.com/user-attachments/assets/5f1c9d92-a1a7-4158-9dcb-b015500775d6" />


### 2. Python – Data Cleaning & Validation
- Removed duplicate records
- Standardized text fields
- Converted and validated datetime columns
- Checked missing and inconsistent values
- Calculated ticket resolution time from OpenDateTime to ResolvedDateTime 
- Exported the cleaned dataset for SQL analysis

### 3. SQL Server – Data Analysis
- Built and validated the analytical data model
- Used joins, aggregations, CTEs and window functions
- Analyzed ticket status, categories and priorities
- Calculated response and resolution metrics
- Analyzed pending and reopened tickets
- Analyzed ticket resolution times and identified categories with high average resolution times.

### 4. Power BI – Dashboard
Created an interactive Service Desk dashboard covering:
- Total Tickets
- Closed and Resolved Tickets
- Pending and Reopened Tickets
- Average First Response Time
- Average Resolution Time
- SLA Performance
- Ticket analysis by Category and Subcategory
- Year-over-Year analysis
- Drill-down and drill-through analysis

## Repository Structure
- `Excel/` – Data exploration and quality checks
- `Python/` – Data cleaning and validation notebook
- `SQL/` – SQL analysis queries
- `PowerBI/` – Power BI dashboard and PDF preview

## Key Skills Demonstrated
Excel | Python | Pandas | SQL Server | Power BI | DAX | Data Cleaning | Data Validation | Data Modeling | Data Visualization | Business Analysis
