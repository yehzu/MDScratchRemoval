function out =  multi_dir_scratch_detection(img)

% needs to be tuned
max_scratch_num = 4;
scratch_threshold = 50;


[img_width, img_height, img_color] = size(img);

%%%% step 1: preprocessing
	% get sharp part of img
	h = fspecial('gaussian');
	bluredImg = imfilter(img, h);
	sharpImg = double(img - bluredImg);
	sharpImg = sharpImg / max(sharpImg(:));
	DEBUG_SHOW(sharpImg);

	% apply band-pass filter (Kass and Witkin [5])
	% this substep generates 12 binary image
	% hard to understand...OMG????
	

	% 12 binary image are stored in cell array
	band_pass_imgs{1} = im2bw(sharpImg, mean(sharpImg(:)));
	bp_imgs_num = 1;

	DEBUG_SHOW(band_pass_imgs{1})
	



	%%%% step 2: Line Direction Detection
	% accumulator = 0;
	for bp_imgs_idx = 1:bp_imgs_num
		[h_img theta rho] = hough(band_pass_imgs{bp_imgs_idx});
		if bp_imgs_idx == 1
			accumulator = h_img;
		else
			accumulator = accumulator + h_img;
		end
	end
	
	DEBUG_SHOW(accumulator/max(accumulator(:)));
	
	
	% find scratches
	P = houghpeaks(accumulator, max_scratch_num,'threshold', ceil(0.3*max(accumulator(:))))
	lines = houghlines(band_pass_imgs{1}, theta, rho, P, 'FillGap', 10, 'MinLength', 7);
	figure, imshow(img), hold on
	max_len = 0;
	for k = 1:length(lines)
		xy = [lines(k).point1; lines(k).point2];
		plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

		% Plot beginnings and ends of lines
		plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
		plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

		% Determine the endpoints of the longest line segment
		len = norm(lines(k).point1 - lines(k).point2);
		if ( len > max_len)
			 max_len = len;
			 xy_long = xy;
		end
	end

	

out = 0;
	%%%% step 3: Contour Drawing


	%%%% step 4: Core Detection


function DEBUG_SHOW(img)
	imshow(img)
	waitforbuttonpress
