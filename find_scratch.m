function out = find_scratch(lines, img, sharpImg)

distance_constraint = 10;
stack_size = 1000;
cross_correlation_nbr = 5;
connected_component_threshold = 7;
min_total_scratch_pixel = 100;
On = 1;
Visited = 0.5;
scratch_width = 5;

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
    
    p = p1;
    while norm(p - p2) > 1
    	p
        if sharpImg(p(2), p(1)) == On
    	    pset = extend_scratch_width(p, normal, scratch_width, sharpImg); % find nearest 5 pixels
            for pt = 1:length(pset)
                [scratches sharpImg] = grow_scratch(pset(pt, :), dir, sharpImg); % find scartch and update sharpImg
                point_stack(ps_size + 1: ps_size + size(scratches, 1), :) = scratches;
                ps_size = ps_size + size(scratches, 2);
    	    end
        end
        p = round(p + dir);
    end 
    % len = [0:1:norm(p2 - p1), norm(p2 - p1)]; % small bug (twice norm(p2 - p1))

end
end

%% extend_scratch_width: according the first p to border the scratch
function [pset] = extend_scratch_width(p, normal, scratch_width, sharpImg)
	ext_scratch_para = -scratch_width/2 : scratch_width/2;
    pset = round( ext_scratch_para' * normal + ones(size(ext_scratch_para))' * p );
    for ptn = 1:scratch_width  % remove invalid points
        if pset(ptn, 1) < 1 || pset(ptn, 2) < 1 || pset(ptn, 1) > size(sharpImg, 2) || pset(ptn, 2) > size(sharpImg, 1)
            pset(ptn, :) = [];
        end
    end 
end


%% grow_scratch: according the first p to grow the whole scratch
function [scratches sharpImg] = grow_scratch(p, dir, sharpImg)
    % parameters
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


    tdir = dir;
    % main loop
    while true
        sharpImg(p(2), p(1)) = Visited;
        n_ps = n_ps + 1;
        scratches(n_ps, :) = p;

        test = 0;
        % find next point
        while true
            np = round(p + tdir)
            if sum(np == p) == 2
                np = round(p + 2 * tdir);
            end

            if sum(np < 1) < 1 && np(2) < size(sharpImg, 1) && np(1) < size(sharpImg, 2) && sharpImg(np(2), np(1)) == On 
                p = np;
                dir = tdir;
                break;
            else
                theta = (rand(1) * 2 - 1) * pi / 5;
                theta
                tdir = dir * [cos(theta), sin(theta); -sin(theta), cos(theta)]; 
                dir
            end
            test = test + 1;
            if test > rand_test_time
                break;
            end
        end

        if test > rand_test_time
            break;
        end

    end

    
end
