-- CAC PER CHANNEL

Select Marketing_Channel, Sum(CAC) as Total_CAC
from
(
SELECT *,Marketing_Spend/New_Customers as CAC
FROM [NEW DATABASE].[dbo].customer_acquisition_cost_dataset)X
  
Group by Marketing_Channel



--BREAK EVEN CUSTOMERS
SELECT Marketing_Channel, Sum(Break_even_Customers) as Total_Break_even_Customers
from(
SELECT Marketing_Channel, Marketing_Spend/CAC as Break_even_Customers
from
(
 SELECT *,Marketing_Spend/New_Customers as CAC
FROM [NEW DATABASE].[dbo].customer_acquisition_cost_dataset)x
)y
Group by Marketing_Channel
