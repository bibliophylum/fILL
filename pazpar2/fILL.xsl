<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
    xmlns:marc="http://www.loc.gov/MARC21/slim">
  
  <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

  <xsl:import href="/etc/pazpar2/marc21.xsl"/>

  <xsl:variable name="symbol">
    <xsl:value-of select="$symbol">
  </xsl:variable>

</xsl:stylesheet>

