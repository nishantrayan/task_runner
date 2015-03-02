#!/bin/bash
source util.sh

inputFile=$1
machineList=$2
privateKey=$3
scriptFile=$4
scriptName=`basename $scriptFile`
runnerScript="./run_script.sh"
screenScript="./run_screen.sh" 

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

# upload all the files
cd $currentDir
numFilesPerMachine=`expr $numInputFiles / $numMachines`
echo "Files per machine:$numFilesPerMachine"
i=0
while read machine; do
  inputFile=${inputFiles[i]}
  inputName=`basename $inputFile`
  filesArr=($inputFile)
  scpFiles $machine "~/inputs" $privateKey filesArr[@]
  scriptFiles=($scriptFile $runnerScript $screenScript)
  scpFiles $machine "~/scripts" $privateKey scriptFiles[@]
  cmd="~/scripts/run_script.sh ~/scripts/$scriptName ~/inputs/$inputName /tmp/ /tmp/log.log /tmp/marker.txt"
  runScreen $machine $privateKey "$inputName" "~/scripts/`basename $screenScript`" "$cmd"
  i=`expr $i + 1`
done < $machineList

rm -rf $inputDir/x*

