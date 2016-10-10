function x = sort_zhouli(input_txt_path,output_txt_path)

fid=fopen(input_txt_path,'r');

aaa = {}; %%v declar a cell to store the content of text


global size_row;
global size_col;

tline=fgetl(fid);
tline = regexp(tline, ' ','split'); %% split the line to an array
aaa(1,:) = tline;

[size_row, size_col] = size(tline);
num = 2;

while ~feof(fid) % 判断是否为文件末尾

    tline=fgetl(fid);
    tline = regexp(tline, ' ','split'); %% split the line to an array

    aaa(num,:) = tline;
    num = num +1;
    
end
fprintf('Sort Begins!\n');
b = sortrows(aaa,1);

[x,y]=size(b);

fid2=fopen(output_txt_path,'a+');

for i=1:x
  output = '';
  
  for j = 1:size_col
    output = sprintf('%s%s ',output,b{i,j});
  end
  
    fprintf(fid2,'%s\n',output);
end

fclose(fid2);

fclose(fid);
