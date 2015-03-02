screenName=$1
cmd=$2
screen -dmS $screenName sh
screen -r $screenName -p 0 -X stuff $cmd
screen -r $screenName -p 0 -X stuff $'\n'