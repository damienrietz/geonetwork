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

package org.fao.geonet.csw.common.requests;

import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import org.fao.geonet.csw.common.Csw;
import org.fao.geonet.csw.common.exceptions.CatalogException;
import org.fao.geonet.csw.common.exceptions.NoApplicableCodeEx;
import org.fao.geonet.csw.common.util.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpState;
import org.apache.commons.httpclient.Cookie;
import org.apache.commons.httpclient.cookie.CookiePolicy;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.HttpMethodBase;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.NameValuePair;
import java.util.ArrayList;
import java.net.URLEncoder;
import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.jdom.Document;
import java.io.UnsupportedEncodingException;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.Header;
import java.net.URL;
import org.apache.commons.httpclient.Credentials;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;

//=============================================================================

public abstract class CatalogRequest
{
	public enum Method { GET, POST }

	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	public CatalogRequest() { this(null); }

	//---------------------------------------------------------------------------

	public CatalogRequest(String host) { this(host, 80); }

	//---------------------------------------------------------------------------

	public CatalogRequest(String host, int port)
	{
		this.host    = host;
		this.port    = port;

		setMethod(Method.POST);
		state.addCookie(cookie);
		client.setState(state);
		client.getParams().setCookiePolicy(CookiePolicy.BROWSER_COMPATIBILITY);
	}

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------

	public String getHost()         { return host;         }
	public int    getPort()         { return port;         }
	public String getAddress()      { return address;      }
	public Method getMethod()       { return method;       }
	public String getSentData()     { return sentData;     }
	public String getReceivedData() { return receivedData; }

	//---------------------------------------------------------------------------

	public void setHost(String host)
	{
		this.host = host;
	}

	//---------------------------------------------------------------------------

	public void setPort(int port)
	{
		this.port = port;
	}

	//---------------------------------------------------------------------------

	public void setAddress(String address)
	{
		this.address = address;
	}

	//---------------------------------------------------------------------------

	public void setUrl(URL url)
	{
		this.host    = url.getHost();
		this.port    = url.getPort();
		this.address = url.getPath();

		if (this.port == -1)
			this.port = 80;
	}

	//---------------------------------------------------------------------------

	public void setMethod(Method m)
	{
		method = m;
	}

	//---------------------------------------------------------------------------

	public void setLoginAddress(String address)
	{
		loginAddr = address;
	}

	//---------------------------------------------------------------------------

	public void setUseSOAP(boolean yesno)
	{
		useSOAP = yesno;
	}

	//---------------------------------------------------------------------------

	public boolean login(String username, String password) throws IOException, CatalogException,
																				  JDOMException, Exception

	{
		Element request = new Element("request")
						.addContent(new Element("username").setText(username))
						.addContent(new Element("password").setText(password));

		PostMethod post = new PostMethod();

		postData = Xml.getString(new Document(request));

		post.setRequestEntity(new StringRequestEntity(postData, "application/xml", "UTF8"));
//		post.setFollowRedirects(true);
		post.setPath(loginAddr);

		Element response = doExecute(post);

		if (Csw.NAMESPACE_ENV.getURI().equals(response.getNamespace().getURI()))
			response = soapUnembed(response);

		return response.getName().equals("ok");
	}

	//---------------------------------------------------------------------------

	public Element execute() throws IOException, CatalogException, JDOMException, Exception
	{
		HttpMethodBase httpMethod = setupHttpMethod();

		Element response = doExecute(httpMethod);

		if (useSOAP)
			response = soapUnembed(response);

		//--- raises an exception if the case
		CatalogException.unmarshal(response);

		return response;
	}

	//---------------------------------------------------------------------------

	public void setCredentials(String username, String password)
	{
		this.useAuthent = true;
		this.username   = username;
		this.password   = password;
	}

	//---------------------------------------------------------------------------
	//---
	//--- Abstract methods
	//---
	//---------------------------------------------------------------------------

	protected abstract String  getRequestName();
	protected abstract void    setupGetParams();
	protected abstract Element getPostParams ();

	//---------------------------------------------------------------------------
	//---
	//--- Protected methods
	//---
	//---------------------------------------------------------------------------

	//---------------------------------------------------------------------------
	//--- GET fill methods
	//---------------------------------------------------------------------------

	protected void fill(String param, Iterable iter)
	{
		fill(param, iter, "");
	}

	//---------------------------------------------------------------------------

	protected void fill(String param, Iterable iter, String prefix)
	{
		Iterator i = iter.iterator();

		if (!i.hasNext())
			return;

		StringBuffer sb = new StringBuffer();

		while(i.hasNext())
		{
			sb.append(prefix+i.next());

			if (i.hasNext())
				sb.append(",");
		}

		addParam(param, sb.toString());
	}

	//---------------------------------------------------------------------------
	//--- POST fill methods
	//---------------------------------------------------------------------------

	protected void fill(Element root, String parentName, String childName,
							  Iterable iter, Namespace ns)
	{
		Iterator i = iter.iterator();

		if (!i.hasNext())
			return;

		Element parent = new Element(parentName, ns);

		while(i.hasNext())
		{
			Element el = new Element(childName, ns);
			el.setText(i.next().toString());

			parent.addContent(el);
		}

		root.addContent(parent);
	}

	//---------------------------------------------------------------------------

	protected void fill(Element root, String childName, Iterable iter)
	{
		Iterator i = iter.iterator();

		if (!i.hasNext())
			return;

		while(i.hasNext())
		{
			Element el = new Element(childName, root.getNamespace());
			el.setText(i.next().toString());

			root.addContent(el);
		}
	}

	//---------------------------------------------------------------------------
	//--- Attribute facilities
	//---------------------------------------------------------------------------

