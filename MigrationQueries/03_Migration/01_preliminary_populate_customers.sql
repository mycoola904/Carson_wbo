-- ========================================================================
-- This script is used to populate the preliminary Customer tables 
-- in the RM97 Migration database.
-- It creates views to identify active accounts and children,
-- and then populates the MasterAccount, BillingInfo, LocationInfo, Account, and Child tables.
-- ========================================================================

use ModMigration

-- Drop existing tables if they exist

IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'v_ActiveAccounts')
BEGIN
    EXEC sp_executesql N'
    CREATE VIEW [dbo].[v_ActiveAccounts]
    AS
    SELECT CU.C_ID, ST.Status, CU.C_CUR_BAL
    -- select distinct st.Status
    FROM ConversionData.dbo.cust CU
    INNER JOIN Status ST ON ST.StatusID = CU.C_CSTAT
    WHERE ST.Status NOT IN (''INACTIVE'') OR CU.C_CUR_BAL <> 0';
END
ELSE
BEGIN
    EXEC sp_executesql N'
    ALTER VIEW [dbo].[v_ActiveAccounts]
    AS
    SELECT CU.C_ID, ST.Status, CU.C_CUR_BAL
    -- select distinct st.Status
    FROM ConversionData.dbo.cust CU
    INNER JOIN Status ST ON ST.StatusID = CU.C_CSTAT
    WHERE ST.Status NOT IN (''INACTIVE'') OR CU.C_CUR_BAL <> 0';
END

-- Create the v_ActiveChildren view
-- This view is used to identify active children accounts
-- The view selects all accounts that are not inactive or have a current balance greater than 0
-- and have a C_ID_ALPHA that contains a hyphen and does not end with '-001'

IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'v_ActiveChildren')
BEGIN
    EXEC sp_executesql N'
	CREATE VIEW [dbo].[v_ActiveChildren]
	AS
	SELECT CU.C_ID, aa.Status, cu.c_cur_bal
    FROM ConversionData.dbo.cust CU
    inner join v_ActiveAccounts aa on aa.C_ID = cu.C_ID
	where cu.C_ID_ALPHA like ''%-%'' and cu.C_ID_ALPHA not like ''%-001''';
END
ELSE
BEGIN
    EXEC sp_executesql N'
	ALTER VIEW [dbo].[v_ActiveChildren]
	AS
	SELECT CU.C_ID, aa.Status, cu.c_cur_bal
    FROM ConversionData.dbo.cust CU
    inner join v_ActiveAccounts aa on aa.C_ID = cu.C_ID
	where cu.C_ID_ALPHA like ''%-%'' and cu.C_ID_ALPHA not like ''%-001''';
END

-- Create the v_AccountRelationships view
-- This view is used to identify account relationships

IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'v_ParentChildrenCount')
BEGIN
    EXEC sp_executesql N'
	CREATE VIEW [dbo].[v_ParentChildrenCount]
	AS
	select p.c_id, p.C_ID_ALPHA, count(c.c_id_alpha) ChildCount
	from ConversionData.dbo.cust p
	left join (
	select c_id_alpha, left(c_id_alpha, charindex(''-'', C_ID_ALPHA)) ParentAccount
	from ConversionData.dbo.cust cu
	inner join v_ActiveChildren ac on ac.C_ID = cu.C_ID
	
	) c on c.ParentAccount = left(p.c_id_alpha, charindex(''-'', p.C_ID_ALPHA))
	where p.C_ID_ALPHA like ''%-001''
	group by p.C_ID, p.C_ID_ALPHA';
END
ELSE
BEGIN
    EXEC sp_executesql N'
	ALTER VIEW [dbo].[v_ParentChildrenCount]
	AS
	select p.c_id, p.C_ID_ALPHA, count(c.c_id_alpha) ChildCount
	from ConversionData.dbo.cust p
	left join (
	select c_id_alpha, left(c_id_alpha, charindex(''-'', C_ID_ALPHA)) ParentAccount
	from ConversionData.dbo.cust cu
	inner join v_ActiveChildren ac on ac.C_ID = cu.C_ID
	
	) c on c.ParentAccount = left(p.c_id_alpha, charindex(''-'', p.C_ID_ALPHA))
	where p.C_ID_ALPHA like ''%-001''
	group by p.C_ID, p.C_ID_ALPHA';
