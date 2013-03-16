function out =  multi_dir_scratch_detection(img, scratch_color)
if scratch_color == 0
    img = imcomplement(img);
end

if size(img, 3) == 3
   img = rgb2gray(img);
end

if max(img(:)) > 1
   img = double(img) / 255; 
end




% needs to be tuned
max_scratch_num = 10;
scratch_threshold = 50;
madian_filter_radius = 3;
gradiant_avg_nbr = 7;


[img_width, img_height, img_color] = size(img);

%%%% step 1: preprocessing
	%%% get sharp part of img
    %{
	h = fspecial('gaussian');
	bluredImg = imfilter(img, h);
	sharpImg = double(img - bluredImg);
    DEBUG_SHOW(sharpImg, 'sharp image');
    %}
           
        DEBUG_SHOW(img, 'original', true);
        
        texture_area = entropy_block(img, 8);
        DEBUG_SHOW(texture_area, 'texture area', true);
        
        
        sharpImg = img;
        sharpImg = localextrema(sharpImg, 2);
        
        %%% Top-hat transform
        s1 = [1 1 1; 1 0 1; 1 1 1];
        %s2 = [2 2 2 2 2; 2 1 1 1 2; 2 1 0 1 2; 2 1 1 1 2; 2 2 2 2 2];
        s2 = [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1];
        sharpImg = imtophat(sharpImg, s1);
        DEBUG_SHOW(sharpImg, 'tophat', true);
        
        %%% texture analysis
        texture = stdfilt(img);
        % sharpImg = sharpImg - texture;
        DEBUG_SHOW(texture, 'texture', true);
        
        
        
        %%% cut the noises
        I_var = sqrt(var(sharpImg(:)));
        sharpImg( abs(sharpImg) < 1.5 * I_var) = 0;  % note: how to decide the ratio?
        DEBUG_SHOW(sharpImg, 'Cutting noises');
        
        %%% denoise 
        %sharpImg = medfilt2(sharpImg, [madian_filter_radius madian_filter_radius]);
        
        DEBUG_SHOW(sharpImg, 'median', true);
        
        %%% exclude textrue part
        sharpImg(texture_area > 0.5) = 0;
        DEBUG_SHOW(sharpImg, 'exclude texture', true);
        
        %{
        %%% refine the sharp img
        [row col] = find(sharpImg >= 1.5 * I_var);
        for ii = 1:length(row)
            for jj = 1:length(col)
                patch = 
                
            end
        end
        %}
        
    
    
    
    
    
    
    
    %%% normalize the image
    
    
    
    
    %%% normalize the image
    
    
	%sharpImg = sharpImg / max(sharpImg(:));
	

	%%% apply band-pass filter (Kass and Witkin [5])
	%%% this substep generates 12 binary image
	%%% hard to understand...OMG????
	
    

    
    
	%%% 12 binary image are stored in cell array
    I_var = sqrt(var(sharpImg(:)));
    
    %%% elliminate strong edge responses 
    nonzero = sharpImg(sharpImg > 2/255);
    
    sharpImg(sharpImg > mean(nonzero(:))) = mean(nonzero(:));
    DEBUG_SHOW(sharpImg, 'normalized', true)
    
    band_pass_imgs{1} = sharpImg;
	bp_imgs_num = 1;

    
	

	%%%% step 2: Line Direction Detection
    
	for bp_imgs_idx = 1:bp_imgs_num
		%[h_img theta rho] = Hough_Grd(band_pass_imgs{bp_imgs_idx});
       
        %[h_img, theta, rho] = modified_hough(band_pass_imgs{bp_imgs_idx});
        [h_img, theta, rho] = hough(band_pass_imgs{bp_imgs_idx});
        
		if bp_imgs_idx == 1
			accumulator = h_img;
		else
			accumulator = accumulator + h_img;
		end
	end
	
	DEBUG_SHOW(accumulator/max(accumulator(:)), 'hough', true);
	
    
	accumulator = ceil(accumulator * 65535);
	
    
    % find scratches
	P = houghpeaks(accumulator, max_scratch_num, 'threshold', ceil(0.3*max(accumulator(:))));
	
	
	% plot lines
    if (img_color > 1)
        bw = im2bw(band_pass_imgs{1}, mean(band_pass_imgs{1}(:)));
    else 
        bw = band_pass_imgs{1};
    end
    
	lines = houghlines(bw, theta, rho, P, 'FillGap', 100000, 'MinLength', 7);
	figure, imshow(img), hold on
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

	

out = 0;
	%%%% step 3: Contour Drawing


	%%%% step 4: Core Detection


function DEBUG_SHOW(img, varargin)
    %figure
	img = (img - min(img(:))) / (max(img(:)) - min(img(:)));
	
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
