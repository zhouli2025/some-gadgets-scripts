function a = extract_fileName_to_txt_zhouli(input_file_path,ext,output_file_path)


%display([input_file_path '*' ext]);

dd = dir([input_file_path '*' ext]); 

fid = fopen([output_file_path 'yours.txt'],'a+');

for i = 1:length(dd)
    
    [weizhi, fileName, ext] = fileparts(dd(i).name);
    fprintf(fid,'%s\n',fileName); 
    
end

fclose(fid);

a = 1;