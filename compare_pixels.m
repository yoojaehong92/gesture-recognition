% https://kr.mathworks.com/matlabcentral/answers/44509-how-can-i-compare-whole-set-of-binary-images
function similarity = compare_pixcels(img1, img2)
imgOverlap_pos = img1 .* img2;

imgOverlap_neg = imcomplement(img1) .* imcomplement(img2);

imgOverlap = imgOverlap_pos + imgOverlap_neg;

count = 0;
for i = 1:100
    for j = 1:100
        if imgOverlap(i, j) > 0
            count = count + 1;
        end
    end
end

[x, y] = size(img1);
similarity = count / (x * y);
end