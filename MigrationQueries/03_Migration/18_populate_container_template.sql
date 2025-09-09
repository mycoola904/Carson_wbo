use ModMigration
	drop table if exists containerTemplate
	
	create table containerTemplate (
	[CCID] int,
	c_id int,
	c_id_alpha varchar(50),
	[ContainerSerialNo] varchar(255), 
	[CompanyOutlet] varchar(255), 
	[ContainerType] varchar(255), 
	[DateOfDelivery] date, 
	[TagReference] varchar(255), 
	[Notes] varchar(255), 
	[AgreeNbr] varchar(255), 
	[Commercial] varchar(255), 
	[BinOnSiteNumber] varchar(255),
	SiteOrderUniqueRef int
	);
	

	insert into containerTemplate (c_id_alpha, c_id, [ContainerSerialNo], [CompanyOutlet], [ContainerType], [DateOfDelivery],
	[TagReference], [Notes],  [Commercial], [BinOnSiteNumber], SiteOrderUniqueRef)
	select  cu.c_id_alpha, cr.c_id
	,isnull(cr.SerialNumber, '')  SerialNumber
	, cv.Company
	, cv.ContainerType
	, cr.Placed_Date
	, '' TagReference
	, cr.Notes
	, '' Commercial
	, '1' [BinOnSiteNumber]
	, soh.id SiteOrderUniqueRef
	--select count(1)
	-- select *  --from Container_View
	from conversiondata.dbo.ContainerRoute cr
	inner join ConversionData.dbo.cust cu on cu.c_id = cr.C_ID
	--inner join DMContainers cs on cs.ContainerID = cr.ContainerID
	inner join Container_View cv on cv.ContainerID = cr.ContainerID
	--where C_ID_ALPHA = '100018'
	inner join SiteOrderHeader soh on soh.DMAccount = cu.C_ID_ALPHA