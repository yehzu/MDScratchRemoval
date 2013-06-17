function out = find_scratch(lines, img, sharpImg, imgId, imgs)
fprintf(1, 'find_scratch\n');

distance_constraint = 10;
stack_size = 1000;
cross_correlation_nbr = 5;
connected_component_threshold = 7;
min_total_scratch_pixel = 100;
On = 1;
Visited = 0.5;
scratch_width = 5;
gap_size = 20;
fill_gap_nbr = 2;
min_scratch_len = 6;

num_lines = length(lines);
[M, N] = size(img);

out = zeros(size(img));
point_stack = zeros(stack_size, 2);
ps_size = 0;

max_connected_component_num = -inf;

for search_dir = [-1 1] % two direction
for line_id = 1:num_lines
    p1 = lines(line_id).point1;
    p2 = lines(line_id).point2;
    dir = (p2 - p1) / norm(p2 - p1);
    
    % the direction and the search direction
    if abs(dir(1)) > abs(dir(2)) % mode 1
       if search_dir == 1
          if dir(1) < 0
             tmp = p1;
             p1 = p2;
             p2 = tmp;
             dir = -dir;
          end
          
       else
          if dir(1) > 0
             tmp = p1;
             p1 = p2;
             p2 = tmp;
             dir = -dir;
          end
       end
        
    else
        if search_dir == 1
		  if dir(2) < 0
             tmp = p1;
             p1 = p2;
             p2 = tmp;
             dir = -dir;
           end
        else
		   if dir(2) > 0
			 tmp = p1;
             p1 = p2;
             p2 = tmp;
             dir = -dir;
           end
        end
    end
    
    
    %{
    if dir(2) > 0
       if search_dir == 1
        % not same direction
     
           tmp = p1;
           p1 = p2;
           p2 = tmp;
           dir = -dir;
       end
    else
        if search_dir == -1
            tmp = p1;
           p1 = p2;
           p2 = tmp;
           dir = -dir;
        
        end
        
    end
    %}
    normal = [dir(2), -dir(1)];
    
	last_p = zeros(1, 2);
    p = p1;
    
    currid = imgId(line_id);
    sharpImg = imgs(:, :, currid);
    while norm(p - p2) > 1
        pset = extend_scratch_width(round(p), normal, scratch_width, sharpImg); % find nearest 5 pixels
        for pt = 1:length(pset)
		%	if sharpImg(round(p(2)), round(p(1))) == On
                if sharpImg(pset(pt, 2), pset(pt, 1)) == On
					
                    [scratches len sharpImg] = grow_scratch(pset(pt, :), dir, sharpImg, search_dir); % find scartch and update sharpImg
                    
                    scratches
                    if len > min_scratch_len
						point_stack(ps_size + 1: ps_size + size(scratches, 1), :) = scratches;
						ps_size = ps_size + size(scratches, 1);
                      
                        sdir = (last_p - pset(3, :)) / norm(last_p - pset(3, :));
                        ang = acos(sdir * dir');
                        
						if sum(last_p) ~= 0 && (ang < pi / 180 * 15 || ang > pi - pi / 180 * 15 ) && norm(last_p - pset(3, :)) < gap_size
							intensity = zeros(ps_size, 1);
							
                            % calculate the scratch intensity
							for i = 1:ps_size
								intensity(i) = img(point_stack(i, 2), point_stack(i, 1));
							end
							vi = var(intensity);
							mi = mean(intensity);
							% ----
                            
                            nor = norm(last_p - pset(pt, :));

							pt1 = round(linspace(last_p(1), pset(pt, 1), nor + 1));
							pt2 = round(linspace(last_p(2), pset(pt, 2), nor + 1));
							
							for i = 1:length(pt1)
								patch_j = pt1(i) - fill_gap_nbr:pt1(i) + fill_gap_nbr;
								patch_i = pt2(i) - fill_gap_nbr:pt2(i) + fill_gap_nbr;
                                
								for idx_i = 1: length(patch_i)
									for idx_j = 1: length(patch_j)
										if patch_j(idx_j) < 1 || patch_i(idx_i) < 1 || patch_j(idx_j) > N || patch_i(idx_i) > M || ...
                                           sqrt( (patch_j(idx_j)-pt1(i))^2 + (patch_i(idx_i) - pt2(i))^2) > fill_gap_nbr
											continue
                                        end
                                        
										if abs(img(patch_i(idx_i), patch_j(idx_j)) - mi) <= 1 * vi
										%	fprintf(1, 'fill scratch\n');
											point_stack(ps_size + 1, :) = [patch_j(idx_j), patch_i(idx_i)];
											ps_size = ps_size + 1;
										end
									end
								end

							end
							
						end
                        
						last_p = scratches(end, :);
					end
         %       end
            end
        end
        p = p + dir;
    end
    % len = [0:1:norm(p2 - p1), norm(p2 - p1)]; % small bug (twice norm(p2 - p1))
    imshow(sharpImg)
    waitforbuttonpress
end
end

for pt = 1:ps_size	
	out(point_stack(pt, 2), point_stack(pt, 1)) = 1;
end


end

%% extend_scratch_width: according the first p to border the scratch
function [pset] = extend_scratch_width(p, normal, scratch_width, sharpImg)
%fprintf(1, 'extend_scratch_width\n');
ext_scratch_para = -scratch_width/2 : scratch_width/2;
pset = round( ext_scratch_para' * normal + ones(size(ext_scratch_para))' * p );
n_delete = 0;
for ptn = 1:size(pset, 1)  % remove invalid points
    if pset(ptn - n_delete, 1) < 1 || pset(ptn - n_delete, 2) < 1 || pset(ptn - n_delete, 1) > size(sharpImg, 2) || pset(ptn - n_delete, 2) > size(sharpImg, 1)
        pset(ptn - n_delete, :) = [];
        n_delete = n_delete + 1;
    end
end
end

%% grow_scratch: according the first p to grow the whole scratch
function [scratches, maxlen, sharpImg] = grow_scratch(p, dir, sharpImg, search_dir)
%fprintf(1, 'grow_scratch\n');
% parameters
sharpImg = double(sharpImg);
scratch_size = 1000;
%stack_size = 1000;
Visited = 0.5;
On = 1;
rand_test_time = 100;

% storage
scratches = zeros(scratch_size, 2);
%pt_stack = zeros(stack_size, 2);
n_ps = 0;
%dir_stack = zeros(stack_size, 2);
%n_ds = 0;

mode = 0;
if abs(dir(1)) > abs(dir(2))
    mode = 1;
    tdir = dir / dir(1);
else
    mode = 2;
    tdir = dir / dir(2);
end
% tdir
% dir
% waitforbuttonpress

% main loop
no_scratch = false;
maxlen = 0;

while true
    sharpImg(round(p(2)), round(p(1))) = Visited;
	
	%imshow(sharpImg)
    %waitforbuttonpress

    n_ps = n_ps + 1;
    scratches(n_ps, :) = round(p);
    
    if mode == 1
        np1p = round([p(1), p(2) + 1]);
        np1m = round([p(1), p(2) - 1]);
    else
        np1p = round([p(1) + 1, p(2)]);
        np1m = round([p(1) - 1, p(2)]);
    end
    
    % add adjecent pixels
    if sum(np1p < 1) < 1 && np1p(2) < size(sharpImg, 1) && np1p(1) < size(sharpImg, 2) && sharpImg(np1p(2), np1p(1)) == On
        n_ps = n_ps + 1;
        scratches(n_ps, :) = round(np1p);
    end
    if sum(np1m < 1) < 1 && np1m(2) < size(sharpImg, 1) && np1m(1) < size(sharpImg, 2) && sharpImg(np1m(2), np1m(1)) == On
        n_ps = n_ps + 1;
        scratches(n_ps, :) = round(np1m);
    end

    
    test = 0;
    % find next point
    while true
        if mode == 1
            np = [p(1) + search_dir, p(2) + search_dir * dir(2)];
        else
            np = [p(1) + search_dir * dir(1), p(2) + search_dir];
        end
        
        rnp = round(np);
        
        if sum(rnp < 1) < 1 && rnp(2) < size(sharpImg, 1) && rnp(1) < size(sharpImg, 2) && sharpImg(rnp(2), rnp(1)) == On
            p = np;
            dir = tdir;
            break;
        else
            
            if mode == 1
                np1 = [np(1), np(2) + 1];
                np2 = [np(1), np(2) - 1];
            else
                np1 = [np(1) + 1, np(2)];
                np2 = [np(1) - 1, np(2)];
            end
            
            rnp1 = round(np1);
            rnp2 = round(np2);
            if sum(rnp1 < 1) < 1 && rnp1(2) < size(sharpImg, 1) && rnp1(1) < size(sharpImg, 2) && sharpImg(rnp1(2), rnp1(1)) == On
                p = np1;
                dir = tdir;
                break;
                
            elseif sum(rnp2 < 1) < 1 && rnp2(2) < size(sharpImg, 1) && rnp2(1) < size(sharpImg, 2) && sharpImg(rnp2(2), rnp2(1)) == On
                    p = np2;
                    dir = tdir;
                    break;
            else
                    no_scratch = true;
            end
               
        end % end if
        test = test + 1;
        if test > rand_test_time || no_scratch
            break;
        end % end if
            
    end % end while     
        
    if test > rand_test_time || no_scratch
        break;
    end % end if

        
        
    end % end while
	scratches = scratches(1:n_ps, :);
    
    maxlen = norm(scratches(1, :) - scratches(n_ps, :));
end % end func
