#!/bin/bash
# V 1.0

usage="$0 [-o <output directory>] [-q (0|1|2)]"

SCRIPT_PATH=`readlink -f $(dirname $0)`
TMP_DIR=`mktemp -d`

quiet=0

echo_2() { if [ $quiet -lt 2 ]; then echo $1; fi;}

echo_1() { if [ $quiet -lt 1 ]; then echo $1; fi;}

while getopts ":o:q:" opt; do
	case $opt in
		o)
			outputdir=$OPTARG
			;;
		q)
			quiet=$OPTARG
			;;
	esac
done

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

echo '' >> $LOG_FILE
echo '=== make webinst ===' >> $LOG_FILE
echo '' >> $LOG_FILE
make webinst &>> $LOG_FILE
echo '' >> $LOG_FILE
echo "--- make webinst exitcode: $? ---" >> $LOG_FILE

nbwebinst=0
for webinst in $TMP_DIR/*.webinst; do
	nbwebinst=$(($nbwebinst+1))
	cp $webinst $outputdir
done

if [ $nbwebinst -gt 0 ]; then
	rm -rf $LOG_FILE
	rm -rf $TMP_DIR
	if [ $quiet -lt 1 ]; then
		echo "$nbwebinst webinst(s): "
	fi
	if [ $quiet -lt 2 ]; then
		for webinst in $outputdir/*.webinst; do
			echo -e "\t$webinst"
		done
	fi
else
	echo "no webinst build"
	echo "log file is $LOG_FILE"
	echo "tmp dir is $TMP_DIR"
	exit 1
fi
