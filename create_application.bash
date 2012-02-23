#!/bin/bash

usage="$0 -a <appname> -m <modulename> -o <output directory> [-f]"
usage="${usage}\n\t-f makes cp overwrite files without prompting"

SCRIPT_PATH=`readlink -f $(dirname $0)`

CP_COMMAND="cp -i"

appname=''
module=''
while getopts ":a:m:o:fh" opt; do
  case $opt in
    a)
      appname=$OPTARG
      ;;
    m)
      module=$OPTARG
      ;;
    o)
      dir=$OPTARG
      ;;
    f)
      CP_COMMAND="cp"
      ;;
    h)
      helpCalled=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo -e ${usage}
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo -e ${usage}
      exit 1
      ;;
  esac
done

if [ ! -z "${helpCalled}" ]; then
  echo -e ${usage}
  exit 0
elif [ -z "$appname" -o -z "$module" -o -z "$dir" ]; then
  echo -e ${usage}
  exit 1
else
  echo "Output directory: $dir" >&2
  echo "Module name: $module" >&2
  echo "Application name: $appname" >&2
  echo "" >&2
fi

echo -e "copying files to ${dir}" >&2

mkdir -p "${dir}"
if [ $? != 0 ]; then
  echo "cannot create dir ${dir}"
  exit 1;
fi
${CP_COMMAND} -r "${SCRIPT_PATH}"/* "${dir}"
if [ $? != 0 ]; then
  echo "cannot copy files to ${dir}"
  exit 1;
fi
${CP_COMMAND} "${SCRIPT_PATH}/.gitmodules" "${dir}"
if [ $? != 0 ]; then
  echo "cannot copy .gitmodules file to ${dir}"
  exit 1;
fi
rm -f "${dir}/create_application.bash"
if [ $? != 0 ]; then
  echo "cannot delete ${dir}/create_application.bash"
  exit 1
fi

pushd $dir >/dev/null

echo "renaming files" >&2

APPNAME=`echo $appname  | tr [a-z] [A-Z]`

mv TEMPLATE.app ${APPNAME}.app
mv TEMPLATE_init.php.in ${APPNAME}_init.php.in
mv TEMPLATE_en.po ${APPNAME}_en.po
mv TEMPLATE_fr.po ${APPNAME}_fr.po

echo -e "injecting variable parts in files" >&2

sed -i -e"s/freedom-template/$module/" configure.in
sed -i -e"s/TEMPLATE/$APPNAME/" configure.in
sed -i -e"s/template/$appname/" configure.in
sed -i -e"s/TEMPLATE/$APPNAME/" ${APPNAME}.app
sed -i -e"s/template/$appname/" ${APPNAME}.app
sed -i -e"s/Template/$appname/" ${APPNAME}.app
sed -i -e"s/TEMPLATE/$APPNAME/" info.xml.in

echo "" >&2
echo "application successfully initialised in ${dir}" >&2
echo "application successfully initialised in ${dir}"