	protected void setAttrib(Element el, String name, Object value)
	{
		setAttrib(el, name, value, "");
	}

	//---------------------------------------------------------------------------

	protected void setAttrib(Element el, String name, Object value, String prefix)
	{
		if (value != null)
			el.setAttribute(name, prefix + value.toString());
	}

	//---------------------------------------------------------------------------

	protected void setAttrib(Element el, String name, Iterable iter, String prefix)
	{
		Iterator i = iter.iterator();

		if (!i.hasNext())
			return;

		StringBuffer sb = new StringBuffer();

		while(i.hasNext())
		{
			sb.append(prefix + i.next().toString());

			if (i.hasNext())
				sb.append(" ");
		}

		el.setAttribute(name, sb.toString());
	}

	//--------------------------------------------------------------------------
	//--- Parameters facilities (POST)
	//---------------------------------------------------------------------------

	protected void addParam(Element root, String name, Object value)
	{
		if (value != null)
			root.addContent(new Element(name, Csw.NAMESPACE_CSW).setText(value.toString()));
	}

	//---------------------------------------------------------------------------
	//--- Parameters facilities (GET)
	//--------------------------------------------------------------------------

	protected void addParam(String name, Object value)
	{
		addParam(name, value, "");
	}

	//--------------------------------------------------------------------------

	protected void addParam(String name, Object value, String prefix)
	{
		if (value != null)
			alGetParams.add(new NameValuePair(name, prefix+value.toString()));
	}

	//---------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//---------------------------------------------------------------------------

	private Element doExecute(HttpMethodBase httpMethod) throws IOException, JDOMException
	{
		client.getHostConfiguration().setHost(host, port, "http");

		byte[] data = null;

		try
		{
			client.executeMethod(httpMethod);
			data = httpMethod.getResponseBody();

			return Xml.loadStream(new ByteArrayInputStream(data));
		}
		finally
		{
			httpMethod.releaseConnection();

			setupSentData(httpMethod);
			setupReceivedData(httpMethod, data);
		}
	}

	//---------------------------------------------------------------------------

	private HttpMethodBase setupHttpMethod() throws UnsupportedEncodingException
	{
		HttpMethodBase httpMethod;

		if (method == Method.GET)
		{
			alGetParams = new ArrayList<NameValuePair>();
			setupGetParams();
			httpMethod = new GetMethod();
			httpMethod.setQueryString(alGetParams.toArray(new NameValuePair[1]));

			if (useSOAP)
				httpMethod.addRequestHeader("Accept", "application/soap+xml");
		}
		else
		{
			Element    params = getPostParams();
			PostMethod post   = new PostMethod();

			if (!useSOAP)
			{
				postData = Xml.getString(new Document(params));
				post.setRequestEntity(new StringRequestEntity(postData, "application/xml", "UTF8"));
			}
			else
			{
				postData = Xml.getString(new Document(soapEmbed(params)));
				post.setRequestEntity(new StringRequestEntity(postData, "application/soap+xml", "UTF8"));
			}

			httpMethod = post;
		}

//		httpMethod.setFollowRedirects(true);
		httpMethod.setPath(address);

		if (useAuthent)
		{
			Credentials cred = new UsernamePasswordCredentials(username, password);
			AuthScope   scope= new AuthScope(AuthScope.ANY_HOST, AuthScope.ANY_PORT, AuthScope.ANY_REALM);

			client.getState().setCredentials(scope, cred);
			httpMethod.setDoAuthentication(true);
		}

		return httpMethod;
	}

	//---------------------------------------------------------------------------

	private void setupSentData(HttpMethodBase httpMethod)
	{
		sentData = httpMethod.getName() +" "+ httpMethod.getPath();

		if (httpMethod.getQueryString() != null)
			sentData += "?"+ httpMethod.getQueryString();

		sentData += "\r\n";

		for (Header h : httpMethod.getRequestHeaders())
			sentData += h;

		sentData += "\r\n";

		if (httpMethod instanceof PostMethod)
			sentData += postData;
	}

	//---------------------------------------------------------------------------

	private void setupReceivedData(HttpMethodBase httpMethod, byte[] response)
	{
		receivedData = httpMethod.getStatusText() +"\r\r";

		for (Header h : httpMethod.getResponseHeaders())
			receivedData += h;

		receivedData += "\r\n";

		try
		{
			if (response != null)
				receivedData += new String(response, "UTF8");
		}
		catch (UnsupportedEncodingException e) {}
	}

	//---------------------------------------------------------------------------

	private Element soapEmbed(Element elem)
	{
		Element envl = new Element("Envelope", Csw.NAMESPACE_ENV);
		Element body = new Element("Body",     Csw.NAMESPACE_ENV);

		envl.addContent(body);
		body.addContent(elem);

		return envl;
	}

	//---------------------------------------------------------------------------

	private Element soapUnembed(Element envelope) throws Exception
	{
		Namespace ns   = envelope.getNamespace();
		Element   body = envelope.getChild("Body", ns);

		if (body == null)
			throw new Exception("Bad SOAP response");

		List list = body.getChildren();

		if (list.size() == 0)
			throw new Exception("Bas SOAP response");

		return (Element) list.get(0);
	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	private String  host;
	private int     port;
	private String  address;
	private String  loginAddr;
	private Method  method;
	private boolean useSOAP;
	private boolean useAuthent;
	private String  username;
	private String  password;

	private HttpClient client = new HttpClient();
	private HttpState  state  = new HttpState();
	private Cookie     cookie = new Cookie();

	private ArrayList<NameValuePair> alGetParams;

	//--- transient vars

	private String sentData;
	private String receivedData;
	private String postData;
}

//=============================================================================

