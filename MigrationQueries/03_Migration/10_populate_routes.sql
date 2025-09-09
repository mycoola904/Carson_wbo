
/* Populate RouteType table from ConversionData.dbo.RTYP
   Note: RouteType.RouteTypeID is populated with RTYP.TYPE
   Note: RouteType.RouteTypeDescription is populated with RTYP.DESCRIPT
*/

/* populate routes 
*/
use ModMigration



insert into [Route](RouteID, RouteNo, RouteDescription, Notes, VehicleType, SingleDayRoute, Company_id, RouteType_id
,Mon ,Tue ,Wed,Thu ,Fri,Sat,Sun
) 
select r.NewRouteid RouteID, NewRouteNum RouteNo, isnull(r.DESCRIPT, '') RouteDescription, isnull(r.COMMENT,'') Notes, '' VehicleType, dbo.fn_IsSingleDayRoute(routeid) SingleDayRoute
, co.id Company_id, rt.id RouteType_id,
case when r.MON = 1 then 1 else 0 end Mon,
case when r.TUE = 1 then 1 else 0 end Tue,
case when r.WED = 1 then 1 else 0 end Wed,
case when r.THU = 1 then 1 else 0 end Thu,
case when r.FRI = 1 then 1 else 0 end Fri,
case when r.SAT = 1 then 1 else 0 end Sat,
case when r.SUN = 1 then 1 else 0 end Sun
-- select count(1)
from RTESMigration r
left join RouteType rt on rt.RouteTypeID = r.TYPE
left join Company co on co.id = r.CMPY_ID




/* Populate RouteStops table from ConversionData.dbo.RXRF
   Note: RouteStops.NextDate is populated with RXRF.NEXT_DATE
   Note: RouteStops.Stop is populated with RXRF.STOP
   Note: RouteStops.StopID is populated with RXRF.STOPID
   Note: RouteStops.Comments is populated with RXRF.COMMENT
   Note: RouteStops.StopFrequency is populated with RouteFrequency.Value
*/
insert into RouteStops(C_ID, StopID, Stop, Comments, StopFrequency, NextDate, Account_id, Child_id, Route_id, rxFreq)
select rx.C_ID, rx.STOPID StopID, case when rx.STOP = 'E' then 0 else ISNULL(TRY_CAST(REPLACE(rx.STOP, ',', '') AS INT), 0) end Stop
, isnull(rx.COMMENT, '') Comments
, rf.[Value], rx.NEXT_DATE
, a.id as Account_id
, ch.id as Child_id
, r.id as Route_id
, rx.FREQUENCY
-- select count(1)
-- select cu.c_id_alpha
from ConversionData.dbo.RXRF rx
inner join ConversionData.dbo.rtes rt on rt.ROUTEID = rx.ROUTEID
inner join ConversionData.dbo.cust cu on cu.C_ID = rx.C_ID
inner join Route r on r.RouteID = rx.ROUTEID
inner join RouteFrequency rf on rf.[Key] = rx.Frequency
left join Child ch on ch.C_ID = rx.C_ID
left join Account a on a.C_ID = rx.C_ID


--select rs.*, r.RouteNo
--from RouteStops rs
--inner join ConversionData.dbo.RXRF rx on rx.STOPID = rs.StopID
--inner join Route r on r.RouteID = rx.ROUTEID
--order by r.RouteNo

--select *
--from Route