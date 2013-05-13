%% scratch_refinement: use inpainting technique to refine the scratch
function [scratch] = scratch_refinement(img, sharpImg, lines)
% parameters
patch_radius = 4;
search_radius = 30;
[M N] = size(img);
inpaint_img = img;
inpaint_patch_scratch_threshold = 10;
last_err = inf;
err = 0;

% do preprocessing on sharpimg
% erode the image
%SE = strel('ball',5,5);
%sharpImg = imerode(sharpImg, SE);

while abs(last_err - err) > 10^-6
	last_err = err;
	inpaint_img = img;
	inpaint_mask = sharpImg;
	%inpaint_img = zeros(size(img));
	for i = patch_radius+1:M-patch_radius
		for j = patch_radius+1:N-patch_radius


			if inpaint_mask(i, j) == 1
				% find patch to impaint
				%fprintf(1, 'i, j = %d, %d\n', i, j);
				minerr = inf;
				best_patch = zeros(2*patch_radius + 1);
				while true

					angle = (rand(1) * 2 - 1) * pi;
					r = rand(1) * search_radius;
					ni = round(i + r * sin(angle));
					nj = round(j + r * cos(angle));

					% patch index
					current_idi = i - patch_radius: i + patch_radius;
					current_idj = j - patch_radius: j + patch_radius;
					patch_idi = ni - patch_radius : ni + patch_radius;
					patch_idj = nj - patch_radius : nj + patch_radius;


					if min(patch_idi) < 1 + patch_radius || min(patch_idj) < 1 + patch_radius|| max(patch_idi) > M - patch_radius || max(patch_idj) > N - patch_radius
						% out of range
						continue
					else
						if sum(sum(sharpImg(patch_idi, patch_idj) == 1)) > inpaint_patch_scratch_threshold
							%fprintf(1, 'too much scratch points\n');
							% there are scratch in the patch 
							continue;
						else
							err = abs(img(patch_idi, patch_idj) - img( current_idi, current_idj) );
							if abs(minerr - sum(err(:))) < 10^-6
								inpaint_img(current_idi, current_idj) = best_patch;
								inpaint_mask(current_idi, current_idj) = 0;
								break
							end

							if minerr > sum(err(:))
								minerr = sum(err(:));
								best_patch = img(patch_idi, patch_idj);
								%best_patch = zeros(size(best_patch));
							end


						end
					end
				end

				%imshow(inpaint_img)
				%waitforbuttonpress
			end % if scratch



			% end double for loop
		end
	end


	% compute error
	diff_img = abs(img - inpaint_img);
	%imshow(inpaint_img);
	%waitforbuttonpress
	
	% compute the variance of error
	d_var = var(diff_img(diff_img ~= 0))
	num_err_pix = sum(sum(diff_img ~= 0));

	if d_var < 0.01
%		break;
	end
	% have to use a better criteria to update the scratch
	% update scratch
	sharpImg( abs(diff_img - mean(diff_img(:))) <  d_var) = 0;
	% sharpImg = abs(diff_img - mean(diff_img(:))) > 2 * d_var;

	imshow(sharpImg);
	%waitforbuttonpress
	err = sum(diff_img(abs(diff_img - mean(diff_img(:))) >  d_var)) / num_err_pix

end
imshow(sharpImg);
waitforbuttonpress
scratch = sharpImg;


