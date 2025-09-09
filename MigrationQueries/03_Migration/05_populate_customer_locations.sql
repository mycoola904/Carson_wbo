use ModMigration

-- Insert the customer location information from the Account table


	INSERT INTO CustomerLocations ( C_ID, C_ID_ALPHA, B_CONTACT, C_CONTACT, ARAccountCode, UniqRef, SiteName, HouseNbr, Address1, Address2, Town, County, State, Country, Postcode, CompanyOutlet, TelNbr, FaxNbr, MobileNbr, 
                         EmailAddress, SICCode, Zone, AccessContact, DocumentDeliveryType, LocalAuthority, SiteType, LocationDescription, Latitude, Longitude, CustomerSiteState, SalesRepresentative, AltSearchReference, FederalID, CSR, 
                         CustomerOrderNo, AnalysisCode, InvoicingAddressSiteID, PaymentType, PaymentTerm, RebatePaymentType, RebatePaymentTerm, PaymentHandlingCode, PayableCycle, MasterChild, DifferentBilling, MasterParent, Taxable, 
                         TaxArea,HQLocation,OperationalArea,
						 DMAccount, Account_id, Child_id

	)
	
	select c.c_id, c.C_ID_ALPHA,
	li.C_PCONT,
	bi.B_PCONT,
	cs.ar_account_code  ARAccount,
	cast(c.c_id as varchar) [UniqRef], -- populate with id
	case 
	when isnull(li.C_NAME,'') <> '' then li.C_NAME
	else li.C_NAME2 end [SiteName], 
	li.C_ADDRNUM1 [HouseNbr], 
	C_ADDR1 [address1], 
	C_ADDR2 [address2],
	li.c_city [Town], 
	'' [County],
	li.c_state [State], 
	'United States' [Country], 
	li.c_ZIP [Postcode], 
	co.COMPANY [CompanyOutlet],
	li.c_pho [TelNbr], 
	'' [FaxNbr], 
	isnull(li.C_FAX, '') + ' ' + isnull(li.C_FCONT, '') [MobileNbr], 
	li.C_EMAIL [EmailAddress], 
	'' [SICCode],
	
	isnull(ba.Description,'') [Zone],
	'' [AccessContact], 
	'' [DocumentDeliveryType], 
	'' [LocalAuthority], 
	case 
	when c.C_ID_ALPHA like '%-001' and bi.UniqueReference = cast(c.c_id as varchar) then 'HQ' else '' end [SiteType], 
	li.C_NAME [LocationDescription], 
	isnull(m.LATITUDE,'') [Latitude], 
	isnull(m.LONGITUDE,'') [Longitude], 
	-- select * from status
	case 
	when s.Description = 'InActiveAuto' and c.C_ID_ALPHA like '%-001' then 'ACTIVE'
	else s.Status end [CustomerSiteState], 
	r.NAME [SalesRepresentative], 
	c.C_ID_ALPHA [AltSearchReference], 
	'' [FederalID], 
	'' [CSR], 
	'' [CustomerOrderNo], 
	'' [AnalysisCode], 
	case when bi.UniqueReference <> cast(c.c_id as varchar) then bi.UniqueReference
	else '' end [InvoicingAddressSiteID], 
	'' [PaymentType], 
	te.Description [PaymentTerm], 
	'' [RebatePaymentType], 
	'' [RebatePaymentTerm], 
	'' [PaymentHandlingCode], 
	'' [PayableCycle],
	0 [MasterChild],
	0 [DifferentBilling],
	0 [MasterParent],
	c.B_TAXABLE [taxable],
	ta.Description [taxarea],
	case 
	when c.C_ID_ALPHA like '%-001' and bi.UniqueReference = cast(c.c_id as varchar) then 1 else 0 end HQLocation,
	co.Company OperationalArea,
	c.C_ID_ALPHA DMAccount
	, c.id as Account_id
	, null as Child_id
	-- select c.c_id -- 199,153
	-- select count(1)
	FROM Account c
	inner join Customers cs on cs.c_id = c.C_ID
	left join BillingInfo bi on bi.id = c.BillingInfo_id
	left join LocationInfo li on li.id = c.LocationInfo_id
	inner join Company co on co.id = c.Company_id
	left join BillArea ba on ba.id = c.BillArea_id
	left join ConversionData.dbo.MAP m on m.C_ID = c.C_ID
	inner join Status s on s.id = c.status_id
	left join Terms te on te.id = c.Terms_id
	left join TaxArea ta on ta.id = c.TaxArea_id
	left join CustomerRep r on r.id = c.CREP1_id
	where c.MigrationStatus = 'Active'


