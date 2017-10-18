close all
clear all
clc

PathBaseServer = '/media/thiagoatserver';
Subject = 'TG020';
TaskName = 'Dual2AFC';
PathBhvServer = fullfile(PathBaseServer,'Behavior',Subject,TaskName,'Session Data');

PathBhvFig = fullfile(PathBaseServer,'Figures','Daily bhv',Subject);

Sessions = dir([PathBhvServer '/*.mat']);
dates = struct2table(Sessions);
dates = dates(:,6);
[~,ndx] = sortrows(dates);
Sessions = Sessions(ndx);
%% GENERATE AND SAVE FIGURES
for iSess = [19 20 25 26 27 29 31 33 34 35 36 37 39 42 45 46 47] %1:numel(Sessions)
    sessFileName = Sessions(iSess).name;
    [h, pooled] = dailybhv(fullfile(PathBhvServer,sessFileName));
    drawnow
    print(fullfile(PathBhvFig,sessFileName(1:end-4)),'-depsc2')
end

%% LIST SESSION NAMES
clc

for iSess = 1:numel(Sessions)
    display([num2str(iSess) '       ' Sessions(iSess).name])
end