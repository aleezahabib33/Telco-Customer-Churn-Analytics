CREATE DATABASE telecom_churn_analysis;
USE telecom_churn_analysis;

CREATE TABLE telco_customers (
    customerID VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen TINYINT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    tenure INT,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(25),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(25),
    OnlineBackup VARCHAR(25),
    DeviceProtection VARCHAR(25),
    TechSupport VARCHAR(25),
    StreamingTV VARCHAR(25),
    StreamingMovies VARCHAR(25),
    Contract VARCHAR(20),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(30),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    Churn VARCHAR(5),
    TotalCharges_Clean DECIMAL(10,2)
);
SELECT COUNT(*) AS total_customers
FROM telco_customers;
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customerID) AS unique_customers,
    COUNT(customerID) AS non_null_customer_ids
FROM telco_customers;

SELECT
    COUNT(*) AS zero_tenure_customers
FROM telco_customers
WHERE tenure = 0;
SELECT customerID, tenure, TotalCharges_Clean
FROM telco_customers
WHERE customerID IN (
    '4472-LVYGI',
    '3115-CZMZD',
    '5709-LVOEQ',
    '4367-NUYAO',
    '1371-DWPAZ',
    '7644-OMVMY',
    '3213-VVOLG',
    '2520-SGTTA',
    '2923-ARZLG',
    '4075-WKNIU',
    '2775-SEFEE'
);
SELECT COUNT(*) AS matching_customers
FROM telco_customers
WHERE customerID IN (
    '4472-LVYGI',
    '3115-CZMZD',
    '5709-LVOEQ',
    '4367-NUYAO',
    '1371-DWPAZ',
    '7644-OMVMY',
    '3213-VVOLG',
    '2520-SGTTA',
    '2923-ARZLG',
    '4075-WKNIU',
    '2775-SEFEE'
);

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN tenure = 0 THEN 1 ELSE 0 END) AS zero_tenure_customers
FROM telco_customers;
SELECT
    COUNT(*) AS zero_tenure_customers,
    SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) AS missing_original_charges,
    SUM(CASE WHEN TotalCharges_Clean = 0 THEN 1 ELSE 0 END) AS zero_cleaned_charges
FROM telco_customers
WHERE tenure = 0;
SELECT
    MIN(tenure) AS min_tenure,
    MAX(tenure) AS max_tenure,
    MIN(MonthlyCharges) AS min_monthly_charges,
    MAX(MonthlyCharges) AS max_monthly_charges,
    MIN(TotalCharges_Clean) AS min_total_charges,
    MAX(TotalCharges_Clean) AS max_total_charges
FROM telco_customers;


-- Business Question 1: What is the overall customer churn rate?

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage
FROM telco_customers;

/*Business Insights
Approximately 1 in 4 customers has churned.*/

-- Business Question 2: Which contract type has the highest customer churn rate?

SELECT
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage
FROM telco_customers
GROUP BY Contract
ORDER BY churn_rate_percentage DESC;

/* Business Insight
- Month-to-month customers have the highest churn rate at 42.71%.
- Two-year contract customers have the lowest churn rate at 2.83%.
- Month-to-month churn is approximately 15 times the two-year contract churn rate. */

-- -- Business Question 3: How does customer tenure relate to churn?

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY tenure_group
ORDER BY MIN(tenure);

/* Business Insights
1. New customers (0–12 months) have the highest churn rate: 47.44%.
2. Churn consistently decreases as customer tenure increases.
3. Long-term customers (49–72 months) have the lowest churn rate: 9.51%.
4. Early customer retention appears to be a major business priority.*/

-- -- Business Question 4: How do monthly charges relate to churn?

SELECT
    CASE
        WHEN MonthlyCharges <= 35 THEN 'Low (<= $35)'
        WHEN MonthlyCharges <= 70 THEN 'Medium ($35-$70)'
        ELSE 'High (> $70)'
    END AS monthly_charges_group,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY monthly_charges_group
ORDER BY MIN(MonthlyCharges);

/*Business Insights
1. High-charge customers have the highest churn rate (35.36%).
2. Low-charge customers have the lowest churn rate (10.89%).
3. Churn rate increases across all three monthly-charge groups.
4. The company should investigate pricing concerns and perceived service value among high-charge customers.*/

-- Business Question 5: How does payment method relate to customer churn?

SELECT
    PaymentMethod,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY PaymentMethod
ORDER BY churn_rate_percentage DESC;

/* Business Insights
1. Electronic check users have the highest churn rate: 45.29%.
2. Automatic credit card payments have the lowest churn rate: 15.24%.
3. Electronic check churn is almost three times the automatic credit card churn rate.
4. The company should investigate whether payment convenience, billing experience, or customer preferences are associated with this difference. */

-- Business Question 6: How does internet service type relate to churn?

SELECT
    InternetService,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY InternetService
ORDER BY churn_rate_percentage DESC;

/* Business Insights
1. Fiber optic customers have the highest churn rate (41.89%).
2. Customers without internet service have the lowest churn rate (7.40%).
3. Fiber optic churn is substantially higher than DSL churn.
4. The company should investigate fiber optic service quality, pricing, and customer satisfaction.*/

