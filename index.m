pathNeurodata = '/Volumes/Neurodata/';
animal = 'TG020';
sessions = {'TG020_09-06-2017_12_17_33','TG020_09-11-2017\(17_41_07\)',...
    'TG020_09-12-2017\(16_20_41\)','TG020_20170927_155601'};

%% EXPORT
for i=1:length(sessions)
    session = sessions{i};
    %% CHECK THAT .REC FILE EXISTS
    pathREC = fullfile(pathNeurodata,'Spikegadgets',animal,session,[session '.rec']);
%     assert(exist(pathREC)==2) %#ok<EXIST>
    
    %% EXPORTLFP and DIO
    pathLFPdest = fullfile(pathNeurodata, 'Preprocessed', animal, session);    
    cmd = ['~/Trodes_MacOSX_v1.5.0/exportLFP -rec ' pathREC ' -outputdirectory ' pathLFPdest];% $sessions -outputdirectory $PATHHD$animal/$filename )]
    status = unix(cmd);
    assert(status==0)
    
    %% EXPORTLFP and DIO
    pathLFPdest = fullfile(pathNeurodata, 'Preprocessed', animal, session);    
    cmd = ['~/Trodes_MacOSX_v1.5.0/exportdio -rec ' pathREC ' -outputdirectory ' pathLFPdest];% $sessions -outputdirectory $PATHHD$animal/$filename )]
    status = unix(cmd);
    assert(status==0)
end

%% ANALYZE
