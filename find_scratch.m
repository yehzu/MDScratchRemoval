function out = find_scratch(lines, img, sharpImg)
% may use cross  corelation

num_lines = length(lines);
[M, N] = size(img);

out = zero(size(img));

for line_id = 1:num_lines % each line
    p1 = lines(line_id).point1;
    p2 = lines(line_id).point2;
    dir = p2 - p1 / norm(p2 - p1);
    normal = [dir(2), -dir(1)];
    len = [0:1:norm(p2 - p1), norm(p2 - p1)]; % small bug
    
    potential_scratch_pixels = - ones(4 * sqrt(M^2 + N^2), 2); % initial memory size is 4 * diag of image
    
    k = 1;
    for l = len
        center = p1 + l * dir;
        if sharpImg(center(1), center(2)) == 1 % is scratch point
            sharpImg(center(1), center(2)) = 0;
            potential_scratch_pixels(k, :) = center;
            
            % ---
                %recursive part, find connected component
            
            % ---
            
            k = k + 1;
        end
    end
    
    
    k = k - 1;
    
    for point_id = 1:k
        % should be modified, neighbor pixels
        p_pix = potential_scratch_pixels(point_id);
        out(p_pix(1), p_pix(2)) = is_scratch_pixel(img, p_pix, normal);
        
    end
    
end