END


-- Insert into the MasterAccount table
-- This table stores the master account information
-- The insert statement selects data from the ConversionData.dbo.CUST table and joins it with the Status and v_ParentChildrenCount views
-- The data is filtered to only include accounts that have a C_ID_ALPHA that ends with '-001' and have more than 250 children

insert into MasterAccount(c_id, Parent_ID, Name, ARAccount, Currency, Notes, DMAccount, ChildCount, Project, Status_id)
select cu.c_id,LEFT(cu.C_ID_ALPHA, CHARINDEX('-', cu.C_ID_ALPHA)-1) , B_NAME, 'MC'+LEFT(cu.C_ID_ALPHA, CHARINDEX('-', cu.C_ID_ALPHA)-1)
, 'USD', CU.C_COMMENTS, cu.C_ID_ALPHA, pc.ChildCount, '', s.id --, pc.childcount
from ConversionData.dbo.CUST cu 
inner join Status s on s.StatusID = cu.C_CSTAT
left join [v_ParentChildrenCount] pc on pc.c_id = cu.c_id
where cu.C_ID_ALPHA like '%-001' and pc.ChildCount > 250


-- Insert into the BillingInfo table
-- This table stores the billing information for each account


insert into BillingInfo( B_NAME, B_NAME2, B_ADDR1, B_ADDR2, B_CITY, B_STATE, B_ZIP, B_PHO, B_PCONT, B_FAX, B_FCONT, B_EMAIL, BillKey, C_ID, UniqueReference)
select B_NAME, B_NAME2, B_ADDR1, B_ADDR2, B_CITY, B_STATE, B_ZIP, B_PHO, B_PCONT, B_FAX, B_FCONT, B_EMAIL
,replace(concat( isnull( b_addr1, ''), isnull( b_addr2, ''), isnull( B_CITY, ''), isnull( B_STATE, ''), isnull( B_ZIP,'')),' ','') Billkey
, C_ID
, cast(c_id as varchar) UniqueRef
from ConversionData.dbo.cust cu


-- Insert into the LocationInfo table
-- This table stores the location information for each account
insert into LocationInfo( C_NAME, C_NAME2, C_ADDRNUM1, C_ADDR1, C_ADDR2, C_CITY, C_STATE, C_ZIP, C_PHO, C_PCONT, C_FAX, C_FCONT, C_BILL_TO, C_SALESREP, C_EMAIL, C_ID, LocKey)
select C_NAME, C_NAME2, C_ADDRNUM1, C_ADDR1, C_ADDR2, C_CITY, C_STATE, C_ZIP, C_PHO, C_PCONT, C_FAX, C_FCONT, C_BILL_TO, C_SALESREP, C_EMAIL, C_ID
, replace(concat( isnull( C_ADDRNUM1, ''), isnull( c_addr1, ''), isnull( C_ADDR2, ''), isnull( C_CITY, ''), isnull( C_STATE, ''), isnull( C_ZIP,'')),' ','') LocKey
--select *
from ConversionData.dbo.cust cu
--where C_ADDRNUM1 like '%803 Jacks%'




-- Insert into the Account table
-- This table stores the account information for each customer


