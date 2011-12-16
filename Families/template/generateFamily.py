#! /usr/bin/env python
# -*- coding: utf-8 -*-

from string import Template
import sys

if len(sys.argv) < 2:
	familyName = raw_input("Give me your logical Name : ")
else :
	familyName = sys.argv[1]

familyName = familyName.upper()

templateCSVStruct = Template(open("templateFamilyStruct.csv", "r").read())
templateCSVParam = Template(open("templateFamilyParam.csv", "r").read())
templatePHPContent = Template(open("templateFamily.php", "r").read())

familyIcon =familyName.lower()+".png"
familyMethod = "Method."+familyName.lower()+".php"
familyDFLID = "FLD_"+familyName

csvStruct = templateCSVStruct.safe_substitute(familyName=familyName)
csvParam = templateCSVParam.safe_substitute(familyName=familyName, parentFamily="", familyNameIcon=familyIcon, familyNameMethod=familyMethod, familyNameDFLDID=familyDFLID)
php = templatePHPContent.safe_substitute(familyName=familyName)

familyCSVStruct = open("../STRUCT_"+familyName.lower()+".csv","w")
familyCSVStruct.write(csvStruct)
familyCSVStruct.close()

familyCSVParam = open("../PARAM_"+familyName.lower()+".csv","w")
familyCSVParam.write(csvParam)
familyCSVParam.close()

familyPHP = open("../"+familyMethod,"w")
familyPHP.write(php)
familyPHP.close()

importStr = """
<process command="./wsh.php --api=importDocuments --file=./@APPNAME@/PARAM_$familyFileName.csv">
    <label lang="en">importing PARAM_$familyName.csv</label>
</process>
<process command="./wsh.php --api=importDocuments --file=./@APPNAME@/STRUCT_$familyFileName.csv">
    <label lang="en">importing STRUCT_$familyName.csv</label>
</process>
"""

print Template(importStr).safe_substitute(familyName=familyName, familyFileName=familyName.lower())