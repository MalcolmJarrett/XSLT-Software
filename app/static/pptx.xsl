<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
    xmlns:z="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:output method="html" indent="yes"/>


    <!-- list of slides -->
    <xsl:variable name="slides" select="//file[contains(@name, 'slides/slide')]"/>

    <!-- list of slide rels -->
    <xsl:variable name="slides.rels" select="//file[contains(@name, 'slides/_rels/slide')]"/>

    <!-- list of slide master layouts -->
    <xsl:variable name="slides.layout" select="//file[contains(@name, 'slideLayouts/slideLayout')]"/>

    <xsl:template match="/">

        <p>Total slides: <xsl:value-of select="count($slides)"/></p>


        <xsl:for-each select="$slides">
            <xsl:sort select="@name"/>
            <div class="slide-item">
                <!-- container div for each slide -->
                <h3>Slide <xsl:value-of select="position()"/>
                    <!-- displays the slide number -->
                </h3>


                <!-- initial template for a slide -->
                <xsl:apply-templates select=".//p:spTree"/>


            </div>
        </xsl:for-each>
    </xsl:template>



    <xsl:template match="p:spTree">
        <!-- only relecant nodes applied here -->
        <xsl:apply-templates select="p:sp | p:graphicFrame | p:pic"/>
    </xsl:template>



    <xsl:template match="p:sp">

        <!-- Shape (e.g. rectangle for the text)
        - if a shape is created on a slide, the informations occur on the slide
        - if the shape comes from the slide master, it needs to read the referenced slide layout
          - the slide layout is connected with a idx attribute of the shape
        - the correct slide reference is located in the corresponding slide.xml.rels files

        -->

        <xsl:variable name="slide.name" select="ancestor::file/@name"/>
        <xsl:variable name="slide.num"
            select="substring-before(substring-after($slide.name, '/slides/slide'), '.xml')"/>
        <xsl:variable name="slide.rels.name" select="concat('_rels/slide', $slide.num, '.xml.rels')"/>
        <xsl:variable name="slide.layout.name"
            select="substring-after($slides.rels[contains(@name, $slide.rels.name)]/*/*/@Target, '../')"/>

        <xsl:variable name="slide.layout.node"
            select="$slides.layout[contains(@name, $slide.layout.name)]"/>

        <!-- check what kind of shape it is -->
        <xsl:variable name="shape.type" select=".//p:nvPr/p:ph/@type"/>
        <xsl:variable name="shape.index" select=".//p:nvPr/p:ph/@idx"/>
        <!-- needs for the slideLayout -->

        <xsl:variable name="shape.type.value">
            <xsl:choose>

                <!-- the title types are ... -->
                <xsl:when test="$shape.type = 'ctrTitle'">ctrTitle</xsl:when>
                <xsl:when test="$shape.type = 'subTitle'">subTitle</xsl:when>
                <xsl:when test="$shape.type = 'title'">title</xsl:when>


                <!-- It's currently not clear, how to detect a shape with a list
                      (Some information are not possible (yet) to detect correct)
                 - inside a shape, there are no information. If a list only have one level, there
                   are no informations available on the slide.
                 - to find out, check the slide where the layout comes from.
                 - via the shape index, the correct information can be found
                -->
                <xsl:when
                    test="

                        (
                        $slide.layout.node//p:sp[.//p:nvPr//p:ph/@idx = $shape.index]//a:p/a:pPr[@lvl] or
                        p:txBody/a:p/a:pPr[@lvl]
                        )"
                    >list</xsl:when>

                <xsl:otherwise>nothing yet</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div>

            <xsl:attribute name="class">
                <xsl:value-of select="$shape.type.value"/>
            </xsl:attribute>

            <!-- the template handles a parameter to check what kind of shape it is -->
            <xsl:apply-templates select="p:txBody">
                <xsl:with-param name="shape.type" select="$shape.type.value"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="p:txBody">
        <xsl:param name="shape.type"/>

        <xsl:choose>

            <!-- only if there is a list (check if it is a list in template p:sp) -->

            <xsl:when test="$shape.type = 'list'">

                <!-- always <ul> -->
                <xsl:text disable-output-escaping="yes">&lt;ul></xsl:text>

                <!-- loop through all paragraphs (with text) -->
                <xsl:for-each select="a:p[a:r]">

                    <!-- curent list level: if there is no @lvl attribute, but's in a shape with bullets, set it to 0
                      - all higer levels have numbers

                    -->
                    <xsl:variable name="current.list.level">
                        <xsl:choose>
                            <xsl:when test="not(a:pPr/@lvl)">0</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="a:pPr/@lvl"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <!-- previous list level -->
                    <xsl:variable name="prev.list.level">
                        <xsl:choose>
                            <xsl:when test="not(preceding-sibling::a:p[1]/a:pPr/@lvl)">0</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="preceding-sibling::a:p[1]/a:pPr/@lvl"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <!-- next list level -->
                    <xsl:variable name="next.list.level">
                        <xsl:choose>
                            <xsl:when test="not(following-sibling::a:p[1]/a:pPr/@lvl)">0</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="following-sibling::a:p[1]/a:pPr/@lvl"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <!--

                     Pyton uses the XSLT 1.0 processor
                     - because of that, it's not possible to use the xsl:for-each-group - syntax
                     - via grouping it's easier possible to create a deep structure from a flat one
                     - here we check each list entry (always on the same structure level)
                      - the difference is the lvl-attribute
                      - writing all necessary <ul><li> elements with xsl:text

                    -->

                    <xsl:text>
