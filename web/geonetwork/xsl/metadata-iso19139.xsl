<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:geonet="http://www.fao.org/geonetwork"
	xmlns:xalan = "http://xml.apache.org/xalan">

	<!-- ============================================================================= -->
	<!-- default: in simple mode just a flat list -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="*|@*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<!-- do not show empty elements in view mode -->
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="element" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
					<xsl:with-param name="flat"   select="$currTab='simple'"/>
				</xsl:apply-templates>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:variable name="empty">
					<xsl:apply-templates mode="iso19139IsEmpty" select="."/>
				</xsl:variable>
				
				<xsl:if test="$empty!=''">
					<xsl:apply-templates mode="element" select=".">
						<xsl:with-param name="schema" select="$schema"/>
						<xsl:with-param name="edit"   select="false()"/>
						<xsl:with-param name="flat"   select="$currTab='simple'"/>
					</xsl:apply-templates>
				</xsl:if>
				
			</xsl:otherwise>
		</xsl:choose>
			
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- these elements should be boxed -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:graphicOverview"/>
	<xsl:template mode="iso19139" match="gmd:contact|gmd:identificationInfo|gmd:distributionInfo|gmd:descriptiveKeywords|gmd:spatialRepresentationInfo|gmd:pointOfContact|gmd:dataQualityInfo|gmd:referenceSystemInfo|gmd:equivalentScale|gmd:projection|gmd:ellipsoid|gmd:extent[name(..)!='gmd:EX_TemporalExtent']|gmd:geographicBox|gmd:EX_TemporalExtent|gmd:MD_Distributor">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:apply-templates mode="complexElement" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- some gco: elements and some gml elements-->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:*[gco:CharacterString|gco:Date|gco:DateTime|gco:Integer|gco:Decimal|gco:Boolean|gco:Real|gco:Measure|gco:RecordType]">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:call-template name="iso19139String">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============================================================================= -->

	<xsl:template name="iso19139String">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="rows" select="1"/>
		<xsl:param name="cols" select="50"/>

		<xsl:variable name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name"   select="name(.)"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="helpLink">
			<xsl:call-template name="getHelpLink">
				<xsl:with-param name="name"   select="name(.)"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="text">
			<xsl:for-each select="gco:*">
				<xsl:call-template name="getElementText">
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="rows"   select="$rows"/>
					<xsl:with-param name="cols"   select="$cols"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		<xsl:apply-templates mode="simpleElement" select=".">
			<xsl:with-param name="schema"   select="$schema"/>
			<xsl:with-param name="edit"     select="$edit"/>
			<xsl:with-param name="title"    select="$title"/>
			<xsl:with-param name="helpLink" select="$helpLink"/>
			<xsl:with-param name="text"     select="$text"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- codelists -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:*[*/@codeList]">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:call-template name="iso19139Codelist">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============================================================================= -->

	<xsl:template name="iso19139Codelist">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:apply-templates mode="simpleElement" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="text">
				<xsl:apply-templates mode="iso19139GetAttributeText" select="*/@codeListValue">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139GetAttributeText" match="@*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:variable name="name"     select="local-name(..)"/>
		<xsl:variable name="qname"    select="name(..)"/>
		<xsl:variable name="value"    select="../@codeListValue"/>
		<xsl:variable name="codelist" select="/root/gui/*[name(.)=$schema]/codelist[@name = $qname]"/>

		<xsl:choose>
			<xsl:when test="$edit=true()">
				<!-- codelist in edit mode -->
				<select class="md" name="_{../geonet:element/@ref}_{name(.)}" size="1">
					<option name=""/>
					<xsl:for-each select="$codelist/entry">
						<option>
							<xsl:if test="code=$value">
								<xsl:attribute name="selected"/>
							</xsl:if>
							<xsl:attribute name="value"><xsl:value-of select="code"/></xsl:attribute>
							<xsl:value-of select="label"/>
						</option>
					</xsl:for-each>
				</select>
			</xsl:when>
			<xsl:otherwise>
				<!-- codelist in view mode -->
				<xsl:value-of select="$codelist/entry[code = $value]/label"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<!--
		<xsl:call-template name="getAttributeText">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
		</xsl:call-template>
		-->
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!--
	make the following fields always not editable:
	dateStamp
	metadataStandardName
	metadataStandardVersion
	fileIdentifier
	characterSet
	-->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:dateStamp|gmd:metadataStandardName|gmd:metadataStandardVersion|gmd:fileIdentifier" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:apply-templates mode="simpleElement" select=".">
			<xsl:with-param name="schema"  select="$schema"/>
			<xsl:with-param name="edit"    select="false()"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="iso19139" match="gmd:characterSet" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:call-template name="iso19139Codelist">
			<xsl:with-param name="schema"  select="$schema"/>
			<xsl:with-param name="edit"    select="false()"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- electronicMailAddress -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:electronicMailAddress" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:call-template name="iso19139String">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="text">
						<a href="mailto:{string(.)}"><xsl:value-of select="string(.)"/></a>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- descriptiveKeywords -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:descriptiveKeywords">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="element" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="text">
						<xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
							<xsl:if test="position() &gt; 1">, </xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:if test="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue!=''">
							<xsl:text> (</xsl:text>
							<xsl:value-of select="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue"/>
							<xsl:text>)</xsl:text>
						</xsl:if>
						<xsl:text>.</xsl:text>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- place keyword; only called in edit mode (see descriptiveKeywords template) -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:keyword[following-sibling::gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='place']">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:variable name="text">
			<xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>
			<xsl:variable name="keyword" select="gco:CharacterString/text()"/>
			
			<input class="md" type="text" name="_{$ref}" value="{gco:CharacterString/text()}" size="50" />

			<!-- regions combobox -->

			<xsl:variable name="lang" select="/root/gui/language"/>

			<select name="place" size="1" onChange="document.mainForm._{$ref}.value=this.options[this.selectedIndex].text">
				<option value=""/>
				<xsl:for-each select="/root/gui/regions/record">
					<xsl:sort select="label/child::*[name() = $lang]" order="ascending"/>
					<option value="{id}">
						<xsl:if test="string(label/child::*[name() = $lang])=$keyword">
							<xsl:attribute name="selected"/>
						</xsl:if>
						<xsl:value-of select="label/child::*[name() = $lang]"/>
					</option>
				</xsl:for-each>
			</select>
		</xsl:variable>
		<xsl:apply-templates mode="simpleElement" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="true()"/>
			<xsl:with-param name="text"   select="$text"/>
		</xsl:apply-templates>
	</xsl:template>
		
	<!-- ============================================================================= -->
	<!-- EX_GeographicBoundingBox -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:EX_GeographicBoundingBox" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:variable name="geoBox">
			<xsl:apply-templates mode="iso19139GeoBox" select=".">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit"   select="$edit"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:variable name="places">
					<xsl:variable name="ref" select="geonet:element/@ref"/>
					<xsl:variable name="keyword" select="string(.)"/>
					
					<xsl:variable name="selection" select="concat(gmd:westBoundLongitude/gco:Decimal,';',gmd:eastBoundLongitude/gco:Decimal,';',gmd:southBoundLatitude/gco:Decimal,';',gmd:northBoundLatitude/gco:Decimal)"/>

					<!-- regions combobox -->

					<xsl:variable name="lang" select="/root/gui/language"/>

					<select name="place" size="1" onChange="javascript:setRegion(document.mainForm._{gmd:westBoundLongitude/gco:Decimal/geonet:element/@ref}, document.mainForm._{gmd:eastBoundLongitude/gco:Decimal/geonet:element/@ref}, document.mainForm._{gmd:southBoundLatitude/gco:Decimal/geonet:element/@ref}, document.mainForm._{gmd:northBoundLatitude/gco:Decimal/geonet:element/@ref}, this.options[this.selectedIndex].value)">
						<option value=""/>
						<xsl:for-each select="/root/gui/regions/record">
							<xsl:sort select="label/child::*[name() = $lang]" order="ascending"/>
		
							<xsl:variable name="value" select="concat(west,';',east,';',south,';',north)"/>
							<option value="{$value}">
								<xsl:if test="$value=$selection">
									<xsl:attribute name="selected"/>
								</xsl:if>
								<xsl:value-of select="label/child::*[name() = $lang]"/>
							</option>
						</xsl:for-each>
					</select>
				</xsl:variable>
				<xsl:apply-templates mode="complexElement" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="content">
						<tr>
							<td align="center">
								<xsl:copy-of select="$geoBox"/>
							</td>
							<td>
								<xsl:copy-of select="$places"/>
							</td>
						</tr>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="complexElement" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="content">
						<tr>
							<td align="center">
								<xsl:copy-of select="$geoBox"/>
							</td>
						</tr>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->

	<xsl:template mode="iso19139GeoBox" match="*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<table>
			<tr>
				<td/>
				<td class="padded" align="center">
					<xsl:apply-templates mode="iso19139VertElement" select="gmd:northBoundLatitude/gco:Decimal">
						<xsl:with-param name="schema" select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="name"   select="'gmd:northBoundLatitude'"/>
					</xsl:apply-templates>
				</td>
				<td/>
			</tr>
			<tr>
				<td class="padded" align="center">
					<xsl:apply-templates mode="iso19139VertElement" select="gmd:westBoundLongitude/gco:Decimal">
						<xsl:with-param name="schema" select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="name"   select="'gmd:westBoundLongitude'"/>
					</xsl:apply-templates>
				</td>
				
				<!--
				<td class="box" width="100" height="100" align="center">
				-->
				<xsl:variable name="md">
					<xsl:apply-templates mode="brief" select="//gmd:MD_Metadata"/>
				</xsl:variable>
				<xsl:variable name="metadata" select="xalan:nodeset($md)/*[1]"/>
				<!--td width="100" height="100" align="center">
					<xsl:call-template name="thumbnail">
						<xsl:with-param name="metadata" select="$metadata"/>
					</xsl:call-template>
				</td-->
				<td/>
				<td class="padded" align="center">
					<xsl:apply-templates mode="iso19139VertElement" select="gmd:eastBoundLongitude/gco:Decimal">
						<xsl:with-param name="schema" select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="name"   select="'gmd:eastBoundLongitude'"/>
					</xsl:apply-templates>
				</td>
			</tr>
			<tr>
				<td/>
				<td class="padded" align="center">
					<xsl:apply-templates mode="iso19139VertElement" select="gmd:southBoundLatitude/gco:Decimal">
						<xsl:with-param name="schema" select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="name"   select="'gmd:southBoundLatitude'"/>
					</xsl:apply-templates>
				</td>
				<td/>
			</tr>
		</table>
	</xsl:template>
	
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139VertElement" match="*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="name"/>
		
		<xsl:variable name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="name"   select="$name"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="helpLink">
			<xsl:call-template name="getHelpLink">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="name"   select="$name"/>
			</xsl:call-template>
		</xsl:variable>
		<b>
			<xsl:choose>
				<xsl:when test="$helpLink!=''">
					<span id="tip.{$helpLink}" style="cursor:help;"><xsl:value-of select="$title"/>
						<xsl:call-template name="asterisk">
							<xsl:with-param name="link" select="$helpLink"/>
							<xsl:with-param name="edit" select="$edit"/>													
						</xsl:call-template>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$title"/>
				</xsl:otherwise>
			</xsl:choose>
		</b>
		<br/>
		<xsl:call-template name="getElementText">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="cols"  select="10"/>
		</xsl:call-template>
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- abstract -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:abstract" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:call-template name="iso19139String">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="rows"   select="10"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- supplementalInformation | purpose -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:supplementalInformation|gmd:purpose|gmd:statement" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:call-template name="iso19139String">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="rows"   select="5"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!--
	dateTime (format = %Y-%m-%dT%H:%M:00)
	usageDateTime
	plannedAvailableDateTime
	-->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:dateTime|gmd:usageDateTime|gmd:plannedAvailableDateTime" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="text">
						<xsl:variable name="ref" select="gco:DateTime/geonet:element/@ref"/>
						
						<table width="100%"><tr>
							<td>
								<input class="md" type="text" name="_{$ref}" id="_{$ref}_cal" value="{gco:DateTime/text()}" size="30" readonly="1"/>
							</td>
							<td align="center" width="30" valign="middle">
								<img src="{/root/gui/url}/scripts/calendar/img.gif"
									 id="_{$ref}_trigger"
									 style="cursor: pointer; border: 1px solid;"
									 title="Date selector"
									 onmouseover="this.style.background='red';"
									 onmouseout="this.style.background=''" />
								<script type="text/javascript">
									Calendar.setup(
										{
											inputField  : &quot;_<xsl:value-of select="$ref"/>_cal&quot;,         // ID of the input field
											ifFormat    : "%Y-%m-%dT%H:%M:00",                                // the date format
											showsTime   : true, // Show the time
											button      : &quot;_<xsl:value-of select="$ref"/>_trigger&quot;  // ID of the button
										}
									);
									Calendar.setup(
										{
											inputField  : &quot;_<xsl:value-of select="$ref"/>_cal&quot;,         // ID of the input field
											ifFormat    : "%Y-%m-%dT%H:%M:00",                                // the date format
											showsTime   : true, // Show the time
											button      : &quot;_<xsl:value-of select="$ref"/>_cal&quot;  // ID of the button
										}
									);
								</script>
							</td>
							<td align="left" width="100%">
								<xsl:text>  </xsl:text>
								<a href="JavaScript:clear{$ref}();"> <xsl:value-of select="/root/gui/strings/clear"/></a>
								<script type="text/javascript">
									function clear<xsl:value-of select="$ref"/>()	{
										document.mainForm._<xsl:value-of select="$ref"/>.value = &quot;&quot;
									}
								</script>
							</td>
						</tr></table>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="iso19139String">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->
	<!--
	date (format = %Y-%m-%d)
	editionDate
	dateOfNextUpdate
	mdDateSt is not editable (!we use DateTime instead of only Date!)
	-->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:date[gco:DateTime|gco:Date]|gmd:editionDate|gmd:dateOfNextUpdate" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="text">
						<xsl:variable name="ref" select="gco:DateTime/geonet:element/@ref|gco:Date/geonet:element/@ref"/>
						
						<table width="100%"><tr>
							<td>
								<xsl:choose>
                  <xsl:when test="gco:DateTime">
                <input class="md" type="text" name="_{$ref}" id="_{$ref}_cal" value="{gco:DateTime/text()}" size="30" readonly="1"/>
                  </xsl:when>
                  <xsl:otherwise>
                <input class="md" type="text" name="_{$ref}" id="_{$ref}_cal" value="{gco:Date/text()}" size="30" readonly="1"/>
                  </xsl:otherwise>
                </xsl:choose>
							</td>
							<td align="center" width="30" valign="middle">
								<img src="{/root/gui/url}/scripts/calendar/img.gif"
									 id="_{$ref}_trigger"
									 style="cursor: pointer; border: 1px solid;"
									 title="Date selector"
									 onmouseover="this.style.background='red';"
									 onmouseout="this.style.background=''" />
								<script type="text/javascript">
									Calendar.setup(
										{
											inputField  : &quot;_<xsl:value-of select="$ref"/>_cal&quot;,         // ID of the input field
								<xsl:choose>
                  <xsl:when test="gco:DateTime">
                      ifFormat    : "%Y-%m-%dT%H:%M:00", // the date format
                      showsTime : false, // Do not show the time
                  </xsl:when>
                  <xsl:otherwise>
                      ifFormat    : "%Y-%m-%d", // the date format
                      showsTime : false, // Do not show the time
                  </xsl:otherwise>
                </xsl:choose>
											button      : &quot;_<xsl:value-of select="$ref"/>_trigger&quot;  // ID of the button
										}
									);
									Calendar.setup(
										{
											inputField  : &quot;_<xsl:value-of select="$ref"/>_cal&quot;,         // ID of the input field
								<xsl:choose>
                  <xsl:when test="gco:DateTime">
                      ifFormat    : "%Y-%m-%dT%H:%M:00", // the date format
                      showsTime : false, // Do not show the time
                  </xsl:when>
                  <xsl:otherwise>
                      ifFormat    : "%Y-%m-%d",  // the date format
                      showsTime : false, // Do not show the time
                  </xsl:otherwise>
                </xsl:choose>
											button      : &quot;_<xsl:value-of select="$ref"/>_cal&quot;  // ID of the button
										}
									);
								</script>
							</td>
							<td align="left" width="100%">
								<xsl:text>  </xsl:text><a href="JavaScript:clear{$ref}();"> clear</a>
								<script type="text/javascript">
									function clear<xsl:value-of select="$ref"/>()	{
										document.mainForm._<xsl:value-of select="$ref"/>.value = &quot;&quot;
									}
								</script>
							</td>
						</tr></table>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="iso19139String">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!--
	gml:TimePeriod (format = %Y-%m-%dThh:mm:ss)
	-->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gml:TimePeriod[gml:beginPosition|gml:endPosition]" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:for-each select="gml:beginPosition|gml:endPosition">
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="text">
						<xsl:variable name="ref" select="geonet:element/@ref"/>
						
						<table width="100%"><tr>
							<td>
	                					<input class="md" type="text" name="_{$ref}" id="_{$ref}_cal" value="{text()}" size="30" readonly="1"/>
							</td>
							<td align="center" width="30" valign="middle">
								<img src="{/root/gui/url}/scripts/calendar/img.gif"
									 id="_{$ref}_trigger"
									 style="cursor: pointer; border: 1px solid;"
									 title="Date selector"
									 onmouseover="this.style.background='red';"
									 onmouseout="this.style.background=''" />
								<script type="text/javascript">
									Calendar.setup(
										{
											inputField  : &quot;_<xsl:value-of select="$ref"/>_cal&quot;,         // ID of the input field
						                    ifFormat    : "%Y-%m-%dT%H:%M:00", // the date format
                    						showsTime : false, // Do not show the time
											button      : &quot;_<xsl:value-of select="$ref"/>_trigger&quot;  // ID of the button
										}
									);
								</script>
							</td>
							<td align="left" width="100%">
								<xsl:text>  </xsl:text><a href="JavaScript:clear{$ref}();"> clear</a>
								<script type="text/javascript">
									function clear<xsl:value-of select="$ref"/>()	{
										document.mainForm._<xsl:value-of select="$ref"/>.value = &quot;&quot;
									}
								</script>
							</td>
						</tr></table>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="text">
						<xsl:value-of select="text()"/>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- subtemplates -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="*[geonet:info/isTemplate='s']" priority="3">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:apply-templates mode="element" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!--
	placeholder
	<xsl:template mode="iso19139" match="TAG">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		BODY
	</xsl:template>
	-->
	<!-- ============================================================================= -->

	<!-- ============================================================================= -->
	<!-- Metadata -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:MD_Metadata">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
		
			<!-- metadata tab -->
			<xsl:when test="$currTab='metadata'">
			
				<!-- thumbnail -->
				<tr>
					<td class="padded" align="center" valign="center" colspan="2">
						<xsl:variable name="md">
							<xsl:apply-templates mode="brief" select="."/>
						</xsl:variable>
						<xsl:variable name="metadata" select="xalan:nodeset($md)/*[1]"/>
						<xsl:call-template name="thumbnail">
							<xsl:with-param name="metadata" select="$metadata"/>
						</xsl:call-template>
					</td>
				</tr>

				<xsl:call-template name="iso19139Metadata">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:call-template>
			</xsl:when>

			<!-- identification tab -->
			<xsl:when test="$currTab='identification'">
			
				<!-- thumbnail -->
				<tr>
					<td class="padded" align="center" valign="center" colspan="2">
						<xsl:variable name="md">
							<xsl:apply-templates mode="brief" select="."/>
						</xsl:variable>
						<xsl:variable name="metadata" select="xalan:nodeset($md)/*[1]"/>
						<xsl:call-template name="thumbnail">
							<xsl:with-param name="metadata" select="$metadata"/>
						</xsl:call-template>
					</td>
				</tr>
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- maintenance tab -->
			<xsl:when test="$currTab='maintenance'">
				<xsl:apply-templates mode="elementEP" select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- constraints tab -->
			<xsl:when test="$currTab='constraints'">
				<xsl:apply-templates mode="elementEP" select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- spatial tab -->
			<xsl:when test="$currTab='spatial'">
				<xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- refSys tab -->
			<xsl:when test="$currTab='refSys'">
				<xsl:apply-templates mode="elementEP" select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- distribution tab -->
			<xsl:when test="$currTab='distribution'">
				<xsl:apply-templates mode="elementEP" select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- dataQuality tab -->
			<xsl:when test="$currTab='dataQuality'">
				<xsl:apply-templates mode="elementEP" select="gmd:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- appSchInfo tab -->
			<xsl:when test="$currTab='appSchInfo'">
				<xsl:apply-templates mode="elementEP" select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- porCatInfo tab -->
			<xsl:when test="$currTab='porCatInfo'">
				<xsl:apply-templates mode="elementEP" select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- contentInfo tab -->
      <xsl:when test="$currTab='contentInfo'">
        <xsl:apply-templates mode="elementEP" select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- extensionInfo tab -->
      <xsl:when test="$currTab='extensionInfo'">
        <xsl:apply-templates mode="elementEP" select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

			<!-- default -->
			<xsl:otherwise>
			
				<!-- thumbnail -->
				<tr>
					<td class="padded" align="center" valign="center" colspan="2">
						<xsl:variable name="md">
							<xsl:apply-templates mode="brief" select="."/>
						</xsl:variable>
						<xsl:variable name="metadata" select="xalan:nodeset($md)/*[1]"/>
						<xsl:call-template name="thumbnail">
							<xsl:with-param name="metadata" select="$metadata"/>
						</xsl:call-template>
					</td>
				</tr>
				
				<xsl:call-template name="iso19139Simple">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="flat"   select="$currTab='simple'"/>
				</xsl:call-template>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->

  <xsl:template name="iso19139Metadata">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

