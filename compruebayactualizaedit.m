function valor=compruebayactualizaedit(handle, lim_inferior, lim_superior, valoranterior)
%
% valor=compruebayactualizaedit(handle, lim_inferior, lim_superior, valoranterior)
% Dado un handle de un edit, comprueba si el valor introducido es num�rico
% Si no es num�rico, deja el anterior.
% Si no est� entre los l�mites corrige al valor m�nimo o m�ximo,
% respectivamente. El m�nimo o m�ximo puede ser -Inf o Inf
% Actualiza autom�ticamente el control del edit
%
% Generalmente se usa as�: 
% 
% v=getappdata (handles.figure1, 'v'); 
% v.valor=compruebayactualizaedit(hObject, lim_Inferior, lim_Superior, v.valor);
% setappdata (handles.figure1, 'v', v); 
%
% jri 2oct12 
temp=str2double(get (handle, 'String'));
if isnan(temp)
    set (handle, 'String', num2str(valoranterior));
    valor=valoranterior;
else
    valor=temp;
    if valor<lim_inferior
        valor=lim_inferior;
        set (handle, 'String', num2str(valor));
    end
    if valor>lim_superior
        valor=lim_superior;
        set (handle, 'String', num2str(valor));
    end
end
