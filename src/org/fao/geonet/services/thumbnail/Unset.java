//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.services.thumbnail;

import java.io.File;
import jeeves.exceptions.OperationAbortedEx;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.exceptions.ConcurrentUpdateEx;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.lib.Lib;
import org.jdom.Element;

//=============================================================================

public class Unset implements Service
{
	//--------------------------------------------------------------------------
	//---
	//--- Init
	//---
	//--------------------------------------------------------------------------

	public void init(String appPath, ServiceConfig params) throws Exception {}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		String id      = Util.getParam(params, Params.ID);
		String type    = Util.getParam(params, Params.TYPE);
		String version = Util.getParam(params, Params.VERSION);

		Lib.resource.checkEditPrivilege(context, id);

		//-----------------------------------------------------------------------
		//--- extract thumbnail filename

		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);

		DataManager dataMan = gc.getDataManager();

		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

		//--- check if the metadata has been modified from last time

		if (version != null && !dataMan.getVersion(id).equals(version))
			throw new ConcurrentUpdateEx(id);

		Element result = dataMan.getThumbnails(dbms, id);

		if (result == null)
			throw new OperationAbortedEx("Metadata not found", id);

		result = result.getChild(type);

		if (result == null)
			throw new OperationAbortedEx("Metadata has no thumbnail", id);

		String file = Lib.resource.getDir(context, Params.Access.PUBLIC, id) + result.getText();

		//-----------------------------------------------------------------------
		//--- remove thumbnail

		dataMan.unsetThumbnail(dbms, id, type.equals("small"));

		if (!new File(file).delete())
			context.error("Error while deleting thumbnail : "+file);

		//-----------------------------------------------------------------------

		Element response = new Element("a");
		response.addContent(new Element("id").setText(id));
		response.addContent(new Element("version").setText(dataMan.getNewVersion(id)));

		return response;
	}
}

//=============================================================================