<!-- if the parent is root then display fields not in tabs -->

		<xsl:choose>
    <xsl:when test="name(..)='root'">
	    <xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:language|geonet:child[string(@name)='language']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:parentIdentifier|geonet:child[string(@name)='parentIdentifier']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:hierarchyLevelName|geonet:child[string(@name)='hierarchyLevelName']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

			<xsl:apply-templates mode="elementEP" select="gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:metadataStandardVersion|geonet:child[string(@name)='metadataStandardVersion']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:contact|geonet:child[string(@name)='contact']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:dataSetURI|geonet:child[string(@name)='dataSetURI']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:locale|geonet:child[string(@name)='locale']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:series|geonet:child[string(@name)='series']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:describes|geonet:child[string(@name)='describes']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:propertyType|geonet:child[string(@name)='propertyType']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

			<xsl:apply-templates mode="elementEP" select="gmd:featureType|geonet:child[string(@name)='featureType']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>

    	<xsl:apply-templates mode="elementEP" select="gmd:featureAttribute|geonet:child[string(@name)='featureAttribute']">
      	<xsl:with-param name="schema" select="$schema"/>
      	<xsl:with-param name="edit"   select="$edit"/>
    	</xsl:apply-templates>
		</xsl:when>

<!-- otherwise, display everything because we have embedded MD_Metadata -->

		<xsl:otherwise>
			<xsl:apply-templates mode="elementEP" select="*">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit"   select="$edit"/>
			</xsl:apply-templates>
		</xsl:otherwise>
		</xsl:choose>

  </xsl:template>
	
	<!-- ============================================================================= -->
	<!--
	simple mode; ISO order is:
	- gmd:fileIdentifier
	- gmd:language
	- gmd:characterSet
	- gmd:parentIdentifier
	- gmd:hierarchyLevel
	- gmd:hierarchyLevelName
	- gmd:contact
	- gmd:dateStamp
	- gmd:metadataStandardName
	- gmd:metadataStandardVersion
	+ gmd:dataSetURI
	+ gmd:locale
	- gmd:spatialRepresentationInfo
	- gmd:referenceSystemInfo
	- gmd:metadataExtensionInfo
	- gmd:identificationInfo
	- gmd:contentInfo
	- gmd:distributionInfo
	- gmd:dataQualityInfo
	- gmd:portrayalCatalogueInfo
	- gmd:metadataConstraints
	- gmd:applicationSchemaInfo
	- gmd:metadataMaintenance
	+ gmd:series
	+ gmd:describes
	+ gmd:propertyType
	+ gmd:featureType
	+ gmd:featureAttribute
	-->
	<!-- ============================================================================= -->

	<xsl:template name="iso19139Simple">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="flat"/>

		<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:call-template name="complexElementGui">
			<xsl:with-param name="title" select="/root/gui/strings/metadata"/>
			<xsl:with-param name="content">
				<xsl:call-template name="iso19139Simple2">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="flat"   select="$flat"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="schema" select="$schema"/>
		</xsl:call-template>
		
		<xsl:apply-templates mode="elementEP" select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
	</xsl:template>
	
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="//gmd:language">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<xsl:apply-templates mode="simpleElement" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="text">
				<xsl:apply-templates mode="iso19139GetIsoLanguage" select="gco:CharacterString">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139GetIsoLanguage" match="*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:variable name="lang"  select="/root/gui/language"/>
		<xsl:variable name="value" select="string(.)"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<select class="md" name="_{geonet:element/@ref}" size="1">
					<option name=""/>

					<xsl:for-each select="/root/gui/isoLang/record">
						<option value="{code}">
							<xsl:if test="code = $value">
								<xsl:attribute name="selected"/>
							</xsl:if>							
							<xsl:value-of select="label/child::*[name() = $lang]"/>
						</option>
					</xsl:for-each>
				</select>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="/root/gui/isoLang/record[code=$value]/label/child::*[name() = $lang]"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<!-- ============================================================================= -->

	<xsl:template name="iso19139Simple2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="flat"/>
		
		<xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:language|geonet:child[string(@name)='language']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:parentIdentifier|geonet:child[string(@name)='parentIdentifier']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:hierarchyLevelName|geonet:child[string(@name)='hierarchyLevelName']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:metadataStandardVersion|geonet:child[string(@name)='metadataStandardVersion']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:contact|geonet:child[string(@name)='contact']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:dataSetURI|geonet:child[string(@name)='dataSetURI']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:locale|geonet:child[string(@name)='locale']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:series|geonet:child[string(@name)='series']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:describes|geonet:child[string(@name)='describes']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:propertyType|geonet:child[string(@name)='propertyType']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:featureType|geonet:child[string(@name)='featureType']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gmd:featureAttribute|geonet:child[string(@name)='featureAttribute']">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="flat"   select="$flat"/>
		</xsl:apply-templates>
		
	</xsl:template>

	<!-- ============================================================================= -->
	<!--
	FIXME
	rpCntInfo: ISO order is:
	- rpIndName
	- rpOrgName
	- rpPosName
	- rpCntInfo
	- role
	-->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="mdContact|idPoC">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<xsl:variable name="content">
			<xsl:if test="*">
				<td class="padded-content" width="100%" colspan="2">
					<table width="100%">
						<tr>
							<td width="50%" valign="top">
								<table width="100%">

									<xsl:apply-templates mode="elementEP" select="rpIndName|geonet:child[string(@name)='rpIndName']">
										<xsl:with-param name="schema" select="$schema"/>
										<xsl:with-param name="edit"   select="$edit"/>
									</xsl:apply-templates>
									
									<xsl:apply-templates mode="elementEP" select="rpOrgName|geonet:child[string(@name)='rpOrgName']">
										<xsl:with-param name="schema" select="$schema"/>
										<xsl:with-param name="edit"   select="$edit"/>
									</xsl:apply-templates>
									
									<xsl:apply-templates mode="elementEP" select="rpPosName|geonet:child[string(@name)='rpPosName']">
										<xsl:with-param name="schema" select="$schema"/>
										<xsl:with-param name="edit"   select="$edit"/>
									</xsl:apply-templates>
									
									<xsl:apply-templates mode="elementEP" select="role|geonet:child[string(@name)='role']">
										<xsl:with-param name="schema" select="$schema"/>
										<xsl:with-param name="edit"   select="$edit"/>
									</xsl:apply-templates>
									
								</table>
							</td>
							<td valign="top">
								<table width="100%">
									<xsl:apply-templates mode="elementEP" select="rpCntInfo|geonet:child[string(@name)='rpCntInfo']">
										<xsl:with-param name="schema" select="$schema"/>
										<xsl:with-param name="edit"   select="$edit"/>
									</xsl:apply-templates>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</xsl:if>
		</xsl:variable>

		<xsl:apply-templates mode="complexElement" select=".">
			<xsl:with-param name="schema"  select="$schema"/>
			<xsl:with-param name="edit"    select="$edit"/>
			<xsl:with-param name="content" select="$content"/>
		</xsl:apply-templates>

	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- online resources -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:CI_OnlineResource" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="text">
						<a href="{gmd:linkage/gmd:URL}" target="_new">
							<xsl:choose>
								<xsl:when test="string(gmd:description/gco:CharacterString)!=''">
									<xsl:value-of select="gmd:description/gco:CharacterString"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="gmd:linkage/gmd:URL"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->

	<xsl:template mode="iso19139EditOnlineRes" match="*">
		<xsl:param name="schema"/>
		
		<xsl:apply-templates mode="complexElement" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="true()"/>
			<xsl:with-param name="content">
				
				<xsl:apply-templates mode="elementEP" select="gmd:linkage|geonet:child[string(@name)='linkage']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:protocol|geonet:child[string(@name)='protocol']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:applicationProfile|geonet:child[string(@name)='applicationProfile']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
				
				<xsl:choose>
					<xsl:when test="string(gmd:protocol/gco:CharacterString)='WWW:DOWNLOAD-1.0-http--download' and string(gmd:name/gco:CharacterString)!=''">
						<xsl:apply-templates mode="iso19139FileRemove" select="gmd:name/gco:CharacterString">
							<xsl:with-param name="access" select="'private'"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="string(gmd:protocol/gco:CharacterString)='WWW:DOWNLOAD-1.0-http--download' and gmd:name">
						<xsl:apply-templates mode="iso19139FileUpload" select="gmd:name/gco:CharacterString">
							<xsl:with-param name="access" select="'private'"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="string(gmd:protocol/gco:CharacterString)='WWW:LINK-1.0-http--link'"/> <!-- hide orName for www links -->
					<xsl:otherwise>
						<xsl:apply-templates mode="elementEP" select="gmd:name|geonet:child[string(@name)='name']">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="true()"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates mode="elementEP" select="gmd:description|geonet:child[string(@name)='description']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:function|geonet:child[string(@name)='function']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- online resources: WMS get map -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'OGC:WMS-') and contains(gmd:protocol/gco:CharacterString,'-get-map') and gmd:name]" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string(//geonet:info/dynamic)='true'">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="title"  select="/root/gui/strings/interactiveMap"/>
					<xsl:with-param name="text">
						<!-- ETj
						<a href="javascript:popInterMap('{/root/gui/url}/intermap/srv/{/root/gui/language}/map.addServicesExt?url={gmd:linkage/gmd:URL}&amp;service={gmd:name/gco:CharacterString}&amp;type=2')" title="{/root/strings/interactiveMap}">
						-->
						<a href="javascript:runIM_addService('{gmd:linkage/gmd:URL}','{gmd:name/gco:CharacterString}',2)" title="{/root/strings/interactiveMap}">
							<xsl:choose>
								<xsl:when test="string(gmd:description/gco:CharacterString)!=''">
									<xsl:value-of select="gmd:description/gco:CharacterString"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="gmd:name/gco:CharacterString"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- online resources: WMS get capabilities -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'OGC:WMS-') and contains(gmd:protocol/gco:CharacterString,'-get-capabilities') and gmd:name]" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string(//geonet:info/dynamic)='true'">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="title"  select="/root/gui/strings/interactiveMap"/>
					<xsl:with-param name="text">
						<a href="javascript:runIM_selectService('{gmd:linkage/gmd:URL}',2,{//geonet:info/id})" title="{/root/strings/interactiveMap}">							
							<xsl:choose>
								<xsl:when test="string(gmd:description/gco:CharacterString)!=''">
									<xsl:value-of select="gmd:description/gco:CharacterString"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="gmd:name/gco:CharacterString"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- online resources: ARCIMS -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'ESRI:AIMS-') and contains(gmd:protocol/gco:CharacterString,'-get-image') and gmd:name]" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string(//geonet:info/dynamic)='true'">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="title"  select="/root/gui/strings/interactiveMap"/>
					<xsl:with-param name="text">
