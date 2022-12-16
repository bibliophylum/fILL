<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
    xmlns:marc="http://www.loc.gov/MARC21/slim">
  
  <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

<!-- Extract metadata from MARC21/USMARC 
      http://www.loc.gov/marc/bibliographic/ecbdhome.html
-->  
  <xsl:template name="record-hook"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="marc:record">
    <xsl:variable name="title_medium" select="marc:datafield[@tag='245']/marc:subfield[@code='h']"/>
    <xsl:variable name="rda_carrier" select="marc:datafield[@tag='338']/marc:subfield[@code='a']"/>
    <xsl:variable name="rda_carrier_b" select="marc:datafield[@tag='338']/marc:subfield[@code='b']"/>
    <xsl:variable name="digital_file_characteristics" select="marc:datafield[@tag='347']/marc:subfield[@code='b']"/>
    <xsl:variable name="journal_title" select="marc:datafield[@tag='773']/marc:subfield[@code='t']"/>
    <xsl:variable name="electronic_location_url" select="marc:datafield[@tag='856']/marc:subfield[@code='u']"/>
    <xsl:variable name="fulltext_a" select="marc:datafield[@tag='900']/marc:subfield[@code='a']"/>
    <xsl:variable name="fulltext_b" select="marc:datafield[@tag='900']/marc:subfield[@code='b']"/>
    <xsl:variable name="destiny_material_type" select="marc:datafield[@tag='926']/marc:subfield[@code='a']"/>
    <xsl:variable name="cela_restricted" select="marc:datafield[@tag='506']/marc:subfield[@code='a']"/>
    <xsl:variable name="is_cela_record">
      <xsl:choose>
	<!-- DC: CELA records will have a 506$a = "For the exclusive use of persons with a print disability." (or French equivalent)
	     and a 020$q = "(CELA)" (or French equivalent) -->
	<xsl:when test="contains(marc:datafield[@tag='506']/marc:subfield[@code='a'],'For the exclusive use of persons with a print disability.')">
	  <xsl:choose>
	    <xsl:when test="marc:datafield[@tag='506']/marc:subfield[@code='a']='(CELA)'">
	      <xsl:text>CELA</xsl:text>
	    </xsl:when>
	  </xsl:choose>
	</xsl:when>
	<xsl:when test="contains(marc:datafield[@tag='506']/marc:subfield[@code='a'],'usage exclusif des personnes incapables de lire')">
	  <xsl:choose>
	    <xsl:when test="marc:datafield[@tag='506']/marc:subfield[@code='a']='(CAÉB)'">
	      <xsl:text>CELA</xsl:text>
	    </xsl:when>
	  </xsl:choose>
	</xsl:when>
      </xsl:choose>
    </xsl:variable>
      
    <xsl:variable name="medium">
      <xsl:choose>
	<!-- DC: prefer RDA digital file characteristics, then RDA carrier, then GMD, then default to 'book' -->
	<xsl:when test="$rda_carrier and not($rda_carrier = 'unspecified')">
	  <xsl:choose>
	    <xsl:when test="$rda_carrier='volume'">
	      <xsl:text>book</xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:choose>
		<xsl:when test="$digital_file_characteristics">
		  <xsl:value-of select="$digital_file_characteristics"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$rda_carrier"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>

	<xsl:when test="$rda_carrier_b"> <!-- DC: Apollo (eg Rainy River) doesn't use 338$a, just 338$b.... -->
	  <xsl:choose>
	    <xsl:when test="$rda_carrier_b='sg'"><xsl:text>audio cartridge</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='se'"><xsl:text>audio cylinder</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='sd'"><xsl:text>audio disc</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='si'"><xsl:text>sound track reel</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='sq'"><xsl:text>audio roll</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='sw'"><xsl:text>audio wire roll</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='ss'"><xsl:text>audiocassette</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='st'"><xsl:text>audiotape roll</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='sz'"><xsl:text>other</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='ck'"><xsl:text>aperture card</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='cb'"><xsl:text>computer chip cartridge</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='cd'"><xsl:text>computer disc</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='ce'"><xsl:text>computer disc cartridge</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='ca'"><xsl:text>computer tape cartridge</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='cf'"><xsl:text>computer tape cassette</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='ch'"><xsl:text>computer tape reel</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='cr'"><xsl:text>online resource</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='cz'"><xsl:text>other</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='ha'"><xsl:text>aperture card</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='he'"><xsl:text>microfiche</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='hf'"><xsl:text>microfiche cassette</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='hb'"><xsl:text>microfilm cartridge</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='hc'"><xsl:text>microfilm cassette</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='hd'"><xsl:text>microfilm reel</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='hj'"><xsl:text>microfilm roll</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='hh'"><xsl:text>microfilm slip</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='hg'"><xsl:text>microopaque</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='hz'"><xsl:text>other</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='pp'"><xsl:text>microscope slide</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='pz'"><xsl:text>other</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='mc'"><xsl:text>film cartridge</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='mf'"><xsl:text>film cassette</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='mr'"><xsl:text>film reel</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='mo'"><xsl:text>film roll</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='gd'"><xsl:text>filmslip</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='gf'"><xsl:text>filmstrip</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='gc'"><xsl:text>filmstrip cartridge</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='gt'"><xsl:text>overhead transparency</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='gs'"><xsl:text>slide</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='mz'"><xsl:text>other</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='eh'"><xsl:text>sereograph card</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='es'"><xsl:text>sereograph disc</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='ez'"><xsl:text>other</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='no'"><xsl:text>card</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='nn'"><xsl:text>flipchart</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='na'"><xsl:text>roll</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='nb'"><xsl:text>sheet</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='nc'"><xsl:text>book</xsl:text></xsl:when> <!-- 'volume', set to 'book' -->
	    <xsl:when test="$rda_carrier_b='nr'"><xsl:text>object</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='nz'"><xsl:text>other</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='vc'"><xsl:text>video cartridge</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='vf'"><xsl:text>videocassette</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='vd'"><xsl:text>videodisc</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='vr'"><xsl:text>videotape reel</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='vz'"><xsl:text>other</xsl:text></xsl:when>
	    <xsl:when test="$rda_carrier_b='zu'"><xsl:text>unspecified</xsl:text></xsl:when>
	  </xsl:choose>
	</xsl:when>
	
	<xsl:when test="$title_medium">
	  <xsl:value-of select="translate($title_medium, ' []/', '')"/>
	</xsl:when>
