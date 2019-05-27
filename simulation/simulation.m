clc,clear

SNR_db_max = 30;
SNR_db_min = 0;
SNR_db_step = 3;
SNR = 10^(SNR_db_min/10);
num_symbols = 1e6;
bits_per_symbol = 2; % modulation-relative. 2 means 4QAM

rotation_cycle_min = 1;
rotation_cycle_max = 1;
rotation_cycle_step = 1;

return_zero_min = 0;% return zero after return_zero symbols, 0 for not return.
return_zero_max = 9;
return_zero_step = 1;
rotation_symbols = [1];
with_scaling = 0;

for return_zero = return_zero_min:return_zero_step:return_zero_max
    for rotation_cycle = rotation_cycle_min:rotation_cycle_step:rotation_cycle_max
%         dir_path = ['pics\return_zero_',num2str(return_zero),'\rotation_cycle_',num2str(rotation_cycle)];
        if with_scaling == 1
             dir_path = ['pics\return_zero_',num2str(return_zero),'\rotation_bits_',num2str(rotation_symbols)];
        else
             dir_path = ['pics\return_zero_',num2str(return_zero),'\rotation_bits_',num2str(rotation_symbols),'_without_scaling'];
        end
       
        if ~exist(dir_path,'dir')
            mkdir(dir_path);
        end

        % rotation_symbols = randi([1,3],1,rotation_cycle);% how many symbols jointly decide the roration angle, chosen from 1 to 3
%         rotation_symbols = [2];
        rotation_bits = rotation_symbols * bits_per_symbol;

        % define messages 
        message_A = randi([0,3],1, num_symbols);
        message_B = randi([0,3],1, num_symbols);
        message_fake = randi([0,3],1, num_symbols);
        message_joint = 4 * message_fake + message_A; 

        constellation_B_value = [0;1;2;3]; % constellation that B transmit. It's fixed and won't rotate.
        constellation_B_position = [-2,2; -2,-2; 2,2; 2,-2]; 
        constellation_fake_value = [0;1;2;3]; % suppose Relay use this to demodulate A's message. this is fixed and used to construst A's real constellation
        constellation_fake_position = [-2,2; -2,-2; 2,2; 2,-2]; % focus (center) of the position 

        constellation_real_value = zeros(16,1); % this matrix is fixed and corresponding to real position. it's just 0:15
        temp = [0;1;2;3];
        for temp1 = 0:3
            for temp2 = 1:4
                constellation_real_value(temp1 * 4 + temp2) = bin2dec([dec2bin(temp(temp1 + 1),2),dec2bin(temp(temp2),2)]);
            end
        end
        constellation_ideal_value = constellation_real_value; % actually it's just 0:15
        constellation_ideal_quadrant_position_0 = [-1,1; -1,-1; 1,1; 1,-1]; % ideal constellation, i.e. B demodulate using this
        constellation_ideal_quadrant_position = [-1,1; -1,-1; 1,1; 1,-1]; % ideal constellation, i.e. B demodulate using this
        constellation_real_quadrant_position_0 =  [-1,1; -1,-1; 1,1; 1,-1]; % real constellation, i.e. A modulate and transmit using this.
        constellation_real_quadrant_position =  [-1,1; -1,-1; 1,1; 1,-1]; % real constellation, i.e. A modulate and transmit using this.
        constellation_real_position = zeros(16,2);% real constellation, i.e. A modulate using this, this will rotate.
%         constellation_ideal_position = zeros(16,2);
        for temp1 = 0:3
            for temp2 = 1:4
                constellation_real_position(temp1 * 4 + temp2,:) = constellation_fake_position(temp1 + 1,:) + constellation_real_quadrant_position(temp2,:);
            end
        end
        constellation_ideal_position = constellation_real_position;

        gray_ref_mat_4_bits = [ 0,4,12,8;    1,5,13,9;    3,7,15,11;    2,6,14,10;];
        symbol_to_angle_mapping_4_bits = [0,1,15,14,2,3,4,5,9,8,6,7,11,10,13,12]; % histroical reason....
        symbol_to_angle_mapping_4_bits = symbol_to_angle_mapping_4_bits * 2 * pi / 16;

        symbol_to_angle_mapping_2_bits = [0,1,2,3] * 2 * pi / 4;

        symbol_to_angle_mapping_6_bits = [0,5,3,4,12,11,21,6,2,1,63,60,8,31,26,61,43,44,22,49,37,42,25,46,38,47,58,50,36,35,28,51,15,14,18,9,13,16,20,7,30,62,59,55,10,29,23,57,41,17,19,48,34,40,24,45,32,54,56,53,39,33,27,52] * 2 * pi / 64;

        % just modulation , awgn and demodulation!
        SER = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
        BER = zeros(1,length(SNR_db_min:SNR_db_step:SNR_db_max));
