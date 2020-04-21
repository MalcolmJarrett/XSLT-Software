Repository created for collaborative working between Jonathan Fine, Andy Parker, Jane Matthews and Malcolm Jarrett

Intended to be used to build a Heroku Website to analyse PowerPoint giles for alt text

Some notes on starting. 21st April 2020.

1. doit.py. This is Jonathan's Python code, based on Peter Flynn's original work. I believe it uses getalt.xsl, the kernel of the project. This is an XSLT file which strips out the data from the PowerPoint file.

2. There is a simple shell script showing how to invoke doit.py, doit-2020-02-12 that illustrates how to use doit.py 

3. There's also my attempt to take a dump of Joe Lanman's code form the Heroku site. Might be a useful way forward?

4. The power point mangler code is what Jane and I used to test doit.py. It allowed Jane to drop files in a Google Drive folder. The file would then be processed and a report produced.


