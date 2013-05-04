
b = 0;
w = 1;
% I = imread('testLine.jpg');
% I = imread('test.jpg');


% I = imread('20060503165139725.jpg' );
% I = imread('a13425342_s.jpg');
% I = imread('1.jpg');
% I = imread('2.png'); %bad
%I = imread('3.png');  %ok
%I = imread('4.png'); %ok
%I = imread('5.png'); %bad
I = imread('6.png'); % ok
% I = imread('SITDOWN7.JPG');
% I = imread('SITDOWN7-1.JPG'); %ok
% I = imread('h.png');
% I = imread('cup.png');
% I = imread('blur.png');
% I = imread('testImg/t05.jpg');
% I = imread('testImg/t09.jpg');

detected = multi_dir_scratch_detection(I, w);

