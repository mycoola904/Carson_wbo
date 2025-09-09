-- This inserts into customers all from the 'parent' accounts and single location accounts

use ModMigration

insert into Customers(c_id, c_id_alpha, ar_account_code, company, customer_name, currency, invoice_cycle, invoice_frequency_term, payment_term, payment_type, credit_limit, customer_state, invoice_document_delivery_type, 
                         ar_ap_documents_option, credit_controller, customer_category, sic_code, combine_ar_ap_for_credit_checks, combine_charges_rebates, is_internal, rct_customer, show_lft_on_invoice, tickets_required_with_invoice, 
                         proof_of_service_required, collate_invoices, settlement_percentage, roll_up_invoice_by_service, roll_up_invoice_by_site, customer_invoice_number_required, is_order_number_required, summary_invoice, 
                         rebate_billing_option, rebate_invoice_cycle, rebate_invoice_frequency_term, invoices_sent_electronically, one_inv_per_po, one_inv_per_dept, one_inv_per_job, contract_status, exclude_from_statement_run, customer_type, 
                         customer_notes, customer_template, customer_group, federal_id, marketing_source, start_date, alt_search_reference, business_sector, ap_account_code, sales_rep, csr, payment_handling_code, rebate_payment_type, 
                         rebate_payment_terms, sales_territory, master_ar_account_code, dm_account, Parent_id, Child_id, Account_id) 
SELECT 
	 a.C_ID
	 , a.C_ID_ALPHA
	-- ,REPLACE(LEFT(REPLACE(CASE 
	--WHEN ISNULL(CUST.B_NAME,'')<>'' THEN CUST.B_NAME
	--ELSE CUST.B_NAME2 END, ' ', ''),10),'@','')  [ARAccountCode] 
	 , dbo.GetARAccountCode(a.C_ID_ALPHA) [ARAccountCode]
	 ,co.COMPANY [Company]
	 
	 ,case 
      when isnull(li.C_NAME,'')='' then li.C_NAME2 
      ELSE li.C_NAME END [CustomerName] 
	 ,'USD' [Currency] 
	 , bc.Description [InvoiceCycle] 
	 , 'Immediately' [InvoiceFrequencyTerm] 
	 , te.Description [PaymentTerm] 
	 ,'Check' [PaymentType] 
	 , a.B_ACCTTYPE [CreditLimit] 
	 , case 
		when C_ID_ALPHA like '%-001' then a.MigrationStatus else  st.Status end [CustomerState] 
	 ,case 
	  when a.OUTPUT = 3 then '2' else '1' end  [InvoiceDocumentDeliveryType] 
	 , '' [ARAPDocumentsOption] 
	 , '' [CreditController] 
	 , bg.Description [CustomerCategory] 
	 , '' [SICCode] 
	 , '' [CombineARAPForCreditChecks] 
	 , '' [CombineChargesRebates] 
	 , '' [IsInternal] 
	 , '' [RCTCustomer] 
	 , '' [ShowLFTOnInvoice] 
	 , '' [TicketsRequiredWithInvoice] 
	 , '' [ProofOfServiceRequired] 
	 , '0' [CollateInvoices] 
	 , '' [SettlementPercentage] 
	 , '' [RollUpInvoiceByService] 
	 , '' [RollUpInvoiceBySite] 
	 , '' [CustomerInvoiceNumberRequired] 
	 , '' [IsOrderNumberRequired] 
	 , '' [SummaryInvoice] 
	 , '' [RebateBillingOption] 
	 , '' [RebateInvoiceCycle] 
	 , '' [RebateInvoiceFrequencyTerm] 
	 , '' [InvoicesSentElectronically] 
	 , '' [OneInvPerPO] 
	 , '' [OneInvPerDept] 
	 , '' [OneInvPerJob] 
	 , '' [ContractStatus] 
	 , '' [ExcludeFromStatementRun] 
	 , '' [CustomerType] 
	 , isnull(a.C_COMMENTS,'') [CustomerNotes]  
	 , '' [CustomerTemplate] 
	 , '' [CustomerGroup] 
	 , '' [FederalId] 
	 , '' [MarketingSource] 
	 , cast(isnull(a.c_quote, getdate()) as date) [StartDate] 
	 , a.C_ID_ALPHA [AltSearchReference] 
	 , '' [BusinessSector] 
	 , '' [APAccountCode] 
	 , isnull(cr.NAME, '') [SalesRep] 
	 , '' [CSR] 
	 , '' [PaymentHandlingCode] 
	 , '' [RebatePaymentType] 
	 , '' [RebatePaymentTerms] 
	 , '' [SalesTerritory]
	 , isnull(ma.ARAccount, '') [MasterARAccountCode]
	 , a.C_ID_ALPHA DMAccount
	 ,null  parent
	 ,null Child_id
	 ,a.id Account_id
	 --select count(1)
	 --select bc.description, a.*
	 from Account a
	 left join Company co on co.id = a.Company_id
	 inner join LocationInfo li on li.id = a.LocationInfo_id
	 inner join BillingInfo bi on bi.id = a.BillingInfo_id
	 left join BillingCycle bc on bc.id = a.BillingCycle_id
	 --where bc.id is null 
	 left join Terms te on te.id = a.Terms_id
	 --where te.id is null 
	 inner join Status st on st.id = a.status_id
	 left join BillingGroup bg on bg.id = a.BillingGroup_id
	 left join CustomerRep cr on cr.id = a.CREP1_id
	 left join MasterAccount ma on ma.id = a.MasterAccount_id
	 where a.MigrationStatus = 'Active'
	 