-- Business Question 7: How does senior citizen status relate to churn?

SELECT
    CASE
        WHEN SeniorCitizen = 1 THEN 'Senior Citizen'
        ELSE 'Non-Senior Citizen'
    END AS customer_group,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY SeniorCitizen
ORDER BY SeniorCitizen;

/* Business Insights
1. Senior citizens have a higher churn rate (41.68%).
2. Non-senior citizens have a churn rate of 23.61%.
3. The difference is 18.07 percentage points.
4. The company should investigate whether senior customers have different support, pricing, or service needs. */

-- Business Question 8: How does online security subscription relate to churn?

SELECT
    OnlineSecurity,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY OnlineSecurity
ORDER BY churn_rate_percentage DESC;

/* Business Insights
1. Customers without online security have the highest churn rate (41.77%).
2. Customers with online security have a much lower churn rate (14.61%).
3. The difference between these two groups is 27.16 percentage points.
4. The company should investigate whether security-service adoption is associated with better customer retention. */

-- Business Question 9: How does tech support subscription relate to churn?

SELECT
    TechSupport,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY TechSupport
ORDER BY churn_rate_percentage DESC;

/* Business Insights
1. Customers without tech support have the highest churn rate (41.64%).
2. Customers with tech support have a much lower churn rate (15.17%).
3. The difference is 26.47 percentage points.
4. Technical support availability and customer experience deserve further investigation.*/

-- Business Question 10: How does partner status relate to churn?

SELECT
    Partner,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY Partner
ORDER BY churn_rate_percentage DESC;

/* Business Insights
1. Customers without partners have a higher churn rate (32.96%).
2. Customers with partners have a churn rate of 19.66%.
3. The difference is 13.30 percentage points.
4. Partner status may help identify customer segments that need closer retention attention.*/

-- Business Question 11: How does dependent status relate to churn?

SELECT
    Dependents,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY Dependents
ORDER BY churn_rate_percentage DESC;

/*Business Insights
1. Customers without dependents have a higher churn rate (31.28%).
2. Customers with dependents have a churn rate of 15.45%.
3. The difference is 15.83 percentage points.
4. Dependent status may help the company understand differences between customer segments.*/

-- Business Question 12: How does paperless billing relate to churn?

SELECT
    PaperlessBilling,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY PaperlessBilling
ORDER BY churn_rate_percentage DESC;

/*Business Insights
1. Customers using paperless billing have a higher churn rate (33.57%).
2. Customers not using paperless billing have a churn rate of 16.33%.
3. The difference is 17.24 percentage points.
4. The company should investigate whether billing preferences, payment experiences, or customer profiles are associated with this difference.*/

-- Business Question 13: How does multiple lines subscription relate to churn?

SELECT
    MultipleLines,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY MultipleLines
ORDER BY churn_rate_percentage DESC;

/*Business Insights
1. Customers with multiple lines have the highest churn rate (28.61%).
2. Customers without multiple lines have a churn rate of 25.04%.
3. The difference between the highest and lowest groups is only 3.68 percentage points.
4. Multiple-line subscription shows a relatively small difference in churn rates compared with several other factors we've analyzed.*/

-- Business Question 14: How does online backup subscription relate to churn?

SELECT
    OnlineBackup,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY OnlineBackup
ORDER BY churn_rate_percentage DESC;

/*Business Insights
1. Customers without online backup have the highest churn rate (39.93%).
2. Customers with online backup have a churn rate of 21.53%.
3. The difference is 18.40 percentage points.
4. Online backup subscription is associated with a noticeably lower churn rate.*/

-- Business Question 15: How does device protection subscription relate to churn?

SELECT
    DeviceProtection,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY DeviceProtection
ORDER BY churn_rate_percentage DESC;

/* Business Insights
1. Customers without device protection have the highest churn rate (39.13%).
2. Customers with device protection have a churn rate of 22.50%.
3. The difference is 16.63 percentage points.
4. Device protection subscription is associated with a lower churn rate.*/

-- Business Question 16: How does Streaming TV subscription relate to churn?

SELECT
    StreamingTV,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY StreamingTV
ORDER BY churn_rate_percentage DESC;

/*Business Insights
1. Customers without Streaming TV have a slightly higher churn rate (33.52%).
2. Customers with Streaming TV have a churn rate of 30.07%.
3. The difference is 3.45 percentage points.
4. Streaming TV has a relatively small difference between the two internet-service customer groups.*/

-- Business Question 17: How does Streaming Movies subscription relate to churn?

SELECT
    StreamingMovies,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate_percentage

FROM telco_customers
GROUP BY StreamingMovies
ORDER BY churn_rate_percentage DESC;

/* Business Insights
1. Customers without Streaming Movies have a churn rate of 33.68%.
2. Customers with Streaming Movies have a churn rate of 29.94%.
3. The difference is 3.74 percentage points.
4. Streaming Movies shows a relatively small difference between customers with and without the service.*/


-- Consolidated Analysis: Overall churn rate by major customer segments

SELECT
    'Contract' AS customer_segment,
    Contract AS higher_risk_group,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY Contract
