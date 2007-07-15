filter_input
coeffs
out = conv(in,coeffs);
dlmwrite('expected_response.out',out,'\n');
