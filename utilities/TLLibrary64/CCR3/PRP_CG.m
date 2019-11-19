%W0,afa,beta
function [W,result] = PRP_CG(W0,afa1,size_sets,yuzhi)

global TestX;
global TestY;
global TrainX;
global TrainY;
global afa;
global gama;
%%%%%%
global d0;
global tempW0;
global rr;


global AT; %记录各个domain对测试集测试的准确率
global AT0;
global Ensemble0; %记录优化前各个domain进行测试，然后Ensemble的结果
global Ensemble; %记录各个domain进行测试，然后Ensemble的结果

%%%%%%
afa = afa1;
global index1;

sump = 0;
fprintf('Respective result is: ');
ndomain = size(size_sets,1);
vp = zeros(ndomain-1,size(TestX,2));
for i=1:(ndomain-1)
    tmp_1 = 0;
    if i>1
        for j=1:(i-1)
            tmp_1 = tmp_1+size_sets(j,2);
        end
    end
    tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tempTrainXY = scale_cols(tempTrainX,tempTrainY);
    tmp_2 = 0;
    if i>1
        for j=1:(i-1)
            tmp_2 = tmp_2+size_sets(j,1);
        end
    end
    w1 = W0((tmp_2+1):(tmp_2+size_sets(i,1)),1);
%     s1 = w1'*tempTrainXY;
%     p1 = 1./(1 + exp(-s1));
    sump = sump + logProb(tempTrainXY,w1);
    s1 = w1'*TestX;
    p1 = 1./(1 + exp(-s1));
    vp(i,:) = p1;
    AT0(1,i) = getResult(p1,TestY);
    fprintf('%g   ',AT0(1,i));
end
fprintf('\n');

p = sum(vp)/(ndomain-1);

if ndomain == 2
    p = p1;
end

f = -(sump+afa*(2*p-1)*(2*p-1)'-0.5*gama*(W0'*W0)); %07-12-31
fprintf('initial value...%g\n',f);
index1 = 0;

Ensemble0 = getResult(p,TestY);
fprintf('iterating...%g...%g\n',index1,Ensemble0);
result(1,1) = getResult(p,TestY);
ff(1,1) = f;
tempW0 = W0;

while index1 < 10000
    %g = zeros(length(W0),1);
    aW = zeros(length(tempW0),1);
    for i=1:(ndomain-1)
        tmp_1 = 0;
        if i>1
            for j=1:(i-1)
                tmp_1 = tmp_1+size_sets(j,2);
            end
        end
        tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
        tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
        tempTrainXY = scale_cols(tempTrainX,tempTrainY);
        tmp_2 = 0;
        if i>1
            for j=1:(i-1)
                tmp_2 = tmp_2+size_sets(j,1);
            end
        end
        w1 = tempW0((tmp_2+1):(tmp_2+size_sets(i,1)),1);
        
        tmps11 = (exp(-w1'*tempTrainXY))./(1+exp(-w1'*tempTrainXY)); %modified080224
        temp1 = (1+exp(-w1'*tempTrainXY));
        for k = 1:length(tmps11)
            if  temp1(1,k)~= inf
                continue;
            else
                tmps11(1,k) = 1;
            end
        end
        s11 = sum(scale_cols(tempTrainXY,tmps11),2);
        for k = (1:ndomain-1)
            tmp_3 = 0;
            if k>1
                for j=1:(k-1)
                    tmp_3 = tmp_3+size_sets(j,1);
                end
            end
            w2 = tempW0((tmp_3+1):(tmp_3+size_sets(k,1)),1);
            vp(k,:) = 1./(1+exp(-w2'*TestX));
        end
        if ndomain == 2
            tmps12 = 2*(afa/(ndomain-1)^2)*(2*((vp))-(ndomain-1)).*(2*exp(-w1'*TestX)./(1+exp(-w1'*TestX)).^2);
        else
            tmps12 = 2*(afa/(ndomain-1)^2)*(2*(sum(vp))-(ndomain-1)).*(2*exp(-w1'*TestX)./(1+exp(-w1'*TestX)).^2);
        end
        
        temp2 = (1+exp(-w1'*TestX)).^2;
        for k = 1:length(tmps12)
            if  temp2(1,k)~= inf
                continue;
            else
                tmps12(1,k) = 0;
            end
        end
        s12 = sum(scale_cols(TestX,tmps12),2);
        aW((tmp_2+1):(tmp_2+size_sets(i,1)),1) = s11+s12;
    end
    
    %g = [s11+s12;s21+s22;s31+s32];
    %判断是否结束迭代
    if (aW-gama*tempW0)'*(aW-gama*tempW0) < yuzhi^2
        break;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if index1 == 0
        d0 = aW-gama*tempW0;
    end
    if index1 > 0
       afa0 = ((aW-gama*tempW0)'*(aW-gama*tempW0-temp_aW))/(temp_aW'*temp_aW);
       d1 = (aW-gama*tempW0) + afa0*d0;
       d0 = d1;
    end
    
    temp_aW = aW-gama*tempW0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%改到这里
    beta = 0;
    options = optimset('LargeScale','on');
    [x,fval] = fminunc(@objfun,beta,options);
    beta = x;
    if beta == 0
        break;
    end
    fprintf('the corresponding objective value of beta is:%g\n',beta);
 
    tempW0 = tempW0 + beta*d0;
    for i=1:(ndomain-1)
        tmp_1 = 0;
        if i>1
            for j=1:(i-1)
                tmp_1 = tmp_1+size_sets(j,2);
            end
        end
        tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
        tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
        tempTrainXY = scale_cols(tempTrainX,tempTrainY);
        tmp_2 = 0;
        if i>1
            for j=1:(i-1)
                tmp_2 = tmp_2+size_sets(j,1);
            end
        end
        w1 = tempW0((tmp_2+1):(tmp_2+size_sets(i,1)),1);
%         s1 = w1'*tempTrainXY;
%         p1 = 1./(1 + exp(-s1));
        sump = sump + logProb(tempTrainXY,w1);
        s1 = w1'*TestX;
        p1 = 1./(1 + exp(-s1));
        vp(i,:) = p1;
    end

    p = sum(vp)/(ndomain-1);
    if ndomain == 2
        p = p1;
    end
    f = -(sump+afa*(2*p-1)*(2*p-1)'-0.5*gama*(tempW0'*tempW0)); %07-12-31

    index1 = index1+1;
    
    result(1,index1+1) = getResult(p,TestY);
    ff(1,index1+1) = f;
    
    Ensemble = getResult(p,TestY);
    fprintf('iterating...%g value : %g...the accuracy:%g\n',index1,f,Ensemble);

end

fprintf('Respective result is one: ');
pro = zeros(1,size(TestY,2));
for i=1:(ndomain-1)
    tmp_2 = 0;
    if i>1
        for j=1:(i-1)
            tmp_2 = tmp_2+size_sets(j,1);
        end
    end
    w1 = tempW0((tmp_2+1):(tmp_2+size_sets(i,1)),1);
    s1 = w1'*TestX;
    p1 = 1./(1 + exp(-s1));
    vp(i,:) = p1;
    pro = pro + p1./3;
    AT(1,i) = getResult(p1,TestY);
    fprintf('%g   ',AT0(1,i));
end
fprintf('\n');
W = tempW0;
rr = getResult(pro,TestY);
%subplot(1,2,1),plot(result),title('Iteratering Accuracy')
%subplot(1,2,2),plot(ff),title('Iteratering Value')