insert into Account( C_ID, C_ID_ALPHA, C_CSTAT, C_COMMENTS, C_FIN_CHG, C_DELNQLVL, B_TAXABLE, B_ACCTTYPE, B_PO_NUM, B_PAGE, B_PAYBYCC, B_CONTRACT_NUM, B_CONTRACT_DATE, C_15D, C_45D, REFERRAL, 
                         B_NAME_2ND, B_NAME_2ND2, B_ADDR1_2ND, B_ADDR1_2ND2, B_CITY_2ND, B_STATE_2ND, B_ZIP_2ND, C_DEPOSIT, CREP1_NOTES, CREP2_NOTES, SREP1_NOTES, SREP2_NOTES, C_TYPE2, C_TYPE3, B_MTD, B_YTD, 
                         B_LMTD, B_LYTD, B_TERMS, REFERRAL2, KFACTOR, GAL_DEGREE_DAY, LCK_GAL_DEGREE_DAY, GAL_DAY, LCK_GAL_DAY, T_ID, OUTPUT, C_120D, C_150D, B_SURCHARGE, SITEFILE, QUOTE_SHEET, C_TYPE4, 
                         C_TYPE5, C_TYPE6, C_TYPE7, C_TYPE8, C_TYPE9, C_LOCS2, C_NLOCS2, C_SUFFIX2, ISCHILD2, C_LOCS3, C_NLOCS3, C_SUFFIX3, ISCHILD3, TOTAL_TONS, GUARANTEED_PRICE, C_CURRENCY, REGION, DISTRICT, 
                         PROFILE_AREA, CLIENT_ID, BUSINESS_UNIT, LOCATION_TYPE, RANK_CLASS, DIVISION, CLIENT_SHARED_PERCENTAGE, SURCHARGE_BENCHMARK, LOCATION_ID, NATIONAL_ACCT, V_STORENO, PARENT_C_ID, 
                         AUTHORIZEDPAYEE, REBATEPAY, LastUpdated, B_QB_PATH, ContactViaPhone, Tax_Exempt_ID, Flex_Date, AutoEmailCustomerReceipt, Relationship, Parent_id_alpha, BillArea_id, BillingCycle_id, BillingGroup_id, 
                         BillingInfo1_id, BillingInfo2_id, BillingInfo3_id, BillingInfo4_id, CREP1_id, CREP2_id, Company_id, DelinquencyLevel_id, FinanceCharge_id, MasterAccount_id, SREP1_id, SREP2_id, StatementType_id, TaxArea_id, status_id, BillingInfo_id, LocationInfo_id, Terms_id, C_QUOTE)
