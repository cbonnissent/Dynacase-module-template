#!/bin/bash
# V 1.0

usage="$0 [-o <output directory>] [-q (0|1|2)]  [-p (Y|N)] [-w (Y|N)]\ndefaults is -o \`pwd\` -q 0 -p N -w Y"

SCRIPT_PATH=`readlink -f $(dirname $0)`
TMP_DIR=`mktemp -d`

quiet=0
makepo=false
makewebinst=true
errors=false

echo_2() { if [ $quiet -lt 2 ]; then echo $1; fi;}

while getopts ":o:p:q:w:" opt; do
	case $opt in
		o)
			outputdir=$OPTARG
			;;
		p)
			if [ "$OPTARG" == "Y" ]; then
				makepo=true
			elif [ "$OPTARG" == "N" ]; then
				makepo=false
			else
				echo_2 "invalid value for -p ($OPTARG). The default will be used (N)"
			fi
			;;
		q)
			quiet=$OPTARG
			;;
		w)
			if [ "$OPTARG" == "Y" ]; then
				makewebinst=true
			elif [ "$OPTARG" == "N" ]; then
				makewebinst=false
			else
				echo_2 "invalid value for -w ($OPTARG). The default will be used (Y)"
			fi
			;;
		*)
			echo "invalid option : -$opt $OPTARG"
			echo -e $usage
			exit 1
			;;
	esac
done

shopt -s nullglob

if [ -z "$outputdir" ]; then
	outputdir=$SCRIPT_PATH
fi

if [ ! -d "$outputdir" ]; then
	echo "$outputdir n'est pas un répertoire"
	exit 1
fi

if [ ! -w "$outputdir" ]; then
	echo "le répertoire $outputdir ne possède pas les droits d'écriture"
	exit 1
fi

tar -C $SCRIPT_PATH -cf - . | tar -C $TMP_DIR -xf -
cd $TMP_DIR

LOG_FILE="$outputdir/$(basename $0 .sh)-$(date +%Y%m%d).log"

echo '' >> $LOG_FILE
echo '###########################' >> $LOG_FILE
echo '#                         #' >> $LOG_FILE
echo "#   $(date +%x) $(date +%X)   #" >> $LOG_FILE
echo '#                         #' >> $LOG_FILE
echo '###########################' >> $LOG_FILE
echo '' >> $LOG_FILE
echo "    Output directory: $outputdir" >> $LOG_FILE
echo "    tmp directory: $TMP_DIR" >> $LOG_FILE
echo "    log file: $LOG_FILE" >> $LOG_FILE
echo '' >> $LOG_FILE
echo '###########################' >> $LOG_FILE
echo '' >> $LOG_FILE

make clean &> /dev/null

echo '' >> $LOG_FILE
echo '=== autoconf ===' >> $LOG_FILE
echo '' >> $LOG_FILE
autoconf &>> $LOG_FILE
echo '' >> $LOG_FILE
echo "--- autoconf exitcode: $? ---" >> $LOG_FILE

echo '' >> $LOG_FILE
echo '=== ./configure ===' >> $LOG_FILE
echo '' >> $LOG_FILE
./configure &>> $LOG_FILE
echo '' >> $LOG_FILE
echo "--- ./configure exitcode: $? ---" >> $LOG_FILE

if $makepo; then
	echo '' >> $LOG_FILE
	echo '=== make po ===' >> $LOG_FILE
	echo '' >> $LOG_FILE
	make po &>> $LOG_FILE
	echo '' >> $LOG_FILE
	echo "--- make po exitcode: $? ---" >> $LOG_FILE
	
	nbpo=0
	for po in $TMP_DIR/*.po; do
		nbpo=$(($nbpo+1))
		cp $po $outputdir
		cp $po $SCRIPT_PATH
	done
	
	if [ $nbpo -gt 0 ]; then
		if [ $quiet -lt 2 ]; then
			echo "$nbpo po(s): "
			for po in $outputdir/*.po; do
				echo -e "\t$po"
			done
			echo -e "\tpo were copied in source dir:$SCRIPT_PATH"
		fi
	else
		echo "no po builded"
		errors=true
	fi
fi

if $makewebinst; then
	echo '' >> $LOG_FILE
	echo '=== make webinst ===' >> $LOG_FILE
	echo '' >> $LOG_FILE
	make webinst &>> $LOG_FILE
	makewebinstexitcode=$?
	echo '' >> $LOG_FILE
	echo "--- make webinst exitcode: $makewebinstexitcode ---" >> $LOG_FILE

	if [ $makewebinstexitcode -eq 0 ]; then
		nbwebinst=0
		for webinst in $TMP_DIR/*.webinst; do
			nbwebinst=$(($nbwebinst+1))
			cp $webinst $outputdir
		done

		if [ $nbwebinst -gt 0 ]; then
			if [ $quiet -lt 2 ]; then
				echo "$nbwebinst webinst(s): "
				for webinst in $outputdir/*.webinst; do
					echo -e "\t$webinst"
				done
			fi
		else
			echo "0 webinst builded"
			errors=true
		fi
	else
		echo -e "$RED no webinst builded (error generated from make webinst)$BLACK"
		errors=true
	fi
fi

if $errors; then
	echo "log file is $LOG_FILE"
	echo "tmp dir is $TMP_DIR"
	exit 1
else
	rm -rf $LOG_FILE
	rm -rf $TMP_DIR
	exit 0
fi