%         constellation_position_to_draw = constellation_ideal_position;
        SNR_idx = 0;
        for SNR_db = SNR_db_min:SNR_db_step:SNR_db_max
            SNR_idx = SNR_idx + 1;
            SNR = 10^(SNR_db/10);

            % B->A . 
            % bit-to-symbol-map. notice that the constellation is fixed.
            sig_B = symbol_mapping(message_B,constellation_B_value,constellation_B_position);
            % awgn
            sig_B = awgn(sig_B,SNR_db,4);
            % demodulate at A 
            message_B_demod = custom_demodulate(sig_B,constellation_B_value,constellation_B_position);

            % A->B.
            % here we have to get signal symbol by symbol.
            sig_A = zeros(1,num_symbols);
            sig_joint = zeros(1,num_symbols);
            message_joint_demod = zeros(1,num_symbols);
            message_A_demod = zeros(1,num_symbols);
            theta_real = 0;
            theta_ideal = 0;
            for idx = 1:num_symbols
                if return_zero ~= 0
                    if mod(idx,return_zero * rotation_cycle) == 0
                        theta_real = 0;
                        theta_ideal = 0;
                    end
                end
                
                % firstly , map the received message x to rotation angle theta. use the theta to calculate constellation.
                x_real = 0; % theta = f(x_real); x_real is got from message_B_demod
                x_ideal = 0;
                rotation_symbols_of_this_idx = rotation_symbols(mod(idx,rotation_cycle)+ 1);
                for temp = rotation_symbols_of_this_idx:-1:1
                    if idx > temp
                        x_real = 4 * x_real + message_B_demod(idx - temp);
                        x_ideal = 4 * x_ideal + message_B(idx - temp);
                    else
                        x_real = 0;
                        x_ideal = 0;
                    end
                end
                if rotation_symbols_of_this_idx == 3
                    theta_real = theta_real + symbol_to_angle_mapping_6_bits(x_real + 1);
                    theta_ideal = theta_ideal + symbol_to_angle_mapping_6_bits(x_ideal + 1);
                else
                    if rotation_symbols_of_this_idx  == 2
                        theta_real = theta_real + symbol_to_angle_mapping_4_bits(x_real + 1);
                        theta_ideal = theta_ideal + symbol_to_angle_mapping_4_bits(x_ideal + 1);
                    else
                        if rotation_symbols_of_this_idx == 1
                            theta_real = theta_real + symbol_to_angle_mapping_2_bits(gray_ref_mat_4_bits(x_real + 1) + 1);
                            theta_ideal = theta_ideal + symbol_to_angle_mapping_2_bits(gray_ref_mat_4_bits(x_ideal + 1) + 1);
                        end
                    end
                end
                theta_real = mod(theta_real, 2 * pi);
                theta_ideal = mod(theta_ideal, 2 * pi);
                if with_scaling == 1
                    r_real = scaling_r(theta_real);
                    r_ideal = scaling_r(theta_ideal);
                else
                    r_real = 1;
                    r_ideal = 1;                    
                end
 
                rotation_matrix_real = [cos(theta_real),-sin(theta_real);sin(theta_real),cos(theta_real)];
                rotation_matrix_ideal = [cos(theta_ideal),-sin(theta_ideal);sin(theta_ideal),cos(theta_ideal)];
                % get the constellation 
                constellation_real_quadrant_position = r_real * constellation_real_quadrant_position_0 * rotation_matrix_real;
                constellation_ideal_quadrant_position = r_ideal * constellation_ideal_quadrant_position_0 * rotation_matrix_ideal;
                for temp1 = 0:3
                    for temp2 = 1:4
                        constellation_real_position(temp1 * 4 + temp2,:) = constellation_fake_position(temp1 + 1,:) + constellation_real_quadrant_position(temp2,:);
                    end
                end
                for temp1 = 0:3
                    for temp2 = 1:4
                        constellation_ideal_position(temp1 * 4 + temp2,:) = constellation_fake_position(temp1 + 1,:) + constellation_ideal_quadrant_position(temp2,:);
                    end
                end
                
                % given the constellation, we can do bit-to-symbol-map -> awgn -> demodulate and decide
                sig_joint(idx) = symbol_mapping(message_joint(idx),constellation_real_value,constellation_real_position);
                % awgn
                sig_joint(idx) = awgn(sig_joint(idx),SNR_db,10);  %todo
                % demodulate
                message_joint_demod(idx) = custom_demodulate(sig_joint(idx),constellation_ideal_value,constellation_ideal_position);
                message_A_demod(idx) = bitand(message_joint_demod(idx), 2^bits_per_symbol - 1);
            end % idx_num_symbol 
            [errorBit,BER(SNR_idx)] = biterr(message_A, message_A_demod, bits_per_symbol);
            [errorSym,SER(SNR_idx)] = symerr(message_A, message_A_demod);          
            scatter(real(sig_joint),imag(sig_joint));
            title(['received constellation at SNR=',num2str(SNR_db)]);
            % saveas(gcf,[dir_path,'\received_constellation_SNR_',num2str(SNR_db)],'fig');
            saveas(gcf,[dir_path,'\received_constellation_SNR_',num2str(SNR_db)],'bmp');
            % scatter(constellation_ideal_position(:,1),constellation_ideal_position(:,2));
            % title(['ideal constellation at SNR=',num2str(SNR_db)]);
        end % SNR
        semilogy(SNR_db_min:SNR_db_step:SNR_db_max,SER,'-go',SNR_db_min:SNR_db_step:SNR_db_max,BER,'-b*');
        grid;
        legend('SER','BER');
        title('Performance of B as a receiver in AWGN');
        xlabel('Signal-to-Noise-Ratio(dB)');
        ylabel('SER and BER')
        saveas(gcf,[dir_path,'\performance'],'fig');
        saveas(gcf,[dir_path,'\performance'],'bmp');
        csvwrite([dir_path,'\rotation_symbols.csv'],rotation_symbols);
        csvwrite([dir_path,'\SER.csv'],SER);
        csvwrite([dir_path,'\BER.csv'],BER);
    end % rotation_cycle
end % return_zero