<!--	ETj					<a href="javascript:popInterMap('{/root/gui/url}/intermap/srv/{/root/gui/language}/map.addServicesExt?url={gmd:linkage/gmd:URL}&amp;service={gmd:name/gco:CharacterString}&amp;type=1')" title="{/root/strings/interactiveMap}">
-->						<a href="javascript:runIM_addService('{gmd:linkage/gmd:URL}','{gmd:name/gco:CharacterString}',1)" title="{/root/strings/interactiveMap}">
								<xsl:choose>
								<xsl:when test="string(gmd:description/gco:CharacterString)!=''">
									<xsl:value-of select="gmd:description/gco:CharacterString"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="gmd:name/gco:CharacterString"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- online resources: download -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:DOWNLOAD-') and contains(gmd:protocol/gco:CharacterString,'http--download') and gmd:name]" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string(//geonet:info/download)='true'">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema"  select="$schema"/>
					<xsl:with-param name="title"  select="/root/gui/strings/downloadData"/>
					<xsl:with-param name="text">
						<a href="{gmd:linkage/gmd:URL}" target="_blank">
							<xsl:choose>
								<xsl:when test="string(gmd:description/gco:CharacterString)!=''">
									<xsl:value-of select="gmd:description/gco:CharacterString"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="gmd:name/gco:CharacterString"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- protocol -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="gmd:protocol" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
					<xsl:with-param name="text">
						<xsl:variable name="value" select="string(gco:CharacterString)"/>
						<select name="_{gco:CharacterString/geonet:element/@ref}" size="1">
							<xsl:if test="$value=''">
								<option value=""/>
							</xsl:if>
							<xsl:for-each select="/root/gui/strings/protocolChoice[@value]">
								<option>
									<xsl:if test="string(@value)=$value">
										<xsl:attribute name="selected"/>
									</xsl:if>
									<xsl:attribute name="value"><xsl:value-of select="string(@value)"/></xsl:attribute>
									<xsl:value-of select="string(.)"/>
								</option>
							</xsl:for-each>
						</select>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="element" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="false()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- FIXME graphOver -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="graphOver">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:if test="$edit=true() and $currTab!='simple'">
			<xsl:apply-templates mode="iso19139EditGraphOver" select=".">
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- FIXME 	-->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139EditGraphOver" match="*">
		<xsl:param name="schema"/>
		
		<xsl:apply-templates mode="complexElement" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="true()"/>
			<xsl:with-param name="content">
				
				<xsl:choose>
					<xsl:when test="(string(bgFileDesc)='thumbnail' or string(bgFileDesc)='large_thumbnail') and string(bgFileName)!=''">
						<xsl:apply-templates mode="iso19139FileRemove" select="bgFileName"/>
					</xsl:when>
					<xsl:when test="string(bgFileDesc)='thumbnail' or string(bgFileDesc)='large_thumbnail'">
						<xsl:apply-templates mode="iso19139FileUpload" select="bgFileName"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="elementEP" select="bgFileName|geonet:child[string(@name)='bgFileName']">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="true()"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates mode="elementEP" select="bgFileDesc|geonet:child[string(@name)='bgFileDesc']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="bgFileType|geonet:child[string(@name)='bgFileType']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="true()"/>
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- FIXME bgFileDesc -->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139" match="bgFileDesc">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:choose>
			<xsl:when test="$edit=true()">
				<xsl:apply-templates mode="simpleElement" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="text">
						<xsl:variable name="value" select="string(.)"/>
						<select name="_{geonet:element/@ref}" size="1">
							<xsl:if test="string(.)=''">
								<option value=""/>
							</xsl:if>
							<xsl:for-each select="/root/gui/strings/bgFileDescChoice[@value]">
								<option value="{string(@value)}">
									<xsl:if test="string(@value)=$value">
										<xsl:attribute name="selected"/>
									</xsl:if>
									<xsl:value-of select="string(.)"/>
								</option>
							</xsl:for-each>
						</select>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="element" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="false()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- file upload/download utilities	-->
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139FileUpload" match="*">
		<xsl:param name="access" select="'public'"/>
	
		<xsl:call-template name="simpleElementGui">
			<xsl:with-param name="title" select="/root/gui/strings/file"/>
			<xsl:with-param name="text">
				<table width="100%"><tr>
					<xsl:variable name="ref" select="geonet:element/@ref"/>
					<td width="70%"><input type="file" class="content" name="f_{$ref}" value="{string(.)}"/>&#160;</td>
					<td align="right"><button class="content" onclick="javascript:doFileUploadAction('{/root/gui/locService}/resources.upload','{$ref}',document.mainForm.f_{$ref}.value,'{$access}')"><xsl:value-of select="/root/gui/strings/upload"/></button></td>
				</tr></table>
			</xsl:with-param>
			<xsl:with-param name="schema"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============================================================================= -->

	<xsl:template mode="iso19139FileRemove" match="*">
		<xsl:param name="access" select="'public'"/>
	
		<xsl:call-template name="simpleElementGui">
			<xsl:with-param name="title" select="/root/gui/strings/file"/>
			<xsl:with-param name="text">
				<table width="100%"><tr>
					<xsl:variable name="ref" select="geonet:element/@ref"/>
					<td width="70%"><xsl:value-of select="string(.)"/></td>
					<td align="right"><button class="content" onclick="javascript:doFileRemoveAction('{/root/gui/locService}/resources.del','{$ref}','{$access}')"><xsl:value-of select="/root/gui/strings/remove"/></button></td>
				</tr></table>
			</xsl:with-param>
			<xsl:with-param name="schema"/>
		</xsl:call-template>
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- === iso19139 brief formatting === -->
	<!-- ============================================================================= -->
	
	<xsl:template name="iso19139Brief">
		<metadata>
			<xsl:variable name="id" select="geonet:info/id"/>

			<xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title">
				<title><xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/></title>
			</xsl:if>
			
			<xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract">
				<abstract><xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract"/></abstract>
			</xsl:if>

			<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString[text()]">
				<keyword><xsl:value-of select="."/></keyword>
			</xsl:for-each>

			<xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
				<geoBox>
					<westBL><xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude"/></westBL>
					<eastBL><xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude"/></eastBL>
					<southBL><xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude"/></southBL>
					<northBL><xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude"/></northBL>
				</geoBox>
			</xsl:if>
			
			<xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
				<xsl:variable name="protocol" select="gmd:protocol/gco:CharacterString"/>
				<xsl:variable name="linkage"  select="gmd:linkage/gmd:URL"/>
				<xsl:variable name="name"     select="gmd:name/gco:CharacterString"/>
				<xsl:choose>
					<xsl:when test="starts-with($protocol,'WWW:DOWNLOAD-') and contains($protocol,'http--download') and $name">
						<link type="download"><xsl:value-of select="$linkage"/></link>
					</xsl:when>
					<xsl:when test="starts-with($protocol,'ESRI:AIMS-') and contains($protocol,'-get-image') and $name">
						<link type="arcims">
