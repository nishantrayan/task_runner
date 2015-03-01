inputFile=$1
machineList=$2
inputDir=`dirname $inputFile`
inputBasename=`basename $inputFile`
numMachines=`wc -l $machineList | cut -d" " -f1`
numInputItems=`wc -l $inputFile | cut -d" " -f1`
echo "Number of lines of input:$numInputItems"
echo "Number of machines to use:$numMachines"
splitSize=`expr $numInputItems / $numMachines`
echo "Chunk size of input:$splitSize"

# Start splitting
cd $inputDir
split -l $splitSize $inputBasename

