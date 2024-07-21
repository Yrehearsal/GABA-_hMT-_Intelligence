subjlist=dir('*.COORD');

for i = 1:size(subjlist)
    subj=subjlist(i).name;
    fid = fopen(subj,'r');
    fidw = fopen('coordinate.txt','w');   %打开新建的空文本文件，也是后续写入数据的文本文件
    filename_b=[subj '_background.txt']
    fid_b = fopen(filename_b,'w');    %打开新建的空文本文件，写入背景数据的文本文件
    filename_g=[subj '_gaba.txt']
    fid_g =  fopen(filename_g,'w'); %打开新建的空文本文件，写入GABA数据的文本文件
    figure=0;
    for k=1:6336
        tline = fgetl(fid);
        marker=findstr('GABA',tline);
        if (k>46) && (k<279)
            fprintf(fidw,tline);  %将读取到的数据写入新建的空文本文件中，每次写入会覆盖之前的数据
            
            %也可直接用disp(tline); 可直接在命令行窗口显示读取的数据
            fprintf(fidw,'\n');  %对写入的数据进行换行处理
        end
        
        if (k>745) && (k<978)
            fprintf(fid_b,tline);  %将读取到的数据写入新建的空文本文件中，每次写入会覆盖之前的数据
            %也可直接用disp(tline); 可直接在命令行窗口显示读取的数据
            fprintf(fid_b,'\n');  %对写入的数据进行换行处理
        end
        
        if (isempty(marker)==0) || (figure>0)
            if (isempty(marker)==1) && (figure<233)
                fprintf(fid_g,tline);
                fprintf(fid_g,'\n');
                figure=figure+1;
            elseif (isempty(marker)==0)
                if (marker==2)
                    figure=figure+1;
                end
            end
        end
    end
    data_c=importdata('coordinate.txt');
    data_temp=data_c';
    data_vector=data_temp(:);
    coordinate=data_vector(1:2314);
    
    data_b=importdata(filename_b);
    data_temp=data_b';
    data_vector=data_temp(:);
    background(:,i)=data_vector(1:2314);
    
    data_g=importdata(filename_g);
    data_temp=data_g';
    data_vector=data_temp(:);
    gaba(:,i)=data_vector(1:2314);
end