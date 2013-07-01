#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sys
import os
import os.path
import shutil
import fileinput

sys.path.append(os.path.join(os.path.dirname(__file__), 'devTools'))

from utils import copytree
from addApplication import addApplication

from tempfile import mkdtemp
from string import Template

if sys.version_info < (2, 7):
    raise "must use python 2.7 or greater"
import argparse

def parseOptions():
    argParser = argparse.ArgumentParser(
        description='create a new module with a single application'
    )
    argParser.add_argument('-m', '--moduleName',
        help = 'module name',
        dest = 'moduleName',
        required = True,
        )
    argParser.add_argument('-a', '--app',
        help = 'Application name',
        dest = 'appName',
        required = True)
    argParser.add_argument('outputDir',
        help = 'target Directory (preferably empty directory)')
    argParser.add_argument('-c', '--childof',
        help = 'parent Application',
        dest = 'childOf',
        default = '')
    argParser.add_argument('-i', '--ignore',
        action = 'append',
        help = 'ignore patterns (use it several times)',
        dest = 'ignoreList')
    args = argParser.parse_args()
    if(not args.ignoreList):
        args.ignoreList = []
    return args

def createModule(moduleName, appName, outputDir, childOf='', ignoreList=[], appShortName=''):

    toParseFiles = [
        'configure.in',
        'info.xml.in',
        'Makefile.in'
    ]

    # create tmp dir
    tempDir = mkdtemp()
    #print "working in %s"%(tempDir)
    # copy files to tmp dir (exclude some)
    ignoreList = tuple(ignoreList) + ('createModule.py', '.git', '.gitmodules', '*.md')
    #print "ignoring '%s'"%("', '".join(ignoreList))
    ignore = shutil.ignore_patterns(*ignoreList)
    copytree(os.path.dirname(__file__), tempDir, symlinks=False, ignore=ignore)
    # parse files in tmp dir
    for parsedFilePath in toParseFiles:
        parsedFileFullPath = os.path.join(tempDir, parsedFilePath)
        #print "parsing %s"%(parsedFileFullPath)

        for line in fileinput.input(parsedFileFullPath, inplace=1):
            print Template(line).safe_substitute({
            'APPNAME': appName.upper(),
            'modulename': moduleName
        }).rstrip() #strip to remove EOL duplication

    addApplication(appName, childOf=childOf, appShortName=appShortName, targetDir=tempDir)

    # move tmp dir to target dir
    copytree(tempDir, outputDir)
    shutil.rmtree(tempDir)
    return

def main():
    args = parseOptions()
    createModule(
        args.moduleName,
        args.appName,
        args.outputDir,
        childOf = args.childOf,
        ignoreList = args.ignoreList,
        appShortName = args.appName.capitalize())

if __name__ == "__main__":
    main()