function out = entropy_block(img, nbrsize)
entropy_threshold = 0.1;  %this value can be modified


% normalize the image
if max(img(:)) > 1
    img = double(img) / 255;
end

[M, N] = size(img);
out = zeros(M, N);

Midxs = floor(M / nbrsize);
Nidxs = floor(N / nbrsize);

% res pixels
Mres = M - Midxs * nbrsize;
Nres = N - Nidxs * nbrsize;

es = zeros(length(Midxs) * length(Nidxs), 1);
k = 1;
for ii = (1:Midxs) - 1
    for jj = (1:Nidxs) - 1
        patch = img(ii * nbrsize + 1: (ii+1) * nbrsize, jj * nbrsize + 1: (jj+1) * nbrsize);
        
        
        s = sort(patch(:))';
        diff_s = abs(s - fliplr(s));
        
        % variance
        e = mean(diff_s(1:floor(nbrsize/2)));
        es(k) = e;
        k = k+1;
        
        if e > entropy_threshold 
            out(ii * nbrsize + 1: (ii+1) * nbrsize, jj * nbrsize + 1: (jj+1) * nbrsize) = e * ones(nbrsize);
        else
            out(ii * nbrsize + 1: (ii+1) * nbrsize, jj * nbrsize + 1: (jj+1) * nbrsize) = e * ones(nbrsize);
        end
        
        % entropy
        %{
        e = entropy(patch);
        if e > entropy_threshold 
            out(ii * nbrsize + 1: (ii+1) * nbrsize, jj * nbrsize + 1: (jj+1) * nbrsize) = zeros(nbrsize);
        else
            out(ii * nbrsize + 1: (ii+1) * nbrsize, jj * nbrsize + 1: (jj+1) * nbrsize) = ones(nbrsize);
        end
        %}
    end
end
imshow(out)
figure
e_var = var(es);
e_mean = mean(es);
min(es)
max(es)
out(out >= e_mean) = 1;
out(out < e_mean) = 0;

%con = out(out > 0/255);
%threshold = mean(con(:));
%out(out>threshold) = 1;
%out(out<threshold) = 0;
imshow(out)