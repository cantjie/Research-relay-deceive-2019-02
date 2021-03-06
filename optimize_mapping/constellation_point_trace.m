%constellation_point_trace.m
% purpose: to find trace of point, given the constrains to maximize the 
% distance among different quadrant.
% author: Cantjie
% last updated at 2019/03/27


clear;

theta_deg = 1:90;
N_sampling = 1;
theta_rad = theta_deg / 180 * pi;

SNR = 10;


a = zeros(1,90 * N_sampling);
% a(1:15) = 1 ./ cos(deg2rad(theta_deg(1:15)));
% a(16:45) = 2 * sqrt(2) * cos(deg2rad(45 - theta_deg(16:45))) - 2 * sqrt(sin(deg2rad((2 * theta_deg(16:45)))));
a(1:15 * N_sampling) = 1 ./ cos(theta_rad(1:15 * N_sampling));
a(15 * N_sampling + 1 : 75 * N_sampling) ...
    = 2 * sqrt(2) * cos(deg2rad(45) - theta_rad(15 * N_sampling + 1 : 75 * N_sampling)) ...
      - 2 * sqrt(sin(2 * theta_rad(15 * N_sampling + 1 : 75 * N_sampling)));
% a(45 * N_sampling + 1 : 75 * N_sampling) ...
%     = 2 * sqrt(2) * cos(deg2rad(45) - theta_rad(15 * N_sampling + 1 : 45 * N_sampling)) ...
%       - 2 * sqrt(sin(2 * theta_rad(15 * N_sampling + 1 : 45 * N_sampling)));
a(75 * N_sampling + 1 : 90 * N_sampling) = 1 ./ sin(theta_rad(75 * N_sampling + 1 : 90 * N_sampling));

Sr = sqrt(2) .* a .* sin(deg2rad(45) - theta_rad);
Cr = sqrt(2) .* a .* cos(deg2rad(45) - theta_rad); 

A = [2 - Sr; 2 + Cr];
B = [2 + Cr; 2 + Sr];
C = [2 - Cr; 2 - Sr];
D = [2 + Sr; 2 - Cr];
figure(1)
scatter(A(1,:),A(2,:));
hold on;
scatter(B(1,:),B(2,:));
scatter(C(1,:),C(2,:));
scatter(D(1,:),D(2,:));

%%
SNR = 10;
% 
% A_awgn = awgn(A,SNR,'measured');
% B_awgn = awgn(B,SNR,'measured');
% C_awgn = awgn(C,SNR,'measured');
% D_awgn = awgn(D,SNR,'measured');
% 
% 
% % figure
% scatter(A_awgn(1,:),A_awgn(2,:));
% hold on
% scatter(B_awgn(1,:),B_awgn(2,:));
% scatter(C_awgn(1,:),C_awgn(2,:));
% scatter(D_awgn(1,:),D_awgn(2,:));


%%
number_of_rotate_bits = 4;

theta_rotate_deg = 360 / (2^number_of_rotate_bits);

theta_selected = floor(0:theta_rotate_deg:360);
theta_selected(1) = [];  % delete the first element 0 ;

vertex = [A,B,C,D];
vertex_selected = vertex(:,theta_selected);
vertex_selected_rep = repmat(vertex_selected,1,10);
vertex_selected_rep_awgn = awgn(vertex_selected_rep,SNR,'measured');

figure(2)
scatter(vertex_selected(1,:), vertex_selected(2,:));
hold on 
scatter(vertex_selected_rep_awgn(1,:),vertex_selected_rep_awgn(2,:));










