#! /usr/bin/env python
# -*- coding: utf-8 -*-

from string import Template
import sys

if len(sys.argv) < 2:
    print "add family logical name"
else:
    templateCSVContent = Template(open("templateWorkflow.csv", "r").read())
    templatePHPContent = Template(open("templateWorkflow.php", "r").read())
    familyName = "WFL_"+sys.argv[1].upper()

    csv = templateCSVContent.safe_substitute(familyName=familyName)
    php = templatePHPContent.safe_substitute(familyName=familyName)
    
    familyCSV = open("../WFL_"+familyName.lower()[4:]+".csv","w")
    familyCSV.write(csv)
    familyCSV.close()
    
    familyPHP = open("../Class."+familyName.lower()+".php","w")
    familyPHP.write(php)
    familyPHP.close()
