USE [aero]
GO
/****** Object:  Table [dbo].[PDCL]    Script Date: 15.03.2022 14:54:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

select Deal, sum(Sum) as debt, min(Date) as dept_start_date, DATEDIFF(day, max(DATE), GETDATE()) as days_of_dapt
from PDCL
group by Deal
having sum(Sum)>0

GO
