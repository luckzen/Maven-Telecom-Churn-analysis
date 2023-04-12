--DATA CLEANING AND DATA PREPARATION

SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM public.customer_churn;

--cheacking for duplicates 
SELECT customer_id, COUNT(customer_id) AS customer_count
FROM public.customer_churn
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;

--updating multiple lines column 
UPDATE public.customer_churn
SET multiple_lines = 'No'
WHERE phone_service ILIKE 'NO';

--updating internet type column 
UPDATE public.customer_churn
SET internet_type = 'None'
WHERE internet_service = 'No';

--updating average monthly GB download column 
UPDATE public.customer_churn
SET avg_monthly_gb_download = 0
WHERE internet_service = 'No';

-- updating online security column
UPDATE public.customer_churn
SET online_security = 'None'
WHERE internet_service = 'No';

--updating online backup column 
UPDATE public.customer_churn
SET  online_backup = 'No'
WHERE internet_service = 'No';

--updating device protection plan column 
UPDATE public.customer_churn
SET device_protection_plan = 'No'
WHERE internet_service = 'No';

--updating premium tech support column
UPDATE public.customer_churn
SET premium_tech_supp = 'No'
WHERE internet_service = 'No';

--updating streaming tv column 
UPDATE public.customer_churn
SET streaming_tv = 'No'
WHERE internet_service = 'No';

--updating streaming movies column
UPDATE public.customer_churn
SET streaming_movies = 'No'
WHERE internet_service = 'No';

--updating streaming music column
UPDATE public.customer_churn
SET streaming_music = 'No'
WHERE internet_service = 'No';

--updating unlimited data column
UPDATE public.customer_churn
SET unlimited_data = 'No'
WHERE internet_service = 'No';

--INTERVIEWING THE DATA / DEEP DIVE ANALYSIS(Why are customers leaving Maven Telecom?)

--Total number of customers
SELECT COUNT(customer_id)
FROM public.customer_churn;
--7043 total customers

--Total number of customers joined 
SELECT customer_status, COUNT(customer_status) 
FROM public.customer_churn
WHERE customer_status = 'Joined'
GROUP BY customer_status;
--454 customers joined the company

--Revenue lost from churned customers
SELECT customer_status, SUM(total_revenue)
FROM public.customer_churn
WHERE customer_status = 'Churned'
GROUP BY customer_status;

--Lost percentage revenu
SELECT customer_status, round(CAST(SUM(total_revenue) AS numeric (10,2))/ SUM(SUM(total_revenue)) OVER(),3)*100 AS percentage_Revenue
FROM public.customer_churn
GROUP BY customer_status;
-- (INSIGHT) company has lost about 17.2% of its revenue becauseofthe lost customers.

-- Avarage TENURE for churned customers
SELECT 
	CASE 
		WHEN tenure_in_months <= 6 THEN '6 months or less'
		WHEN tenure_in_months <= 12 THEN 'less than 12 months'
		WHEN tenure_in_months <= 24 THEN 'less than 24 months'
		ELSE 'more than 2 years'
	END AS TENURE, COUNT(customer_id)AS churned_Customers, round((COUNT(customer_id)/SUM(COUNT(customer_id)) OVER()),3)*100 AS churned_percentage

FROM public.customer_churn
WHERE customer_status = 'Churned'
GROUP BY TENURE
ORDER BY churned_percentage DESC;
--42% of churned customers only stayed less than 6 months

--REASON WHY CUSTOMERS LEAVE
SELECT churn_category, COUNT(churn_category) AS Churned_customers, ROUND((COUNT(churn_category)/SUM(COUNT(churn_category)) OVER()),3)*100 AS Percentage
FROM public.customer_churn
WHERE customer_status= 'Churned'
GROUP BY churn_category
ORDER BY Churned_customers DESC;

--REASON WHY CUSTOMERS LEFT FROM REVENUE VIEW POINT
SELECT churn_category, SUM(total_revenue) lost_revenue, ROUND((SUM(total_revenue)/SUM(SUM(total_revenue)) OVER()), 3)*100 AS Peercentage_lost
FROM public.customer_churn
WHERE customer_status = 'Churned'
GROUP BY churn_category
ORDER BY lost_revenue DESC;
--(INSIGHT) 46% of churned revenue is because of the competition

--The exact Specific reasons why customers left
SELECT churn_reason, COUNT(customer_id) churned_customers, ROUND((COUNT(customer_id)/SUM(COUNT(customer_id)) OVER()),3)*100 AS Percentage
FROM public.customer_churn
WHERE customer_status= 'Churned'
GROUP BY churn_reason
ORDER BY churned_customers DESC
LIMIT 10;
--16.7% and 16.6% say competition had a better devide and made a better offer respectively and 11.8 said its beacuse of attitute of support person

--Specific reason why we lost revenue
SELECT churn_reason, SUM(total_revenue) lost_revenue, ROUND((SUM(total_revenue)/SUM(SUM(total_revenue)) OVER()), 3)*100 AS Peercentage_lost
FROM public.customer_churn
WHERE customer_status = 'Churned'
GROUP BY churn_reason
ORDER BY lost_revenue DESC
LIMIT 10;
--(INSIGHT) over 30% of churned revenue is because of the competition had a better offer and better devices and 11% cuz of attitute of support person

--To try solve the "better offer reason", we look at the kind of offers our churned customers had
SELECT offer, COUNT(customer_id) AS no_customers,(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER())*100 AS Perc
FROM public.customer_churn
WHERE (customer_status = 'Churned' AND churn_reason = 'Competitor made better offer' )
GROUP BY offer
ORDER BY Perc DESC
--(INSIGNT) 56% churned customers had no offer and 25% had offer E, offer A had the list number of customers leaving

--The other reason why customers left is bacause of the Attitute of support person,lets look if they had premium_tech_supp
SELECT premium_tech_supp, COUNT(customer_id) AS no_customers, Round(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(),3)*100 AS Perc
FROM public.customer_churn
WHERE (customer_status = 'Churned' AND churn_reason = 'Attitude of support person')
GROUP BY premium_tech_supp
ORDER BY Perc DESC
--(INSIGHT)As expected 88% percent dont, giving the same training to all support stuff could be a possible solution

--contract that churned customers were on
SELECT contract, COUNT(customer_id) AS no_customers, ROUND((COUNT(customer_id)/SUM(COUNT(customer_id)) OVER()),4)*100 AS Perc
FROM public.customer_churn
WHERE customer_status= 'Churned'
GROUP BY contract
ORDER BY perc DESC;
--89% were on month to month contract

--Cities with most churned customers
SELECT city, COUNT(customer_id) churned_customers
FROM public.customer_churn
WHERE customer_status= 'Churned'
GROUP BY city
ORDER BY churned_customers DESC
LIMIT 5;