ORDER BY churn_rate DESC;

/* Business Insight: 
Month-to-month customers are the highest-risk contract group.*/

-- Consolidated Churn Risk Analysis
-- Purpose: Compare churn rates across major customer segments.

SELECT
    'Contract' AS customer_segment,
    Contract AS higher_risk_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS churn_rate
FROM telco_customers
GROUP BY Contract

UNION ALL

SELECT
    'Internet Service',
    InternetService,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY InternetService

UNION ALL

SELECT
    'Online Security',
    OnlineSecurity,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY OnlineSecurity

ORDER BY churn_rate DESC;

-- Consolidated Churn Risk Analysis

SELECT
    'Contract' AS customer_segment,
    Contract AS higher_risk_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS churn_rate
FROM telco_customers
GROUP BY Contract

UNION ALL

SELECT
    'Internet Service',
    InternetService,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY InternetService

UNION ALL

SELECT
    'Online Security',
    OnlineSecurity,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY OnlineSecurity

UNION ALL

SELECT
    'Senior Citizens',
    CASE
        WHEN SeniorCitizen = 1 THEN 'Yes'
        ELSE 'No'
    END,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY SeniorCitizen

UNION ALL

SELECT
    'Tech Support',
    TechSupport,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY TechSupport

UNION ALL

SELECT
    'Online Backup',
    OnlineBackup,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY OnlineBackup

UNION ALL

SELECT
    'Device Protection',
    DeviceProtection,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY DeviceProtection

UNION ALL

SELECT
    'Monthly Charges',
    CASE
        WHEN MonthlyCharges <= 35 THEN 'Low (<= $35)'
        WHEN MonthlyCharges <= 70 THEN 'Medium ($35-$70)'
        ELSE 'High (> $70)'
    END,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)
FROM telco_customers
GROUP BY
    CASE
        WHEN MonthlyCharges <= 35 THEN 'Low (<= $35)'
        WHEN MonthlyCharges <= 70 THEN 'Medium ($35-$70)'
        ELSE 'High (> $70)'
    END

UNION ALL

SELECT
    'Paperless Billing',
    PaperlessBilling,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )
FROM telco_customers
GROUP BY PaperlessBilling

UNION ALL

SELECT
    'Dependents',
    Dependents,
    COUNT(*),
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )
FROM telco_customers
GROUP BY Dependents
ORDER BY churn_rate DESC;

-- Business Question 18: Which customer groups have the most churned customers?

SELECT
    Contract,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY Contract
ORDER BY churned_customers DESC;

/*Business insight: 
Month-to-month contracts account for approximately 89% of all churned customers. This makes them a major priority for retention campaigns.
Notice the difference: the month-to-month churn rate is 42.71%, while its share of all churned customers is 88.55%. .*/

-- Business Question 19: Churned customers by tenure group

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY tenure_group
ORDER BY churned_customers DESC;

/*Business insight: 
More than half of all churned customers left within their first 12 months.*/

-- Business Question 20: Churned customers by payment method

SELECT
    PaymentMethod,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY PaymentMethod
ORDER BY churned_customers DESC;

/*Business insight: 
Electronic check customers account for approximately 57% of all churned customers. 
The company should investigate whether payment friction, billing experience, or differences in customer profiles are associated with this pattern.*/

-- Business Question 21: Churned customers by internet service

SELECT
    InternetService,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY InternetService
ORDER BY churned_customers DESC;

/*Business insight: 
Nearly 70% of churned customers used Fiber optic service. 
This makes Fiber optic customers an important group to investigate for service quality, pricing, and customer satisfaction.*/

-- Business Question 22: Churned customers by senior citizen status

SELECT
    CASE
        WHEN SeniorCitizen = 1 THEN 'Senior Citizen'
        ELSE 'Non-Senior Citizen'
    END AS customer_group,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY SeniorCitizen
ORDER BY churned_customers DESC;

/*Business Insight:
Although senior citizens have a higher churn rate (41.68%), non-senior citizens account for approximately 75% of all churned customers 
because they represent a much larger customer population.*/

-- Business Question 23: Churned customers by online security

SELECT
    OnlineSecurity,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY OnlineSecurity
ORDER BY churned_customers DESC;

/*Business insight: 
More than 78% of churned customers did not have an online security subscription. 
Customers without this service also had a much higher churn rate (41.77%) than customers with it (14.61%).*/

-- Business Question 24: Churned customers by tech support

SELECT
    TechSupport,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY TechSupport
ORDER BY churned_customers DESC;

/*Business insight: 
Approximately 77% of churned customers did not have Tech Support. 
Their churn rate was also much higher (41.64%) than customers with Tech Support (15.17%).*/

-- Business Question 25: Churned customers by partner status

SELECT
    Partner,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY Partner
ORDER BY churned_customers DESC;

/*Business insight: 
Customers without partners account for approximately 64% of all churned customers. 
Their churn rate (32.96%) is also higher than customers with partners (19.66%).*/

-- Business Question 26: Churned customers by dependent status

SELECT
    Dependents,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY Dependents
ORDER BY churned_customers DESC;

