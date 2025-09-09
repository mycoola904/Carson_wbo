use ModMigration

insert into CustomerServiceAgreementPrices (AgreeNbr, VAT, StartDate, ContainerType, PrimaryService, Action, PricingBasis, Material, MaterialClass, UnitOfMeasure, Multiply, Price, RentalPeriod, MinValue, MinTon, Allowance, QuantityFrom, QuantityTill, 
                         PriceParentId, IsEstimate, TaxTemplateCollection, ARAccountCode, DefaultAction, PriceType, FreqInWeeks, c_id, autoid, CompanyOutlet, OutletAgreement, DMAccount, PRORATE, MasterARAccountCode, Items
						 , ServiceCode, ServiceDescription, Customer_id
						 ,Size --, ServiceContainerID
		)
		Select 
		--cs.MasterARAccountCode,
		ad.AUTOID AgreeNbr,
		'' VAT,
		aa.STARTDATE StartDate,
		ad.CodeMap ContainerType,
		ad.PrimaryService PrimaryService,
		ad.Action Action,
		case 
		when nd.BillCycle is not null then 'Rent\Advance Service'
		else 'Per Job' end PricingBasis,
		--case 
		--when ad.PricingBasis in ('DAILY') THEN 'Per Job'
		--else 'Review' end PricingBasis,
		ad.CodeMap Material,
		ad.CodeMap MaterialClass,
		'' UnitOfMeasure,
		aa.MULTIPLY Multiply,
		aa.amount Price,
		CASE 
		when ad.RentalPeriod = 'DAILY' then ''
		else ad.RentalPeriod end RentalPeriod,
		null MinValue,
		null MinTon,
		aa.FREETONS Allowance,
		null QuantityFrom,
		null QuantityTill,
		null PriceParentId,
		null IsEstimate,
		'' TaxTemplateCollection,
		cu.ARAccountCode ARAccountCode,
		null DefaultAction,
		'' PriceType,
		ad.Frequency FreqInWeeks,
		aa.c_id,
		aa.AUTOID,
		cu.CompanyOutlet CompanyOutlet,
		--case 
		--when cop.PriceUniqueReferenceId is not null then cop.AgreeNbr
		--else '' end OutletAgreement,
		'' OutletAgreement,
		cu.C_ID_ALPHA DMAccount
		,aa.PRORATE
		, c.master_ar_account_code MasterARAccountCode
		, aa.MULTIPLY Items
		, aa.ServiceCode
		, aa.ServiceDescription
		, c.id Customer_id
		, ad.Size
		--, 0 ServiceContainerID
		-- select aa.autoid
		-- select max(len(ad.pricingbasis))
		-- select count(1)
		-- select * from autodetails
		--into customerserviceagreementprices1
		from activeauto aa --where aa.useinoutlet = 0
		
		inner join AutoDetails ad on ad.autoid = aa.autoid
		left join NextBillingDate nd on nd.BillCycle = aa.BillingCycle
		--inner join Pricing p on p.autoid = aa.AUTOID
		--inner join AgreeNumber an on an.GroupKey = p.GroupKey
		--where aa.ServiceCode = 'wtpr' 
		inner join CustomerLocations cu on cu.UniqRef = cast(aa.C_ID as varchar)
		inner join customers c on c.ar_account_code = cu.ARAccountCode
		inner join ConversionData.dbo.cust cs on cs.c_id = aa.C_ID
		
		left join ServiceCodeTaxAreas ta on ta.svc_code = aa.SVC_CODE and ta.UNIQUE_ID = cs.B_TAXAREA
		
	

		
		-- update sap
		-- set sap.ContainerType= ad.PlatformContainer
		-- from CustomerServiceAgreementPrices sap
		-- inner join RM97ToPlatformRADFirstCut.dbo.AutoDetails ad on ad.AUTOID = sap.autoid
		-- where isnull(ad.PlatformContainer, '') <> ''

	insert into CustomerServiceAgreementHeader (AgreeNbr,CompanyOutlet, ARAccountCode, UniqRef,   ContainerType, MaterialClass, PrimaryService, ScheduledRouted, StartDate, Description, VAT, RequiresPeriodicDoC, 
	ProofOfServiceRequired, OrderNumberRequired, InvoiceCycle, DriverNotes, OrderNotes, CustomerSuppliesReleaseNumbers, InvoiceOnShipDate, TransportSupplier, CollateInvoices, 
	LastInvoiceDate, InvoiceFrequencyTerm, OutletAgreement, MasterARAccountCode, DMAccount)
	select  AgreeNbr, CompanyOutlet, sah.ARAccountCode, c_id UniqRef, '' ContainerType,'' MaterialClass, PrimaryService, '' ScheduledRouted, cast(Getdate()-30 as date) startdate,
	ServiceDescription Description, VAT, '' RequiresPeriodicDoC,'' ProofOfServiceRequired, '' OrderNumberRequired, '' InvoiceCycle, '' DriverNotes, '' OrderNotes,
	'' CustomerSuppliesReleaseNumbers, '' InvoiceOnShipDate, '' TransportSupplier, '' CollateInvoices, 
	'' LastInvoiceDate, '' InvoiceFrequencyTerm, sah.OutletAgreement, sah.MasterARAccountCode, DMAccount
	--select count(id)
	from CustomerServiceAgreementPrices sah
	GROUP BY AgreeNbr, 
         CompanyOutlet, 
         sah.ARAccountCode, 
         c_id, 
         PrimaryService,
		 ServiceDescription,
         VAT, 
         sah.OutletAgreement, 
         sah.MasterARAccountCode, 
         DMAccount



