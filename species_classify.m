2%scrit file name species_classfy
%purpose:
%This program is used to analysis species file
%(1)C20 means species with 20 C, C42+ denotes species with C number larger
%than 42, C100- is species with C less than 100
%(2)M100 indicates species with Mw of 100, M125+ denotes Mw larger than 125, M400- is species less than 400
%(3)eleC are species have C, eleCO are species have C and O
%(4)eleonlyCH are species only have C and H, eleonlyCO are species only have C and O
%version 1;2018.6.23

disp('##################################################################################################################################')
disp('欢迎使用本程序--by 刘强@中国工程物理研究院核物理与化学研究所，Email:liubinqiang@163.com')
disp('githup仓库地址: https://github.com/dadaoqiuzhi/RMD_Digging');
disp('参考文献: 1.Fuel 287 (2021) 119484. 2.ACS Appl. Mat. Interfaces 13(34) (2021) 41287-41302. 3.ACS Appl. Mat. Interfaces 2022, 14.(4), 5959-5972.')
disp('4.ACS Materials Letters 2023, 2174-2188. More work is coming!')
disp('##################################################################################################################################')

disp('species_analysis程序运行后，反复利用此程序可以提取感兴趣的产物')
fprintf('\n(1)C20代表代表含有20个C元素的产物,C42+代表含有超过42个C元素的产物, C100-代表含有少于100个C元素的产物，\nC42-100代表含有42-100个C元素的产物')
fprintf('\n(2)M100代表分子量是100（原子质量）的产物, M125+代表分子量超过125的产物, M400-代表分子量低于400的产物,\nM125-400代表分子量介于125-400的产物')
fprintf('\n(3)代表必须含有C的产物, eleCO代表必须含有C和O的产物')
fprintf('\n(4)eleonlyCH代表只含有C和H元素的产物, eleonlyCO代表只含有C和O元素的产物')
fprintf('\n\n请选择筛选方法: \na:C1,C20,C42+,C100-,C42-100,+ 代表 >=,- 代表 <，xx-yy代表xx>= & <=yy\n')
fprintf('b:M100,M125+,M400-,M125-400,+ 代表 >=,- 代表 <，xx-yy代表xx>= & <=yy\n')
fprintf('c:eleC,eleCO\n')
fprintf('d:eleonlyC,eleonlyCO\n\n\n')
tarclass=input('请选择选项 (a, b, c or d): \n','s');
tarclass=lower(tarclass);
sumans=input('筛选出的产物数据求和? y/n:\n','s');
sumans=lower(sumans);
%datadelimiter中顺序不可随意放，优先放长字符，杜绝匹配Cl却优先找到了C，匹配Na却优先找到了N
datadelimiter={'eleonly','ele','Li','Be','He','Ne','Na','Mg','Cl','Ar','Ca','Sc','Ti','Al','Si','Cr','Mn','Fe','Co','Ni','Cu','Zn','Ga','Ge','As','Se','Br','Kr','Pd','Ag','Cd','In','Sn','Sb','Xe','Cs','Ba','Pt','Au','Hg','Pb','M','C','H','O','N','+','-','B','F','P','S','K','V','I'};
outputdatast=outputdata(1,:);
fprintf('\n如果数据只有三列就没有找到目标物质，请删除工作空间的数据\n')
if tarclass=='a'||tarclass=='b'
    classid=input('请根据选择的a或b选项输入筛选要求, 比如 C100-, M100: \n','s');
    classid=upper(classid);
    clear dataexport matchdatacol sumdata
    [C,matches]=strsplit(classid,datadelimiter,'CollapseDelimiters',false);
    if isempty(matches)
        error('未匹配到相关选项，请检查输入或补全datadelimiter参数中的元素')
    end
    Clength=length(C);
    if Clength==2 %如C40
        classidcell={};
        classidcell{1}=matches{1};
        classidcell{2}=C{2};
    end
    if Clength==3 %如C40-100
        if ~isempty(C{3})
        classidcell={};
        classidcell{1}=matches{1};
        classidcell{2}=C{2};
        classidcell{3}=matches{2};
        classidcell{4}=C{3};
        elseif isempty(C{3})
        classidcell={};
        classidcell{1}=matches{1};
        classidcell{2}=C{2};
        classidcell{3}=matches{2};
        else
            error('错误的输入，请检查')
        end
    end
    
    fprintf('\nspecies_classfy正在运行, 请等待...\n')
end


if tarclass=='c' || tarclass=='d'
    classid=input('请根据选择的c或d选项输入筛选要求, 比如 eleonlyCH, eleCO: \n','s');
    [~,matches]=strsplit(classid,datadelimiter,'CollapseDelimiters',false);
    classidcell={};
    for i=1:length(matches)
        classidcell{i}=matches{i};
    end
    fprintf('\n正在运行, 请等待...\n')
end

