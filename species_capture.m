%scrit1 file name species_capture
%purpose:
%This program is used to analysis species file
%version 1;2018.6.22
disp('##################################################################################################################################')
disp('欢迎使用本程序--by 刘强@中国工程物理研究院核物理与化学研究所，Email:liubinqiang@163.com')
disp('githup仓库地址: https://github.com/dadaoqiuzhi/RMD_Digging');
disp('参考文献: 1.Fuel 287 (2021) 119484. 2.ACS Appl. Mat. Interfaces 13(34) (2021) 41287-41302. 3.ACS Appl. Mat. Interfaces 2022, 14.(4), 5959-5972.')
disp('4.ACS Materials Letters 2023, 2174-2188. More work is coming!')
disp('###################x###############################################################################################################')
fprintf('可选择是否先运行species_analysis程序（内存需求不一样），可用此程序输出想要输出的部分产物含量随时间变化的结果,\n保留了文件前三列非分子式信息')

species=input('\n请输入产物分子式，分子式应与文件中一致（主要注意元素顺序），各分子式间用空格分开：\n','s');
species=upper(species);
species=strtrim(species);
species=strsplit(species);
if exist('outputdata','var')
    msgbox('outputdata已存在，请确保其中数据是由species_analysis产生');
    fprintf('\n\nspecies_capture程序运行中,请等待...\n\n')
    outputdatast=outputdata(1,:);
    datamatch=[];find=0;
    for i=1:length(species)
        for j=1:length(outputdatast)
            if strcmpi(species{i},(outputdatast{j}))
                find=1;
                datamatch(1,size(datamatch,2)+1)=size(datamatch,2)+1;
                datamatch(2,size(datamatch,2))=j;
            end
        end
        if find~=1
            fprintf('\n产物%s没有找到！',species{i});
        end
        find=0;
    end
    
    [~,checkcol]=size(datamatch);%检查匹配情况
    if checkcol~=length(species)
        if isempty(datamatch)
            fprintf('\n完全没有匹配到产物，原始文件可能未有该产物或者输入错误，请小心检查！！！');
            %         return;
        else
            fprintf('\n部分产物没有匹配到，原始文件可能未有该产物或者输入错误，请小心检查！！！');
            %         return;
        end
    end
    if sum(ismember(datamatch,0))>=1
        fprintf('\n产物存在匹配错误，导致小标索引为0，请逐个输入分子式排查，清空工作空间产生的无用文件！！！');
        %     return;
    end
    
    
    outputdatanew={};
    for k=1:3
        outputdatanew(:,k)=outputdata(:,k);
    end
    for j=1:size(datamatch,2)
        outputdatanew(:,j+3)=outputdata(:,datamatch(2,j));
    end
    fprintf('\nspecies_capture分析结果存在outputdatanew中')
    
    
    
    
    
    