<!--							<xsl:value-of select="concat('javascript:popInterMap(&#34;',/root/gui/url,'/intermap/srv/',/root/gui/language,'/map.addServicesExt?url=',$linkage,'&amp;service=',$name,'&amp;type=1&#34;)')"/>-->
							<xsl:value-of select="concat('javascript:runIM_addService(&#34;'  ,  $linkage  ,  '&#34;, &#34;', $name  ,'&#34;, 1)' )"/>
						</link>
					</xsl:when>
					<xsl:when test="starts-with($protocol,'OGC:WMS-') and contains($protocol,'-get-map') and $name">
						<link type="wms">
<!--							<xsl:value-of select="concat('javascript:popInterMap(&#34;',/root/gui/url,'/intermap/srv/',/root/gui/language,'/map.addServicesExt?url=',$linkage,'&amp;service=',$name,'&amp;type=2&#34;)')"/>-->
							<xsl:value-of select="concat('javascript:runIM_addService(&#34;'  ,  $linkage  ,  '&#34;, &#34;', $name  ,'&#34;, 2)' )"/>
							
						</link>
					</xsl:when>
					<xsl:when test="starts-with($protocol,'OGC:WMS-') and contains($protocol,'-get-capabilities') and $name">
						<link type="wms">
							<xsl:value-of select="concat('javascript:runIM_selectService(&#34;'  ,  $linkage  ,  '&#34;, 2,',$id,')' )"/>
						</link>
					</xsl:when>
					<xsl:when test="string($linkage)!=''">
						<link type="url"><xsl:value-of select="$linkage"/></link>
					</xsl:when>
					
				</xsl:choose>
			</xsl:for-each>

			<xsl:if test="not(geonet:info/server)">
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:graphicOverview/gmd:MD_BrowseGraphic">
					<xsl:variable name="fileName"  select="gmd:fileName/gco:CharacterString"/>
					<xsl:if test="$fileName != ''">
						<xsl:variable name="fileDescr" select="gmd:fileDescription/gco:CharacterString"/>
						<xsl:choose>

							<!-- the thumbnail is an url -->

							<xsl:when test="contains($fileName ,'://')">
								<image type="unknown"><xsl:value-of select="$fileName"/></image>								
							</xsl:when>

							<!-- small thumbnail -->

							<xsl:when test="string($fileDescr)='thumbnail'">
								<image type="thumbnail">
									<xsl:value-of select="concat(/root/gui/locService,'/resources.get?id=',$id,'&amp;fname=',$fileName,'&amp;access=public')"/>
								</image>
							</xsl:when>

							<!-- large thumbnail -->

							<xsl:when test="string($fileDescr)='large_thumbnail'">
								<image type="overview">
									<xsl:value-of select="concat(/root/gui/locService,'/graphover.show?id=',$id,'&amp;fname=',$fileName,'&amp;access=public')"/>
								</image>
							</xsl:when>

						</xsl:choose>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>

			<xsl:copy-of select="geonet:info"/>
		</metadata>
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- iso19139 complete tab template	-->
	<!-- ============================================================================= -->

	<xsl:template name="iso19139CompleteTab">
		<xsl:param name="tabLink"/>
		
		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'complete'"/> <!-- just a non-existing tab -->
			<xsl:with-param name="text"    select="/root/gui/strings/completeTab"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
		
		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'metadata'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/metadata"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
		
		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'identification'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/identificationTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>

		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'maintenance'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/maintenanceTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>

		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'constraints'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/constraintsTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>

		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'spatial'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/spatialTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>

		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'refSys'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/refSysTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>

		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'distribution'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/distributionTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>

		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'dataQuality'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/dataQualityTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
		
		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'appSchInfo'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/appSchInfoTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
		
		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'porCatInfo'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/porCatInfoTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>

		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'contentInfo'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/contentInfoTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
		
		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'extensionInfo'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/extensionInfoTab"/>
			<xsl:with-param name="indent"  select="'&#xA0;&#xA0;&#xA0;'"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
		
	</xsl:template>
	
	<!-- ============================================================================= -->
	<!-- utilities -->
	<!-- ============================================================================= -->
	
	<xsl:template mode="iso19139IsEmpty" match="*|@*|text()">
		<xsl:choose>
			<!-- normal element -->
			<xsl:when test="*">
				<xsl:apply-templates mode="iso19139IsEmpty"/>
			</xsl:when>
			<!-- text element -->
			<xsl:when test="text()!=''">txt</xsl:when>
			<!-- empty element -->
			<xsl:otherwise>
				<!-- codelist? -->
				<xsl:variable name="name" select="name(.)"/>
				<xsl:if test="@codeList">
					<xsl:if test="@codeListValue!=''">cdl</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
