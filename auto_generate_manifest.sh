#!/bin/bash
#author: yiyan
#date: 2024-11-26
#Github: https://github.com/zhangzl96
#Blog: https://zhangzl96.github.io/

usage(){
echo "Usage:
    -f [format [single or paired], Single-end or paired-end read data for four samples. | required]
    -d [fastqdir | required]
    -s [suffix, The suffix of fastq file(the entire string following the ID). | required]
    -o [outfile, manifest file. | default: manifest.txt]
    -h [print this help info]
eg:
    auto_generate_manifest.sh \\
        -f single \\
        -d ~/project/fqdata \\
        -s .fastq \\
        -o manifest.txt"
exit 1
}

# Default parameters
outfile=manifest.txt

while getopts f:d:s:o:h opt; do
    case "${opt}" in
        f) format=${OPTARG};;
        d) fastqdir=${OPTARG};;
        s) suffix=${OPTARG};;
        o) outfile=${OPTARG};;
        h) usage;;
        ?) usage;;
    esac
done

if [ -z "${fastqdir}" ]; then
    echo "Error: Missing required argument -d"
    usage
fi

sigleEnd(){
echo -e "sample-id\tabsolute-filepath" > ${outfile}
for file in ${fastqdir}/*${suffix};do
    idx=${file%${suffix}}
    echo ${idx##*/}
    echo $(realpath $file)
done | paste - - >> ${outfile}
}

pairedEnd(){
dirpath=$(realpath $fastqdir)
suffix2=${suffix//1/2}
echo -e "sample-id\tforward-absolute-filepath\treverse-absolute-filepath" > ${outfile}
for file in ${fastqdir}/*${suffix};do
    idx=$(basename $file "${suffix}")
    echo $idx
    echo ${dirpath}/${idx}${suffix}
    echo ${dirpath}/${idx}${suffix2}
done | paste - - - >> ${outfile}
}

if [ "${format}" = "single" ];then
    sigleEnd
elif [ "${format}" = "paired" ];then
    pairedEnd
else
    echo "Error: Format error with argument -f"
fi