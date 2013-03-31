function out = pointwise_cooccurence(img, nbrsize)
% !! input is sharp image

% normalize the image
if max(img(:)) > 1
    img = double(img) / 255;
end

[M, N] = size(img);

out = zeros(M, N);

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

        f(k, :) = glcm(:);
        k = k+1;
    end
end

k = 4;
fprintf(1, 'Clustering\n');

idx = [];
while isempty(idx)
    try
        [idx ~] = kmeans(f, k);
    catch err
    end
end

v = zeros(k, 1);
for i = 1:k
   val = img(idx == i);
   v(i) = sqrt(var(val(:))) / mean(val(:)); % coefficient of variance
end

[~, sid] = sort(v);
out(idx ~= sid(3)) = 1;

end

function img = normalize_image(img)
    img = (img - min(img(:))) / (max(img(:)) - min(img(:)));
end