<!--
	<xsl:when test="$fulltext_a">
	  <xsl:text>electronic resource</xsl:text>
	</xsl:when>
	<xsl:when test="$fulltext_b">
	  <xsl:text>electronic resource</xsl:text>
	</xsl:when>
-->
	<xsl:when test="$journal_title">
	  <xsl:text>article</xsl:text>
	</xsl:when>

	<xsl:when test="$destiny_material_type='Destiny Material Type'">
	  <xsl:choose>
	    <xsl:when test="contains($electronic_location_url,'overdrive')">
	      <xsl:text>electronicresource</xsl:text>
	    </xsl:when>
	  </xsl:choose>
	</xsl:when>
	
	<xsl:when test="$is_cela_record='CELA'">
	  <xsl:text>CELA resource</xsl:text>
	</xsl:when>
	
	<xsl:otherwise>
	  <xsl:text>book</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="has_fulltext">
      <xsl:choose>
        <xsl:when test="marc:datafield[@tag='856']/marc:subfield[@code='q']">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:when test="marc:datafield[@tag='856']/marc:subfield[@code='i']='TEXT*'">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>no</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <pz:record>
      <xsl:for-each select="marc:controlfield[@tag='001']">
        <pz:metadata type="id">
          <xsl:value-of select="."/>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='010']">
        <pz:metadata type="lccn">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='020']">
        <pz:metadata type="isbn">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='022']">
        <pz:metadata type="issn">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='027']">
        <pz:metadata type="tech-rep-nr">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='035']">
        <pz:metadata type="system-control-nr">
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='a']">
              <xsl:value-of select="marc:subfield[@code='a']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="marc:subfield[@code='b']"/>
            </xsl:otherwise>
          </xsl:choose>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='100']">
	<pz:metadata type="author">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="author-title">
	  <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
	<pz:metadata type="author-date">
	  <xsl:value-of select="marc:subfield[@code='d']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='110']">
	<pz:metadata type="corporate-name">
	    <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="corporate-location">
	    <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
	<pz:metadata type="corporate-date">
	    <xsl:value-of select="marc:subfield[@code='d']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='111']">
	<pz:metadata type="meeting-name">
	    <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="meeting-location">
	    <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
	<pz:metadata type="meeting-date">
	    <xsl:value-of select="marc:subfield[@code='d']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='260']">
	<pz:metadata type="date">
	    <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='245']">
        <pz:metadata type="title">
          <xsl:value-of select="marc:subfield[@code='a']"/>
        </pz:metadata>
        <pz:metadata type="title-remainder">
          <xsl:value-of select="marc:subfield[@code='b']"/>
        </pz:metadata>
        <pz:metadata type="title-responsibility">
          <xsl:value-of select="marc:subfield[@code='c']"/>
        </pz:metadata>
        <pz:metadata type="title-dates">
          <xsl:value-of select="marc:subfield[@code='f']"/>
        </pz:metadata>
        <pz:metadata type="title-medium">
          <xsl:value-of select="marc:subfield[@code='h']"/>
        </pz:metadata>
        <pz:metadata type="title-number-section">
          <xsl:value-of select="marc:subfield[@code='n']"/>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='250']">
	<pz:metadata type="edition">
	    <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='260']">
        <pz:metadata type="publication-place">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
        <pz:metadata type="publication-name">
	  <xsl:value-of select="marc:subfield[@code='b']"/>
	</pz:metadata>
        <pz:metadata type="publication-date">
	  <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='300']">
	<pz:metadata type="physical-extent">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="physical-format">
	  <xsl:value-of select="marc:subfield[@code='b']"/>
	</pz:metadata>
	<pz:metadata type="physical-dimensions">
	  <xsl:value-of select="marc:subfield[@code='c']"/>
	</pz:metadata>
	<pz:metadata type="physical-accomp">
	  <xsl:value-of select="marc:subfield[@code='e']"/>
	</pz:metadata>
	<pz:metadata type="physical-unittype">
	  <xsl:value-of select="marc:subfield[@code='f']"/>
	</pz:metadata>
	<pz:metadata type="physical-unitsize">
	  <xsl:value-of select="marc:subfield[@code='g']"/>
	</pz:metadata>
	<pz:metadata type="physical-specified">
	  <xsl:value-of select="marc:subfield[@code='3']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='440' or @tag='490' or @tag='830']">
	<pz:metadata type="series-title">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag = '500' or @tag = '505' or
      		@tag = '518' or @tag = '520' or @tag = '522']">
	<pz:metadata type="description">
            <xsl:value-of select="*/text()"/>
        </pz:metadata>
      </xsl:for-each>
      
      <xsl:for-each select="marc:datafield[@tag='506']">
        <pz:metadata type="cela-notice">
	  <xsl:value-of select="marc:subfield[@code='q']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='600' or @tag='610' or @tag='611' or @tag='630' or @tag='648' or @tag='650' or @tag='651' or @tag='653' or @tag='654' or @tag='655' or @tag='656' or @tag='657' or @tag='658' or @tag='662' or @tag='69X']">
        <pz:metadata type="subject">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
	<pz:metadata type="subject-long">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text>, </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='856']">
	<pz:metadata type="electronic-url">
	  <xsl:value-of select="marc:subfield[@code='u']"/>
	</pz:metadata>
	<pz:metadata type="electronic-text">
	  <xsl:value-of select="marc:subfield[@code='y' or @code='3']"/>
	</pz:metadata>
	<pz:metadata type="electronic-note">
	  <xsl:value-of select="marc:subfield[@code='z']"/>
	</pz:metadata>
	<pz:metadata type="electronic-format-instruction">
	  <xsl:value-of select="marc:subfield[@code='i']"/>
	</pz:metadata>
	<pz:metadata type="electronic-format-type">
	  <xsl:value-of select="marc:subfield[@code='q']"/>
	</pz:metadata>
      </xsl:for-each>

      <pz:metadata type="has-fulltext">
        <xsl:value-of select="$has_fulltext"/> 
      </pz:metadata>

      <xsl:for-each select="marc:datafield[@tag='773']">
    	<pz:metadata type="citation">
	      <xsl:for-each select="*">
	        <xsl:value-of select="normalize-space(.)"/>
	        <xsl:text> </xsl:text>
    	  </xsl:for-each>
        </pz:metadata>
        <xsl:if test="marc:subfield[@code='t']">
    	  <pz:metadata type="journal-title">
	        <xsl:value-of select="marc:subfield[@code='t']"/>
          </pz:metadata>          
        </xsl:if>
        <xsl:if test="marc:subfield[@code='g']">
    	  <pz:metadata type="journal-subpart">
	        <xsl:value-of select="marc:subfield[@code='g']"/>
          </pz:metadata>          
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='852']">
        <xsl:if test="marc:subfield[@code='y']">
	  <pz:metadata type="publicnote">
	    <xsl:value-of select="marc:subfield[@code='y']"/>
	  </pz:metadata>
	</xsl:if>
	<xsl:if test="marc:subfield[@code='h']">
	  <pz:metadata type="callnumber">
	    <xsl:value-of select="marc:subfield[@code='h']"/>
	  </pz:metadata>
	</xsl:if>
	<!-- generic holdings info -->
        <pz:metadata type="holding">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
        </pz:metadata>
	<!-- Spruce locations -->
	<xsl:if test="marc:subfield[@code='d']">
	  <pz:metadata type="locallocation">
	    <xsl:value-of select="marc:subfield[@code='d']"/>
	  </pz:metadata>
	</xsl:if>
	<!-- Spruce call numbers -->
	<xsl:if test="marc:subfield[@code='c']">
	  <pz:metadata type="localcallno">
	    <xsl:value-of select="marc:subfield[@code='c']"/>
	  </pz:metadata>
	</xsl:if>
	<!-- Jolys holdings -->
	<xsl:if test="marc:subfield[@code='b']">
	  <pz:metadata type="holding-mstp-location">
	    <xsl:value-of select="marc:subfield[@code='b']"/>
	  </pz:metadata>
	  <!-- Other joint school-public Destiny systems will be the same -->
	  <!-- This is more general, and should replace holding-mstp-location -->
	  <pz:metadata type="holding-destiny-location">
	    <xsl:value-of select="marc:subfield[@code='b']"/>
	  </pz:metadata>
	</xsl:if>
      </xsl:for-each>

      <pz:metadata type="medium">
	<xsl:value-of select="$medium"/>
      </pz:metadata>
      
      <pz:metadata type="largeprint">
	<xsl:choose>
	  <!-- fixed fields in MARC start counting position at 0, in here at 1.... -->
          <xsl:when test="contains(substring(marc:controlfield[@tag='008'], 24, 1),'d')">
            <xsl:text>LARGE PRINT</xsl:text>
          </xsl:when>
          <xsl:when test="contains(substring(marc:controlfield[@tag='007'], 1, 2),'tb')">
	    <xsl:text>LARGE PRINT</xsl:text>
          </xsl:when>
	  <xsl:when test="contains(marc:datafield[@tag='650']/marc:subfield[@code='a'],'Large type books.')">
	    <xsl:text>LARGE PRINT</xsl:text>
	  </xsl:when>
	</xsl:choose>
      </pz:metadata>
      
      <xsl:for-each select="marc:datafield[@tag='900']/marc:subfield[@code='a']">
        <pz:metadata type="fulltext">
          <xsl:value-of select="."/>
        </pz:metadata>
      </xsl:for-each>

      <!-- <xsl:if test="$fulltext_a">
	<pz:metadata type="fulltext">
	  <xsl:value-of select="$fulltext_a"/>
	</pz:metadata>
      </xsl:if> -->

      <xsl:for-each select="marc:datafield[@tag='900']/marc:subfield[@code='b']">
        <pz:metadata type="fulltext">
          <xsl:value-of select="."/>
        </pz:metadata>
      </xsl:for-each>

      <!-- <xsl:if test="$fulltext_b">
	<pz:metadata type="fulltext">
	  <xsl:value-of select="$fulltext_b"/>
	</pz:metadata>
      </xsl:if> -->

      <xsl:for-each select="marc:datafield[@tag='907' or @tag='901']">
        <pz:metadata type="iii-id">
	  <xsl:value-of select="marc:subfield[@code='a']"/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='926']">
        <pz:metadata type="holding">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='948']">
        <pz:metadata type="holding">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <!-- Parklands -->
      <xsl:for-each select="marc:datafield[@tag='982']">
        <pz:metadata type="holding">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
        </pz:metadata>
	<xsl:if test="marc:subfield[@code='b']">
	  <pz:metadata type="locallocation">
	    <xsl:value-of select="marc:subfield[@code='b']"/>
	  </pz:metadata>
	</xsl:if>
	<xsl:if test="marc:subfield[@code='m']">
	  <pz:metadata type="localcallno">
	    <xsl:value-of select="marc:subfield[@code='m']"/>
	  </pz:metadata>
	</xsl:if>
      </xsl:for-each>

      <xsl:for-each select="marc:datafield[@tag='991']">
        <pz:metadata type="holding">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <!-- Maplin - holdings info -->
