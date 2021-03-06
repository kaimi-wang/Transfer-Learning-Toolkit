function [TrainX, TestX, TrainY, TestY, numSource, numTrain, numTarget, numTest] = CDPLSA_loadData(inputPath)
    load(inputPath);
    numSource = size(TrainData,2);                              % number of train file
    numTrain = zeros(1,numSource);
    TrainX = [];
    TrainY = [];
    for i = 1 : length(numTrain)
        numTrain(1,i) = size(TrainData{1,i},2);
        TrainX = [TrainX TrainData{1,i}];
        TrainY = [TrainY TrainLabel{1,i}];
    end
    
    numTarget = size(TestData,2);                              % number of train file
    numTest = zeros(1,numTarget);
    TestX = [];
    TestY = [];
    for i = 1 : length(numTest)
        numTest(1,i) = size(TestData{1,i},2);
        TestX = [TestX TestData{1,i}];
        TestY = [TestY TestLabel{1,i}];
    end
end