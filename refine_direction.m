function outlines = refine_direction(lines, para, sharpImg)
	% back up of sharpImg
	origin = sharpImg;
	partitions = 5;
	max_scratch_num = 6;
	outlines = [];
    para_dist = 5;
	for line_id = 1:length(lines)   
		p1 = lines(line_id).point1;
    	p2 = lines(line_id).point2;
    	dir = (p2 - p1) / norm(p2 - p1);

    	pt = [linspace(p1(1), p2(1), partitions); linspace(p1(2), p2(2), partitions)];

    	for part = 1:partitions-1
    		conditioned_map = ROI_of_partition(sharpImg, pt(:, part), pt(:, part + 1));

    		[h_img, theta, rho] = hough(conditioned_map);
    		P = houghpeaks(h_img, max_scratch_num, 'threshold', ceil(0.7 * max(h_img(:))));
    		l = houghlines(sharpImg, theta, rho, P, 'FillGap', 100, 'MinLength', 7);
            
            %{
            for sub_lines = 1:length(l)
                
               if norm( P(sub_lines, :) - para(line_id, :)) < para_dist
                    outlines = [outlines l(sub_lines)];
               end
            end
            %}
            
    		for sub_lines = 1:length(l)
    			sp1 = l(sub_lines).point1;
    			sp2 = l(sub_lines).point2;
    			sdir = (sp1 - sp2) / norm(sp1 - sp2)
    			dir
    			ang = acos(sdir * dir')
    			if ang < pi / 180 * 20 || ang > pi - pi / 180 * 20 
    				ang = acos(sdir * dir')
    				outlines = [outlines l(sub_lines)];
    			end

    		end
            
    		%{
    		figure, imshow(ROI_of_partition(sharpImg, pt(:, part), pt(:, part + 1))), hold on
        	max_len = 0;
        	for k = 1:length(l)
          	  xy = [l(k).point1; l(k).point2];
            	plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');

	            % Plot beginnings and ends of lines
    	        plot(xy(1,1),xy(1,2),'x','LineWidth',1,'Color','yellow');
        	    plot(xy(2,1),xy(2,2),'x','LineWidth',1,'Color','red');

            	% Determine the endpoints of the longest line segment
            	len = norm(l(k).point1 - l(k).point2);
            	if (len > max_len)
               	  max_len = len;
               	  xy_long = xy;
            	end
        	end
        	waitforbuttonpress
        	%}
    	end

    	
	end


end



%% ROI_of_partition: function description
function [img] = ROI_of_partition(sharpImg, pt1, pt2)
	[M N] = size(sharpImg);
	dir = (pt1 - pt2) / norm(pt1 - pt2);
	img = sharpImg;

	[nn, mm] = meshgrid(1:N, 1:M);
	nn = nn - pt2(1);
	mm = mm - pt2(2);

	innerprod = nn.*dir(1) + mm .* dir(2);

	cond1 = innerprod > norm(pt1 - pt2);
	cond2 = innerprod < 0;

	img( cond1 + cond2 > 0) = 0;

	%{
	imshow(img);
	waitforbuttonpress
	%}
end
