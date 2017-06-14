% divide block
% https://kr.mathworks.com/matlabcentral/answers/126821-divide-and-compare-blocks
addpath('./template/');

set(gcf, 'Position', get(0,'Screensize')); 

template_list = {'normalized_image', 'scissor', 'jumuk', 'hab', 'garoro', 'bo'};

% remove_noises % get normalized_image

for i = 1:length(template_list)
    img = imread(template_list{i},'png');
    img = imresize(img,[100 100]);
    img = bwmorph(img,'skel',Inf);

    figure(1);subplot(2,3,i);imshow(img); hold on
    xlabel({[template_list{i}];});
    for k = 1:10:100
        x = [1 100];
        y = [k k];
        plot(x,y,'Color','w','LineStyle','-');
        plot(x,y,'Color','k','LineStyle',':');
        x = [k k];
        y = [1 100];
        plot(x,y,'Color','w','LineStyle','-');
        plot(x,y,'Color','k','LineStyle',':');
    end
    hold off
end
