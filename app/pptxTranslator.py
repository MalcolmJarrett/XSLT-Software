import os
import time
import re
import urllib.request
from flask import render_template, flash, request, redirect, url_for, Blueprint
from werkzeug.utils import secure_filename
from zipfile import ZipFile
from lxml import etree

bp = Blueprint('translatorBlueprint', __name__, url_prefix="")

UPLOAD_FOLDER = "/tmp/"

def make_transform(name, parser):
    # https://lxml.de/xpathxslt.html#xslt
    with open(name) as f:
        # For base_url: https://lxml.de/parsing.html#parsers
        xslt_root = etree.parse(f, parser, base_url='')

        transform = etree.XSLT(xslt_root)
        return transform

# results page showing the output from the uploaded file
@bp.route('/results/<filename>', methods=['GET', 'POST'])
def results(filename):
    filename = filename
    fileSubmitted = UPLOAD_FOLDER + filename

    """
    ZipFile is a python tool that allows you to work with zip files.
    We are using it to tell python that the .pptx file uploaded is actually a zipfile.
    the 'r' tells ZipFile that this is for reading only.
    """
    prs = ZipFile(fileSubmitted, 'r')

    # xml_combined is used to concat the content of all needed xml files
    xml_combined = "<?xml version='1.0'?>\n<files>\n"

    # not needed anymore

    # save the whole zip to the processing directory
    # with ZipFile(fileSubmitted, 'r') as zipObj:
    #     zipObj.extractall(processDest)

    with prs as pptx:
        # The parser we are going to use to read this .pptx.
        parser = etree.XMLParser()

        # Have the transform use our custom schema to resolve it.
        xsl_name = os.path.join("app/static/pptx.xsl")

        # transform command stating the schema to run into the parser.
        transform = make_transform(xsl_name, parser)


        """
        The main for loop runs through the transformed xml and appends to the slide_contents array what it finds on each loop.
        """
        for name in pptx.namelist():
            # get all xml files we need
            if "ppt/slideLayouts" in name or "ppt/slides" in name:

                # for sorting the slides in the correct order, the number of each slide is saved in a num attribute
                num = re.findall(r'\d+', name)

                # for each xml file we create a new file element with the relative path
                xml_combined = xml_combined + "\n<file name=\"" + name + "\" num=\"" + str(num[0]) + "\">"
                with pptx.open(name) as f:
                    data = f.read()
                    data_no_bom = data.decode("utf-8-sig") # remove BOM of each file

                    xml_combined = xml_combined + str(data_no_bom)

                    # removing of each xml declaration in xml files (we need only one)
                    xml_combined = re.sub('<\?xml version=\"1.0\"[^>]+>', '', xml_combined)
                    xml_combined = xml_combined + "\n</file>"

    xml_combined = xml_combined + "</files>"

    # reading from string instead of file to parse
    xml_new = etree.fromstring(xml_combined)

    result = transform(xml_new)
    newXMLLoc = UPLOAD_FOLDER + str(filename) + ".xml"

    # Creating new files and writing to them the contents in the fors.
    newXML = open(newXMLLoc, "w")
    newXML.write(str(result))

    # remove the uploaded file from the tmp dir
    os.remove(fileSubmitted)
    os.remove(newXMLLoc)
    return render_template("results.html",  result = result, filename = filename)
