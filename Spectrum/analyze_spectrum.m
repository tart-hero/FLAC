clc; clear; close all;

%% 1. Đọc dữ liệu từ file âm thanh
filename = 'ghi_am_5_phut_stereo2.wav'; % chỉnh lại đường dẫn nếu cần
[data, fs] = audioread(filename); %data:[Nx2]
left = data(:,1); % kênh trái
right = data(:,2); % kênh phải

%% 2. Vẽ tín hiệu trong miền thời gian
t = (0:length(data)-1) / fs;
figure;
subplot(2,1,1);
plot(t, left);
title('Input Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,1);
plot(t, right);
title('Input Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

%% 3. Biến đổi Fourier (FFT)
NFFT = 2^nextpow2(length(left));
f = fs/2 * linspace(0, 1, NFFT/2 + 1);  % trục tần số (Hz)

X_fft_left = fft(left, NFFT);
X_mag_left = abs(X_fft_left(1:NFFT/2 + 1));

X_fft_right = fft(right, NFFT);
X_mag_right = abs(X_fft_right(1:NFFT/2 + 1));

figure;
subplot(2,1,1);
plot(f, X_mag_left);
title('FFT Spectrum - Left Channel');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(2,1,2);
plot(f, X_mag_right);
title('FFT Spectrum - Right Channel');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

%% 4. Welch Power Spectral Density Estimate
win_len = 256;                  % độ dài cửa sổ
overlap = win_len / 2;          % chồng lấn 50%
nfft = 512;                     % số điểm FFT
step = win_len - overlap;       
n = (0:win_len-1)';
win = 0.54 - 0.46 * cos(2 * pi * n / (win_len - 1));
         
% Hàm tính Welch PSD
welch_psd = @(x) ...
    mean(arrayfun(@(k) ...
        abs(fft(x((1:win_len)+(k-1)*step) .* win, nfft)).^2 / ...
        (sum(win.^2) * fs), ...
        1:floor((length(x) - overlap)/step), 'UniformOutput', false), 2);

% Kênh trái
pxx_welch_left = zeros(nfft,1);
count = 0;
for k = 1:floor((length(left) - overlap)/step)
    idx = (1:win_len) + (k-1)*step;
    if idx(end) > length(left), break; end
    segment = left(idx) .* win;
    X = fft(segment, nfft);
    P = abs(X).^2 / (sum(win.^2) * fs);
    pxx_welch_left = pxx_welch_left + P;
    count = count + 1;
end
pxx_welch_left = pxx_welch_left / count;

% Kênh phải
pxx_welch_right = zeros(nfft,1);
count = 0;
for k = 1:floor((length(right) - overlap)/step)
    idx = (1:win_len) + (k-1)*step;
    if idx(end) > length(right), break; end
    segment = right(idx) .* win;
    X = fft(segment, nfft);
    P = abs(X).^2 / (sum(win.^2) * fs);
    pxx_welch_right = pxx_welch_right + P;
    count = count + 1;
end
pxx_welch_right = pxx_welch_right / count;

% Cắt phổ đơn biên
n_half = floor(nfft/2) + 1;
f_welch = (0:nfft-1)*(fs/nfft);
f_welch = f_welch(1:n_half);

pxx_welch_left = pxx_welch_left(1:n_half);
pxx_welch_right = pxx_welch_right(1:n_half);

% Vẽ PSD Welch
figure;
subplot(2,1,1);
plot(f_welch/1000, 10*log10(pxx_welch_left));
title('Welch PSD - Left Channel');
xlabel('Frequency (kHz)');
ylabel('Power/Frequency (dB/Hz)');

subplot(2,1,2);
plot(f_welch/1000, 10*log10(pxx_welch_right));
title('Welch PSD - Right Channel');
xlabel('Frequency (kHz)');
ylabel('Power/Frequency (dB/Hz)');

%% 5. Periodogram PSD Estimate (cả 2 kênh)
nfft = length(left);
win = ones(nfft,1); % cửa sổ chữ nhật

% Trái
X_left = fft(left .* win, nfft);
pxx_left = abs(X_left).^2 / (sum(win.^2) * fs);
f_pxx = (0:nfft-1)*(fs/nfft);
pxx_left = pxx_left(1:nfft/2+1);
f_pxx = f_pxx(1:nfft/2+1);

% Phải
X_right = fft(right .* win, nfft);
pxx_right = abs(X_right).^2 / (sum(win.^2) * fs);
pxx_right = pxx_right(1:nfft/2+1);

% Vẽ đồ thị
figure;
subplot(2,1,1);
plot(f_pxx/1000, 10*log10(pxx_left));
title('Periodogram PSD - Left Channel');
xlabel('Frequency (kHz)');
ylabel('Power/Frequency (dB/Hz)');

subplot(2,1,2);
plot(f_pxx/1000, 10*log10(pxx_right));
title('Periodogram PSD - Right Channel');
xlabel('Frequency (kHz)');
ylabel('Power/Frequency (dB/Hz)');