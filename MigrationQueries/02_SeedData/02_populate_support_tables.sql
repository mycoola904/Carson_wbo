-- =============================================================================
-- Seed Data for Support Tables
-- Description: This script populates the support tables with initial data that is required for the migration to function correctly.
-- =============================================================================



use ModMigration
-- Populate ContactType table

INSERT [dbo].[ContactType] ([Type]) VALUES (N'Operations/Service')

INSERT [dbo].[ContactType] ([Type]) VALUES (N'A/P Contact')

INSERT [dbo].[ContactType] ([Type]) VALUES (N'Other Contact')

drop table if exists xBillCycles

CREATE TABLE [dbo].[xBillCycles](
	[System_Val] [varchar](4) NULL,
	[Cycle] [varchar](30) NULL
) ON [PRIMARY]

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'300', N'Monthly')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'301', N'Quarterly 1 (Jan, Apr, ...)')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'302', N'Quarterly 2 (Feb, May, ...)')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'303', N'Quarterly 3 (Mar, Jun, ...)')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'304', N'Bi-Monthly')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'305', N'Semi-Annually')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'306', N'Annually ')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'307', N'Weekly')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'308', N'Bi-Weekly')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'309', N'4-Month Cycle')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'310', N'4 Weeks')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'311', N'Per work order')

INSERT [dbo].[xBillCycles] ([System_Val], [Cycle]) VALUES (N'312', N'Per Job')

--  Billing groups

/* This remarked section was originally intended for RM97 to pull billing groups from the udef table where name like '%BILLTYPE%'
   However, it was found that the LOB table is used in RMO.
   Therefore, the insertion now pulls data from the LOB table instead.
*/
-- insert into BillingGroup (BillingGroup, Description, BillingGroupID)
-- select  u.DATA Description,u.DATA Description, u.UNIQUE_ID
-- from ConversionData.dbo.udef u
-- where name like '%BILLTYPE%'

insert into BillingGroup (BillingGroup, Description, BillingGroupID)
select Description, Description, LOBID
from ConversionData.dbo.LOB

--  status

insert into Status (Status, Description, StatusID, SysValue)
SELECT  data
		, SystemValDefined
      ,UNIQUE_ID
      ,SYSTEM_VAL
     
  FROM [dbo].[CustomerStatusMapping]



-- Service Category
insert into ServiceCategory(ServiceCategory, Description, ServiceCategoryID)
select Description ServiceCategory,  Description, CodeCategoryID ServiceCategoryID
--select *
from ConversionData.dbo.CodeCategory

-- Unit of Measure
insert into UnitOfMeasure(UnitOfMeasure, Description, UnitOfMeasureID)
select Description UnitOfMeasure, Description, UOMID UnitOfMeasureID
from ConversionData.dbo.CodeUom 



-- Container Unit of Measure
insert into ContainerUOM( ContainerUOM, Description, ContainerUOMID)
select c.Description, c.Description, c.ContainerUOMID
from conversiondata.dbo.ContainerUOM c

-- Companies
--select *
--from Company

insert into Company(Company, Description, CompanyID)
select COMPANY, COMPANY, CMPY_ID
from ConversionData.dbo.CMPY


-- Finance Charge
--select C_ID_ALPHA, B_STMT_TYP
--from ConversionData.dbo.cust c

insert into FinanceCharge(Description, FinanceChargeID)
select --name,
DATA as Description, UNIQUE_ID as FinanceChargeID
from ConversionData.dbo.udef ba
where ba.NAME like '%FINCHARGE%'

-- B_DELINQ
insert into DelinquencyLevel(Description, DelinquencyLevelID)
select --name, 
DATA as Description, UNIQUE_ID as DelinquencyLevelID
from ConversionData.dbo.udef u
where u.NAME like '%DELINQNOTE%'

-- B_B_CYCLE
insert into BillingCycle(Description, BillingCycleID, Cycle)
select --name, 
DATA as Description, UNIQUE_ID as BillingCycleID
, x.Cycle
from ConversionData.dbo.udef u
inner join xBillCycles x on x.System_Val = u.SYSTEM_VAL
where u.NAME like '%BILLCYCLE%'

-- bill area
insert into BillArea(Description, BillAreaID)
select BillArea as Description, BillAreaID
--select *
from ConversionData.dbo.BillArea ba


-- B_STMT_TYP
insert into StatementType(Description, StatementTypeID)
select --name, 
DATA as Description, UNIQUE_ID as StatementTypeID
from ConversionData.dbo.udef u
where u.NAME like '%STMNTTYPE%'

-- B_TAXAREA
--select c_id_alpha, b_taxarea, dbo.Uname(b_taxarea)
--from ConversionData.dbo.cust  

insert into TaxArea(Description, TaxAreaID)
select --name, 
DATA as Description, UNIQUE_ID as TaxAreaID
from ConversionData.dbo.udef u
where u.NAME like '%TAXAREA%'