/*Business insight: 
Customers without dependents account for approximately 83% of all churned customers. 
Their churn rate (31.28%) is also higher than customers with dependents (15.45%).*/

-- Business Question 27: Churned customers by paperless billing

SELECT
    PaperlessBilling,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY PaperlessBilling
ORDER BY churned_customers DESC;

/*Business insight: 
Approximately 75% of churned customers used paperless billing. 
Their churn rate (33.57%) was also higher than customers using non-paperless billing (16.33%).*/

-- Business Question 28: Churned customers by monthly charge group

SELECT
    CASE
        WHEN MonthlyCharges <= 35 THEN 'Low (<= $35)'
        WHEN MonthlyCharges <= 70 THEN 'Medium ($35-$70)'
        ELSE 'High (> $70)'
    END AS monthly_charge_group,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY monthly_charge_group
ORDER BY churned_customers DESC;

/*Business insight: 
Nearly 68% of churned customers belonged to the high monthly charge group. 
This suggests that higher-billing customers deserve attention through pricing reviews, value-based offers, and service-quality improvements.*/

-- Business Question 29: Churned customers by online backup

SELECT
    OnlineBackup,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY OnlineBackup
ORDER BY churned_customers DESC;

/*Business insight: 
Approximately 66% of churned customers did not have Online Backup. 
Their churn rate (39.93%) was also considerably higher than customers with this service (21.53%).*/

-- Business Question 30: Churned customers by device protection

SELECT
    DeviceProtection,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY DeviceProtection
ORDER BY churned_customers DESC;

/*Business insight: 
Nearly 65% of churned customers did not subscribe to Device Protection. 
Their churn rate (39.13%) was considerably higher than customers with the service (22.50%)*/

-- Business Question 31: Churned customers by multiple lines

SELECT
    MultipleLines,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY MultipleLines
ORDER BY churned_customers DESC;

/*Business insight: 
Customers with and without Multiple Lines contributed almost equal numbers of churned customers (850 vs. 849).
The difference between their churn rates is relatively small (28.61% vs. 25.04%).*/

-- Business Question 32: Churned customers by streaming TV

SELECT
    StreamingTV,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY StreamingTV
ORDER BY churned_customers DESC;

/*Business insight: 
Customers without Streaming TV contributed slightly more churned customers than those with it. 
However, their churn rates were relatively close (33.52% vs. 30.07%).*/

-- Business Question 33: Churned customers by streaming movies

SELECT
    StreamingMovies,
    COUNT(*) AS churned_customers
FROM telco_customers
WHERE Churn = 'Yes'
GROUP BY StreamingMovies
ORDER BY churned_customers DESC;

/*Business insight: 
Customers without Streaming Movies contributed slightly more churned customers than customers with the service. 
Their churn rates were also relatively close (33.68% vs. 29.94%).*/

-- Customer-Level Churn Risk Profiling --

-- Business Question 34: Customer churn by number of high-risk characteristics

WITH customer_risk AS (
    SELECT
        customerID,
        Churn,
        (
            CASE WHEN Contract = 'Month-to-month' THEN 1 ELSE 0 END +
            CASE WHEN tenure <= 12 THEN 1 ELSE 0 END +
            CASE WHEN InternetService = 'Fiber optic' THEN 1 ELSE 0 END +
            CASE WHEN OnlineSecurity = 'No' THEN 1 ELSE 0 END +
            CASE WHEN TechSupport = 'No' THEN 1 ELSE 0 END +
            CASE WHEN MonthlyCharges > 70 THEN 1 ELSE 0 END +
            CASE WHEN PaymentMethod = 'Electronic check' THEN 1 ELSE 0 END
        ) AS risk_factor_count
    FROM telco_customers
)

SELECT
    risk_factor_count,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM customer_risk
GROUP BY risk_factor_count
ORDER BY risk_factor_count;

/* Key business insights
1. Customers with zero risk characteristics have only a 1.21% churn rate.
2. Customers with five risk characteristics have a 44.64% churn rate.
3. Customers with all seven characteristics have a 74.17% churn rate.
4. The seven-factor group contains 484 customers, of whom 359 churned.
5. The difference between the zero-factor and seven-factor groups is 72.96 percentage points.*/

-- Business Question 35: Churned customer contribution by risk group

WITH customer_risk AS (
    SELECT
        customerID,
        Churn,
        (
            CASE WHEN Contract = 'Month-to-month' THEN 1 ELSE 0 END +
            CASE WHEN tenure <= 12 THEN 1 ELSE 0 END +
            CASE WHEN InternetService = 'Fiber optic' THEN 1 ELSE 0 END +
            CASE WHEN OnlineSecurity = 'No' THEN 1 ELSE 0 END +
            CASE WHEN TechSupport = 'No' THEN 1 ELSE 0 END +
            CASE WHEN MonthlyCharges > 70 THEN 1 ELSE 0 END +
            CASE WHEN PaymentMethod = 'Electronic check' THEN 1 ELSE 0 END
        ) AS risk_factor_count
    FROM telco_customers
)

