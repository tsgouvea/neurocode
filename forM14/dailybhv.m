function [ h, pooled ] = dailybhv( filepath, varargin )
%DAILYBHV Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    consolidateBlocks = true;
else
    consolidateBlocks = varargin{1};
end

%% Load data
load(filepath)

%% Init
[~,sessionName] = fileparts(filepath);
h = figure('Position', [200 200 1000 600],'name',sessionName,'numbertitle','off', 'MenuBar', 'none');

%% Outcomes
a.outcomes.axes = subplot(2,1,2);
a.outcomes.DV = line(1:numel(SessionData.Custom.DV),SessionData.Custom.DV, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
a.outcomes.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
a.outcomes.Correct = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
a.outcomes.Incorrect = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
a.outcomes.BrokeFix = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
a.outcomes.EarlyWithdrawal = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
a.outcomes.NoFeedback = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','none','MarkerFace','w', 'MarkerSize',5);
a.outcomes.NoResponse = line(-1,[0 1], 'LineStyle','none','Marker','x','MarkerEdge','w','MarkerFace','none', 'MarkerSize',6);
a.outcomes.Catch = line(-1,[0 1], 'LineStyle','none','Marker','o','MarkerEdge',[0,0,0],'MarkerFace',[0,0,0], 'MarkerSize',4);
set(a.outcomes.axes,'TickDir', 'out','XLim',[0, SessionData.nTrials],'YLim', [-1.1, 1.1], 'YTick', [-1, 1],'YTickLabel', {'Right','Left'}, 'FontSize', 13);
xlabel(a.outcomes.axes, 'Trial#', 'FontSize', 14);
hold(a.outcomes.axes, 'on');
%%
indxToPlot = 1:SessionData.nTrials;
R = SessionData.Custom.RewardMagnitude;
ndxRwd = SessionData.Custom.Rewarded;
C = zeros(size(R)); C(SessionData.Custom.ChoiceLeft==1&ndxRwd,1) = 1; C(SessionData.Custom.ChoiceLeft==0&ndxRwd,2) = 1;
R = R.*C;
set(a.outcomes.CumRwd, 'position', [SessionData.nTrials+1 1], 'string', ...
    [num2str(sum(R(:))/1000) ' mL']);
clear R C
%Plot Rewarded
ndxCor =   SessionData.Custom.ChoiceCorrect==1;
Xdata = indxToPlot(ndxCor);
Ydata = SessionData.Custom.DV; Ydata = Ydata(ndxCor);
set(a.outcomes.Correct, 'xdata', Xdata, 'ydata', Ydata);
%Plot Incorrect
ndxInc = SessionData.Custom.ChoiceCorrect==0;
Xdata = indxToPlot(ndxInc);
Ydata = SessionData.Custom.DV(ndxInc);
set(a.outcomes.Incorrect, 'xdata', Xdata, 'ydata', Ydata);
%Plot Broken Fixation
ndxBroke = SessionData.Custom.FixBroke;
Xdata = indxToPlot(ndxBroke); Ydata = zeros(1,sum(ndxBroke));
set(a.outcomes.BrokeFix, 'xdata', Xdata, 'ydata', Ydata);
%Plot Early Withdrawal
ndxEarly = SessionData.Custom.EarlyWithdrawal;
Xdata = indxToPlot(ndxEarly);
Ydata = zeros(1,sum(ndxEarly));
set(a.outcomes.EarlyWithdrawal, 'xdata', Xdata, 'ydata', Ydata);
%Plot missed choice trials
ndxMiss = isnan(SessionData.Custom.ChoiceLeft)&~ndxBroke&~ndxEarly;
Xdata = indxToPlot(ndxMiss);
Ydata = SessionData.Custom.DV(indxToPlot); Ydata = Ydata(ndxMiss);
set(a.outcomes.NoResponse, 'xdata', Xdata, 'ydata', Ydata);
%Plot NoFeedback trials
ndxNoFeedback = ~SessionData.Custom.Feedback;
Xdata = indxToPlot(ndxNoFeedback&~ndxMiss);
Ydata = SessionData.Custom.DV(indxToPlot); Ydata = Ydata(ndxNoFeedback&~ndxMiss);
set(a.outcomes.NoFeedback, 'xdata', Xdata, 'ydata', Ydata);

%% Psychometric
a.psyc.axes = subplot(2,3,1);
a.psyc.axes.YLim = [-.05 1.05];
a.psyc.axes.XLim = 100*[-.05 1.05];
% a.psyc.axes.XLabel.String = '% odor A'; % FIGURE OUT UNIT
a.psyc.axes.YLabel.String = '% left';
a.psyc.axes.Title.String = 'Psychometric Olf';
hold(a.psyc.axes, 'on');
%axis square

OdorFracA = SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft));
ndxOlf = ~SessionData.Custom.AuditoryTrial(1:numel(SessionData.Custom.ChoiceLeft));
ndxFeedback = SessionData.Custom.Feedback == 1;
if consolidateBlocks
    BlockNumber = nan(size(SessionData.Custom.ChoiceLeft));
    logRewRatio = log(SessionData.Custom.RewardMagnitude(:,1)./SessionData.Custom.RewardMagnitude(:,2));
    setlogRewRatio = unique(logRewRatio);
    for i = 1:numel(setlogRewRatio)
        BlockNumber(logRewRatio == setlogRewRatio(i)) = i;
    end
