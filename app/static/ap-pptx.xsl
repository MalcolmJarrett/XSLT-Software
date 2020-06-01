<?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
        xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
        xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
        xmlns:z="http://schemas.openxmlformats.org/package/2006/relationships">

        <xsl:output method="html" />

        <xsl:param name="pptfile"/>
        <xsl:param name="slidefile"/>

        <!-- each time the parse runs it is giving a single xml file they're named slide##.xml.
        We grab the last bit (the number) to denote the slide number and put it in a variable so we can print it -->
        <xsl:variable name="slideno" select="substring-before(substring-after($slidefile,'slides/slide'),'.xml')"/>

        <!-- the relsfile has all the information in it for images or shapes used on a slide.
        We can use it to get the filename relating to an image on a slide and if it has an alt tag -->
        <xsl:variable name="relsfile" select="concat('ppt/slides/_rels/slide',$slideno,'.xml.rels')"/>

        <xsl:template match="/">
            <xsl:text disable-output-escaping="yes">&lt;div class="slide-item"&gt;</xsl:text><!-- container div for each slide -->
                <xsl:text disable-output-escaping="yes">&lt;h3&gt;Slide # </xsl:text>
                <xsl:value-of select="$slideno"/> <!-- displays the slide number -->
                <xsl:text disable-output-escaping="yes">&lt;/h3&gt;</xsl:text>

                <xsl:apply-templates match="descendant::p:sp"/> <!-- get the template for anything in p:sp -->
            <xsl:text disable-output-escaping="yes">&lt;/div&gt;</xsl:text><!-- close the container div -->
        </xsl:template>

        <!-- looking in the slide for body text -->
        <xsl:template match="p:sp">
                <!--  words on the slide -->
                <xsl:for-each select="p:txBody/a:p/a:r/a:t">
                    <xsl:text disable-output-escaping="yes">&lt;p&gt;</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text disable-output-escaping="yes">&lt;/p&gt;</xsl:text>
                </xsl:for-each>

        </xsl:template>

        <!-- <xsl:template match="p:graphicFrame">
            <xsl:text disable-output-escaping="yes">Slide has TABLE</xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;table&gt;</xsl:text>
                <xsl:for-each select="a:graphic/a:graphicData/a:tbl/a:tr">
                    <xsl:text disable-output-escaping="yes">&lt;tr&gt;</xsl:text>
                        <xsl:for-each select="a:graphic/a:graphicData/a:tbl/a:tr/a:tc/a:txBody/a:p/a:r/a:t">
                            <xsl:text disable-output-escaping="yes">&lt;td&gt;</xsl:text>
                                <xsl:value-of select="."/>
                            <xsl:text disable-output-escaping="yes">&lt;/td&gt;</xsl:text>
                        </xsl:for-each>
                    <xsl:text disable-output-escaping="yes">&lt;/tr&gt;</xsl:text>
                </xsl:for-each>
            <xsl:text disable-output-escaping="yes">&lt;/table&gt;</xsl:text>
        </xsl:template> -->

    </xsl:stylesheet>
