use ModMigration
-- this script is used to create the billing address for the customer headquarter and child locations

IF NOT EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[GetBillingAddress]') 
           AND type = N'FN')
BEGIN
    EXEC sp_executesql N'
    Create FUNCTION [dbo].[GetBillingAddress]
	(
		-- Add the parameters for the function here
		@BillingStreet varchar(60) 
	)
	RETURNS varchar(60)
	AS
	BEGIN
		-- Declare the return variable here
		DECLARE @StreetNum varchar(60) = ''''

		-- Add the T-SQL statements to compute the return value here
		set @BillingStreet = isnull(@BillingStreet,'''')
		SELECT @StreetNum = 
		case
		when Len(@BillingStreet)>1 and isnumeric(left(@BillingStreet, charindex('' '', @BillingStreet)))=1 
		then left(@BillingStreet, charindex('' '', @BillingStreet)-1)
		when @BillingStreet LIKE ''PO BOX %'' THEN ''PO BOX ''
		when @BillingStreet like ''P.O. Box %'' then ''P.O. Box ''	
		when @BillingStreet like ''P.O Box %'' then ''P.O Box ''
		when @BillingStreet like ''PO POX %'' then ''PO POX ''	
		when @BillingStreet like ''POx BOX %'' then ''POX BOX ''
		else '''' end

		-- Return the result of the function
		RETURN @StreetNum

	END';
END

-- Account Billing Locations

-- this insert is used to insert the billing address for the customer headquarter and child locations into the CustomerLocations table
INSERT INTO CustomerLocations ( C_ID, C_ID_ALPHA, B_CONTACT, C_CONTACT, ARAccountCode, UniqRef, SiteName, HouseNbr, Address1, Address2, Town, County, State, Country, Postcode, CompanyOutlet, TelNbr, FaxNbr, MobileNbr, 
                         EmailAddress, SICCode, Zone, AccessContact, DocumentDeliveryType, LocalAuthority, SiteType, LocationDescription, Latitude, Longitude, CustomerSiteState, SalesRepresentative, AltSearchReference, FederalID, CSR, 
                         CustomerOrderNo, AnalysisCode, InvoicingAddressSiteID, PaymentType, PaymentTerm, RebatePaymentType, RebatePaymentTerm, PaymentHandlingCode, PayableCycle, MasterChild, DifferentBilling, MasterParent, Taxable, 
                         TaxArea,HQLocation,OperationalArea, DMAccount, Account_id, Child_id

)

select cl.[C_ID]
      ,cl.[C_ID_ALPHA]
      ,cl.[B_CONTACT]
      ,cl.[C_CONTACT]
      ,cl.[ARAccountCode]
      ,bi.UniqueReference  [UniqRef]
      ,case 
      when isnull(bi.b_name,'')='' then bi.B_NAME2
      ELSE bi.B_NAME END [SiteName]
      ,dbo.GetBillingAddress(bi.B_ADDR1) [HouseNbr]
      ,replace(bi.B_ADDR1, dbo.GetBillingAddress(bi.B_ADDR1),'')[Address1]
      ,bi.B_ADDR2 [Address2]
      ,bi.B_CITY [Town]
      ,cl.[County]
      ,bi.B_STATE [State]
      ,cl.[Country]
      ,bi.B_ZIP [Postcode]
      ,cl.[CompanyOutlet]
      ,ISNULL(bi.b_pho, '') + ' '+ ISNULL(b_PCONT,'') [TelNbr]
      ,bi.B_FAX [FaxNbr]
      ,cl.[MobileNbr]
      ,bi.B_EMAIL [EmailAddress]
      ,cl.[SICCode]
      ,cl.[Zone]
      ,cl.[AccessContact]
      ,cl.[DocumentDeliveryType]
      ,cl.[LocalAuthority]
      ,'HQ' [SiteType]
      ,cl.[LocationDescription]
      ,cl.[Latitude]
      ,cl.[Longitude]
      ,cl.[CustomerSiteState]
      ,cl.[SalesRepresentative]
      ,cl.[AltSearchReference]
      ,cl.[FederalID]
      ,cl.[CSR]
      ,cl.[CustomerOrderNo]
      ,cl.[AnalysisCode]
      ,'' [InvoicingAddressSiteID]
      ,cl.[PaymentType]
      ,cl.[PaymentTerm]
      ,cl.[RebatePaymentType]
      ,cl.[RebatePaymentTerm]
      ,cl.[PaymentHandlingCode]
      ,cl.[PayableCycle]
      ,cl.[MasterChild]
      ,cl.[DifferentBilling]
      ,cl.[MasterParent]
      ,cl.[Taxable]
      ,cl.[TaxArea]
      , 1 HQLocation
      ,cl.OperationalArea
      ,cl.[DMAccount]
      ,cl.[Account_id]
      ,cl.[Child_id]
-- select *
from Account a
inner join BillingInfo bi on bi.id = a.BillingInfo_id
inner join CustomerLocations cl on cl.Account_id = a.id 
where bi.UniqueReference like '%.2'



-- Child Billing Locations
INSERT INTO CustomerLocations ( C_ID, C_ID_ALPHA, B_CONTACT, C_CONTACT, ARAccountCode, UniqRef, SiteName, HouseNbr, Address1, Address2, Town, County, State, Country, Postcode, CompanyOutlet, TelNbr, FaxNbr, MobileNbr, 
                         EmailAddress, SICCode, Zone, AccessContact, DocumentDeliveryType, LocalAuthority, SiteType, LocationDescription, Latitude, Longitude, CustomerSiteState, SalesRepresentative, AltSearchReference, FederalID, CSR, 
                         CustomerOrderNo, AnalysisCode, InvoicingAddressSiteID, PaymentType, PaymentTerm, RebatePaymentType, RebatePaymentTerm, PaymentHandlingCode, PayableCycle, MasterChild, DifferentBilling, MasterParent, Taxable, 
                         TaxArea,HQLocation,OperationalArea, DMAccount, Account_id, Child_id

)

select cl.[C_ID]
      ,cl.[C_ID_ALPHA]
      ,cl.[B_CONTACT]
      ,cl.[C_CONTACT]
      ,cl.[ARAccountCode]
      ,bi.UniqueReference  [UniqRef]
      ,case 
      when isnull(bi.b_name,'')='' then bi.b_name2 
      ELSE bi.B_NAME END [SiteName]
      ,dbo.GetBillingAddress(bi.B_ADDR1) [HouseNbr]
      ,replace(bi.B_ADDR1, dbo.GetBillingAddress(bi.B_ADDR1),'')[Address1]
      ,bi.B_ADDR2 [Address2]
      ,bi.B_CITY [Town]
      ,cl.[County]
      ,bi.B_STATE [State]
      ,cl.[Country]
      ,bi.B_ZIP [Postcode]
      ,cl.[CompanyOutlet]
      ,ISNULL(bi.b_pho, '') + ' '+ ISNULL(b_PCONT,'') [TelNbr]
      ,bi.B_FAX [FaxNbr]
      ,cl.[MobileNbr]
      ,bi.B_EMAIL [EmailAddress]
      ,cl.[SICCode]
      ,cl.[Zone]
      ,cl.[AccessContact]
      ,cl.[DocumentDeliveryType]
      ,cl.[LocalAuthority]
      ,'HQ' [SiteType]
      ,cl.[LocationDescription]
      ,cl.[Latitude]
      ,cl.[Longitude]
      ,cl.[CustomerSiteState]
      ,cl.[SalesRepresentative]
      ,cl.[AltSearchReference]
      ,cl.[FederalID]
      ,cl.[CSR]
      ,cl.[CustomerOrderNo]
      ,cl.[AnalysisCode]
      ,'' [InvoicingAddressSiteID]
      ,cl.[PaymentType]
      ,cl.[PaymentTerm]
      ,cl.[RebatePaymentType]
      ,cl.[RebatePaymentTerm]
      ,cl.[PaymentHandlingCode]
      ,cl.[PayableCycle]
      ,cl.[MasterChild]
      ,cl.[DifferentBilling]
      ,cl.[MasterParent]
      ,cl.[Taxable]
      ,cl.[TaxArea]
      , 1 HQLocation
      ,cl.OperationalArea
      ,cl.[DMAccount]
      ,cl.[Account_id]
      ,cl.[Child_id]
--select bi.UniqueReference, pcl.UniqRef
-- select a.*
from Child a
inner join BillingInfo bi on bi.id = a.BillingInfo_id
inner join CustomerLocations cl on cl.Child_id = a.id 
left join CustomerLocations pcl on pcl.UniqRef = bi.UniqueReference
where bi.UniqueReference like '%.2'
and pcl.id is null


---- This is a check for duplicate UniqRef(s)
--select UniqRef
--from CustomerLocations cl1
--group by UniqRef
--having count(uniqref)>1