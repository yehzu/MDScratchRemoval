function out = pointwise_cooccurence(img, nbrsize)
% !! input is sharp image

% normalize the image
if max(img(:)) > 1
    img = double(img) / 255;
end
out = ones(size(img));


for times = 1:2

if times == 2
   img = img'; 
end


[M, N] = size(img);


k = 1;

DP_table = zeros([M, N + 1, 4]);

h = waitbar(0, 'Estabulish DP table');

fprintf(1, 'building table\n');
for jj = 2:(N+1)
    for ii = 2:M
        
        % initial the table
        DP_table(ii, jj, :) = DP_table(ii - 1, jj, :) + DP_table(ii, jj - 1, :) - DP_table(ii-1, jj-1, :);
       
        
        sub = img(ii, jj - 1) - img(ii - 1, jj - 1);
        mul = img(ii, jj - 1) * img(ii - 1, jj - 1);
        
        
        switch sub * 2 - mul
            case 0   % [0 0]
                idx = 1;
            case -1  % [1 1]
                idx = 4;
            case -2  % [0 1]
                idx = 2;
            case 2   % [1 0]
                idx = 3;
        end

        % update
        DP_table(ii, jj, idx) = DP_table(ii, jj, idx) + 1;
        
    end
    waitbar(jj * M / (M*N), h);
end
close(h)



% cooccurence matrix
f = zeros(M*N, 4);
for jj = 1:N
    for ii = 1:M
        glcm =   DP_table(min(ii + nbrsize, M), min(jj + nbrsize, N) + 1, :) ...
               - DP_table(max(ii - nbrsize, 1), min(jj + nbrsize, N) + 1, :) ...
               - DP_table(min(ii + nbrsize, M), max(jj - nbrsize, 1), :) ...
               + DP_table(max(ii - nbrsize, 1), max(jj - nbrsize, 1), :);

        if (ii - nbrsize < 1) || (jj - nbrsize < 1) || (ii + nbrsize > M) || (jj + nbrsize > N)
            area = (min(ii + nbrsize, M) - max(ii - nbrsize, 1)) * (min(jj + nbrsize, N) - max(jj - nbrsize, 1));
            glcm = glcm * (2 * nbrsize + 1) ^ 2 / area; % normalize boundary featrue
        end
    
        f(k, :) = glcm(:);
        k = k+1;
    end
end

k = 4;
fprintf(1, 'Clustering\n');

idx = [];

limit = 30;
counter = 0;
while isempty(idx)
    
    try
        [idx cent] = kmeans(f, k);
    catch err
        err.identifier
        counter = counter  + 1;
        if counter > limit
            k = k -1;
        end
    end
end
cent
%{


v = zeros(k, 1);

gradidx = zeros(k, 1);
[mag, dir] = imgradient(img, 'CentralDifference');


for i = 1:k
   area = sum(idx == i);
   % check the area
   if area > M*N / 3 
       out(idx == i) = 0;
       fprintf(1, 'texture %d is excluded', i);
   end
end
%}
%{
for i = 1:k
   %gradidx(i) = sum(mag(idx == i))

%   sum(mag(idx == i)) / sum(idx == i)
%   var(img(idx == i))
    var(dir(idx == i))
    figure
   hist(dir(idx == i) .* mag(idx==i))
   figure
   tmp = zeros(size(img));
   tmp(idx == i) = 1;
   imshow(tmp)
   waitforbuttonpress
   val = img(idx == i);
   v(i) = sqrt(var(val(:))) / mean(val(:)); % coefficient of variance
end
%}
%{
decide = max(cent);
decide = decide(2);
for i = 1:k
    if cent(i, 2) == decide
        id = i;
        break;
    end
end
%}
id = selectFromClasses(cent, nbrsize)
if times == 1
out(idx == id) = 0;
else
   out = out';
   out(idx == id) = 0;
   out = out';
end
imshow(out)
waitforbuttonpress
end


end

function img = normalize_image(img)
    img = (img - min(img(:))) / (max(img(:)) - min(img(:)));
end

function id = selectFromClasses(cent, nbrsize)
    k = size(cent, 1);
    len = 2 * nbrsize + 1;
    scratch_width = 4; % mostly, a scratch's width is about 4 px
    range = [len len * sqrt(2)] * 2/3; % possible scratch len range
    approx_black_area = mean(- scratch_width * range + len ^ 2);
    
    candidate = zeros(4, 1);
    
    num_c = 1;
    for i = 1:k
        % if 1-0 and 0-1 pair large enough
        if cent(i, 2) > range(1) && cent(i, 3) > range(1)
            candidate(num_c) = i;
            num_c = num_c + 1;
        end
    end
    num_c = num_c - 1;

    candidate;
    if num_c == 0
        fprintf(1, 'no candidate....');
		
		cri = cent(:, 2) .* cent(:, 3);
        mcri = max(cri);
        id = find(cri == mcri);
        
        return;
    end
   
    % check 0-0 and 1-1 pair 
    dist = abs(cent(candidate(1:num_c), 1) - approx_black_area);
    mdist = min(dist);
    i = find(dist==mdist(1));
    id = candidate(i);
end
