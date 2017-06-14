% show a static images and similarity
addpath('./Zernike_code/'); % http://kr.mathworks.com/matlabcentral/fileexchange/38900-zernike-moments
addpath('./template/');

template_list = {'normalized_image', 'scissor', 'jumuk', 'hab', 'garoro', 'bo'};
METHOD = 'moment'; % select method of {'skel', 'corr', 'pixel', 'moment'}
normalized_image = imread('normalized_image.png');

switch lower(METHOD)     
        case 'skel'
            block_size = [10 10]; % image is divided in 10 x 10 
            entropyFilterFunction = @(theBlockStructure)entropy(theBlockStructure.data(:));
            normalized_image = bwmorph(normalized_image,'skel',Inf);
            normalized_image = blockproc(normalized_image,block_size,entropyFilterFunction);
end
% remove_noises % get normalized_image

similarities = zeros(1, length(template_list));

for i = 1:length(template_list)
    img = imread(template_list{i},'png');
    img = imresize(img,[100 100]);
    switch lower(METHOD)     
        case 'skel'
            img = bwmorph(img,'skel',Inf);
            img = blockproc(img,block_size,entropyFilterFunction);
            r = corr2(normalized_image, img);
            label = {['r = ' num2str(r)]};
        case 'corr'
            r = corr2(normalized_image, img);
            label = {['r = ' num2str(r)]};
        case 'pixel'
            r = compare_pixels(normalized_image, img);
            label = {['r = ' num2str(r)]};
        case 'moment'
            [~, A, Phi] = Zernikmoment(logical(img),4,2);
            label = {['A = ' num2str(A)]; ['\phi = ' num2str(Phi)]};
    end
    figure(1);subplot(2,3,i);imshow(img);
    xlabel(label);
end
