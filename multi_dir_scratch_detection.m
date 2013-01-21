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
	band_pass_imgs

	%%%% step 2: Line Direction Detection
	accumulator = 0;
	for bp_imgs_idx = 1:12
		h_img = hough(band_pass_imgs{bp_imgs_idx});
		accumulator = accumulator + h_img;
	end
	



	%%%% step 3: Contour Drawing


	%%%% step 4: Core Detection


function DEBUG_SHOW(img)
	imshow(img)
	pause(1);
