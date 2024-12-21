#!/bin/bash
#author: yiyan
#date: 2024-11-22
#Github: https://github.com/zhangzl96
#Blog: https://zhangzl96.github.io/
usage(){
        echo "Usage:
            -i [fqpath | default: ./]
            -s [suffix of fastq files | default: _R1.fastq.gz]
            -o [outfile name | default: fastqIDs.txt]
            -h [print this help info]"
        exit -1
}

# Default parameters
fqpath=./
suffix=_R1.fastq.gz
outfile=fastqIDs.txt

while getopts i:s:o:h opt; do
    case "${opt}" in
        i) fqpath=${OPTARG};;
        s) suffix=${OPTARG};;
        o) outfile=${OPTARG};;
        h) usage;;
        ?) usage;;
    esac
done

if [ ! -d ${fqpath} ];then
    echo "There is no dir named with ${fqpath}"
    exit
fi

n=0
touch ${outfile}

for file in ${fqpath}/*${suffix}
do
    idx=$(basename ${file%${suffix}})
    echo $idx >> ${outfile}
    n=$[n+1]
done

echo "Successfuly get $n ${suffix} names to ${outfile} in ${fqpath}!"