function txt_cell = read_txt_to_cell(input_txt_path,separator)

fid = fopen(input_txt_path,'r');

txt_cell = {};


num = 1;

while ~feof(fid)
   
    tline = fgetl(fid);
    tline2 = regexp(tline,separator,'split');
    
    txt_cell(num,:) = tline2;
    num = num + 1;
    
end

fclose(fid);