-- B_TERMS
--select c_id_alpha, B_TERMS, dbo.Uname(B_TERMS)
--from ConversionData.dbo.cust  

insert into Terms(Description, TermsID)
select --name, 
DATA as Description, UNIQUE_ID as TermsID
from ConversionData.dbo.udef u
where u.NAME like '%TERMS%'

-- Customer Reps
insert into CustomerRep(Name, Phone, Email, CommisionPlan, CustomerRepID)
select r.NAME, isnull(r.PHONE,''), isnull(r.EMAIL,''), isnull(r.COMMPLAN,'') as CommisionPlan, r.REP_ID as CustomerRepID
--select *
from ConversionData.dbo.REPS r

--B_BILL_INFO1
--select c_id_alpha, B_BILL_INFO1, dbo.Uname(B_BILL_INFO1)
--from ConversionData.dbo.cust  

insert into BillScreenInfo(UdefName, Description, BillScreenInfoID)
select name as UdefName, DATA as Description, UNIQUE_ID as BillScreenInfoID
from ConversionData.dbo.udef u
where u.NAME like '%BILLINFO%'

--B_SURCHARGE
--select c_id_alpha, B_SURCHARGE, dbo.Uname(B_SURCHARGE)
--from ConversionData.dbo.cust  

insert into SurchargeArea(Description, SurchargeAreaID)
select --name, 
DATA as Description, UNIQUE_ID as SurchargeAreaID
from ConversionData.dbo.udef u
where u.NAME like '%SURCHARGE%'


insert into RouteType(Description, RouteTypeID)
SELECT RT.DATA RouteType, rt.UNIQUE_ID RouteTypeID
FROM  ConversionData.DBO.UDEF RT 
where name like '%CONTROUTE%'


drop table if exists RouteDays

CREATE TABLE [dbo].[RouteDays](
	[mon] [int] NULL,
	[tue] [int] NULL,
	[wed] [int] NULL,
	[thu] [int] NULL,
	[fri] [int] NULL,
	[sat] [int] NULL,
	[sun] [int] NULL,
	[DayValue] [int] NULL,
	[WhichDay] [varchar](30) NULL
) ON [PRIMARY]

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (1, 0, 0, 0, 0, 0, 0, 2, N'Monday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 1, 0, 0, 0, 0, 0, 3, N'Tuesday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 1, 0, 0, 0, 0, 4, N'Wednesday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 0, 1, 0, 0, 0, 5, N'Thursday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 0, 0, 1, 0, 0, 6, N'Friday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 0, 0, 0, 1, 0, 7, N'Saturday')

INSERT [dbo].[RouteDays] ([mon], [tue], [wed], [thu], [fri], [sat], [sun], [DayValue], [WhichDay]) VALUES (0, 0, 0, 0, 0, 0, 1, 1, N'Sunday')


/* Route Frequency */

drop table if exists RouteFrequency

CREATE TABLE [dbo].[RouteFrequency](
	[Key] [varchar](10) NULL,
	[Value] [varchar](30) NULL
) ON [PRIMARY]

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'E', N'1 x week')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'A', N'EOW')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'B', N'EOW')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'1W', N'1 x week')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'2W', N'Every Other Week')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'3W', N'Every 3 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'4W', N'Every 4 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'5W', N'Every 5 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'6W', N'Every 6 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'7W', N'Every 7 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'8W', N'Every 8 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'9W', N'Every 9 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'10W', N'Every 10 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'11W', N'Every 11 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'12W', N'Every 12 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'13W', N'Every 13 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'14W', N'Every 14 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'15W', N'Every 15 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'16W', N'Every 16 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'17W', N'Every 17 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'18W', N'Every 18 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'19W', N'Every 19 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'20W', N'Every 20 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'21W', N'Every 21 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'22W', N'Every 22 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'23W', N'Every 23 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'24W', N'Every 24 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'25W', N'Every 25 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'26W', N'Every 26 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'27W', N'Every 27 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'28W', N'Every 28 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'29W', N'Every 29 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'30W', N'Every 30 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'31W', N'Every 31 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'32W', N'Every 32 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'33W', N'Every 33 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'34W', N'Every 34 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'35W', N'Every 35 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'36W', N'Every 36 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'37W', N'Every 37 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'38W', N'Every 38 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'39W', N'Every 39 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'40W', N'Every 40 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'41W', N'Every 41 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'42W', N'Every 42 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'43W', N'Every 43 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'44W', N'Every 44 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'45W', N'Every 45 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'46W', N'Every 46 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'47W', N'Every 47 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'48W', N'Every 48 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'49W', N'Every 49 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'50W', N'Every 50 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'51W', N'Every 51 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'52W', N'Every 52 Weeks')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'2D', N'Every 2 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'3D', N'Every 3 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'4D', N'Every 4 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'5D', N'Every 5 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'6D', N'Every 6 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'7D', N'Every 7 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'8D', N'Every 8 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'9D', N'Every 9 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'10D', N'Every 10 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'11D', N'Every 11 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'12D', N'Every 12 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'13D', N'Every 13 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'14D', N'Every 14 Days')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'1st', N'First Week Monthly')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'2nd', N'Second Week Monthly')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'3rd', N'Third Week Monthly')

INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'4th', N'Forth Week Montly')
INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'ODD', N'Every Other Week')
INSERT [dbo].[RouteFrequency] ([Key], [Value]) VALUES (N'EVEN', N'Every Other Week')


drop table if exists ServiceCodeDetail

CREATE TABLE [dbo].[ServiceCodeDetail](
	[id] [bigint] NULL,
	[DMAccount] [nvarchar](19) NULL,
	[# Used] [int] NULL,
	[ServiceCode] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](250) NULL,
	[ServiceCategory] [varchar](255) NULL,
	[linkstat] [varchar](255) NULL,
	[size] [nvarchar](255) NULL,
	[unit] [nvarchar](255) NULL,
	[action] [nvarchar](255) NULL,
	[frequency] [nvarchar](255) NULL,
	[ServiceMap] [nvarchar](511) NULL,
	[container] [nvarchar](255) NULL,
	[type] [nvarchar](255) NULL
) ON [PRIMARY]
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (1, N'889', 126, N'65GAL', N'65GAL Toter 1X Week Residential', N'RESIDENTIAL', NULL, N'65', N'Gallon', N'Service', N'1 per week', N'65GAL|65', N'65 Gallon', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (2, N'998', 1568, N'96GAL', N'96gal Toter 1X Week Residential', N'RESIDENTIAL', NULL, N'96', N'Gallon', N'Service', N'1 per week', N'96GAL|96', N'96 Gallon', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (3, N'790', 23, N'ADDTOTER', N'Additional Toter 96GAL', N'RESIDENTIAL', NULL, N'96', N'Gallon', N'Service', N'', N'ADDTOTER|96', N'96 Gallon', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (4, N'6288', 171, N'Cardboard Removal', N'Cardboard Removal', N'COMMERCIAL', NULL, N'0', N'', N'Service', N'', N'Cardboard Removal|0', N'', N'Cardboard')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (5, N'95', 205, N'COM', N'Commercial Waste Service', N'COMMERCIAL', N'FALSE', N'0', N'', N'Service', N'', N'COM|0', N'', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (6, N'6290', 589, N'Container Frontload', N'Commercial Waste Service', N'COMMERCIAL', N'FALSE', N'0', N'', N'Service', N'', N'Container Frontload|0', N'', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (7, N'89', 68, N'FHHA', N'Forest Heights Homeowners Association-96GAL', N'RESIDENTIAL', NULL, N'96', N'Gallon', N'Service', N'', N'FHHA|96', N'96 Gallon', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (8, N'471', 2, N'FHHA65', N'Forest Heights Homeowners Association-65GAL', N'RESIDENTIAL', NULL, N'65', N'Gallon', N'Service', N'', N'FHHA65|65', N'65 Gallon', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (9, N'679', 2, N'LITEBAG', N'Residential Lite Bag 1x week', N'RESIDENTIAL', NULL, N'', N'Bag', N'Service', N'1 per week', N'LITEBAG|', N' Bag', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (10, N'6288', 165, N'Recycling', N'Commercial Recycling', N'COMMERCIAL', NULL, N'', N'', N'Service', N'', N'Recycling|', N'', N'Recycle')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (11, N'6264', 135, N'Red Bin Recycling', N'Red Bin Recycling', N'COMMERCIAL', NULL, N'', N'Bin', N'Service', N'', N'Red Bin Recycling|', N' Bin', N'Recycle')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (12, N'999', 2000, N'RES1', N'Residential once a week', N'RESIDENTIAL', NULL, N'', N'', N'Service', N'1 per week', N'RES1|', N'', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (13, N'987', 171, N'RES2', N'Residential senior dis', N'RESIDENTIAL', NULL, N'', N'', N'Service', N'', N'RES2|', N'', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (14, N'6292', 30, N'The Horizon', N'The Horizon- 1x week w/recycling', N'RESIDENTIAL', NULL, N'', N'', N'Service', N'1 per week', N'The Horizon|', N'', N'Recycle')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (15, N'5688', 3, N'VETDISC', N'Residential 1x week Military Discount', N'RESIDENTIAL', NULL, N'', N'', N'Service', N'1 per week', N'VETDISC|', N'', N'Waste')
GO
INSERT [dbo].[ServiceCodeDetail] ([id], [DMAccount], [# Used], [ServiceCode], [ServiceDescription], [ServiceCategory], [linkstat], [size], [unit], [action], [frequency], [ServiceMap], [container], [type]) VALUES (16, N'1974', 1, N'XDUMP', N'Extra Dump', N'COMMERCIAL', N'FALSE', N'', N'', N'', N'', N'', N'', N'Waste')
GO
