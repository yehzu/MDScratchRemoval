function [houghSpace, theta, rho] = modified_hough(Img)

Img = double(Img);
if max(Img(:) > 1)
    Img = Img / max(Img(:));
end

% default resolution
thetaResolution = 0.5;
rhoResolution = 0.5;


[M,N] = size(Img);

% constract theta

    theta = linspace(-90, 0, ceil(90/thetaResolution) + 1);
    theta = [theta -fliplr(theta(2:end - 1))];

    
% constract rho

    D = sqrt((M - 1)^2 + (N - 1)^2);
    q = ceil(D/rhoResolution);
    nrho = 2*q + 1;
    rho = linspace(-q*rhoResolution, q*rhoResolution, nrho);

    [mm, nn] = meshgrid(1:M, 1:N);
    xIndicies = nn(:)';
    yIndicies = mm(:)';

    %Preallocate space for the accumulator array

    accumulator = zeros(length(xIndicies),length(theta));
 
%Preallocate cosine and sine calculations to increase speed. In
%addition to precallculating sine and cosine we are also multiplying
%them by the proper pixel weights such that the rows will be indexed by 
%the pixel number and the columns will be indexed by the thetas.
%Example: cosine(3,:) is 2*cosine(0 to pi)
%         cosine(:,1) is (0 to width of image)*cosine(0)

    cosine = (0:M-1)'*cos(theta * pi / 180); %Matrix Outerproduct  
    sine = (0:N-1)'*sin(theta * pi / 180); %Matrix Outerproduct
    
    %%%% modified part -- weighted hough
    n = length(Img(:));
    
    accumulator(:,:) = cosine(yIndicies,:) + sine(xIndicies,:);
    houghSpace = zeros(length(rho), length(theta));
    
    %Scan over the thetas and bin the rhos 
   
    %{
    for i = (1:length(theta))
        houghSpace(:,i) = hist(accumulator(:,i),rho);
    end
    %}
    
   
    
    for i = (1:length(theta))
        [~, rhobin] = histc(accumulator(:,i), rho);
        %valid_idx = rhobin > 0;

        bin = accumarray(rhobin(:), Img(:));
        l = length(rho) - length(bin);
        houghSpace(:,i) = [bin; zeros(l, 1)];
        
    end    
   
  
    
    %{
    figure
    pcolor(theta,rho,houghSpace/max(houghSpace(:)));
    shading flat;
    title('Hough Transform');
    xlabel('Theta (radians)');
    ylabel('Rho (pixels)');
    colormap('gray');
    %}
%{
% rho's
cosine = (0:N-1)' * cos(theta);
sine = (0:M-1)' * sin(theta);

accum = zeros(1:N*M, length(theta));
for ii = 0:M-1
    for jj = 0:N-1
        accum(ii * N + jj + 1, :) = cosine(ii, :) + sine(jj, :);
    end
end
%}


