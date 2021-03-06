package org.wfp.vam.intermap.services.map.layers;

import org.jdom.*;

import jeeves.interfaces.*;
import jeeves.server.*;
import jeeves.server.context.*;

import org.wfp.vam.intermap.kernel.map.*;
import org.wfp.vam.intermap.services.map.MapUtil;
import org.wfp.vam.intermap.Constants;

//=============================================================================

/** main.result service. shows search results
  */

public class ToggleVisibility implements Service
{
	public void init(String appPath, ServiceConfig config) throws Exception {}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		int layerId = Integer.parseInt(params.getChildText(Constants.MAP_SERVICE_ID));
		
		MapMerger mm = MapUtil.getMapMerger(context);
		
		boolean visibility = mm.toggleVisibility(layerId);
		
		Element response = new Element("response");
		response.addContent(new Element("visible").setText("" + visibility));
		
		return response;
	}
	
}

//=============================================================================

