function varargout=FCS_representaTraza (FCSTraza, tTraza, tipoCorrelacion, hfig)

%
% [hinf hsup hfig]=FCS_representa (FCSData, Gdata, tipoCorrelacion, hfig);
% Representa el resultado de la correlaci�n
%   FCSData es un vector columna o una matriz de dos columnas que contiene datos de la traza temporal de uno o dos canales, respectivamente.
%   Gdata es una matriz que contiene los datos de la correlaci�n (matrizFCS): la 1� columna es el tiempo, la 2� la ACF del canal 1, la 3� su error, etc.
%   deltaT=1/sampfreq (en s)
%   tipoCorrelacion es 3 para correlac�n cruzada o 1 � 2 para autocorrelaci�n
%   Puede estar vac�o: []. Si no hay handle, tampoco es necesario ponerlo
%   hfig es el handle a la figura en la que lo representar�. Si no se indica crea una figura nueva
%   Si no hay argumentos de salida no devuelve nada
%
%  hinf es el handle a los ejes de la gr�fica de la correlaci�n (inferior)
%  hsup es el handle a los ejes de la gr�fica de la traza temporal (superior)
%  hfig es el handle a la figura
%
% jri & GdlH - 12nov10
% jri & GdlH - 01jun11
% jri 19may14 - Evito el argumento de salida con vargout si no se pone nada
% jri 1ago14 - Cambio el tama�o de la figura para que no se salga de la pantalla.
% jri 1ago14 - Comentarios en ingl�s y fondo blanco
% jri 1ago14 - Cambio la escala a ms (no s�lo la leyenda)
% jri 27Nov14 - Hago una funci�n para calcular la traza y no tener que hacerlo de cada vez.
% jri 21Jan15 - Incluye que no sea necesario poner el canal en 'auto'
% jri 2Feb15 - Incluye el n�mero de figura
% jri 26Mar15 - Dibuja CPS en 10^2 CPS (bins de 0.01s). Cambia la l�nea para que pase por el promedio, en vez de por 1
% jri 20Abr15


verde =[1 131 95]/255;
rojo = [197 22 56]/255;
azul = [0 102 204]/255;
negro = [50 50 50]/255;

if nargin<5 %No hay handle a la figura, por tanto crea una nueva
    hfig=figure;
else
    %set (0, 'CurrentFigure', hfig);
    figure (hfig)
end




if tipoCorrelacion==3 % cuando es correlaci�n cruzada
    h_axes(1)=subplot (2,1,1); %Representa las trazas
    h_axes(2)=subplot (2,1,2); %Representa las trazas
    set(hfig, 'CurrentAxes', hsup(1))
    htemp1=plot (tTraza, FCSTraza(:,1), 'Color', verde, 'Linewidth', 1.5);
    hLegend(1)=legend (['Ch 1: ', num2str(cpscanal(1))]);
    %hold on
    set(hfig, 'CurrentAxes', hsup(2))
    htemp2=plot (tTraza, FCSTraza(:,2), 'Color', rojo, 'Linewidth', 1.5);
    hLegend(2)=legend (['Ch 2: ', num2str(cpscanal(2))]);
    linePos=mean(FCSTraza);
    v=axis (hsup(1));
    line ([v(1) v(2)], [linePos(1) linePos(1)], 'Color', [0 0 0], 'LineStyle', ':') %Pinta una l�nea que pasa por 1
    line ([v(1) v(2)], [linePos(2) linePos(2)], 'Color', [0 0 0], 'LineStyle', ':')
    
    %     line ([v(1) v(2)], [meangkmean(1)+sqrt(meangkmean(1)) meangkmean(1)+sqrt(meangkmean(1))]/meangkmean(1), 'Color', verde, 'LineStyle', ':') %Pinta una l�nea que indica la desv. est. poissoniana
    %     line ([v(1) v(2)], [meangkmean(1)-sqrt(meangkmean(1)) meangkmean(1)-sqrt(meangkmean(1))]/meangkmean(1), 'Color', verde, 'LineStyle', ':') %Pinta una l�nea que indica la desv. est. poissoniana
    %     line ([v(1) v(2)], [meangkmean(2)+sqrt(meangkmean(2)) meangkmean(2)+sqrt(meangkmean(2))]/meangkmean(2), 'Color', rojo, 'LineStyle', ':') %Pinta una l�nea que indica la desv. est. poissoniana
    %     line ([v(1) v(2)], [meangkmean(2)-sqrt(meangkmean(2)) meangkmean(2)-sqrt(meangkmean(2))]/meangkmean(2), 'Color', rojo, 'LineStyle', ':') %Pinta una l�nea que indica la desv. est. poissoniana
    axis (hsup(1), [v(1) v(2) min(min(FCSTraza(:, 1)))*0.99 max(max(FCSTraza(:, 1)))*1.01]) %Cambia los l�mites de los ejes
    axis (hsup(2), [v(1) v(2) min(min(FCSTraza(:, 2)))*0.99 max(max(FCSTraza(:, 2)))*1.01]) 
    pos_tmp=get(hsup(1), 'Position');
    set (hsup(1), 'YColor', verde)
    set (hsup(2), 'Position', pos_tmp, 'Box', 'off')
    set (hsup(2), 'Color', 'none', 'YAxisLocation', 'right', 'YColor', rojo)
    
    set(hfig, 'CurrentAxes', hinf)
    hold on
    hcorr1=errorbar (tdata_k, G(:,1), SD(:,1), 'o-', 'Color', verde, 'Linewidth', 1.5);
    hcorr2=errorbar (tdata_k, G(:,2), SD(:,2), 'o-', 'Color', rojo, 'Linewidth', 1.5);
    hcorr12=errorbar (tdata_k, G(:,3), SD(:,3), 'o-', 'Color', azul, 'Linewidth', 1.5);
    hLegend(2)=legend ('Ch1', 'Ch2', 'Cross');
    hold off
