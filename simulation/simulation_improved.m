%% 我也太蠢了吧？？？？
clc,clear

num_symbols = 2e5;

SNR_db_min = 0;
SNR_db_max = 30;
SNR_db_step = 3;
% SNR = 10^(SNR_db_min/10);

return_zero_min = 0;
return_zero_max = 6;
return_zero_step = 3;

with_scaling = 1;

bits_per_symbol = 2;  % 4QAM
rotation_symbols = 1;
rotation_bits = rotation_symbols * bits_per_symbol;

constellation_B_0 = [-2+2i,-2-2i,2+2i,2-2i];
constellation_fake = [-2+2i,-2-2i,2+2i,2-2i];
constellation_quadrant_0 = [-1+1i,-1-1i,1+1i,1-1i];
constellation_real_quadrant = constellation_quadrant_0;
constellation_ideal_quadrant = constellation_quadrant_0;
constellation_16QAM_at_R = [-3+3i,-3+1i,-1+3i,-1+1i,-3-1i,-3-3i,-1-1i,-1-3i,1+3i,1+1i,3+3i,3+1i,1-1i,1-3i,3-1i,3-3i];
constellation_4QAM_at_R = [-2+2i,-2-2i,2+2i,2-2i];
constellation_real = [-3+3i,-3+1i,-1+3i,-1+1i,-3-1i,-3-3i,-1-1i,-1-3i,1+3i,1+1i,3+3i,3+1i,1-1i,1-3i,3-1i,3-3i];
constellation_ideal = [-3+3i,-3+1i,-1+3i,-1+1i,-3-1i,-3-3i,-1-1i,-1-3i,1+3i,1+1i,3+3i,3+1i,1-1i,1-3i,3-1i,3-3i];
for temp1 = 0:3
    for temp2 = 1:4
        constellation_real(temp1 * 4 + temp2) = constellation_fake(temp1 + 1) + constellation_real_quadrant(temp2);
        constellation_ideal(temp1 * 4 + temp2) = constellation_fake(temp1 + 1) + constellation_ideal_quadrant(temp2);
    end
end

symbol_to_angle_mapping_2_bits = [0,1,2,3] * 2 * pi / 4;

gray_ref_mat_4_bits = [ 0,4,12,8;    1,5,13,9;    3,7,15,11;    2,6,14,10;] + 1;
symbol_to_angle_mapping_4_bits = [0,1,15,14,2,3,4,5,9,8,6,7,11,10,13,12] * 2 * pi / 16; % histroical reason....

symbol_to_angle_mapping_6_bits = [0,5,3,4,12,11,21,6,2,1,63,60,8,31,26,61,43,44,22,49,37,42,25,46,38,47,58,50,36,35,28,51,15,14,18,9,13,16,20,7,30,62,59,55,10,29,23,57,41,17,19,48,34,40,24,45,32,54,56,53,39,33,27,52] * 2 * pi / 64;

%%%%%%%%% above are environment

% prepare these variables
D = 2;
eta = 3;
var_h = D .^ (-eta);
h_AR = sqrt(var_h/2) * (randn(1,num_symbols) + i * randn(1,num_symbols));
h_BR = sqrt(var_h/2) * (randn(1,num_symbols) + i * randn(1,num_symbols));
E_h_modulus = sqrt(var_h / 2 .* pi / 2); % Rayleigh distribution
E_h_modulus_square =  2 * var_h; % 高斯分布的平方的�?????????????????

P_transmit = 1; % transmit power = 1
Eb_B = 8;
if with_scaling
    switch rotation_symbols
    case 1
        Eb_A = 10;
    case 2
        Eb_A = 9.7105;
    case 3
        Eb_A = 9.7420;
    end
else
    Eb_A = 10;
end

constellation_16QAM_at_R = constellation_16QAM_at_R * sqrt(P_transmit/Eb_A);
constellation_4QAM_at_R = constellation_4QAM_at_R * sqrt(P_transmit/Eb_B);
message_A = randi([0,3],1, num_symbols);
message_B = randi([0,3],1, num_symbols);
message_fake = randi([0,3],1, num_symbols);
message_joint = 4 * message_fake + message_A; 
% allocate space for these variables to speed up
signal_A_transmit = zeros(1,num_symbols);
signal_B_transmit = zeros(1,num_symbols);
message_B_at_A = zeros(1,num_symbols);
message_A_joint_at_B = zeros(1,num_symbols);
message_A_at_B = zeros(1,num_symbols);

