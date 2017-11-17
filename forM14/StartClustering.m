% wrapper script to convert nlx recording files (*.ncs) to mda files
% and start mountainlab sorting pipeline.

% Torben Ott, CSHL, 2017

%%%%%PARAMS%%%%%%%%%%%%%
Animals = {'TG020'};
Dates = {'20170908','20170915','20170926','20171002'};
%{'20170906','20170907','20170908','20170911','20170912','20170913','20170914',...
    %'20170915','20170916','20170919','20170920','20170921','20170922','20170923',...
    %'20170926','20170927','20170928','20170929','20171002'};%for multiple sessions, Animals must be osame length
Animals=repmat(Animals,size(Dates));
Tetrodes={[1:32]}; %[1:32] %which tetrodes to include, cell of same length as Animals and Dates
Tetrodes=repmat(Tetrodes,size(Dates));
% Tetrodes{13} = [7 8];
% Tetrodes{14} = [7 8];
Notify={'Thiago'}; %cell with names; names need to be associated with email in MailAlert.m
ServerPathBase =  '/media/thiagoatserver/Neurodata/Spikegadgets';% path to original recording files
% ServerPathBase =  '/home/thiago/Neurodata/Spikegadgets';% path to original recording files
DataPathBase = '/home/thiago/Neurodata/Preprocessed'; % where to store big mda files. recommend HDD.
SortingPathBase = '/shorthand/Neurodata/mountainsort/'; %where to store mountainlab sorting results (small(er) files). recommend SSD.
% ParamsPath = '/home/thiago/Documents/MATLAB/mountainsort_matlab_wrapper/params/params_minimal_TG020.json'; %default params file location
ParamsPath = '/home/thiago/Documents/MATLAB/mountainsort_matlab_wrapper/params/params_default_20171107.json'; %default params file location
CurationPath = '/home/thiago/Documents/MATLAB/mountainsort_matlab_wrapper/params/annotation.script'; %default curation script location
Convert2MDA = false; %if set to false, uses converted mda file if present
RunClustering = true; %if set to false, does not run clustering
Convert2MClust = false; %if set to false, does not convert to MClust readable cluster file (large!)
RecSys = 'spikegadgets'; %recording system. either 'neuralynx' or 'spikegadgets'
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this prepareas mountainview function for in-matlab call (execute only
%after soring)

% view_tetrode=11;
% params=struct('basepath',sortingpathbase,'animal',Animals{1},'date',Dates{1},'tetrode',view_tetrode,...
%     'metrics','cluster_metrics_annotated.json');
% % ALL MOUNTAINVIEW
%  start_mountainview(params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CLUSTERING PIPELINE
EXTRACTTIME = zeros(1,length(Animals)); SORTINGTIME=zeros(1,length(Animals)); MCLUSTCONVERTTIME=zeros(1,length(Animals));

howlong = struct('extract',[],'sort',[],'mclustconvert',[],'date',[],'animal',[]);

for session = 4%1:length(Animals)
    %
    animal = Animals{session};
    howlong(session).animal = animal;
    date = Dates{session};
    tetrodes = Tetrodes{session};
    howlong(session).date = date;

    %which leads to use
    %default: all 4
    tetrodes_config = num2cell(repmat(1:4,tetrodes(end),1),2);

    %load animal-specific config file
    switch animal
        case 'P36'
            load('P36Config.mat');
        case 'P35'
            load('P35Config.mat');
        otherwise
            warning('No animal config file found. Using all leads of all tetrodes.');
    end

    %build params struct
    Params.Date = date;
    Params.Animal = animal;
    Params.Tetrodes = tetrodes;
    Params.TetrodesConfig = tetrodes_config;
    Params.ServerPathBase = ServerPathBase;
    Params.DataPathBase = DataPathBase;
    Params.SortingPathBase = SortingPathBase;
    Params.ParamsPath = ParamsPath;
    Params.CurationPath = CurationPath;
    Params.RecSys = RecSys;

    % convert ncs to mda
    if Convert2MDA
        tic
        try
            Tetrode2MDALocal(Params);
        catch
            MailAlert(Notify,'Oxossi:SortingWrapperKron','Error:Tetrode2MDALocal.');
        end
        howlong(session).extract = duration([0 0 toc]);
    end


    % start analysis pipeline
    if RunClustering
        tic
        try
            ExecuteSortingKron(Params);
        catch
            MailAlert(Notify,'Oxossi:SortingWrapperKron','Error:ExecuteSortingKron.');
        end
        howlong(session).sort = duration([0 0 toc]);
    end


    % convert to  MClust tetrode data and cluster object
    if Convert2MClust
        tic
        try
            ConvertToMClust(animal,date,tetrodes,DataPathBase,SortingPathBase);
        catch
            MailAlert(Notify,'Oxossi:SortingWrapperKron','Error:ConvertToMClust.');
        end
        howlong(session).mclustconvert = duration([0 0 toc]);
    end

end%session

% TIME = sum((EXTRACTTIME + SORTINGTIME + MCLUSTCONVERTTIME))/60;
% fprintf('Overall Time: %2.1f min (session average %2.1f min).\n',TIME,TIME/length(Animals));

save('howlong.mat','howlong');

%send slack notification
MailAlert(Notify,'Oxossi:SortingWrapperKron','Sorting Done.');
