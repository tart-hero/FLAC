function flac_degree2_simple(filename)
    % ==== 1. Đọc file WAV và chuẩn hóa về int16 ====
    [x, Fs] = audioread(filename);
    x = int16(x * 32768);  % chuẩn hóa [-1,1] -> [-32768, 32767]
    [N, C] = size(x);      % N: số mẫu, C: số kênh

    fprintf('Đang xử lý file: %s\n', filename);
    fprintf('Tần số lấy mẫu: %d Hz\n', Fs);
    fprintf('Số kênh: %d\n\n', C);

    % ==== 2. Mã hóa bằng dự đoán bậc 2 ====
    if C == 1
        disp('File là MONO. Đang mã hóa...');
        x = x(:);  % đảm bảo là vector cột
        residual = linear_predict_order2(x);
        save('encoded_mono_degree2.mat', 'residual', 'Fs');

        % ==== 3. Giải mã lại ====
        x_rec = decode_flac_order2(residual);
        x_rec = double(x_rec) / 32768;  % chuyển lại dạng float

        % ==== 4. Ghi ra file FLAC ====
        audiowrite('output_mono_degree2_simple.flac', x_rec, Fs);
        disp(' Đã lưu output_mono_degree2_simple.flac');

    elseif C == 2
        disp('File là STEREO. Đang mã hóa từng kênh...');
        left  = x(:,1);
        right = x(:,2);

        residual_L = linear_predict_order2(left);
        residual_R = linear_predict_order2(right);

        save('encoded_stereo_degree2.mat', 'residual_L', 'residual_R', 'Fs');

        % ==== 3. Giải mã lại ====
        xL = decode_flac_order2(residual_L);
        xR = decode_flac_order2(residual_R);

        x_stereo = double([xL, xR]) / 32768;

        % ==== 4. Ghi ra file FLAC ====
        audiowrite('output_stereo_degree2_simple.flac', x_stereo, Fs);
        disp(' Đã lưu output_stereo_degree2_simple.flac');

    else
        error('File WAV có nhiều hơn 2 kênh – không hỗ trợ.');
    end
end

% ==== Hàm mã hóa FLAC bậc 2 ====
function residual = linear_predict_order2(x)
    N = length(x);
    residual = zeros(N, 1, 'int16');
    residual(1) = x(1);                     % giữ nguyên mẫu đầu tiên
    if N >= 2
        residual(2) = x(2) - x(1);          % dự đoán bậc 1 cho mẫu thứ 2
    end
    for n = 3:N
        pred = int16(2*x(n-1) - x(n-2));    % dự đoán: x[n] ≈ 2*x[n-1] - x[n-2]
        residual(n) = x(n) - pred;          % phần dư
    end
end

% ==== Hàm giải mã FLAC bậc 2 ====
function x_rec = decode_flac_order2(residual)
    N = length(residual);
    x_rec = zeros(N, 1, 'int16');
    x_rec(1) = residual(1);                 % mẫu đầu tiên
    if N >= 2
        x_rec(2) = x_rec(1) + residual(2);  % mẫu thứ 2 = x[1] + residual[2]
    end
    for n = 3:N
        pred = int16(2*x_rec(n-1) - x_rec(n-2));  % dự đoán ngược
        x_rec(n) = pred + residual(n);            % khôi phục lại tín hiệu
    end
end
