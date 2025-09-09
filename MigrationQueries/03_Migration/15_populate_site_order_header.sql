use ModMigration

insert into SiteOrderHeader (ARAccountCode, UniqueRefNbr, AgreeNbr, OrderCombinationGroup, ContainerType, MaterialType, StartDate,
	EndDateIfClosed, RouteOrSched, IsCustomerOwnedBin, InvoiceMethod, Haulier, DisposalPoint, PrimaryService, VAT, CustomerOrderNumber, LastInvoiceDate,
	DriverNotes, Notes2, Contact, InvoiceCycle, PaymentType, ServicePointCode, DMAccount, Frequency, autoid, CompanyOutlet_id, ServiceID
	, ServiceCode, ServiceDescription)

select 
	 --sah.[CompanyOutlet], 
	sah.ARAccountCode,	 --sah.[ARAccountCode], 
	cast(cu.c_id as varchar) UniqueRefNbr,	 --sah.UniqRef [UniqueRefNbr], 
	sah.AgreeNbr,	 --sah.[AgreeNbr], 
	'' OrderCombinationGroup,	
	case 
	when sah.ContainerType = '' then sah.PrimaryService
	else sah.ContainerType end ContainerType,	 --sah.[ContainerType], 
	sah.MaterialClass MaterialType,	 --'' [MaterialType], 
	cast(sah.StartDate as date)StartDate ,	 --sah.[StartDate], 
	'' EndDateIfClosed,	 --'' [EndDateIfClosed], 
	'Routed' RouteOrSched,	 --'' [RouteOrSched], 
	'' IsCustomerOwnedBin,	 --'' [IsCustomerOwnedBin], 
	'' InvoiceMethod,	 --'' [InvoiceMethod], 
	'' Haulier,	 --'' [Haulier], 
	'' DisposalPoint,	 --'' [DisposalPoint], 
	sah.PrimaryService,	 --sah.[PrimaryService], 
	sah.VAT,	 --sah.VAT [VAT], 
	'' CustomerOrderNumber,	 --'' [CustomerOrderNumber], 
	'' LastInvoiceDate,	 --'' [LastInvoiceDate], 
	'' DriverNotes,	 --'' [DriverNotes], 
	'' Notes2,	 --'' [Notes2],
	'' Contact,	
	'' InvoiceCycle,	
	'' PaymentType,	
	'' ServicePointCode,
	cu.C_ID_ALPHA DMAccount,
	'' frequency
	,sah.autoid
	, co.id
	, sah.id ServiceID
	, sah.ServiceCode
	, sah.ServiceDescription
	--into SiteOrderHeader
	--select servicecode, RentalPeriod 
	--select count(1)
		from CustomerServiceAgreementPrices sah 
		--inner join NextBillingDate nd on nd.BillCycle = sah.RentalPeriod
		inner join ConversionData.dbo.CUST cu on cu.C_ID_ALPHA = sah.DMAccount
		left join Company co on co.Company = sah.CompanyOutlet
		left join NextBillingDate nb on nb.BillCycle = sah.RentalPeriod
		where nb.UNIQUE_ID is not null




		drop table if exists SiteOrderItems

		select row_number() over(order by SiteOrderUniqueRef) SOItemId, SiteOrderUniqueRef, AgreeNbr, ContainerType, StartDate, Items,DMAccount, t.size
		into SiteOrderItems
		from
		(
		select soh.SiteOrderUniqueRef, soh.AgreeNbr, soh.ContainerType, soh.StartDate, sap.Multiply items, soh.DMAccount, sap.size
		--select count(1)
		from
		v_SiteOrderHeader soh
		inner join CustomerServiceAgreementPrices sap on sap.id = soh.ServiceID	
		
		) t
		CROSS APPLY dbo.fnTally(Items)