#!/bin/bash

appname=''
module=''
while getopts ":a:m:o:" opt; do
  case $opt in
    a)
      echo "-a was triggered, Parameter: $OPTARG" >&2
      appname=$OPTARG
      ;;
    m)
      echo "-m was triggered, Parameter: $OPTARG" >&2
      module=$OPTARG
      ;;
    o)
      echo "-o was triggered, Parameter: $OPTARG" >&2
      dir=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

echo $appname $module


mkdir $dir
if [ $? != 0 ]; then
  echo cannot create dir $dir
  exit 1;
fi
cp -r * $dir
pushd $dir
APPNAME=`echo $appname  | tr [a-z] [A-Z]`

mv TEMPLATE.app ${APPNAME}.app
mv TEMPLATE_init.php.in ${APPNAME}_init.php.in
mv TEMPLATE_en.po ${APPNAME}_en.po
mv TEMPLATE_fr.po ${APPNAME}_fr.po

sed -i -e"s/freedom-template/$module/" configure.in
sed -i -e"s/TEMPLATE/$APPNAME/" configure.in
sed -i -e"s/template/$appname/" configure.in
sed -i -e"s/TEMPLATE/$APPNAME/" ${APPNAME}.app
sed -i -e"s/template/$appname/" ${APPNAME}.app
sed -i -e"s/Template/$appname/" ${APPNAME}.app
sed -i -e"s/TEMPLATE/$APPNAME/" info.xml.in
sed -i -e"s/freedom-template/$module/" info.xml.in
