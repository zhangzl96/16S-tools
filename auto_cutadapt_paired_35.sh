#!/bin/bash
#author: yiyan
#date: 2024-11-25
#Github: https://github.com/zhangzl96
#Blog: https://zhangzl96.github.io/

usage(){
echo "Usage:
    -i [idxfile, A text file containing the fastq file IDs. | required]
    -s [suffix, The suffix of forward fastq file(the entire string following the ID). | default: _R1.fastq.gz]
    -f [primer1, The forward primer used for fastq file sequencing. | required]
    -r [primer2, The reverse primer used for fastq file sequencing. | required]
    -t [threads, Threads used in cutadapter | default: 1]
    -o [outpath, Processed fastq files directory | default:./1-cutadapt]
    -h [print this help info]
eg:
    auto_cutadapt_paired_53.sh \
        -i fastqIDs.txt \
        -s _R1.fastq.gz \
        -f GTGCCAGCMGCCGCGGTAA \
        -r GGACTACHVGGGTWTCTAAT \
        -t 8 -o ../1-cutadapt"
exit 1
}

# Default parameters
suffix=_R1.fastq.gz
threads=1
outpath=./1-cutadapt

while getopts i:s:f:r:t:o:h opt; do
    case "${opt}" in
        i) idxfile=${OPTARG};;
        s) suffix=${OPTARG};;
        f) primer1=${OPTARG};;
        r) primer2=${OPTARG};;
        t) threads=${OPTARG};;
        o) outpath=${OPTARG};;
        h) usage;;
        ?) usage;;
    esac
done

if [ -z "${idxfile}" ]; then
    echo "Error: Missing required argument -i"
    usage
fi

suffix2="${suffix/1/2}"

if [ ! -f ${idxfile} ];then
    echo "There is no file named with ${idxfile}"
    exit
fi

if [ ! -d ${outpath} ];then
    echo "Creating directory: ${outpath}"
    mkdir -p ${outpath}
else
    echo "Out directory: ${outpath} has been created!"
fi

i=0
j=0

for idx in $(cat ${idxfile});do
    if [ -f ${idx}${suffix} ] && [ -f ${idx}${suffix2} ];then
        i=$[i+1]
        cutadapt -a ${primer1} -g ${primer2} \
            -o ${outpath}/${idx}_1.fastq -p ${outpath}/${idx}_2.fastq \
            ${idx}${suffix} ${idx}${suffix2} \
            -j ${threads} -q 20 -m 40| tee report.txt
        rm report.txt
        # echo -e "${idx}\t${R1_Total}\t${R1_Cut}\t${R2_Total}\t${R2_Cut}" >> ${outpath}/cutadapt_report.txt
    else
        j=$[j+1]
        echo "#${idx}${suffix} and ${idx}${suffix2} not exist" >> ${outpath}/cutadapt_report.txt
    fi
done