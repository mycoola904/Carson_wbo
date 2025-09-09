use ModMigration

drop table if exists ContactsPrep 


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
	[ContactType_id] [bigint] NULL,
	)



	-- Operations/Service Contacts
	insert into ContactsPrep ( ARAccountCode, Salutation, Forename, Surname, JobTitle, TelNbr, TelExtNbr, MobileNbr, FaxNbr, EmailAddress, Notes, ContactType_id, ContactType2
	, ContactType3, TelNo, FaxNo, Account_id, Child_id
	)
	  select 
	cl.[ARAccountCode] ,
	'' [Salutation], 
	'' [Forename], 
	case 
	when isnull(c.C_PCONT, '') = '' and isnull(c.c_name,'')= '' then c.c_name2 
	when isnull(c.C_PCONT, '') = '' then c.c_name
	else c.c_pcont end [Surname], 
	'' [JobTitle], 
	c.C_PHO [TelNbr], 
	'' [TelExtNbr], 
	'' [MobileNbr], 
	c.C_FAX [FaxNbr], 
	c.C_EMAIL [EmailAddress], 
	'' [Notes], 
	ct.id [ContactType1], 
	'' [ContactType2], 
	'' [ContactType3], 
	'' [TelNo], 
	'' [FaxNo],
	a.id Account_id,
	ch.id Child_id
	-- select count(1)
	from ConversionData.dbo.cust c
	inner join CustomerLocations cl on cl.UniqRef = cast(c.C_ID as varchar)
	left join Child ch on ch.C_ID = c.C_ID
	left join Account a on a.C_ID = c.C_ID
	inner join ContactType ct on ct.Type = 'Operations/Service'
	
	-- AP Contacts
	insert into ContactsPrep (ARAccountCode, Salutation, Forename, Surname, JobTitle, TelNbr, TelExtNbr, MobileNbr, FaxNbr, EmailAddress, Notes, ContactType_id, ContactType2
	, ContactType3, TelNo, FaxNo, Account_id, Child_id
	)
	  select 
	cl.[ARAccountCode] ,
	'' [Salutation], 
	'' [Forename], 
	--case when isnull(c.B_PCONT, '') = '' then c.B_name2 else c.B_pcont end [Surname],
	case 
	when isnull(c.B_PCONT, '') = '' and isnull(c.B_NAME,'')= '' then c.B_NAME2 
	when isnull(c.B_PCONT, '') = '' then c.B_NAME
	else c.B_PCONT end [Surname],
	'' [JobTitle], 
	c.B_PHO [TelNbr], 
	'' [TelExtNbr], 
	'' [MobileNbr], 
	c.B_FAX [FaxNbr], 
	c.B_EMAIL [EmailAddress], 
	'' [Notes], 
	ct.id [ContactType1], 
	'' [ContactType2], 
	'' [ContactType3], 
	'' [TelNo], 
	'' [FaxNo],
	a.id Account_id,
	null Child_id
	-- select count(1)
	from ConversionData.dbo.cust c
	inner join CustomerLocations cl on cl.UniqRef = cast(c.C_ID as varchar)
	--left join Child ch on ch.C_ID = c.C_ID
	inner join Account a on a.C_ID = c.C_ID
	inner join ContactType ct on ct.Type = 'A/P Contact'
	
	

	-- Contacts  Do not pull these contacts going forward
	--insert into ContactsPrep (ARAccountCode, Salutation, Forename, Surname, JobTitle, TelNbr, TelExtNbr, MobileNbr, FaxNbr, EmailAddress, Notes, ContactType_id, ContactType2
	--, ContactType3, TelNo, FaxNo, Account_id, Child_id
	--)
	--	  select 
	--cl.[ARAccountCode] ,
	--'' [Salutation], 
	--'' [Forename], 
	--ct.C_NAME  [Surname], 
	--ct.TITLE [JobTitle], 
	--ct.C_PHO [TelNbr], 
	--'' [TelExtNbr], 
	--'' [MobileNbr], 
	--'' [FaxNbr], 
	--case 
	--when isnull(ct.C_EMAIL, '')='' then ct.b_EMAIL else ct.C_EMAIL end  [EmailAddress], 
	--'' [Notes], 
	--cx.id [ContactType1], 
	--'' [ContactType2], 
	--'' [ContactType3], 
	--'' [TelNo], 
	--'' [FaxNo],
	--a.id Account_id,
	--ch.id Child_id
	---- select count(1)
	--from ConversionData.dbo.CONT ct
	--inner join ConversionData.dbo.cust c on c.C_ID = ct.C_ID
	--inner join CustomerLocations cl on cl.UniqRef = cast(c.C_ID as varchar)
	--left join Child ch on ch.C_ID = c.C_ID
	--left join Account a on a.C_ID = c.C_ID
	--inner join ContactType cx on cx.Type = 'Other Contact'
	--where isnull(ct.C_NAME, '') <> '' or  isnull(ct.TITLE, '') <> '' or  isnull(ct.C_ADDR1, '') <> '' 
	--or  isnull(ct.C_ADDR2, '') <> '' or  isnull(ct.C_CITY, '') <> '' or  isnull(ct.C_STATE, '') <> '' or  isnull(ct.C_ZIP, '') <> '' 
	--or  isnull(ct.C_PHO, '') <> '' or  isnull(ct.C_EMAIL, '') <> '' or  isnull(ct.C_FAX, '') <> '' or  isnull(ct.B_EMAIL, '') <> ''
	--or isnull(ct.c_fax, '') <> ''

	--SELECT distinct ct.Type, ct.id
	--FROM ContactsPrep CP
	--INNER JOIN ContactType ct on ct.id = cp.ContactType_id
		
	delete cp
	--select cp.*
	from ContactsPrep cp
	inner join
	(
		select *
		from ContactsPrep
		where ContactType_id <> 3 --Other Contact
	) t on t.ARAccountCode = cp.ARAccountCode
	and t.Surname = cp.Surname
	and isnull(t.TelNbr, '') = isnull(cp.TelNbr, '')
	and isnull(t.EmailAddress, '') = isnull(cp.EmailAddress, '')
	where cp.ContactType_id = 3 -- Other Contact

	delete cp
	--select cp.*
	from ContactsPrep cp
	inner join
	(
		select *
		from ContactsPrep
		where ContactType_id = 2 -- A/P Contact
	) t on t.ARAccountCode = cp.ARAccountCode
	and t.Surname = cp.Surname
	and isnull(t.TelNbr, '') = isnull(cp.TelNbr, '')
	and isnull(t.EmailAddress, '') = isnull(cp.EmailAddress, '')
	where cp.ContactType_id <> 2 -- A/P Contact


	insert into Contacts (ARAccountCode, Salutation, Forename, Surname, JobTitle, TelNbr, TelExtNbr, MobileNbr, FaxNbr, EmailAddress, Notes, ContactType_id, ContactType2
	, ContactType3, TelNo, FaxNo, Account_id, Child_id
	)
	select ARAccountCode, Salutation, Forename, Surname, JobTitle, TelNbr, TelExtNbr, MobileNbr, FaxNbr, EmailAddress, Notes, ContactType_id, ContactType2
	, ContactType3, TelNo, FaxNo, Account_id, Child_id
	from ContactsPrep
	

