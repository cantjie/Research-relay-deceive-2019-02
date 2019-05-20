function sig = symbol_mapping(codes,constellation_value,constellation_position)

L = length(codes);
sig = zeros(1,L);
for idx = 1:L
   temp = find(constellation_value == codes(idx));
   sig(idx) = constellation_position(temp,1) + i * constellation_position(temp,2);
end