SELECT
    risk_factor_count,
    COUNT(*) AS churned_customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM telco_customers WHERE Churn = 'Yes'),
        2
    ) AS contribution_to_total_churn
FROM customer_risk
WHERE Churn = 'Yes'
GROUP BY risk_factor_count
ORDER BY churned_customers DESC;

/*Key business insights
- The 6-risk-factor group contributes the most churned customers: 466 (24.93%).
- The 7-risk-factor group has the highest churn rate (74.17%), but contributes 19.21% of total churn.
- Groups with 5, 6, or 7 risk factors account for 65.54% of all churned customers.*/

-- Business Question 36: Average monthly charges by churn status

SELECT
    Churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(MonthlyCharges), 2) AS average_monthly_charges,
    ROUND(MIN(MonthlyCharges), 2) AS minimum_monthly_charges,
    ROUND(MAX(MonthlyCharges), 2) AS maximum_monthly_charges
FROM telco_customers
GROUP BY Churn;

/*Business insights
1. Churned customers have higher average monthly charges.
2. This supports our earlier finding that the high monthly-charge group has a higher churn rate.
3. The company should investigate whether pricing, perceived value, or service expectations contribute to customer dissatisfaction.*/

-- Business Question 37: Average total charges by churn status

SELECT
    Churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(TotalCharges_Clean), 2) AS average_total_charges,
    ROUND(SUM(TotalCharges_Clean), 2) AS total_customer_spending
FROM telco_customers
GROUP BY Churn;

/* Key business insights
1. Retained customers have approximately $1,018.11 higher average total charges.
2. Churned customers have higher average monthly charges ($74.44 vs. $61.27), but lower accumulated total charges.
3. This difference is consistent with churned customers having shorter customer relationships and less time to accumulate charges.*/

-- Business Question 38: Average tenure by churn status

SELECT
    Churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(tenure), 2) AS average_tenure_months,
    MIN(tenure) AS minimum_tenure,
    MAX(tenure) AS maximum_tenure
FROM telco_customers
GROUP BY Churn;

/*Business insights
- Churned customers have substantially shorter relationships.
- Early customer retention is particularly important.
- The first 12 months deserve special attention because our earlier analysis showed a 47.44% churn rate in that group.*/

-- Business Question 39: Churned customers with month-to-month contracts and low tenure

SELECT
    COUNT(*) AS matching_churned_customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM telco_customers
         WHERE Churn = 'Yes'),
        2
    ) AS percentage_of_total_churn
FROM telco_customers
WHERE Churn = 'Yes'
  AND Contract = 'Month-to-month'
  AND tenure <= 12;
  
/*  Business Question 40 — How many customers have all three major risk characteristics?
Now we'll examine customers who have:
1. Month-to-month contract.
2. Tenure of 12 months or less.
3. Monthly charges above $70.*/

-- Business Question 40: Customers with three major risk characteristics

SELECT
    Churn,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM telco_customers
         WHERE Churn = 'Yes'),
        2
    ) AS percentage_of_all_churned
FROM telco_customers
WHERE Contract = 'Month-to-month'
  AND tenure <= 12
  AND MonthlyCharges > 70
GROUP BY Churn;

-- Business Question 41: Churn rate by payment method type

SELECT
    CASE
        WHEN PaymentMethod = 'Electronic check'
            THEN 'Electronic Check'
        ELSE 'Other Payment Methods'
    END AS payment_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM telco_customers
GROUP BY payment_group;

/*Business insight: 
Electronic check customers are a high-priority segment for retention analysis. 
The business should investigate payment experience, billing preferences, and customer characteristics.*/

-- Business Question 42: Churn rate by contract and internet service

SELECT
    Contract,
    InternetService,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM telco_customers
GROUP BY Contract, InternetService
ORDER BY churn_rate DESC;

/*Business Insight:
Month-to-month + Fiber optic customers have the highest churn rate: 54.61%.*/

-- Business Question 43: Churn rate by contract and payment method

SELECT
    Contract,
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM telco_customers
GROUP BY Contract, PaymentMethod
ORDER BY churn_rate DESC;

/*Business Insight:
Month-to-month + Electronic check customers have the highest churn rate: 53.73%.*/

-- Business Question 44: Churn rate by tenure group and contract

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM telco_customers
GROUP BY tenure_group, Contract
ORDER BY churn_rate DESC;

/*Business Insight:
New customers (0–12 months) with month-to-month contracts have the highest churn rate: 51.35%.

Key observations:
1. Month-to-month customers have the highest churn rate in every tenure group.
2. Month-to-month churn declines as tenure increases, from 51.35% to 26.02%.
3. Two-year contract groups show very low churn across all tenure groups.
4. The largest churn count in this combination analysis is 1,024 customers in the first-year, month-to-month group.*/

-- Business Question 45: Churn rate by internet service and online security

SELECT
    InternetService,
    OnlineSecurity,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM telco_customers
GROUP BY InternetService, OnlineSecurity
ORDER BY churn_rate DESC;

/*Key business insight:
- Fiber optic customers without online security have the highest churn rate: 49.36%.
- For both Fiber optic and DSL customers, the group without online security has a higher churn rate than the group with it.
- Fiber optic customers with online security still have a higher churn rate than DSL customers with online security.*/

