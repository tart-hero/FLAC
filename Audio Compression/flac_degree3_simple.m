function flac_degree3_simple(filename)
    % ==== 1. Đọc file WAV và chuẩn hóa về int16 ====
    [x, Fs] = audioread(filename);
    x = int16(x * 32768);  % chuẩn hóa [-1,1] -> [-32768, 32767]
    [N, C] = size(x);      % N: số mẫu, C: số kênh

    fprintf('Đang xử lý file: %s\n', filename);
    fprintf('Tần số lấy mẫu: %d Hz\n', Fs);
    fprintf('Số kênh: %d\n\n', C);

    % ==== 2. Mã hóa bằng dự đoán bậc 3 ====
    if C == 1
        disp('File là MONO. Đang mã hóa...');
        x = x(:);  % đảm bảo là vector cột
        residual = linear_predict_order3(x);
        save('encoded_mono_degree3.mat', 'residual', 'Fs');

        % ==== 3. Giải mã lại ====
        x_rec = decode_flac_order3(residual);
        x_rec = double(x_rec) / 32768;  % chuyển lại dạng float

        % ==== 4. Ghi ra file FLAC ====
        audiowrite('output_mono_degree3_simple.flac', x_rec, Fs);
        disp(' Đã lưu output_mono_degree3_simple.flac');

    elseif C == 2
        disp('File là STEREO. Đang mã hóa từng kênh...');
        left  = x(:,1);
        right = x(:,2);

        residual_L = linear_predict_order3(left);
        residual_R = linear_predict_order3(right);

        save('encoded_stereo_degree3.mat', 'residual_L', 'residual_R', 'Fs');

        % ==== 3. Giải mã lại ====
        xL = decode_flac_order3(residual_L);
        xR = decode_flac_order3(residual_R);

        x_stereo = double([xL, xR]) / 32768;

        % ==== 4. Ghi ra file FLAC ====
        audiowrite('output_stereo_degree3_simple.flac', x_stereo, Fs);
        disp(' Đã lưu output_stereo_degree3_simple.flac');

    else
        error('File WAV có nhiều hơn 2 kênh – không hỗ trợ.');
    end
end

% ==== Hàm mã hóa FLAC bậc 3 ====
function residual = linear_predict_order3(x)
    N = length(x);
    residual = zeros(N,1, 'int16');
    residual(1:3) = x(1:3);  % Giữ nguyên 3 mẫu đầu
    for n = 4:N
        % Công thức dự đoán bậc 3:
        pred = int16(3*x(n-1) - 3*x(n-2) + x(n-3));
        residual(n) = x(n) - pred;
    end
end

% ==== Hàm giải mã FLAC bậc 3 ====
function x_rec = decode_flac_order3(residual)
    N = length(residual);
    x_rec = zeros(N,1, 'int16');
    x_rec(1:3) = residual(1:3);  % Khôi phục 3 mẫu đầu

    for n = 4:N
        pred = int16(3*x_rec(n-1) - 3*x_rec(n-2) + x_rec(n-3));
        x_rec(n) = pred + residual(n);
    end
end
