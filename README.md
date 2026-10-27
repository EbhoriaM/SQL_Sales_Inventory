# TechElectro Inc. — Inventory Optimization Using MySQL
###  Project Overview

TechElectro Inc. faces inventory management challenges, including overstocking, stockouts, and inefficient inventory allocation. These issues can increase operational costs, tie up working capital, and negatively affect customer satisfaction.

This project uses MySQL to analyze inventory data, identify stock management inefficiencies, evaluate sales trends, and develop data-driven inventory optimization strategies.

By integrating sales records, product information, and external economic factors, the analysis establishes a framework for calculating product-level reorder points, monitoring stockout frequencies, and supporting more effective inventory planning.

The ultimate goal is to help TechElectro Inc. maintain optimal stock levels, reduce inventory-related costs, improve product availability, and strengthen operational efficiency.

###  Project Objectives

The key objectives of this project are to:

Analyze historical sales and inventory data to understand product performance.

Identify missing values, duplicate records, and data type inconsistencies.

Integrate sales, product, and external economic datasets for comprehensive analysis.

Identify high-demand products and investigate stockout occurrences.

Examine the potential influence of GDP, inflation, and seasonal factors on inventory demand.

Calculate product-level reorder points using historical sales patterns and safety stock calculations.

Develop SQL procedures to monitor inventory levels, sales trends, and stockout frequencies.

Provide actionable recommendations for reducing overstocking and preventing stockouts.

### Tools and Technologies

Tool

Purpose

MySQL

Data cleaning, transformation, analysis, and inventory optimization

SQL

Data exploration, aggregation, joins, subqueries, and business analysis

Common Table Expressions (CTEs)

Organizing complex analytical queries

Window Functions

Calculating rolling averages, ranking records, and identifying duplicates

Views

Integrating data from multiple tables

Stored Procedures

Automating inventory and sales monitoring tasks

Triggers

Initiating reorder point recalculations after new inventory records are inserted

### Dataset Description

The project uses three primary datasets.

1. Sales Data

Contains sales and inventory-related information used to evaluate product performance and historical demand.

Key fields include:

product_id

sales_date

inventory_quantity

product_cost

2. Product Information

Contains product-level information used to categorize products and evaluate promotional activity.

Key fields include:

product_id

product_category

promotions

3. External Factors

Contains economic and seasonal variables that may help explain changes in product demand.

Key fields include:

sales_date

GDP

inflation_rate

seasonal_factor

Note: The dataset descriptions above reflect the fields referenced in the SQL analysis. Dataset size, date coverage, and the number of unique products have not been specified.

 ### Project Workflow

1. Data Exploration

The analysis began by exploring the available datasets and examining their structures.

SQL techniques used:

SELECT

LIMIT

SHOW COLUMNS

DESCRIBE

This established an understanding of the available variables and prepared the datasets for cleaning and analysis.

2. Data Cleaning and Preparation

Data cleaning was performed to improve consistency and prepare the datasets for reliable analysis.

Key activities included:

Converting sales date fields into the appropriate DATE data type using STR_TO_DATE().

Converting GDP, inflation rate, and seasonal factor fields into numeric data types.

Standardizing promotional values using the ENUM data type.

Enforcing appropriate data types for product identifiers and product costs.

Checking for missing values using conditional aggregation and IS NULL.

Identifying duplicate records using GROUP BY and HAVING.

Removing duplicate records using ROW_NUMBER() and table joins.

These steps established a more consistent data structure for subsequent analysis.

3. Data Integration

To enable comprehensive inventory analysis, the project combined information from the three datasets.

Two SQL views were created:

sales_product_data — combines sales records with product categories and promotional information.

new_inventory_data — enriches the combined sales and product data with external economic and seasonal factors.

The integrated dataset provides a unified foundation for examining product performance, inventory levels, and external influences.

4. Exploratory and Descriptive Analysis

The analysis examined several aspects of inventory and sales performance.

Product Performance

Calculated estimated sales value by multiplying inventory quantity by product cost.

Compared average and total estimated sales values across products.

Ranked products based on their calculated sales values.

Inventory Levels

Examined average inventory quantities by product.

Calculated a median-like inventory statistic using SQL window functions.

Identified products with comparatively high average inventory quantities.

Stockout Analysis

Identified products with zero recorded inventory.

Counted stockout occurrences for selected high-demand products.

Evaluated inventory availability alongside rolling sales averages.

External Factors

Compared inventory quantities across positive and non-positive GDP values.

Examined inventory quantities across positive and non-positive inflation values.

Prepared the data for investigating relationships between external conditions and inventory patterns.

Analytical note: The sales value used in this project is calculated as inventory_quantity × product_cost. This is an estimated inventory-based value, not necessarily actual sales revenue. Likewise, the external-factor comparisons are descriptive and do not independently establish causation.

5. Inventory Optimization

A major component of the project was the calculation of product-level reorder points.

The model uses historical demand patterns, a seven-day lead time, and a target service level of 95%.

The general formula is:

Reorder Point = Lead-Time Demand + Safety Stock

Where:

Lead-Time Demand: Expected demand during the replenishment lead time.

Safety Stock: Additional inventory intended to reduce the risk of stockouts caused by demand variability.

Lead Time: Assumed to be seven days.

Service Level: Targeted at 95%, using a Z-score of approximately 1.645 under the normal-distribution assumption.

The SQL analysis uses rolling averages to estimate recent demand and incorporates demand variability into the reorder point calculations.

The resulting reorder points provide a starting point for identifying when products may require replenishment.

Important: The SQL script contains multiple safety stock calculations. A standard deviation-based safety stock calculation is generally expressed as:

Safety Stock = Z × Standard Deviation of Demand × √Lead Time