-- Business Question 46: Churn rate by monthly charges group and contract

SELECT
    CASE
        WHEN MonthlyCharges <= 35 THEN 'Low (<= $35)'
        WHEN MonthlyCharges <= 70 THEN 'Medium ($35-$70)'
        ELSE 'High (> $70)'
    END AS monthly_charges_group,
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM telco_customers
GROUP BY
    monthly_charges_group,
    Contract
ORDER BY churn_rate DESC;

/*Business insights:
1. High monthly charges combined with month-to-month contracts show the highest churn rate: 52.69%.
2. Among month-to-month customers, churn increases as monthly charges increase.
3. Longer contracts are associated with substantially lower churn across all three charge groups.
4. Even high-charge customers on two-year contracts have only a 4.81% churn rate.*/

-- Business Question 47: Churn rate by tenure group and monthly charges

-- Business Question 47: Churn Rate by Tenure Group and Monthly Charges

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    CASE
        WHEN MonthlyCharges <= 35 THEN 'Low (<= $35)'
        WHEN MonthlyCharges <= 70 THEN 'Medium ($35-$70)'
        ELSE 'High (> $70)'
    END AS monthly_charge_group,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY tenure_group, monthly_charge_group
ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk segment: New customers (0–12 months) with high monthly charges have a 67.89% churn rate.
2. High monthly charges are associated with higher churn across every tenure group.
3. Churn generally decreases as customer tenure increases, even among high-charge customers.
4. Long-term customers with low monthly charges have the lowest churn rate: just 1.34%.*/

-- Business Question 48: Churn Rate by Senior Citizen and Contract

SELECT
    CASE
        WHEN SeniorCitizen = 1 THEN 'Senior Citizen'
        ELSE 'Non-Senior Citizen'
    END AS customer_type,

    Contract,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY SeniorCitizen, Contract
ORDER BY churn_rate DESC;

/*Business insights
1. Senior citizens on month-to-month contracts have the highest churn rate: 54.65%.
2. Within every contract category, senior citizens have a higher churn rate than non-senior citizens.
3. Two-year contracts are associated with much lower churn for both customer groups.
4. Contract type appears to be an important factor when identifying high-risk customer segments.*/

-- Business Question 49: Churn Rate by Partner Status and Contract

SELECT
    Partner,
    Contract,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY Partner, Contract
ORDER BY churn_rate DESC;

/*Business insights
1. Customers without partners on month-to-month contracts have the highest churn rate: 44.69%.
2. Within each contract type, customers without partners have slightly higher churn.
3. Two-year contracts show low churn regardless of partner status.
4. Contract type appears to have a stronger association with churn than partner status in these results.*/

-- Business Question 50: Churn Rate by Dependents and Contract

SELECT
    Dependents,
    Contract,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY Dependents, Contract
ORDER BY churn_rate DESC;

/*Business insights
1. Customers without dependents on month-to-month contracts have the highest churn rate: 45.24%.
2. Customers with dependents show lower churn across all three contract types.
3. Two-year contracts are associated with low churn regardless of dependent status.
4. Month-to-month customers without dependents could be prioritized for retention campaigns.*/

-- Business Question 51: Churn Rate by Payment Method and Internet Service

SELECT
    InternetService,
    PaymentMethod,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY InternetService, PaymentMethod
ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk combination: Fiber optic customers using electronic checks have a 53.23% churn rate.
2. Electronic check customers have higher churn rates than automatic payment customers across all three internet-service categories.
3. Fiber optic customers show higher churn than DSL customers for every payment method.
4. Automatic payment methods, particularly credit cards and bank transfers, are associated with lower churn in this dataset.*/

-- Business Question 52: Churn Rate by Online Security and Tech Support

SELECT
    OnlineSecurity,
    TechSupport,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY OnlineSecurity, TechSupport
ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk segment: Customers without both online security and tech support have a 48.96% churn rate.
2. Customers with both services have a much lower churn rate of 9.01%.
3. Having either one of these services is associated with lower churn than having neither.
4. The difference between the highest and lowest internet-service customer groups is substantial, although customers with no internet service are a separate category.*/

-- Business Question 53: Churn Rate by Online Backup and Device Protection

SELECT
    OnlineBackup,
    DeviceProtection,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY OnlineBackup, DeviceProtection
ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk segment: Customers without online backup and device protection have a 45.92% churn rate.
2. Customers with both services have a lower churn rate of 16.92%.
3. Having both services is associated with lower churn than having only one.
4. The pattern is similar to our previous security and tech support analysis: customers without additional services tend to show higher churn.*/

-- Business Question 54: Churn Rate by Paperless Billing and Payment Method

SELECT
    PaperlessBilling,
    PaymentMethod,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY PaperlessBilling, PaymentMethod
ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk combination: Paperless billing customers using electronic checks have a 49.77% churn rate.
2. Electronic check customers have higher churn than customers using other payment methods in both billing groups.
3. Automatic payment methods show lower churn rates than electronic checks.
4. Paperless billing customers show higher churn rates within every payment method category.*/

-- Business Question 55: Churn Rate by Gender and Contract

