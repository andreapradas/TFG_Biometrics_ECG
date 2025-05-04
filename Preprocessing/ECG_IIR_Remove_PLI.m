function Filtered_Signal = ECG_IIR_Remove_PLI(signal, fs, f0, gr)
    r = 0.9; % Factor de atenuación del notch
    
    % Calcular la cantidad máxima de armónicos antes de Nyquist
    max_harmonics = floor((fs/2) / f0);
    
    % Inicializar coeficientes de filtro en 1 (identidad)
    b_total = 1;
    a_total = 1;

    % Aplicar notch en cada múltiplo de f0 hasta el Nyquist
    for k = 1:max_harmonics
        fk = k * f0;
        omega0 = 2 * pi * fk / fs; % Frecuencia angular normalizada

        % Coeficientes del filtro notch en fk Hz
        b = [1, -2*cos(omega0), 1];
        a = [1, -2*r*cos(omega0), r^2];

        % Multiplicar los filtros Notch en cascada
        b_total = conv(b_total, b);
        a_total = conv(a_total, a);
    end

    % Normalización de ganancia en DC
    gain_dc = sum(b_total) / sum(a_total);
    b_total = b_total / gain_dc;
    a_total = a_total / gain_dc;

    % Graficar la respuesta en frecuencia si `gr` es true
    if gr
        [H, w] = freqz(b_total, a_total, 1024, fs);
        figure;
        plot(w * fs / (2*pi), abs(H), 'b'); % Escalar frecuencia correctamente
        xlabel('Frequency (Hz)'); ylabel('Magnitude');
        title(['IIR Notch Filter Frequency Response']);
        grid on;
    end

    % Aplicar el filtro a la señal ECG
    Filtered_Signal = filtfilt(b_total, a_total, signal);
end
