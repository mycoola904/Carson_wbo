use ConversionData



select max(cu.C_ID_ALPHA) DMAccount, count(1) [#Used]
, co.SVC_CODE_ALPHA [ServiceCode], co.Descript [ServiceDescription], cc.Description ServiceCategory
,co.LINK_STAT, '' size, '' unit, '' action, '' frequency, ''ServiceMap
, '' container, '' type
from auto a
inner join cust cu on cu.c_id = a.C_ID
inner join CodeMaster co on co.SVC_CODE = a.SVC_CODE
inner join CodeCategory cc on cc.CodeCategoryID = co.CODECATEGORYID
left join ModMigration.dbo.ServiceCodeDetail sd on sd.ServiceCode = co.SVC_CODE_ALPHA
where sd.id is null
group by co.SVC_CODE_ALPHA, co.Descript, cc.Description, co.LINK_STAT
order by co.SVC_CODE_ALPHA