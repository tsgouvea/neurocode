PATHSSD=/shorthand/Neurodata/
PATHHD=/home/thiago/Neurodata/
PATHSERVER=/media/thiagoatserver/Neurodata/
PATHWORKSPACE=/home/thiago/Documents/Trodes/Workspaces/TG020.trodesconf

for animals in $(find ${PATHSSD}Spikegadgets -maxdepth 1 -mindepth 1 -type d); do
  animal=${animals##${PATHSSD}Spikegadgets/}
  #echo $animal
  [ -d ${PATHHD}Spikegadgets/$animal ] || (mkdir -p ${PATHHD}Spikegadgets/$animal && echo "Creating folder ${PATHHD}Spikegadgets/$animal")

  # PUT SESSION FILES IN A SESSION FOLDER
  for sessions in ${PATHSSD}Spikegadgets/$animal/*.rec; do
    session=$(basename "$sessions")
    extension="${session##*.}"
    session="${session%.*}"
    [ "$session" == "*" ] && continue
    echo "$session"

    mkdir ${PATHSSD}Spikegadgets/$animal/$session && echo "Creating folder ${PATHSSD}Spikegadgets/$animal/$session"
    mv ${PATHSSD}Spikegadgets/$animal/$session* ${PATHSSD}Spikegadgets/$animal/$session/ && echo "Moving session data to their own folder."
  done

  # PREPROCESSING (I.E. CONVERTING .REC TO .{DIO,LFP,MDA})
  for sessions in $(find ${PATHSSD}Spikegadgets/$animal -maxdepth 1 -mindepth 1 -type d); do
    session=${sessions##${PATHSSD}Spikegadgets/$animal/}

    # export DIO
    [ -d ${PATHHD}Preprocessed/$animal/$session/$session.DIO ] || ( echo "Exporting DIO for session $session" && exportdio -rec $sessions/$session.rec -outputdirectory ${PATHHD}Preprocessed/$animal/$session )

    # export LFP
    [ -d ${PATHHD}Preprocessed/$animal/$session/$session.LFP ] || ( echo "Exporting LFP for session $session" && exportLFP -rec $sessions/$session.rec -outputdirectory ${PATHHD}Preprocessed/$animal/$session )

    # export MDA
    [ -d ${PATHHD}Preprocessed/$animal/$session/$session.mda ] || ( echo "Exporting MDA for session $session" && exportmda -rec $sessions/$session.rec -outputdirectory ${PATHHD}Preprocessed/$animal/$session -reconfig $PATHWORKSPACE )

    # copy to server
   [ -d $PATHSERVERPP$animal/$session/$session.DIO ] || ( echo "Copying DIO to server" && mkdir $PATHSERVERPP$animal/$session/$session.DIO/ -p && cp -r $PATHHD$animal/$session/$session.DIO/* $PATHSERVERPP$animal/$session/$session.DIO/ )
   [ -d $PATHSERVERPP$animal/$session/$session.LFP ] || ( echo "Copying LFP to server" && mkdir $PATHSERVERPP$animal/$session/$session.LFP/ -p && cp -r $PATHHD$animal/$session/$session.LFP/* $PATHSERVERPP$animal/$session/$session.LFP/ )
   for sessionFiles in $PATHSSD$animal/*.rec
   [ -f $PATHSERVER$animal/$session/$session.rec ] || ( echo "Copying REC to server" && mkdir $PATHSERVER$animal/$session/ -p && cp $sessions $PATHSERVER$animal/$session/ )
  done
done
