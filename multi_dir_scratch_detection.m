function multi_dir_scratch_detection(img)

% needs to be tuned
max_scratch_num = 20;
scratch_threshold = 50;


[img_width, img_height, img_color] = size(img);

%%%% step 1: preprocessing
	% get sharp part of img
	h = fspecial('gaussian');
	bluredImg = imfilter(img, h);
	sharpImg = img - bluredImg;

	DEBUG_SHOW(sharpImg); 

	% apply band-pass filter (Kass and Witkin [5])
	% this substep generates 12 binary image
	% hard to understand...OMG????
	

	% 12 binary image are stored in cell array
	band_pass_imgs
	bp_imgs_num = 12;
	
	%%%% step 2: Line Direction Detection
	accumulator = 0;
	for bp_imgs_idx = 1:bp_imgs_num
		h_img = hough(band_pass_imgs{bp_imgs_idx});
		accumulator = accumulator + h_img;
	end

	% find scratches
	idx_record = zeros(2, max_scratch_num);
	num_points_record = zeros(1, max_scratch_num);
	for detect_scratch = 1:max_scratch_num
		[max_idx_m, max_idx_n, num_points]= find(accumulator == max(accumulator));
		
		if (detect_scratch == 1) || (num_points_record(detect_scratch - 1) - num_points < scratch_threshold)
			idx_record(:, detect_scratch) = [max_idx_m, max_idx_n];
			num_points_record(detect_scratch) = num_points;
			
			% neighborhood values are set to zero to prevent multiple overlapping scratches
			% % % % % % % % % % %
			% didn't implemented
			accumulator(max_idx_m, max_idx_n) = 0;
			
		else
			break;
		end
		
	end



	
	
	%%%% step 3: Contour Drawing


	%%%% step 4: Core Detection


function DEBUG_SHOW(img)
	imshow(img)
	pause(1);
