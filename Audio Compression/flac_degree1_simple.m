function flac_degree1_simple(filename)
    % ==== 1. Đọc file WAV ====
    [x, Fs] = audioread(filename);
    [N, C] = size(x);  % N: số mẫu, C: số kênh

    fprintf('Đang xử lý file: %s\n', filename);
    fprintf('Tần số lấy mẫu: %d Hz\n', Fs);
    fprintf('Số kênh: %d\n\n', C);

    % ==== 2. Mã hóa FLAC dự đoán bậc 1 ====
    if C == 1
        disp('File là MONO. Đang mã hóa...');
        x = x(:);  % đảm bảo vector cột
        residual = linear_predict_order1(x);
        save('encoded_mono_degree1.mat', 'residual', 'Fs');

        % ==== 3. Giải mã lại ====
        x_rec = decode_flac_order1(residual);

        % ==== 4. Ghi ra file FLAC ====
        audiowrite('output_mono_degree1_simple.flac', x_rec, Fs);
        disp(' Đã lưu output_mono_degree1_simple.flac');
    
    elseif C == 2
        disp(' File là STEREO. Đang mã hóa từng kênh...');

        left  = x(:,1);
        right = x(:,2);

        residual_L = linear_predict_order1(left);
        residual_R = linear_predict_order1(right);

        save('encoded_stereo_degree1.mat', 'residual_L', 'residual_R', 'Fs');

        % ==== 3. Giải mã lại ====
        xL = decode_flac_order1(residual_L);
        xR = decode_flac_order1(residual_R);

        x_stereo = [xL, xR];  % ghép 2 kênh lại

        % ==== 4. Ghi ra file FLAC ====
        audiowrite('output_stereo_degree1_simple.flac', x_stereo, Fs);
        disp('Đã lưu output_stereo_degree1_simple.flac');

    else
        error('File WAV có nhiều hơn 2 kênh – không hỗ trợ.');
    end
end

% ==== Hàm mã hóa FLAC bậc 1 ====
function residual = linear_predict_order1(x)
    N = length(x);
    residual = zeros(N,1);
    residual(1) = x(1);
    for n = 2:N
        residual(n) = x(n) - x(n-1);
    end
end

% ==== Hàm giải mã FLAC bậc 1 ====
function x_rec = decode_flac_order1(residual)
    N = length(residual);
    x_rec = zeros(N,1);
    x_rec(1) = residual(1);
    for n = 2:N
        x_rec(n) = residual(n) + x_rec(n-1);
    end
end