SELECT
    gender,
    Contract,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY gender, Contract
ORDER BY churn_rate DESC;

/*Business insights
1. Female customers on month-to-month contracts have the highest churn rate: 43.74%.
2. The difference between female and male churn rates is relatively small within each contract category.
3. Contract type shows a much larger difference in churn than gender.
4. Both genders have very low churn rates with two-year contracts.*/

-- Business Question 56: Churn Rate by Phone Service and Multiple Lines

SELECT
    PhoneService,
    MultipleLines,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY PhoneService, MultipleLines
ORDER BY churn_rate DESC;

/*Business insights
1. Customers with multiple phone lines have the highest churn rate at 28.61%.
2. Customers with one phone line and customers without phone service have very similar churn rates.
3. The difference between the highest and lowest groups is only 3.68 percentage points.
4. Phone configuration appears less strongly associated with churn than contract type, tenure, or payment method in our earlier analyses.*/

-- Business Question 57: Churn Rate by Streaming TV and Streaming Movies

SELECT
    StreamingTV,
    StreamingMovies,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY StreamingTV, StreamingMovies
ORDER BY churn_rate DESC;

/*Business insights
1. Customers without either streaming service have the highest churn rate: 34.44%.
2. Customers subscribing to both services have a lower churn rate of 29.43%.
3. Having one or both streaming services is associated with slightly lower churn.
4. The differences between internet customers are relatively small compared with the contract and tenure patterns we discovered earlier.*/

-- Business Question 58: Average Customer Charges and Tenure by Churn Status

SELECT
    Churn,

    COUNT(*) AS total_customers,

    ROUND(AVG(tenure), 2) AS avg_tenure_months,

    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,

    ROUND(AVG(TotalCharges_Clean), 2) AS avg_accumulated_charges,

    ROUND(SUM(TotalCharges_Clean), 2) AS total_accumulated_charges

FROM telco_customers
GROUP BY Churn
ORDER BY Churn;

/*Business insights
1. Tenure difference: Retained customers stay approximately 19.59 months longer on average.
2. Monthly charges: Churned customers pay $13.17 more per month on average.
3. Accumulated spending: Retained customers have $1,018.11 higher average accumulated charges.
4. Revenue opportunity: Customers who leave early represent a potential opportunity for improving customer retention and long-term revenue.*/

-- Business Question 59: Average Monthly Charges by Tenure Group and Churn

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    Churn,

    COUNT(*) AS total_customers,

    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,

    ROUND(AVG(TotalCharges_Clean), 2) AS avg_accumulated_charges

FROM telco_customers
GROUP BY tenure_group, Churn
ORDER BY
    CASE tenure_group
        WHEN '0-12 Months' THEN 1
        WHEN '13-24 Months' THEN 2
        WHEN '25-48 Months' THEN 3
        ELSE 4
    END,
    Churn;
    
/*Business insights
1. Churned customers have higher average monthly charges in all four tenure groups.
2. The largest monthly charge difference is in the 49–72 month group: $20.14.
3. Even long-tenure customers who eventually churn have relatively high monthly charges.
4. Early-tenure churn remains a major concern, but pricing and service value should also be investigated among longer-tenure customers.*/

-- Business Question 60: Customer Profile by Contract and Churn

SELECT
    Contract,
    Churn,

    COUNT(*) AS total_customers,

    ROUND(AVG(tenure), 2) AS avg_tenure_months,

    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,

    ROUND(AVG(TotalCharges_Clean), 2) AS avg_accumulated_charges

FROM telco_customers
GROUP BY Contract, Churn
ORDER BY Contract, Churn;

/*Business insights
1. Month-to-month customers: Churned customers stayed 7.01 months less on average and paid $11.56 more per month.
2. One-year contracts: Churned customers actually had higher average tenure (44.96 months) than retained customers (41.67 months).
3. Two-year contracts: Churned customers also had higher average tenure and monthly charges.
4. Across all three contract types, churned customers had higher average monthly charges.*/

-- Business Question 61: Churn Rate by Tenure Group and Payment Method

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    PaymentMethod,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY tenure_group, PaymentMethod
ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk segment: New customers using electronic checks have a 61.96% churn rate.
2. Electronic check customers show higher churn than other payment groups in every tenure category.
3. Electronic-check churn decreases as tenure increases, from 61.96% in the first year to 21.56% in the longest-tenure group.
4. Mailed-check customers in the 49–72 month group have the lowest churn rate, just 1.19%.*/

-- Business Question 62: Churn Rate by Tenure Group and Online Security

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    OnlineSecurity,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY tenure_group, OnlineSecurity
ORDER BY churn_rate DESC;

/*Business insights
1. New customers without online security have the highest churn rate: 60.84%.
2. Customers without online security show higher churn across every tenure group.
3. Churn generally decreases as tenure increases, regardless of security status.
4. Long-term customers with online security have a relatively low churn rate of 6.67%.*/

-- Business Question 63: Churn Rate by Tenure Group and Tech Support

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    TechSupport,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY tenure_group, TechSupport
ORDER BY churn_rate DESC;

