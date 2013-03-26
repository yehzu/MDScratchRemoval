function out = pointwise_cooccurence(img, nbrsize)
% !! input is sharp image


% normalize the image
if max(img(:)) > 1
    img = double(img) / 255;
end

[M, N] = size(img);

out = zeros(M, N);

k = 1;
h = waitbar(0,'Computing');


f = [];

if isempty(f);
    f = zeros(M*N, 4);

    for jj = 1:N
        for ii = 1:M

            iidx = max(ii - nbrsize, 1) : min(ii + nbrsize, M);
            jidx = max(jj - nbrsize, 1) : min(jj + nbrsize, N);

            glcm = graycomatrix(img(iidx, jidx));

            f(k, :) = glcm(:);
            k = k+1;
        end
        waitbar(k/(M*N), h)
    end
end
    
    
close(h)

idx = [];


k = 4;
fprintf(1, 'Clustering\n');
while isempty(idx)
    try
        [idx c] = kmeans(f, k);
    catch err
    
    end
end

v = zeros(k, 1);
for i = 1:k
   val = img(idx == i);
   v(i) = sqrt(var(val(:))) / mean(val(:)); % coefficient of variance
end
[~, sid] = sort(v);
v
out(idx ~= sid(3)) = 1;

end

function img = normalize_image(img)
    img = (img - min(img(:))) / (max(img(:)) - min(img(:)));
end