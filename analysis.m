clear all;
close all;
load('Data.mat')

%t.Area=[]; % Remove a coloumn from a table
%% Add an extra coloumn to identify the type before concatenating.
tsize = size(SpindleCHC) ; 
temp = repmat({'CHC'},[tsize(1) 1]) ;
SpindleCHC.Type = temp;
tsize = size(SpindleLuci) ; 
temp = repmat({'Luci'},[tsize(1) 1]) ;
SpindleLuci.Type = temp;
tsize = size(SpindleUntreated) ; 
temp = repmat({'Untreated'},[tsize(1) 1]) ;
SpindleUntreated.Type = temp;

SpindleAll = vertcat(SpindleCHC, SpindleLuci, SpindleUntreated);
tsize = size(DNACHC) ; 
temp = repmat({'CHC'},[tsize(1) 1]) ;
DNACHC.Type = temp;
tsize = size(DNALuci) ; 
temp = repmat({'Luci'},[tsize(1) 1]) ;
DNALuci.Type = temp;
tsize = size(DNAUntreated) ; 
temp = repmat({'Untreated'},[tsize(1) 1]) ;
DNAUntreated.Type = temp;
DNAAll = vertcat(DNACHC, DNALuci, DNAUntreated);

%% 
% remove based on a criteria - remove all rows of Luci
% s = SpindleAll(cellfun(@isempty, strfind(SpindleAll.Type, 'Luci') ), :);  
% d = ResultsDNAall(cellfun(@isempty, strfind(ResultsSpindleall.Type, 'Luci') ), :);  

%% Label Luci data as Untreated. 
SpindleCHCUntreated = SpindleAll;
t = cellfun(@isempty, strfind(SpindleAll.Type, 'Luci')); % this is will find all idexes for Luci rows
t = ~t;
SpindleCHCUntreated(t, 20) = {'Untreated'}; 


DNACHCUntreated = DNAAll;
t = cellfun(@isempty, strfind(DNAAll.Type, 'Luci')); % this is will find all idexes for Luci rows
t = ~t;
DNACHCUntreated(t, 20) = {'Untreated'}; 

% 
%% Random selection of records - testing accuracy for SVM
SpU= SpindleCHCUntreated;
t = cellfun(@isempty, strfind(SpU.Type, 'Untreated')); % this is will find all idexes for Luci rows
t = ~t;
SpU = SpU(t,:); 

