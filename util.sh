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
  declare -a files=("${!4}")
  echo "SCPing files to $instance"
  for file in "${files[@]}"
  do
    `echo "mkdir $baseDir" | ssh -i $privateKey $instance /bin/sh`
    scpCmd="scp -i $privateKey $file $instance:$baseDir/`basename $file`"
    echo $scpCmd
    `$scpCmd`
  done  
}

runCommand()
{
  instance=$1
  privateKey=$2
  cmd=$3
  echo "Executing command on $instance:$cmd"
  `echo "$cmd" | ssh -i $privateKey $instance /bin/bash`
}

runScreen()
{
  instance=$1
  privateKey=$2
  screenName=$3
  screenScript=$4
  cmd=$5
  screenCmd="$screenScript $screenName \"$cmd\""
  echo "Screen command:$screenCmd"
  `echo "$screenCmd" | ssh -i $privateKey $instance /bin/bash`
}