else
    if isfield(SessionData.Custom,'BlockNumber')
        BlockNumber = SessionData.Custom.BlockNumber;
    else
        BlockNumber = ones(size(SessionData.Custom.ChoiceLeft));
    end
end
setBlocks = reshape(unique(BlockNumber),1,[]); % STOPPED HERE
ndxNan = isnan(SessionData.Custom.ChoiceLeft);

for iBlock = setBlocks
    ndxBlock = SessionData.Custom.BlockNumber(1:numel(SessionData.Custom.ChoiceLeft)) == iBlock;
    if any(ndxBlock&ndxFeedback)
        
        lineColor = rgb2hsv([0.8314    0.5098    0.4157]);
        bias = tanh(.3 * SessionData.Custom.RewardMagnitude(find(ndxBlock,1),:) * [1 -1]');
        lineColor(1) = 0.08+0.04*bias; lineColor(2) = 0.75; lineColor(3) = abs(bias); lineColor = hsv2rgb(lineColor);
        
        a.psyc.scatter(iBlock) = line(a.psyc.axes,[5 95],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge',lineColor,'MarkerFace',lineColor, 'MarkerSize',6);
        a.psyc.fit(iBlock) = line(a.psyc.axes,[0 100],[.5 .5],'color',lineColor);
        
        setStim = reshape(unique(OdorFracA(ndxBlock&ndxFeedback)),1,[]);
        psyc = nan(size(setStim));
        for iStim = setStim
            ndxStim = reshape(OdorFracA == iStim,1,[]);
            ndx = ndxStim&~ndxNan&ndxBlock&ndxOlf&ndxFeedback;
            psyc(setStim==iStim) = sum(SessionData.Custom.ChoiceLeft(ndx))/...
                sum(ndx);
        end
        a.psyc.scatter(iBlock).XData = setStim;
        a.psyc.scatter(iBlock).YData = psyc;
        a.psyc.fit(iBlock).XData = linspace(min(setStim),max(setStim),100);
        ndx = ~ndxNan&ndxBlock&ndxOlf&ndxFeedback;
        if any(ndx)
            a.psyc.fit(iBlock).YData = glmval(glmfit(OdorFracA(ndx),...
                SessionData.Custom.ChoiceLeft(ndx)','binomial'),a.psyc.fit(iBlock).XData,'logit');
        end
    end
end

%% PSYCHOMETRIC
a.psycnofeed.axes = subplot(2,3,2);
a.psycnofeed.axes.YLim = [-.05 1.05];
a.psycnofeed.axes.XLim = 100*[-.05 1.05];
a.psycnofeed.axes.XLabel.String = '% odor A'; % FIGURE OUT UNIT
a.psycnofeed.axes.YLabel.String = '% left';
a.psycnofeed.axes.Title.String = 'No Feedback';
hold(a.psycnofeed.axes, 'on');
%axis square

ndxFeedback = SessionData.Custom.Feedback == 0;

for iBlock = setBlocks
    ndxBlock = SessionData.Custom.BlockNumber(1:numel(SessionData.Custom.ChoiceLeft)) == iBlock;
    if any(ndxBlock&ndxFeedback)
        
        lineColor = rgb2hsv([0.8314    0.5098    0.4157]);
        bias = tanh(.3 * SessionData.Custom.RewardMagnitude(find(ndxBlock,1),:) * [1 -1]');
        lineColor(1) = 0.08+0.04*bias; lineColor(2) = 0.75; lineColor(3) = abs(bias); lineColor = hsv2rgb(lineColor);
        
        a.psycnofeed.scatter(iBlock) = line(a.psycnofeed.axes,[5 95],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge',lineColor,'MarkerFace','w', 'MarkerSize',6);
        a.psycnofeed.fit(iBlock) = line(a.psycnofeed.axes,[0 100],[.5 .5],'color',lineColor,'LineStyle','--');
        
        setStim = reshape(unique(OdorFracA(ndxBlock&ndxFeedback)),1,[]);
        psyc = nan(size(setStim));
        for iStim = setStim
            ndxStim = reshape(OdorFracA == iStim,1,[]);
            ndx = ndxStim&~ndxNan&ndxBlock&ndxOlf&ndxFeedback;
            psyc(setStim==iStim) = sum(SessionData.Custom.ChoiceLeft(ndx))/...
                sum(ndx);
        end
        a.psycnofeed.scatter(iBlock).XData = setStim;
        a.psycnofeed.scatter(iBlock).YData = psyc;
        a.psycnofeed.fit(iBlock).XData = linspace(min(setStim),max(setStim),100);
        ndx = ~ndxNan&ndxBlock&ndxOlf&ndxFeedback;
        if any(ndx)
            a.psycnofeed.fit(iBlock).YData = glmval(glmfit(OdorFracA(ndx),...
                SessionData.Custom.ChoiceLeft(ndx)','binomial'),a.psycnofeed.fit(iBlock).XData,'logit');
        end
    end
end

%% MT

a.mt.axes = subplot(2,3,3);
% a.mt.axes.YLim = [-.05 1.05];
a.mt.axes.XLim = 100*[-.05 1.05];
a.mt.axes.XLabel.String = '% odor A'; % FIGURE OUT UNIT
a.mt.axes.YLabel.String = 'Movement Time (s)';
a.mt.axes.Title.String = 'MT';
hold(a.mt.axes, 'on');
%axis square

for iBlock = setBlocks
    ndxBlock = SessionData.Custom.BlockNumber(1:numel(SessionData.Custom.ChoiceLeft)) == iBlock;
    if any(ndxBlock)
        
        lineColor = rgb2hsv([0.8314    0.5098    0.4157]);
        bias = tanh(.3 * SessionData.Custom.RewardMagnitude(find(ndxBlock,1),:) * [1 -1]');
        lineColor(1) = 0.08+0.04*bias; lineColor(2) = 0.75; lineColor(3) = abs(bias); lineColor = hsv2rgb(lineColor);
        
        a.mt.errorbar(iBlock) = errorbar(a.mt.axes,[5 95],[.5 .5],[.1 .1],'color',lineColor,'Marker','o','MarkerEdge',lineColor,'MarkerFace',lineColor, 'MarkerSize',6);
        
        setStim = reshape(unique(OdorFracA(ndxBlock)),1,[]);
        mt = nan(numel(setStim),3);
        for iStim = setStim
            ndxStim = reshape(OdorFracA == iStim,1,[]);
            ndx = ndxStim&~ndxNan&ndxBlock&ndxOlf;
            mt(iStim==setStim,1) = mean(SessionData.Custom.MT(ndx));
            s = std(SessionData.Custom.MT(ndx))/sqrt(sum(ndx));
            mt(iStim==setStim,2) = s;
            mt(iStim==setStim,3) = s;
%             mt(iStim==setStim,2) = abs(mt(iStim==setStim,1) - prctile(SessionData.Custom.MT(ndx),40));
%             mt(iStim==setStim,3) = abs(mt(iStim==setStim,1) - prctile(SessionData.Custom.MT(ndx),60));
        end
        
        a.mt.errorbar(iBlock).XData = setStim;
        a.mt.errorbar(iBlock).YData = mt(:,1);
        a.mt.errorbar(iBlock).YNegativeDelta = mt(:,2);
        a.mt.errorbar(iBlock).YPositiveDelta = mt(:,3);
    end
end

pooled = nan;

%%
% a.outcomes.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
% a.outcomes.HandleFix = axes('Position',        [4*.05 + 3*.08   .6  .1  .3], 'Visible', 'off');
% a.outcomes.HandleST = axes('Position',         [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
% a.outcomes.HandleFeedback = axes('Position',   [6*.05 + 5*.08   .6  .1  .3], 'Visible', 'off');
% a.outcomes.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');
%
% %% Psyc Olfactory
% a.outcomes.PsycOlf = line(a.mt.axes,[5 95],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','off');
% a.outcomes.PsycOlfFit = line(a.mt.axes,[0 100],[.5 .5],'color','k','Visible','off');
% a.mt.axes.YLim = [-.05 1.05];
% a.mt.axes.XLim = 100*[-.05 1.05];
% a.mt.axes.XLabel.String = '% odor A'; % FIGURE OUT UNIT
% a.mt.axes.YLabel.String = '% left';
% a.mt.axes.Title.String = 'Psychometric Olf';
% %% Psyc Auditory
% a.outcomes.PsycAud = line(a.HandlePsycAud,[-1 1],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','off');
% a.outcomes.PsycAudFit = line(a.HandlePsycAud,[-1. 1.],[.5 .5],'color','k','Visible','off');
% a.HandlePsycAud.YLim = [-.05 1.05];
% a.HandlePsycAud.XLim = [-1.05, 1.05];
% a.HandlePsycAud.XLabel.String = 'beta'; % FIGURE OUT UNIT
% a.HandlePsycAud.YLabel.String = '% left';
% a.HandlePsycAud.Title.String = 'Psychometric Aud';
% %% Vevaiometric curve
% hold(a.HandleVevaiometric,'on')
% a.outcomes.VevaiometricCatch = line(a.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','g','Visible','off','LineWidth',2);
% a.outcomes.VevaiometricErr = line(a.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','r','Visible','off','LineWidth',2);
% a.outcomes.VevaiometricPointsErr = line(a.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','r','Marker','o','MarkerFaceColor','r', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','r');
% a.outcomes.VevaiometricPointsCatch = line(a.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','g','Marker','o','MarkerFaceColor','g', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','g');
% a.HandleVevaiometric.YLim = [0 10];
% a.HandleVevaiometric.XLim = [-1.05, 1.05];
% a.HandleVevaiometric.XLabel.String = 'DV';
% a.HandleVevaiometric.YLabel.String = 'WT (s)';
% a.HandleVevaiometric.Title.String = 'Vevaiometric';
% %% Trial rate
% hold(a.HandleTrialRate,'on')
% a.outcomes.TrialRate = line(a.HandleTrialRate,[0],[0], 'LineStyle','-','Color','k','Visible','off'); %#ok<NBRAK>
% a.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
% a.HandleTrialRate.YLabel.String = 'nTrials';
% a.HandleTrialRate.Title.String = 'Trial rate';
% %% Stimulus delay
% hold(a.HandleFix,'on')
% a.HandleFix.XLabel.String = 'Time (ms)';
% a.HandleFix.YLabel.String = 'trial counts';
% a.HandleFix.Title.String = 'Pre-stimulus delay';
% %% ST histogram
% hold(a.HandleST,'on')
% a.HandleST.XLabel.String = 'Time (ms)';
% a.HandleST.YLabel.String = 'trial counts';
% a.HandleST.Title.String = 'Stim sampling time';
% %% Feedback Delay histogram
% hold(a.HandleFeedback,'on')
% a.HandleFeedback.XLabel.String = 'Time (ms)';
% a.HandleFeedback.YLabel.String = 'trial counts';
% a.HandleFeedback.Title.String = 'Feedback delay';
%
%
% %% Fill in
%
%     %% Psyc Olf
%     if TaskParameters.GUI.ShowPsycOlf
%         OdorFracA = SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft));
%         ndxOlf = ~SessionData.Custom.AuditoryTrial(1:numel(SessionData.Custom.ChoiceLeft));
%         if isfield(SessionData.Custom,'BlockNumber')
%             BlockNumber = SessionData.Custom.BlockNumber;
%         else
%             BlockNumber = ones(size(SessionData.Custom.ChoiceLeft));
%         end
%         setBlocks = reshape(unique(BlockNumber),1,[]); % STOPPED HERE
%         ndxNan = isnan(SessionData.Custom.ChoiceLeft);
%         for iBlock = setBlocks(end)
%             ndxBlock = SessionData.Custom.BlockNumber(1:numel(SessionData.Custom.ChoiceLeft)) == iBlock;
%             if any(ndxBlock)
%                 setStim = reshape(unique(OdorFracA(ndxBlock)),1,[]);
%                 psyc = nan(size(setStim));
%                 for iStim = setStim
%                     ndxStim = reshape(OdorFracA == iStim,1,[]);
%                     psyc(setStim==iStim) = sum(SessionData.Custom.ChoiceLeft(ndxStim&~ndxNan&ndxBlock&ndxOlf))/...
%                         sum(ndxStim&~ndxNan&ndxBlock&ndxOlf);
%                 end
%                 if iBlock <= numel(a.outcomes.PsycOlf) && ishandle(a.outcomes.PsycOlf(iBlock))
%                     a.outcomes.PsycOlf(iBlock).XData = setStim;
%                     a.outcomes.PsycOlf(iBlock).YData = psyc;
%                     a.outcomes.PsycOlfFit(iBlock).XData = linspace(min(setStim),max(setStim),100);
%                     if sum(OdorFracA(ndxBlock&ndxOlf))>0
%                         a.outcomes.PsycOlfFit(iBlock).YData = glmval(glmfit(OdorFracA(ndxBlock&ndxOlf),...
%                             SessionData.Custom.ChoiceLeft(ndxBlock&ndxOlf)','binomial'),linspace(min(setStim),max(setStim),100),'logit');
%                     end
%                 else
%                     lineColor = rgb2hsv([0.8314    0.5098    0.4157]);
%                     bias = tanh(.3 * SessionData.Custom.RewardMagnitude(find(ndxBlock,1),:) * [1 -1]');
%                     lineColor(1) = 0.08+0.04*bias; lineColor(2) = .75; lineColor(3) = abs(bias); lineColor = hsv2rgb(lineColor);
%                     %                     lineColor = lineColor + [0 0.3843*(tanh(SessionData.Custom.RewardMagnitude(find(ndxBlock,1),:) * [1 -1]')) 0]
%                     a.outcomes.PsycOlf(iBlock) = line(a.mt.axes,setStim,psyc, 'LineStyle','none','Marker','o',...
%                         'MarkerEdge',lineColor,'MarkerFace',lineColor, 'MarkerSize',6);
%                     a.outcomes.PsycOlfFit(iBlock) = line(a.mt.axes,[0 100],[.5 .5],'color',lineColor);
%                 end
%             end
%             % GUIHandles.OutcomePlot.Psyc.YData = psyc;
%         end
%         %
%         %
%         %         stimSet = unique(OdorFracA);
%         %         a.outcomes.PsycOlf.XData = stimSet;
%         %         psyc = nan(size(stimSet));
%         %         for iStim = 1:numel(stimSet)
%         %             ndxStim = OdorFracA == stimSet(iStim);
%         %             ndxNan = isnan(SessionData.Custom.ChoiceLeft(:));
%         %             psyc(iStim) = nansum(SessionData.Custom.ChoiceLeft(ndxStim)/sum(ndxStim&~ndxNan));
%         %         end
%         %         a.outcomes.PsycOlf.YData = psyc;
%     end
%
%     %% Psych Aud
%     if TaskParameters.GUI.ShowPsycAud
%         AudDV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
%         ndxAud = SessionData.Custom.AuditoryTrial(1:numel(SessionData.Custom.ChoiceLeft));
%         ndxNan = isnan(SessionData.Custom.ChoiceLeft);
%         AudBin = 8;
%         BinIdx = discretize(AudDV,linspace(-1,1,AudBin+1));
%         PsycY = grpstats(SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan),BinIdx(ndxAud&~ndxNan),'mean');
%         PsycX = unique(BinIdx(ndxAud&~ndxNan))/AudBin*2-1-1/AudBin;
%         a.outcomes.PsycAud.YData = PsycY;
%         a.outcomes.PsycAud.XData = PsycX;
%         if sum(ndxAud&~ndxNan) > 1
%             a.outcomes.PsycAudFit.XData = linspace(min(AudDV),max(AudDV),100);
%             a.outcomes.PsycAudFit.YData = glmval(glmfit(AudDV(ndxAud&~ndxNan),...
%                 SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan)','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
%         end
%     end
%     %% Vevaiometric
%     if TaskParameters.GUI.ShowVevaiometric
%         ndxError = SessionData.Custom.ChoiceCorrect(1:iTrial) == 0 ; %all (completed) error trials (including catch errors)
%         ndxCorrectCatch = SessionData.Custom.CatchTrial(1:iTrial) & SessionData.Custom.ChoiceCorrect(1:iTrial) == 1; %only correct catch trials
%         ndxMinWT = SessionData.Custom.FeedbackTime > TaskParameters.GUI.VevaiometricMinWT;
%         DV = SessionData.Custom.DV(1:iTrial);
%         DVNBin = TaskParameters.GUI.VevaiometricNBin;
%         BinIdx = discretize(DV,linspace(-1,1,DVNBin+1));
%         WTerr = grpstats(SessionData.Custom.FeedbackTime(ndxError&ndxMinWT),BinIdx(ndxError&ndxMinWT),'mean')';
%         WTcatch = grpstats(SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT),BinIdx(ndxCorrectCatch&ndxMinWT),'mean')';
%         Xerr = unique(BinIdx(ndxError&ndxMinWT))/DVNBin*2-1-1/DVNBin;
%         Xcatch = unique(BinIdx(ndxCorrectCatch&ndxMinWT))/DVNBin*2-1-1/DVNBin;
%         a.outcomes.VevaiometricErr.YData = WTerr;
%         a.outcomes.VevaiometricErr.XData = Xerr;
%         a.outcomes.VevaiometricCatch.YData = WTcatch;
%         a.outcomes.VevaiometricCatch.XData = Xcatch;
%         if TaskParameters.GUI.VevaiometricShowPoints
%             a.outcomes.VevaiometricPointsErr.YData = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT);
%             a.outcomes.VevaiometricPointsErr.XData = DV(ndxError&ndxMinWT);
%             a.outcomes.VevaiometricPointsCatch.YData = SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT);
%             a.outcomes.VevaiometricPointsCatch.XData = DV(ndxCorrectCatch&ndxMinWT);
%         else
%             a.outcomes.VevaiometricPointsErr.YData = -1;
%             a.outcomes.VevaiometricPointsErr.XData = 0;
%             a.outcomes.VevaiometricPointsCatch.YData = -1;
%             a.outcomes.VevaiometricPointsCatch.XData = 0;
%         end
%     end
%     %% Trial rate
%     if TaskParameters.GUI.ShowTrialRate
%         a.outcomes.TrialRate.XData = (SessionData.TrialStartTimestamp-min(SessionData.TrialStartTimestamp))/60;
%         a.outcomes.TrialRate.YData = 1:numel(SessionData.Custom.ChoiceLeft);
%     end
%     if TaskParameters.GUI.ShowFix
%         %% Stimulus delay
%         cla(a.HandleFix)
%         a.outcomes.HistBroke = histogram(a.HandleFix,SessionData.Custom.FixDur(SessionData.Custom.FixBroke)*1000);
%         a.outcomes.HistBroke.BinWidth = 50;
%         a.outcomes.HistBroke.EdgeColor = 'none';
%         a.outcomes.HistBroke.FaceColor = 'r';
%         a.outcomes.HistFix = histogram(a.HandleFix,SessionData.Custom.FixDur(~SessionData.Custom.FixBroke)*1000);
%         a.outcomes.HistFix.BinWidth = 50;
%         a.outcomes.HistFix.FaceColor = 'b';
%         a.outcomes.HistFix.EdgeColor = 'none';
%         BreakP = mean(SessionData.Custom.FixBroke);
%         cornertext(a.HandleFix,sprintf('P=%1.2f',BreakP))
%     end
%     %% ST
%     if TaskParameters.GUI.ShowST
%         cla(a.HandleST)
%         a.outcomes.HistSTEarly = histogram(a.HandleST,SessionData.Custom.ST(SessionData.Custom.EarlyWithdrawal)*1000);
%         a.outcomes.HistSTEarly.BinWidth = 50;
%         a.outcomes.HistSTEarly.FaceColor = 'r';
%         a.outcomes.HistSTEarly.EdgeColor = 'none';
%         a.outcomes.HistST = histogram(a.HandleST,SessionData.Custom.ST(~SessionData.Custom.EarlyWithdrawal)*1000);
%         a.outcomes.HistST.BinWidth = 50;
%         a.outcomes.HistST.FaceColor = 'b';
%         a.outcomes.HistST.EdgeColor = 'none';
%         EarlyP = sum(SessionData.Custom.EarlyWithdrawal)/sum(~SessionData.Custom.FixBroke);
%         cornertext(a.HandleST,sprintf('P=%1.2f',EarlyP))
%     end
%     %% Feedback delay (exclude catch trials and error trials, if set on catch)
%     if TaskParameters.GUI.ShowFeedback
%         cla(a.HandleFeedback)
%         if TaskParameters.GUI.CatchError
%             ndxExclude = SessionData.Custom.ChoiceCorrect(1:iTrial) == 0; %exclude error trials if they are set on catch
%         else
%             ndxExclude = false(1,iTrial);
%         end
%         a.outcomes.HistNoFeed = histogram(a.HandleFeedback,SessionData.Custom.FeedbackTime(~SessionData.Custom.Feedback(1:iTrial)&~SessionData.Custom.CatchTrial(1:iTrial)&~ndxExclude)*1000);
%         a.outcomes.HistNoFeed.BinWidth = 100;
%         a.outcomes.HistNoFeed.EdgeColor = 'none';
%         a.outcomes.HistNoFeed.FaceColor = 'r';
%         %a.outcomes.HistNoFeed.Normalization = 'probability';
%         a.outcomes.HistFeed = histogram(a.HandleFeedback,SessionData.Custom.FeedbackTime(SessionData.Custom.Feedback(1:iTrial)&~SessionData.Custom.CatchTrial(1:iTrial)&~ndxExclude)*1000);
%         a.outcomes.HistFeed.BinWidth = 50;
%         a.outcomes.HistFeed.EdgeColor = 'none';
%         a.outcomes.HistFeed.FaceColor = 'b';
%         %a.outcomes.HistFeed.Normalization = 'probability';
%         LeftSkip = sum(~SessionData.Custom.Feedback(1:iTrial)&~SessionData.Custom.CatchTrial(1:iTrial)&~ndxExclude&SessionData.Custom.ChoiceLeft(1:iTrial)==1)/sum(~SessionData.Custom.CatchTrial(1:iTrial)&~ndxExclude&SessionData.Custom.ChoiceLeft(1:iTrial)==1);
%         RightSkip = sum(~SessionData.Custom.Feedback(1:iTrial)&~SessionData.Custom.CatchTrial(1:iTrial)&~ndxExclude&SessionData.Custom.ChoiceLeft(1:iTrial)==0)/sum(~SessionData.Custom.CatchTrial(1:iTrial)&~ndxExclude&SessionData.Custom.ChoiceLeft(1:iTrial)==0);
%         cornertext(a.HandleFeedback,{sprintf('L=%1.2f',LeftSkip),sprintf('R=%1.2f',RightSkip)})
%     end
% end
%
%
% function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
% FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
% mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
% mx = mn + nTrialsToShow - 1;
% set(AxesHandle,'XLim',[mn-1 mx+1]);
% end
%
% function cornertext(h,str)
% unit = get(h,'Units');
% set(h,'Units','char');
% pos = get(h,'Position');
% if ~iscell(str)
%     str = {str};
% end
% for i = 1:length(str)
%     x = pos(1)+1;y = pos(2)+pos(4)-i;
%     uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
% end
% set(h,'Units',unit);
% end
