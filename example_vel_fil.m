% Запуск фильтрации для трех размеров окна Ханна
path = "C:\Users\ledid\Downloads\beta0_1.2";
name_mat = "C:\Users\ledid\Downloads\PIVlab_set_Diana_beta0.1_1.mat";

% Запускаем для трех размеров окон
IW_sizes = [64, 32];

for i = 1:length(IW_sizes)
    IW = IW_sizes(i);
    fprintf('Запуск фильтрации с IW = %d...\n', IW);
    
    % Создаем отдельную папку для каждого размера окна
    current_path = path + "\IW_" + num2str(IW);
    if ~exist(current_path, 'dir')
        mkdir(current_path);
    end
    
    velocity_filtered(current_path, name_mat, IW);
    fprintf('Завершено для IW = %d\n\n', IW);
end