SELECT 
	   cu.[C_ID]
      ,cu.[C_ID_ALPHA]
      ,cu.[C_CSTAT]
      ,cu.[C_COMMENTS]
      ,cu.[C_FIN_CHG]
      ,cu.[C_DELNQLVL]
      ,cu.[B_TAXABLE]
      ,cu.[B_ACCTTYPE]
      ,cu.[B_PO_NUM]
      ,cu.[B_PAGE]
      ,cu.[B_PAYBYCC]
      ,cu.[B_CONTRACT_NUM]
      ,cu.[B_CONTRACT_DATE]
      ,cu.[C_15D]
      ,cu.[C_45D]
      ,cu.[REFERRAL]
      ,cu.[B_NAME_2ND]
      ,cu.[B_NAME_2ND2]
      ,cu.[B_ADDR1_2ND]
      ,cu.[B_ADDR1_2ND2]
      ,cu.[B_CITY_2ND]
      ,cu.[B_STATE_2ND]
      ,cu.[B_ZIP_2ND]
      ,cu.[C_DEPOSIT]
      ,cu.[CREP1_NOTES]
      ,cu.[CREP2_NOTES]
      ,cu.[SREP1_NOTES]
      ,cu.[SREP2_NOTES]
      ,cu.[C_TYPE2]
      ,cu.[C_TYPE3]
      ,cu.[B_MTD]
      ,cu.[B_YTD]
      ,cu.[B_LMTD]
      ,cu.[B_LYTD]
      ,cu.[B_TERMS]
      ,cu.[REFERRAL2]
      ,cu.[KFACTOR]
      ,cu.[GAL_DEGREE_DAY]
      ,cu.[LCK_GAL_DEGREE_DAY]
      ,cu.[GAL_DAY]
      ,cu.[LCK_GAL_DAY]
      ,cu.[T_ID]
      ,cu.[OUTPUT]
      ,cu.[C_120D]
      ,cu.[C_150D]
      ,cu.[B_SURCHARGE]
      ,cu.[SITEFILE]
      ,cu.[QUOTE_SHEET]
      ,cu.[C_TYPE4]
      ,cu.[C_TYPE5]
      ,cu.[C_TYPE6]
      ,cu.[C_TYPE7]
      ,cu.[C_TYPE8]
      ,cu.[C_TYPE9]
      ,cu.[C_LOCS2]
      ,cu.[C_NLOCS2]
      ,cu.[C_SUFFIX2]
      ,cu.[ISCHILD2]
      ,cu.[C_LOCS3]
      ,cu.[C_NLOCS3]
      ,cu.[C_SUFFIX3]
      ,cu.[ISCHILD3]
      ,cu.[TOTAL_TONS]
      ,cu.[GUARANTEED_PRICE]
      ,cu.[C_CURRENCY]
      ,cu.[REGION]
      ,cu.[DISTRICT]
      ,cu.[PROFILE_AREA]
      ,cu.[CLIENT_ID]
      ,cu.[BUSINESS_UNIT]
      ,cu.[LOCATION_TYPE]
      ,cu.[RANK_CLASS]
      ,cu.[DIVISION]
      ,cu.[CLIENT_SHARED_PERCENTAGE]
      ,cu.[SURCHARGE_BENCHMARK]
      ,cu.[LOCATION_ID]
      ,cu.[NATIONAL_ACCT]
      ,cu.[V_STORENO]
      ,cu.[PARENT_C_ID]
      ,cu.[AUTHORIZEDPAYEE]
      ,cu.[REBATEPAY]
      ,cu.[LastUpdated]
      ,cu.[B_QB_PATH]
      ,cu.[ContactViaPhone]
      ,cu.[Tax_Exempt_ID]
      ,cu.[Flex_Date]
      ,cu.[AutoEmailCustomerReceipt]
      ,rs.[Relationship]
	  ,case when charindex('-',cu.c_id_alpha)<> 0 then left(cu.C_ID_ALPHA, charindex('-',cu.C_ID_ALPHA)) else C_ID_ALPHA end [Parent_id_alpha]
      ,ba.id [BillArea_id]
      ,bc.id [BillingCycle_id]
      ,bg.id [BillingGroup_id]
      ,bi1.id [BillingInfo1_id]
      ,bi2.id [BillingInfo2_id]
      ,bi3.id [BillingInfo3_id]
      ,bi4.id [BillingInfo4_id]
      ,cr1.id [CREP1_id]
      ,cr2.id [CREP2_id]
      ,co.id [Company_id]
      ,dl.id [DelinquencyLevel_id]
      ,fc.id [FinanceCharge_id]
	  ,ma.id MasterAccount_id
      ,sr1.id [SREP1_id]
      ,sr2.id [SREP2_id]
      ,st.id [StatementType_id]
      ,ta.id [TaxArea_id]
      ,cst.id [status_id]
      ,billinfo.id [BillingInfo_id]
      ,locinfo.id [LocationInfo_id]
      ,Terms.id [Terms_id]
	  ,cu.C_QUOTE
  -- Select count(1)
  FROM  (select * from ConversionData.dbo.CUST where C_ID_ALPHA like '%-001' or C_ID_ALPHA not like '%-%')  cu
  inner join dbo.v_AccountRelationships rs on rs.C_ID = cu.C_ID
  left join BillArea ba on ba.BillAreaID = cu.B_AREA
  left join BillingCycle bc on bc.BillingCycleID = cu.B_B_CYCLE
  left join BillingGroup bg on bg.BillingGroupID = cu.B_BILL_TYP
  left join BillScreenInfo bi1 on bi1.BillScreenInfoID = cu.B_BILL_INFO1
  left join BillScreenInfo bi2 on bi2.BillScreenInfoID = cu.B_BILL_INFO2
  left join BillScreenInfo bi3 on bi3.BillScreenInfoID = cu.B_BILL_INFO3
  left join BillScreenInfo bi4 on bi4.BillScreenInfoID = cu.B_BILL_INFO4
  left join CustomerRep cr1 on cr1.CustomerRepID = cu.CREP1
  left join CustomerRep cr2 on cr2.CustomerRepID = cu.CREP2
  left join CustomerRep sr1 on sr1.CustomerRepID = cu.SREP1
  left join CustomerRep sr2 on sr2.CustomerRepID = cu.SREP2
  left join Company co on co.CompanyID = cu.B_BILL_CO
  left join DelinquencyLevel dl on dl.DelinquencyLevelID = B_DELINQ
  left join FinanceCharge fc on fc.FinanceChargeID = B_FIN_DESC
  left join MasterAccount ma on ma.c_id = cu.C_ID
  left join StatementType st on st.StatementTypeID = B_STMT_TYP
  left join TaxArea ta on ta.TaxAreaID = B_TAXAREA
  inner join Status cst on cst.StatusID = C_CSTAT
  inner join BillingInfo billinfo on billinfo.c_id = cu.c_id
  inner join LocationInfo locinfo on locinfo.c_id = cu.c_id
  left join Terms on Terms.TermsID = cu.B_TERMS
  where C_ID_ALPHA like '%-001' or C_ID_ALPHA not like '%-%'



