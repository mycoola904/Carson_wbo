use ModMigration
-- update Accounts
update BillingInfo
set UniqueReference = cast(c_id as varchar)

update bi 
set bi.UniqueReference = cast(bi.C_ID as varchar) + '.2'
--select a.*
from Account a
inner join BillingInfo bi on bi.id = a.BillingInfo_id
inner join LocationInfo li on li.id = a.LocationInfo_id
where bi.BillKey <> li.LocKey



	-- set UniqueReference to parent if bill to = 2
	update bi 
	set bi.UniqueReference =  parent_bi.UniqueReference
	--select ch.c_id_alpha, bi.c_id, bi.uniquereference, parent_bi.UniqueReference
	from Child ch
	inner join BillingInfo bi on bi.id = ch.BillingInfo_id
	inner join LocationInfo li on li.id = ch.LocationInfo_id
	inner join ConversionData.dbo.cust cu on cu.c_id = ch.C_ID
	inner join Account a on a.id = ch.Parent_id
	inner join BillingInfo parent_bi on parent_bi.C_ID = a.C_ID
	where cu.C_BILL_TO = 2

	 
	 update bi 
	 set bi.UniqueReference =  cast(bi.C_ID as varchar) + '.2'
	 --select bi.*
	 from Child ch
	 inner join ConversionData.dbo.cust cu on cu.c_id = ch.C_ID
	 inner join BillingInfo bi on bi.id = ch.BillingInfo_id
	 inner join LocationInfo li on li.id = ch.LocationInfo_id
	 where bi.BillKey <> li.LocKey
	 and cu.c_bill_to <> 2



	-- set UniqueReference to parent if parent billkey = child billkey
	 update bi 
	 set bi.UniqueReference =  parent_bi.UniqueReference
	 --select bi.c_id, bi.uniquereference, parent_bi.UniqueReference, ch.c_id_alpha, a.c_id_alpha
	 from Child ch
	 inner join BillingInfo bi on bi.id = ch.BillingInfo_id
	 inner join LocationInfo li on li.id = ch.LocationInfo_id
	 inner join ConversionData.dbo.cust cu on cu.c_id = ch.C_ID
	 inner join Account a on a.id = ch.Parent_id
	 inner join BillingInfo parent_bi on parent_bi.C_ID = a.C_ID
	 where parent_bi.BillKey = bi.BillKey


	 /* use this to make all locations billkey = parent if requested */
	 -- update bi 
	 --set bi.UniqueReference =  parent_bi.UniqueReference
	 ----select bi.c_id, bi.uniquereference, parent_bi.UniqueReference, ch.c_id_alpha, a.c_id_alpha
	 --from Child ch
	 --inner join BillingInfo bi on bi.id = ch.BillingInfo_id
	 --inner join LocationInfo li on li.id = ch.LocationInfo_id
	 --inner join ConversionData.dbo.cust cu on cu.c_id = ch.C_ID
	 --inner join Account a on a.id = ch.Parent_id
	 --inner join BillingInfo parent_bi on parent_bi.C_ID = a.C_ID
	
	 





