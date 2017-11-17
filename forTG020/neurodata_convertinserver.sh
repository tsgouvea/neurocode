#PATHSSD=/shorthand/Neurodata/Spikegadgets/
PATHHDPP='/home/thiago/Neurodata/Preprocessed/'
PATHSERVERREC='/media/thiagoatserver/Neurodata/Spikegadgets/'
PATHSERVERPP='/media/thiagoatserver/Neurodata/Preprocessed/'
PATHWORKSPACE='/home/thiago/Documents/Trodes/Workspaces/TG020.trodesconf'

#for animals in $(find ${PATHSERVERREC} -maxdepth 1 -mindepth 1 -type d); do
  #animal=${animals##${PATHSERVERREC}}
  animal='TG020'
  echo $animal
  mkdir -p $PATHSERVERPP$animal
  # get filename.rec
  for sessions in $PATHSERVERREC$animal/$animal*/; do
    #session=${sessions##${animals}}
    #echo $sessions
    filename=$(basename "$sessions")
    #extension="${filename##*.}"
    #filename="${filename%.*}"
    echo $filename

    # export DIO
    [ -d $PATHSERVERPP$animal/$filename/$filename.DIO ] || ( echo "Exporting DIO" && exportdio -rec $sessions/$filename.rec -outputdirectory $PATHSERVERPP$animal/$filename )

    # export LFP
    [ -d $PATHSERVERPP$animal/$filename/$filename.LFP ] || ( echo "Exporting LFP" && exportLFP -rec $sessions/$filename.rec -outputdirectory $PATHSERVERPP$animal/$filename -reconfig $PATHWORKSPACE)

    # export MDA
    [ -d $PATHHDPP$animal/$filename/$filename.mda ] || ( echo "Exporting MDA" && exportmda -rec $sessions/$filename.rec -outputdirectory $PATHHDPP$animal/$filename -reconfig $PATHWORKSPACE )
  done
#done
