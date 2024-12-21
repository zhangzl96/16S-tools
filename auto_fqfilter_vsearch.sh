#!/bin/bash
#author: yiyan
#date: 2024-11-26
#Github: https://github.com/zhangzl96
#Blog: https://zhangzl96.github.io/

usage(){
echo "Usage:
    -i [fqpath, Fastq file path. | default: .]
    -f [idxfile, A text file containing the fastq file IDs. | required]
    -s [suffix, The suffix of forward fastq file(the entire string following the ID). | default: .fastq]
    -r [fastq_maxee_rate, Discard if expected error rate is higher. | default: 0.04]
    -m [fastq_minlen, Discard if length of sequence is shorter. | required]
    -M [fastq_maxlen, Discard if length of sequence is longer. | required]
    -t [threads, Threads used in cutadapter | default: 1]
    -o [outpath, Processed fastq files directory | default: ./]
    -h [print this help info]
eg:
    auto_fqfilter_vsearch.sh \
        -i ./ -f fastqIDs.txt \
        -s .fastq -r 0.04 -m 251 -M 256 \
        -t 8 -o 3-fastq-filter"
exit 1
}

# Default parameters
fqpath=.
suffix=.fastq
threads=1
outpath=./3-fastq-filter

while getopts i:f:s:r:m:M:t:o:h opt; do
    case "${opt}" in
        i) fqpath=${OPTARG};;
        f) idxfile=${OPTARG};;
        s) suffix=${OPTARG};;
        r) maxee_rate=${OPTARG};;
        m) minlen=${OPTARG};;
        M) maxlen=${OPTARG};;
        t) threads=${OPTARG};;
        o) outpath=${OPTARG};;
        h) usage;;
        ?) usage;;
    esac
done

for idx in $(cat ${idxfile});do
    if [ -f ${idx}${suffix} ];then
        i=$[i+1]
        vsearch --fastq_filter ${fqpath}/${idx}${suffix} \
            --fastq_maxee_rate ${maxee_rate} \
            --fastq_minlen ${minlen} --fastq_maxlen ${maxlen} \
            --fastqout ${outpath}/${idx}${suffix} --threads ${threads}
    else
        j=$[j+1]
        echo "#${fqpath}/${idx}${suffix} not exist" >> ${outpath}/vsearch_report.txt
    fi
done