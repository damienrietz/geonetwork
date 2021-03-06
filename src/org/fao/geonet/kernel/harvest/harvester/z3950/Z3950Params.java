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

package org.fao.geonet.kernel.harvest.harvester.z3950;

import jeeves.exceptions.BadInputEx;
import jeeves.utils.Util;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.harvest.harvester.AbstractParams;
import org.jdom.Element;

//=============================================================================

public class Z3950Params extends AbstractParams
{
	//--------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//--------------------------------------------------------------------------

	public Z3950Params(DataManager dm)
	{
		super(dm);
	}

	//---------------------------------------------------------------------------
	//---
	//--- Create : called when a new entry must be added. Reads values from the
	//---          provided entry, providing default values
	//---
	//---------------------------------------------------------------------------

	public void create(Element node) throws BadInputEx
	{
		super.create(node);

		Element site     = node.getChild("site");
//		Element searches = node.getChild("searches");
//
//		capabUrl = Util.getParam(site, "capabilitiesUrl", "");
		icon     = Util.getParam(site, "icon",            "default.gif");
//
//		addSearches(searches);
	}

	//---------------------------------------------------------------------------
	//---
	//--- Update : called when an entry has changed and variables must be updated
	//---
	//---------------------------------------------------------------------------

	public void update(Element node) throws BadInputEx
	{
		super.update(node);

		Element site     = node.getChild("site");
//		Element searches = node.getChild("searches");
//
//		capabUrl = Util.getParam(site, "capabilitiesUrl", capabUrl);
		icon     = Util.getParam(site, "icon",            icon);
//
//		//--- if some search queries are given, we drop the previous ones and
//		//--- set these new ones
//
//		if (searches != null)
//			addSearches(searches);
	}

	//---------------------------------------------------------------------------
	//---
	//--- Other API methods
	//---
	//---------------------------------------------------------------------------

//	public Iterable<Search> getSearches() { return alSearches; }

	//---------------------------------------------------------------------------

	public Z3950Params copy()
	{
		Z3950Params copy = new Z3950Params(dm);
		copyTo(copy);

//		copy.capabUrl = capabUrl;
		copy.icon     = icon;
//
//		for (Search s : alSearches)
//			copy.alSearches.add(s.copy());

		return copy;
	}

	//---------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//---------------------------------------------------------------------------

//	private void addSearches(Element searches)
//	{
//		alSearches.clear();
//
//		if (searches == null)
//			return;
//
//		Iterator searchList = searches.getChildren("search").iterator();
//
//		while (searchList.hasNext())
//		{
//			Element search = (Element) searchList.next();
//
//			Search s = new Search();
//
//			s.freeText = Util.getParam(search, "freeText", "").trim();
//			s.title    = Util.getParam(search, "title",    "").trim();
//			s.abstrac  = Util.getParam(search, "abstract", "").trim();
//			s.subject  = Util.getParam(search, "subject",  "").trim();
//
//			alSearches.add(s);
//		}
//	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

//	public String capabUrl;
	public String icon;
//
//	private ArrayList<Search> alSearches = new ArrayList<Search>();
}

//=============================================================================

//class Search
//{
//	//---------------------------------------------------------------------------
//	//---
//	//--- API methods
//	//---
//	//---------------------------------------------------------------------------
//
//	public Search copy()
//	{
//		Search s = new Search();
//
//		s.freeText = freeText;
//		s.title    = title;
//		s.abstrac  = abstrac;
//		s.subject  = subject;
//
//		return s;
//	}
//
//	//---------------------------------------------------------------------------
//	//---
//	//--- Variables
//	//---
//	//---------------------------------------------------------------------------
//
//	public String freeText;
//	public String title;
//	public String abstrac;
//	public String subject;
//}

//=============================================================================

