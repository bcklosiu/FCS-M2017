function [guess LB UB numparamvariables numparamfijos indparamvariables indparamfijos valorparamfijos]=...
    check_fijoovariable (paramlibre, valorparametro, indice, guess, LB, UB, valorLB, valorUB, numparamvariables, numparamfijos, indparamvariables, indparamfijos, valorparamfijos)
%Necesario para los ajustes

%Comprueba si los par�metros son fijos o variables para (1) a�adirle los
%l�mites inferior y superior y (2) hacer un �ndice de par�metros variables
%para pas�rselo a la funci�n de ajuste

if paramlibre
    numparamvariables=numparamvariables+1;
    indparamvariables(numparamvariables)=indice;
    guess(numparamvariables)=valorparametro; %Si el parametro est� libre usa el valor introducido como guess
    LB(numparamvariables)=valorLB; 
    UB(numparamvariables)=valorUB; 
else
    numparamfijos=numparamfijos+1;
    indparamfijos(numparamfijos)=indice;
    valorparamfijos(numparamfijos)=valorparametro;
    %Si el par�metro est� fijo no se a�ade lower o upper bounds
end