-- Insert contact locations
insert into ContactLocations( ARAccountCode, SiteUniqueId, ContactUniqueId_id, Account_id, Child_id)
select cl.ARAccountCode
, cl.UniqRef
, ct.id
, a.id 
, ch.id
from Contacts ct
left join Account a on a.id = ct.Account_id
left join Child ch on ch.id = ct.Child_id
left join CustomerLocations cl on cl.UniqRef = case
when a.c_id is null then cast(ch.C_ID  as varchar)
else cast(a.C_ID  as varchar) end
where ct.ContactType_id in (1, 3)


insert into ContactLocations( ARAccountCode, SiteUniqueId, ContactUniqueId_id, Account_id, Child_id)
select cl.ARAccountCode
, cl.UniqRef
, ct.id
, a.id 
, ch.id
from Contacts ct
left join Account a on a.id = ct.Account_id
left join Child ch on ch.id = ct.Child_id
inner join (select * from CustomerLocations where UniqRef like '%.2') cl on cl.UniqRef = case
when a.c_id is null then cast(ch.C_ID  as varchar) + '.2'
else cast(a.C_ID  as varchar)+ '.2' end
where ct.ContactType_id in (2) --A/P Contacts


drop table if exists tempContactLocations 

select cl.ARAccountCode
, cl.UniqRef
, ct.id contactuniqueid
, a.id accountid
, ch.id childid
into tempContactLocations
from (
	select ct.* from Contacts ct
	left join ContactLocations cl on cl.ContactUniqueId_id = ct.id
	where cl.id is null  -- Where missing A/P contact
	) ct
left join Account a on a.id = ct.Account_id
left join Child ch on ch.id = ct.Child_id
inner join (select * from CustomerLocations where UniqRef not like '%.2') cl on cl.UniqRef = case
when a.c_id is null then cast(ch.C_ID  as varchar)
else cast(a.C_ID  as varchar) end
where ct.ContactType_id in (2)  -- A/P Contacts


-- Insert missing A/P Contacts
insert into ContactLocations( ARAccountCode, SiteUniqueId, ContactUniqueId_id, Account_id, Child_id)
select *
from tempContactLocations




