#!/bin/bash

usage="$0 -a <appname> -m <modulename> -o <output directory>"

appname=''
module=''
while getopts ":a:m:o:" opt; do
  case $opt in
    a)
      echo "Application name: $OPTARG" >&2
      appname=$OPTARG
      ;;
    m)
      echo "Module name: $OPTARG" >&2
      module=$OPTARG
      ;;
    o)
      echo "Output directory: $OPTARG" >&2
      dir=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo $usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo $usage
      exit 1
      ;;
  esac
done


if [ -z "$appname" -o -z "$module" -o -z "$dir" ]; then
     echo $usage
      exit 1
fi

mkdir -p $dir
if [ $? != 0 ]; then
  echo cannot create dir $dir
  exit 1;
fi
cp -r * $dir
pushd $dir >/dev/null
APPNAME=`echo $appname  | tr [a-z] [A-Z]`

mv TEMPLATE.app ${APPNAME}.app
mv TEMPLATE_init.php.in ${APPNAME}_init.php.in
mv TEMPLATE_en.po ${APPNAME}_en.po
mv TEMPLATE_fr.po ${APPNAME}_fr.po
find . -type d -name CVS -exec rm -fr {} \; 2>/dev/null
rm -f create_application.bash

sed -i -e"s/freedom-template/$module/" configure.in
sed -i -e"s/TEMPLATE/$APPNAME/" configure.in
sed -i -e"s/template/$appname/" configure.in
sed -i -e"s/TEMPLATE/$APPNAME/" ${APPNAME}.app
sed -i -e"s/template/$appname/" ${APPNAME}.app
sed -i -e"s/Template/$appname/" ${APPNAME}.app
sed -i -e"s/TEMPLATE/$APPNAME/" info.xml.in
sed -i -e"s/freedom-template/$module/" info.xml.in
