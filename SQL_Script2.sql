USE [aero]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ToMonth]
    @MonthNumber real = 0

AS
BEGIN

	SET NOCOUNT ON;

WITH cte AS
(
  SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1 AS [Incrementor]
  FROM   [master].[sys].[columns] sc1
  CROSS JOIN [master].[sys].[columns] sc2
),
Data_table as (Select months, CAST(sum(payments) AS DECIMAL(15, 2)) as payments
from
(Select MONTH(day) months, 
case
when payment_sum is null
then CAST((max(payment_sum) OVER(ORDER BY MONTH(day) ASC ROWS BETWEEN CURRENT ROW AND 4 FOLLOWING)) AS DECIMAL(15, 2))/5
else (case 
when lag(MONTH(day)) OVER(ORDER BY MONTH(day) ASC) is not null
then CAST(payment_sum AS DECIMAL(15, 2))/5
else CAST(payment_sum AS DECIMAL(15, 2))
end)
end payments
from payments a
right join
(SELECT DATEADD(DAY, cte.[Incrementor], (SELECT min(payment_dt) FROM payments)) as day
FROM   cte
WHERE  DATEADD(DAY, cte.[Incrementor], (SELECT min(payment_dt) FROM payments)) <= (SELECT max(payment_dt) FROM payments)) b
on a.payment_dt=b.day
where DATEPART(WEEKDAY, day) not in (6, 7)) m
group by months)
SELECT * from Data_table
where months in 
(select case
when @MonthNumber in (select months from Data_table)
then @MonthNumber
else months
end filter
from Data_table)
order by months

END
