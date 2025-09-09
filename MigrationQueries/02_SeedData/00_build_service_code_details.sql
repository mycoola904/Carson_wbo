use ConversionData



select row_number() over(order by co.svc_code_alpha) ID, max(cu.C_ID_ALPHA) DMAccount, count(1) [#Used]
, co.SVC_CODE_ALPHA [ServiceCode], co.Descript [ServiceDescription], cc.Description ServiceCategory
,co.LINK_STAT, '' size, '' unit, '' action, '' frequency, ''ServiceMap
, '' container, '' type
from auto a
inner join cust cu on cu.c_id = a.C_ID
inner join CodeMaster co on co.SVC_CODE = a.SVC_CODE
inner join CodeCategory cc on cc.CodeCategoryID = co.CODECATEGORYID
group by co.SVC_CODE_ALPHA, co.Descript, cc.Description, co.LINK_STAT
order by co.SVC_CODE_ALPHA


use ModMigration

drop table if exists ServiceCodeDetail

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