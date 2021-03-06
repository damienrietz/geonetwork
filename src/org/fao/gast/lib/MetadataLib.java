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

package org.fao.gast.lib;

import java.io.File;
import java.util.List;
import jeeves.resources.dbms.Dbms;
import jeeves.utils.Xml;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.XmlSerializer;
import org.fao.geonet.kernel.search.SearchManager;
import org.jdom.Element;

//=============================================================================

public class MetadataLib
{
	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	public MetadataLib(String appPath) throws Exception
	{
		this.appPath = appPath;

//		searchMan = new SearchManager(appPath +"/web/geonetwork/", Lib.config.getLuceneDir());
	}

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------

	public Element getMetadata(Dbms dbms, String id) throws Exception
	{
		return XmlSerializer.select(dbms, "Metadata", id);
	}

	//---------------------------------------------------------------------------

	public boolean canConvert(String fromSchema, String toSchema)
	{
		String format = fromSchema +"-to-"+ toSchema;
		String path   = appPath +"/web/geonetwork/conversion/"+format+"/main.xsl";

		return new File(path).exists();
	}

	//---------------------------------------------------------------------------

	public Element convert(Element md, String fromSchema, String toSchema) throws Exception
	{
		if (!canConvert(fromSchema, toSchema))
			throw new Exception("Cannot convert to schema :"+ toSchema);

		String format = fromSchema +"-to-"+ toSchema;
		String path   = appPath +"/web/geonetwork/conversion/"+format;

		Element result   = Xml.transform(md, path +"/main.xsl");
		Element unmapped = Xml.transform(md, path +"/unmapped.xsl");

		Element metadata = new Element("metadata")
			.addContent(result);

		return new Element("result")
			.addContent(metadata)
			.addContent(unmapped);
	}

	//---------------------------------------------------------------------------
	/** Transactional */

	public void sync(Dbms dbms) throws Exception
	{
		try
		{
			List list = dbms.select("SELECT * FROM Metadata WHERE isTemplate='n'").getChildren();
			dbms.commit();

			String siteURL = Lib.site.getSiteURL(dbms);

			for(int i=0; i<list.size(); i++)
			{
				Element record = (Element) list.get(i);

				String id     = record.getChildText("id");
				String schema = record.getChildText("schemaid");
				String data   = record.getChildText("data");
				String uuid   = record.getChildText("uuid");
				String date   = record.getChildText("createdate");

				Element md = updateFixedInfo(id, Xml.loadString(data, false),
													  uuid, date, schema, siteURL);

				XmlSerializer.update(dbms, id, md, date);
				dbms.commit();
			}
		}
		catch(Exception e)
		{
			dbms.abort();
			throw e;
		}
	}

	//--------------------------------------------------------------------------

	public Element updateFixedInfo(String id, Element md, String uuid, String date,
											  String schema, String siteURL) throws Exception
	{
		md.detach();

		//--- setup environment

		Element env = new Element("env");

		env.addContent(new Element("id")        .setText(id));
		env.addContent(new Element("uuid")      .setText(uuid));
		env.addContent(new Element("changeDate").setText(date));
		env.addContent(new Element("siteURL")   .setText(siteURL));

		//--- setup root element

		Element root = new Element("root");

		root.addContent(md);
		root.addContent(env);

		//--- do an XSL  transformation

		String styleSheet = appPath +"/web/geonetwork/xml/schemas/"+schema+"/"+ Geonet.File.UPDATE_FIXED_INFO;

		return Xml.transform(root, styleSheet);
	}

	//---------------------------------------------------------------------------

//	public void index(Dbms dbms, String id) throws Exception
//	{
//		DataManager.indexMetadata(dbms, id, searchMan);
//	}

	//---------------------------------------------------------------------------

	public void clearIndexes() throws Exception
	{
		File dir = new File(appPath +"/web/geonetwork/"+ Lib.config.getLuceneDir());
		Lib.io.cleanDir(dir);
	}

	//--------------------------------------------------------------------------

	public Element getThumbnails(Dbms dbms, String schema, String id) throws Exception
	{
		Element md = XmlSerializer.select(dbms, "Metadata", id);

		if (md == null)
			return null;

		//--- do an XSL  transformation

		String styleSheet = appPath +"/web/geonetwork/xml/schemas/"+ schema +"/"+ Geonet.File.EXTRACT_THUMBNAILS;

		return Xml.transform(md, styleSheet);
	}

	//--------------------------------------------------------------------------

	public String getDataDir()
	{
		String dataDir = Lib.config.getHandlerProp(Geonet.Config.DATA_DIR);

		if (!new File(dataDir).isAbsolute())
			dataDir = appPath +"/web/geonetwork/"+ dataDir;

		return dataDir;
	}

	//--------------------------------------------------------------------------

	public String getDir(int id, String access)
	{
		String group    = pad(id / 100, 3);
		String groupDir = group +"00-"+ group +"99";
		String subDir   = (access != null && access.equals(Params.Access.PUBLIC))
									? Params.Access.PUBLIC
									: Params.Access.PRIVATE;

		return getDataDir() +"/"+ groupDir +"/"+ id +"/"+ subDir +"/";
	}

	//--------------------------------------------------------------------------

	public Element setUUID(String schema, String uuid, Element md) throws Exception
	{
		//--- setup environment

		Element env = new Element("env");
		env.addContent(new Element("uuid").setText(uuid));

		//--- setup root element

		Element root = new Element("root");
		root.addContent(md);
		root.addContent(env);

		//--- do an XSL  transformation

		String styleSheet = appPath +"/web/geonetwork/xml/schemas/"+ schema +"/"+ Geonet.File.SET_UUID;

		return Xml.transform(root, styleSheet);
	}

	//-----------------------------------------------------------------------------

	public void insertMetadata(Dbms dbms, String schema, Element md, int id, String source,
										String createDate, String changeDate, String uuid, int owner,
										String groupOwner, String template, String title) throws Exception
	{
		//--- force namespace prefix for iso19139 metadata
		DataManager.setNamespacePrefix(md);

		XmlSerializer.insert(dbms, schema, md, id, source, uuid, createDate,
											 changeDate, template, title, owner, groupOwner);
	}

	//-----------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//-----------------------------------------------------------------------------

	private String pad(int group, int lenght)
	{
		String text = Integer.toString(group);

		while(text.length() < lenght)
			text = "0" + text;

		return text;
	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	private String appPath;

	private SearchManager searchMan;
}

//=============================================================================