</xsl:text>

                    <xsl:text disable-output-escaping="yes">&lt;li></xsl:text>


                    <xsl:apply-templates/>


                    <xsl:if test="$next.list.level > $current.list.level">
                        <xsl:text disable-output-escaping="yes">&lt;ul></xsl:text>
                    </xsl:if>
                    <xsl:if test="$next.list.level &lt; $current.list.level">
                        <xsl:text disable-output-escaping="yes">&lt;/li>&lt;/ul>&lt;/li></xsl:text>
                    </xsl:if>
                    <xsl:if test="$next.list.level = $current.list.level">
                        <xsl:text disable-output-escaping="yes">&lt;/li></xsl:text>
                    </xsl:if>

                </xsl:for-each>

                <xsl:text disable-output-escaping="yes">&lt;/ul></xsl:text>


            </xsl:when>
            <xsl:otherwise>
                <div class="{$shape.type}">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>

        </xsl:choose>


    </xsl:template>


    <!-- paragraph -->
    <xsl:template match="a:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- soft break -->
    <xsl:template match="a:br">
        <br/>
    </xsl:template>

    <!-- something like running text
        - in this element, properties could be defined (like bold)
        -->
    <xsl:template match="a:r">

        <xsl:variable name="slide.name" select="ancestor::file/@name"/>
        <xsl:variable name="slide.num"
            select="substring-before(substring-after($slide.name, '/slides/slide'), '.xml')"/>
        <xsl:variable name="slide.rels.name" select="concat('_rels/slide', $slide.num, '.xml.rels')"/>
        <xsl:variable name="slide.layout.name"
            select="substring-after($slides.rels[contains(@name, $slide.rels.name)]/*/*/@Target, '../')"/>
        <xsl:variable name="slide.layout.node"
            select="$slides.layout[contains(@name, $slide.layout.name)]"/>

        <xsl:variable name="slide.rels.node"
            select="$slides.rels[contains(@name, $slide.rels.name)]"/>
        <span>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="a:rPr/@b = '1'">bold</xsl:when>
                    <xsl:when test="a:rPr/@i = '1'">italic</xsl:when>
                    <xsl:otherwise>none</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <xsl:variable name="linkId" select="a:rPr/a:hlinkClick/@r:id"/>
            <xsl:choose>
                <xsl:when test="$linkId != ''">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$slide.rels.node/*/*[@Id = $linkId]/@Target"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>



    <!-- currently only table elements are allowed here
    - maybe also other graphic elements are possible
    -->
    <xsl:template match="p:graphicFrame">
        <xsl:apply-templates select=".//a:tbl"/>
    </xsl:template>

    <!-- tables -->
    <xsl:template match="a:tbl">
        <table>
            <xsl:apply-templates select="a:tr"/>
        </table>
    </xsl:template>

    <!-- table rows -->
    <xsl:template match="a:tr">
        <tr>
            <!-- if a firstRow attribute available, the first row (header) looks a little bit different -->
            <xsl:if test="not(preceding-sibling::a:tr) and parent::a:tbl/a:tblPr/@firstRow = '1'">
                <xsl:attribute name="class">tableRowFirst</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <!-- table cells -->
    <xsl:template match="a:tc">
        <td>
            <xsl:apply-templates select=".//a:p"/>
        </td>
    </xsl:template>

    <!-- Images -->
    <xsl:template match="p:pic">

        <xsl:variable name="slide.name" select="ancestor::file/@name"/>
        <xsl:variable name="slide.num"
            select="substring-before(substring-after($slide.name, '/slides/slide'), '.xml')"/>
        <xsl:variable name="slide.rels.name" select="concat('_rels/slide', $slide.num, '.xml.rels')"/>
        <xsl:variable name="slide.layout.name"
            select="substring-after($slides.rels[contains(@name, $slide.rels.name)]/*/*/@Target, '../')"/>
        <xsl:variable name="slide.layout.node"
            select="$slides.layout[contains(@name, $slide.layout.name)]"/>

        <xsl:variable name="slide.rels.node"
            select="$slides.rels[contains(@name, $slide.rels.name)]"/>

        <!-- id for image in rels file -->
        <xsl:variable name="id" select="descendant::a:blip/@r:embed"/>


        <!-- image filename and description -->
        <div class="image">
            <p>
                <b>PIC:</b>
                <xsl:text> </xsl:text>
                <xsl:value-of
                    select="$slide.rels.node//*[name() = 'Relationship'][@Id = $id]/@Target"/>
                <xsl:text>, </xsl:text>
                <b>DESC: </b>
                <xsl:value-of select="p:nvPicPr/p:cNvPr/@descr"/>
            </p>
        </div>

    </xsl:template>
</xsl:stylesheet>
