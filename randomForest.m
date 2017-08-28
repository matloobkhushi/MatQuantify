%% This script is not used the manuscript

X = table2array( SpindleAll(:,1:19) );
Y = ordinal(SpindleAll.Type);

rng(9876,'twister');
savedRng = rng;

nTrees = 50;
leaf = 10;
rng(savedRng);

% b = TreeBagger(nTrees,X,Y,'OOBVarImp','on',...
%                           'CategoricalPredictors',3,...
%                           'MinLeaf',leaf);
Mdl = TreeBagger(200,X,Y,'Method','regression','Surrogate','on',...
    'PredictorSelection','curvature','OOBPredictorImportance','on');

imp = Mdl.OOBPermutedVarDeltaError;
figure
bar(imp);
h = gca;
h.XTickLabel = X.PredictorNames;
h.XTickLabelRotation = 45;
ylabel('Out-of-bag feature importance');
title('Feature importance results');

oobErrorFullX = b.oobError;

