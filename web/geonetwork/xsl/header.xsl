<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!--
	main html header
	-->
	<xsl:template name="header">
		
		<!-- title -->
		<title><xsl:value-of select="/root/gui/strings/title"/></title>
		<link href="{/root/gui/url}/favicon.ico" rel="shortcut icon" type="image/x-icon" />
		<link href="{/root/gui/url}/favicon.ico" rel="icon" type="image/x-icon" />

		<!-- stylesheet -->
		<link rel="stylesheet" type="text/css" href="{/root/gui/url}/geonetwork.css"/>
		
		<!-- Recent updates newsfeed -->
		<link href="{/root/gui/locService}/rss.latest" rel="alternate" type="application/rss+xml" title="GeoNetwork opensource | {/root/gui/strings/recentAdditions}" />
		<link href="{/root/gui/locService}/portal.opensearch" rel="search" type="application/opensearchdescription+xml">

		<xsl:attribute name="title">GeoNetwork|<xsl:value-of select="//site/organization"/>|<xsl:value-of select="//site/name"/></xsl:attribute>

		</link>

		
		<!-- meta tags -->
		<xsl:copy-of select="/root/gui/strings/header_meta/meta"/>
		
		<META HTTP-EQUIV="Pragma"  CONTENT="no-cache"/>
		<META HTTP-EQUIV="Expires" CONTENT="-1"/>

		<!-- javascript -->
		<script type="text/javascript" src="{/root/gui/url}/scripts/prototype.js"/>
		<script type="text/javascript" src="{/root/gui/url}/scripts/geonetwork.js"/>
		<script type="text/javascript" src="{/root/gui/url}/scripts/form_check.js"/>
	
		<script language="JavaScript" type="text/javascript">
			var Env = new Object();

			Env.locService= "<xsl:value-of select="/root/gui/locService"/>";
			Env.locUrl    = "<xsl:value-of select="/root/gui/locUrl"/>";
			Env.url       = "<xsl:value-of select="/root/gui/url"/>";
			Env.lang      = "<xsl:value-of select="/root/gui/language"/>";
		</script>

	</xsl:template>
	
</xsl:stylesheet>
