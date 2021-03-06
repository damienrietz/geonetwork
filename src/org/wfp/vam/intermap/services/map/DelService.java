package org.wfp.vam.intermap.services.map;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import org.jdom.Element;
import org.wfp.vam.intermap.Constants;
import org.wfp.vam.intermap.kernel.map.MapMerger;

/**
  */

public class DelService implements Service
{
	public void init(String appPath, ServiceConfig config) throws Exception {}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		// Get request parameters
		int id = Integer.parseInt(params.getChildText(Constants.MAP_SERVICE_ID));

		// Get the MapMerger object from the user session
		MapMerger mm = MapUtil.getMapMerger(context);

		MapUtil.setVisibleLayers(params, mm); // ETj: ???
		mm.delService(id);

		return mm.toElementSimple();
	}

}

//=============================================================================

