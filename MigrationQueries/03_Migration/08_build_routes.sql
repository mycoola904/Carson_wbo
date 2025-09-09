/* EDITED FOR CARSON */

USE ModMigration

drop table if exists [RTESMigration]

CREATE TABLE [dbo].[RTESMigration](
	[ROUTEID] [int] NOT NULL,
	[DESCRIPT] [varchar](60) NULL,
	[ROUTENUM] [nvarchar](20) NULL,
	[MON] [bit] NOT NULL,
	[TUE] [bit] NOT NULL,
	[WED] [bit] NOT NULL,
	[THU] [bit] NOT NULL,
	[FRI] [bit] NOT NULL,
	[SAT] [bit] NOT NULL,
	[SUN] [bit] NOT NULL,
	[TYPE] [int] NULL,
	[DRIVER] [int] NULL,
	[TRUCK] [nvarchar](5) NULL,
	[COMMENT] [varchar](50) NULL,
	[CMPY_ID] [int] NULL,
	[CAPACITY] [int] NULL,
	[MASTER_ROUTE] [bit] NOT NULL,	
	[BUDGET_HRS] [numeric](18, 6) NULL,
	[GeoCodeLastChanged] [datetime] NULL,
	[DISP_ID] [int] NULL,
	--[Updated] [datetime] NULL,
	[NewRouteid] [int] NOT NULL,
	[NewRouteNum] varchar(60) null,
	Stops int null
) ON [PRIMARY]


insert INTO RTESMigration
SELECT  r.ROUTEID, r.DESCRIPT, r.ROUTENUM, r.MON, r.TUE, r.WED, r.THU, r.FRI, r.SAT, r.SUN, r.TYPE, r.DRIVER, r.TRUCK, r.COMMENT, 1 CMPY_ID, r.CAPACITY, r.MASTER_ROUTE, r.BUDGET_HRS, 
                         r.GeoCodeLastChanged
						 --  DISP_ID ONLY EXISTS IN RM97 AND THEREFORE THIS IS NULL FOR WASTEBOOKS (CARSON)
						 , Null DISP_ID
, r.ROUTEID, r.ROUTENUM, rx.Stops
--SELECT MAX(LEN(R.ROUTENUM))
FROM ConversionData.DBO.RTES R
left join (
select rx.ROUTEID, count(distinct rx.STOPID) Stops
from ConversionData.dbo.rxrf rx
inner join ConversionData.dbo.cust cu on cu.c_id = rx.C_ID
group by rx.ROUTEID
) rx on rx.ROUTEID = r.ROUTEID



/* COMMENTED OUT FOR Carson BECAUSE THEY ONLY HAVE ONE COMPANY */
--insert INTO RTESMigration
--SELECT r.[ROUTEID]
--      ,[DESCRIPT]
--      ,[ROUTENUM]
--      ,[MON]
--      ,[TUE]
--      ,[WED]
--      ,[THU]
--      ,[FRI]
--      ,[SAT]
--      ,[SUN]
--      ,[TYPE]
--      ,[TRUCK]
--      ,[COMMENT]
--      ,
--	  case 
--	  when t.[CMPY_ID] is null then r.CMPY_ID
--	  else t.CMPY_ID end [CMPY_ID]
--      ,[CAPACITY]
--      ,[MASTER_ROUTE]
--      ,[DRIVER]
--      ,[BUDGET_HRS]
--      ,[GeoCodeLastChanged]
--      ,[DISP_ID]
--      ,null [Updated]
--      , row_number() over(order by r.routeid) + (select max(NewRouteid) from RTESMigration) [NewRouteid]
--      ,case 
--	  when t.[CMPY_ID] is null then r.[ROUTENUM]
--	  else r.[ROUTENUM] + '-C'+ cast(t.cmpy_id as varchar) end [NewRouteNum]
--	  ,t.Stops
----select count(1)
--from ConversionData.dbo.RTES r
--left join (
--	select rt.ROUTEID, cm.CMPY_ID, count(distinct rx.stopid) Stops
--	from ConversionData.dbo.rxrf rx
--	INNER JOIN ConversionData.DBO.RTES RT ON RT.ROUTEID = RX.ROUTEID
--	inner join ConversionData.dbo.cust cu on cu.c_id = rx.C_ID
--	INNER JOIN ConversionData.DBO.CMPY CM ON CM.CMPY_ID = CU.B_BILL_CO
--	WHERE RT.CMPY_ID = 0
--	group by rt.ROUTEID, cm.CMPY_ID
--) t on t.ROUTEID = r.ROUTEID
--where r.CMPY_ID = '0'