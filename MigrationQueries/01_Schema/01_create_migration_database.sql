/****
This script creates the ModMigration database and all its objects.
****/
CREATE DATABASE [ModMigration]
go

USE [ModMigration]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_IsSingleDayRoute]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    CREATE FUNCTION [dbo].[fn_IsSingleDayRoute] (@Route_id INT)
	RETURNS BIT
	AS
	BEGIN
		DECLARE @IsSingleDayRoute BIT

		SELECT @IsSingleDayRoute = 
			CASE
				WHEN CAST(MON AS INT) + CAST(TUE AS INT) + CAST(WED AS INT) + CAST(THU AS INT) + CAST(FRI AS INT) + CAST(SAT AS INT) + CAST(SUN AS INT) = 1 THEN 1
				ELSE 0
			END
		FROM ConversionData.dbo.RTES 
		WHERE ROUTEID = @Route_id

		RETURN @IsSingleDayRoute
	END
GO
/****** Object:  UserDefinedFunction [dbo].[GetARAccountCode]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetARAccountCode]
(
	-- Add the parameters for the function here
	 @c_id_alpha varchar(50)
)
RETURNS varchar(10)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ARAccountCode varchar(10)

	-- Add the T-SQL statements to compute the return value here
	select @ARAccountCode = 	 
	case 
	when C_ID_ALPHA like '%-%' and len(c_id_alpha)>10 then replace(c_id_alpha, '-0', '-') 
	when c_id_alpha like '%-%' then C_ID_ALPHA
	else C_ID_ALPHA end 
	from ConversionData.dbo.CUST
	where c_id_alpha = @c_id_alpha

	-- Return the result of the function
	RETURN @ARAccountCode

END
GO
/****** Object:  UserDefinedFunction [dbo].[GetBillingAddress]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    Create FUNCTION [dbo].[GetBillingAddress]
	(
		-- Add the parameters for the function here
		@BillingStreet varchar(60) 
	)
	RETURNS varchar(60)
	AS
	BEGIN
		-- Declare the return variable here
		DECLARE @StreetNum varchar(60) = ''

		-- Add the T-SQL statements to compute the return value here
		set @BillingStreet = isnull(@BillingStreet,'')
		SELECT @StreetNum = 
		case
		when Len(@BillingStreet)>1 and isnumeric(left(@BillingStreet, charindex(' ', @BillingStreet)))=1 
		then left(@BillingStreet, charindex(' ', @BillingStreet)-1)
		when @BillingStreet LIKE 'PO BOX %' THEN 'PO BOX '
		when @BillingStreet like 'P.O. Box %' then 'P.O. Box '	
		when @BillingStreet like 'P.O Box %' then 'P.O Box '
		when @BillingStreet like 'PO POX %' then 'PO POX '	
		when @BillingStreet like 'POx BOX %' then 'POX BOX '
		else '' end

		-- Return the result of the function
		RETURN @StreetNum

	END
GO
/****** Object:  UserDefinedFunction [dbo].[GetNumericCharacters]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetNumericCharacters] (@input NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @output NVARCHAR(MAX) = '';
    DECLARE @i INT = 1;
    DECLARE @char NCHAR(1);
    
    WHILE @i <= LEN(@input)
    BEGIN
        SET @char = SUBSTRING(@input, @i, 1);
        
        IF @char LIKE '[0-9]'
        BEGIN
            SET @output = @output + @char;
        END
        
        SET @i = @i + 1;
    END
    
    RETURN @output;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[NextDay]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    CREATE FUNCTION [dbo].[NextDay]
	(
		-- Add the parameters for the function here
		@nextWeekDay int
	)
	RETURNS datetime
	AS
	BEGIN
		-- Declare the return variable here
		declare @time datetime;
		set @time=getdate();

		declare @weekday int;
		set @weekday = datepart(weekday,  @time) ;

		declare @diff int;
		set @diff= @nextWeekDay-@weekday;

		--modulo 7 bijectively
		declare @moduloed int;
		set @moduloed = case 
			when @diff <=0 then @diff+7 
			else @diff
		end;

		return dateadd(day, @moduloed,  @time);

	END
GO
/****** Object:  Table [dbo].[CustomerServiceAgreementPrices]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerServiceAgreementPrices](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[AgreeNbr] [nvarchar](32) NULL,
	[VAT] [nvarchar](30) NOT NULL,
	[StartDate] [datetimeoffset](7) NULL,
	[ContainerType] [nvarchar](255) NULL,
	[PrimaryService] [nvarchar](255) NULL,
	[Action] [nvarchar](255) NULL,
	[PricingBasis] [nvarchar](20) NOT NULL,
	[Material] [nvarchar](30) NOT NULL,
	[MaterialClass] [nvarchar](30) NOT NULL,
	[UnitOfMeasure] [nvarchar](30) NOT NULL,
	[Multiply] [numeric](18, 5) NULL,
	[Price] [numeric](32, 19) NULL,
	[RentalPeriod] [nvarchar](255) NULL,
	[MinValue] [int] NULL,
	[MinTon] [int] NULL,
	[Allowance] [numeric](18, 5) NULL,
	[QuantityFrom] [int] NULL,
	[QuantityTill] [int] NULL,
	[PriceParentId] [int] NULL,
	[IsEstimate] [int] NULL,
	[TaxTemplateCollection] [nvarchar](30) NOT NULL,
	[ARAccountCode] [nvarchar](255) NULL,
	[DefaultAction] [int] NULL,
	[PriceType] [nvarchar](30) NOT NULL,
	[FreqInWeeks] [nvarchar](255) NULL,
	[c_id] [int] NOT NULL,
	[CompanyOutlet] [nvarchar](255) NULL,
	[OutletAgreement] [nvarchar](30) NOT NULL,
	[DMAccount] [nvarchar](255) NULL,
	[PRORATE] [nvarchar](50) NULL,
	[MasterARAccountCode] [nvarchar](255) NULL,
	[Items] [int] NULL,
	[AutoID] [int] NULL,
	[size] [nvarchar](255) NULL,
	[ServiceCode] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](255) NULL,
	[Customer_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServiceCodeDetail]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceCodeDetail](
	[id] [bigint] NULL,
	[DMAccount] [nvarchar](19) NULL,
	[# Used] [int] NULL,
	[ServiceCode] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](250) NULL,
	[ServiceCategory] [varchar](255) NULL,
	[linkstat] [varchar](255) NULL,
	[size] [nvarchar](255) NULL,
	[unit] [nvarchar](255) NULL,
	[action] [nvarchar](255) NULL,
	[frequency] [nvarchar](255) NULL,
	[ServiceMap] [nvarchar](511) NULL,
	[container] [nvarchar](255) NULL,
	[type] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_CustomerServiceAgreementPrices]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view [dbo].[T_CustomerServiceAgreementPrices] as
    select 
        sap.id,
        --sap.CompanyOutlet,
        AgreeNbr,
        VAT,
        cast(sap.StartDate as date) StartDate,
        '' EndDate,
        'Price|' + sd.ServiceMap ContainerType,
        PrimaryService,
        sd.ServiceMap Action,
         PricingBasis,
        'Price|' + sd.ServiceMap Material,
        'Price|' + sd.ServiceMap MaterialClass,
        sap.UnitOfMeasure,
        Price,
        RentalPeriod,
        MinValue,
        MinTon,
        Allowance,
        QuantityFrom,
        QuantityTill,
        PriceParentId,
        IsEstimate,
        TaxTemplateCollection,
        ARAccountCode,
        DefaultAction,
        PriceType,
        case 
		when FreqInWeeks <> '' then FreqInWeeks -- + ' per week' 
		else FreqInWeeks end FreqInWeeks,
        case 
		when FreqInWeeks <> '' then FreqInWeeks -- + ' per week' 
		else FreqInWeeks end ServiceFrequency,
        '' InactivityDaysAllowance,
        '' PriceOffset,
        '' AgreedSoldWeights,
        sap.DMAccount,
		sap.ServiceCode,
		sap.ServiceDescription
	--select count(1)
    from CustomerServiceAgreementPrices sap
	INNER JOIN ServiceCodeDetail SD ON sd.ServiceCode = sap.ServiceCode
GO
/****** Object:  Table [dbo].[Company]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Company](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Company] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[CompanyID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SiteOrderHeader]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SiteOrderHeader](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ARAccountCode] [nvarchar](10) NOT NULL,
	[UniqueRefNbr] [nvarchar](50) NOT NULL,
	[AgreeNbr] [nvarchar](20) NOT NULL,
	[OrderCombinationGroup] [nvarchar](60) NOT NULL,
	[ContainerType] [nvarchar](60) NOT NULL,
	[MaterialType] [nvarchar](100) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDateIfClosed] [nvarchar](20) NOT NULL,
	[RouteOrSched] [nvarchar](10) NOT NULL,
	[IsCustomerOwnedBin] [nvarchar](30) NOT NULL,
	[InvoiceMethod] [nvarchar](30) NOT NULL,
	[Haulier] [nvarchar](60) NOT NULL,
	[DisposalPoint] [nvarchar](60) NOT NULL,
	[PrimaryService] [nvarchar](50) NOT NULL,
	[VAT] [nvarchar](60) NOT NULL,
	[CustomerOrderNumber] [nvarchar](30) NOT NULL,
	[LastInvoiceDate] [nvarchar](20) NOT NULL,
	[DriverNotes] [nvarchar](max) NOT NULL,
	[Notes2] [nvarchar](max) NOT NULL,
	[Contact] [nvarchar](30) NOT NULL,
	[InvoiceCycle] [nvarchar](30) NOT NULL,
	[PaymentType] [nvarchar](30) NOT NULL,
	[ServicePointCode] [nvarchar](20) NOT NULL,
	[Frequency] [nvarchar](40) NULL,
	[DMAccount] [nvarchar](30) NOT NULL,
	[autoid] [int] NOT NULL,
	[CAND_ID] [int] NULL,
	[ServiceID] [int] NOT NULL,
	[ServiceCode] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](255) NULL,
	[CompanyOutlet_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_SiteOrderHeader]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[T_SiteOrderHeader] as
	select 
		soh.id SiteOrderUniqueRef,
		co.Company CompanyOutlet,
		soh.ARAccountCode,
		UniqueRefNbr,
		soh.AgreeNbr,
		OrderCombinationGroup,
		sd.ServiceMap ContainerType,
		sd.ServiceMap MaterialType,
		soh.StartDate,
		EndDateIfClosed,
		RouteOrSched,
		IsCustomerOwnedBin,
		InvoiceMethod,
		Haulier,
		DisposalPoint,
		soh.PrimaryService,
		soh.VAT,
		CustomerOrderNumber,
		LastInvoiceDate,
		DriverNotes,
		Notes2,
		Contact,
		InvoiceCycle,
		PaymentType,
		ServicePointCode,
		sap.FreqInWeeks ServiceFrequency,
		'' RentalStartDate,
		'' AgreeNbrIsOutletAgreement,
		'' OrderedBy,
		'' Origin,
		soh.DMAccount,
		soh.ServiceCode,
		soh.ServiceDescription
	-- select count(1)
	FROM SiteOrderHeader soh
	inner join T_CustomerServiceAgreementPrices sap on sap.id = soh.ServiceID
	inner join ServiceCodeDetail sd on sd.ServiceCode = soh.ServiceCode
	left join Company co on co.id = soh.CompanyOutlet_id
GO
/****** Object:  Table [dbo].[AgedDebtorsData]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AgedDebtorsData](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ARAccountCode] [nvarchar](10) NULL,
	[DocumentType] [nvarchar](1) NULL,
	[DocumentNumber] [nvarchar](100) NULL,
	[DocumentDate] [date] NULL,
	[DueDate] [date] NULL,
	[NetDocumentValue] [numeric](18, 2) NULL,
	[VATCode] [nvarchar](10) NULL,
	[VATRateApplied] [nvarchar](10) NULL,
	[VATAmount] [nvarchar](10) NULL,
	[GrossDocumentValue] [numeric](18, 2) NULL,
	[Notes] [nvarchar](max) NULL,
	[OutstandingAmount] [numeric](18, 2) NULL,
	[CompanyOutlet] [nvarchar](60) NULL,
	[Department] [nvarchar](60) NULL,
	[ReasonCode] [nvarchar](60) NULL,
	[Currency] [nvarchar](60) NULL,
	[CustomerIDs] [nvarchar](60) NULL,
	[CustomerSiteIDs] [nvarchar](10) NULL,
	[SiteNames] [nvarchar](60) NULL,
	[InvoiceLocationIDs] [nvarchar](10) NULL,
	[PaymentTypeIDs] [nvarchar](10) NULL,
	[PaymentPointIDs] [nvarchar](10) NULL,
	[ReasonIDs] [nvarchar](10) NULL,
	[AlternativeSearchReference] [nvarchar](10) NULL,
	[DMAccount] [nvarchar](100) NULL,
	[LinkID] [int] NULL,
	[Account_id] [bigint] NULL,
	[Child_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_AgedDebtorsData]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create view [dbo].[T_AgedDebtorsData] as
	select		
		ARAccountCode,
		DocumentType,
		DocumentNumber,
		DocumentDate,
		DueDate,
		ad.NetDocumentValue NettDocumentValue,
		VATCode,
		VATRateApplied,
		VATAmount,
		GrossDocumentValue,
		Notes,
		OutstandingAmount,
		CompanyOutlet,
		Department,
		ReasonCode,
		Currency,
		CustomerIDs,
		CustomerSiteIDs,
		SiteNames,
		InvoiceLocationIDs,
		PaymentTypeIDs,
		PaymentPointIDs,
		ReasonIDs,
		AlternativeSearchReference,
		ad.DMAccount		
	from AgedDebtorsData ad
GO
/****** Object:  Table [dbo].[CallLog]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CallLog](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[c_id] [int] NULL,
	[ARAccountCode] [nvarchar](10) NULL,
	[UniqueRef] [nvarchar](30) NULL,
	[CustomerSite] [nvarchar](255) NULL,
	[CallDate] [date] NULL,
	[CallType] [nvarchar](30) NULL,
	[Notes] [nvarchar](max) NOT NULL,
	[SysUser] [nvarchar](20) NULL,
	[CompanyOutlet] [nvarchar](255) NULL,
	[CallDateTime] [datetimeoffset](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_CallLog]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[T_CallLog] as
	select 
		ARAccountCode,
		CustomerSite,
		cast(CallDate as date) CallDate,
		'' CallNo,
		CallType,
		Notes,
		SysUser,
		CompanyOutlet,
		isnull(cast(CallDateTime as varchar), '') CallDateTime
	-- select *
	from CallLog
GO
/****** Object:  Table [dbo].[ContactLocations]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactLocations](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ARAccountCode] [nvarchar](255) NULL,
	[SiteUniqueId] [nvarchar](255) NULL,
	[Account_id] [bigint] NULL,
	[Child_id] [bigint] NULL,
	[ContactUniqueId_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerLocations]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerLocations](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[C_ID] [int] NULL,
	[C_ID_ALPHA] [nvarchar](255) NULL,
	[B_CONTACT] [nvarchar](255) NULL,
	[C_CONTACT] [nvarchar](255) NULL,
	[ARAccountCode] [nvarchar](255) NULL,
	[UniqRef] [nvarchar](200) NULL,
	[SiteName] [nvarchar](255) NULL,
	[HouseNbr] [nvarchar](255) NULL,
	[Address1] [nvarchar](255) NULL,
	[Address2] [nvarchar](255) NULL,
	[Town] [nvarchar](255) NULL,
	[County] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
	[Postcode] [nvarchar](255) NULL,
	[CompanyOutlet] [nvarchar](255) NULL,
	[TelNbr] [nvarchar](255) NULL,
	[FaxNbr] [nvarchar](255) NULL,
	[MobileNbr] [nvarchar](255) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[SICCode] [nvarchar](255) NULL,
	[Zone] [nvarchar](255) NULL,
	[AccessContact] [nvarchar](255) NULL,
	[DocumentDeliveryType] [nvarchar](255) NULL,
	[LocalAuthority] [nvarchar](255) NULL,
	[SiteType] [nvarchar](255) NULL,
	[LocationDescription] [nvarchar](255) NULL,
	[Latitude] [nvarchar](255) NULL,
	[Longitude] [nvarchar](255) NULL,
	[CustomerSiteState] [nvarchar](255) NULL,
	[SalesRepresentative] [nvarchar](255) NULL,
	[AltSearchReference] [nvarchar](255) NULL,
	[FederalID] [nvarchar](255) NULL,
	[CSR] [nvarchar](255) NULL,
	[CustomerOrderNo] [nvarchar](255) NULL,
	[AnalysisCode] [nvarchar](255) NULL,
	[InvoicingAddressSiteID] [nvarchar](255) NULL,
	[PaymentType] [nvarchar](255) NULL,
	[PaymentTerm] [nvarchar](255) NULL,
	[RebatePaymentType] [nvarchar](255) NULL,
	[RebatePaymentTerm] [nvarchar](255) NULL,
	[PaymentHandlingCode] [nvarchar](255) NULL,
	[PayableCycle] [nvarchar](255) NULL,
	[MasterChild] [int] NULL,
	[DifferentBilling] [int] NULL,
	[MasterParent] [int] NULL,
	[Taxable] [int] NULL,
	[TaxArea] [nvarchar](100) NULL,
	[HQLocation] [int] NULL,
	[OperationalArea] [nvarchar](100) NULL,
	[DMAccount] [nvarchar](100) NULL,
	[Billingname2] [nvarchar](255) NULL,
	[BillingAddress2] [nvarchar](255) NULL,
	[Locationname2] [nvarchar](255) NULL,
	[LocationAddress2] [nvarchar](255) NULL,
	[Account_id] [bigint] NULL,
	[Child_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_ContactLocations]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[T_ContactLocations] as
    SELECT 
        clo.ARAccountCode,
        SiteUniqueId,
        ContactUniqueId_id ContactUniqueId,
        '' SiteCode,
        '' IsPrimary,
        cl.DMAccount
        -- select count(1)
    FROM ContactLocations clo
    INNER JOIN CustomerLocations cl ON cl.UniqRef = clo.SiteUniqueId
GO
/****** Object:  Table [dbo].[Account]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[C_ID] [int] NOT NULL,
	[C_ID_ALPHA] [nvarchar](19) NULL,
	[C_CSTAT] [int] NULL,
	[C_COMMENTS] [nvarchar](max) NULL,
	[C_FIN_CHG] [numeric](18, 5) NULL,
	[C_DELNQLVL] [int] NULL,
	[B_TAXABLE] [bit] NULL,
	[B_ACCTTYPE] [nvarchar](15) NULL,
	[B_PO_NUM] [nvarchar](25) NULL,
	[B_PAGE] [int] NULL,
	[B_PAYBYCC] [bit] NULL,
	[B_CONTRACT_NUM] [nvarchar](30) NULL,
	[B_CONTRACT_DATE] [datetimeoffset](7) NULL,
	[C_15D] [numeric](18, 5) NULL,
	[C_45D] [numeric](18, 5) NULL,
	[REFERRAL] [nvarchar](80) NULL,
	[B_NAME_2ND] [nvarchar](50) NULL,
	[B_NAME_2ND2] [nvarchar](50) NULL,
	[B_ADDR1_2ND] [nvarchar](50) NULL,
	[B_ADDR1_2ND2] [nvarchar](50) NULL,
	[B_CITY_2ND] [nvarchar](50) NULL,
	[B_STATE_2ND] [nvarchar](20) NULL,
	[B_ZIP_2ND] [nvarchar](20) NULL,
	[C_DEPOSIT] [numeric](18, 5) NULL,
	[CREP1_NOTES] [nvarchar](80) NULL,
	[CREP2_NOTES] [nvarchar](80) NULL,
	[SREP1_NOTES] [nvarchar](80) NULL,
	[SREP2_NOTES] [nvarchar](80) NULL,
	[C_TYPE2] [bit] NULL,
	[C_TYPE3] [bit] NULL,
	[B_MTD] [float] NULL,
	[B_YTD] [float] NULL,
	[B_LMTD] [float] NULL,
	[B_LYTD] [float] NULL,
	[B_TERMS] [int] NULL,
	[REFERRAL2] [int] NULL,
	[KFACTOR] [numeric](10, 3) NULL,
	[GAL_DEGREE_DAY] [float] NULL,
	[LCK_GAL_DEGREE_DAY] [bit] NULL,
	[GAL_DAY] [float] NULL,
	[LCK_GAL_DAY] [bit] NULL,
	[T_ID] [int] NULL,
	[OUTPUT] [int] NULL,
	[C_120D] [numeric](18, 5) NULL,
	[C_150D] [numeric](18, 5) NULL,
	[B_SURCHARGE] [int] NULL,
	[SITEFILE] [nvarchar](255) NULL,
	[QUOTE_SHEET] [nvarchar](255) NULL,
	[C_TYPE4] [nvarchar](1) NULL,
	[C_TYPE5] [nvarchar](1) NULL,
	[C_TYPE6] [nvarchar](1) NULL,
	[C_TYPE7] [nvarchar](1) NULL,
	[C_TYPE8] [nvarchar](1) NULL,
	[C_TYPE9] [nvarchar](1) NULL,
	[C_LOCS2] [nvarchar](1) NULL,
	[C_NLOCS2] [int] NULL,
	[C_SUFFIX2] [int] NULL,
	[ISCHILD2] [bit] NULL,
	[C_LOCS3] [nvarchar](1) NULL,
	[C_NLOCS3] [int] NULL,
	[C_SUFFIX3] [int] NULL,
	[ISCHILD3] [bit] NULL,
	[TOTAL_TONS] [numeric](18, 5) NULL,
	[GUARANTEED_PRICE] [bit] NULL,
	[C_CURRENCY] [nvarchar](5) NULL,
	[REGION] [nvarchar](50) NULL,
	[DISTRICT] [nvarchar](50) NULL,
	[PROFILE_AREA] [nvarchar](50) NULL,
	[CLIENT_ID] [nvarchar](50) NULL,
	[BUSINESS_UNIT] [nvarchar](50) NULL,
	[LOCATION_TYPE] [nvarchar](50) NULL,
	[RANK_CLASS] [nvarchar](50) NULL,
	[DIVISION] [nvarchar](50) NULL,
	[CLIENT_SHARED_PERCENTAGE] [int] NULL,
	[SURCHARGE_BENCHMARK] [numeric](18, 5) NULL,
	[LOCATION_ID] [nvarchar](50) NULL,
	[NATIONAL_ACCT] [bit] NULL,
	[V_STORENO] [nvarchar](30) NULL,
	[PARENT_C_ID] [int] NULL,
	[AUTHORIZEDPAYEE] [nvarchar](50) NULL,
	[REBATEPAY] [int] NULL,
	[LastUpdated] [datetimeoffset](7) NULL,
	[B_QB_PATH] [nvarchar](255) NULL,
	[ContactViaPhone] [int] NULL,
	[Tax_Exempt_ID] [nvarchar](50) NULL,
	[Flex_Date] [datetimeoffset](7) NULL,
	[AutoEmailCustomerReceipt] [bit] NULL,
	[Relationship] [nvarchar](10) NOT NULL,
	[Parent_id_alpha] [nvarchar](54) NULL,
	[C_QUOTE] [nvarchar](50) NULL,
	[MigrationStatus] [nvarchar](50) NULL,
	[Sites] [int] NULL,
	[BillArea_id] [bigint] NULL,
	[BillingCycle_id] [bigint] NULL,
	[BillingGroup_id] [bigint] NULL,
	[BillingInfo_id] [bigint] NULL,
	[BillingInfo1_id] [bigint] NULL,
	[BillingInfo2_id] [bigint] NULL,
	[BillingInfo3_id] [bigint] NULL,
	[BillingInfo4_id] [bigint] NULL,
	[CREP1_id] [bigint] NULL,
	[CREP2_id] [bigint] NULL,
	[Company_id] [bigint] NULL,
	[DelinquencyLevel_id] [bigint] NULL,
	[FinanceCharge_id] [bigint] NULL,
	[LocationInfo_id] [bigint] NULL,
	[MasterAccount_id] [bigint] NULL,
	[SREP1_id] [bigint] NULL,
	[SREP2_id] [bigint] NULL,
	[StatementType_id] [bigint] NULL,
	[TaxArea_id] [bigint] NULL,
	[Terms_id] [bigint] NULL,
	[status_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Child]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Child](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[C_ID] [int] NOT NULL,
	[C_ID_ALPHA] [nvarchar](19) NULL,
	[C_CSTAT] [int] NULL,
	[C_COMMENTS] [nvarchar](max) NULL,
	[C_FIN_CHG] [numeric](18, 5) NULL,
	[C_DELNQLVL] [int] NULL,
	[B_TAXABLE] [bit] NULL,
	[B_ACCTTYPE] [nvarchar](15) NULL,
	[B_PO_NUM] [nvarchar](25) NULL,
	[B_PAGE] [int] NULL,
	[B_PAYBYCC] [bit] NULL,
	[B_CONTRACT_NUM] [nvarchar](30) NULL,
	[B_CONTRACT_DATE] [datetimeoffset](7) NULL,
	[C_15D] [numeric](18, 5) NULL,
	[C_45D] [numeric](18, 5) NULL,
	[REFERRAL] [nvarchar](80) NULL,
	[B_NAME_2ND] [nvarchar](50) NULL,
	[B_NAME_2ND2] [nvarchar](50) NULL,
	[B_ADDR1_2ND] [nvarchar](50) NULL,
	[B_ADDR1_2ND2] [nvarchar](50) NULL,
	[B_CITY_2ND] [nvarchar](50) NULL,
	[B_STATE_2ND] [nvarchar](20) NULL,
	[B_ZIP_2ND] [nvarchar](20) NULL,
	[C_DEPOSIT] [numeric](18, 5) NULL,
	[CREP1_NOTES] [nvarchar](80) NULL,
	[CREP2_NOTES] [nvarchar](80) NULL,
	[SREP1_NOTES] [nvarchar](80) NULL,
	[SREP2_NOTES] [nvarchar](80) NULL,
	[C_TYPE2] [bit] NULL,
	[C_TYPE3] [bit] NULL,
	[B_MTD] [float] NULL,
	[B_YTD] [float] NULL,
	[B_LMTD] [float] NULL,
	[B_LYTD] [float] NULL,
	[B_TERMS] [int] NULL,
	[REFERRAL2] [int] NULL,
	[KFACTOR] [numeric](10, 3) NULL,
	[GAL_DEGREE_DAY] [float] NULL,
	[LCK_GAL_DEGREE_DAY] [bit] NULL,
	[GAL_DAY] [float] NULL,
	[LCK_GAL_DAY] [bit] NULL,
	[T_ID] [int] NULL,
	[OUTPUT] [int] NULL,
	[C_120D] [numeric](18, 5) NULL,
	[C_150D] [numeric](18, 5) NULL,
	[B_SURCHARGE] [int] NULL,
	[SITEFILE] [nvarchar](255) NULL,
	[QUOTE_SHEET] [nvarchar](255) NULL,
	[C_TYPE4] [nvarchar](1) NULL,
	[C_TYPE5] [nvarchar](1) NULL,
	[C_TYPE6] [nvarchar](1) NULL,
	[C_TYPE7] [nvarchar](1) NULL,
	[C_TYPE8] [nvarchar](1) NULL,
	[C_TYPE9] [nvarchar](1) NULL,
	[C_LOCS2] [nvarchar](1) NULL,
	[C_NLOCS2] [int] NULL,
	[C_SUFFIX2] [int] NULL,
	[ISCHILD2] [bit] NULL,
	[C_LOCS3] [nvarchar](1) NULL,
	[C_NLOCS3] [int] NULL,
	[C_SUFFIX3] [int] NULL,
	[ISCHILD3] [bit] NULL,
	[TOTAL_TONS] [numeric](18, 5) NULL,
	[GUARANTEED_PRICE] [bit] NULL,
	[C_CURRENCY] [nvarchar](5) NULL,
	[REGION] [nvarchar](50) NULL,
	[DISTRICT] [nvarchar](50) NULL,
	[PROFILE_AREA] [nvarchar](50) NULL,
	[CLIENT_ID] [nvarchar](50) NULL,
	[BUSINESS_UNIT] [nvarchar](50) NULL,
	[LOCATION_TYPE] [nvarchar](50) NULL,
	[RANK_CLASS] [nvarchar](50) NULL,
	[DIVISION] [nvarchar](50) NULL,
	[CLIENT_SHARED_PERCENTAGE] [int] NULL,
	[SURCHARGE_BENCHMARK] [numeric](18, 5) NULL,
	[LOCATION_ID] [nvarchar](50) NULL,
	[NATIONAL_ACCT] [bit] NULL,
	[V_STORENO] [nvarchar](30) NULL,
	[PARENT_C_ID] [int] NULL,
	[AUTHORIZEDPAYEE] [nvarchar](50) NULL,
	[REBATEPAY] [int] NULL,
	[LastUpdated] [datetimeoffset](7) NULL,
	[B_QB_PATH] [nvarchar](255) NULL,
	[ContactViaPhone] [int] NULL,
	[Tax_Exempt_ID] [nvarchar](50) NULL,
	[Flex_Date] [datetimeoffset](7) NULL,
	[AutoEmailCustomerReceipt] [bit] NULL,
	[Relationship] [nvarchar](10) NOT NULL,
	[Parent_id_alpha] [nvarchar](54) NULL,
	[C_QUOTE] [nvarchar](50) NULL,
	[MigrationStatus] [nvarchar](50) NULL,
	[BillArea_id] [bigint] NULL,
	[BillingCycle_id] [bigint] NULL,
	[BillingGroup_id] [bigint] NULL,
	[BillingInfo_id] [bigint] NULL,
	[BillingInfo1_id] [bigint] NULL,
	[BillingInfo2_id] [bigint] NULL,
	[BillingInfo3_id] [bigint] NULL,
	[BillingInfo4_id] [bigint] NULL,
	[CREP1_id] [bigint] NULL,
	[CREP2_id] [bigint] NULL,
	[Company_id] [bigint] NULL,
	[DelinquencyLevel_id] [bigint] NULL,
	[FinanceCharge_id] [bigint] NULL,
	[LocationInfo_id] [bigint] NULL,
	[MasterAccount_id] [bigint] NULL,
	[Parent_id] [bigint] NULL,
	[SREP1_id] [bigint] NULL,
	[SREP2_id] [bigint] NULL,
	[StatementType_id] [bigint] NULL,
	[TaxArea_id] [bigint] NULL,
	[Terms_id] [bigint] NULL,
	[status_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Contacts]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Contacts](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ARAccountCode] [nvarchar](255) NULL,
	[Salutation] [nvarchar](255) NULL,
	[Forename] [nvarchar](255) NULL,
	[Surname] [nvarchar](255) NULL,
	[JobTitle] [nvarchar](255) NULL,
	[TelNbr] [nvarchar](255) NULL,
	[TelExtNbr] [nvarchar](255) NULL,
	[MobileNbr] [nvarchar](255) NULL,
	[FaxNbr] [nvarchar](255) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[Notes] [nvarchar](255) NULL,
	[ContactType2] [nvarchar](255) NULL,
	[ContactType3] [nvarchar](255) NULL,
	[TelNo] [nvarchar](255) NULL,
	[FaxNo] [nvarchar](255) NULL,
	[Billingname2] [nvarchar](255) NULL,
	[Account_id] [bigint] NULL,
	[Child_id] [bigint] NULL,
	[ContactType_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContactType]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactType](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_Contacts]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[T_Contacts] as
    select 
            ARAccountCode,
            c.id ContactUniqueId,
            Salutation,
            Forename,
            Surname,
            JobTitle,
            TelNbr,
            TelExtNbr,
            MobileNbr,
            FaxNbr,
            EmailAddress,
            Notes,
            ct.Type ContactType1,
            ContactType2,
            ContactType3,
            TelNo,
            FaxNo,
            '' IsPrimary,
            '' ReceiveServiceUpdatesByEmail,
            '' ReceiveServiceUpdatesByText,
            '' ReceiveMarketingUpdatesViaEmail,
            '' ReceiveMarketingUpdatesViaText,
            '' IsEmailBasedUsername,
            '' ContactRegistrationStatus,
            '' ActivationCode,
            '' PinCode,
            '' AccessGroup,
            '' Password
            ,CASE 
                WHEN ch.id IS NULL THEN a.C_ID_ALPHA
                ELSE ch.C_ID_ALPHA END [DMAccount]
            -- select count(1)
    from Contacts c
    LEFT JOIN Child ch ON ch.id = c.Child_id
    LEFT JOIN Account a ON a.id = c.Account_id
    inner join ContactType ct on ct.id = c.ContactType_id
GO
/****** Object:  View [dbo].[T_CustomerLocations]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[T_CustomerLocations] as
        select  ARAccountCode,
            UniqRef,
            SiteName,
            HouseNbr,
            Address1,
            Address2,
            Town,
            County,
            Country,
            Postcode,
            CompanyOutlet,
            TelNbr,
            FaxNbr,
            MobileNbr,
            EmailAddress,
            SICCode,
            Zone,
            AccessContact,
            DocumentDeliveryType,
            LocalAuthority,
            SiteType,
            LocationDescription,
            Latitude,
            Longitude,
            CustomerSiteState,
            '' SiteSuspendStartDate,
            SalesRepresentative,
            '' RegionCode,
            AltSearchReference,
            FederalId,
            CSR,
            CustomerOrderNo,
            AnalysisCode,
            InvoicingAddressSiteID,
            PaymentType,
            PaymentTerm,
            RebatePaymentType,
            RebatePaymentTerm,
            PaymentHandlingCode,
            PayableCycle,
            '' SiteNotes,
            '' ServiceLocation,
            State,
            '' Gnr,
            '' Bnr,
            '' Fnr,
            '' Snr,
            '' commune,
            case when Taxable = 1 then 0 else 1 end IsTaxExempt,
            '' TaxExemptID,
            TaxArea TaxJurisdiction,
            '' ExcludeFromSurcharge,
            '' ExcludeFromFranchiseFee,
            InvoicingAddressSiteID InvoiceAddressUniqRef,
            case when SiteType = 'HQ' then '1' else '0' end HQLocation,
            '' Addr8,
            '' Addr9,
            case when SiteType = 'HQ' then '1' else '0' end IsNonServiceSiteFlag,
            OperationalArea,
            '' CoCNumber,
            DMAccount
        from CustomerLocations
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[c_id] [int] NULL,
	[c_id_alpha] [nvarchar](255) NULL,
	[ar_account_code] [nvarchar](255) NULL,
	[company] [nvarchar](255) NULL,
	[customer_name] [nvarchar](255) NULL,
	[currency] [nvarchar](255) NULL,
	[invoice_cycle] [nvarchar](255) NULL,
	[invoice_frequency_term] [nvarchar](255) NULL,
	[payment_term] [nvarchar](255) NULL,
	[payment_type] [nvarchar](255) NULL,
	[credit_limit] [nvarchar](255) NULL,
	[customer_state] [nvarchar](255) NULL,
	[invoice_document_delivery_type] [nvarchar](255) NULL,
	[ar_ap_documents_option] [nvarchar](255) NULL,
	[credit_controller] [nvarchar](255) NULL,
	[customer_category] [nvarchar](255) NULL,
	[sic_code] [nvarchar](255) NULL,
	[combine_ar_ap_for_credit_checks] [nvarchar](255) NULL,
	[combine_charges_rebates] [nvarchar](255) NULL,
	[is_internal] [nvarchar](255) NULL,
	[rct_customer] [nvarchar](255) NULL,
	[show_lft_on_invoice] [nvarchar](255) NULL,
	[tickets_required_with_invoice] [nvarchar](255) NULL,
	[proof_of_service_required] [nvarchar](255) NULL,
	[collate_invoices] [nvarchar](255) NULL,
	[settlement_percentage] [nvarchar](255) NULL,
	[roll_up_invoice_by_service] [nvarchar](255) NULL,
	[roll_up_invoice_by_site] [nvarchar](255) NULL,
	[customer_invoice_number_required] [nvarchar](255) NULL,
	[is_order_number_required] [nvarchar](255) NULL,
	[summary_invoice] [nvarchar](255) NULL,
	[rebate_billing_option] [nvarchar](255) NULL,
	[rebate_invoice_cycle] [nvarchar](255) NULL,
	[rebate_invoice_frequency_term] [nvarchar](255) NULL,
	[invoices_sent_electronically] [nvarchar](255) NULL,
	[one_inv_per_po] [nvarchar](255) NULL,
	[one_inv_per_dept] [nvarchar](255) NULL,
	[one_inv_per_job] [nvarchar](255) NULL,
	[contract_status] [nvarchar](255) NULL,
	[exclude_from_statement_run] [nvarchar](255) NULL,
	[customer_type] [nvarchar](255) NULL,
	[customer_notes] [nvarchar](500) NULL,
	[customer_template] [nvarchar](255) NULL,
	[customer_group] [nvarchar](255) NULL,
	[federal_id] [nvarchar](255) NULL,
	[marketing_source] [nvarchar](255) NULL,
	[start_date] [date] NULL,
	[alt_search_reference] [nvarchar](255) NULL,
	[business_sector] [nvarchar](255) NULL,
	[ap_account_code] [nvarchar](255) NULL,
	[sales_rep] [nvarchar](255) NULL,
	[csr] [nvarchar](255) NULL,
	[payment_handling_code] [nvarchar](255) NULL,
	[rebate_payment_type] [nvarchar](255) NULL,
	[rebate_payment_terms] [nvarchar](255) NULL,
	[sales_territory] [nvarchar](255) NULL,
	[master_ar_account_code] [nvarchar](255) NULL,
	[dm_account] [nvarchar](100) NULL,
	[Account_id] [bigint] NULL,
	[Child_id] [bigint] NULL,
	[Parent_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_Customers]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[T_Customers] as
        select  cu.ar_account_code ARAccountCode,
                cu.company Company,
                cu.customer_name CustomerName,
                cu.currency Currency,
                isnull(cu.invoice_cycle, '')+'|'+isnull(cu.customer_category, '') InvoiceCycle,
                cu.invoice_frequency_term InvoiceFrequencyTerm,
                cu.payment_term PaymentTerm,
                cu.payment_type PaymentType,
                '5000' CreditLimit,
                cu.customer_state CustomerState,
                '' SuspendStartDate,
                cu.invoice_document_delivery_type InvoiceDocumentDeliveryType,
                cu.ar_ap_documents_option ARAPDocumentsOption,
                cu.credit_controller CreditController,
                isnull(cu.invoice_cycle, '')+'|'+isnull(cu.customer_category, '') CustomerCategory,
                cu.sic_code SICCode,
                cu.combine_ar_ap_for_credit_checks CombineARAPForCreditChecks,
                cu.combine_charges_rebates CombineChargesRebates,
                cu.is_internal IsInternal,
                cu.rct_customer RCTCustomer,
                cu.show_lft_on_invoice ShowLFTOnInvoice,
                cu.tickets_required_with_invoice TicketsRequiredWithInvoice,
                cu.proof_of_service_required ProofOfServiceRequired,
                cu.collate_invoices CollateInvoices,
                cu.settlement_percentage SettlementPercentage,
                cu.roll_up_invoice_by_service RollUpInvoiceByService,
                cu.roll_up_invoice_by_site RollUpInvoiceBySite,
                cu.customer_invoice_number_required CustomerInvoiceNumberRequired,
                cu.is_order_number_required IsOrderNumberRequired,
                cu.summary_invoice SummaryInvoice,
                cu.rebate_billing_option RebateBillingOption,
                cu.rebate_invoice_cycle RebateInvoiceCycle,
                cu.rebate_invoice_frequency_term RebateInvoiceFrequencyTerm,
                cu.invoices_sent_electronically InvoicesSentElectronically,
                cu.one_inv_per_po OneInvPerPO,
                cu.one_inv_per_dept OneInvPerDept,
                cu.one_inv_per_job OneInvPerJob,
                cu.contract_status ContractStatus,
                cu.exclude_from_statement_run ExcludeFromStatementRun,
                isnull(cu.invoice_cycle, '')+'|'+isnull(cu.customer_category, '') CustomerType,
                isnull(cu.invoice_cycle, '')+'|'+isnull(cu.customer_category, '') CustomerTemplate,
                isnull(cu.customer_category, '') BusinessType,
                cu.customer_group CustomerGroup,
                cu.federal_id FederalId,
                cu.customer_notes CustomerNotes,
                '' BusinessTypeOption,
                cu.marketing_source MarketingSource,
                cast(cu.start_date as date) StartDate,
                '' ApprovedDate,
                cu.alt_search_reference AlternativeSearchReference,
                cu.business_sector BusinessSector,
                cu.ap_account_code APAccountCode,
                cu.sales_rep SalesRep,
                cu.CSR,
                cu.payment_handling_code PaymentHandlingCode,
                cu.rebate_payment_type RebatePaymentType,
                cu.rebate_payment_terms RebatePaymentTerms,
                '' SalesTerritory,
                '' Department,
                cu.master_ar_account_code MasterARAccountCode,
                '' ReceiveServiceUpdatesByEmail,
                '' ReceiveServiceUpdatesByText,
                '' ReceiveMarketingUpdatesByEmail,
                '' ReceiveMarketingUpdatesByText,
                cl.TaxArea TaxArea,
                case when cl.Taxable = 1 then 0 else 1 end IsTaxExempt,
                '' ExcludeFromLatePaymentFee,
                '' FinanceChargeDaysAfter,
                '' FinanceChargePercentage,
                '' CoCNumber,
                '' VATRegistrationNumber,
                '' AmiceNumber,
                '' ApplyPaymentServiceFee,
                '' BillToCustomer
				, cu.dm_account
            from Customers cu
			left join CustomerLocations cl on cl.DMAccount = cu.dm_account and cast(cu.c_id as varchar) = cl.UniqRef
GO
/****** Object:  Table [dbo].[CustomerServiceAgreementHeader]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerServiceAgreementHeader](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[CompanyOutlet] [nvarchar](255) NULL,
	[ARAccountCode] [nvarchar](255) NULL,
	[UniqRef] [nvarchar](30) NULL,
	[AgreeNbr] [nvarchar](32) NULL,
	[ContainerType] [nvarchar](30) NOT NULL,
	[MaterialClass] [nvarchar](30) NOT NULL,
	[PrimaryService] [nvarchar](255) NULL,
	[ScheduledRouted] [nvarchar](30) NOT NULL,
	[startdate] [datetimeoffset](7) NULL,
	[Description] [nvarchar](255) NULL,
	[VAT] [nvarchar](30) NOT NULL,
	[RequiresPeriodicDoC] [nvarchar](30) NOT NULL,
	[ProofOfServiceRequired] [nvarchar](30) NOT NULL,
	[OrderNumberRequired] [nvarchar](30) NOT NULL,
	[InvoiceCycle] [nvarchar](30) NOT NULL,
	[DriverNotes] [nvarchar](30) NOT NULL,
	[OrderNotes] [nvarchar](30) NOT NULL,
	[CustomerSuppliesReleaseNumbers] [nvarchar](30) NOT NULL,
	[InvoiceOnShipDate] [nvarchar](30) NOT NULL,
	[TransportSupplier] [nvarchar](30) NOT NULL,
	[CollateInvoices] [nvarchar](30) NOT NULL,
	[LastInvoiceDate] [nvarchar](30) NOT NULL,
	[InvoiceFrequencyTerm] [nvarchar](30) NOT NULL,
	[OutletAgreement] [nvarchar](30) NOT NULL,
	[MasterARAccountCode] [nvarchar](255) NULL,
	[DMAccount] [nvarchar](255) NULL,
	[Customer_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_CustomerServiceAgreementHeader]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[T_CustomerServiceAgreementHeader] as
	select
		CompanyOutlet,
		ARAccountCode,
		UniqRef,
		AgreeNbr,
		ContainerType,
		MaterialClass,
		PrimaryService,
		ScheduledRouted,
		cast(StartDate as date) StartDate,
		Description,
		VAT,
		RequiresPeriodicDoC,
		ProofOfServiceRequired,
		OrderNumberRequired,
		InvoiceCycle,
		DriverNotes,
		OrderNotes,
		CustomerSuppliesReleaseNumbers,
		InvoiceOnShipDate,
		TransportSupplier,
		CollateInvoices,
		LastInvoiceDate,
		InvoiceFrequencyTerm,
		'' Notes,
		'' ParentServiceAgreementNumber,
		'' Department,
		'' IsForAllSites,
		'' EndDate,
		DMAccount
	from CustomerServiceAgreementHeader sah
GO
/****** Object:  Table [dbo].[MasterAccount]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterAccount](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[c_id] [int] NOT NULL,
	[Parent_ID] [nvarchar](54) NULL,
	[Name] [nvarchar](50) NULL,
	[ARAccount] [nvarchar](32) NOT NULL,
	[Currency] [nvarchar](50) NOT NULL,
	[Notes] [nvarchar](4000) NULL,
	[DMAccount] [nvarchar](50) NOT NULL,
	[ChildCount] [int] NULL,
	[Project] [nvarchar](50) NOT NULL,
	[Status_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_MasterCustomers]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[T_MasterCustomers] AS
		select	Name,
			ARAccount	MasterARAccountCode,
			''	MasterAPAccountCode,
			Currency,
			Notes
		from MasterAccount
GO
/****** Object:  Table [dbo].[Routing]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Routing](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[RouteID] [int] NULL,
	[RouteNo] [nvarchar](255) NOT NULL,
	[RouteDescription] [nvarchar](255) NOT NULL,
	[WhichDay] [nvarchar](255) NOT NULL,
	[Notes] [nvarchar](255) NOT NULL,
	[VehicleType] [nvarchar](255) NOT NULL,
	[PickUpInterval] [nvarchar](255) NOT NULL,
	[Haulier] [nvarchar](255) NOT NULL,
	[RouteManagementType] [nvarchar](255) NOT NULL,
	[NextPlannedDate] [date] NOT NULL,
	[SingleDayRoute] [bit] NOT NULL,
	[NoOfStops] [int] NULL,
	[Company_id] [bigint] NULL,
	[RouteType_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_Routing]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[T_Routing] as
	select
		co.Company CompanyOutlet,
		RouteNo,
		RouteDescription,
		WhichDay,
		Notes,
		VehicleType,
		PickUpInterval,
		Haulier,
		'On Vehicle' RouteManagementType,
		'' DefaultTipMaterial,
		cast(NextPlannedDate as date) NextPlannedDate,
		'' DestinationLocation,
		'' DaysBeforeExpiry,
		'' Vehicle
	-- select count(1)
	from Routing r
	inner join Company co on co.id = r.Company_id
GO
/****** Object:  Table [dbo].[SiteOrderAssignments]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SiteOrderAssignments](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[SOAssignmentId] [int] NULL,
	[SiteOrderUniqueRef] [nvarchar](50) NOT NULL,
	[Action] [nvarchar](7) NOT NULL,
	[DayOfWeek] [int] NULL,
	[RouteTemplate] [nvarchar](255) NOT NULL,
	[Position] [int] NOT NULL,
	[PickUpInterval] [nvarchar](255) NOT NULL,
	[ContainerType] [nvarchar](60) NOT NULL,
	[StartDate] [date] NOT NULL,
	[RoutedOrScheduled] [nvarchar](40) NOT NULL,
	[MinLiftQuantity] [nvarchar](1) NOT NULL,
	[RequiresQuantity] [nvarchar](1) NOT NULL,
	[NextDueDate] [nvarchar](1) NOT NULL,
	[Notes] [nvarchar](max) NULL,
	[SJVehicle] [nvarchar](1) NOT NULL,
	[SJDriver] [nvarchar](1) NOT NULL,
	[DMAccount] [nvarchar](30) NOT NULL,
	[StopID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_SiteOrderAssignments]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[T_SiteOrderAssignments] as
    select	
        SiteOrderUniqueRef,
        Action,
        DayOfWeek,
        RouteTemplate,
        Position,
        PickUpInterval,
        soa.ContainerType,
        cast(soa.StartDate as date) StartDate,
        RoutedOrScheduled,
        MinLiftQuantity,
        RequiresQuantity,
        NextDueDate,
        Notes,
        SJVehicle,
        SJDriver,
        soh.AgreeNbr,
        soh.Frequency ServiceFrequency,
        co.Company CompanyOutlet,
        '' OldRouteAssignmentId,
        '' MaxLiftQuantity,
		row_number() over(order by SiteOrderUniqueRef)  SOAssignmentID,
        soa.DMAccount
    from SiteOrderAssignments soa
    inner join SiteOrderHeader soh on soh.id = soa.SiteOrderUniqueRef
    inner join Company co on co.id = soh.CompanyOutlet_id
GO
/****** Object:  Table [dbo].[SiteOrderRental]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SiteOrderRental](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[SiteOrderUniqueRef] [nvarchar](32) NULL,
	[AgreeNbr] [nvarchar](32) NULL,
	[ContainerType] [nvarchar](255) NULL,
	[RentalFrequency] [nvarchar](255) NULL,
	[RentalRate] [numeric](32, 19) NULL,
	[RentalStartDate] [date] NULL,
	[RentalEndDate] [nvarchar](1) NOT NULL,
	[RentalQuantity] [int] NULL,
	[Action] [nvarchar](255) NULL,
	[BinsOnSiteBasedOnQuantityNow] [nvarchar](1) NOT NULL,
	[RentalType] [nvarchar](1) NOT NULL,
	[StartOnStartOfCycle] [nvarchar](1) NOT NULL,
	[EndOnEndOfCycle] [nvarchar](1) NOT NULL,
	[RentalApplication] [nvarchar](1) NOT NULL,
	[RentalQuantityAttribute] [nvarchar](1) NOT NULL,
	[PriceNotes] [nvarchar](32) NULL,
	[DMAccount] [nvarchar](255) NULL,
	[ServiceCode] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](255) NULL,
	[Customer_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_SiteOrderRental]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[T_SiteOrderRental] as
	select 	
		SiteOrderUniqueRef,
		sor.AgreeNbr,
		sd.ServiceMap ContainerType,
		RentalFrequency,
		RentalRate,
		RentalStartDate,
		RentalEndDate,
		RentalQuantity,
		sor.Action,
		BinsOnSiteBasedOnQuantityNow,
		RentalType,
		StartOnStartOfCycle,
		EndOnEndOfCycle,
		RentalApplication,
		RentalQuantityAttribute,
		soh.Frequency ServiceFrequency,
		row_number() over(order by SiteOrderUniqueRef)  SORentalId,
		sor.DMAccount,
		sor.ServiceCode,
		sor.ServiceDescription
	-- select count(1)
	from SiteOrderRental sor
	inner join SiteOrderHeader soh on soh.id = sor.SiteOrderUniqueRef
	inner join ServiceCodeDetail sd on sd.ServiceCode = sor.ServiceCode
GO
/****** Object:  Table [dbo].[Status]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[StatusID] [int] NOT NULL,
	[SysValue] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_ActiveAccounts]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    CREATE VIEW [dbo].[v_ActiveAccounts]
    AS
    SELECT CU.C_ID, ST.Status, CU.C_CUR_BAL
    -- select distinct st.Status
    FROM ConversionData.dbo.cust CU
    INNER JOIN Status ST ON ST.StatusID = CU.C_CSTAT
    WHERE ST.Status NOT IN ('INACTIVE') OR CU.C_CUR_BAL <> 0
GO
/****** Object:  View [dbo].[v_ActiveChildren]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE VIEW [dbo].[v_ActiveChildren]
	AS
	SELECT CU.C_ID, aa.Status, cu.c_cur_bal
    FROM ConversionData.dbo.cust CU
    inner join v_ActiveAccounts aa on aa.C_ID = cu.C_ID
	where cu.C_ID_ALPHA like '%-%' and cu.C_ID_ALPHA not like '%-001'
GO
/****** Object:  View [dbo].[v_ParentChildrenCount]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE VIEW [dbo].[v_ParentChildrenCount]
	AS
	select p.c_id, p.C_ID_ALPHA, count(c.c_id_alpha) ChildCount
	from ConversionData.dbo.cust p
	left join (
	select c_id_alpha, left(c_id_alpha, charindex('-', C_ID_ALPHA)) ParentAccount
	from ConversionData.dbo.cust cu
	inner join v_ActiveChildren ac on ac.C_ID = cu.C_ID
	
	) c on c.ParentAccount = left(p.c_id_alpha, charindex('-', p.C_ID_ALPHA))
	where p.C_ID_ALPHA like '%-001'
	group by p.C_ID, p.C_ID_ALPHA
GO







/****** Object:  View [dbo].[v_CustWithSingleRoute]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[v_CustWithSingleRoute] AS
select rx.C_ID, cu.C_ID_ALPHA
from ConversionData.dbo.RXRF rx
inner join CustomerServiceAgreementPrices p on p.c_id = rx.C_ID
inner join ConversionData.dbo.RTES rt on rt.ROUTEID = rx.ROUTEID
inner join ConversionData.dbo.CUST cu on cu.c_id = rx.C_ID
group by rx.c_id, cu.C_ID_ALPHA
having count(distinct rt.ROUTEID) = 1	

GO
/****** Object:  Table [dbo].[RouteAssignments]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RouteAssignments](
	[STOPID] [int] NOT NULL,
	[AutoID] [int] NULL,
	[routeid] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_UnassignedServices]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[v_UnassignedServices] AS
	select sap.* from CustomerServiceAgreementPrices sap
	left join (select distinct autoid from RouteAssignments) ra on ra.AutoID = sap.AutoID
	where [Action] = 'Service'
	and ra.AutoID is null	

GO
/****** Object:  View [dbo].[v_SiteOrderHeader]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [dbo].[v_SiteOrderHeader] AS
	select soh.id SiteOrderUniqueRef, co.Company CompanyOutlet, ARAccountCode, UniqueRefNbr, AgreeNbr, OrderCombinationGroup, ContainerType, MaterialType, StartDate, EndDateIfClosed, RouteOrSched, IsCustomerOwnedBin, 
                         InvoiceMethod, Haulier, DisposalPoint, isnull(cu.customer_category, '') +'|'+ PrimaryService PrimaryService, VAT, CustomerOrderNumber, LastInvoiceDate, DriverNotes, Notes2, Contact
						 , InvoiceCycle, PaymentType, ServicePointCode, Frequency,ct.Origin, DMAccount, autoid, ServiceID
	--select count(1)
	from SiteOrderHeader soh
	inner join Company co on co.id = soh.CompanyOutlet_id
	inner join Customers cu on cu.ar_account_code = soh.ARAccountCode
	inner join 
	(
	select cu.c_id, ct.DATA Origin
	from ConversionData.dbo.cust cu
	left join conversiondata.dbo.udef ct on ct.UNIQUE_ID = cu.B_CONTRACT
	) ct on ct.C_ID = cu.c_id




	

GO
/****** Object:  Table [dbo].[SiteOrderItems]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SiteOrderItems](
	[SOItemId] [bigint] NULL,
	[SiteOrderUniqueRef] [bigint] NOT NULL,
	[AgreeNbr] [nvarchar](20) NOT NULL,
	[ContainerType] [nvarchar](60) NOT NULL,
	[StartDate] [date] NOT NULL,
	[Items] [numeric](18, 5) NULL,
	[DMAccount] [nvarchar](30) NOT NULL,
	[size] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_SiteOrderItems]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[T_SiteOrderItems] as
	select 
			SiteOrderUniqueRef,
			ContainerType,
			soi.StartDate ItemStartDate,
			AgreeNbr,
			'' ApplyBatchProcessing,
			'' BatchProcessingStartDate,
			row_number() over(partition by SiteOrderUniqueRef order by SiteOrderUniqueRef) BinOnSiteNumber,
			ROW_NUMBER() over(order by SiteOrderUniqueRef) SOItemId,
			DMAccount

	from SiteOrderItems soi
GO
/****** Object:  Table [dbo].[BillingCycle]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillingCycle](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[BillingCycleID] [int] NOT NULL,
	[Cycle] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_PreliminaryServices]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[V_PreliminaryServices]
	AS

	select ROW_NUMBER() over(order by co.SVC_CODE_ALPHA) id, max(C_ID_ALPHA) DMAccount, count(cu.C_ID) '# Used', co.SVC_CODE_ALPHA ServiceCode, co.DESCRIPT ServiceDescription
	, sc.data ServiceCategory, co.LINKSTAT, '' Size, '' Unit, '' Action, '' Frequency, '' ServiceMap 
	, '' Container, '' Type, um.DATA UnitOfMeasure
	--select distinct cu.c_id_alpha--, st.description, st.status
	-- select count(1)
	from  ConversionData.dbo.AUTO a 
	inner join ConversionData.dbo.CODE co on co.SVC_CODE = a.SVC_CODE
	inner join ConversionData.dbo.cust cu on cu.c_id = a.C_ID
	--inner join (select distinct c_id, CustomerSiteState from CustomerLocations) cl on cl.C_ID = cu.C_ID
	--where cl.C_ID is null 
	inner join ModMigration.dbo.Status st on st.StatusID = cu.C_CSTAT
	left join ModMigration.dbo.BillingCycle bc on bc.BillingCycleID = a.BILLCYCLE
	inner join ConversionData.dbo.udef sc on sc.UNIQUE_ID = co.CATEGORY
	inner join ConversionData.dbo.udef um on um.UNIQUE_ID = co.UNITMEASUR
	where  (a.STOPDATE is null or cast(a.STOPDATE as date) > cast(getdate() as date) )
	and st.Description = 'ActiveAuto'
	AND A.PRORATE <> 'Y'  
	group by co.SVC_CODE_ALPHA , co.DESCRIPT 
	, sc.data , co.LINKSTAT,  um.DATA 
	
GO
/****** Object:  Table [dbo].[TempContainers]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempContainers](
	[ContRefId] [bigint] NULL,
	[ContainerSerialNo] [varchar](60) NULL,
	[ContainerType] [varchar](767) NULL,
	[TagReference] [varchar](1) NOT NULL,
	[Notes] [varchar](1000) NULL,
	[CompanyOutlet] [varchar](50) NULL,
	[DateOfDelivery] [date] NULL,
	[SiteOrderUniqueRef] [bigint] NOT NULL,
	[Commercial] [varchar](1) NOT NULL,
	[BinOnSiteNumber] [varchar](1) NOT NULL,
	[AgreeNbr] [nvarchar](32) NULL,
	[DMAccount] [nvarchar](30) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[T_Containers]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[T_Containers] as
	select *
	from TempContainers
GO
/****** Object:  UserDefinedFunction [dbo].[fnTally]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE FUNCTION [dbo].[fnTally]
/**********************************************************************************************************************
 Purpose:
 Return a column of BIGINTs from 1up to and including @MaxN with a max value of 1 Trillion.

 As a performance note, it takes about 00:01:45 (hh:mm:ss) to generate 1 Billion numbers to a throw-away variable.

 Usage:
--===== Basic syntax example (Returns BIGINT)
 SELECT t.N
   FROM dbo.fnTally(@MaxN) t
;

 Notes:
 1. Can also be used with APPLY.
 2. Note that this does not contain Recursive CTEs (rCTE), which are much slower and resource intensive.
 3. Based on Itzik Ben-Gan's cascading CTE (cCTE) method for creating a "readless" Tally Table source of BIGINTs.
    Refer to the following URLs for how it works and introduction for how it replaces certain loops. 
    http://www.sqlservercentral.com/articles/T-SQL/62867/
    http://sqlmag.com/sql-server/virtual-auxiliary-table-numbers
 4. As a bit of a sidebar, one of the definitions of the word "Tally" is "to count", which is what this function does.
    It "counts" from 1 to whatever the value of @MaxN is every time it's called and it does so without producing any
    logical reans and it's nasty fast.
 5. I don't normally use the "Hungarian Notation" method of naming but I also have a table name Tally and so this 
    function needed to be named differently.

-- Jeff Moden
**********************************************************************************************************************/
        (@MaxN BIGINT)
