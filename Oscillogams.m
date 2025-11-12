%%
clear, clc

directory = "H:\Pulse\27.10.2025\190D_Wo9_Re3000\matlab\PIVlab_set_Diana_beta0.3_2.mat";
load(directory) %Директория обработанных результатов в PIVlab
num_frame = length(u_filtered); %Количество кадров
[len, wide] = size(u_filtered{1,1}); % Количество строк и столбцов
u_time = zeros(1, num_frame-1);
u_01_time = zeros(1, num_frame);
u_03_time = zeros(1, num_frame);
x_axes = zeros(1, num_frame-1);
profile = zeros(1, len);
u_average = zeros(len, wide);
v_average = zeros(len, wide);
u_sd = zeros(len, wide);
v_sd = zeros(len, wide);
uv_sd = zeros(len, wide);
dt = 0.0004;

%%
%Заполняем массив значениями скорости в выбранной точке
for step = 1:num_frame-1
    u_time(1, step) = u_filtered{step,1}(round(len/2),round(wide/2)); %(1,1) - координаты выбранной точки
%     u_01_time(1, step) = u_filtered{step,1}(39,7); %(1,1) - координаты выбранной точки
%     u_03_time(1, step) = u_filtered{step,1}(35,7); %(1,1) - координаты выбранной точки
    x_axes(1, step) = step * dt;
end

% % 
% %Построение профиля скорости
% for step = 1:len-1
%     profile(1, step) = u_filtered{5,1}(step,8);
% end
% 
% % Подсчет среднего значения поля скорости
% for step = 1:num_frame-1
%     for i = 1:len
%         for j = 1:wide
%             u_average(i,j) =  u_average(i,j) + u_filtered{step,1}(i, j);
%             v_average(i,j) =  v_average(i,j) + u_filtered{step,1}(i, j);
%         end
%     end
% end
% 
% u_average = u_average / num_frame;
% v_average = v_average / num_frame;
% 
% % Вычисление u' и v'
% for step = 1:num_frame-1
%     dev_u = (u_filtered{step,1} - u_average).^2;
%     u_sd = u_sd + dev_u;
%     dev_v = (v_filtered{step,1} - v_average).^2;
%     v_sd = v_sd + dev_v;
%     dev_uv = (u_filtered{step,1} - u_average).*(v_filtered{step,1} - v_average);
%     uv_sd = uv_sd + dev_uv;
% end
% 
% dev_u = dev_u / num_frame;
% dev_v = dev_v / num_frame;
% dev_uv = dev_uv / num_frame;
% 
% u_mean = mean(u_time);
%%
% figure(2)
% u_filtered1 = flipud(u_filtered{1,1});
% u_average1 =  flipud(u_average);
% pcolor(u_average1)
% h = colorbar;
% shading flat;    % Убирает границы между клетками
% axis equal;      % Делает клетки квадратными (масштаб по X и Y одинаковый)
% axis tight;      % Убирает лишние отступы по краям
% shading interp;  % Плавные цветовые переходы (сглаживание границ)
% caxis([0,0.4])

% Построение спектра осциллограммы
Fs = 2000; % Частота дискретизации
T = 1 / Fs; % Период дискретизации
L = 18955; % Длина сигнала
t = (0:L-1)*T; % Массив времени

Y = fft(u_time);
P2 = abs(Y/L); %Двусторонний спектр
P1 = P2(1:L/2+1); %Односторонний спектр
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L; % Область частот
plot(f,P1) 


% Построение графиков
figure;  % Создание нового окна для графика
loglog(f,P1)  % Построение графика
xlabel('f (Hz)')
ylabel('|P1(f)|')
grid on;

figure;  % Создание нового окна для графика
plot(x_axes, u_time)  % Построение графика
hold on; % Удерживаем текущий график
% plot(x_axes, u_01_time)  % Построение графика
% plot(x_axes, u_03_time)  % Построение графика

xlabel('Time');
ylabel('u');
%ylim([-150 200]);
% legend('Ядро', '0.1 r', '0.3 r');
% grid on;
hold off; % Отпускаем удержание

% figure;  % Создание нового окна для графика
% plot(profile)  % Построение профиля
% xlabel('x');
% ylabel('u');
% grid on;
