#!/bin/bash
#author: yiyan
#date: 2024-11-23
#Github: https://github.com/zhangzl96
#Blog: https://zhangzl96.github.io/

usage(){
echo "Usage:
    -i [idxfile, A text file containing the fastq file IDs. | required]
    -m [The minimum required overlap length between two
        reads to provide a confident overlap. | default: 10]
    -M [default: 1000]
    -x [Maximum allowed ratio between the number of
        mismatched base pairs and the overlap length. | default: 0.1]
    -t [threads, Threads used in flash2 | default: 1]
    -o [outpath, Processed fastq files directory | default:./2-flash]
    -h [print this help info]"
exit 1
}

# Default parameters
m=10
M=1000
x=0.1
threads=1
outpath=./2-flash


while getopts i:m:M:x:t:o:h opt; do
    case "${opt}" in
        i) idxfile=${OPTARG};;
        m) m=${OPTARG};;
        M) M=${OPTARG};;
        x) x=${OPTARG};;
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

echo -e "Sample_name\tMax_overlap\tTotal_pairs\tCombined_pairs\tUncombined_pairs\tPercent_combined" > ${outpath}/flash2_report.txt

# 定义后缀，与auto_cutadapt_paired_5.sh中输出的后缀一致
# 减少代码修改量
suffix=_1.fastq
suffix2=_2.fastq
i=0
j=0

for idx in $(cat ${idxfile});do
    if [ -f ${idx}${suffix} ] && [ -f ${idx}${suffix2} ];then
        i=$[i+1]
        flash2 ${idx}${suffix} ${idx}${suffix2} -m ${m} -M ${M} -x ${x} -t ${threads} -o ${idx} -d ${outpath} | tee report.txt
        rm ${outpath}/*notCombined_*
        rm ${outpath}/*hist*
        mv ${outpath}/${idx}.extendedFrags.fastq ${outpath}/${idx}.fastq
        while read -r line; do
            if [[ $line == *"Max overlap:"* ]]; then
                Max_overlap=$(echo "$line" | grep -oP 'Max overlap:\s+\K\d+')
            elif [[ $line == *"Total pairs:"* ]]; then
                Total_pairs=$(echo "$line" | grep -oP 'Total pairs:\s+\K\d+')
            elif [[ $line == *"Combined pairs:"* ]]; then
                Combined_pairs=$(echo "$line" | grep -oP 'Combined pairs:\s+\K\d+')
            elif [[ $line == *"Uncombined pairs:"* ]]; then
                Uncombined_pairs=$(echo "$line" | grep -oP 'Uncombined pairs:\s+\K\d+')
            elif [[ $line == *"Percent combined:"* ]]; then
                Percent_combined=$(echo "$line" | grep -oP 'Percent combined:\s+\K\d+.\d+%')
            fi
        done < report.txt
        rm report.txt
        echo -e "${idx}\t${Max_overlap}\t${Total_pairs}\t${Combined_pairs}\t${Uncombined_pairs}\t${Percent_combined}" >> ${outpath}/flash2_report.txt
    else
        j=$[j+1]
        echo "#${idx}${suffix} and ${idx}${suffix2} not exist" >> ${outpath}/flash2_report.txt
    fi
done

if [ "$j" -eq 0 ];then
    echo "${0} script successfully processed all(${i}) pairs of fastq files."
else
    echo "${0} script successfully processed ${i} pairs of fastq files, ${j} paired fastq files failed."
fi

echo "See ${outpath}/flash2_report.txt file for data processing summary."