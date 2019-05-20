function codes = custom_demodulate(sig,constellation_value,constellation_position)
L = length(sig);
codes = zeros(1,L);
for idx = 1:L
    decision_var = abs(constellation_position(:,1) - real(sig(idx))).^2 + abs(constellation_position(:,2) - imag(sig(idx))).^2;
    [min_value,min_idx] = min(decision_var);
    codes(idx) = constellation_value(min_idx);
end
    
