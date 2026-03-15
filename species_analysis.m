%scrit file name species_analysis
%purpose:
%This program is used to analysis species file
%version 1;2018.6.21
disp('##################################################################################################################################')
disp('欢迎使用本程序--by 刘强@中国工程物理研究院核物理与化学研究所，Email:liubinqiang@163.com')
disp('githup仓库地址: https://github.com/dadaoqiuzhi/RMD_Digging');
disp('参考文献: 1.Fuel 287 (2021) 119484. 2.ACS Appl. Mat. Interfaces 13(34) (2021) 41287-41302. 3.ACS Appl. Mat. Interfaces 2022, 14.(4), 5959-5972.')
disp('4.ACS Materials Letters 2023, 2174-2188. More work is coming!')
disp('##################################################################################################################################')
disp('本程序按分子式整理产物随时间的输出，占用内存较大，注意：本程序并不能识别同分异构体！！！')

dataname=input('请输入要处理的species文件名：\n','s');
tic %开始计时
disp('species_analysis程序运行中，请等待...')
outputdata={};line=1;%控制读入输出
rawdata=fopen(dataname,'r');%一次性导入大文件很占内存。rawdata=textread(dataname,'%s','delimiter','\n'),采用逐行读取处理
dataline=fgetl(rawdata);%读取第一行
datacell=textscan(dataline,'%s','delimiter','\n');%读取文本行，产物化学式
datacellchar=char(datacell{1});
datadel=strrep(datacellchar,'#','');%去除井号
datarep=strtrim(datadel);%去掉首尾空格
datasplit=strsplit(datarep);%分割字符，存储在cell数组中，每个单元为char类型，可用ismember检查成员
datacellnum=length(datasplit);
indexapp=[];%处理第二行数值数据，第一行产物的数量
for j=1:datacellnum
    outputdata{1,j}=datasplit{j};
    indexapp(j)=j;
end
datalinenum=fgetl(rawdata);%读取相应产物名行下的纯数字文本行
datalinenum=strtrim(datalinenum);%去掉数字文本首尾空格
datalinenum=strread(datalinenum);%读取数值矩阵
for i=1:length(indexapp)%将产物数量加在相应产物名同列的下一行
    outputdata{2,i}=datalinenum(i);
end


line=3;
while ~feof(rawdata)%判断指针是否在文件尾,不在则得到1，即true。处理后面的数据，包括产物和数量
    dataline=fgetl(rawdata);
    if ~isempty(dataline) && ischar(dataline) && length(dataline) > 1 %检查是否为空,且是奇数行
        datacell=textscan(dataline,'%s','delimiter','\n');%读取文本行，即产物的化学式
        datacellchar=char(datacell{1});
        datadel=strrep(datacellchar,'#','');%去除井号
        datarep=strtrim(datadel);%去掉首尾空格
        datasplit=strsplit(datarep);%分割字符，存储在cell数组中，每个单元为char类型，可用ismember检查成员
        datacellnum=length(datasplit);
        datafirstrow=outputdata(1,:);
        [indexcol,indexovlp,indexapp]=membercheck(datasplit,datafirstrow);%得到读入数据的重名产物在outputdata索引的索引indexcol以及其在
        %读入数据中的索引indexovlp，新产物在读入数据中的索引indexapp
        [datarow,datacol]=size(outputdata);
        for k=1:length(indexapp)%将新产物名字附加在输出文件的第一行后面
            outputdata{1,k+datacol}=datasplit{indexapp(k)};
        end
        
        datalinenum=fgetl(rawdata);%读取相应产物名行下的纯数字文本行（产物含量行）
        datalinenum=strtrim(datalinenum);%去掉数字文本首尾空格
        datalinenum=strread(datalinenum);%读取数值矩阵
        %datalinenum=strsplit(datalinenum);%读取数值元胞
        for i=1:length(indexcol)%归类已有的产物的数量
            outputdata{line,indexcol(i)}=datalinenum(indexovlp(i));
        end
        for i=1:length(indexapp)%归类新产物的数量
            outputdata{line,i+datacol}=datalinenum(indexapp(i));
        end
    else
        break
    end
    line=line+1;%下一行字符串行
end
fclose(rawdata);%关闭文件


[datarow,datacol]=size(outputdata);%将所有空值数值变为0
for i=2:datarow
    for j=1:datacol
        if isempty(outputdata{i,j})
        outputdata{i,j}=0;
        end
    end
end



% outputans=input('请问是否输出结果？大型数据需要很多时间，且必须关闭需要使用的Excel表。y/n?！：\n','s');
% outputans=lower(outputans);
% if outputans=='y'
%     [dataoutrow,dataoutcol]=size(outputdata);%导出数据
%     dataoutputrow=strcat('A','1');
%     if dataoutcol<=26%将outputdata的列数换为excel对应的字母列
%         dataoutcolchar=char(65+dataoutcol-1);
%         dataoutputcol=strcat(dataoutcolchar,num2str(dataoutrow));
%     else
%           dataoutcol=dec2base(dataoutcol,26);%利用短除法，对于大于26的列数，转化为26进制，再对应相应字母
%           dataoutcol=num2str(dataoutcol);
%           datadelimiter={'1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','0'};
%           [C,matches]=strsplit(dataoutcol,datadelimiter,'CollapseDelimiters',false);%拆分26进制数，得到单个字符
%           charcor=char26cor(matches);%得到excel里的列字符串
%           dataoutputcol=strcat(charcor,num2str(dataoutrow));
%     end    
%     filename='output_mydata.xlsx';
%     xlswrite(filename,outputdata,dataoutputrow:dataoutputcol)
%     disp('降解产物随时间变化的数据储存在outputdata中,导出在excel:output_mydata中')
% end
msgbox('产物导入整理完成！');
disp('可用species_capture函数抓取输出想要的产物随时间含量的变化数据,可用species_classfy输出归类总结产物含量随时间变化信息')
fprintf('\n\nspecies_analysis程序运行结束\n')
fprintf('\n数据储存在outputdata中\n\n')
Elapsedtime = toc; %结束计时
fprintf('\n本次运行耗时：%.2f s\n',Elapsedtime)

clear datacell datacellchar datacellnum datacol datadel datafirstrow dataline datalinenum datanow filename ans
clear dataoutcol dataoutcolchar dataoutputcol dataoutputrow datarow datarep datarow datasec datasplit statans
clear i j k line rawdata charcor datadelimiter dataoutrow matches outputans dataname indexapp indexcol indexovlp
clear tic toc Elapsedtime
