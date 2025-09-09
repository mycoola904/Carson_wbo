-- ========================================================================
-- NextBillingDates.sql
-- Description:
-- This script creates a table with the next billing dates based on historical billing data and the billing cycle.
-- It calculates the next billing date based on the cycle type (e.g., weekly, monthly, quarterly).
-- ========================================================================

--select *
--from xBillCycles

--select  h.BILLCYCLE, u.SYSTEM_VAL, x.Cycle
--from ConversionData.dbo.HIST h
--inner join ConversionData.dbo.udef u on u.UNIQUE_ID = h.BILLCYCLE
--inner join xBillCycles x on x.System_Val = u.SYSTEM_VAL
--where cast(TRANS_DATE as date) > '12/31/2023' and type = 'A'
--group by h.BILLCYCLE, u.SYSTEM_VAL, x.Cycle

--select *
--from xBillCycles
use ModMigration

drop table if exists ModMigration.dbo.billingdates

select row_number() over(order by bc.unique_id) ID,  bc.UNIQUE_ID, bc.DATA BillCycle
, x.Cycle
, cast(date_time as date) PostedForDate
, cast(TRANS_DATE as date) PostedDate
, count(hist_id) NoOfRecords
into ModMigration.dbo.BillingDates
-- select count(1)
from conversiondata.dbo.HIST h
inner join conversiondata.dbo.UDEF bc on h.BILLCYCLE = bc.UNIQUE_ID
left join ModMigration.dbo.xBillCycles x on x.System_Val = bc.SYSTEM_VAL
where type = 'A'
and descript not like 'prora%'
--and bc.data like 'ann%'
and cast(TRANS_DATE as date) > '12/31/2023'
group by bc.UNIQUE_ID, bc.DATA, x.Cycle, cast(h.DATE_TIME as date), cast(h.TRANS_DATE as date)
order by cast(TRANS_DATE as date) desc, bc.DATA

--select *
--from BillingDates
--order by BillCycle, PostedForDate desc

--select *
--from BillingDates
--where BillCycle like 'wee%'
--order by BillCycle, PostedForDate desc




drop table if exists ModMigration.dbo.NextBillingDate

select bd.UNIQUE_ID, bd.BillCycle, bd.Cycle, bd.PostedForDate, bd.PostedDate, 
case when bd.Cycle like 'Quar%' then dateadd(MONTH, 3, bd.PostedForDate) 
when bd.Cycle like '28%' then dateadd(day, 28, bd.PostedForDate) 
when bd.Cycle like 'Ann%' then dateadd(YEAR, 1, bd.PostedForDate)
when bd.Cycle like 'Semi-Ann%' then dateadd(MONTH, 6, bd.PostedForDate)
when bd.Cycle like 'bi%' then dateadd(MONTH, 2, bd.PostedForDate)
when bd.BillCycle = 'WEEKLY' then dateadd(DAY, 7, bd.PostedForDate) 
else dateadd(MONTH, 1, bd.PostedForDate) end NextBillingDate
into ModMigration.dbo.NextBillingDate
from ModMigration.dbo.BillingDates bd
inner join 
(
select UNIQUE_ID, BillCycle, Cycle, max(PostedDate) PostedDate
from ModMigration.dbo.BillingDates
where BillCycle not like '28%' and 
BillCycle not like 'on%call'
group by UNIQUE_ID, BillCycle, Cycle
) t on t.UNIQUE_ID = bd.UNIQUE_ID
and bd.PostedDate = t.PostedDate
order by BillCycle

---- for 28 day cycle
--insert into NextBillingDate(UNIQUE_ID, BillCycle, Cycle)
--select UNIQUE_ID,  DATA, '28 day'
--from ConversionData.dbo.UDEF
--where data like '%28 day%'

select *
from NextBillingDate