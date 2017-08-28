sampleSize = 100;
Accuracy=[];
for i=1:100
    c=randperm(275,sampleSize);  % randperm(totalRows, required#rows)
    Sp1=SpindleCHC(c,:);  % output matrix

    c=randperm(410,sampleSize);  % randperm(totalRows, required
    Sp2=SpU(c,:);  % output matrix
    Sp = vertcat(Sp1, Sp2);

    [trainedClassifier, validationAccuracy] = trainSVNClassifier(Sp);
    Accuracy = vertcat (Accuracy, validationAccuracy);
end
avgAccuracy=min(Accuracy)
