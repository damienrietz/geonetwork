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

package org.fao.geonet.kernel.mef;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import jeeves.utils.BinaryFile;
import jeeves.utils.Log;
import jeeves.utils.Xml;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.util.ISODate;
import org.jdom.Element;

import static org.fao.geonet.kernel.mef.MEFConstants.*;

//=============================================================================

class Importer
{
	//--------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//--------------------------------------------------------------------------

	public static int doImport(final ServiceContext context, File mefFile) throws Exception
	{
		final GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		final DataManager   dm = gc.getDataManager();

		final Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

		final String  id[] = { ""   };
		final Element md[] = { null };

		//--- import metadata from MEF file

		MEFLib.visit(mefFile, new MEFVisitor()
		{
			public void handleMetadata(Element metadata) throws Exception
			{
				Log.debug(Geonet.MEF, "Collecting metadata:\n"+ Xml.getString(metadata));
				md[0] = metadata;
			}

			//--------------------------------------------------------------------

			public void handleInfo(Element info) throws Exception
			{
				Element general = info.getChild("general");

				String uuid       = general.getChildText("uuid");
				String createDate = general.getChildText("createDate");
				String changeDate = general.getChildText("changeDate");
				String source     = general.getChildText("siteId");
				String sourceName = general.getChildText("siteName");
				String schema     = general.getChildText("schema");
				String isTemplate = general.getChildText("isTemplate").equals("true") ? "y" : "n";

				boolean dcore  = schema.equals("dublin-core");
				boolean fgdc   = schema.equals("fgdc-std");
				boolean iso115 = schema.equals("iso19115");
				boolean iso139 = schema.equals("iso19139");

				if (!dcore && !fgdc && !iso115 && !iso139)
					throw new Exception("Unknown schema format : "+schema);

				if (uuid == null)
				{
					uuid   = UUID.randomUUID().toString();
					source = null;

					//--- set uuid inside metadata
					md[0] = dm.setUUID(schema, uuid, md[0]);
				}
				else
				{
					if (sourceName == null)
						sourceName = "???";

					Lib.sources.update(dbms, source, sourceName, true);
				}

				Log.debug(Geonet.MEF, "Adding metadata with uuid="+ uuid);

				id[0] = dm.insertMetadataExt(dbms, schema, md[0], context.getSerialFactory(),
													  source, createDate, changeDate, uuid,
													  context.getUserSession().getUserIdAsInt(), null);

				int iId = Integer.parseInt(id[0]);

				dm.setTemplate(dbms, iId, isTemplate, null);
				dm.setHarvested(dbms, iId, null);

				String pubDir = Lib.resource.getDir(context, "public",  id[0]);
				String priDir = Lib.resource.getDir(context, "private", id[0]);

				new File(pubDir).mkdirs();
				new File(priDir).mkdirs();

				addCategories(dm, dbms, id[0], info.getChild("categories"));
				addPrivileges(dm, dbms, id[0], info.getChild("privileges"));
				dm.indexMetadata(dbms, id[0]);
			}

			//--------------------------------------------------------------------

			public void handlePublicFile(String file, String changeDate,
												  InputStream is) throws IOException
			{
				Log.debug(Geonet.MEF, "Adding public file with name="+ file);
				saveFile(context, id[0], "public", file, changeDate, is);
			}

			//--------------------------------------------------------------------

			public void handlePrivateFile(String file, String changeDate,
													InputStream is) throws IOException
			{
				Log.debug(Geonet.MEF, "Adding private file with name="+ file);
				saveFile(context, id[0], "private", file, changeDate, is);
			}
		});

		return Integer.parseInt(id[0]);
	}

	//--------------------------------------------------------------------------

	private static void saveFile(ServiceContext context, String id, String access, String file,
										  String changeDate, InputStream is) throws IOException
	{
		String dir = Lib.resource.getDir(context, access, id);

		File outFile = new File(dir, file);
		FileOutputStream os = new FileOutputStream(outFile);
		BinaryFile.copy(is, os, false, true);

		outFile.setLastModified(new ISODate(changeDate).getSeconds() * 1000);
	}

	//--------------------------------------------------------------------------
	//--- Categories
	//--------------------------------------------------------------------------

	private static void addCategories(DataManager dm, Dbms dbms, String id,
												 Element categ) throws Exception
	{
		List locCats = dbms.select("SELECT id,name FROM Categories").getChildren();
		List list    = categ.getChildren("category");

		for(Iterator j=list.iterator(); j.hasNext();)
		{
			String catName = ((Element) j.next()).getAttributeValue("name");
			String catId   = mapLocalEntity(locCats, catName);

			if (catId == null)
				Log.debug(Geonet.MEF, " - Skipping inesistent category : "+ catName);
			else
			{
				//--- metadata category exists locally

				Log.debug(Geonet.MEF, " - Setting category : "+ catName);
				dm.setCategory(dbms, id, catId);
			}
		}
	}

	//--------------------------------------------------------------------------
	//--- Privileges
	//--------------------------------------------------------------------------

	private static void addPrivileges(DataManager dm, Dbms dbms, String id,
												 Element privil) throws Exception
	{
		List locGrps = dbms.select("SELECT id,name FROM Groups").getChildren();
		List list    = privil.getChildren("group");

		for (Object g : list)
		{
			Element group   = (Element) g;
			String  grpName = group.getAttributeValue("name");
			String  grpId   = mapLocalEntity(locGrps, grpName);

			if (grpId == null)
				Log.debug(Geonet.MEF, " - Skipping inesistent group : "+ grpName);
			else
			{
				//--- metadata group exists locally

				Log.debug(Geonet.MEF, " - Setting privileges for group : "+ grpName);
				addOperations(dm, dbms, group, id, grpId);
			}
		}
	}

	//--------------------------------------------------------------------------

	private static void addOperations(DataManager dm, Dbms dbms, Element group,
												 String id, String grpId) throws Exception
	{
		List opers = group.getChildren("operation");

		for (int j=0; j<opers.size(); j++)
		{
			Element oper   = (Element) opers.get(j);
			String  opName = oper.getAttributeValue("name");

			int opId = dm.getAccessManager().getPrivilegeId(opName);

			if (opId == -1)
				Log.debug(Geonet.MEF, "   Skipping --> "+ opName);
			else
			{
				//--- operation exists locally

				Log.debug(Geonet.MEF, "   Adding --> "+ opName);
				dm.setOperation(dbms, id, grpId, opId +"");
			}
		}
	}

	//--------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//--------------------------------------------------------------------------

	private static String mapLocalEntity(List entities, String name)
	{
		for (Object e : entities)
		{
			Element entity = (Element) e;

			if (entity.getChildText("name").equals(name))
				return entity.getChildText("id");
		}

		return null;
	}
}

//=============================================================================

