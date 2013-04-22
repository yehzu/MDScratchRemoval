function out = find_scratch(lines, img, sharpImg)
sharpImg = double(sharpImg);
% may use cross corelation
distance_constraint = 5;
stack_size = 1000;
cross_correlation_nbr = 5;
On = 1;
Visited = 0.5;


num_lines = length(lines);
[M, N] = size(img);

out = zeros(size(img));
stack = zeros(stack_size, 2);

for line_id = 1:num_lines % each line
    p1 = lines(line_id).point1;
    p2 = lines(line_id).point2;
    dir = (p2 - p1) / norm(p2 - p1);
    normal = [dir(2), -dir(1)];
    len = [0:1:norm(p2 - p1), norm(p2 - p1)]; % small bug (twice norm(p2 - p1))
    
    potential_scratch_pixels = - ones(ceil(4 * sqrt(M^2 + N^2)), 2); % initial memory size is 4 * diag of image
    
    k = 1;
    for l = len
        center = round(p1 + l * dir);
        
        % boundary detection
        if sum(center <= 0) > 0 || sum(center(2) > M) > 0 || sum(center(1) > N) > 0
			continue;
        end
        
        if sharpImg(center(2), center(1)) == On % is scratch point
            
            % ---
			%recursive part, find connected component
			
            sharpImg(center(2), center(1)) = Visited;
            stack(1, :) = center;
			s_ptr = 1;
			
			while true
				% get the scratch point from the stack, and collect all the connected component.
				point = stack(s_ptr, :);
				s_ptr = s_ptr - 1;
                 
				potential_scratch_pixels(k, :) = point;
				k = k + 1;
                   
                %{
				% 4-connected neighborhoods 
				neighbors = [point(1), point(2) + 1;
							 point(1), point(2) - 1;
							 point(1) + 1, point(2);
							 point(1) - 1, point(2)];
                num_nbr = 4;
                %}
                
                % 8-connected neighborhoods
                neighbors = [point(1), point(2) + 1;
							 point(1), point(2) - 1;
							 point(1) + 1, point(2);
							 point(1) - 1, point(2);
                             point(1) + 1, point(2) + 1;
							 point(1) - 1, point(2) - 1;
							 point(1) + 1, point(2) - 1;
							 point(1) - 1, point(2) + 1];
                num_nbr = 8;
                
				
                for pt = 1:num_nbr
                    if sum(neighbors(pt, :) <= 0) > 0 || sum(neighbors(pt, 2) > M) > 0 || sum(neighbors(pt, 1) > N) > 0
						continue;
                    end
                    
                    u = neighbors(pt, :) - p1;
                    if sqrt(norm(u)^2 - (u * dir')^2) > distance_constraint
                       continue; 
                    end
                    
                    if sharpImg(neighbors(pt, 2), neighbors(pt, 1)) == On
                        
                        % check stack size
                        if s_ptr == stack_size
                           stack_size = stack_size * 2;
                           stack = [stack; zeros(size(stack))];
                        end
                        
                        sharpImg(neighbors(pt, 2), neighbors(pt, 1)) = Visited;
                        s_ptr = s_ptr + 1;
						stack(s_ptr, :) = neighbors(pt, :);
                    end
                end
				
                if s_ptr == 0
                    break;
                end
			end  % end while
            % ---
            
        end
    end

    k = k - 1;
    
	% check each side of the scratch
    for point_id = 1:k
        % should be modified, neighbor pixels
        p_pix = potential_scratch_pixels(point_id, :);
        out(p_pix(2), p_pix(1)) = is_scratch_pixel(img, sharpImg, p_pix, normal, cross_correlation_nbr);
    end
    
end

end %end function

function bool = is_scratch_pixel(img, sharpImg, p_pix, normal, cross_correlation_nbr)
	% img: gray scale image
	% p_pix: the scratch pixel which would be determined
	% normal: normal vector
	% nbr: compare size
    weber_coeff = 0.1;
    bool = false;
	len = 1:cross_correlation_nbr;
    pattern = zeros(cross_correlation_nbr, 2);
    [M, N] = size(img);
   
	o_p_pix = p_pix;
    for dir = 1:2 % two side
        
        cur_dir = (-1)^dir * normal; 
		
		p_p_pix = o_p_pix;
		
		% move to the edge of the scratch
		while true
			p_p_pix = p_p_pix + 0.1 * cur_dir;
			p_pix = round(p_p_pix);

            if sum(p_pix < 1) > 0 || p_pix(2) > M || p_pix(1) > N  % check boundary
				break;
			end
			if sharpImg(p_pix(2), p_pix(1)) == 0
				break;
			end
		end

		% compare the mean of two sides of the scratch 
        for l = len
            pt = round(p_pix + l * cur_dir);
            if sum(pt < 1) > 0 || pt(2) > M || pt(1) > N  % check boundary
                continue;
            end
            pattern(l, dir) = img(pt(2), pt(1));
        end
       
    end

    delta = abs(mean(pattern(:, 1)) - mean(pattern(:, 2)));
	dth = delta / min(mean(pattern(:, 1)), mean(pattern(:, 2)));

	s_delta = max(abs(img(o_p_pix(2), o_p_pix(1)) - mean(pattern(:, 1))), abs(img(o_p_pix(2), o_p_pix(1)) - mean(pattern(:, 2))));
	s_dth = s_delta / min(mean(pattern(:, 1)), mean(pattern(:, 2)));
	
	if dth < weber_coeff && s_dth > weber_coeff
        bool = true;
    end
end