-- This inserts locations into customers if it is linked to a master customer.	 
  insert into Customers(c_id, c_id_alpha, ar_account_code, company, customer_name, currency, invoice_cycle, invoice_frequency_term, payment_term, payment_type, credit_limit, customer_state, invoice_document_delivery_type, 
                           ar_ap_documents_option, credit_controller, customer_category, sic_code, combine_ar_ap_for_credit_checks, combine_charges_rebates, is_internal, rct_customer, show_lft_on_invoice, tickets_required_with_invoice, 
                           proof_of_service_required, collate_invoices, settlement_percentage, roll_up_invoice_by_service, roll_up_invoice_by_site, customer_invoice_number_required, is_order_number_required, summary_invoice, 
                           rebate_billing_option, rebate_invoice_cycle, rebate_invoice_frequency_term, invoices_sent_electronically, one_inv_per_po, one_inv_per_dept, one_inv_per_job, contract_status, exclude_from_statement_run, customer_type, 
                           customer_notes, customer_template, customer_group, federal_id, marketing_source, start_date, alt_search_reference, business_sector, ap_account_code, sales_rep, csr, payment_handling_code, rebate_payment_type, 
                           rebate_payment_terms, sales_territory, master_ar_account_code, dm_account, Parent_id, Child_id, Account_id) 
  SELECT 
  	 a.C_ID
  	 , a.C_ID_ALPHA
  	-- ,REPLACE(LEFT(REPLACE(CASE 
  	--WHEN ISNULL(CUST.B_NAME,'')<>'' THEN CUST.B_NAME
  	--ELSE CUST.B_NAME2 END, ' ', ''),10),'@','')  [ARAccountCode] 
  	 , dbo.GetARAccountCode(a.C_ID_ALPHA) [ARAccountCode]
  	 ,co.COMPANY [Company] 
  	 ,CASE 
  	  WHEN ISNULL(li.C_NAME, '')<>'' THEN li.C_NAME
  	  WHEN ISNULL(li.c_NAME2, '')<>'' THEN li.C_NAME2
  	  ELSE li.C_NAME END [CustomerName] 
  	 ,'USD' [Currency] 
  	 , bc.Description [InvoiceCycle] 
  	 , 'Immediately' [InvoiceFrequencyTerm] 
  	 , te.Description [PaymentTerm] 
  	 ,'Check' [PaymentType] 
  	 , a.B_ACCTTYPE [CreditLimit] 
  	 , st.Status [CustomerState] 
  	 ,case 
  	  when a.OUTPUT = 3 then '2' else '1' end  [InvoiceDocumentDeliveryType] 
  	 , '' [ARAPDocumentsOption] 
  	 , '' [CreditController] 
  	 , bg.Description [CustomerCategory] 
  	 , '' [SICCode] 
  	 , '' [CombineARAPForCreditChecks] 
  	 , '' [CombineChargesRebates] 
  	 , '' [IsInternal] 
  	 , '' [RCTCustomer] 
  	 , '' [ShowLFTOnInvoice] 
  	 , '' [TicketsRequiredWithInvoice] 
  	 , '' [ProofOfServiceRequired] 
  	 , '0' [CollateInvoices] 
  	 , '' [SettlementPercentage] 
  	 , '' [RollUpInvoiceByService] 
  	 , '' [RollUpInvoiceBySite] 
  	 , '' [CustomerInvoiceNumberRequired] 
  	 , '' [IsOrderNumberRequired] 
  	 , '' [SummaryInvoice] 
  	 , '' [RebateBillingOption] 
  	 , '' [RebateInvoiceCycle] 
  	 , '' [RebateInvoiceFrequencyTerm] 
  	 , '' [InvoicesSentElectronically] 
  	 , '' [OneInvPerPO] 
  	 , '' [OneInvPerDept] 
  	 , '' [OneInvPerJob] 
  	 , '' [ContractStatus] 
  	 , '' [ExcludeFromStatementRun] 
  	 , '' [CustomerType] 
  	 , isnull(a.C_COMMENTS,'') [CustomerNotes]  
  	 , '' [CustomerTemplate] 
  	 , '' [CustomerGroup] 
  	 , '' [FederalId] 
  	 , '' [MarketingSource] 
  	 , cast(isnull(a.c_quote, getdate()) as date) [StartDate] 
  	 , a.C_ID_ALPHA [AltSearchReference] 
  	 , '' [BusinessSector] 
  	 , '' [APAccountCode] 
  	 , cr.NAME [SalesRep] 
  	 , '' [CSR] 
  	 , '' [PaymentHandlingCode] 
  	 , '' [RebatePaymentType] 
  	 , '' [RebatePaymentTerms] 
  	 , '' [SalesTerritory]
  	 , ma.ARAccount [MasterARAccountCode]
  	 , a.C_ID_ALPHA DMAccount
  	 ,null  parent
  	 ,a.id Child_id
  	 ,null Account_id
  	 --select len(cust.C_COMMENTS)
  	 --select count(1)
  	 from Child a
 	 inner join ConversionData.dbo.cust cu on cu.c_id = a.C_ID
  	 left join Company co on co.id = a.Company_id
  	 inner join LocationInfo li on li.id = a.LocationInfo_id
  	 left join BillingCycle bc on bc.id = a.BillingCycle_id
  	 left join Terms te on te.id = a.Terms_id
  	 inner join Status st on st.id = a.status_id
  	 left join BillingGroup bg on bg.id = a.BillingGroup_id
  	 left join CustomerRep cr on cr.id = a.CREP1_id
  	 inner join MasterAccount ma on ma.id = a.MasterAccount_id
 	 --left join (select distinct c_id from ActiveAuto) aa on aa.C_ID = cu.C_ID
 	 where a.MigrationStatus = 'Active'


-- select *
-- from Customers c
-- inner join ConversionData.dbo.CUST cu on cu.c_id = c.c_id 

-- select c.*
-- from ConversionData.dbo.CUST c
-- left join Customers cu on cu.c_id = c.c_id 
-- where cu.c_id is null

-- select *
-- from Customers c
-- inner join ConversionData.dbo.CUST cu on cu.c_id = c.c_id 

-- select c.*
-- from ConversionData.dbo.CUST c
-- left join Customers cu on cu.c_id = c.c_id 
-- where cu.c_id is null

-- select *
-- from T_Customers
