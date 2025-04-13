% ====== NHIỆM VỤ 4: So sánh WAV/MP3 (stereo) vs FLAC (mono) ======

% Đọc các file âm thanh
[x_wav, fs1]  = audioread("Track No07.wav");
[x_mp3, fs2]  = audioread("Track No07.mp3");
[x_flac_mono, fs3] = audioread("output_mono_degree1.flac");  % MONO

% Kiểm tra sample rate
if fs1 ~= fs2 || fs1 ~= fs3
    error("⚠️ Sample rates không đồng nhất!");
end

% Cắt độ dài theo file ngắn nhất
minLen = min([length(x_wav), length(x_mp3), length(x_flac_mono)]);
x_wav  = x_wav(1:minLen, :);     % stereo
x_mp3  = x_mp3(1:minLen, :);     % stereo
x_flac_mono = x_flac_mono(1:minLen);  % mono vector

% Chuyển mono thành stereo bằng cách nhân bản
x_flac = repmat(x_flac_mono, 1, 2);  % tạo 2 kênh từ mono

% ====== PSNR Function ======
psnr_channel = @(a, b) 10 * log10(1^2 / mean((a - b).^2));

% PSNR (WAV vs MP3)
psnr_mp3_L = psnr_channel(x_wav(:,1), x_mp3(:,1));
psnr_mp3_R = psnr_channel(x_wav(:,2), x_mp3(:,2));

% PSNR (WAV vs FLAC-mono)
psnr_flac_L = psnr_channel(x_wav(:,1), x_flac(:,1));
psnr_flac_R = psnr_channel(x_wav(:,2), x_flac(:,2));

% PSNR (MP3 vs FLAC-mono)
psnr_mf_L = psnr_channel(x_mp3(:,1), x_flac(:,1));
psnr_mf_R = psnr_channel(x_mp3(:,2), x_flac(:,2));

% ====== KẾT QUẢ PSNR ======
fprintf("🎧 PSNR (WAV vs MP3)  - Left: %.2f dB | Right: %.2f dB\n", psnr_mp3_L, psnr_mp3_R);
fprintf("🎧 PSNR (WAV vs FLAC) - Left: %.2f dB | Right: %.2f dB\n", psnr_flac_L, psnr_flac_R);
fprintf("🎧 PSNR (MP3 vs FLAC) - Left: %.2f dB | Right: %.2f dB\n", psnr_mf_L, psnr_mf_R);

% ====== PHỔ CHÊNH LỆCH ======
NFFT = 2^nextpow2(minLen);
f = fs1/2 * linspace(0, 1, NFFT/2+1);

plot_diff_spectrum(x_wav, x_mp3,  fs1, NFFT, 'WAV vs MP3');
plot_diff_spectrum(x_wav, x_flac, fs1, NFFT, 'WAV vs FLAC');
plot_diff_spectrum(x_mp3, x_flac, fs1, NFFT, 'MP3 vs FLAC');

% ====== Hàm vẽ phổ chênh lệch giữa 2 tín hiệu stereo ======
function plot_diff_spectrum(sig1, sig2, fs, NFFT, label)
    f = fs/2 * linspace(0, 1, NFFT/2+1);
    figure('Name', ['Difference Spectrum: ' label]);

    % LEFT
    diffL = fft(sig1(:,1) - sig2(:,1), NFFT) / length(sig1);
    magL = 20*log10(abs(diffL(1:NFFT/2+1)) + 1e-12);  % tránh log(0)
    subplot(2,1,1);
    plot(f, magL); title([label ' - LEFT channel']);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); grid on;

    % RIGHT
    diffR = fft(sig1(:,2) - sig2(:,2), NFFT) / length(sig1);
    magR = 20*log10(abs(diffR(1:NFFT/2+1)) + 1e-12);
    subplot(2,1,2);
    plot(f, magR); title([label ' - RIGHT channel']);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); grid on;
end
    