Accuracy=[];
for i=1:1000
    c=randperm(275,250);  % randperm(totalRows, required#rows)
    Sp1=SpindleCHC(c,:);  % output matrix

    c=randperm(410,250);  % randperm(totalRows, required
    Sp2=SpU(c,:);  % output matrix
    Sp = vertcat(Sp1, Sp2);

    [trainedClassifier, validationAccuracy] = trainSVNClassifier(Sp);
    Accuracy = vertcat (Accuracy, validationAccuracy);
end
avgAccuracy=mean(Accuracy)
%% One-way Anova for normally distributed data
use Kruskal–Wallis test when data is not normally distributed

for i=1:19
    % i = 14;
    y = cat(1, SpindleUntreated(:,i), SpindleLuci(:,i), SpindleCHC(:,i) );
    y = table2array(y);
    c = categorical({'Untreated'});
    g1 = repmat(c, size(SpindleUntreated, 1) );
    g1 = g1(:,1);

    c = categorical({'Luci'});
    g2 = repmat(c, size(SpindleLuci, 1));
    g2 = g2(:,1);

    c = categorical({'CHC'});
    g3 = repmat(c, size(SpindleCHC, 1));
    g3 = g3(:,1);

    g = cat(1, g1, g2, g3);

    %[p tbl stats] = anova1(y, g, 'off')      % One-way Anova
     [p,tbl,stats] = kruskalwallis(y,g )
     title(char(SpindleUntreated.Properties.VariableNames(i)));
    % uncomment the following line to save to disk 
    %saveas(gcf, strcat('C:\Users\mkhushi\Dropbox\ManuscriptsInPrep\MitoticSpindle\images\spindle\', strcat(char(SpindleUntreated.Properties.VariableNames(i))),'-box'), 'epsc')
    
    % figure, 
    [c,m,h,nms] = multcompare(stats, 'Ctype','tukey-kramer'); %
    title(char(SpindleUntreated.Properties.VariableNames(i)));
    % uncomment the following line to save to disk 
    % saveas(gcf, strcat('C:\Users\mkhushi\Dropbox\ManuscriptsInPrep\MitoticSpindle\images\spindle\', char(SpindleUntreated.Properties.VariableNames(i))), 'epsc')
    
%SpindleUntreated.Properties.VariableNames(i))
end

% h=findobj(gca,'tag','Outliers');
% h.delete
%[nms num2cell(m)]
%% Normality Test: One-sample Kolmogorov-Smirnov test, if h=1 data is not normal
% norm=[];
% for i=1:19
%     [h p] = kstest(SpindleUntreated(:,i))
%     norm = cat(1, norm, h);
% end
% norm=[];
% for i=1:19
%     [h p] = kstest(SpindleLuci(:,i))
%     norm = cat(1, norm, h);
% end
% 
% norm=[];
% for i=1:19
%     [h p] = kstest(SpindleCHC(:,i))
%     norm = cat(1, norm, h);
% end

%% Machine Learning
% [trainedClassifier, validationAccuracy] = trainClassifier(t)
% 
%  yfit = trainedClassifier.predictFcn(T)
%  
%  hFigs = findall(groot,'type','figure'); % Find all handles to the figures
%  
%  saveas(hFigs(1), 'roc.eps');
%  saveas(hFigs(2), 'confusionmatrix.eps');

%% DNA DATA: the following code generates kruskalwallis plots for DNA
for i=1:19
    y = cat(1, DNAUntreated(:,i), DNALuci(:,i), DNACHC(:,i) );
    y = table2array(y);
    c = categorical({'Untreated'});
    g1 = repmat(c, size(DNAUntreated, 1) );
    g1 = g1(:,1);

    c = categorical({'Luci'});
    g2 = repmat(c, size(DNALuci, 1));
    g2 = g2(:,1);

    c = categorical({'CHC'});
    g3 = repmat(c, size(DNACHC, 1));
    g3 = g3(:,1);

    g = cat(1, g1, g2, g3);       

    % [p tbl stats] = anova1(y, g)      % One-way Anova
    
    [p,tbl,stats] = kruskalwallis(y,g, 'off' )
%     title(char(DNAAll.Properties.VariableNames(i)));
    %saveas(gcf, strcat('C:\Users\mkhushi\Dropbox\ManuscriptsInPrep\MitoticSpindle\images\DNA\', char(DNAAll.Properties.VariableNames(i)), 'box'), 'epsc')
    %
    figure, [c,m,h,nms] = multcompare(stats, 'Ctype','tukey-kramer');
    title(char(DNAAll.Properties.VariableNames(i)));
end

% close all;

% tbl{2,6}
% 
% pvalues = [0.001; 4.0e-8; 5.08e-47; 5.3e-5]
% 
% [fdr, q] = mafdr(pvalues)
% 
% 
% MatQuantify('B:\Process\Bioinformatics\mkhushi\MatSpindleImages\untreated\untreatedrgb', 'green', 25000);
% MatQuantify('B:\Process\Bioinformatics\mkhushi\MatSpindleImages\chc_kd\chcrgb', 'green', 25000);
% MatQuantify('B:\Process\Bioinformatics\mkhushi\MatSpindleImages\luciferase\lucirgb', 'green', 25000);
% 
% MatQuantify('C:\Users\mkhushi\Dropbox\ManuscriptsInPrep\MitoticSpindle\RawRGB', 'green', 25000);
% % delete
%     i=maskedImg(:) ;
%     i(i==0)=[] ;
%     %figure, histogram(i);
%     fname = strcat('C:\Users\mkhushi\Dropbox\ManuscriptsInPrep\MitoticSpindle\RawRGB\processed\', fname,'.txt');
%     fid = fopen(fname,'wt');  % Note the 'wt' for writing in text mode
%     fprintf(fid,'%d\n',i);  % The format string is applied to each element of a
%     fclose(fid);
% % end delete  