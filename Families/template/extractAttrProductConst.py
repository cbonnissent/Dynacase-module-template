#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import codecs
import string

def parseFam ( directoryStart ) :
    os.path.walk( directoryStart, callback, '' )

def callback ( args, directory, files ) :
    print 'Scanning',directory
    for fileName in files:
        if os.path.isfile( os.path.join(directory,fileName) ) :
            if (string.lower(os.path.splitext(fileName)[1]) in ['.csv']) and (fileName[:3] in ["FAM"]) :
                extractAttr(directory,fileName)

def extractAttr(directory, fileName):
        famReader = codecs.open(os.path.join(directory,fileName), 'r', 'utf8').readlines()
        attributes = []
        for currentLine in famReader:
                currentLine = currentLine.split(";")
                if currentLine[0] == "ATTR":
                        attributes.append(currentLine[1])
        methodFileName = os.path.join(directory,"Method."+os.path.splitext(fileName)[0][4:]+".php")
        if os.path.isfile(methodFileName):
                methodPhp = codecs.open(methodFileName, 'r', 'utf8')
                methodContent = []
                modeInAttr = False
                injectAttr = True
                for currentContent in methodPhp.readlines():
                        if currentContent.find("/**ATTR**/") >= 0:
                                modeInAttr = not(modeInAttr)
                        if modeInAttr :
                                if injectAttr:
                                        methodContent.append("    /**ATTR**/\n")
                                        for currentAttr in attributes:
                                                methodContent.append("    const %s = '%s';\n"%(currentAttr, currentAttr))
                                        injectAttr = False
                        else :
                                methodContent.append(currentContent)
                methodPhp.close()
                
                if (len(methodContent) > 0) and not(modeInAttr):
                        methodPhp = codecs.open(methodFileName, 'w', 'utf8')
                        print methodFileName
                        methodPhp.writelines(methodContent)
                        methodPhp.close()

parseFam("../")