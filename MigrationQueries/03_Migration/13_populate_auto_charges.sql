
	use ModMigration
	
	drop table if exists ActiveAuto 
	
	select cu.C_ID_ALPHA DMAccount, co.SVC_CODE_ALPHA ServiceCode, co.DESCRIPT ServiceDescription, bc.Description BillingCycle
	--, sc.data ServiceCategory, um.DATA UnitOfMeasure
	, a.*
	into ActiveAuto
	--select distinct cu.c_id_alpha--, st.description, st.status
	-- select count(1)
	from  ConversionData.dbo.AUTO a 
	inner join ConversionData.dbo.CodeMaster co on co.SVC_CODE = a.SVC_CODE
	inner join ConversionData.dbo.cust cu on cu.c_id = a.C_ID
	--inner join (select distinct c_id, CustomerSiteState from CustomerLocations) cl on cl.C_ID = cu.C_ID
	--where cl.C_ID is null 
	inner join ModMigration.dbo.Status st on st.StatusID = cu.C_CSTAT
	left join ModMigration.dbo.BillingCycle bc on bc.BillingCycleID = a.BILLCYCLE
	inner join ServiceCategory sc on sc.ServiceCategoryID = co.CODECATEGORYID
	--inner join ConversionData.dbo.ServiceCodeUnitOfMeasure um on um.ServiceCode = co.SVC_CODE
	where  (a.STOPDATE is null or cast(a.STOPDATE as date) > cast(getdate() as date) )
	and st.Description = 'ActiveAuto'
	AND A.PRORATE <> 'Y' 

	---- Do check missing servcie code details
	---- This query is to check for missing service code details. 
	--	 select aa.serviceCode, aa.ServiceDescription
	--	 from ActiveAuto aa
	--	 left join ServiceCodeDetail sd on sd.ServiceCode = aa.ServiceCode
	--	 where sd.id is null
	--	 group by aa.ServiceCode, aa.ServiceDescription



	IF EXISTS(SELECT * FROM sys.tables WHERE SCHEMA_NAME(schema_id) LIKE 'dbo' AND name like 'TaxableCodes')  
	DROP TABLE [dbo].TaxableCodes; 

	select co.SVC_CODE, t.TAXAREA 
	into TaxableCodes
	from ConversionData.dbo.CodeMaster co
	inner join ConversionData.dbo.XREF x on x.SVC_CODE = co.SVC_CODE
	inner join ConversionData.dbo.taxs t on t.TAX_CODE = x.TAX_CODE
	group by co.SVC_CODE, t.TAXAREA;


	IF EXISTS(SELECT * FROM sys.tables WHERE SCHEMA_NAME(schema_id) LIKE 'dbo' AND name like 'ServiceCodeTaxAreas')  
	DROP TABLE [dbo].ServiceCodeTaxAreas;

	select x.SVC_CODE,ta.UNIQUE_ID,  ta.data [VAT]
	into ServiceCodeTaxAreas
	from ConversionData.dbo.xref x 
	inner join ConversionData.dbo.taxs t on t.TAX_CODE = x.TAX_CODE
	inner join ConversionData.dbo.UDEF ta on ta.UNIQUE_ID = t.TAXAREA
	group by x.SVC_CODE, ta.UNIQUE_ID, ta.data



	IF EXISTS(SELECT * FROM sys.tables WHERE SCHEMA_NAME(schema_id) LIKE 'dbo' AND name like 'AutoDetails')  
	DROP TABLE [dbo].AutoDetails;

	select row_number() over (order by aa.AUTOID) [ID],
	aa.c_id, aa.AUTOID, cm.SVC_CODE_ALPHA, cm.Descript
	,sd.ServiceCode PrimaryService, sd.Action Action
	,sd.ServiceCode PricingBasis, aa.BillingCycle RentalPeriod, aa.BillingCycle RentalTerm
	, sd.ServiceCode, sd.ServiceCode [MaterialClass], sd.unit UnitOfMeasure
	, ''  VAT,
	sd.frequency
	, sd.container  ContainerType
	,cl.C_ID_ALPHA DMAccount
	, aa.MULTIPLY
	, aa.AMOUNT
	, aa.FREETONS
	, sd.SIZE
	, aa.reference
	, sd.ServiceMap CodeMap
	,	-- case 
	--when aa.BillingCycle like 'quar%' and aa.MULTIPLY % 3 = 0 then cast(aa.MULTIPLY/3 as int)
	--when aa.BillingCycle like 'semi%' and aa.MULTIPLY % 6 = 0 then cast(aa.MULTIPLY/6 as int)
	--when aa.BillingCycle like 'ann%' and aa.MULTIPLY % 12 = 0 then cast(aa.MULTIPLY/12 as int)
	--when aa.BillingCycle like 'bi%' and aa.MULTIPLY % 2 = 0 then cast(aa.MULTIPLY/2 as int)
	 aa.MULTIPLY  Items
	into AutoDetails
	--select cm.SVC_CODE_ALPHA
	--select distinct  case 
	--when ta.svc_code is null then cl.TaxArea
	--when ta.svc_code is not null and cl.taxable = 0 then cl.TaxArea
	--else '' end
	-- select aa.autoid--, max(svc_code_alpha)
	-- select count(1) --4715
	-- select *
	from ActiveAuto aa
	inner join ConversionData.dbo.CodeMaster cm on cm.SVC_CODE = aa.SVC_CODE
	inner join ConversionData.dbo.UDEF bc on bc.UNIQUE_ID = aa.BILLCYCLE
	--where bc.UNIQUE_ID is null
	inner join ConversionData.dbo.CUST cl on cl.c_id = aa.C_ID
	left join ConversionData.dbo.udef cta on cta.UNIQUE_ID = cl.B_TAXAREA
	inner join  ModMigration.dbo.ServiceCodeDetail sd on sd.[ServiceCode] = cm.SVC_CODE_ALPHA
	--and	sd.ServiceCategory = aa.ServiceCategory

	/* update frequencies */

	/* COMMENTED OUT FOR GAUTHIER UNTIL I DETERMINE IF NEEDED */
--update ad 
--set ad.frequency= cast(f.freq as varchar) + ' per week'
---- select ad.DMAccount, frequency, f.freq
--from AutoDetails ad
--inner join (
--select x.AUTOID, count(distinct x.STOPID) freq
--from ConversionData.dbo.XAUS x
--inner join ConversionData.dbo.rxrf rx on rx.STOPID = x.STOPID
--where dbo.fn_IsSingleDayRoute(rx.ROUTEID) = 1 and rx.FREQUENCY in ('E','1W')
--group by x.AUTOID
--) f on f.AUTOID = ad.AUTOID
--where ad.frequency = ''


