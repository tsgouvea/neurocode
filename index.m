pathNeurodata = '/Users/thiago/Neurodata';
animal = 'TG020';
sessions = {'TG020_09-06-2017_12_17_33','TG020_09-11-2017(17_41_07)',...
    'TG020_09-12-2017(16_20_41)','TG020_20170927_155601'};
%%

for i=1:length(sessions)
    assert(exist(fullfile(pathNeurodata,'Spikegadgets',animal,[sessions{i} '.rec'])))
end

%% CHECK FOR LFP




pathLFP = fullfile(pathNeurodata, 'Preprocessed', animal, session, [session '.LFP']);
filename = [session '.LFP_nt3ch1.dat'];
pathfile = fullfile(pathLFP,filename);
%%
data = readTrodesExtractedDataFile(pathfile)
%%
lfp = data.fields.data;