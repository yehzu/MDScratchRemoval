function out =  multi_dir_scratch_detection(img, scratch_color, filename)

% scratch color preprocess
if scratch_color == 0
    img = imcomplement(img);
end

% trans to gray scale
if size(img, 3) == 3
   img = rgb2gray(img); 
end

% normalize
if max(img(:)) > 1
   img = double(img) / 255; 
end



% needs to be tuned
max_scratch_num = 6;
scratch_threshold = 50;
madian_filter_radius = 3;
gradiant_avg_nbr = 7;
texture_block_size = 9;
binary_threshold = 0.1;


[img_width, img_height, img_color] = size(img);


myfilter = fspecial('gaussian',[2 2], 0.8);
img = imfilter(img, myfilter, 'replicate');
%smooth_img = L0Smoothing(img, 0.0001, 1.5);
smooth_img = img;

%%%% step 1: preprocessing
    % the flow chart now:
    %   1. get sharp part image
    %   2. remove texture part (sharp image)
    %   3. denoise (sharp image)
    %   4. thresholding (accroding to the variance of the sharp image)
    %   5. hough transform
    
    
        
        % --- step 1 ---
    
        %%% Top-hat transform
        s1 = [1 1 1; 1 0 1; 1 1 1];
        %s2 = [2 2 2 2 2; 2 1 1 1 2; 2 1 0 1 2; 2 1 1 1 2; 2 2 2 2 2];
        s2 = [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1];
        
        sharpImg = normalize_image(imtophat(smooth_img, s2));
        DEBUG_SHOW(sharpImg, 'Sharp Image', true);
             
        
        % --- delete some noises
        sharpImg(sharpImg < binary_threshold) = 0;
        
        save_tmp_image(sharpImg, 'result/', filename, 'taphat');
        binary_image = sharpImg > binary_threshold;
        save_tmp_image(binary_image, 'result/', filename, 'threshold');
        % --- step 2 ---
        %%% remove texture
        DEBUG_SHOW(sharpImg >= 0.1, 'before', true);
        texture_area = pointwise_cooccurence(binary_image, texture_block_size);
        DEBUG_SHOW(texture_area, 'texture area', true);
        
        hough_input = sharpImg;
        hough_input(texture_area == 1) = 0; % remove texture
        % DEBUG_SHOW(hough_input, 'after', true);
        
        % --- step 3 ---
        
        %%% denoise
        %sharpImg = medfilt2(sharpImg, [madian_filter_radius madian_filter_radius]);
        %DEBUG_SHOW(sharpImg, 'median', true);
        
        
        
        
        % --- step 4 ---
        %%% cut the noises
        I_var = sqrt(var(hough_input(:)));
        hough_input( abs(hough_input) < 2 * I_var) = 0;  % note: how to decide the ratio?
        
        save_tmp_image(hough_input ~= 0, 'result/', filename, 'hough_input');
        %imwrite(hough_input ~= 0, 'result/hough_input.jpg', 'jpg');

        %%%% step 2: Line Direction Detection
        %DEBUG_SHOW(hough_input > 0.1, 'Input of Hough trans.', true);
        %imwrite(hough_input ~=  0, 'sharpImg.bmp', 'bmp');
        
        hough_input = hough_input ~= 0;

        [h_img, theta, rho] = hough(hough_input);


        % find scratches
        P = houghpeaks(h_img, max_scratch_num, 'threshold', ceil(0.6 * max(h_img(:))));
        lines = houghlines(img, theta, rho, P, 'FillGap', 999999999, 'MinLength', 7);

        % plot the lines
        figure, himg = imshow(img, 'Border', 'tight'), hold on
        max_len = 0;
        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');

            % Plot beginnings and ends of lines
            plot(xy(1,1),xy(1,2),'x','LineWidth',1,'Color','yellow');
            plot(xy(2,1),xy(2,2),'x','LineWidth',1,'Color','red');

            % Determine the endpoints of the longest line segment
            len = norm(lines(k).point1 - lines(k).point2);
            if (len > max_len)
                 max_len = len;
                 xy_long = xy;
            end
        end
        %set(gca,'position',[0 0 1 1],'units','normalized')
        saveas(himg, 'result/hough.tif');
        
        %%% next step~~
        DEBUG_SHOW(sharpImg > 0.1, 'sharpimg', true);

        % find precise scratch direction using globle direction
        %lines = refine_direction(lines, P, hough_input);
        [lines, imgId, imgs] = refine_direction(lines, P, sharpImg > binary_threshold);
      
        scratches = find_scratch(lines, img, sharpImg > binary_threshold, imgId, imgs);
        
        %SE1 = strel('ball',1,1);
        %SE2 = strel('ball',5,5);
        %scratches = imdilate(imclose(scratches, SE1), SE2);
        DEBUG_SHOW(scratches, 'scratches', true);
        
        
        
        
        se = strel('disk', 1); 
        out = imdilate(scratches ~= 0, se);
        out  = scratches;

end
    
function img = normalize_image(img)
    img = (img - min(img(:))) / (max(img(:)) - min(img(:)));
end

    
function DEBUG_SHOW(img, varargin)
%{
    %figure
	img = normalize_image(img);
	
    if nargin == 3
        if varargin{2} == true
            figure
        end
    end

    imshow(img)
    
        
    if nargin >= 2
		title(varargin{1})
    end
	waitforbuttonpress
%}
end



function save_tmp_image(img, dir, filename, vicename)
    imwrite(img, strcat(dir, filename, '_', vicename,'.bmp'), 'bmp');
end