else
    fprintf('\n未调用species_analysis预先分析形成outputdata变量(占用内存大)，自动进行逐步分析\n')
    dataname=input('\n请输入要处理的species文件名：\n','s');
    fprintf('\nspecies_capture程序运行中,请等待...\n')
    outputdata_copy={};%控制读入输出
    rawdata=fopen(dataname,'r');%一次性导入大文件很占内存。rawdata=textread(dataname,'%s','delimiter','\n'),采用逐行读取处理
    dataline=fgetl(rawdata);%读取第一行
    datacell=textscan(dataline,'%s','delimiter','\n');%读取文本行，产物化学式
    datacellchar=char(datacell{1});
    datadel=strrep(datacellchar,'#','');%去除井号
    datarep=strtrim(datadel);%去掉首尾空格
    datasplit=strsplit(datarep);%分割字符，存储在cell数组中，每个单元为char类型，可用ismember检查成员
    datacellnum=length(datasplit);
    species_copy(1,1:3)={'Timestep','No_Moles','No_Specs'};
    for i=1:size(species,2)
        species_copy{1,3+i}=species{i};
    end
    outputdatanew={};
    outputdatanew=species_copy(1,:);
    outputdata_copy(1,:)=species_copy(1,:);
    outputdata_copy(2,:)=num2cell(zeros([1 length(species_copy)]));%数量设为0
    for j=1:datacellnum
        for k=1:size(outputdata_copy,2)
            if strcmpi(datasplit{j},outputdata_copy{1,k})
                outputdata_copy{2,k}=j;%记录数量所在位置
            end
        end
    end
    datalinenum=fgetl(rawdata);%读取相应产物名行下的纯数字文本行
    datalinenum=strtrim(datalinenum);%去掉数字文本首尾空格
    datalinenum=strread(datalinenum);%读取数值矩阵
    for i=1:size(outputdata_copy,2)%将产物数量加在相应产物名同列的下一行
        if outputdata_copy{2,i}~=0
        outputdata_copy{2,i}=datalinenum(outputdata_copy{2,i});
        end
    end
    outputdatanew(2,:)=outputdata_copy(2,:);
    
    
    while ~feof(rawdata)%判断指针是否在文件尾,不在则得到1，即true。处理后面的数据，包括产物和数量
        dataline=fgetl(rawdata);
        if ~isempty(dataline) && ischar(dataline) && length(dataline) > 1 %检查是否为空,且是奇数行
            datacell=textscan(dataline,'%s','delimiter','\n');%读取文本行，即产物的化学式
            datacellchar=char(datacell{1});
            datadel=strrep(datacellchar,'#','');%去除井号
            datarep=strtrim(datadel);%去掉首尾空格
            datasplit=strsplit(datarep);%分割字符，存储在cell数组中，每个单元为char类型，可用ismember检查成员
            datacellnum=length(datasplit);
            
            outputdata_copy(2,:)=num2cell(zeros([1 length(species_copy)]));%数量设为0
            for j=1:datacellnum
                for k=1:size(outputdata_copy,2)
                    if strcmpi(datasplit{j},outputdata_copy{1,k})
                        outputdata_copy{2,k}=j;%记录数量所在位置
                    end
                end
            end
            datalinenum=fgetl(rawdata);%读取相应产物名行下的纯数字文本行
            datalinenum=strtrim(datalinenum);%去掉数字文本首尾空格
            datalinenum=strread(datalinenum);%读取数值矩阵
            for i=1:size(outputdata_copy,2)%将产物数量加在相应产物名同列的下一行
                if outputdata_copy{2,i}~=0
                    outputdata_copy{2,i}=datalinenum(outputdata_copy{2,i});
                end
            end
            outputdatanew(size(outputdatanew,1)+1,:)=outputdata_copy(2,:);
        else
            break
        end
    end
    fclose(rawdata);%关闭文件
    for i=1:size(outputdatanew,2) %检查匹配情况
        if sum(cell2mat(outputdatanew(2:end,i)))==0
            fprintf('完全没有匹配到产物%s，原始文件可能未有该产物或者输入错误，请小心检查！！！',outputdatanew{1,i});
        end
    end
end




expoans=input('\n请问是否导出数据到excel表？y导出，n不导出。y/n:\n','s');
expoans=lower(expoans);
if expoans=='y'
    [dataoutrow,dataoutcol]=size(outputdatanew);%导出数据
    dataoutputrow=strcat('A','1');
    dataoutcolchar=char(65+dataoutcol-1);
    dataoutputcol=strcat(dataoutcolchar,num2str(dataoutrow));
    filename='output_mydata.xlsx';
    xlswrite(filename,outputdatanew,dataoutputrow:dataoutputcol)
    fprintf('\nspecies_capture分析结果已经导出到excel:output_mydata中')
end
fprintf('\nspecies_capture程序运行结束\n\n')
disp('species_capture分析结果储存在outputdatanew中')

clear datamatch dataoutcol dataoutrow dataoutcolchar dataoutputcol  dataoutputrow i j k outputdatast 
clear filename expoans checkrow checkcol find outputdata_copy datacell datacellchar datacellnum datadel dataline 
clear datalinenum dataname datarep datasplit rawdata 