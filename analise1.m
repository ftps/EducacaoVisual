clear
file = "EV_2019.1_3";
fp = fopen(file,'r');
m = data_read(fp);
fclose(fp);

Time = 1; Sats = 4; HPL = 5; VPL = 6; 
Lat = 7; Lon = 8; Alt = 9; Ref = 6; ER = 6.371*10^6; deg = pi/180; 
Hor = 1; Ver = 2; HAL_Ref = 40; VAL_Ref = 12; % CAT-I

errors = zeros(2, size_lin(m));
alerts = zeros(2, size_lin(m));

for i = 1:size_lin(m)
    dLat = abs(ER*deg*(m(i, Lat) - m(i, Lat+Ref)));
    dLon = abs(ER*deg*(m(i, Lon) - m(i, Lon+Ref))*sin(m(i, Lat+Ref)*deg));

    errors(Hor, i) = sqrt(dLat^2 + dLon^2);
    errors(Ver, i) = abs(m(i, Alt) - m(i, Alt+Ref));

    alerts(Hor, i) = errors(Hor, i) - m(i, HPL);
    if alerts(Hor, i) > 0
       fprintf("Evento horizontal, no tempo da semana %d (s), com um erro de %.2f metros. O HPL � de apenas %.2f m nesse momento.\n", m(i,Time), errors(Hor, i), m(i,HPL));
    end
    alerts(Ver, i) = errors(Ver, i) - m(i, VPL);
    if alerts(Ver, i) > 0
       fprintf("Evento vertical, no tempo da semana %d (s), com um erro de %.2f metros. O VPL � de apenas %.2f m nesse momento.\n", m(i,Time), errors(Ver, i), m(i,VPL));
    end
end

HPE = prctile(errors(Hor), 95); %0.5672m
VPE = prctile(errors(Ver), 95); %2.3540m

HAL = prctile(m(:,HPL), 99);
VAL = prctile(m(:,VPL), 99);

Dispo = 1;

for i = 1:size_lin(m)
    if (HAL_Ref-m(i,HPL) < 0) || (VAL_Ref-m(i,VPL) < 0)
        Dispo = Dispo - (1/size_lin(m));
    end
end

HAL_Vec = HAL_Ref*ones(1, size_lin(m));
VAL_Vec = VAL_Ref*ones(1, size_lin(m));

figure(1)
plot(m(:,Time), m(:,Sats));
axis([-inf inf 7.5 9.5]);
xlabel('t (s)');
ylabel('N� de Satelites ');

figure(2)
subplot(2,1,1);
plot(m(:,Time), HAL_Vec, m(:,Time), m(:,HPL));
axis([-inf inf 0 42]);
xlabel('t (s)');
ylabel('N�veis de prote��o e alerta (m)');

subplot(2,1,2);
plot(m(:,Time), VAL_Vec, m(:,Time), m(:,VPL));
axis([-inf inf 0 15]);
xlabel('t (s)');
ylabel('N�veis de prote��o e alerta (m)');

figure(3)
subplot(2,1,1);
plot(m(:,Time), m(:,HPL), m(:,Time), errors(Hor,:));
axis([-inf inf 0 60]);
xlabel('t (s)');
ylabel('Erro (m)');

subplot(2,1,2);
plot(m(:,Time), m(:,VPL), m(:,Time), errors(Ver,:));
axis([-inf inf 0 15]);
xlabel('t (s)');
ylabel('Erro (m)');


% funcao para ler os valores dos ficheiros
function mat = data_read(fp)
    cols = 1;
    line = fgets(fp);
    mat = 0;

    for i = 1:size_col(line)
        if line(i) == ';'
            cols = cols + 1;
        end
    end

    while ~feof(fp)
        line = fgets(fp);
        aux = sscanf(line, "%f;", [1, cols]);
        if mat == 0
            mat = aux;
        else
            mat = [mat; aux];
        end
    end

end

%funcoes auxiliares para tamanho da matriz
function n = size_col(v)
    [~, n] = size(v);
end

function n = size_lin(v)
    [n, ~] = size(v);
end