The demand variability calculation should therefore be validated to ensure the variance is converted to standard deviation correctly and that the time units are consistent before deploying the model operationally.

6. SQL Automation

The project introduces SQL database objects to support ongoing inventory management.

Inventory Optimization Table

The inventory_optimization table stores calculated reorder points by product.

Stored Procedure: recalculate_reorder_point

Designed to recalculate a product's reorder point using rolling demand statistics and update the optimization table.

Stored Procedure: monitorinventorylevels

Returns average inventory quantities by product to support inventory monitoring.

Stored Procedure: monitorsalestrend

Calculates rolling average sales values over time to help identify changes in product performance.

Stored Procedure: monitorstockout

Counts and ranks stockout occurrences by product.

Trigger: afterinsertunifiedtable

Designed to call the reorder point recalculation procedure after a new record is inserted into the inventory table.

Together, these SQL components demonstrate how database-level automation can support recurring inventory monitoring and replenishment planning.

Implementation note: The trigger and stored procedure definitions should be tested against the final database schema, including product keys, update behavior, and the accuracy of the rolling demand calculations.

### Key Findings

The analysis identified several inventory management concerns.

1. Inventory Imbalances

The initial analysis indicated discrepancies in inventory levels, with evidence of both overstocking and understocking.

These imbalances can tie up working capital in excess inventory while increasing the risk of losing sales when high-demand products are unavailable.

2. Demand Variability

Historical inventory and sales-related measures can help identify differences in product demand.

Rolling averages provide a way to monitor changes over time and support more responsive inventory planning.

3. External Influences

GDP, inflation, and seasonal factors were incorporated into the analysis to explore potential relationships between external conditions and inventory patterns.

These variables may provide useful context for future demand forecasting, although their predictive value requires further statistical validation.

4. Need for Product-Level Replenishment

A single replenishment policy may not be suitable for every product.

Calculating reorder points at the product level provides a framework for tailoring replenishment decisions to individual demand patterns and stockout risks.

Evidence limitation: The SQL script documents these analytical observations, but it does not provide numerical result tables or quantified business improvements. Specific percentages, savings, and forecast accuracy improvements are therefore not claimed in this README.

### Business Recommendations

Based on the analysis, the following actions are recommended.

1. Implement Dynamic Inventory Management

Move from static inventory planning toward a process that regularly considers recent demand, seasonality, and relevant external factors.

Review product demand patterns frequently to identify changing replenishment needs.

2. Optimize Reorder Points and Safety Stock

Use validated reorder point calculations to guide replenishment decisions.

Review lead times, demand variability, and service-level targets regularly so inventory policies remain aligned with business needs.

3. Reduce Overstocking

Identify products with consistently high inventory relative to demand.

Consider adjusting purchasing quantities, reviewing replenishment frequency, and using targeted promotions where commercially appropriate.

4. Prevent Stockouts

Prioritize products with frequent stockout occurrences, particularly those demonstrating strong demand.

Use stockout monitoring to investigate replenishment delays and improve product availability.

5. Improve Demand Forecasting

Combine historical demand patterns with seasonal and economic indicators where their predictive value can be demonstrated.

Validate forecasting methods against historical outcomes before using them to drive purchasing decisions.

6. Establish Continuous Monitoring

Use SQL procedures to monitor inventory levels, sales trends, and stockout frequencies.

Review the results regularly with inventory, procurement, sales, and operations stakeholders.

7. Review Product Pricing and Costs

Evaluate product cost structures and pricing decisions using reliable sales and profitability data.

Because product cost alone does not establish profitability, future analysis should incorporate actual selling prices and relevant operating costs.

📈 Expected Business Benefits

Implementing the recommendations could help TechElectro Inc. achieve the following outcomes:

Reduced Overstocking: Lower the risk of holding excessive inventory.

Fewer Stockouts: Improve product availability through better replenishment planning.

Improved Cost Efficiency: Reduce unnecessary inventory holding and emergency replenishment costs.

Better Decision-Making: Provide stakeholders with structured, data-driven inventory insights.

Improved Customer Satisfaction: Support more reliable product availability.

More Consistent Monitoring: Establish repeatable SQL-based inventory monitoring processes.

These are expected benefits, not measured outcomes from the SQL analysis.

### SQL Skills Demonstrated

This project demonstrates practical SQL skills relevant to data analyst, business intelligence, and operations analytics roles.

Database creation and management

Data exploration and profiling

Data type conversion and standardization

Missing-value analysis

Duplicate detection and removal

Conditional aggregation

Joins and data integration

Views

Common Table Expressions (CTEs)

Subqueries

Window functions, including ROW_NUMBER() and rolling averages

Statistical calculations using SQL

Inventory and sales performance analysis

Reorder point and safety stock calculations

Stored procedures

Database triggers

Business recommendations based on data analysis


### Future Improvements

Potential extensions to this project include:

Developing a demand forecasting model to predict future product requirements.

Incorporating supplier lead-time variability into safety stock calculations.

Creating an inventory performance dashboard in Power BI.

Adding actual sales revenue, purchase prices, and inventory holding costs.

Establishing automated alerts for products approaching their reorder points.

Measuring inventory turnover and days of inventory on hand.

Validating reorder point calculations against historical stockout outcomes.

Evaluating the financial impact of inventory optimization after implementation.

### Conclusion

The TechElectro Inc. Inventory Optimization project demonstrates how MySQL can be used to transform raw inventory-related data into actionable operational insights.

Through data cleaning, dataset integration, descriptive analysis, stockout monitoring, and reorder point calculations, the project establishes a framework for improving inventory planning and replenishment decisions.

By combining structured SQL analysis with continuous monitoring and validated inventory policies, TechElectro Inc. can work toward reducing inventory imbalances, improving product availability, and supporting more cost-efficient operations.

### SQL LINK 