-- Insert the customer location information from the Child table
	INSERT INTO CustomerLocations ( C_ID, C_ID_ALPHA, B_CONTACT, C_CONTACT, ARAccountCode, UniqRef, SiteName, HouseNbr, Address1, Address2, Town, County, State, Country, Postcode, CompanyOutlet, TelNbr, FaxNbr, MobileNbr, 
                         EmailAddress, SICCode, Zone, AccessContact, DocumentDeliveryType, LocalAuthority, SiteType, LocationDescription, Latitude, Longitude, CustomerSiteState, SalesRepresentative, AltSearchReference, FederalID, CSR, 
                         CustomerOrderNo, AnalysisCode, InvoicingAddressSiteID, PaymentType, PaymentTerm, RebatePaymentType, RebatePaymentTerm, PaymentHandlingCode, PayableCycle, MasterChild, DifferentBilling, MasterParent, Taxable, 
                         TaxArea,HQLocation,OperationalArea, DMAccount, Account_id, Child_id
	)
	select c.c_id, c.C_ID_ALPHA,
	li.C_PCONT,
	bi.B_PCONT,
	case when cs1.c_id is null then	cs.ar_account_code
	else cs1.ar_account_code end ARAccount,
	cast(c.c_id as varchar) [UniqRef], -- populate with id
	case 
	when isnull(li.C_ADDRNUM1,'') +' ' + isnull(li.C_ADDR1,'') <> ' ' then isnull(li.C_ADDRNUM1,'') +' ' + isnull(li.C_ADDR1,'') 
	when isnull(li.c_addr2,'') <> '' then li.C_ADDR2
	else li.C_NAME end  [SiteName], 
	li.C_ADDRNUM1 [HouseNbr], 
	C_ADDR1 [address1], 
	C_ADDR2 [address2],
	li.c_city [Town], 
	'' [County],
	li.c_state [State], 
	'United States' [Country], 
	li.c_ZIP [Postcode], 
	co.COMPANY [CompanyOutlet],
	li.c_pho [TelNbr], 
	li.c_FAX [FaxNbr], 
	'' [MobileNbr], 
	li.C_EMAIL [EmailAddress], 
	'' [SICCode],	
	isnull(ba.Description,'') [Zone],
	'' [AccessContact], 
	'' [DocumentDeliveryType], 
	'' [LocalAuthority], 
	'' [SiteType], 
	li.C_NAME [LocationDescription], 
	isnull(m.LATITUDE,'') [Latitude], 
	isnull(m.LONGITUDE,'') [Longitude], 
	s.Status [CustomerSiteState], 
	r.NAME [SalesRepresentative], 
	c.C_ID_ALPHA [AltSearchReference], 
	'' [FederalID], 
	'' [CSR], 
	'' [CustomerOrderNo], 
	'' [AnalysisCode], 
	case when bi.UniqueReference <> cast(c.c_id as varchar) then bi.UniqueReference
	else '' end [InvoicingAddressSiteID],
	'' [PaymentType], 
	te.Description [PaymentTerm], 
	'' [RebatePaymentType], 
	'' [RebatePaymentTerm], 
	'' [PaymentHandlingCode], 
	'' [PayableCycle],
	0 [MasterChild],
	0 [DifferentBilling],
	0 [MasterParent],
	c.B_TAXABLE [taxable],
	ta.Description [taxarea],
	0  HQLocation,
	co.Company OperationalArea,
	c.C_ID_ALPHA DMAccount
	, null as Account_id
	, c.id as Child_id
	-- select c.c_id -- 199,153
	-- select count(1) --26689 -5 = 26684
	-- select c.c_id_alpha
	FROM Child c
	left join (select c_id, ar_account_code from Customers) cs1 on cs1.c_id = c.c_id
	--left join InActiveAccounts ia on ia.C_ID = c.C_ID
	inner join Account a on a.Parent_id_alpha = c.Parent_id_alpha
	inner join Customers cs on cs.c_id = a.C_ID
	left join BillingInfo bi on bi.id = c.BillingInfo_id
	LEFT join LocationInfo li on li.id = c.LocationInfo_id
	left join Company co on co.id = c.Company_id
	left join BillArea ba on ba.id = c.BillArea_id
	left join ConversionData.dbo.MAP m on m.C_ID = c.C_ID
	inner join Status s on s.id = c.status_id
	left join Terms te on te.id = c.Terms_id
	left join TaxArea ta on ta.id = c.TaxArea_id
	left join CustomerRep r on r.id = c.CREP1_id
	where c.MigrationStatus = 'Active'




-- orphan accounts
drop table if exists OrphanAccounts

select cu.C_ID_ALPHA
into OrphanAccounts
from ConversionData.dbo.CUST cu
left join CustomerLocations cl on cl.UniqRef = cast(cu.C_ID as varchar)
where cl.UniqRef is null


 --select count(1)
 --from ConversionData.dbo.cust 

 --select count(1)
 --from CustomerLocations

----select count(1)
----from Customers

--select count(1)
--from ConversionData.dbo.CUST cu
--inner join CustomerLocations cl on cl.UniqRef = cast(cu.C_ID as varchar)

--select *
--from CustomerLocations cl
--left join Customers c on c.ar_account_code = cl.ARAccountCode
--where c.c_id is null

--select cu.C_ID_ALPHA
--from ConversionData.dbo.CUST cu
--left join CustomerLocations cl on cl.UniqRef = cast(cu.C_ID as varchar)
--where cl.UniqRef is null


-- select *
-- from OrphanAccounts
