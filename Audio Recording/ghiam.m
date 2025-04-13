clear;
% Thiết lập thông số
fs = 44100;            % Tần số lấy mẫu 44.1 kHz
bits = 16;             % Độ phân giải 16-bit
channels = 2;          % Ghi âm STEREO
duration = 285;        % Ghi âm trong 285 giây = 4ph45'

% Tạo đối tượng ghi âm
rec = audiorecorder(fs, bits, channels);

% Bắt đầu ghi âm
disp('Bắt đầu ghi âm (STEREO). Bạn có 5 phút...');
recordblocking(rec, duration);

% Dừng ghi âm
disp('Đã dừng ghi âm.');

% Lấy dữ liệu âm thanh
data = getaudiodata(rec);

% (Tùy chọn) Lưu thành file WAV
audiowrite('ghi_am_5_phut_stereo2.wav', data, fs);

% (Tùy chọn) Hiển thị waveform từng kênh
plot(data);
title('Biểu đồ sóng âm (STEREO)');
xlabel('Samples');
ylabel('Biên độ');
legend('Kênh trái', 'Kênh phải');