matchdatacol=[]; kk=1;[~,col]=size(outputdata);
for i=4:col
    [C,matches]=strsplit(outputdatast{i},datadelimiter,'CollapseDelimiters',false);
    classmatch={};
    C=delnull(C);
    if length(matches)~=length(C)
        [C,matches]=strsplit(outputdatast{i},datadelimiter,'CollapseDelimiters',false);
        C=C(1,2:end);
        for k=1:length(C)
            if isempty(C{k})
                C{k}='1';
            end
        end
    end
    for j=1:length(matches)
        classmatch{j,1}=matches{j};
        classmatch{j,2}=C{j};
    end
    
    
    if tarclass=='a'
        memcheck=ismember(classmatch(:,1),classidcell{1});
        if sum(memcheck)>=1
            [row,~]=size(memcheck);matchrow=[];matchnum=[];
            for j=1:row
                if memcheck(j,1)==1
                    matchrow(length(matchrow)+1,1)=j;
                    matchnum(length(matchnum)+1,1)=str2num(classmatch{j,2});
                end
            end
            if length(classidcell)==2 && matchnum==str2num(classidcell{2})
                matchdatacol(kk)=i;
                kk=kk+1;
            elseif length(classidcell)==3
                memcheck=ismember(classidcell,{'+'});
                if sum(memcheck)==1
                    if matchnum>=str2num(classidcell{2})
                        matchdatacol(kk)=i;
                        kk=kk+1;
                    end
                end
                memcheck=ismember(classidcell,{'-'});
                if sum(memcheck)==1
                    if matchnum<str2num(classidcell{2})
                        matchdatacol(kk)=i;
                        kk=kk+1;
                    end
                end
            elseif length(classidcell)==4
                memcheck=ismember(classidcell,{'-'});
                if sum(memcheck)==1
                    if str2num(classidcell{2})<=matchnum && matchnum<=str2num(classidcell{4})
                        matchdatacol(kk)=i;
                        kk=kk+1;
                    end
                end
            end
        end
    end
    
    
    
    if tarclass=='b'
        mw=str2num(classidcell{2});
        datamw=molecuweight(classmatch);
        if length(classidcell)==2
            if mw==round(datamw)
                matchdatacol(kk)=i;
                kk=kk+1;
            end
        end
        if length(classidcell)==3
            memcheck=ismember(classidcell,{'+'});
            if sum(memcheck)==1
                if datamw>=mw
                    matchdatacol(kk)=i;
                    kk=kk+1;
                end
            end
            memcheck=ismember(classidcell,{'-'});
            if sum(memcheck)==1
                if datamw<mw
                    matchdatacol(kk)=i;
                    kk=kk+1;
                end
            end
        end
        if length(classidcell)==4
            memcheck=ismember(classidcell,{'-'});
            if sum(memcheck)==1
                if datamw >= str2num(classidcell{2}) && datamw <= str2num(classidcell{4})
                    matchdatacol(kk)=i;
                    kk=kk+1;
                end
            end
        end
    end
    
    if tarclass=='c'
        sumcheck=0;
        for j=2:length(classidcell)
            memcheck=ismember(classmatch,classidcell{j});
            sumcheck=sumcheck+sum(sum(memcheck));
        end
        if sumcheck==length(classidcell)-1
            matchdatacol(kk)=i;
            kk=kk+1;
        end
    end
    
    if tarclass=='d'
        if length(classidcell)-1==length(matches)
            sumcheck=0;
            for j=2:length(classidcell)
                memcheck=ismember(classmatch,classidcell{j});
                sumcheck=sumcheck+sum(sum(memcheck));
                if sumcheck==length(matches)
                    matchdatacol(kk)=i;
                    kk=kk+1;
                end
            end
        end
    end  
end



dataexport={};
for j=1:length(matchdatacol)
    dataexport(:,j+3)=outputdata(:,matchdatacol(j));
end
dataexport(:,1:3)=outputdata(:,1:3);
disp('结果储存在dataexport中')
 
if isempty(matchdatacol)
    fprintf('\n\n未找到产物信息，请检查！\n\n')
end

if sumans=='y'
    fprintf('\n加和计算正在运行...\n')
    [a,b]=size(dataexport);
    sumdata=[];
    for i=2:a
        sumsum=0;
        for j=4:b
            sumsum=sumsum+dataexport{i,j};
        end
        sumdata(i-1,1)=sumsum;
    end
end
fprintf('\nspecies_classfy 运行结束\n')

fprintf('\n结果储存在dataexport中, 加和数据储存在sumdata中')
fprintf('\nHint：通过将dataexport数据重名为outputdata，原来的outputdata改为其他名字（如outputdata_raw），可以实现更加复杂的数据提取操作\n')
msgbox('species_classfy运行结束!');

clear classid classidcell classmatch Clength col datadelimiter dataoutcol dataoutcolchar dataoutputcol dataoutputrow sumsum
clear dataoutrow filename i j k kk matches matchnum matchrow memcheck outputdatast sumcheck tarclass saveans sumans a b mw
clear matchdatacol C row 
