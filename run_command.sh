#!/bin/bash
inputFile=$1
machineList=$2
privateKey=$3
fileCount()
{
  fileName=$1
  fileCount=`wc -l $fileName | cut -d" " -f1`
}

freshFile()
{
  fileName=$1
  rm -rf $fileName
  touch $fileName
}

scpFiles()
{
  instance=$1
  baseDir=$2
  privateKey=$3
  files=$4
  echo "SCPing files to $instance"
  for file in ${files[@]}
  do
    scpCmd="scp -i $privateKey $file $instance:$baseDir/"
    echo $scpCmd
    `$scpCmd`
  done  
}

currentDir=`pwd`
inputDir=`dirname $inputFile`
inputBasename=`basename $inputFile`
file_instance_map_file="/tmp/file_instance_map_file"
fileCount $machineList
numMachines=$fileCount
fileCount $inputFile
numInputItems=$fileCount
echo "Number of lines of input:$numInputItems"
echo "Number of machines to use:$numMachines"
splitSize=`expr $numInputItems / $numMachines`
echo "Chunk size of input:$splitSize"

# Start splitting
rm -rf $inputDir/x*
cd $inputDir
split -l $splitSize $inputBasename
cd $currentDir
inputFiles=(`ls $inputDir/x*`)
echo "Input files:${inputFiles[@]}"
numInputFiles=$(ls $inputDir/x* | wc -l)
echo "Split generated $numInputFiles files"

# create map of files to upload
cd $currentDir
numFilesPerMachine=`expr $numInputFiles / $numMachines`
echo "Files per machine:$numFilesPerMachine"
i=0
while read machine; do
  j=0
  filesArr=()
  while [ $j -lt $numFilesPerMachine ]; do
    inputFile=${inputFiles[i]} 
    filesArr+=(`readlink -f $inputFile`)
    i=`expr $i + 1`
    j=`expr $j + 1`
  done
  scpFiles $machine "~/inputs" $privateKey ${filesArr[@]}
  echo "$machine,$files" >> $file_instance_map_file
done < $machineList
#scpFiles ${instanceFileMap[@]}

rm -rf $inputDir/x*