-- Insert into the Child table
-- This table stores the child account information
insert into child(C_ID, C_ID_ALPHA, C_CSTAT, C_COMMENTS, C_FIN_CHG, C_DELNQLVL, B_TAXABLE, B_ACCTTYPE, B_PO_NUM, B_PAGE, B_PAYBYCC, B_CONTRACT_NUM, B_CONTRACT_DATE, C_15D, C_45D, REFERRAL, B_NAME_2ND, B_NAME_2ND2, B_ADDR1_2ND, B_ADDR1_2ND2, 
B_CITY_2ND, B_STATE_2ND, B_ZIP_2ND, C_DEPOSIT, CREP1_NOTES, CREP2_NOTES, SREP1_NOTES, SREP2_NOTES, C_TYPE2, C_TYPE3, B_MTD, B_YTD, B_LMTD, B_LYTD, B_TERMS, REFERRAL2, KFACTOR, GAL_DEGREE_DAY, LCK_GAL_DEGREE_DAY, GAL_DAY, 
LCK_GAL_DAY, T_ID, OUTPUT, C_120D, C_150D, B_SURCHARGE, SITEFILE, QUOTE_SHEET, C_TYPE4, C_TYPE5, C_TYPE6, C_TYPE7, C_TYPE8, C_TYPE9, C_LOCS2, C_NLOCS2, C_SUFFIX2, ISCHILD2, C_LOCS3, C_NLOCS3, C_SUFFIX3, ISCHILD3, TOTAL_TONS
, GUARANTEED_PRICE, C_CURRENCY, REGION, DISTRICT, PROFILE_AREA, CLIENT_ID, BUSINESS_UNIT, LOCATION_TYPE, RANK_CLASS, DIVISION, CLIENT_SHARED_PERCENTAGE, SURCHARGE_BENCHMARK, LOCATION_ID, NATIONAL_ACCT, V_STORENO, PARENT_C_ID
, AUTHORIZEDPAYEE, REBATEPAY, LastUpdated, B_QB_PATH, ContactViaPhone, Tax_Exempt_ID, Flex_Date, AutoEmailCustomerReceipt, Relationship, Parent_id_alpha, BillArea_id, BillingCycle_id, BillingGroup_id, BillingInfo1_id
, BillingInfo2_id, BillingInfo3_id, BillingInfo4_id, CREP1_id, CREP2_id, Company_id, DelinquencyLevel_id, FinanceCharge_id, MasterAccount_id, Parent_id, SREP1_id, SREP2_id, StatementType_id, TaxArea_id, status_id, BillingInfo_id
, LocationInfo_id, Terms_id, C_QUOTE)
SELECT 
	   cu.[C_ID]
      ,cu.[C_ID_ALPHA]
      ,cu.[C_CSTAT]
      ,cu.[C_COMMENTS]
      ,cu.[C_FIN_CHG]
      ,cu.[C_DELNQLVL]
      ,cu.[B_TAXABLE]
      ,cu.[B_ACCTTYPE]
      ,cu.[B_PO_NUM]
      ,cu.[B_PAGE]
      ,cu.[B_PAYBYCC]
      ,cu.[B_CONTRACT_NUM]
      ,cu.[B_CONTRACT_DATE]
      ,cu.[C_15D]
      ,cu.[C_45D]
      ,cu.[REFERRAL]
      ,cu.[B_NAME_2ND]
      ,cu.[B_NAME_2ND2]
      ,cu.[B_ADDR1_2ND]
      ,cu.[B_ADDR1_2ND2]
      ,cu.[B_CITY_2ND]
      ,cu.[B_STATE_2ND]
      ,cu.[B_ZIP_2ND]
      ,cu.[C_DEPOSIT]
      ,cu.[CREP1_NOTES]
      ,cu.[CREP2_NOTES]
      ,cu.[SREP1_NOTES]
      ,cu.[SREP2_NOTES]
      ,cu.[C_TYPE2]
      ,cu.[C_TYPE3]
      ,cu.[B_MTD]
      ,cu.[B_YTD]
      ,cu.[B_LMTD]
      ,cu.[B_LYTD]
      ,cu.[B_TERMS]
      ,cu.[REFERRAL2]
      ,cu.[KFACTOR]
      ,cu.[GAL_DEGREE_DAY]
      ,cu.[LCK_GAL_DEGREE_DAY]
      ,cu.[GAL_DAY]
      ,cu.[LCK_GAL_DAY]
      ,cu.[T_ID]
      ,cu.[OUTPUT]
      ,cu.[C_120D]
      ,cu.[C_150D]
      ,cu.[B_SURCHARGE]
      ,cu.[SITEFILE]
      ,cu.[QUOTE_SHEET]
      ,cu.[C_TYPE4]
      ,cu.[C_TYPE5]
      ,cu.[C_TYPE6]
      ,cu.[C_TYPE7]
      ,cu.[C_TYPE8]
      ,cu.[C_TYPE9]
      ,cu.[C_LOCS2]
      ,cu.[C_NLOCS2]
      ,cu.[C_SUFFIX2]
      ,cu.[ISCHILD2]
      ,cu.[C_LOCS3]
      ,cu.[C_NLOCS3]
      ,cu.[C_SUFFIX3]
      ,cu.[ISCHILD3]
      ,cu.[TOTAL_TONS]
      ,cu.[GUARANTEED_PRICE]
      ,cu.[C_CURRENCY]
      ,cu.[REGION]
      ,cu.[DISTRICT]
      ,cu.[PROFILE_AREA]
      ,cu.[CLIENT_ID]
      ,cu.[BUSINESS_UNIT]
      ,cu.[LOCATION_TYPE]
      ,cu.[RANK_CLASS]
      ,cu.[DIVISION]
      ,cu.[CLIENT_SHARED_PERCENTAGE]
      ,cu.[SURCHARGE_BENCHMARK]
      ,cu.[LOCATION_ID]
      ,cu.[NATIONAL_ACCT]
      ,cu.[V_STORENO]
      ,cu.[PARENT_C_ID]
      ,cu.[AUTHORIZEDPAYEE]
      ,cu.[REBATEPAY]
      ,cu.[LastUpdated]
      ,cu.[B_QB_PATH]
      ,cu.[ContactViaPhone]
      ,cu.[Tax_Exempt_ID]
      ,cu.[Flex_Date]
      ,cu.[AutoEmailCustomerReceipt]
      ,rs.[Relationship]
	  ,case 
	  when charindex('-',cu.c_id_alpha)<> 0 then left(cu.C_ID_ALPHA, charindex('-',cu.C_ID_ALPHA))
	  else cu.C_ID_ALPHA end
	  [Parent_id_alpha]
      ,ba.id [BillArea_id]
      ,bc.id [BillingCycle_id]
      ,bg.id [BillingGroup_id]
      ,bi1.id [BillingInfo1_id]
      ,bi2.id [BillingInfo2_id]
      ,bi3.id [BillingInfo3_id]
      ,bi4.id [BillingInfo4_id]
      ,cr1.id [CREP1_id]
      ,cr2.id [CREP2_id]
      ,co.id [Company_id]
      ,dl.id [DelinquencyLevel_id]
      ,fc.id [FinanceCharge_id]
	  ,ma.id MasterAccount_id
	  ,a.id Parent_id
      ,sr1.id [SREP1_id]
      ,sr2.id [SREP2_id]
      ,st.id [StatementType_id]
      ,ta.id [TaxArea_id]
      ,cst.id [status_id]
      ,billinfo.id [bill_id]
	  ,locinfo.id [loc_id]
    ,Terms.id [Terms_id]
	,cu.C_QUOTE
	--select count(1)
  FROM  ( select * from ConversionData.dbo.CUST  where C_ID_ALPHA not like '%-001' and C_ID_ALPHA like '%-%' --and C_ID_ALPHA not like '%-%-%' 
  ) cu
  inner join dbo.v_AccountRelationships rs on rs.C_ID = cu.C_ID
  left join BillArea ba on ba.BillAreaID = cu.B_AREA
  left join BillingCycle bc on bc.BillingCycleID = cu.B_B_CYCLE
  left join BillingGroup bg on bg.BillingGroupID = cu.B_BILL_TYP
  left join BillScreenInfo bi1 on bi1.BillScreenInfoID = cu.B_BILL_INFO1
  left join BillScreenInfo bi2 on bi2.BillScreenInfoID = cu.B_BILL_INFO2
  left join BillScreenInfo bi3 on bi3.BillScreenInfoID = cu.B_BILL_INFO3
  left join BillScreenInfo bi4 on bi4.BillScreenInfoID = cu.B_BILL_INFO4
  left join CustomerRep cr1 on cr1.CustomerRepID = cu.CREP1
  left join CustomerRep cr2 on cr2.CustomerRepID = cu.CREP2
  left join CustomerRep sr1 on sr1.CustomerRepID = cu.SREP1
  left join CustomerRep sr2 on sr2.CustomerRepID = cu.SREP2
  left join Company co on co.CompanyID = cu.B_BILL_CO
  left join DelinquencyLevel dl on dl.DelinquencyLevelID = B_DELINQ
  left join FinanceCharge fc on fc.FinanceChargeID = B_FIN_DESC
  left join Account a on a.C_ID = cu.PARENT_C_ID
  left join MasterAccount ma on ma.c_id = a.C_ID
  left join StatementType st on st.StatementTypeID = B_STMT_TYP
  left join TaxArea ta on ta.TaxAreaID = B_TAXAREA
  inner join Status cst on cst.StatusID = cu.C_CSTAT
  inner join BillingInfo billinfo on billinfo.c_id = cu.c_id
  inner join LocationInfo locinfo on locinfo.c_id = cu.c_id
  left join Terms on Terms.TermsID = cu.B_TERMS
 
