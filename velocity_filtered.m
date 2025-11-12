function velocity_filtered(path, name_mat, IW)
% velocity_filtered(path, name_mat, IW)
data = load(name_mat);
u_filtered = data.u_filtered;
v_filtered = data.v_filtered;

[Ny, Nx] = size(u_filtered{1,1});
iw = round(IW/2);
cut_w = zeros(Ny, Nx); 
cut_h = cut_w;

Nframe = length(u_filtered);
fmin = 3500/Nframe;
cut = 2;

if ~exist(path + "\velocity\", 'dir')
    mkdir(path + "\velocity\");
end

if ~exist(path + "\velocity_filtered\", 'dir')
    mkdir(path + "\velocity_filtered\");
end

%%
for j = 1:Ny
    for i = 1:Nx 
        p = (j-1)*Nx + i;
        for step = 1:Nframe
            x(1, step) = u_filtered{step,1}(j,i);
            y(1, step) = v_filtered{step,1}(j,i);
        end
        dlmwrite(fullfile(path, "velocity", "x_" + num2str(p) + ".txt"), x(:), 'Delimiter','\t');
        dlmwrite(fullfile(path, "velocity", "y_" + num2str(p) + ".txt"), y(:), 'Delimiter','\t');
    end
end

for j = 1:Ny
    for i = 1:Nx
        p = (j-1)*Nx + i;
        
        % ИСПРАВЛЕНИЕ: Добавление транспонирования (') для получения вектора-строки
        w = dlmread(fullfile(path, "velocity", "x_" + num2str(p) + ".txt"), '\t')'; 
        h = dlmread(fullfile(path, "velocity", "y_" + num2str(p) + ".txt"), '\t')';
        
        han = hann(IW).';
        nframe = round(Nframe/2);
        
        % Обработка по X
        F_w = fft(w(1:Nframe));
        F_w_ampl = 2*abs(F_w)./Nframe; F_w_ampl(1) = 0;
        F_w_ampl = fftshift(F_w_ampl);
        F_w_ampl_han = zeros(1, Nframe);
        
        for k = iw:Nframe-iw
            for ii = 1:IW
                % ИСПРАВЛЕНИЕ: F_w_ampl теперь (1 x Nframe), поэтому индексируем как F_w_ampl(1, index) 
                % или просто F_w_ampl(index). Оставляем (1, index) для совместимости
                % с тем, как была написана исходная формула.
                F_w_ampl_han(k) = F_w_ampl_han(k) + F_w_ampl(1, k-iw+ii)*han(ii); 
            end
            F_w_ampl_han(k) = 2*F_w_ampl_han(k)/IW;
        end
        
        F_w_ampl_han(1:iw-1) = F_w_ampl_han(iw);
        F_w_ampl_han(Nframe-iw+1:Nframe) = F_w_ampl_han(Nframe-iw);
        F_w_ampl = ifftshift(F_w_ampl_han);
        F_w_pow = abs(F_w_ampl).^2;
        
        pow_w_min = min(F_w_pow);
        cut_w(j, i) = 1;
        for k = 2:nframe
            if F_w_pow(k) <= cut*pow_w_min
                cut_w(j, i) = k-1;
                break;
            end
        end
        
        F_w(1, cut_w(j, i)+1:Nframe-cut_w(j, i)+1) = 0;
        w_fft = ifft(F_w);
        
        % Обработка по Y
        F_h = fft(h(1:Nframe));
        F_h_ampl = 2*abs(F_h)./Nframe; F_h_ampl(1) = 0;
        F_h_ampl = fftshift(F_h_ampl);
        F_h_ampl_han = zeros(1, Nframe);
        
        for k = iw:Nframe-iw
            for ii = 1:IW
                F_h_ampl_han(k) = F_h_ampl_han(k) + F_h_ampl(1, k-iw+ii)*han(ii);
            end
            F_h_ampl_han(k) = 2*F_h_ampl_han(k)/IW;
        end
        
        F_h_ampl_han(1:iw-1) = F_h_ampl_han(iw);
        F_h_ampl_han(Nframe-iw+1:Nframe) = F_h_ampl_han(Nframe-iw);
        F_h_ampl = ifftshift(F_h_ampl_han);
        F_h_pow = abs(F_h_ampl).^2;
        
        pow_h_min = min(F_h_pow);
        cut_h(j, i) = 1;
        for k = 2:nframe
            if F_h_pow(k) <= cut*pow_h_min
                cut_h(j, i) = k-1;
                break;
            end
        end
        
        F_h(1, cut_h(j, i)+1:Nframe-cut_h(j, i)+1) = 0;
        h_fft = ifft(F_h);
        
        % Сохранение
        dlmwrite([path + "\velocity_filtered\x_" + num2str(p) + ".txt"], real(w_fft(:)), 'precision', '%.6f',...
                 'delimiter', '\n', 'newline', 'pc');
        dlmwrite([path + "\velocity_filtered\y_" + num2str(p) + ".txt"], real(h_fft(:)), 'precision', '%.6f',...
                 'delimiter', '\n', 'newline', 'pc');
    end
end

cut_w = round(cut_w*fmin);
cut_h = round(cut_h*fmin);

dlmwrite([path + "\velocity_filtered\cut_x.txt"], cut_w, 'delimiter', '\t');
dlmwrite([path + "\velocity_filtered\cut_y.txt"], cut_h, 'delimiter', '\t');

fprintf('Фильтрация завершена для IW = %d\n', IW);
end