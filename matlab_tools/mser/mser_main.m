

%% 读取图片
% [filename,pathname]=uigetfile('*.*','choose a picture');
% path = [pathname filename];
% colorImage = imread(path);
colorImage = imread('/media/archer/77d8a1b8-88fb-46a7-ab8e-436ba8727112/MSER/img/JPEGImages/Challenge2_Test_016.jpg');
fcn_output = imread('/media/archer/77d8a1b8-88fb-46a7-ab8e-436ba8727112/MSER/img/image/Challenge2_Test_016.png');

% figure;
% imshow(colorImage);
% 
% figure;
% imshow(fcn_output);

%% mser区域提取
grayImage = rgb2gray(colorImage);

index = find(fcn_output<180);

grayImage(index) = 0;

figure;
imshow(grayImage);

mserRegions = detectMSERFeatures_zx(grayImage);

mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
% figure;
% imshow(mserRegionsPixels);


%%  把mser区域的坐标系数取出来，然后将相应系数的地方赋值为真。取出mser区域。
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
figure;imshow(mserMask);

%% 粗滤除
[p_image,cwidth] =conComp_analysis(mserMask);
figure;imshow(colorImage);
wi= median(cwidth(:))/2;
se1=strel('line',wi,0);
p_image_dilate= imclose(p_image,se1);

%% 细滤除
[rec_word,img_color,img_bw]=f_conComp_analysis(p_image_dilate,colorImage,p_image);