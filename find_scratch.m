function out = find_scratch(lines, img, sharpImg)

distance_constraint = 10;
stack_size = 1000;
cross_correlation_nbr = 5;
connected_component_threshold = 7;
min_total_scratch_pixel = 100;
On = 1;
Visited = 0.5;
scratch_width = 5;
gap_size = 10;
fill_gap_nbr = 3;

num_lines = length(lines);
[M, N] = size(img);

out = zeros(size(img));
point_stack = zeros(stack_size, 2);
ps_size = 0;

max_connected_component_num = -inf;


for line_id = 1:num_lines
    p1 = lines(line_id).point1;
    p2 = lines(line_id).point2;
    dir = (p2 - p1) / norm(p2 - p1);
    normal = [dir(2), -dir(1)];
    
	last_p = zeros(2, 1);
    p = p1;
    while norm(p - p2) > 1
        pset = extend_scratch_width(round(p), normal, scratch_width, sharpImg); % find nearest 5 pixels
        for pt = 1:length(pset)
		%	if sharpImg(round(p(2)), round(p(1))) == On
                if sharpImg(pset(pt, 2), pset(pt, 1)) == On
					
                    [scratches len sharpImg] = grow_scratch(pset(pt, :), dir, sharpImg); % find scartch and update sharpImg
                    if len > 3
						point_stack(ps_size + 1: ps_size + size(scratches, 1), :) = scratches;
						ps_size = ps_size + size(scratches, 1);

						if sum(last_p) ~= 0 && norm(last_p - pset(pt, :)) < gap_size
							intensity = zeros(ps_size, 1);
							
							for i = 1:ps_size
								intensity(i) = img(point_stack(i, 2), point_stack(i, 1));
							end
							vi = var(intensity);
							mi = mean(intensity);
							
							nor = norm(last_p - pset(pt, :));

							pt1 = round(linspace(last_p(1), pset(pt, 1), nor))
							pt2 = round(linspace(last_p(2), pset(pt, 2), nor))
							
							for i = 1:length(pt1)
								if abs(img(pt2(i), pt1(i)) - mi) < 2* vi
									fprintf(1, 'fill scratch\n');
									point_stack(ps_size + 1, :) = [pt1(i), pt2(i)];
									ps_size = ps_size + 1;
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
    
end
for pt = 1:ps_size	
	out(point_stack(pt, 2), point_stack(pt, 1)) = 1;
end
end

%% extend_scratch_width: according the first p to border the scratch
function [pset] = extend_scratch_width(p, normal, scratch_width, sharpImg)
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
function [scratches, maxlen, sharpImg] = grow_scratch(p, dir, sharpImg)
% parameters
sharpImg = double(sharpImg);
scratch_size = 1000;
stack_size = 1000;
Visited = 0.5;
On = 1;
rand_test_time = 100;

% storage
scratches = zeros(scratch_size, 2);
pt_stack = zeros(stack_size, 2);
n_ps = 0;
dir_stack = zeros(stack_size, 2);
n_ds = 0;


tdir = dir / dir(1);
% main loop
no_scratch = false;
maxlen = 0;
while true
    sharpImg(round(p(2)), round(p(1))) = Visited;
	maxlen = maxlen + 1;
	%imshow(sharpImg)
    %waitforbuttonpress

    n_ps = n_ps + 1;
    scratches(n_ps, :) = round(p);
    
    test = 0;
    % find next point
    while true
        np = [p(1) + 1 ,p(2) + dir(2)];
        rnp = round(np);
        
        if sum(rnp < 1) < 1 && rnp(2) < size(sharpImg, 1) && rnp(1) < size(sharpImg, 2) && sharpImg(rnp(2), rnp(1)) == On
            p = np;
            dir = tdir;
            break;
        else
            np1 = [np(1), np(2)+1];
            np2 = [np(1), np(2)-1];
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
                %theta = (rand(1) * 2 - 1) * pi / 5;
                %theta
                %tdir = dir * [cos(theta), sin(theta); -sin(theta), cos(theta)];
                %dir
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
end % end func
