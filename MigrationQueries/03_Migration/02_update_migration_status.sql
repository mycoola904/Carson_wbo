use ModMigration
-- Children migration status

-- NON FILTERED ACCOUNTS
update ch
set MigrationStatus = 'Active'
from Child ch

update p
set MigrationStatus = 'Active'
from Account p

/* THIS SECTION IS FOR FILTERING UPON REQUEST
--update ch
--set MigrationStatus = 'InActive'
--from Child ch



update ch set ch.MigrationStatus = t.NewMigrationStatus
-- select count(1)
-- select ch.c_id_alpha, ch.MigrationStatus , t.NewMigrationStatus
-- select ch.C_ID_ALPHA
from Child ch
inner join 
(
select cu.c_id, cu.C_ID_ALPHA, st.Status, cu.C_CUR_BAL, t3.MaxDate, t3.Years ,ch.MigrationStatus
,case 
when st.Status = 'PROSPECT' THEN 'InActive'
when cu.C_CUR_BAL <> 0 then 'Active'
when st.Status = 'NEW START' then 'Active'
when st.Description = 'ActiveAuto' then 'Active' --and t3.c_id is not null then 'Active' THESE TWO LINES ARE COMMENTED OUT THEY ARE FOR FILTERING OUT INACTIVE CUSTOMERS PER REQUEST
-- when st.Description = 'ActiveAuto' and osc.c_id is not null then 'Active'
else 'InActive' end NewMigrationStatus
from conversiondata.dbo.cust cu
inner join Child ch on ch.c_id = cu.C_ID
inner join status st on st.StatusID = cu.C_CSTAT
left join 	[HIST1Y] t3 on t3.C_ID = cu.C_ID
left join (select distinct c_id from ContainerOnSite) osc on osc.C_ID = cu.C_ID
--where (cu.C_ID_ALPHA not like '%-001' and cu.C_ID_ALPHA  like '%-%') 
) t on t.C_ID = ch.C_ID



 select count(1)
 from Child
 where MigrationStatus = 'Active'



-- Parent migration status
update p
set MigrationStatus = 'InActive'
from Account p

update a
set a.MigrationStatus = t.NewMigrationStatus, Sites = t.Children
-- select count(1)
from Account a
inner join 
(
select cu.c_id, cu.C_ID_ALPHA, st.Status, cu.C_CUR_BAL, t3.MaxDate, t3.Years ,a.MigrationStatus, ch.Children
,case 
when st.Status = 'PROSPECT' THEN 'InActive'
when cu.C_CUR_BAL <> 0 then 'Active'
when st.Description = 'ActiveAuto' and t3.c_id is not null then 'Active'
when st.Description = 'ActiveAuto' and osc.c_id is not null then 'Active'
when ch.Parent_id_alpha is not null then 'Active'
when st.Status = 'NEW START' then 'Active'
else 'InActive' end NewMigrationStatus
-- select count(1)
from conversiondata.dbo.cust cu
inner join Account a on a.c_id = cu.C_ID
inner join status st on st.StatusID = cu.C_CSTAT
left join 	[HIST1Y] t3 on t3.C_ID = cu.C_ID
left join (select distinct c_id from ContainerOnSite) osc on osc.C_ID = cu.C_ID
left join ( select Parent_id_alpha, count(1) Children from child where MigrationStatus = 'Active' group by Parent_id_alpha ) ch on ch.Parent_id_alpha = a.Parent_id_alpha
) t on t.C_ID = a.C_ID


 --select count(1)
 --from Account
 --where MigrationStatus = 'Active'


-- MasterAccount


--select * 
--from MasterAccount

 insert into MasterAccount(c_id
 , Parent_ID
 , Name
 , ARAccount
 , Currency
 , Notes
 , DMAccount
 , ChildCount
 , Project
 , Status_id)
 select cu.c_id
 ,LEFT(cu.C_ID_ALPHA, CHARINDEX('-', cu.C_ID_ALPHA)-1) 
 , B_NAME, 'MC'+LEFT(cu.C_ID_ALPHA, CHARINDEX('-', cu.C_ID_ALPHA)-1)
 , 'USD'
 , CU.C_COMMENTS
 , cu.C_ID_ALPHA
 , a.Sites
 ,  'Accurate'
 , s.id --, a.Sites
 --select *
 from ConversionData.dbo.CUST cu 
 inner join Status s on s.StatusID = cu.C_CSTAT
 inner join Account a on a.C_ID = cu.C_ID
 --left join [v_ParentChildrenCount] pc on pc.c_id = cu.c_id
 where cu.C_ID_ALPHA like '%-001' and a.Sites > 250
 */

 
update a
set a.MasterAccount_id = ma.id
--select a.MasterAccount_id
from account a
inner join MasterAccount ma on ma.c_id = a.C_ID


update ch
set ch.MasterAccount_id= a.MasterAccount_id
from Child ch
inner join Account a on a.id = ch.Parent_id


