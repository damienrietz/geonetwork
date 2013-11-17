<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:saxon="http://saxon.sf.net/" xmlns:gn="http://www.fao.org/geonetwork"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  extension-element-prefixes="saxon" exclude-result-prefixes="#all">

  <!-- The editor form.
  
  The form is built from the processing of the metadocument. The metadocument
  is composed of the source metadata record and the schema information.
  
  # Element identification
  
  In the metadocument, each element are identified by a an identifier stored
  in the geonet:element/@ref. This identifier is used when the editor form is
  sent back for saving edits.
  
  eg.
  <gmd:fileIdentifier>
    <gco:CharacterString>
      da165110-88fd-11da-a88f-000d939bc5d8
      <geonet:element ref="3" parent="2" uuid="gco:CharacterString_b1f1c734-258f-4784-9d47-175c7f1a00e1" min="1" max="1"/>
    </gco:CharacterString>
    <geonet:element ref="2" parent="1" uuid="gmd:fileIdentifier_94eae163-101b-49c0-b06c-ff13c3616263" min="0" max="1" del="true"/>
  
  In that case, _3=<new_uuid> will be sent to update the fileIdentifier/CharacterString.
  
  # Element schema
  
  The metadocument also contains cardinality and list of values for enumeration.
  
  -->

  <xsl:output omit-xml-declaration="yes" method="html" doctype-public="html" indent="yes"
    encoding="UTF-8"/>

  <xsl:include href="../../common/base-variables-metadata-editor.xsl"/>

  <xsl:include href="../../common/functions-core.xsl"/>
  <xsl:include href="../../common/functions-metadata.xsl"/>

  <xsl:include href="../../common/profiles-loader.xsl"/>

  <xsl:include href="../form-builder.xsl"/>

  <xsl:template match="/">
    <!-- 
          The main editor form.
          
          Disable form validation with novalidate attribute. -->
    <form id="gn-editor-{$metadataId}" name="gnEditor" accept-charset="UTF-8" method="POST"
      novalidate="" class="form-horizontal gn-editor" role="form" 
      data-spy="scroll" data-target="#gn-editor-{$metadataId}-spy">
      
      <input type="hidden" id="schema" value="{$schema}"/>
      <input type="hidden" id="template" name="template" value="{$isTemplate}"/>
      <input type="hidden" id="uuid" value="{$metadataUuid}"/>
      <input type="hidden" name="id" value="{$metadataId}"/>
      <input type="hidden" name="language" value="{$metadataLanguage}"/>
      <input type="hidden" name="otherLanguages" value="{$metadataOtherLanguages}"/>
      <input type="hidden" id="version" name="version" value="{$metadata/gn:info/version}"/>
      <input type="hidden" id="currTab" name="currTab" value="{$tab}"/>
      <input type="hidden" id="displayAttributes" name="displayAttributes"
        value="{$isDisplayingAttributes}"/>
      <input type="hidden" id="minor" name="minor" value="{$isMinorEdit}"/>
      <input type="hidden" id="flat" name="flat" value="{$isFlatMode}"/>
      <input type="hidden" name="showvalidationerrors" value="{$showValidationErrors}"/>

      <!-- Dispatch to profile mode -->
      <xsl:if test="$service != 'md.element.add'">
        <xsl:call-template name="menu-builder">
          <xsl:with-param name="config" select="$editorConfig"/>
        </xsl:call-template>
      </xsl:if>
      
      <xsl:choose>
        <xsl:when test="$service != 'md.element.add' and $tabConfig/section">
          <xsl:apply-templates mode="form-builer" select="$tabConfig/section">
            <xsl:with-param name="base" select="$metadata"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$tab = 'xml'">
          <xsl:apply-templates mode="render-xml" select="$metadata"/>
        </xsl:when>
        <xsl:otherwise>
          <saxon:call-template name="{concat('dispatch-',$schema)}">
            <xsl:with-param name="base" select="$metadata"/>
          </saxon:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </form>

  </xsl:template>

</xsl:stylesheet>
