function multi_dir_scratch_detection(img)

[img_width, img_height, img_color] = size(img);

%%%% step 1: preprocessing
	% get sharp part of img
	h = fspecial('gaussian');
	bluredImg = imfilter(img, h);
	sharpImg = img - bluredImg;

	imshow(sharpImg);
	% apply band-pass filter (Kass and Witkin [5])
	


