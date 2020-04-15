import os
from zipfile import ZipFile
from lxml import etree

# To help us find 'getalt.xsl'.
module_dirname = os.path.dirname(__file__)

# https://lxml.de/resolvers.html#document-loading-in-context
class OpenResolver(etree.Resolver):

    def __init__(self, aaa):
        self.open = aaa

    def resolve(self, url, pubid, context):
        f = self.open(url)
        return self.resolve_file(f, context)

    

def make_transform(name, parser):

    # https://lxml.de/xpathxslt.html#xslt
    with open(name) as f:
        # For base_url: https://lxml.de/parsing.html#parsers
        xslt_root = etree.parse(f, parser, base_url='')
    
        transform = etree.XSLT(xslt_root)
        return transform

def doit(src):

    with ZipFile(src, 'r') as pptx:

        # Need custom resolver, that looks in the zip file.
        resolver = OpenResolver(pptx.open)
        parser = etree.XMLParser()
        parser.resolvers.add(resolver)

        # Have the transform use the custom resolver.
        xsl_name = os.path.join(module_dirname, 'getalt.xsl')
        transform = make_transform(xsl_name, parser)

        # Now process all the slides.
        for name in pptx.namelist():
            if name.startswith('ppt/slides/slide'):

                slidefile = name
                with pptx.open(name) as f:
                    slide = etree.parse(f, base_url='')
                    # This is a silent gotcha in the style sheet.
                    # For strparam see: https://lxml.de/xpathxslt.html#xpath
                    result = transform(
                        slide,
                        slidefile=etree.XSLT.strparam(slidefile),
                        pptfile=etree.XSLT.strparam(os.path.basename(src))
                    )
                    print(str(result))


if __name__ == '__main__':

    import sys
    src = sys.argv[1]
    doit(src)
