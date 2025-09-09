use ModMigration

drop table if exists RouteAssignments 

-- INSERT SINGLE SERVICE STOPS

select rs.STOPID, sap.AutoID, rs.routeid 
into RouteAssignments
from v_CustWithSingleRoute ss
inner join (
	select * from CustomerServiceAgreementPrices where [Action] = 'Service'
	) sap on sap.c_id = ss.c_id
inner join v_RouteStops rs on rs.c_id = sap.c_id




-- INSERT SINGLE ROUTE SERVICE STOPS
insert into RouteAssignments
select rx.STOPID, sap.AutoID, rx.ROUTEID
--select distinct sap.AutoID
from v_UnassignedServices sap
inner join [v_CustWithSingleRoute] sr on sr.C_ID = sap.c_id
inner join  ConversionData.dbo.RXRF rx on rx.C_ID = sr.C_ID




--- MATCH SERVICES WITH ROUTE STOPS BY TYPE

-- select us.c_id, AutoID, us.ServiceCode, us.ServiceDescription, us.DMAccount, sd.type
--select distinct sd.type
insert into RouteAssignments
select rs.STOPID, us.AutoID, rs.ROUTEID-- , sd.type, rs.RouteType
from v_UnassignedServices us 
inner join ServiceCodeDetail sd on sd.ServiceCode = us.ServiceCode
inner join v_RouteStops rs on rs.c_id = us.c_id
	and rs.RouteType = case 
		--when sd.[type] = 'Other' then rs.RouteType
		when sd.[type] like '%card%' and rs.RouteType like '%recy%' then rs.RouteType
		when sd.[type] like '%recy%' and rs.RouteType like '%card%' then rs.RouteType
		else sd.[type]
		end
--where us.AutoID = 11079
group by rs.STOPID, us.AutoID, rs.ROUTEID

drop table if exists TempAssignments 

select 
	row_number() over(order by soh.id) SOAssignmentId,
	soh.id SiteOrderUniqueRef,
	'Service' Action,
	case 
when isnull(rt.mon,0) = 1 then 1
when isnull(rt.tue,0) = 1 then 2
when isnull(rt.wed,0) = 1 then 3
when isnull(rt.thu,0) = 1 then 4
when isnull(rt.fri,0) = 1 then 5
when isnull(rt.sat,0) = 1 then 6
when isnull(rt.sun,0) = 1 then 7
end [DayOfWeek],
	isnull(rt.ROUTENUM,'') RouteTemplate,
	rx.Stop Position,
	case 
	when isnull(rx.Frequency,'') = 'E' then '1W' 
	when isnull(rx.Frequency,'') in ('A','B') then 'EOW' 
	else isnull(rx.frequency,'') end PickUpInterval,
	soh.ContainerType ContainerType,
	isnull(rx.NEXT_DATE,'') StartDate,
	'Routed' RoutedOrScheduled,
	'' MinLiftQuantity,
	'' RequiresQuantity,
	'' NextDueDate,
	rx.COMMENT Notes,
	'' SJVehicle,
	'' SJDriver,
	--'' AgreeNbr,
	soh.DMAccount
	,rx.STOPID
	into TempAssignments
	-- 	 select count(1)
	from SiteOrderHeader soh
	inner join CustomerServiceAgreementPrices sap on sap.id = soh.ServiceID
	inner join (
		select *
		from RouteAssignments
		) t on t.AutoID = sap.AutoID
	inner join ConversionData.dbo.RXRF rx on rx.STOPID = t.STOPID
	inner join ConversionData.dbo.RTES rt on rt.ROUTEID = t.ROUTEID
	 
    insert into SiteOrderAssignments(SOAssignmentId, SiteOrderUniqueRef, Action, DayOfWeek, RouteTemplate, Position, PickUpInterval, ContainerType, StartDate, RoutedOrScheduled, MinLiftQuantity, RequiresQuantity, NextDueDate, Notes, SJVehicle, SJDriver, DMAccount, STOPID)
	select SOAssignmentId, SiteOrderUniqueRef, Action, DayOfWeek, RouteTemplate,
	case 
	when Position = 'E' then 0
	else ISNULL(TRY_CAST(REPLACE(Position, ',', '') AS INT), 0)  end Position, PickUpInterval, ContainerType, StartDate, RoutedOrScheduled, MinLiftQuantity, RequiresQuantity, NextDueDate, Notes, SJVehicle, SJDriver, DMAccount, STOPID
	from TempAssignments



/* Services with unmatched route assignments */
/* Customers with multiple routes */
select us.DMAccount, us.AgreeNbr, us.RentalPeriod, us.ServiceCode, us.ServiceDescription, us.Multiply, us.Price
--select *
from v_UnassignedServices us
inner join  ConversionData.dbo.RXRF rx on rx.C_ID = us.C_ID
group by us.DMAccount, us.AgreeNbr, us.RentalPeriod, us.ServiceCode, us.ServiceDescription, us.Multiply, us.Price

/* Services with no stops */
select us.DMAccount, us.AgreeNbr, us.RentalPeriod, us.ServiceCode, us.ServiceDescription, us.Multiply, us.Price
--select *
from v_UnassignedServices us
left join  ConversionData.dbo.RXRF rx on rx.C_ID = us.C_ID
where rx.c_id is null
group by us.DMAccount, us.AgreeNbr, us.RentalPeriod, us.ServiceCode, us.ServiceDescription, us.Multiply, us.Price
