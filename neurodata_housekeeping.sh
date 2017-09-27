PATHSSD=/shorthand/Neurodata/Spikegadgets/
PATHHD=/home/thiago/Neurodata/Preprocessed/
PATHSERVER=/media/thiagoatserver/Neurodata/Spikegadgets/
PATHSERVERPP=/media/thiagoatserver/Neurodata/Preprocessed/
PATHWORKSPACE=/home/thiago/Documents/Trodes/Workspaces/TG020.trodesconf

for animals in $(find ${PATHSSD} -maxdepth 1 -mindepth 1 -type d); do
  animal=${animals##${PATHSSD}}
  echo $animal
  mkdir -p $PATHHD$animal
  # get filename.rec
  for sessions in $PATHSSD$animal/*.rec; do
    #session=${sessions##${animals}}
    #echo $session
    filename=$(basename "$sessions")
    extension="${filename##*.}"
    filename="${filename%.*}"
    echo $filename

    # export DIO
    [ -d $PATHHD$animal/$filename/$filename.DIO ] || ( echo "Exporting DIO" && exportdio -rec $sessions -outputdirectory $PATHHD$animal/$filename )

    # export LFP
    [ -d $PATHHD$animal/$filename/$filename.LFP ] || ( echo "Exporting LFP" && exportLFP -rec $sessions -outputdirectory $PATHHD$animal/$filename )

    # export MDA
    [ -d $PATHHD$animal/$filename/$filename.mda ] || ( echo "Exporting MDA" && exportmda -rec $sessions -outputdirectory $PATHHD$animal/$filename -reconfig $PATHWORKSPACE )

    # copy to server
    [ -d $PATHSERVERPP$animal/$filename/$filename.DIO ] || ( echo "Copying DIO to server" && mkdir $PATHSERVERPP$animal/$filename/$filename.DIO/ -p && cp -r $PATHHD$animal/$filename/$filename.DIO/* $PATHSERVERPP$animal/$filename/$filename.DIO/ )
    [ -d $PATHSERVERPP$animal/$filename/$filename.LFP ] || ( echo "Copying LFP to server" && mkdir $PATHSERVERPP$animal/$filename/$filename.LFP/ -p && cp -r $PATHHD$animal/$filename/$filename.LFP/* $PATHSERVERPP$animal/$filename/$filename.LFP/ )
    [ -f $PATHSERVER$animal/$filename/$filename.rec ] || ( echo "Copying REC to server" && mkdir $PATHSERVER$animal/$filename/ -p && cp $sessions $PATHSERVER$animal/$filename/ )
  done
done
