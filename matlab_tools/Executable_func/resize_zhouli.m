function a = resize_zhouli(input_img_path,output_img_path,cat_of_img,target_size)

if ~isdir(output_img_path)
    
   mkdir(output_img_path); 
end

dd = dir([input_img_path '*' cat_of_img]);

for i = 1:length(dd)
   [weizhi, name, ext] = fileparts(dd(i).name);
   display([input_img_path dd(i).name]);
   img = imread([input_img_path dd(i).name]);
   [x,y,z] = size(img);
   if(x > y)
   result = imresize(img,[target_size target_size*y/x],'bilinear');
   else
   result = imresize(img,[target_size*x/y target_size],'bilinear');       
   end
   imwrite(result,[output_img_path dd(i).name]);
end


a = 1;