<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!-- ============================================================================================= -->

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- ============================================================================================= -->
	<!-- === Generate a table that represents a search on the remote node -->
	<!-- ============================================================================================= -->

	<xsl:template match="/root/search">
		<div id="{@id}">
			<p/>
			<xsl:apply-templates select="." mode="data"/>
		</div>
	</xsl:template>

	<!-- ============================================================================================= -->
		
	<xsl:template match="*" mode="data">
		<table>
			<!-- Remove button - - - - - - - - - - - - - - - - - - - - - - - - - -->
			
			<tr>
				<td>
					<img id="{@id}.oai.remove" style="cursor:pointer;" src="{/root/env/url}/images/fileclose.png" />					
				</td>
				<td class="padded" bgcolor="#D0E0FF" colspan="4"><b><xsl:value-of select="/root/strings/criteria"/></b></td>
			</tr>
			
			<!-- From field - - - - - - - - - - - - - - - - - - - - - - - - - -->
			
			<tr>
				<td/>
				<td class="padded"><xsl:value-of select="/root/strings/from"/></td>
				<td class="padded"><input id="{@id}.oai.from" class="content" type="text" value="{from}" size="12" readonly="on"/></td>
				<td>
					<img id="{@id}.oai.from.set" style="cursor:pointer;" src="{/root/env/url}/scripts/calendar/img.gif" />
				</td>
				<td valign="bottom">
					<img id="{@id}.oai.from.clear" style="cursor:pointer;" src="{/root/env/url}/images/clear_left.png"/>
				</td>
			</tr>

			<!-- Until field - - - - - - - - - - - - - - - - - - - - - - - - - -->
			
			<tr>
				<td/>
				<td class="padded"><xsl:value-of select="/root/strings/until"/></td>
				<td class="padded"><input id="{@id}.oai.until" class="content" type="text" value="{until}" size="12" readonly="on"/></td>
				<td>
					<img id="{@id}.oai.until.set" style="cursor:pointer;" src="{/root/env/url}/scripts/calendar/img.gif" />
				</td>
				<td>
					<img id="{@id}.oai.until.clear" style="cursor:pointer;" valign="middle" src="{/root/env/url}/images/clear_left.png"/>
				</td>
			</tr>

			<!-- Set dropdown - - - - - - - - - - - - - - - - - - - - - - - - - -->
			
			<tr>
				<td/>
				<td class="padded"><xsl:value-of select="/root/strings/set"/></td>
				<td class="padded" colspan="3">
					<select id="{@id}.oai.set" class="content" size="1"/>
				</td>
			</tr>

			<!-- Prefix dropdown - - - - - - - - - - - - - - - - - - - - - - - - - -->
			
			<tr>
				<td/>
				<td class="padded"><xsl:value-of select="/root/strings/prefix"/></td>
				<td class="padded" colspan="3">
					<select id="{@id}.oai.prefix" class="content" size="1"/>
				</td>
			</tr>
			
			<!-- Stylesheet dropdown - - - - - - - - - - - - - - - - - - - - - - - -->
			
			<!-- COMMENTED OUT : we need to find a better management of metadata conversion -->
			
			<tr>
				<td/>
				<td class="padded"><!--xsl:value-of select="/root/strings/stylesheet"/--></td>
				<td class="padded" colspan="3">
					<select id="{@id}.oai.stylesheet" class="content" size="1" style="display:none">
						<option value=""/>
					</select>
				</td>
			</tr>
		</table>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template match="strings"/>
	<xsl:template match="env"/>

	<!-- ============================================================================================= -->

</xsl:stylesheet>