RETURNS TABLE WITH SCHEMABINDING AS 
 RETURN WITH
  E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL --Could be converted to VALUES after 2008
            SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL --but there's no performance gain in doing so
            SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL --so kept it "2005 compatible".
            SELECT 1)                               --10^1 or 10 rows
, E4(N) AS (SELECT 1 FROM E1 a, E1 b, E1 c, E1 d)   --10^4 or 10 Thousand rows
,E12(N) AS (SELECT 1 FROM E4 a, E4 b, E4 c)         --10^12 or 1 Trillion rows (yeah, call me when that's done. ;-)                 
            SELECT TOP(@MaxN) N = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E12 -- Values from 1 to @MaxN
;
GO
/****** Object:  View [dbo].[CustomerStatusMapping]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








		create VIEW [dbo].[CustomerStatusMapping]
		AS
			select UNIQUE_ID, SYSTEM_VAL,data, case 
			when system_val = '0' then 'ActiveAuto'
			when system_val = '5' then 'ActiveAuto'
			when system_val = '4' then 'InActiveAuto'
			when system_val = '1' then 'InActiveAuto'
			when system_val = '7' then 'ActiveAuto'
			when system_val = '3' then 'InActiveAuto'
			when system_val = '6' then 'InActiveAuto'
			when system_val = '8' then 'ActiveAuto'
			else '          ' end SystemValDefined
			from ConversionData.dbo.udef
			where name like '%custstat%'
GO
/****** Object:  View [dbo].[HIST1Y]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[HIST1Y]
		AS
	select c_id, cast(max(h.TRANS_DATE) as date) MaxDate, datediff(year, cast(max(h.TRANS_DATE) as date), cast(getdate() as date)) Years
	from conversiondata.dbo.hist h
	where h.type in ('C','R','A')
	group by c_id 
	having datediff(year, cast(max(h.TRANS_DATE) as date), cast(getdate() as date)) <= 1
GO
/****** Object:  View [dbo].[v_AccountRelationships]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[v_AccountRelationships]
AS

select C_ID, case
when C_ID_ALPHA  like '%-001' and C_ID_ALPHA not like '%-%-%' then 'parent'
when C_ID_ALPHA like '%-%' and C_ID_ALPHA not like '%-001' and C_ID_ALPHA not like '%-%-%' then 'child'
when C_ID_ALPHA  like '%-%-%' then 'grandchild' 
else 'single' end as Relationship
--select c_id 
from ConversionData.dbo.cust 

GO
/****** Object:  Table [dbo].[ActiveAuto]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActiveAuto](
	[DMAccount] [varchar](19) NULL,
	[ServiceCode] [varchar](255) NULL,
	[ServiceDescription] [varchar](25) NULL,
	[BillingCycle] [nvarchar](50) NULL,
	[ServiceCategory] [varchar](255) NULL,
	[UnitOfMeasure] [varchar](255) NULL,
	[C_ID] [int] NULL,
	[SVC_CODE] [int] NULL,
	[STARTDATE] [datetime] NULL,
	[STOPDATE] [datetime] NULL,
	[AMOUNT] [numeric](18, 6) NULL,
	[DEFAULT_] [varchar](1) NULL,
	[MULTIPLY] [numeric](18, 5) NULL,
	[REFERENCE] [varchar](14) NULL,
	[BILLCYCLE] [int] NULL,
	[DAY_RTE] [varchar](50) NULL,
	[PRORATE] [varchar](1) NULL,
	[COST] [numeric](18, 6) NULL,
	[FREETONS] [numeric](18, 5) NULL,
	[AUTOID] [int] NOT NULL,
	[FREQUENCY] [varchar](15) NULL,
	[CONSZUID] [int] NULL,
	[COST_FREETONS] [numeric](18, 5) NULL,
	[DISCOUNT] [numeric](18, 5) NULL,
	[V_ID] [int] NULL,
	[LAST_BILL] [datetime] NULL,
	[ADJ_WGT] [numeric](18, 5) NULL,
	[V_REFERENCE] [varchar](50) NULL,
	[COMPACT_RATE] [numeric](18, 5) NULL,
	[ALLOC] [int] NULL,
	[CONGRPUID] [int] NULL,
	[BASELINE] [bit] NULL,
	[LINK_AUTOID] [int] NULL,
	[CANCELDATE] [datetime] NULL,
	[V_INVOICED] [bit] NULL,
	[SRVC_AREA_TYPE] [int] NULL,
	[VARIABLE_PRICING] [bit] NULL,
	[PARTNER_ELIGIBLE] [bit] NULL,
	[DISCOUNT_AMT] [numeric](18, 5) NULL,
	[MARKUP_PERCENT] [numeric](18, 5) NULL,
	[MARKUP_AMT] [numeric](18, 5) NULL,
	[CANCEL_START] [int] NULL,
	[CANCEL_END] [int] NULL,
	[TOTAL_SHARED_SAVING] [numeric](18, 5) NULL,
	[GL_CODE] [varchar](50) NULL,
	[EXCLUDE_FUEL_SURCHARGE] [bit] NULL,
	[CONT_TYPE] [int] NULL,
	[MON] [bit] NULL,
	[TUE] [bit] NULL,
	[WED] [bit] NULL,
	[THU] [bit] NULL,
	[FRI] [bit] NULL,
	[SAT] [bit] NULL,
	[SUN] [bit] NULL,
	[LAST_ACCRUAL] [datetime] NULL,
	[PRORATETYPE] [varchar](1) NULL,
	[TOTALSTOPS] [int] NULL,
	[STOPS] [int] NULL,
	[EXPIRATION_DATE] [datetime] NULL,
	[AUTO_RENEW] [bit] NULL,
	[CONTRACT_START] [datetime] NULL,
	[AUTO_RENEW_TERMS] [varchar](50) NULL,
	[AVG_WEIGHT] [numeric](18, 5) NULL,
	[TEMPLATE] [bit] NULL,
	[TEMPLATE_NAME] [varchar](250) NULL,
	[FLEX11] [varchar](50) NULL,
	[SERVICE_GROUP] [int] NULL,
	[CONT_INFO] [nvarchar](50) NULL,
	[SurveyRequired] [varchar](1) NULL,
	[CustSigReqd] [varchar](1) NULL,
	[DisplayRates] [varchar](1) NULL,
	[S_PRICE_FLEX1] [int] NULL,
	[S_PRICE_FLEX2] [int] NULL,
	[LastUpdated] [datetime] NULL,
	[FLEX12] [varchar](50) NULL,
	[STOPACCRUALS] [bit] NULL,
	[Market_Price_Area] [int] NULL,
	[Price_Inc_Dec] [numeric](18, 6) NULL,
	[CONTRACT_INFO] [int] NULL,
	[CONTRACT_INITIALTERM] [int] NULL,
	[CONTRACT_TERMINATION] [varchar](20) NULL,
	[CONTRACT_AUTORENEW] [varchar](20) NULL,
	[CONTRACT_AUTORENEWPERIOD] [int] NULL,
	[CONTRACT_FLEX1] [int] NULL,
	[CONTRACT_FLEX2] [int] NULL,
	[CONTRACT_FLEX3] [int] NULL,
	[CONTRACT_FLEX4] [int] NULL,
	[CONTRACT_FLEX5] [int] NULL,
	[CONTRACT_FLEX6] [varchar](50) NULL,
	[CONTRACT_FLEX7] [varchar](50) NULL,
	[CONTRACT_FLEX8] [varchar](50) NULL,
	[CONTRACT_FLEX9] [varchar](50) NULL,
	[CONTRACT_ENVIRONMENTALFEE] [varchar](15) NULL,
	[CONTRACT_FUELFEE] [varchar](15) NULL,
	[CONTRACT_LATEFEE] [varchar](15) NULL,
	[CONTRACT_BASERATEINCREASE] [varchar](15) NULL,
	[CONTRACT_ANCILLARYFEE] [varchar](15) NULL,
	[CONTRACT_RENTALFEE] [varchar](15) NULL,
	[CONTRACT_LOCATIONFEE] [varchar](15) NULL,
	[CONTRACT_PICKUPFEE] [varchar](15) NULL,
	[CONTRACT_FLEX10] [varchar](15) NULL,
	[CONTRACT_FLEX11] [varchar](15) NULL,
	[CONTRACT_FLEX12] [varchar](15) NULL,
	[CONTRACT_FLEX13] [varchar](15) NULL,
	[CONTRACT_ANCILLARYFEENOTE] [varchar](30) NULL,
	[CONTRACT_RENTALFEENOTE] [varchar](30) NULL,
	[CONTRACT_LOCATIONFEENOTE] [varchar](30) NULL,
	[CONTRACT_PICKUPFEENOTE] [varchar](30) NULL,
	[CONTRACT_FLEX10NOTE] [varchar](30) NULL,
	[CONTRACT_FLEX11NOTE] [varchar](30) NULL,
	[CONTRACT_FLEX12NOTE] [varchar](30) NULL,
	[CONTRACT_FLEX13NOTE] [varchar](30) NULL,
	[CONTRACT_ENVIRONMENTALFEEPERCENT] [numeric](18, 6) NULL,
	[CONTRACT_ENVIRONMENTALFEEFLAT] [numeric](18, 6) NULL,
	[CONTRACT_FUELFEEPERCENT] [numeric](18, 6) NULL,
	[CONTRACT_FUELFEEFLAT] [numeric](18, 6) NULL,
	[CONTRACT_LATEFEEPERCENT] [numeric](18, 6) NULL,
	[CONTRACT_LATEFEEFLAT] [numeric](18, 6) NULL,
	[CONTRACT_BASERATEINCREASEPERCENT] [numeric](18, 6) NULL,
	[CONTRACT_BASERATEINCREASEFLAT] [numeric](18, 6) NULL,
	[CONTRACT_ANCILLARYFEEPERCENT] [numeric](18, 6) NULL,
	[CONTRACT_ANCILLARYFEEFLAT] [numeric](18, 6) NULL,
	[CONTRACT_RENTALFEEFLAT] [numeric](18, 6) NULL,
	[CONTRACT_LOCATIONFEEFLAT] [numeric](18, 6) NULL,
	[CONTRACT_PICKUPFEEFLAT] [numeric](18, 6) NULL,
	[CONTRACT_FLEX10PERCENT] [numeric](18, 6) NULL,
	[CONTRACT_FLEX10FLAT] [numeric](18, 6) NULL,
	[CONTRACT_FLEX11PERCENT] [numeric](18, 6) NULL,
	[CONTRACT_FLEX11FLAT] [numeric](18, 6) NULL,
	[CONTRACT_FLEX12PERCENT] [numeric](18, 6) NULL,
	[CONTRACT_FLEX12FLAT] [numeric](18, 6) NULL,
	[CONTRACT_FLEX13PERCENT] [numeric](18, 6) NULL,
	[CONTRACT_FLEX13FLAT] [numeric](18, 6) NULL,
	[CONTRACT_BASERATEINCREASEDATE] [datetime] NULL,
	[CONTRACT_LASTUSER] [varchar](60) NULL,
	[CONTRACT_PAGEPATH] [varchar](255) NULL,
	[DESCRIPT] [varchar](255) NULL,
	[MinimumQty] [int] NULL,
	[QtyBasedOnContQty] [bit] NULL,
	[WasteStream] [int] NULL,
	[LineOfBusiness] [int] NULL,
	[PARENTID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ARAge]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARAge](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[C_ID] [int] NULL,
	[InvoiceDate] [date] NULL,
	[DueDate] [date] NULL,
	[Amount] [numeric](18, 5) NULL,
	[Age] [varchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ARBalances]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARBalances](
	[id] [bigint] NULL,
	[ARAccountCode] [nvarchar](255) NULL,
	[DocumentType] [varchar](1) NOT NULL,
	[DocumentNumber] [varchar](33) NULL,
	[DocumentDate] [date] NULL,
	[DueDate] [date] NULL,
	[NettDocumentValue] [numeric](18, 5) NULL,
	[CompanyOutlet] [nvarchar](255) NULL,
	[C_ID] [int] NOT NULL,
	[C_ID_ALPHA] [varchar](19) NULL,
	[C_CUR_BAL] [numeric](18, 5) NULL,
	[C_UN_BILL] [numeric](18, 5) NULL,
	[C_CUR_DUE] [numeric](18, 5) NULL,
	[C_30D] [numeric](18, 5) NULL,
	[C_60D] [numeric](18, 5) NULL,
	[C_90D] [numeric](18, 5) NULL,
	[C_FIN_CHG] [numeric](18, 5) NULL,
	[B_B_CYCLE] [int] NULL,
	[C_15D] [numeric](18, 5) NULL,
	[C_45D] [numeric](18, 5) NULL,
	[C_120D] [numeric](18, 5) NULL,
	[C_150D] [numeric](18, 5) NULL,
	[C_LST_PAY] [numeric](18, 5) NULL,
	[C_LST_DATE] [datetime] NULL,
	[C_PRV_BAL] [numeric](18, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AutoDetails]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoDetails](
	[ID] [bigint] NULL,
	[c_id] [int] NULL,
	[AUTOID] [int] NOT NULL,
	[SVC_CODE_ALPHA] [varchar](255) NULL,
	[Descript] [varchar](25) NULL,
	[PrimaryService] [nvarchar](255) NULL,
	[Action] [nvarchar](255) NULL,
	[PricingBasis] [nvarchar](255) NULL,
	[RentalPeriod] [nvarchar](50) NULL,
	[RentalTerm] [nvarchar](50) NULL,
	[ServiceCode] [nvarchar](255) NULL,
	[MaterialClass] [nvarchar](255) NULL,
	[UnitOfMeasure] [nvarchar](255) NULL,
	[VAT] [varchar](1) NOT NULL,
	[frequency] [nvarchar](255) NULL,
	[ContainerType] [nvarchar](255) NULL,
	[DMAccount] [varchar](19) NULL,
	[MULTIPLY] [numeric](18, 5) NULL,
	[AMOUNT] [numeric](18, 6) NULL,
	[FREETONS] [numeric](18, 5) NULL,
	[SIZE] [nvarchar](255) NULL,
	[reference] [varchar](14) NULL,
	[CodeMap] [nvarchar](511) NULL,
	[Items] [numeric](18, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillArea]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillArea](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[BillAreaID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillingDates]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillingDates](
	[ID] [bigint] NULL,
	[UNIQUE_ID] [int] NOT NULL,
	[BillCycle] [varchar](255) NULL,
	[Cycle] [varchar](30) NULL,
	[PostedForDate] [date] NULL,
	[PostedDate] [date] NULL,
	[NoOfRecords] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillingGroup]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillingGroup](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[BillingGroup] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[BillingGroupID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillingInfo]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillingInfo](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[B_NAME] [nvarchar](50) NULL,
	[B_NAME2] [nvarchar](50) NULL,
	[B_ADDR1] [nvarchar](130) NULL,
	[B_ADDR2] [nvarchar](130) NULL,
	[B_CITY] [nvarchar](120) NULL,
	[B_STATE] [nvarchar](12) NULL,
	[B_ZIP] [nvarchar](10) NULL,
	[B_PHO] [nvarchar](18) NULL,
	[B_PCONT] [nvarchar](50) NULL,
	[B_FAX] [nvarchar](13) NULL,
	[B_FCONT] [nvarchar](50) NULL,
	[B_EMAIL] [nvarchar](50) NULL,
	[BillKey] [nvarchar](4000) NULL,
	[C_ID] [int] NOT NULL,
	[UniqueReference] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillScreenInfo]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillScreenInfo](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[UdefName] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[BillScreenInfoID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Communications]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Communications](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ARAccountCode] [nvarchar](255) NULL,
	[CommunicationNo] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[Classification] [nvarchar](255) NULL,
	[Method] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Owner] [nvarchar](255) NULL,
	[Date] [date] NULL,
	[ReviewDate] [nvarchar](255) NULL,
	[ContactUniqueId] [nvarchar](255) NULL,
	[Notes] [nvarchar](max) NULL,
	[DMAccount] [nvarchar](255) NULL,
	[Account_id] [bigint] NULL,
	[Child_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContactsPrep]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactsPrep](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ARAccountCode] [nvarchar](255) NULL,
	[Salutation] [nvarchar](255) NULL,
	[Forename] [nvarchar](255) NULL,
	[Surname] [nvarchar](255) NULL,
	[JobTitle] [nvarchar](255) NULL,
	[TelNbr] [nvarchar](255) NULL,
	[TelExtNbr] [nvarchar](255) NULL,
	[MobileNbr] [nvarchar](255) NULL,
	[FaxNbr] [nvarchar](255) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[Notes] [nvarchar](255) NULL,
	[ContactType2] [nvarchar](255) NULL,
	[ContactType3] [nvarchar](255) NULL,
	[TelNo] [nvarchar](255) NULL,
	[FaxNo] [nvarchar](255) NULL,
	[Account_id] [bigint] NULL,
	[Child_id] [bigint] NULL,
	[ContactType_id] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContainerRoute]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContainerRoute](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ContainerRouteID] [int] NOT NULL,
	[SerialNumber] [nvarchar](50) NOT NULL,
	[PlacedDate] [date] NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[Notes] [nvarchar](max) NULL,
	[C_ID] [int] NULL,
	[Company_id] [bigint] NOT NULL,
	[Container_id] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Containers]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Containers](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ContainerID] [int] NOT NULL,
	[Size] [nvarchar](10) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[ContainerType] [nvarchar](50) NOT NULL,
	[Company_id] [bigint] NOT NULL,
	[UnitOfMeasure_id] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContainerUOM]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContainerUOM](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ContainerUOM] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[ContainerUOMID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerRep]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerRep](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Phone] [nvarchar](18) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[CommisionPlan] [int] NOT NULL,
	[CustomerRepID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DelinquencyLevel]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DelinquencyLevel](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[DelinquencyLevelID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FinanceCharge]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinanceCharge](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[FinanceChargeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocationInfo]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocationInfo](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[C_NAME] [nvarchar](50) NULL,
	[C_NAME2] [nvarchar](50) NULL,
	[C_ADDRNUM1] [nvarchar](90) NULL,
	[C_ADDR1] [nvarchar](40) NULL,
	[C_ADDR2] [nvarchar](30) NULL,
	[C_CITY] [nvarchar](20) NULL,
	[C_STATE] [nvarchar](50) NULL,
	[C_ZIP] [nvarchar](10) NULL,
	[C_PHO] [nvarchar](18) NULL,
	[C_PCONT] [nvarchar](50) NULL,
	[C_FAX] [nvarchar](18) NULL,
	[C_FCONT] [nvarchar](50) NULL,
	[C_BILL_TO] [nvarchar](1) NULL,
	[C_SALESREP] [int] NULL,
	[C_EMAIL] [nvarchar](50) NULL,
	[C_ID] [int] NOT NULL,
	[LocKey] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MissingAccounts]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MissingAccounts](
	[C_ID] [int] NOT NULL,
	[C_ID_ALPHA] [varchar](19) NULL,
	[C_NAME] [varchar](50) NULL,
	[C_NAME2] [varchar](50) NULL,
	[C_ADDRNUM1] [varchar](50) NULL,
	[C_ADDR1] [varchar](40) NULL,
	[C_ADDR2] [varchar](40) NULL,
	[C_CITY] [varchar](20) NULL,
	[C_STATE] [varchar](2) NULL,
	[C_ZIP] [varchar](10) NULL,
	[C_PHO] [varchar](18) NULL,
	[C_PCONT] [varchar](50) NULL,
	[C_FAX] [varchar](18) NULL,
	[C_FCONT] [varchar](50) NULL,
	[C_CSTAT] [int] NULL,
	[C_SALESREP] [int] NULL,
	[C_QUOTE] [datetime] NULL,
	[C_TYPE] [varchar](1) NULL,
	[C_RTES] [varchar](1) NULL,
	[C_NRTES] [int] NULL,
	[C_LOCS] [varchar](1) NULL,
	[C_NLOCS] [int] NULL,
	[C_SUFFIX] [int] NULL,
	[ISCHILD] [bit] NOT NULL,
	[C_BILL_TO] [varchar](1) NULL,
	[C_COMMENTS] [varchar](240) NULL,
	[C_MEMO] [varchar](50) NULL,
	[C_LST_PAY] [numeric](18, 5) NULL,
	[C_LST_DATE] [datetime] NULL,
	[C_PRV_BAL] [numeric](18, 5) NULL,
	[C_CUR_BAL] [numeric](18, 5) NULL,
	[C_UN_BILL] [numeric](18, 5) NULL,
	[C_CUR_DUE] [numeric](18, 5) NULL,
	[C_30D] [numeric](18, 5) NULL,
	[C_60D] [numeric](18, 5) NULL,
	[C_90D] [numeric](18, 5) NULL,
	[C_FIN_CHG] [numeric](18, 5) NULL,
	[C_DELNQLVL] [int] NULL,
	[B_NAME] [varchar](50) NULL,
	[B_NAME2] [varchar](50) NULL,
	[B_ADDR1] [varchar](40) NULL,
	[B_ADDR2] [varchar](40) NULL,
	[B_CITY] [varchar](20) NULL,
	[B_STATE] [varchar](2) NULL,
	[B_ZIP] [varchar](10) NULL,
	[B_PHO] [varchar](18) NULL,
	[B_PCONT] [varchar](50) NULL,
	[B_FAX] [varchar](13) NULL,
	[B_FCONT] [varchar](50) NULL,
	[B_B_CYCLE] [int] NULL,
	[B_TAXABLE] [bit] NOT NULL,
	[B_ACCTTYPE] [varchar](15) NULL,
	[B_FIN_DESC] [int] NULL,
	[B_DELINQ] [int] NULL,
	[B_STMT_TYP] [int] NULL,
	[B_BILL_TYP] [int] NULL,
	[B_BILL_CO] [int] NULL,
	[B_PO_NUM] [varchar](25) NULL,
	[B_SUSPENDS] [datetime] NULL,
	[B_SUSPENDE] [datetime] NULL,
	[B_STRT_DAT] [datetime] NULL,
	[B_STOP_DAT] [datetime] NULL,
	[B_STRT_STA] [varchar](5) NULL,
	[B_STOP_STA] [varchar](5) NULL,
	[B_STRT_COD] [varchar](5) NULL,
	[B_STOP_COD] [varchar](5) NULL,
	[B_STRT_AMT] [numeric](18, 5) NULL,
	[B_STOP_AMT] [numeric](18, 5) NULL,
	[B_CONTRACT] [int] NULL,
	[B_CONTAINS] [int] NULL,
	[B_GRID] [varchar](30) NULL,
	[B_AREA] [int] NULL,
	[B_TAXAREA] [int] NULL,
	[B_PAGE] [int] NULL,
	[C_ENDDATE] [datetime] NULL,
	[B_PAYBYCC] [bit] NOT NULL,
	[C_UNAPPLIED] [numeric](18, 5) NULL,
	[B_CONTRACT_NUM] [varchar](30) NULL,
	[B_CONTRACT_DATE] [datetime] NULL,
	[C_15D] [numeric](18, 5) NULL,
	[C_45D] [numeric](18, 5) NULL,
	[REFERRAL] [varchar](80) NULL,
	[SREP1] [int] NULL,
	[SREP2] [int] NULL,
	[CREP1] [int] NULL,
	[CREP2] [int] NULL,
	[B_NAME_2ND] [varchar](50) NULL,
	[B_NAME_2ND2] [varchar](50) NULL,
	[B_ADDR1_2ND] [varchar](50) NULL,
	[B_ADDR1_2ND2] [varchar](50) NULL,
	[B_CITY_2ND] [varchar](50) NULL,
	[B_STATE_2ND] [varchar](20) NULL,
	[B_ZIP_2ND] [varchar](20) NULL,
	[C_DEPOSIT] [numeric](18, 5) NULL,
	[CREP1_NOTES] [varchar](80) NULL,
	[CREP2_NOTES] [varchar](80) NULL,
	[SREP1_NOTES] [varchar](80) NULL,
	[SREP2_NOTES] [varchar](80) NULL,
	[C_TYPE2] [bit] NULL,
	[C_TYPE3] [bit] NULL,
	[B_MTD] [float] NULL,
	[B_YTD] [float] NULL,
	[B_LMTD] [float] NULL,
	[B_LYTD] [float] NULL,
	[B_TERMS] [int] NULL,
	[REFERRAL2] [int] NULL,
	[KFACTOR] [decimal](10, 3) NULL,
	[GAL_DEGREE_DAY] [float] NULL,
	[LCK_GAL_DEGREE_DAY] [bit] NULL,
	[GAL_DAY] [float] NULL,
	[LCK_GAL_DAY] [bit] NULL,
	[C_120D] [numeric](18, 5) NULL,
	[C_150D] [numeric](18, 5) NULL,
	[B_BILL_INFO1] [int] NULL,
	[B_BILL_INFO2] [int] NULL,
	[B_BILL_INFO3] [int] NULL,
	[B_BILL_INFO4] [int] NULL,
	[T_ID] [int] NULL,
	[C_EMAIL] [varchar](50) NULL,
	[B_EMAIL] [varchar](50) NULL,
	[OUTPUT] [int] NULL,
	[B_SURCHARGE] [int] NULL,
	[SITEFILE] [varchar](255) NULL,
	[QUOTE_SHEET] [varchar](255) NULL,
	[C_TYPE4] [varchar](1) NULL,
	[C_TYPE5] [varchar](1) NULL,
	[C_TYPE6] [varchar](1) NULL,
	[C_TYPE7] [varchar](1) NULL,
	[C_TYPE8] [varchar](1) NULL,
	[C_TYPE9] [varchar](1) NULL,
	[C_LOCS2] [varchar](1) NULL,
	[C_NLOCS2] [int] NULL,
	[C_SUFFIX2] [int] NULL,
	[ISCHILD2] [bit] NULL,
	[C_LOCS3] [varchar](1) NULL,
	[C_NLOCS3] [int] NULL,
	[C_SUFFIX3] [int] NULL,
	[ISCHILD3] [bit] NULL,
	[TOTAL_TONS] [numeric](18, 5) NULL,
	[GUARANTEED_PRICE] [bit] NULL,
	[C_CURRENCY] [varchar](5) NULL,
	[REGION] [varchar](50) NULL,
	[DISTRICT] [varchar](50) NULL,
	[PROFILE_AREA] [varchar](50) NULL,
	[CLIENT_ID] [varchar](50) NULL,
	[BUSINESS_UNIT] [varchar](50) NULL,
	[LOCATION_TYPE] [varchar](50) NULL,
	[RANK_CLASS] [varchar](50) NULL,
	[DIVISION] [varchar](50) NULL,
	[CLIENT_SHARED_PERCENTAGE] [int] NULL,
	[SURCHARGE_BENCHMARK] [numeric](18, 5) NULL,
	[LOCATION_ID] [varchar](50) NULL,
	[NATIONAL_ACCT] [bit] NULL,
	[V_STORENO] [varchar](30) NULL,
	[PARENT_C_ID] [int] NULL,
	[AUTHORIZEDPAYEE] [varchar](50) NULL,
	[REBATEPAY] [int] NULL,
	[LastUpdated] [datetime] NULL,
	[B_QB_PATH] [varchar](255) NULL,
	[ContactViaPhone] [int] NULL,
	[Tax_Exempt_ID] [varchar](50) NULL,
	[Flex_Date] [datetime] NULL,
	[AutoEmailCustomerReceipt] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NextBillingDate]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NextBillingDate](
	[UNIQUE_ID] [int] NOT NULL,
	[BillCycle] [varchar](255) NULL,
	[Cycle] [varchar](30) NULL,
	[PostedForDate] [date] NULL,
	[PostedDate] [date] NULL,
	[NextBillingDate] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Route]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Route](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[RouteID] [int] NULL,
	[RouteNo] [nvarchar](255) NOT NULL,
	[RouteDescription] [nvarchar](255) NOT NULL,
	[Notes] [nvarchar](255) NOT NULL,
	[VehicleType] [nvarchar](255) NOT NULL,
	[SingleDayRoute] [bit] NOT NULL,
	[Mon] [bit] NOT NULL,
	[Tue] [bit] NOT NULL,
	[Wed] [bit] NOT NULL,
	[Thu] [bit] NOT NULL,
	[Fri] [bit] NOT NULL,
	[Sat] [bit] NOT NULL,
	[Sun] [bit] NOT NULL,
	[Company_id] [bigint] NULL,
	[RouteType_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RouteDays]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RouteDays](
	[mon] [int] NULL,
	[tue] [int] NULL,
	[wed] [int] NULL,
	[thu] [int] NULL,
	[fri] [int] NULL,
	[sat] [int] NULL,
	[sun] [int] NULL,
	[DayValue] [int] NULL,
	[WhichDay] [varchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RouteFrequency]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RouteFrequency](
	[Key] [varchar](10) NULL,
	[Value] [varchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RouteStops]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RouteStops](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[C_ID] [int] NULL,
	[StopID] [int] NOT NULL,
	[Stop] [int] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[StopFrequency] [nvarchar](255) NOT NULL,
	[NextDate] [date] NULL,
	[rxFreq] [nvarchar](255) NULL,
	[Account_id] [bigint] NULL,
	[Child_id] [bigint] NULL,
	[Route_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RouteType]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RouteType](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[RouteTypeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RTESMigration]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RTESMigration](
	[ROUTEID] [int] NOT NULL,
	[DESCRIPT] [varchar](60) NULL,
	[ROUTENUM] [nvarchar](10) NULL,
	[MON] [bit] NOT NULL,
	[TUE] [bit] NOT NULL,
	[WED] [bit] NOT NULL,
	[THU] [bit] NOT NULL,
	[FRI] [bit] NOT NULL,
	[SAT] [bit] NOT NULL,
	[SUN] [bit] NOT NULL,
	[TYPE] [int] NULL,
	[DRIVER] [int] NULL,
	[TRUCK] [nvarchar](5) NULL,
	[COMMENT] [varchar](50) NULL,
	[CMPY_ID] [int] NULL,
	[CAPACITY] [int] NULL,
	[MASTER_ROUTE] [bit] NOT NULL,
	[BUDGET_HRS] [numeric](18, 6) NULL,
	[GeoCodeLastChanged] [datetime] NULL,
	[DISP_ID] [int] NULL,
	[NewRouteid] [int] NOT NULL,
	[NewRouteNum] [varchar](60) NULL,
	[Stops] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServiceCategory]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceCategory](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ServiceCategory] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[ServiceCategoryID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServiceCodeTaxAreas]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceCodeTaxAreas](
	[SVC_CODE] [int] NOT NULL,
	[UNIQUE_ID] [int] NOT NULL,
	[VAT] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServiceCodeUnitOfMeasure]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceCodeUnitOfMeasure](
	[ServiceCode] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](250) NULL,
	[ServiceCategory] [varchar](255) NULL,
	[UnitOfMeasure] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServiceMapping]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceMapping](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ExampleAccount] [nvarchar](255) NULL,
	[NumOfOccurences] [int] NULL,
	[ServiceCode] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](255) NULL,
	[Size] [nvarchar](255) NULL,
	[ContainerType] [nvarchar](255) NULL,
	[BillingCycle] [nvarchar](255) NULL,
	[Cycle] [nvarchar](255) NULL,
	[ServiceCategory] [nvarchar](255) NULL,
	[Frequency] [nvarchar](255) NULL,
	[PrimaryService] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StatementType]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StatementType](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[StatementTypeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SurchargeArea]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SurchargeArea](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[SurchargeAreaID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxableCodes]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxableCodes](
	[SVC_CODE] [int] NOT NULL,
	[TAXAREA] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxArea]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxArea](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[TaxAreaID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TempAssignments]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempAssignments](
	[SOAssignmentId] [bigint] NULL,
	[SiteOrderUniqueRef] [bigint] NOT NULL,
	[Action] [varchar](7) NOT NULL,
	[DayOfWeek] [int] NULL,
	[RouteTemplate] [varchar](7) NOT NULL,
	[Position] [varchar](7) NULL,
	[PickUpInterval] [varchar](3) NOT NULL,
	[ContainerType] [nvarchar](60) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[RoutedOrScheduled] [varchar](6) NOT NULL,
	[MinLiftQuantity] [varchar](1) NOT NULL,
	[RequiresQuantity] [varchar](1) NOT NULL,
	[NextDueDate] [varchar](1) NOT NULL,
	[Notes] [varchar](1000) NULL,
	[SJVehicle] [varchar](1) NOT NULL,
	[SJDriver] [varchar](1) NOT NULL,
	[DMAccount] [nvarchar](30) NOT NULL,
	[STOPID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tempContactLocations]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempContactLocations](
	[ARAccountCode] [nvarchar](255) NULL,
	[UniqRef] [nvarchar](200) NULL,
	[contactuniqueid] [bigint] NOT NULL,
	[accountid] [bigint] NULL,
	[childid] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Terms]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Terms](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[TermsID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UnitOfMeasure]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnitOfMeasure](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[UnitOfMeasure] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[UnitOfMeasureID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xBillCycles]    Script Date: 6/15/2025 4:52:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xBillCycles](
	[System_Val] [varchar](4) NULL,
	[Cycle] [varchar](30) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_BillArea_id_80c070c7_fk_BillArea_id] FOREIGN KEY([BillArea_id])
REFERENCES [dbo].[BillArea] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_BillArea_id_80c070c7_fk_BillArea_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_BillingCycle_id_b3867e62_fk_BillingCycle_id] FOREIGN KEY([BillingCycle_id])
REFERENCES [dbo].[BillingCycle] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_BillingCycle_id_b3867e62_fk_BillingCycle_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_BillingGroup_id_2655ae6d_fk_BillingGroup_id] FOREIGN KEY([BillingGroup_id])
REFERENCES [dbo].[BillingGroup] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_BillingGroup_id_2655ae6d_fk_BillingGroup_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_BillingInfo_id_4d03730a_fk_BillingInfo_id] FOREIGN KEY([BillingInfo_id])
REFERENCES [dbo].[BillingInfo] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_BillingInfo_id_4d03730a_fk_BillingInfo_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_BillingInfo1_id_08671fda_fk_BillScreenInfo_id] FOREIGN KEY([BillingInfo1_id])
REFERENCES [dbo].[BillScreenInfo] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_BillingInfo1_id_08671fda_fk_BillScreenInfo_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_BillingInfo2_id_975fb6d8_fk_BillScreenInfo_id] FOREIGN KEY([BillingInfo2_id])
REFERENCES [dbo].[BillScreenInfo] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_BillingInfo2_id_975fb6d8_fk_BillScreenInfo_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_BillingInfo3_id_7c1709fc_fk_BillScreenInfo_id] FOREIGN KEY([BillingInfo3_id])
REFERENCES [dbo].[BillScreenInfo] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_BillingInfo3_id_7c1709fc_fk_BillScreenInfo_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_BillingInfo4_id_567f7c33_fk_BillScreenInfo_id] FOREIGN KEY([BillingInfo4_id])
REFERENCES [dbo].[BillScreenInfo] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_BillingInfo4_id_567f7c33_fk_BillScreenInfo_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_Company_id_70b50e46_fk_Company_id] FOREIGN KEY([Company_id])
REFERENCES [dbo].[Company] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_Company_id_70b50e46_fk_Company_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_CREP1_id_536628e1_fk_CustomerRep_id] FOREIGN KEY([CREP1_id])
REFERENCES [dbo].[CustomerRep] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_CREP1_id_536628e1_fk_CustomerRep_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_CREP2_id_790fb9e7_fk_CustomerRep_id] FOREIGN KEY([CREP2_id])
REFERENCES [dbo].[CustomerRep] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_CREP2_id_790fb9e7_fk_CustomerRep_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_DelinquencyLevel_id_4e33f7aa_fk_DelinquencyLevel_id] FOREIGN KEY([DelinquencyLevel_id])
REFERENCES [dbo].[DelinquencyLevel] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_DelinquencyLevel_id_4e33f7aa_fk_DelinquencyLevel_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_FinanceCharge_id_e97a119f_fk_FinanceCharge_id] FOREIGN KEY([FinanceCharge_id])
REFERENCES [dbo].[FinanceCharge] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_FinanceCharge_id_e97a119f_fk_FinanceCharge_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_LocationInfo_id_17bcfbb7_fk_LocationInfo_id] FOREIGN KEY([LocationInfo_id])
REFERENCES [dbo].[LocationInfo] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_LocationInfo_id_17bcfbb7_fk_LocationInfo_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_MasterAccount_id_07116aaf_fk_MasterAccount_id] FOREIGN KEY([MasterAccount_id])
REFERENCES [dbo].[MasterAccount] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_MasterAccount_id_07116aaf_fk_MasterAccount_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_SREP1_id_d94c51ba_fk_CustomerRep_id] FOREIGN KEY([SREP1_id])
REFERENCES [dbo].[CustomerRep] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_SREP1_id_d94c51ba_fk_CustomerRep_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_SREP2_id_bf3d8011_fk_CustomerRep_id] FOREIGN KEY([SREP2_id])
REFERENCES [dbo].[CustomerRep] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_SREP2_id_bf3d8011_fk_CustomerRep_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_StatementType_id_d6f12c40_fk_StatementType_id] FOREIGN KEY([StatementType_id])
REFERENCES [dbo].[StatementType] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_StatementType_id_d6f12c40_fk_StatementType_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_status_id_79a7f451_fk_Status_id] FOREIGN KEY([status_id])
REFERENCES [dbo].[Status] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_status_id_79a7f451_fk_Status_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_TaxArea_id_fac09083_fk_TaxArea_id] FOREIGN KEY([TaxArea_id])
REFERENCES [dbo].[TaxArea] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_TaxArea_id_fac09083_fk_TaxArea_id]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [Account_Terms_id_c0e79d50_fk_Terms_id] FOREIGN KEY([Terms_id])
REFERENCES [dbo].[Terms] ([id])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [Account_Terms_id_c0e79d50_fk_Terms_id]
GO
ALTER TABLE [dbo].[AgedDebtorsData]  WITH CHECK ADD  CONSTRAINT [AgedDebtorsData_Account_id_e2e0153e_fk_Account_id] FOREIGN KEY([Account_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[AgedDebtorsData] CHECK CONSTRAINT [AgedDebtorsData_Account_id_e2e0153e_fk_Account_id]
GO
ALTER TABLE [dbo].[AgedDebtorsData]  WITH CHECK ADD  CONSTRAINT [AgedDebtorsData_Child_id_dcd3b96e_fk_Child_id] FOREIGN KEY([Child_id])
REFERENCES [dbo].[Child] ([id])
GO
ALTER TABLE [dbo].[AgedDebtorsData] CHECK CONSTRAINT [AgedDebtorsData_Child_id_dcd3b96e_fk_Child_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_BillArea_id_09236d75_fk_BillArea_id] FOREIGN KEY([BillArea_id])
REFERENCES [dbo].[BillArea] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_BillArea_id_09236d75_fk_BillArea_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_BillingCycle_id_39f095ed_fk_BillingCycle_id] FOREIGN KEY([BillingCycle_id])
REFERENCES [dbo].[BillingCycle] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_BillingCycle_id_39f095ed_fk_BillingCycle_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_BillingGroup_id_9b4e1b0e_fk_BillingGroup_id] FOREIGN KEY([BillingGroup_id])
REFERENCES [dbo].[BillingGroup] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_BillingGroup_id_9b4e1b0e_fk_BillingGroup_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_BillingInfo_id_f84d593d_fk_BillingInfo_id] FOREIGN KEY([BillingInfo_id])
REFERENCES [dbo].[BillingInfo] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_BillingInfo_id_f84d593d_fk_BillingInfo_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_BillingInfo1_id_6d63cbfc_fk_BillScreenInfo_id] FOREIGN KEY([BillingInfo1_id])
REFERENCES [dbo].[BillScreenInfo] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_BillingInfo1_id_6d63cbfc_fk_BillScreenInfo_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_BillingInfo2_id_360072a8_fk_BillScreenInfo_id] FOREIGN KEY([BillingInfo2_id])
REFERENCES [dbo].[BillScreenInfo] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_BillingInfo2_id_360072a8_fk_BillScreenInfo_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_BillingInfo3_id_981333f8_fk_BillScreenInfo_id] FOREIGN KEY([BillingInfo3_id])
REFERENCES [dbo].[BillScreenInfo] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_BillingInfo3_id_981333f8_fk_BillScreenInfo_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_BillingInfo4_id_b844a5a4_fk_BillScreenInfo_id] FOREIGN KEY([BillingInfo4_id])
REFERENCES [dbo].[BillScreenInfo] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_BillingInfo4_id_b844a5a4_fk_BillScreenInfo_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_Company_id_7d5b3bf4_fk_Company_id] FOREIGN KEY([Company_id])
REFERENCES [dbo].[Company] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_Company_id_7d5b3bf4_fk_Company_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_CREP1_id_2b0cc0b2_fk_CustomerRep_id] FOREIGN KEY([CREP1_id])
REFERENCES [dbo].[CustomerRep] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_CREP1_id_2b0cc0b2_fk_CustomerRep_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_CREP2_id_dfc24ce4_fk_CustomerRep_id] FOREIGN KEY([CREP2_id])
REFERENCES [dbo].[CustomerRep] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_CREP2_id_dfc24ce4_fk_CustomerRep_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_DelinquencyLevel_id_b3a8111b_fk_DelinquencyLevel_id] FOREIGN KEY([DelinquencyLevel_id])
REFERENCES [dbo].[DelinquencyLevel] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_DelinquencyLevel_id_b3a8111b_fk_DelinquencyLevel_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_FinanceCharge_id_a5d9f94a_fk_FinanceCharge_id] FOREIGN KEY([FinanceCharge_id])
REFERENCES [dbo].[FinanceCharge] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_FinanceCharge_id_a5d9f94a_fk_FinanceCharge_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_LocationInfo_id_52ae2d62_fk_LocationInfo_id] FOREIGN KEY([LocationInfo_id])
REFERENCES [dbo].[LocationInfo] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_LocationInfo_id_52ae2d62_fk_LocationInfo_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_MasterAccount_id_584335ff_fk_MasterAccount_id] FOREIGN KEY([MasterAccount_id])
REFERENCES [dbo].[MasterAccount] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_MasterAccount_id_584335ff_fk_MasterAccount_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_Parent_id_b95b4084_fk_Account_id] FOREIGN KEY([Parent_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_Parent_id_b95b4084_fk_Account_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_SREP1_id_82b0f003_fk_CustomerRep_id] FOREIGN KEY([SREP1_id])
REFERENCES [dbo].[CustomerRep] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_SREP1_id_82b0f003_fk_CustomerRep_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_SREP2_id_5e285cd0_fk_CustomerRep_id] FOREIGN KEY([SREP2_id])
REFERENCES [dbo].[CustomerRep] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_SREP2_id_5e285cd0_fk_CustomerRep_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_StatementType_id_de46208b_fk_StatementType_id] FOREIGN KEY([StatementType_id])
REFERENCES [dbo].[StatementType] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_StatementType_id_de46208b_fk_StatementType_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_status_id_e25982dd_fk_Status_id] FOREIGN KEY([status_id])
REFERENCES [dbo].[Status] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_status_id_e25982dd_fk_Status_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_TaxArea_id_50b06479_fk_TaxArea_id] FOREIGN KEY([TaxArea_id])
REFERENCES [dbo].[TaxArea] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_TaxArea_id_50b06479_fk_TaxArea_id]
GO
ALTER TABLE [dbo].[Child]  WITH CHECK ADD  CONSTRAINT [Child_Terms_id_71b3df88_fk_Terms_id] FOREIGN KEY([Terms_id])
REFERENCES [dbo].[Terms] ([id])
GO
ALTER TABLE [dbo].[Child] CHECK CONSTRAINT [Child_Terms_id_71b3df88_fk_Terms_id]
GO
ALTER TABLE [dbo].[Communications]  WITH CHECK ADD  CONSTRAINT [Communications_Account_id_c75ef796_fk_Account_id] FOREIGN KEY([Account_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[Communications] CHECK CONSTRAINT [Communications_Account_id_c75ef796_fk_Account_id]
GO
ALTER TABLE [dbo].[Communications]  WITH CHECK ADD  CONSTRAINT [Communications_Child_id_e9acc64b_fk_Child_id] FOREIGN KEY([Child_id])
REFERENCES [dbo].[Child] ([id])
GO
ALTER TABLE [dbo].[Communications] CHECK CONSTRAINT [Communications_Child_id_e9acc64b_fk_Child_id]
GO
ALTER TABLE [dbo].[ContactLocations]  WITH CHECK ADD  CONSTRAINT [ContactLocations_Account_id_c144b5fd_fk_Account_id] FOREIGN KEY([Account_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[ContactLocations] CHECK CONSTRAINT [ContactLocations_Account_id_c144b5fd_fk_Account_id]
GO
ALTER TABLE [dbo].[ContactLocations]  WITH CHECK ADD  CONSTRAINT [ContactLocations_Child_id_4f44c26a_fk_Child_id] FOREIGN KEY([Child_id])
REFERENCES [dbo].[Child] ([id])
GO
ALTER TABLE [dbo].[ContactLocations] CHECK CONSTRAINT [ContactLocations_Child_id_4f44c26a_fk_Child_id]
GO
ALTER TABLE [dbo].[ContactLocations]  WITH CHECK ADD  CONSTRAINT [ContactLocations_ContactUniqueId_id_4467ed72_fk_Contacts_id] FOREIGN KEY([ContactUniqueId_id])
REFERENCES [dbo].[Contacts] ([id])
GO
ALTER TABLE [dbo].[ContactLocations] CHECK CONSTRAINT [ContactLocations_ContactUniqueId_id_4467ed72_fk_Contacts_id]
GO
ALTER TABLE [dbo].[Contacts]  WITH CHECK ADD  CONSTRAINT [Contacts_Account_id_0176a3ff_fk_Account_id] FOREIGN KEY([Account_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[Contacts] CHECK CONSTRAINT [Contacts_Account_id_0176a3ff_fk_Account_id]
GO
ALTER TABLE [dbo].[Contacts]  WITH CHECK ADD  CONSTRAINT [Contacts_Child_id_45641d81_fk_Child_id] FOREIGN KEY([Child_id])
REFERENCES [dbo].[Child] ([id])
GO
ALTER TABLE [dbo].[Contacts] CHECK CONSTRAINT [Contacts_Child_id_45641d81_fk_Child_id]
GO
ALTER TABLE [dbo].[Contacts]  WITH CHECK ADD  CONSTRAINT [Contacts_ContactType_id_594d9e14_fk_ContactType_id] FOREIGN KEY([ContactType_id])
REFERENCES [dbo].[ContactType] ([id])
GO
ALTER TABLE [dbo].[Contacts] CHECK CONSTRAINT [Contacts_ContactType_id_594d9e14_fk_ContactType_id]
GO
ALTER TABLE [dbo].[ContainerRoute]  WITH CHECK ADD  CONSTRAINT [ContainerRoute_Company_id_4ab61dcb_fk_Company_id] FOREIGN KEY([Company_id])
REFERENCES [dbo].[Company] ([id])
GO
ALTER TABLE [dbo].[ContainerRoute] CHECK CONSTRAINT [ContainerRoute_Company_id_4ab61dcb_fk_Company_id]
GO
ALTER TABLE [dbo].[ContainerRoute]  WITH CHECK ADD  CONSTRAINT [ContainerRoute_Container_id_174e7365_fk_Containers_id] FOREIGN KEY([Container_id])
REFERENCES [dbo].[Containers] ([id])
GO
ALTER TABLE [dbo].[ContainerRoute] CHECK CONSTRAINT [ContainerRoute_Container_id_174e7365_fk_Containers_id]
GO
ALTER TABLE [dbo].[Containers]  WITH CHECK ADD  CONSTRAINT [Containers_Company_id_0a51106b_fk_Company_id] FOREIGN KEY([Company_id])
REFERENCES [dbo].[Company] ([id])
GO
ALTER TABLE [dbo].[Containers] CHECK CONSTRAINT [Containers_Company_id_0a51106b_fk_Company_id]
GO
ALTER TABLE [dbo].[Containers]  WITH CHECK ADD  CONSTRAINT [Containers_UnitOfMeasure_id_7ec1673c_fk_ContainerUOM_id] FOREIGN KEY([UnitOfMeasure_id])
REFERENCES [dbo].[ContainerUOM] ([id])
GO
ALTER TABLE [dbo].[Containers] CHECK CONSTRAINT [Containers_UnitOfMeasure_id_7ec1673c_fk_ContainerUOM_id]
GO
ALTER TABLE [dbo].[CustomerLocations]  WITH CHECK ADD  CONSTRAINT [CustomerLocations_Account_id_f5987f4f_fk_Account_id] FOREIGN KEY([Account_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[CustomerLocations] CHECK CONSTRAINT [CustomerLocations_Account_id_f5987f4f_fk_Account_id]
GO
ALTER TABLE [dbo].[CustomerLocations]  WITH CHECK ADD  CONSTRAINT [CustomerLocations_Child_id_c33df04f_fk_Child_id] FOREIGN KEY([Child_id])
REFERENCES [dbo].[Child] ([id])
GO
ALTER TABLE [dbo].[CustomerLocations] CHECK CONSTRAINT [CustomerLocations_Child_id_c33df04f_fk_Child_id]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [Customers_Account_id_4f814522_fk_Account_id] FOREIGN KEY([Account_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [Customers_Account_id_4f814522_fk_Account_id]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [Customers_Child_id_fa277ef8_fk_Child_id] FOREIGN KEY([Child_id])
REFERENCES [dbo].[Child] ([id])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [Customers_Child_id_fa277ef8_fk_Child_id]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [Customers_Parent_id_29d78457_fk_Account_id] FOREIGN KEY([Parent_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [Customers_Parent_id_29d78457_fk_Account_id]
GO
ALTER TABLE [dbo].[CustomerServiceAgreementHeader]  WITH CHECK ADD  CONSTRAINT [CustomerServiceAgreementHeader_Customer_id_f6618fed_fk_Customers_id] FOREIGN KEY([Customer_id])
REFERENCES [dbo].[Customers] ([id])
GO
ALTER TABLE [dbo].[CustomerServiceAgreementHeader] CHECK CONSTRAINT [CustomerServiceAgreementHeader_Customer_id_f6618fed_fk_Customers_id]
GO
ALTER TABLE [dbo].[CustomerServiceAgreementPrices]  WITH CHECK ADD  CONSTRAINT [CustomerServiceAgreementPrices_Customer_id_5e84d988_fk_Customers_id] FOREIGN KEY([Customer_id])
REFERENCES [dbo].[Customers] ([id])
GO
ALTER TABLE [dbo].[CustomerServiceAgreementPrices] CHECK CONSTRAINT [CustomerServiceAgreementPrices_Customer_id_5e84d988_fk_Customers_id]
GO
ALTER TABLE [dbo].[MasterAccount]  WITH CHECK ADD  CONSTRAINT [MasterAccount_Status_id_f33c853d_fk_Status_id] FOREIGN KEY([Status_id])
REFERENCES [dbo].[Status] ([id])
GO
ALTER TABLE [dbo].[MasterAccount] CHECK CONSTRAINT [MasterAccount_Status_id_f33c853d_fk_Status_id]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [Route_Company_id_e6564ab6_fk_Company_id] FOREIGN KEY([Company_id])
REFERENCES [dbo].[Company] ([id])
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [Route_Company_id_e6564ab6_fk_Company_id]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [Route_RouteType_id_ee790134_fk_RouteType_id] FOREIGN KEY([RouteType_id])
REFERENCES [dbo].[RouteType] ([id])
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [Route_RouteType_id_ee790134_fk_RouteType_id]
GO
ALTER TABLE [dbo].[RouteStops]  WITH CHECK ADD  CONSTRAINT [RouteStops_Account_id_b3f3ef4f_fk_Account_id] FOREIGN KEY([Account_id])
REFERENCES [dbo].[Account] ([id])
GO
ALTER TABLE [dbo].[RouteStops] CHECK CONSTRAINT [RouteStops_Account_id_b3f3ef4f_fk_Account_id]
GO
ALTER TABLE [dbo].[RouteStops]  WITH CHECK ADD  CONSTRAINT [RouteStops_Child_id_07d65652_fk_Child_id] FOREIGN KEY([Child_id])
REFERENCES [dbo].[Child] ([id])
GO
ALTER TABLE [dbo].[RouteStops] CHECK CONSTRAINT [RouteStops_Child_id_07d65652_fk_Child_id]
GO
ALTER TABLE [dbo].[RouteStops]  WITH CHECK ADD  CONSTRAINT [RouteStops_Route_id_b87aa4ce_fk_Route_id] FOREIGN KEY([Route_id])
REFERENCES [dbo].[Route] ([id])
GO
ALTER TABLE [dbo].[RouteStops] CHECK CONSTRAINT [RouteStops_Route_id_b87aa4ce_fk_Route_id]
GO
ALTER TABLE [dbo].[Routing]  WITH CHECK ADD  CONSTRAINT [Routing_Company_id_9121913e_fk_Company_id] FOREIGN KEY([Company_id])
REFERENCES [dbo].[Company] ([id])
GO
ALTER TABLE [dbo].[Routing] CHECK CONSTRAINT [Routing_Company_id_9121913e_fk_Company_id]
GO
ALTER TABLE [dbo].[Routing]  WITH CHECK ADD  CONSTRAINT [Routing_RouteType_id_59d2e0e6_fk_RouteType_id] FOREIGN KEY([RouteType_id])
REFERENCES [dbo].[RouteType] ([id])
GO
ALTER TABLE [dbo].[Routing] CHECK CONSTRAINT [Routing_RouteType_id_59d2e0e6_fk_RouteType_id]
GO
ALTER TABLE [dbo].[SiteOrderHeader]  WITH CHECK ADD  CONSTRAINT [SiteOrderHeader_CompanyOutlet_id_90259a82_fk_Company_id] FOREIGN KEY([CompanyOutlet_id])
REFERENCES [dbo].[Company] ([id])
GO
ALTER TABLE [dbo].[SiteOrderHeader] CHECK CONSTRAINT [SiteOrderHeader_CompanyOutlet_id_90259a82_fk_Company_id]
GO
ALTER TABLE [dbo].[SiteOrderRental]  WITH CHECK ADD  CONSTRAINT [SiteOrderRental_Customer_id_117cbc01_fk_Customers_id] FOREIGN KEY([Customer_id])
REFERENCES [dbo].[Customers] ([id])
GO
ALTER TABLE [dbo].[SiteOrderRental] CHECK CONSTRAINT [SiteOrderRental_Customer_id_117cbc01_fk_Customers_id]
GO
USE [master]
GO
ALTER DATABASE [ModMigration] SET  READ_WRITE 
GO
