clc;
clear all;
close all;
addpath('mex');

resize = 1;
resize_scale = 0.2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parameter settings %%%%%%%%%%%%%%%%%%%%%%%%%%%
max_disparity = 255;

sigma_e = 10.00; %Scale Parameters
tau_e = 0.2; %Truncation Parameter

sigma_psi = 85; %Scale Parameters
tau_psi = 7; %Truncation Parameter

sigma_g = 1.0; %Scale Parameters
tau_g = 1.7; %Truncation Parameter

sigma_c = 0.2; %Scale Parameters
tau_c = 5.0; %Truncation Parameter

r = 0.0015; %Restart Probability (1-c)
t = 15; %The number of iteration

superpixel_size = 16000; %Desired number of superpixels, K
spatial_weight = 5; %Weighting between color similarity and spatial proximity, M
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('./lookup_table.mat');
penalty_function = zeros(max_disparity, max_disparity);
for i = 1 : max_disparity
    for j = 1 : max_disparity
        diff = abs(i - j);
        if diff < tau_psi
            penalty_function(i,j) = ( diff * diff / sigma_psi / sigma_psi );
        else
            penalty_function(i,j) = ( tau_psi * tau_psi / sigma_psi / sigma_psi );
        end
    end
end

for iteration = 1 : 1
    
    left = imread('images/g17_left.png'); 
    right = imread('images/g17_right.png');
    
    if resize == 1
        left = imresize(left,resize_scale);
        right = imresize(right,resize_scale); 
    end
%% Stereo Matching
    left_image = rgb2gray(left);
    right_image = rgb2gray(right);
    [left_disparity_map, right_disparity_map] = stereo_matching(left_image, right_image, max_disparity, sigma_e, tau_e, sigma_psi, tau_psi, sigma_g, tau_g, sigma_c, tau_c, r, t, superpixel_size, spatial_weight, lookup_table, penalty_function ); 
    color_disparity = disp_to_color(left_disparity_map,max_disparity);
    drawnow;

end

disp = rgb2gray(color_disparity);
disp = imadjust(disp);

%% Joint-Histogram Filter
res = perform_jhf(disp,left);
dispMapOutput = mat2gray(res);

figure, imshow(disp); title('Initial Depth');
figure, imshow(dispMapOutput); title('Filtered Depth');
