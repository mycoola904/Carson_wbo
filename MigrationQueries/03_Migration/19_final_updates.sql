use ModMigration

update cs 
set cs.payment_type =
case 
when USE_REC_CHGS = '1' then 'Credit Card/Auto-Pay'
else 'Credit Card' end 
from Customers cs
inner join ConversionData.dbo.CARD c on c.c_id = cs.c_id
where c.TYPE = 'CREDIT'

update soh
set soh.DriverNotes= isnull(ta.Notes, '')
from SiteOrderHeader soh
inner join ( select * from SiteOrderAssignments where isnull(notes,'')<> '') ta on ta.SiteOrderUniqueRef = soh.id

