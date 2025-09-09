use ModMigration

insert into SiteOrderRental (
	SiteOrderUniqueRef,
	AgreeNbr,
	ContainerType,
	RentalFrequency,
	RentalRate,
	RentalStartDate,
	RentalEndDate,
	RentalQuantity,
	Action,
	BinsOnSiteBasedOnQuantityNow,
	RentalType,
	StartOnStartOfCycle,
	EndOnEndOfCycle,
	RentalApplication,
	RentalQuantityAttribute,
	PriceNotes,
	DMAccount,
	ServiceCode,
	ServiceDescription
	)
	select 
	soh.id SiteOrderUniqueRef,
	sap.AgreeNbr,
	sap.ContainerType,
	sap.RentalPeriod,
	sap.price RentalRate,
	--nb.NextBillingDate RentalStartDate,
	case 
	when sap.RentalPeriod like '28%'  then cast(dateadd(day, 28, isnull(aa.LAST_BILL, aa.startdate)) as date)
	else nb.NextBillingDate end RentalStartDate,
	--aa.last_bill,
	--aa.startdate,
	'' RentalEndDate,
	sap.Multiply RentalQuantity,
	sap.[Action],
	case 
	when sap.Items > 250 then '1' else '0' end BinsOnSiteBasedOnQuantityNow,
	'' RentalType,
	'' StartOnStartOfCycle,
	'' EndOnEndOfCycle,
	'' RentalApplication,
	'' RentalQuantityAttribute,
	sap.id PriceNotes,
	sap.DMAccount,
	sap.ServiceCode,
	sap.ServiceDescription
	--into SiteOrderRental
	-- select sap.id
	-- select distinct rentalperiod
	-- select sap.CompanyOutlet, sap.RentalPeriod
	--select c_id_alpha, *
	-- select *
	-- select count(*)
	from CustomerServiceAgreementPrices sap -- where sap.RentalPeriod <> '' 
	inner join ActiveAuto aa on aa.AUTOID =sap.AutoID
	inner join ConversionData.dbo.CUST cu on cu.c_id = sap.c_id
	inner join SiteOrderHeader soh on soh.ServiceID = sap.id
	inner join NextBillingDate nb on nb.BillCycle = sap.RentalPeriod
	--and soh.companyoutlet = sap.CompanyOutlet
	--and soh.ARAccountCode = sap.araccountcode
	--and soh.C_ID = sap.c_id 
	--and soh.ContainerType = sap.ContainerType
	--and soh.PrimaryService = sap.PrimaryService
	--and soh.VAT = sap.VAT
	--inner join ConversionData.dbo.auto a on a.AUTOID = sap.id
	--where sap.c_id_alpha = '102465'
	where sap.RentalPeriod <> '' 
