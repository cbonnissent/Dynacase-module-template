#! /usr/bin/env python
# -*- coding: utf-8 -*-

from string import Template
import sys

if len(sys.argv) < 2:
	familyName = raw_input("Give me your logical Name : ")
else :
	familyName = sys.argv[1]

familyName = familyName.upper()

templateCSVContent = Template(open("templateFamily.csv", "r").read())
templatePHPContent = Template(open("templateFamily.php", "r").read())

familyIcon =familyName.lower()+".png"
familyMethod = "Method."+familyName.lower()+".php"
familyDFLID = "FLD_"+familyName

csv = templateCSVContent.safe_substitute(familyName=familyName, parentFamily="", familyNameIcon=familyIcon, familyNameMethod=familyMethod, familyNameDFLDID=familyDFLID)
php = templatePHPContent.safe_substitute(familyName=familyName)

familyCSV = open("../FAM_"+familyName.lower()+".csv","w")
familyCSV.write(csv)
familyCSV.close()

familyPHP = open("../"+familyMethod,"w")
familyPHP.write(php)
familyPHP.close()
