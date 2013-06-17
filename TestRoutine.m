
b = 0;
w = 1;





file = 'g02.png';
% file = 'testLine.jpg';
% file = 'test.jpg';


% file = '20060503165139725.jpg';
% file = 'a13425342_s.jpg';
% file = '1.jpg';
% file = '2.png'; %bad
% file = '3.png';  %ok
% file = '4.png'; %ok
% file = '4.jpg'; %ok
% file = '5.png'; %bad
% file = '6.png'; % ok bad test data
% file = 'SITDOWN7.JPG';
% file = 'SITDOWN7-1.JPG'; %ok
% file = 'h.png';
% file = 'cup.png';
% file = 'blur.png';
% file = 'testImg/t05.jpg';
% file = 'testImg/t09.jpg';


%file = 'c39.jpg'; %v

%file = 'e15.png'; %v
%file = '00139.png'; % v
%file = 'f10.png'; %bug
%file = 'g02.png';
% file = 'h1.jpg';
%file = 'l1.jpg';
%file = 'l2.jpg';
%file = 'l3.jpg';
%file = 'l4.jpg';
%file = 'l5.jpg';
%file = 'l6.jpg';
%file = 'l7.jpg';
%file = 'l8.jpg';

file = 't1.png';
file = 't2.png';
file = 't3.png';
file = 't4.png';
%file = 't5.png';
%file = 't6.png';
%file = 't7.png';
%file = 't8.png';
%file = 't9.png';  % must success
%file = 't10.png';
%file = 't11.png';
%file = 't12.png';
%file = 't13.png';
%file = 't14.png';
%file = 't15.png';

I = imread(file);
detected = multi_dir_scratch_detection(I, w, get_file_name(file));
imwrite(detected, strcat('result/', get_file_name(file), '_scratch','.bmp'), 'bmp');


%{
allfile = [...
%'testLine.jpg         ';...
%'test.jpg             ';...
'20060503165139725.jpg';...
'a13425342_s.jpg      ';...
'1.jpg                ';...
'2.png                ';... %bad
'3.png                ';...  %ok
'4.png                ';... %ok
'4.jpg                ';... %ok
'5.png                ';... %bad
'6.png                ';... % ok bad test data
'SITDOWN7.JPG         ';...
'SITDOWN7-1.JPG       ';... %ok
'h.png                ';...
'cup.png              ';...
'blur.png             ';...
'testImg/t05.jpg      ';...
'testImg/t09.jpg      ';...
'c39.jpg              ';... %v
'e15.png              ';... %v
'00139.png            ';... % v
'f10.png              ';... %bug
'g02.png              ';...
'h1.jpg               ';...
 ];
cell_file = cellstr(allfile);
for i = 1:size(allfile, 1)
    file = cell_file{i};
    I = imread(file);
    detected = multi_dir_scratch_detection(I, w, get_file_name(file));
    imwrite(detected, strcat('result/', get_file_name(file), '_scratch','.bmp'), 'bmp');
end
%}