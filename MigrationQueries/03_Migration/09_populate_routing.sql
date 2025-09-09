-- populate routing

USE ModMigration

-- insert singleday and one multiday
insert into Routing(RouteID, RouteNo, RouteDescription, WhichDay, Notes, VehicleType, PickUpInterval, Haulier
					, RouteManagementType, NextPlannedDate, SingleDayRoute, Company_id, RouteType_id, NoOfStops)
select r.NewRouteid RouteID, r.NewRouteNum RouteNo, isnull(r.DESCRIPT, '') RouteDescription
,case 
	when mon = 1 then 'Monday'
	when TUE = 1 then 'Tuesday'
	when wed = 1 then 'Wednesday'
	when thu = 1 then 'Thursday'
	when fri = 1 then 'Friday'
	when sat = 1 then 'Saturday'
	when sun = 1 then 'Sunday'
	else '' end [WhichDay]
,isnull(r.COMMENT, '') Notes
,'' [VehicleType]
,case 
	when dbo.fn_IsSingleDayRoute(r.ROUTEID) = 0 then 'MultiDay'
	else 'Weekly' end [PickUpInterval]
,'' [Haulier], 
'' [RouteManagementType],
cast (dbo.nextday (case 
	when mon = 1 then 2
	when TUE = 1 then 3
	when wed = 1 then 4
	when thu = 1 then 5
	when fri = 1 then 6
	when sat = 1 then 7
	when sun = 1 then 1
	else 0 end) as date) NextPlannedDate
,dbo.fn_IsSingleDayRoute(r.ROUTEID) SingleDayRoute
, co.id Company_id
, rt.id RouteType_id
, r.Stops NoOfStops
-- select count(1)
from RTESMigration r
--left join (
--select ROUTEID, count(STOPID) Stops
--from ConversionData.dbo.rxrf rx
--inner join (select distinct c_id from CustomerLocations) cl on cl.C_ID = rx.C_ID
--group by ROUTEID
--) rx on rx.ROUTEID = r.ROUTEID
left join RouteType rt on rt.RouteTypeID = r.TYPE
left join Company co on co.id = r.CMPY_ID


-- insert other multidays
insert into Routing(RouteID, RouteNo, RouteDescription, WhichDay, Notes, VehicleType, PickUpInterval, Haulier
					, RouteManagementType, NextPlannedDate, SingleDayRoute, Company_id, RouteType_id, NoOfStops)
select r.ROUTEID RouteID, r.RouteNo, r.RouteDescription
,case 
	when dr.mon = 1 then 'Monday'
	when dr.TUE = 1 then 'Tuesday'
	when dr.wed = 1 then 'Wednesday'
	when dr.thu = 1 then 'Thursday'
	when dr.fri = 1 then 'Friday'
	when dr.sat = 1 then 'Saturday'
	when dr.sun = 1 then 'Sunday'
	else '' end [WhichDay]
,isnull(r.Notes, '')
,r.[VehicleType]
,case 
	when dbo.fn_IsSingleDayRoute(r.RouteID) = 0 then 'MultiDay'
	else 'Weekly' end [PickUpInterval]
,r.[Haulier], 
'' [RouteManagementType],
cast (dbo.nextday (case 
	when dr.mon = 1 then 2
	when dr.TUE = 1 then 3
	when dr.wed = 1 then 4
	when dr.thu = 1 then 5
	when dr.fri = 1 then 6
	when dr.sat = 1 then 7
	when dr.sun = 1 then 1
	else 0 end) as date) NextPlannedDate
,r.SingleDayRoute
, r.Company_id
,r.RouteType_id
, rx.Stops NoOfStops
-- select count(1)
from routing r
inner join ConversionData.dbo.rtes ro on ro.ROUTEID = r.RouteID
left join (
select ROUTEID, count(STOPID) Stops
from ConversionData.dbo.rxrf rx
inner join (select distinct c_id from CustomerLocations) cl on cl.C_ID = rx.C_ID
group by ROUTEID
) rx on rx.ROUTEID = r.RouteID
inner join RouteDays dr on dr.mon = ro.mon 
	or dr.tue = ro.tue 
	or dr.wed = ro.WED
	or dr.thu = ro.THU
	or dr.fri = ro.FRI
	or dr.sat = ro.SAT
	or dr.sun = ro.SUN
	--where r.RouteNo = 'ES'
	where r.PickUpInterval = 'multiday'


-- delete duplicate days from multi-day routes
while exists (
select top(1) RouteID
from Routing
group by RouteID, WhichDay
having count(id)>1
)
begin
delete R
-- select r.*
from Routing R
inner join
(
select RouteID, WhichDay, max(id) maxid
from Routing
group by RouteID, WhichDay
having count(id)>1
) t on t.maxid = R.id
end


delete
from Routing
where routeno = ''

select *
from Routing
order by RouteNo