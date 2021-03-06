package org.wfp.vam.intermap.services.map;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import org.jdom.Element;
import org.wfp.vam.intermap.kernel.map.MapMerger;
import org.wfp.vam.intermap.kernel.map.mapServices.BoundingBox;
import org.wfp.vam.intermap.util.Util;

//=============================================================================

/** main.result service. shows search results
  */

public class Move implements Service
{
	public void init(String appPath, ServiceConfig config) throws Exception {}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		int deltax = Integer.parseInt(params.getChildText("deltax"));
		int deltay = Integer.parseInt(params.getChildText("deltay"));

		// Get the current image size from request OR from the user session
//		int width  = Util.parseInt(params.getChildText("width"), MapUtil.getImageWidth(context));
//		int height = Util.parseInt(params.getChildText("height"), MapUtil.getImageHeight(context));
		// Get the current image size from request
		int width  = Integer.parseInt(params.getChildText("width"));
		int height = Integer.parseInt(params.getChildText("height"));
		
		MapMerger mm = MapUtil.getMapMerger(context);

		BoundingBox bb = Util.parseBoundingBox(params);
		if(bb == null)
			bb = mm.getBoundingBox();

		// zoom in
//		System.out.println(deltax + " ----- " + deltay); // DEBUG
		bb = MapUtil.move(bb, deltax, deltay, width, height);
		mm.setBoundingBox(bb);

		// Merge the images now

		String imagename = mm.merge(width, height);
		String url = MapUtil.getTempUrl() + "/" + imagename;

		return new Element("response")
			.addContent(new Element("imgUrl").setText(url))
			.addContent(new Element("scale").setText(mm.getDistScale()))
			.addContent(mm.getBoundingBox().toElement())
			.addContent(new Element("width").setText(""+width))
			.addContent(new Element("height").setText(""+height));
	}

}

//=============================================================================