--and cu.C_ID_ALPHA not like '%-%-%'
--and p.C_ID is null


-- MasterAccount


--select * 
--from MasterAccount


-- Populate the MissingAccounts table
-- This table stores accounts that are missing from the Account and Child tables
drop table if exists MissingAccounts

select CU.* 
into MissingAccounts
from ConversionData.dbo.cust cu
left join
(
select c_id 
from Account
union 
select c_id 
from child 
) t on t.C_ID = cu.C_ID
where t.C_ID is null


-- --  Check Counts

--  select sum(1)
--  from ConversionData.dbo.CUST 

-- --select c.* 
-- --from ConversionData.dbo.CUST c 
-- --left join Account a  on a.C_ID = c.C_ID
-- --where a.id is null


--    select sum(num)
--    from
--    (
--    select count(1) num, 'accts' typ
--    from Account 
--    union
--    select count(1) num, 'child' typ
--    from Child 
--    ) t


--     select cu.C_ID_ALPHA, cu.*
--    from ConversionData.dbo.CUST  cu
--    left join
--     (
--    select C_ID
--    from Account 
--    union
--    select C_ID
--    from Child 
--    ) t on t.C_ID = cu.C_ID
--    where t.C_ID is null

--   --select 23001 - 22987

--   ---- Seven GrandChildren
--   select c_id_alpha 
--   from ConversionData.dbo.cust cu
--   left join
--   (
--   select c_id 
--   from Account
--   union 
--   select c_id 
--   from child 
--   ) t on t.C_ID = cu.C_ID
--   where t.C_ID is null
--   and C_ID_ALPHA like '%-%-%'