else
    h_axes=axes;
    %canal=tipoCorrelacion;
    canal=1;
    htemp=plot (tTraza, FCSTraza(:, canal), 'Color', verde, 'Linewidth', 1.5);
    hLegend(1)=legend (['Ch ', num2str(canal) ': ', num2str(cpscanal(canal))]);
    v=axis(hsup);
    linePos=mean(FCSTraza(:, 1));
    line ([v(1) v(2)], [linePos linePos], 'Color', [0 0 0], 'LineStyle', ':')
    axis (hsup, [v(1) v(2) min(FCSTraza(:, canal))*0.99 max(FCSTraza(:, canal))*1.01])
    
    hold off
    set(hfig, 'CurrentAxes', hinf)
    hCorrPlot=errorbar (tdata_k, G(:, canal), SD(:, canal), 'o-', 'Color', verde, 'Linewidth', 1.5);
    %{
        htemp=plot (tTraza, FCSTraza(:,2), 'Color', rojo, 'Linewidth', 1.5);
        hLegend(1)=legend (['Ch 2: ', num2str(cpscanal(2))]);
        v=axis (hsup);
        line ([v(1) v(2)], [linePos(canal) linePos(canal)], 'Color', [0 0 0], 'LineStyle', ':')
        axis (hsup, [v(1) v(2) min(min(FCSTraza(canal)))*0.99 max(max(FCSTraza(canal)))*1.01])
        
        hold off
        set(hfig, 'CurrentAxes', hinf)
        hCorrPlot=errorbar (tdata_k, G(:,2), SD(:,2), 'o-', 'Color', rojo, 'Linewidth', 1.5);
    %}
    
end


rect=get (hfig, 'OuterPosition');
screenSize=get(0, 'Screensize');
set (hfig, 'OuterPosition', [rect(1) 50 screenSize(4)-50 screenSize(4)-50])
rect_sup=get (hsup(1), 'OuterPosition');
set (hsup, 'OuterPosition', [rect_sup(1) 0.75 rect_sup(3) rect_sup(3)*0.2])
rect_inf=get (hinf, 'OuterPosition');
set (hinf, 'OuterPosition', [rect_inf(1) 0.01 rect_sup(3) rect_sup(3)*0.7])
set (hinf, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
v=axis (hinf);
axis (hinf, [tdata_k(1)-0.25*tdata_k(1) tdata_k(end)+0.5*tdata_k(end) v(3) v(4)])
% axes (hsup)
%{
     a=get(hinf,'XTickLabel');
     b=str2num(a)+3; %%% Para pasar los segundos a milisegundos en escala logar�tmica
     set(hinf,'XTickLabel',10.^b)
     xlabel ('\tau (ms)')
%}

set (hfig, 'Color', [1 1 1])
set ([hsup hinf], 'Color', 'none', 'FontName', 'Calibri', 'FontSize', 11)

hLabel_sup(1)=xlabel (hsup(1), 'Time (s)');
%hLabel(1,2)=ylabel (hsup, {'Channel-averaged'; 'normalised counts'});
hLabel_sup(2)=ylabel (hsup(1), {'Counts (10^2 CPS)'});
if tipoCorrelacion==3
    hLabel_sup(3)=ylabel (hsup(2), {'Counts (10^2 CPS)'});
end


set (hinf, 'XScale', 'log')
hLabel_inf(1)=xlabel (hinf, '\tau (ms)');
hLabel_inf(2)=ylabel (hinf, 'G (\tau)');
set (hLabel_sup, 'FontName', 'Calibri', 'FontSize', 11)
set (hLabel_inf, 'FontName', 'Calibri', 'FontSize', 11)
set (hLegend, 'FontName', 'Calibri', 'FontSize', 11)


if nargout>0
    varargout(1)={hinf};
end
if nargout>1
    varargout(2)={hsup};
end
if nargout>2
    varargout(3)={hfig};
end




