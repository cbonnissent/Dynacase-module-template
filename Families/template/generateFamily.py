#! /usr/bin/env python
# -*- coding: utf-8 -*-

from string import Template
import sys

if len(sys.argv) < 2:
    print "add family logical name"
else:
    templateCSVContent = Template(open("templateFamily.csv", "r").read())
    templatePHPContent = Template(open("templateFamily.php", "r").read())
    familyName = sys.argv[1].upper()
    if len(sys.argv) > 2:
        familyParent = sys.argv[2].upper()
    else:
        familyParent =""

    familyIcon =familyName.lower()+".png"
    familyMethod = "Method."+familyName.lower()+".php"
    familyDFLID = "FLD_"+familyName
    
    csv = templateCSVContent.safe_substitute(familyName=familyName, parentFamily=familyParent, familyNameIcon=familyIcon, familyNameMethod=familyMethod, familyNameDFLDID=familyDFLID)
    php = templatePHPContent.safe_substitute(familyName=familyName)
    
    familyCSV = open("../FAM_"+familyName.lower()+".csv","w")
    familyCSV.write(csv)
    familyCSV.close()
    
    familyPHP = open("../"+familyMethod,"w")
    familyPHP.write(php)
    familyPHP.close()
