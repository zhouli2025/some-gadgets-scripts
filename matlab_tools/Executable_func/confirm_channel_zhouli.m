function a = confirm_channel(input_img_path);

images = dir([input_img_path '*.jpg']);

for i = 1:length(images)
    
   img = imread([input_img_path images(i).name]);
   
   [x,y,z] = size(img);
   
   if(z ~= 3)
       
       display(images(i).name);
   end
    
end

a = 1;