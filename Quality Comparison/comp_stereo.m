% ================= PHÂN TÍCH PSNR & PHỔ ===================

% Đọc 3 file âm thanh (giữ nguyên stereo)
[x_wav, fs1] = audioread("ghi_am_5_phut_stereo2.wav");
[x_mp3, fs2] = audioread("ghi_am_5_phut_stereo2.mp3");
[x_flac, fs3] = audioread("output_stereo_degree3.flac");

% Kiểm tra sample rate
if fs1 ~= fs2 || fs1 ~= fs3
    error("Sample rates không đồng nhất!");
end

% Đồng bộ độ dài giữa 3 file
minLen = min([size(x_wav,1), size(x_mp3,1), size(x_flac,1)]);
x_wav  = x_wav(1:minLen, :);
x_mp3  = x_mp3(1:minLen, :);
x_flac = x_flac(1:minLen, :);

% ====== HÀM PSNR THEO KÊNH (LEFT / RIGHT) ======
psnr_channel = @(a, b) 10 * log10(1^2 / mean((a - b).^2));  % MAX = 1 do dữ liệu chuẩn hóa

% ====== PSNR: WAV vs MP3 ======
psnr_mp3_L = psnr_channel(x_wav(:,1), x_mp3(:,1));
psnr_mp3_R = psnr_channel(x_wav(:,2), x_mp3(:,2));

% ====== PSNR: WAV vs FLAC ======
psnr_flac_L = psnr_channel(x_wav(:,1), x_flac(:,1));
psnr_flac_R = psnr_channel(x_wav(:,2), x_flac(:,2));

% ====== PSNR: MP3 vs FLAC ======
psnr_mf_L = psnr_channel(x_mp3(:,1), x_flac(:,1));
psnr_mf_R = psnr_channel(x_mp3(:,2), x_flac(:,2));

% ====== HIỂN THỊ KẾT QUẢ ======
fprintf("🎧 PSNR (WAV vs MP3)  - Left: %.2f dB | Right: %.2f dB\n", psnr_mp3_L, psnr_mp3_R);
fprintf("🎧 PSNR (WAV vs FLAC) - Left: %.2f dB | Right: %.2f dB\n", psnr_flac_L, psnr_flac_R);
fprintf("🎧 PSNR (MP3 vs FLAC) - Left: %.2f dB | Right: %.2f dB\n", psnr_mf_L, psnr_mf_R);

% ====== VẼ BIỂU ĐỒ (LEFT + RIGHT) ======
t = (1:minLen)/fs1; % trục thời gian

figure;
subplot(3,2,1); plot(t, x_wav(:,1)); title('WAV - Left'); xlabel('Time (s)');
subplot(3,2,2); plot(t, x_wav(:,2)); title('WAV - Right'); xlabel('Time (s)');

subplot(3,2,3); plot(t, x_mp3(:,1)); title('MP3 - Left'); xlabel('Time (s)');
subplot(3,2,4); plot(t, x_mp3(:,2)); title('MP3 - Right'); xlabel('Time (s)');

subplot(3,2,5); plot(t, x_flac(:,1)); title('FLAC - Left'); xlabel('Time (s)');
subplot(3,2,6); plot(t, x_flac(:,2)); title('FLAC - Right'); xlabel('Time (s)');

% ====== PHỔ CHÊNH LỆCH ======
NFFT = 2^nextpow2(minLen);

% Gọi hàm vẽ phổ chênh lệch
plot_diff_spectrum(x_wav, x_mp3, fs1, NFFT, 'WAV vs MP3');
plot_diff_spectrum(x_wav, x_flac, fs1, NFFT, 'WAV vs FLAC');
plot_diff_spectrum(x_mp3, x_flac, fs1, NFFT, 'MP3 vs FLAC');

% ====== HÀM CON: Vẽ phổ chênh lệch giữa 2 tín hiệu stereo ======
function plot_diff_spectrum(sig1, sig2, fs, NFFT, label)
    f = fs/2 * linspace(0, 1, NFFT/2+1);
    % LEFT
    diffL = fft(sig1(:,1) - sig2(:,1), NFFT) / size(sig1,1);
    magL = 20*log10(abs(diffL(1:NFFT/2+1)) + 1e-12); % tránh log(0)
    % RIGHT
    diffR = fft(sig1(:,2) - sig2(:,2), NFFT) / size(sig1,1);
    magR = 20*log10(abs(diffR(1:NFFT/2+1)) + 1e-12);

    figure('Name', ['Difference Spectrum: ' label]);
    subplot(2,1,1); plot(f, magL); title([label ' - LEFT channel']);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); grid on;

    subplot(2,1,2); plot(f, magR); title([label ' - RIGHT channel']);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); grid on;
end
