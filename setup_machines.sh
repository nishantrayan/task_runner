#!/bin/bash
source util.sh
getopts r restartOpt
if [ $? -eq 0 ]; then
  echo "Restart option specified"
  restart=0
fi
shift $((OPTIND-1))
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
splitSize=`python -c "from math import ceil; print ceil($numInputItems.0/$numMachines)"`
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
  targetLogFile="/tmp/log.log"
  targetMarkerFile="/tmp/marker.txt"
  cmd="~/scripts/run_script.sh ~/scripts/$scriptName ~/inputs/$inputName /tmp/ $targetLogFile $targetMarkerFile"
  # check restart flag and kill screen session and log / marker files before running screen
  test "$restart"
  if [ $? -eq 0 ]; then
    echo "Restarting screen sessions"
    runCommand $machine $privateKey "screen -X -S $inputName quit"
    runCommand $machine $privateKey "rm $targetLogFile"
    runCommand $machine $privateKey "rm $targetMarkerFile"
  fi
  runScreen $machine $privateKey "$inputName" "~/scripts/`basename $screenScript`" "$cmd"
  i=`expr $i + 1`
done < $machineList

rm -rf $inputDir/x*