<!--
      <xsl:for-each select="marc:datafield[@tag='852']">
        <pz:metadata type="holding">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
        </pz:metadata>
	<xsl:if test="marc:subfield[@code='d']">
	  <pz:metadata type="locallocation">
	    <xsl:value-of select="marc:subfield[@code='d']"/>
	  </pz:metadata>
	</xsl:if>
	<xsl:if test="marc:subfield[@code='c']">
	  <pz:metadata type="localcallno">
	    <xsl:value-of select="marc:subfield[@code='c']"/>
	  </pz:metadata>
	</xsl:if>
      </xsl:for-each>
-->
      <xsl:for-each select="marc:datafield[@tag='949']">
        <pz:metadata type="holding">
	  <xsl:for-each select="marc:subfield">
	    <xsl:if test="position() > 1">
	      <xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:value-of select="."/>
	  </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>
      <!-- end of holdings info for Maplin -->

      <!-- passthrough id data -->
      <xsl:for-each select="pz:metadata">
          <xsl:copy-of select="."/>
      </xsl:for-each>

      <!-- fILL -->
<!--      <pz:metadata type="symbol">
	<xsl:value-of select="$symbol"/>
      </pz:metadata>
-->      <!-- end fILL -->

      <!-- other stylesheets importing this might want to define this -->
<!--      <xsl:message>DEBUG: calling template record-hook</xsl:message> -->
      <xsl:call-template name="record-hook"/>
<!--      <xsl:message>DEBUG: done calling template record-hook</xsl:message> -->

    </pz:record>    
  </xsl:template>
  
  <xsl:template match="text()"/>

</xsl:stylesheet>