message_16_4_A_at_R = zeros(1,num_symbols);
message_16_4_B_at_R = zeros(1,num_symbols);
message_4_4_A_at_R = zeros(1,num_symbols);
message_4_4_B_at_R = zeros(1,num_symbols);
message_16_4_fake_at_R = zeros(1,num_symbols);
message_4_A_at_R = zeros(1,num_symbols);
message_16_A_at_R = zeros(1,num_symbols);
message_16_fake_at_R = zeros(1,num_symbols);

BER_A_at_B = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
% jointly decode A and B at R
% 16_4 means 联合解码的两个星座图的点�??????? RA_A 表示R认为的A和真实的A比较
BER_16_4_RA_A = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_16_4_RB_B = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_16_4_Rfake_fake = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_16_4_Rfake_A = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_4_4_RA_A = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_4_4_RA_fake = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_4_4_RB_B = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_4_RA_A = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max)); 
BER_4_RA_fake = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_16_RA_A = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
BER_16_Rfake_fake = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));

for return_zero = return_zero_min:return_zero_step:return_zero_max
    SNR_idx = 0;
    % ! notice that this SNR is the average SNR of Relay
    for SNR_db = SNR_db_min:SNR_db_step:SNR_db_max
        return_zero,SNR_db % display
        SNR_idx = SNR_idx + 1;
        SNR = 10 ^ (SNR_db / 10);
        N_0R = P_transmit * (E_h_modulus_square) * 2 / SNR;
        N_0A = P_transmit * (E_h_modulus_square) / SNR;
        n_R = sqrt(N_0R / 2) * (randn(1,num_symbols) + i * randn(1,num_symbols));
        n_A = sqrt(N_0A / 2) * (randn(1,num_symbols) + i * randn(1,num_symbols));
        n_B = sqrt(N_0A / 2) * (randn(1,num_symbols) + i * randn(1,num_symbols));
        x_real = 0;
        x_ideal = 0;
        theta_real = 0;
        theta_ideal = 0;
            % todo 这里该用平均功率还是瞬时功率呢？
            % http://ita.ucsd.edu/wiki/index.php?title=Amplify_and_forward
            % P_receive = abs(signal_A_at_R) ^ 2 + abs(signal_B_at_R) ^ 2 + abs(n_R(idx)) ^ 2; % instantaneous power
        P_receive = E_h_modulus_square * P_transmit * 2 + N_0R; % average power
        alpha_factor = sqrt(P_transmit / P_receive);

        for idx = 1:num_symbols
            % before first phase, Alice and Bob both rotate it's constellation.      
            % theta = f(x) 
            x_real = 0;
            x_ideal = 0;
            for temp = rotation_symbols:-1:1
                if idx > temp
                    x_real = 4 * x_real + message_B_at_A(idx - temp);
                    x_ideal = 4 * x_ideal + message_B(idx - temp);
                else
                    x_real = 0;
                    x_ideal = 0;
                end
            end
            if return_zero ~= 0 && mod(idx,return_zero) == 0
                theta_ideal = 0;
                theta_real = 0;
            end
            switch rotation_symbols
            case 1
                theta_real = theta_real + symbol_to_angle_mapping_2_bits(x_real + 1);
                theta_ideal = theta_ideal + symbol_to_angle_mapping_2_bits(x_ideal + 1);
            case 2
                theta_real = theta_real + symbol_to_angle_mapping_4_bits(gray_ref_mat_4_bits(x_real + 1));
                theta_ideal = theta_ideal + symbol_to_angle_mapping_4_bits(gray_ref_mat_4_bits(x_ideal + 1));
            case 3
                theta_real = theta_real + symbol_to_angle_mapping_6_bits(x_real + 1);
                theta_ideal = theta_ideal + symbol_to_angle_mapping_6_bits(x_ideal + 1);
            end
            theta_real = mod(theta_real, 2 * pi);
            theta_ideal = mod(theta_ideal, 2 * pi);
            if with_scaling
                r_real = scaling_r(theta_real);
                r_ideal = scaling_r(theta_ideal);
            else
                r_real = 1;
                r_ideal = 1;
            end
            constellation_real_quadrant = r_real * constellation_quadrant_0 * exp(i * theta_ideal);
            constellation_ideal_quadrant = r_ideal * constellation_quadrant_0 * exp(i * theta_real);
            for temp1 = 0:3
                for temp2 = 1:4
                    constellation_real(temp1 * 4 + temp2) = constellation_fake(temp1 + 1) + constellation_real_quadrant(temp2);
                    constellation_ideal(temp1 * 4 + temp2) = constellation_fake(temp1 + 1) + constellation_ideal_quadrant(temp2);
                end
            end
            % scatter(real(constellation_real),imag(constellation_real));
            % pause(0.001)
            constellation_real = constellation_real * sqrt(P_transmit/Eb_A);
            constellation_B = constellation_B_0 * sqrt(P_transmit/Eb_B);

            % first phase , A->R & B->R
            signal_A_transmit(idx) = message_to_signal(message_joint(idx),constellation_real);
            signal_B_transmit(idx) = message_to_signal(message_B(idx),constellation_B);
                % normalize transmit power
            signal_A_at_R = h_AR(idx) * signal_A_transmit(idx);
            signal_B_at_R = h_BR(idx) * signal_B_transmit(idx);
            y_R = signal_A_at_R + signal_B_at_R + n_R(idx);

            % second phase, (R->A & R->B)
                % self message has been cancelled out
            y_A = alpha_factor * h_AR(idx) * signal_B_at_R + alpha_factor * h_AR(idx) * n_R(idx) + n_B(idx);
            y_B = alpha_factor * h_BR(idx) * signal_A_at_R + alpha_factor * h_BR(idx) * n_R(idx) + n_A(idx);

            % after second phase and before first phase. A/B/R all will try to demodulate the current message
                % A demodulate B's message
            message_B_at_A(idx) = signal_to_message(y_A,constellation_B * alpha_factor * h_BR(idx) * h_AR(idx));
                % B demodulate A's message
            message_A_joint_at_B(idx) = signal_to_message(y_B, constellation_real * alpha_factor * h_BR(idx) * h_AR(idx));
            message_A_at_B(idx) = mod(message_A_joint_at_B(idx),4);
                % R jointly decode A's and B's message
            [message_16_4_A_at_R(idx),message_16_4_B_at_R(idx)] = jointly_decode(y_R,constellation_16QAM_at_R * h_AR(idx),constellation_4QAM_at_R * h_BR(idx));
            [message_4_4_A_at_R(idx),message_4_4_B_at_R(idx)] = jointly_decode(y_R,constellation_4QAM_at_R * h_AR(idx),constellation_4QAM_at_R * h_BR(idx));
            message_16_4_fake_at_R(idx) = bitand( message_16_4_A_at_R(idx),12) / 4;
            message_16_4_A_at_R(idx) = bitand(message_16_4_A_at_R(idx),3);
                % R regard B's as noise and only decode A's message
            message_4_A_at_R(idx) = signal_to_message(y_R,constellation_16QAM_at_R * h_AR(idx));
            message_16_A_at_R(idx) = signal_to_message(y_R,constellation_16QAM_at_R * h_AR(idx));
            message_16_fake_at_R(idx) = bitand(message_16_A_at_R(idx),12) / 4;
            message_16_A_at_R(idx) = bitand(message_16_A_at_R(idx),3);
        end
        [A,BER_16_4_RA_A(SNR_idx)] = biterr(message_16_4_A_at_R,message_A);
        [A,BER_16_4_Rfake_fake(SNR_idx)] = biterr(message_16_4_fake_at_R,message_fake);
        [A,BER_16_4_Rfake_A(SNR_idx)] = biterr(message_16_4_fake_at_R,message_A);
        [A,BER_16_4_RB_B(SNR_idx)] = biterr(message_16_4_B_at_R,message_B);
        [A,BER_4_4_RA_A(SNR_idx)] = biterr(message_4_4_A_at_R,message_A);
        [A,BER_4_4_RA_fake(SNR_idx)] = biterr(message_4_4_A_at_R,message_fake);
        [A,BER_4_4_RB_B(SNR_idx)] = biterr(message_4_4_B_at_R,message_B);
        [A,BER_4_RA_A(SNR_idx)] = biterr(message_A,message_4_A_at_R);
        [A,BER_4_RA_fake(SNR_idx)] = biterr(message_fake,message_4_A_at_R);
        [A,BER_16_RA_A(SNR_idx)] = biterr(message_A,message_16_A_at_R);
        [A,BER_16_Rfake_fake(SNR_idx)] = biterr(message_fake,message_16_fake_at_R);
        [A,BER_A_at_B(SNR_idx)] = biterr(message_A,message_A_at_B);

    end
    SNR_array = SNR_db_min:SNR_db_step:SNR_db_max;
    if with_scaling
        dir_path = ['.\result\RZ_',num2str(return_zero),'_RS_',num2str(rotation_symbols)];
    else
        dir_path = ['.\result\RZ_',num2str(return_zero),'_RS_',num2str(rotation_symbols),'_WOS'];
    end
    if ~exist(dir_path,'dir')
        mkdir(dir_path);
    end
    figure();
    semilogy(SNR_array,BER_16_4_RA_A);
    grid
    title('BER-16-4-RA-A');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_16_4_RA_A'],'bmp');
    csvwrite([dir_path,'\BER_16_4_RA_A.csv'],BER_16_4_RA_A);

    semilogy(SNR_array,BER_16_4_Rfake_fake);
    grid
    title('BER-16-4-Rfake-fake');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_16_4_Rfake_fake'],'bmp');
    csvwrite([dir_path,'\BER_16_4_Rfake_fake.csv'],BER_16_4_Rfake_fake);

    semilogy(SNR_array,BER_16_4_Rfake_A);
    grid
    title('BER-16-4-Rfake-A');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_16_4_Rfake_A'],'bmp');
    csvwrite([dir_path,'\BER_16_4_Rfake_A.csv'],BER_16_4_Rfake_A);

    semilogy(SNR_array,BER_16_4_RB_B);
    grid
    title('BER-16-4-RB-B');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_16_4_RB_B'],'bmp');
    csvwrite([dir_path,'\BER_16_4_RB_B.csv'],BER_16_4_RB_B);

    semilogy(SNR_array,BER_4_4_RA_A);
    grid
    title('BER-4-4-RA-A');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_4_4_RA_A'],'bmp');
    csvwrite([dir_path,'\BER_4_4_RA_A.csv'],BER_4_4_RA_A);

    semilogy(SNR_array,BER_4_4_RA_fake);
    grid
    title('BER-4-4-RA-fake');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_4_4_RA_fake'],'bmp');
    csvwrite([dir_path,'\BER_4_4_RA_fake.csv'],BER_4_4_RA_fake);

    semilogy(SNR_array,BER_4_4_RB_B);
    grid
    title('BER-4-4-RB-B');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_4_4_RB_B'],'bmp');
    csvwrite([dir_path,'\BER_4_4_RB_B.csv'],BER_4_4_RB_B);

    semilogy(SNR_array,BER_4_RA_A);
    grid
    title('BER-4-RA-A');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_4_RA_A'],'bmp');
    csvwrite([dir_path,'\BER_4_RA_A.csv'],BER_4_RA_A);

    semilogy(SNR_array,BER_4_RA_fake);
    grid
    title('BER-4-RA-fake');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_4_RA_fake'],'bmp');
    csvwrite([dir_path,'\BER_4_RA_fake.csv'],BER_4_RA_fake);
    semilogy(SNR_array,BER_4_RA_fake);

    grid
    title('BER-16-RA-A');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_16_RA_A'],'bmp');
    csvwrite([dir_path,'\BER_16_RA_A.csv'],BER_16_RA_A);
    semilogy(SNR_array,BER_16_RA_A);

    grid
    title('BER-16-Rfake-fake');
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_16_Rfake_fake'],'bmp');
    csvwrite([dir_path,'\BER_16_Rfake_fake.csv'],BER_16_Rfake_fake);


    semilogy(SNR_array,BER_A_at_B);
    grid
    title("BER-A-at-B");
    xlabel('Signal-to-Noise-Ratio(dB)');
    ylabel('BER')
    saveas(gcf,[dir_path,'\BER_A_at_B'],'bmp');
    csvwrite([dir_path,'\BER_A_at_B.csv'],BER_A_at_B);


end

function signal = message_to_signal(message,constellation)
    signal = constellation(message + 1);
end

function message = signal_to_message(signal,constellation)
    difference = constellation - signal;
    [temp,message] = min(abs(difference));
    message = message - 1;
end

function [message_A,message_B] = jointly_decode(signal,constellation_A,constellation_B)
    L_A = length(constellation_A);
    L_B = length(constellation_B);
    % Cartesian product
    [X,Y] = meshgrid(constellation_A,constellation_B);
    constellation_joint = X(:) + Y(:);
    difference = abs(constellation_joint - signal);
    [temp,message] = min(difference);
    message_A = ceil(message/L_B) - 1;
    message_B = mod(message - 1,L_B);
end