-- select *
-- from MissingAccounts


-- select cu.c_id_alpha, left(cu.c_id_alpha,charindex('-',cu.c_id_alpha)) parentidalpha
-- from ConversionData.dbo.cust cu
-- inner join 
-- (
-- select C_ID_ALPHA, left(c_id_alpha,charindex('-',c_id_alpha)) parentidalpha
-- from ConversionData.dbo.cust 
-- where C_ID_ALPHA like '%-%-%'
-- ) t on t.parentidalpha = left(cu.c_id_alpha,charindex('-',cu.c_id_alpha))
-- where cu.C_ID_ALPHA not like '%-001-%'



-- -- check the length of the id alpha due to the limitation for account numbers in Platform.
--  select *
--  from ConversionData.dbo.cust cu
--  where len(
--  case when c_id_alpha like '%-%-%' then replace(c_id_alpha, '-001-','-')
--  else c_id_alpha end ) > 10

--  select max(len(c_id_alpha)) 
--  from ConversionData.dbo.CUST 
--  where C_ID_ALPHA not like '%-%'

--  select max(len(c_id_alpha)) 
--  from ConversionData.dbo.CUST 
--  where C_ID_ALPHA not like '%-%'

--   select max(len(c_id_alpha)) 
--  from ConversionData.dbo.CUST 
--  where C_ID_ALPHA  like '%-%'


--   select * 
--  from ConversionData.dbo.CUST 
--  where len(C_ID_ALPHA)>10


