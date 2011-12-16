#! /usr/bin/env python
# -*- coding: utf-8 -*-

from string import Template
import sys

if len(sys.argv) < 2:
	familyName = raw_input("Give me your logical Name : ")
else :
	familyName = sys.argv[1]

familyName = "WFL_"+familyName.upper()

templateCSVContent = Template(open("templateWorkflow.csv", "r").read())
templatePHPContent = Template(open("templateWorkflow.php", "r").read())


csv = templateCSVContent.safe_substitute(familyName=familyName)
php = templatePHPContent.safe_substitute(familyName=familyName)

familyCSV = open("../WFL_"+familyName.lower()[4:]+".csv","w")
familyCSV.write(csv)
familyCSV.close()

familyPHP = open("../Class."+familyName+".php","w")
familyPHP.write(php)
familyPHP.close()


importStr = """
<process command="./wsh.php --api=importDocuments --file=./@APPNAME@/WFL_$familyFileName.csv">
    <label lang="en">importing WFL_$familyName.csv</label>
</process>
"""

print Template(importStr).safe_substitute(familyName=familyName[4:], familyFileName=familyName.lower()[4:])