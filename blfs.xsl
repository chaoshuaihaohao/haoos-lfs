<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:exsl="http://exslt.org/common"
      extension-element-prefixes="exsl"
      version="1.0">

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>


  <!-- 定义一个模板来匹配sect1、sect2和sect3元素 -->  
  <xsl:template match="/">  
    <xsl:text>menu "BLFS configuration"&#xA;</xsl:text>
    <xsl:apply-templates select="//chapter"/>  <!-- 处理title子元素 -->  
    <xsl:text>endmenu&#xA;</xsl:text>
  </xsl:template>  
  
  <!-- 定义一个模板来处理chapter元素 -->  
  <xsl:template match="chapter">  
    <xsl:if test="@id != 'welcome' and @id != 'important' and @id != 'postlfs-config'">
    <xsl:text>&#xA;</xsl:text>
    <xsl:text>&#9;menu </xsl:text>
    <xsl:text>&#9;"chapter-</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>"&#xA;</xsl:text>
    <xsl:apply-templates select="sect1">  <!-- 处理sect1子元素 -->  
        <xsl:with-param name="chap-num" select="position()"/>
  </xsl:apply-templates>  
    <xsl:text>&#xA;</xsl:text>
    <xsl:text>&#9;endmenu&#xA;</xsl:text>
    <xsl:text>&#xA;</xsl:text>
</xsl:if>
  </xsl:template>  


  <!-- 定义一个模板来处理sect1元素 -->  
  <xsl:template match="sect1">  
    <xsl:param name="chap-num" select="'1'"/>	<!-- define chap-num param -->
    <xsl:variable name="order">
      <xsl:value-of select="$chap-num"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="position()"/>
    </xsl:variable>

    <xsl:text>&#xA;</xsl:text>

    <xsl:variable name="dirname" select="../@id"/>
    <xsl:variable name="filename" select="@id"/>
    <xsl:if test="$dirname and $filename">

		<!-- Get the dependences -->
	    <xsl:text>&#9;config </xsl:text>
	    <xsl:value-of select="$order"/>
	    <xsl:text>-</xsl:text>
	    <xsl:value-of select="$filename"/>
	    <xsl:text>&#xA;</xsl:text>
	    <xsl:text>&#9;&#9;bool "</xsl:text>
	    <xsl:value-of select="$filename"/>
	    <xsl:text>"&#xA;</xsl:text>
	    <xsl:apply-templates select=".//para">  <!-- 处理para子元素 -->  
	    </xsl:apply-templates>  
	    <xsl:text>&#9;&#9;default y&#xA;</xsl:text>
<exsl:document href="/mnt/build_dir/jhalfs/blfs-commands/{$dirname}/{$order}-{$filename}" method="text">

<!-- 处理multi screen/userinput子元素 -->  
    <xsl:if test=".//screen/userinput">
      <xsl:call-template name="shell-header"/>  <!--  -->  
	    <xsl:for-each select=".//para">
	      <xsl:if test="contains(., 'Download (HTTP):')">
		      <xsl:call-template name="env">
			  <xsl:with-param name="url" select="./ulink/@url"/>
			  <xsl:with-param name="scripts">
					<xsl:value-of select="$dirname"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="$order"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="$filename"/>
				</xsl:with-param> 
		      </xsl:call-template>
	    </xsl:if>
            </xsl:for-each>
      <xsl:call-template name="start-scripts"/>  <!--  -->  
      <xsl:apply-templates select=".//screen/userinput"/>  <!--  -->  
      <xsl:call-template name="end-scripts"/>  <!--  -->  
    </xsl:if>
