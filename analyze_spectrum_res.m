% Анализ результатов фильтрации
base_path = "C:\Users\ledid\Downloads\beta0_1.2\";
point_numbers = [1, 5, 10, 20]; % Выберите несколько точек для анализа
IW_sizes = [64, 32];

% Запускаем сравнение спектров
compare_spectrums(base_path, point_numbers, IW_sizes);