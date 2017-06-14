% Classify gestures in video.

% addpath('./Zernike_code/');
addpath('./template/');

template_list = {'scissor', 'jumuk', 'hab', 'garoro', 'bo'};
METHOD = 'skel'; % select method of {'skel', 'corr', 'pixel'}

v = VideoReader('depth-video.mp4');

v.CurrentTime = 60 + 12;
background_frame = readFrame(v);

v.CurrentTime = 1;
for i = 1:length(template_list)
        img = imread(template_list{i},'png');
        img = imresize(img,[100 100]);
    imageVolume{i} = img; 
end
 
switch lower(METHOD)     
        case 'skel'
            block_size = [10 10]; % image is divided in 10 x 10 
            entropyFilterFunction = @(theBlockStructure)entropy(theBlockStructure.data(:));
            for i = 1:length(template_list)
                img = imageVolume{i};
                img = bwmorph(img,'skel',Inf);
                img = blockproc(img,block_size,entropyFilterFunction);
                imageVolume{i} = img; 
            end
end

similarities = zeros(1, length(template_list));
while hasFrame(v)
    video = double(readFrame(v) - background_frame) / 255;
    video = video(:,:,1); % Convert to single channel.
    img2 = imbinarize(video, 0.1); % https://www.mathworks.com/help/images/ref/imbinarize.html
    img2 = bwareaopen(img2, 200); % https://www.mathworks.com/help/images/ref/bwareaopen.html
    % imshowpair(img1, img2, 'montage');

    [m, n] = size(img2);

    points = [];

    for i = 1:m
        for j = 1:n
            if img2(i, j) > 0
                points = [points; [j, i]];
            end
        end
    end

    meanpoint= mean(points);
    coeff = pca(points);

    % Rotate
    rotated_points = points * coeff;

    min_point = min(rotated_points);

    % rotated_points = rotated_points - min_point;
    rotated_points=bsxfun(@minus,rotated_points,min_point); % https://stackoverflow.com/questions/5967940/matlab-quickly-subtract-1xn-array-from-mxn-matrix-elements

    rotated_image_size = max(rotated_points);

    normalized_points_x = uint8(floor(rotated_points(:, 1) / rotated_image_size(1) * 99)) + 1; % https://www.mathworks.com/matlabcentral/newsreader/view_thread/319129
    normalized_points_y = uint8(floor(rotated_points(:, 2) / rotated_image_size(2) * 99)) + 1;

    normalized_points = unique([normalized_points_x normalized_points_y], 'rows');
    [m, n] = size(normalized_points);

    normalized_image = zeros(100, 100);

    for k = 1:m
        r = normalized_points(k, :);
        normalized_image(r(1), r(2)) = 1;
    end
    
    switch lower(METHOD)     
        case 'skel'
            normalized_image = bwmorph(normalized_image,'skel',Inf);
            normalized_image = blockproc(normalized_image,block_size,entropyFilterFunction);
    end
    
    for i = 1:length(template_list)
            switch lower(METHOD)     
                case 'skel'
                    r = corr2(normalized_image, imageVolume{i});
                    
                case 'corr'
                    r = corr2(normalized_image, imageVolume{i});
                    
                case 'pixel'
                    r = compare_pixels(normalized_image, imageVolume{i});
                    
            end
        similarities(i) = r;
    end
    
    [M,I] = max(similarities);
    imshow(video);
    disp([template_list(I) M]);
    
end
    