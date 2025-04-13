function flac_degree3(filename)
    % ==== 1. Read WAV file and normalize to int16 ====
    [x, Fs] = audioread(filename);  % Read audio data and sampling rate
    x = int16(x * 32768);           % Convert float [-1, 1] to 16-bit PCM values
    [N, C] = size(x);               % Get number of samples (N) and channels (C)

    fprintf('Processing file: %s\n', filename);
    fprintf('Sample rate: %d Hz\n', Fs);
    fprintf('Number of channels: %d\n\n', C);

    if C == 1
        % ==== MONO processing ====
        disp('MONO file. Encoding...');
        x = x(:);  % Ensure column vector
        residual = linear_predict_order3(x);         % Apply 3rd-order predictor to get residual
        u = signed_to_unsigned(residual);            % Convert signed residual to unsigned using zigzag
        [k, rice_bits] = rice_encode_short(u);       % Find best Rice k and encode entire sequence
        fprintf('Optimal k: %d\n\n', k);

        save('encoded_mono.mat', 'rice_bits', 'k', 'Fs');  % Save encoded MONO data

        % === Decoding ===
        u_rec = rice_decode(rice_bits, k);           % Decode Rice bits into unsigned values
        residual_rec = unsigned_to_signed(u_rec);    % Convert back to signed residuals
        x_rec = decode_flac_order3(residual_rec);    % Reconstruct original audio signal
        x_rec = double(x_rec) / 32768;               % Normalize to [-1, 1] float range
        audiowrite('output_mono.flac', x_rec, Fs);   % Write decoded audio to file
        disp('Saved output_mono.flac');

    elseif C == 2
        % ==== STEREO processing ====
        disp('STEREO file. Encoding each channel...');
        L = x(:,1); R = x(:,2);                        % Separate left and right channels
        res_L = linear_predict_order3(L);              % Residual for left channel
        disp('Left residual computed');
        res_R = linear_predict_order3(R);              % Residual for right channel
        disp('Right residual computed');
        uL = signed_to_unsigned(res_L);               % Convert left residual to unsigned
        disp('Left sign conversion done');
        uR = signed_to_unsigned(res_R);               % Convert right residual to unsigned
        disp('Right sign conversion done');

        [kL, bitsL] = rice_encode_short(uL);           % Rice encode left channel
        disp('Left Rice coding done');
        [kR, bitsR] = rice_encode_short(uR);           % Rice encode right channel
        disp('Right Rice coding done');

        save('encoded_stereo.mat', 'bitsL', 'bitsR', 'kL', 'kR', 'Fs');  % Save encoded stereo data

        % === Decoding ===
        uL_rec = rice_decode(bitsL, kL);              % Decode left channel Rice code
        disp('Decoded left channel');
        uR_rec = rice_decode(bitsR, kR);              % Decode right channel Rice code
        disp('Decoded right channel');
        resL_rec = unsigned_to_signed(uL_rec);        % Convert back to signed residuals
        disp('Left sign restored');
        resR_rec = unsigned_to_signed(uR_rec);        % Convert back to signed residuals
        disp('Right sign restored');

        xL = decode_flac_order3(resL_rec);            % Reconstruct left channel
        xR = decode_flac_order3(resR_rec);            % Reconstruct right channel
        disp('FLAC decoding done');

        x_stereo = double([xL, xR]) / 32768;          % Normalize reconstructed stereo signal
        audiowrite('output_stereo_degree3.flac', x_stereo, Fs);  % Save reconstructed stereo audio
        disp('Saved output_stereo_degree3.flac');
    else
        error('Unsupported number of channels');
    end
end

function residual = linear_predict_order3(x)
    % Apply 3rd-order linear prediction: x[n] ≈ 3x[n-1] - 3x[n-2] + x[n-3]
    N = length(x);
    residual = zeros(N,1,'int16');
    residual(1:3) = x(1:3);  % Copy first 3 samples as-is (no prediction possible)
    for n = 4:N
        pred = int16(3*x(n-1) - 3*x(n-2) + x(n-3));  % Calculate prediction
        residual(n) = x(n) - pred;                  % Store prediction error
    end
end

function x_rec = decode_flac_order3(residual)
    % Reconstruct original signal from 3rd-order prediction residual
    N = length(residual);
    x_rec = zeros(N,1,'int16');
    x_rec(1:3) = residual(1:3);  % Restore first 3 samples
    for n = 4:N
        pred = int16(3*x_rec(n-1) - 3*x_rec(n-2) + x_rec(n-3));  % Predict
        x_rec(n) = pred + residual(n);  % Reconstruct original value
    end
end

function u = signed_to_unsigned(x)
    % Zigzag encoding: map signed integers to unsigned integers
    u = zeros(size(x), 'uint16');
    u(x >= 0) = 2 * uint16(x(x >= 0));         % Even values for non-negative
    u(x < 0) = 2 * uint16(-x(x < 0)) - 1;      % Odd values for negative
end

function x = unsigned_to_signed(u)
    % Inverse zigzag: map unsigned integers back to signed integers
    x = zeros(size(u), 'int16');
    odd = mod(u,2) == 1;                       % Identify odd values (originally negative)
    x(~odd) = int16(u(~odd)/2);                % Decode non-negative values
    x(odd)  = -int16((u(odd)+1)/2);            % Decode negative values
end

function [k_opt, bits] = rice_encode_short(u)
    % Estimate best Rice parameter k from first 10,000 samples, then encode all data
    u = uint16(u);
    sample_len = min(10000, length(u));
    u_sample = u(1:sample_len);

    min_bits = Inf;  % Initialize with very high bit count
    k_opt = 0;

    for k = 0:15
        bits_k = rice_encode(u_sample, k);     % Encode sample with current k
        if length(bits_k) < min_bits
            min_bits = length(bits_k);         % Update if fewer bits used
            k_opt = k;
        end
    end

    bits = rice_encode(u, k_opt);              % Encode all data with optimal k
end

function bits = rice_encode(u, k)
    % Rice encoding: represent u as unary quotient + fixed-length remainder
    m = 2^k;
    bit_cells = cell(length(u),1);

    for i = 1:length(u)
        val = u(i);
        q = floor(double(val)/m);        % Compute quotient
        r = mod(val, m);                % Compute remainder
        unary = [repmat('1',1,q) '0'];  % Unary encoding of quotient
        binary = dec2bin(r, k);         % Binary encoding of remainder
        bit_cells{i} = [unary binary];  % Combine unary and binary parts
    end

    bits = [bit_cells{:}];  % Concatenate all encoded strings
end

function u = rice_decode(bits, k)
    % Decode Rice-encoded bitstream to recover unsigned integers
    m = 2^k;
    u = [];
    i = 1; len = length(bits);
    while i <= len
        q = 0;
        while i <= len && bits(i) == '1'       % Count unary 1s (quotient)
            q = q + 1;
            i = i + 1;
        end
        i = i + 1;                             % Skip terminating 0
        if i + k - 1 > len, break; end         % Prevent overflow
        r = bin2dec(bits(i:i+k-1));            % Decode remainder
        i = i + k;
        u_val = q * m + r;                     % Reconstruct original value
        u = [u; uint16(u_val)];
    end
end
