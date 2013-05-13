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
        
        if sharpImg(round(p(2)), round(p(1))) == On
            pset = extend_scratch_width(round(p), normal, scratch_width, sharpImg); % find nearest 5 pixels
            for pt = 1:length(pset)
                [scratches sharpImg] = grow_scratch(pset(pt, :), dir, sharpImg); % find scartch and update sharpImg
                point_stack(ps_size + 1: ps_size + size(scratches, 1), :) = scratches;
                ps_size = ps_size + size(scratches, 1);
            end
        end
        p = p + dir;
    end
    % len = [0:1:norm(p2 - p1), norm(p2 - p1)]; % small bug (twice norm(p2 - p1))
    
end
point_stack
out(point_stack(:, 2), point_stack(:, 1)) = 1;
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

%{
%% grow_scratch: according the first p to grow the whole scratch
function [scratches sharpImg] = grow_scratch(pset, dir, sharpImg)



scratches = 1;
%}


%% grow_scratch: according the first p to grow the whole scratch
function [scratches, sharpImg] = grow_scratch(p, dir, sharpImg)
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
while true
    sharpImg(p(2), p(1)) = Visited;
    n_ps = n_ps + 1;
    scratches(n_ps, :) = p;
    
    test = 0;
    % find next point
    while true
        np = round([p(1) + 1 ,p(2) + dir(2)])
        
        
        if sum(np < 1) < 1 && np(2) < size(sharpImg, 1) && np(1) < size(sharpImg, 2) && sharpImg(np(2), np(1)) == On
            fprintf(1, 'road 1\n');
            p = np;
            dir = tdir;
            break;
        else
            np1 = round([p(1) + 1, p(2)]);
            np2 = round([p(1) - 1, p(2)]);
            
            if sum(np1 < 1) < 1 && np1(2) < size(sharpImg, 1) && np1(1) < size(sharpImg, 2) && sharpImg(np1(2), np1(1)) == On
                fprintf(1, 'road 2\n');
                p = np1;
                dir = tdir;
                break;
                
            elseif sum(np2 < 1) < 1 && np2(2) < size(sharpImg, 1) && np2(1) < size(sharpImg, 2) && sharpImg(np2(2), np2(1)) == On
                    fprintf(1, 'road 3\n');
                    p = np2;
                    dir = tdir;
                    break;
            else
                    no_scratch = true;
                    fprintf(1, 'road 4\n');
            end
                %theta = (rand(1) * 2 - 1) * pi / 5;
                %theta
                %tdir = dir * [cos(theta), sin(theta); -sin(theta), cos(theta)];
                %dir
        end % end if
        test = test + 1;
        if test > rand_test_time || no_scratch
            fprintf(1, 'break\n');
            break;
        end % end if
            
    end % end while     
        
    if test > rand_test_time || no_scratch
        fprintf(1, 'break\n');
        break;
    end % end if
        
        
        
    end % end while
end % end func
