/* EDITED FOR GAUTHIER TO INCLUDE ONLY THOSE WITH A CALL DATE AFTER 2023-01-01' */

use ModMigration

insert into CallLog( c_id, ARAccountCode,UniqueRef, CustomerSite, CallDate, CallType, Notes, SysUser, CompanyOutlet )
	select cu.c_id, cl.ARAccountCode, cl.UniqRef,cl.SiteName, cast(cm.START as date)
	, 'General Inquiry'
	, case 
	when isnull(cm.C_TEXT, '') = '' then isnull(cm.ISSUE, '')
	else cm.C_TEXT end
	--, cm.ISSUE
	, left(cm.USERNAME, 20)
	, cl.CompanyOutlet
	-- select count(1) -- 48938
	from ConversionData.dbo.cmts cm
	inner join ConversionData.dbo.cust cu on cu.c_id = cm.C_ID
	inner join CustomerLocations cl on cl.UniqRef = cast(cu.c_id as varchar)
	left join Account a on a.C_ID = cl.c_id 
	left join Child c on c.C_ID = cl.c_id
	where cm.TYPE <> 'M'
	--and cm.c_text = ''
	and  isnull(cm.C_TEXT, '') + isnull(cm.ISSUE, '') <> ''
	and cm.START is not null
	and cm.start > '2023-01-01'  -- Edit for one year

