function compare_spectrums(base_path, point_numbers, IW_sizes)
    % Создает отдельное окно для каждого размера окна Ханна
    % В каждом окне: верхний ряд - спектры, нижний ряд - осциллограммы
    
    Fs = 3500;
    colors = ['r', 'g', 'b', 'm', 'c'];
    
    N_points = length(point_numbers);
    
    for iw_idx = 1:length(IW_sizes)
        IW = IW_sizes(iw_idx);
        
        % Создаем отдельное окно для каждого IW (увеличиваем высоту для двух рядов)
        figure('Position', [100 + 50*iw_idx, 100 + 50*iw_idx, 600 * N_points, 700]);
        sgtitle(['Размер окна Ханна: IW = ' num2str(IW)]);
        
        for p_idx = 1:N_points
            point_num = point_numbers(p_idx);
            data_path = base_path + "\IW_" + num2str(IW) + "\velocity_filtered\";
            filename_x = data_path + "x_" + num2str(point_num) + ".txt";
            
            if ~exist(filename_x, 'file')
                % Если файл не найден, создаем пустые подграфики
                subplot(2, N_points, p_idx);
                text(0.5, 0.5, 'Данные не найдены', 'HorizontalAlignment', 'center');
                title(['Спектр: Точка ' num2str(point_num)]);
                
                subplot(2, N_points, p_idx + N_points);
                text(0.5, 0.5, 'Данные не найдены', 'HorizontalAlignment', 'center');
                title(['Осциллограмма: Точка ' num2str(point_num)]);
                continue;
            end
            
            u_filtered = dlmread(filename_x);
            L = length(u_filtered);
            
            % --- ВЕРХНИЙ РЯД: СПЕКТРЫ ---
            subplot(2, N_points, p_idx);
            
            % Расчет спектра
            Y = fft(u_filtered);
            P2 = abs(Y/L);
            P1 = P2(1:floor(L/2)+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = Fs*(0:(length(P1)-1))/L;
            
            loglog(f, P1, colors(iw_idx), 'LineWidth', 0.5);
            xlabel('Частота (Hz)');
            ylabel('Амплитуда |P1(f)|');
            title(['Спектр: Точка ' num2str(point_num)]);
            grid on;
            xlim([0.1, 1000]);
            
            % --- НИЖНИЙ РЯД: ОСЦИЛЛОГРАММЫ ---
            subplot(2, N_points, p_idx + N_points);
            
            % Создаем ось времени
            T = 1/Fs;
            t = (0:L-1)*T;
            
            plot(t, u_filtered, colors(iw_idx), 'LineWidth', 1);
            xlabel('Время (s)');
            ylabel('Скорость u');
            title(['Осциллограмма: Точка ' num2str(point_num)]);
            grid on;
        end
    end
end