</exsl:document>
</xsl:if>
  </xsl:template>  

  <!-- 定义一个模板来处理userinput元素 -->  
  <xsl:template match="userinput">  
        <xsl:value-of select="."/>
        <xsl:text>&#xA;&#xA;</xsl:text>
  </xsl:template>  

  <!-- 定义一个模板来处理para元素 -->  
  <xsl:template match="para">  
	<xsl:choose>
	    <xsl:when test="@role='recommended'">
			      <!-- recommended=Kconfig N -->
	    </xsl:when>
	    <xsl:when test="@role='optional'">
			      <!-- optional=Kconfig N -->
	    </xsl:when>
	    <xsl:when test="@role='required'">
		    <xsl:if test="xref">
			<xsl:for-each select="xref">
			    <xsl:if test="@role!='runtime'">
			      <xsl:text>&#9;&#9;depends on </xsl:text>		<!-- required=Kconfig depends on -->
			      <xsl:value-of select="@linkend"/>
			      <xsl:text>&#xA;</xsl:text>
			    </xsl:if>
			</xsl:for-each>
		    </xsl:if>
	    </xsl:when>
	</xsl:choose>
  </xsl:template>  



  <!-- 定义一个模板来add shell header --> 
  <xsl:template name="shell-header"> 
      <xsl:text>#!/bin/bash&#xA;&#xA;</xsl:text>
      <xsl:text>set +h&#xA;</xsl:text>
      <xsl:text>set -e&#xA;&#xA;</xsl:text>
  </xsl:template> 
  <!-- 定义一个模板来add env variables scripts --> 
  <xsl:template name="env"> 
      <xsl:param name="url" />
      <xsl:param name="path" />
      <xsl:param name="scripts" />
      <xsl:text>ROOT=/&#xA;&#xA;</xsl:text>
      <xsl:text>SRC_DIR=${ROOT}sources&#xA;&#xA;</xsl:text>
      <xsl:text>PKG_DEST=${SRC_DIR}/</xsl:text>
      <xsl:value-of select="$scripts"/>
      <xsl:text>&#xA;&#xA;</xsl:text>
      <xsl:text>HTTP_URL=</xsl:text>
      <xsl:value-of select="$url"/>
      <xsl:text>&#xA;</xsl:text>
      <xsl:text>PACKAGE=</xsl:text>
      <xsl:call-template name="basename">
        <xsl:with-param name="path" select="$url"/>
      </xsl:call-template>
      <xsl:text>&#xA;</xsl:text>
      <xsl:text>cd $SRC_DIR&#xA;&#xA;</xsl:text>
      <xsl:text>PKGDIR=$(tar -tf $PACKAGE | head -n1 | sed 's@^./@@;s@/.*@@')&#xA;</xsl:text>
      <xsl:text>export PKGDIR VERSION PKG_DEST&#xA;&#xA;</xsl:text>
      <xsl:text>if [ -d "$PKGDIR" ]; then rm -rf $PKGDIR; fi&#xA;</xsl:text>
      <xsl:text>if [ -d "$PKG_DEST" ]; then rm -rf $PKG_DEST; fi&#xA;</xsl:text>
      <xsl:text>if [ -d "${PKGDIR%-*}-build" ]; then  rm -rf ${PKGDIR%-*}-build; fi&#xA;</xsl:text>
      <xsl:text>tar -xf $PACKAGE&#xA;</xsl:text>
      <xsl:text>cd $PKGDIR&#xA;</xsl:text>
      <xsl:text>&#xA;</xsl:text>
  </xsl:template> 
  <!-- 定义一个模板来decompressing the packet files --> 
  <xsl:template name="tar"> 
      <xsl:text>&#xA;&#xA;</xsl:text>
  </xsl:template> 
  <!-- 定义一个模板来add start scripts --> 
  <xsl:template name="start-scripts"> 
      <xsl:text># Start of BLFS book script&#xA;&#xA;</xsl:text>
  </xsl:template> 
  <!-- 定义一个模板来add end scripts -->  
  <xsl:template name="end-scripts"> 
      <xsl:text># End of LFS book script&#xA;&#xA;</xsl:text>
      <xsl:text>cd $SRC_DIR&#xA;&#xA;</xsl:text>
      <xsl:text>rm -rf $PKGDIR&#xA;</xsl:text>
      <xsl:text>if [ -d "${PKGDIR%-*}-build" ]; then  rm -rf ${PKGDIR%-*}-build; fi&#xA;</xsl:text>
      <xsl:text>exit&#xA;</xsl:text>
  </xsl:template> 


  <xsl:template name="basename">
    <xsl:param name="path" select="''"/>
    <xsl:choose>
      <xsl:when test="contains($path,'/') and substring-after($path,'/')!=''">
        <xsl:call-template name="basename">
          <xsl:with-param name="path" select="substring-after($path,'/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($path,'/') and substring-after($path,'/')=''">
        <xsl:value-of select="substring-before($path,'/')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$path"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
