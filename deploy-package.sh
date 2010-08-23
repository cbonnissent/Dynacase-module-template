#!/bin/bash
# V1.0

usage="$0 [-c <config file>]"

SCRIPT_PATH=`readlink -f $(dirname $0)`
TMP_DIR=`mktemp -d`
WRITE_CONFIG=false

quiet=0
seems_valid_wiff_dir=false
seems_valid_context=false

echo_2() { if [ $quiet -lt 2 ]; then echo $1; fi;}

echo_1() { if [ $quiet -lt 1 ]; then echo $1; fi;}

validate_wiff_dir(){
	if [ -z "$wiff_dir_path_input" ]; then
		seems_valid_wiff_dir=false
		return 0
	elif [ ! -d "$wiff_dir_path_input" ]; then
		echo "$wiff_dir_path does not seems to be a valid wiff dir path"
		seems_valid_wiff_dir=false
		return 0
	fi

	if [ -f "$wiff_dir_path_input/wiff.php" -a -f "$wiff_dir_path_input/wiff" ]; then
		wiff_dir_path=$wiff_dir_path_input
		seems_valid_wiff_dir=true
		return 0
	fi

	seems_valid_wiff_dir=false
	return 1
}

save_config(){
	echo "################################################" > $configfile
	echo "#" >> $configfile
	echo "#  date de génération: $(date)" >> $configfile
	echo "#" >> $configfile
	echo "################################################" >> $configfile
	echo "" >> $configfile
	echo "wiff_dir_path='$wiff_dir_path'" >> $configfile
	echo "target_context='$target_context'" >> $configfile
}

initcontexts(){
	OLDIFS=$IFS
	IFS=$'\012'
	contexts=( $(sudo $wiff_dir_path/wiff list context) )
	IFS=$OLDIFS
	rangcontext=0
	for context in "${contexts[@]}"; do
		acontexts[$rangcontext]=$context
		if [ "$context" = "$target_context" ]; then
			defaultrang=$rangcontext
		fi
		rangcontext=$(($rangcontext+1))
	done
}

askcontext(){
	echo "--- Contextes disponibles ---"
	for (( i = 0 ; i < ${#acontexts[@]} ; i++ )); do
		if [ -z $defaultrang ]; then
			thisisdefault=''
		elif [ $i -eq $defaultrang ]; then
			thisisdefault="\t<-- default value"
		else
			thisisdefault=''
		fi
		echo -e "\t[$i] ${acontexts[$i]}$thisisdefault"
	done
	read -e -p "Dans quel contexte souhaitez-vous publier? [$defaultrang] " rangcontext_input
	if [ -z $rangcontext_input ]; then
		rangcontext_input=$defaultrang
	fi
	if [ $rangcontext_input -gt ${#acontexts[@]} ]; then
		echo "Veuillez saisir un nombre entre 0 et ${#acontexts[@]}"
		return 1
	fi
	target_context=${acontexts[$rangcontext_input]}
	seems_valid_context=true
}

deploy_webinst(){
	if [ -z $1 ]; then
		return 1
	fi
	basewebinst=$(basename $1 .webinst)
	modulename=`expr match "$basewebinst" '^\(.*\)-[0-9][0-9.]*-[0-9][0-9]*$'`
	installedmodule=`sudo "$wiff_dir_path/wiff" context "$target_context" module list installed | grep "$modulename"`
	grepstatus=$?
	echo "grepstatus=$grepstatus"
	if [ $grepstatus -eq 0 ]; then
		echo "$installedmodule detected. UPGRADE with $1"
		sudo "$wiff_dir_path/wiff" context "$target_context" module upgrade --force "$1" 2> /dev/null
	else
		echo "$modulename not detected. INSTALLATION with $1"
		sudo "$wiff_dir_path/wiff" context "$target_context" module install --force "$1" 2> /dev/null
	fi
	
	return $?
}

while getopts ":c:" opt; do
	case $opt in
		c)
			configfile=$OPTARG
			;;
	esac
done

if [ -z "$configfile" ]; then
	configfile="$SCRIPT_PATH/deploy-package.config"
fi
configdir=`readlink -f $(dirname $configfile)`

if [ -w "$configfile" ]; then
	WRITE_CONFIG=true
elif [ -f "$configfile" ]; then
	echo "$configfile is not writable. it will be used read-only."
	WRITE_CONFIG=false
elif [ -w $configdir ]; then
	echo "$configfile does not exists. it will be created."
	touch $configfile
	WRITE_CONFIG=true
else
	echo "$configfile does not exixst and $configdir is not writable."
	WRITE_CONFIG=false
fi

if [ -f $configfile ]; then
	. $configfile 2> /dev/null
	if [ $? -gt 0 ]; then
		echo_2 "an error occured when sourcing $configfile"
	fi
fi

while ! $seems_valid_wiff_dir; do
	read -e -p "please specify wiff directory path [$wiff_dir_path] " wiff_dir_path_input
	if [ -z $wiff_dir_path_input ]; then
		wiff_dir_path_input=$wiff_dir_path
	fi
	validate_wiff_dir
done

initcontexts

while ! $seems_valid_context; do
	askcontext
done

if $WRITE_CONFIG; then
	save_config
	if [ $? -gt 0 ]; then
		echo_2 "an error occured when trying to save config to $configfile"
		echo_2 "current config will only be used for this session"
	fi
fi

chmod 777 $TMP_DIR

$SCRIPT_PATH/build-package.sh -o $TMP_DIR -q 2
buildstatus=$?
if [ $buildstatus -gt 0 ]; then
	echo "an error occured in webinst generation"
	exit $((buildstatus+1))
fi

for webinst in $TMP_DIR/*.webinst; do
	deploy_webinst $webinst
done

deploystatus=$?
if [ $deploystatus -gt 0 ]; then
        echo "an error occured in webinst deployment"
        exit $((deploystatus+1))
fi

