scriptCmd=$1
inputFile=$2
outputDir=$3
logFile=$4
markerFile=$5
i=0
if [ -f $markerFile ]; then
  i=`cat $markerFile`
  echo "Marker exists at $i"
fi
echo "Reading input from $i of input file:$inputFile"
awk "NR > $i" $inputFile | while read inputItem; do
  i=`expr $i + 1`
  cmd="$scriptCmd \"$inputItem\" $outputDir $logFile"
  echo "Running:$cmd"
  $cmd
  [ $? -eq 0 ] && echo $i > $markerFile
done 

echo "Done processing input $inputFile"