/*Business insights
1. New customers without tech support have the highest churn rate: 60.29%.
2. Customers without tech support have higher churn across every tenure group.
3. Churn generally decreases as tenure increases.
4. Long-term customers with tech support have a relatively low churn rate of 6.55%.*/

-- Business Question 64: Churn Rate by Tenure Group and Internet Service

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    InternetService,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY tenure_group, InternetService
ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk segment: New fiber optic customers have a 69.88% churn rate.
2. Fiber optic customers have higher churn than DSL customers in every tenure group.
3. Fiber optic churn declines from 69.88% in the first year to 17.06% in the longest-tenure group.
4. New DSL customers also have considerable churn at 40%.*/

-- Business Question 65: Churn Rate by Monthly Charges and Payment Method

SELECT
    CASE
        WHEN MonthlyCharges <= 35 THEN 'Low (<= $35)'
        WHEN MonthlyCharges <= 70 THEN 'Medium ($35-$70)'
        ELSE 'High (> $70)'
    END AS monthly_charge_group,

    PaymentMethod,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY monthly_charge_group, PaymentMethod
ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk combination: Customers paying more than $70 monthly and using electronic checks have a 49.88% churn rate.
2. Electronic-check customers show higher churn than other payment groups in every monthly-charge category.
3. High-charge customers generally have higher churn than low-charge customers within each payment method.
4. Low-charge customers using automatic credit-card payments have the lowest churn rate: 4.66%.*/

-- Business Question 66: Churn Rate by Senior Citizen and Payment Method

SELECT
    CASE
        WHEN SeniorCitizen = 1 THEN 'Senior Citizen'
        ELSE 'Non-Senior Citizen'
    END AS customer_type,

    PaymentMethod,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY SeniorCitizen, PaymentMethod
ORDER BY churn_rate DESC;

/*Business insights
1. Senior citizens using electronic checks have the highest churn rate: 53.37%.
2. Electronic checks are associated with higher churn in both age groups.
3. Senior citizens show higher churn than non-seniors across every payment method.
4. Automatic payment methods have lower churn rates than electronic checks in both groups.*/

-- Business Question 67: Churn Rate by Partner and Dependents

SELECT
    Partner,
    Dependents,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY Partner, Dependents
ORDER BY churn_rate DESC;

/*Business insights
1. Customers with neither a partner nor dependents have the highest churn rate: 34.24%.
2. Customers with both a partner and dependents have the lowest churn rate: 14.24%.
3. Having dependents is associated with lower churn in both partner groups.
4. Household characteristics may help create more meaningful customer segments for retention campaigns.*/

-- Business Question 68: Churn by Contract, Internet Service, and Online Security

SELECT
    Contract,
    InternetService,
    OnlineSecurity,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY
    Contract,
    InternetService,
    OnlineSecurity

ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk segment: Month-to-month Fiber optic customers without Online Security have a 58.12% churn rate.
2. Within month-to-month Fiber customers, the churn rate is 21.11 percentage points lower among customers with Online Security.
3. Longer contracts are associated with substantially lower churn across the internet-service groups.
4. The combination of a two-year contract, DSL, and Online Security has only 1.65% churn.*/

-- Business Question 69: Churn by Tenure, Contract, and Payment Method

SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    Contract,
    PaymentMethod,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY
    tenure_group,
    Contract,
    PaymentMethod

ORDER BY churn_rate DESC;

/*Business insights
1. Highest-risk segment: New customers (0–12 months) on month-to-month contracts using electronic checks have a 63.10% churn rate.
2. Electronic-check customers on month-to-month contracts show consistently high churn across tenure groups.
3. Longer contracts are generally associated with lower churn.
4. Several two-year contract segments have zero observed churn, but some contain very few customers. Don't interpret these small groups as guaranteed low-risk populations.*/

-- Business Question 70: Customer Churn Risk Segmentation

WITH customer_risk AS (
    SELECT
        customerID,
        Churn,

        (CASE WHEN Contract = 'Month-to-month'
            THEN 1 ELSE 0 END
        +
        CASE WHEN tenure <= 12
            THEN 1 ELSE 0 END
        +
        CASE WHEN InternetService = 'Fiber optic'
            THEN 1 ELSE 0 END
        +
        CASE WHEN OnlineSecurity = 'No'
            THEN 1 ELSE 0 END
        +
        CASE WHEN TechSupport = 'No'
            THEN 1 ELSE 0 END
        +
        CASE WHEN MonthlyCharges > 70
            THEN 1 ELSE 0 END
        +
        CASE WHEN PaymentMethod = 'Electronic check'
            THEN 1 ELSE 0 END
        ) AS risk_score

    FROM telco_customers
)

SELECT
    risk_score,
    COUNT(*) AS total_customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,

    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END)
        AS retained_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM customer_risk
GROUP BY risk_score
ORDER BY risk_score;

/*Final business insights
1. Highest-risk group: Customers with all 7 risk factors have a 74.17% churn rate.
2. Lowest-risk group: Customers with none of the risk factors have a 1.21% churn rate.
3. Churn generally increases as the number of risk factors increases.
4. Customers with 5–7 risk factors account for a substantial share of churn and deserve retention attention.*/