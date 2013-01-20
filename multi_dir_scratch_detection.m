function multi_dir_scratch_detection(img)

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
	

	%%%% step 2: Line Direction Detection
	
	for b_img_idx = 1:12


	end
	%%%% step 3: Contour Drawing


	%%%% step 4: Core Detection


function DEBUG_SHOW(img)
	imshow(img)
	pause(1);
