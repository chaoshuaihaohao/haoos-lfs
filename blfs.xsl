<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:exsl="http://exslt.org/common"
      extension-element-prefixes="exsl"
      version="1.0">

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

  <!-- 定义一个模板来匹配sect1、sect2和sect3元素 -->  
  <xsl:template match="/">  
    <xsl:text>menu "mybook"&#xA;</xsl:text>
    <xsl:apply-templates select="//chapter"/>  <!-- 处理title子元素 -->  
    <xsl:text>endmenu&#xA;</xsl:text>
  </xsl:template>  
  
  <!-- 定义一个模板来处理chapter元素 -->  
  <xsl:template match="chapter">  
    <xsl:if test="@id != 'welcome' and @id != 'important' and @id != 'postlfs-config'">
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="sect1">  <!-- 处理sect1子元素 -->  
        <xsl:with-param name="chap-num" select="position()"/>
  </xsl:apply-templates>  
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
	    <xsl:value-of select="$filename"/>
	    <xsl:text>&#xA;</xsl:text>
	    <xsl:text>&#9;&#9;bool "</xsl:text>
	    <xsl:value-of select="$filename"/>
	    <xsl:text>"&#xA;</xsl:text>
	    <xsl:apply-templates select=".//para">  <!-- 处理para子元素 -->  
	    </xsl:apply-templates>  
	    <xsl:text>&#9;&#9;default y&#xA;</xsl:text>
<exsl:document href="/home/hao/github/haoos-lfs/cmd/{$dirname}/{$order}-{$filename}" method="text">
<!-- 处理multi screen/userinput子元素 -->  
    <xsl:for-each select=".//screen/userinput">
        <xsl:value-of select="."/>
        <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>  
</exsl:document>
</xsl:if>
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

</xsl:stylesheet>
