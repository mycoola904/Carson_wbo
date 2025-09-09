use modmigration

/****** Object:  View [dbo].[Container_View]    Script Date: 9/6/2025 9:36:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[Container_View]
		AS
 select co.Company, cm.ContainerID, cz.description size, uom.description [UnitOfMeasure], typ.Description [Type]
 , isnull(cz.Description,'') + ' ' + isnull(uom.Description,'') + ' ' + isnull(typ.Description,'') ContainerType
-- select count(1)
from ConversionData.dbo.ContainerMaster cm
inner join ConversionData.dbo.ContainerSize cz on cz.ContainerSizeID = cm.ContainerSizeID
LEFT join ContainerUOM uom on uom.ContainerUOMID = cm.ContainerUOMID
LEFT join ConversionData.dbo.ContainerType typ on typ.ContainerTypeID = cm.ContainerTypeID
left join Company co on co.CompanyID = cm.CMPY_ID
GO


/****** Object:  View [dbo].[v_ContainerType]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create VIEW [dbo].[v_ContainerType] AS
		select ContainerID, UnitOfMeasure, Size,
		case 
		when UnitOfMeasure like '%recy%' then 'Recycle'
		when UnitOfMeasure like '%card%' then 'Cardboard'
		when UnitOfMeasure like '%comp%' then 'Compost'
		else 'Other' end [Type]
		from Container_View

GO

/****** Object:  View [dbo].[v_Stoptype]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[v_Stoptype] AS
	select cc.STOPID, ct.*
	from ConversionData.dbo.CCAN cc
	inner join ConversionData.dbo.CANG cg on cg.CONGRPUID = cc.CONGRPUID
	inner join v_ContainerType ct on ct.ContainerID = cg.CONTID

	

GO

/****** Object:  View [dbo].[v_CustWithSingleServices]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[v_CustWithSingleServices] AS
select c_id
from CustomerServiceAgreementPrices
where [Action] = 'Service'
group by c_id 
having count(agreenbr) = 1	

GO

/****** Object:  View [dbo].[ContainerOnSite]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ContainerOnSite]
		AS

select  cu.C_ID_ALPHA, cu.C_ID, cv.size, cv.ContainerType
from ConversionData.dbo.CANG cg
inner join Container_View cv on cv.ContainerID = cg.CONTID
inner join ConversionData.dbo.cust cu on cu.C_ID = cg.C_ID
group by cu.C_ID_ALPHA, cu.C_ID, cv.size, cv.ContainerType
GO

/****** Object:  View [dbo].[v_RouteStops]    Script Date: 6/15/2025 4:52:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[v_RouteStops] AS
	select rx.c_id, cu.C_ID_ALPHA Account,  rx.STOPID, rt.ROUTEID, rt.ROUTENUM, rt.DESCRIPT, 
	case 
	when st.Type is null then cat.DATA
	else st.Type end [RouteType]
	from ConversionData.dbo.rxrf rx
	left join v_Stoptype st on st.STOPID = rx.STOPID
	inner join ConversionData.dbo.RTES rt on rt.ROUTEID = rx.ROUTEID
	left join ConversionData.dbo.udef cat on cat.UNIQUE_ID = rt.TYPE
	inner join ConversionData.dbo.cust cu on cu.c_id = rx.C_ID

GO

