
b = 0;
w = 1;
% I = imread('testLine.jpg');
% I = imread('test.jpg');


% I = imread('20060503165139725.jpg' );
% I = imread('a13425342_s.jpg');
 I = imread('1.jpg');
% I = imread('SITDOWN7.JPG');
% I = imread('h.png');
% I = imread('cup.png');
% I = imread('blur.png');
 
%I = imread('testImg/t05.jpg');

detected = multi_dir_scratch_detection(I, w);

