subjlist=dir('*.COORD');

for i = 1:size(subjlist)
    subj=subjlist(i).name;
    fid = fopen(subj,'r');
    fidw = fopen('coordinate.txt','w');   %���½��Ŀ��ı��ļ���Ҳ�Ǻ���д�����ݵ��ı��ļ�
    filename_b=[subj '_background.txt']
    fid_b = fopen(filename_b,'w');    %���½��Ŀ��ı��ļ���д�뱳�����ݵ��ı��ļ�
    filename_g=[subj '_gaba.txt']
    fid_g =  fopen(filename_g,'w'); %���½��Ŀ��ı��ļ���д��GABA���ݵ��ı��ļ�
    figure=0;
    for k=1:6336
        tline = fgetl(fid);
        marker=findstr('GABA',tline);
        if (k>46) && (k<279)
            fprintf(fidw,tline);  %����ȡ��������д���½��Ŀ��ı��ļ��У�ÿ��д��Ḳ��֮ǰ������
            
            %Ҳ��ֱ����disp(tline); ��ֱ���������д�����ʾ��ȡ������
            fprintf(fidw,'\n');  %��д������ݽ��л��д���
        end
        
        if (k>745) && (k<978)
            fprintf(fid_b,tline);  %����ȡ��������д���½��Ŀ��ı��ļ��У�ÿ��д��Ḳ��֮ǰ������
            %Ҳ��ֱ����disp(tline); ��ֱ���������д�����ʾ��ȡ������
            fprintf(fid_b,'\n');  %��д������ݽ��л��д���
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