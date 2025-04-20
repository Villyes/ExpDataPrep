% villyes, 21.11.2024

function [THotIn_corr, THotOut_corr, TColdIn_corr, TColdOut_corr]=correctTs(THotIn, THotOut, TColdIn, TColdOut, THotIn_err, THotOut_err, TColdIn_err, TColdOut_err, pHotIn, pHotOut, pColdIn, pColdOut)
    m=[THotIn, THotOut, TColdIn, TColdOut]; % measured T
    err=[THotIn_err, THotOut_err, TColdIn_err, TColdOut_err]; % error of measured T
    V=diag(err);
    p=[pHotIn, pHotOut, pColdIn, pColdOut]; % pressure not reconciliated

    opts=optimoptions('fmincon','display','off','Algorithm','sqp');
    fun = @(x) mqf(x,m,V);


    x = fmincon(fun,m,[],[],[],[],[],[],@(x) mycon(x,p),opts);
    THotIn_corr=x(1);
    THotOut_corr=x(2);
    TColdIn_corr=x(3);
    TColdOut_corr=x(4);

    %%
    function sse=mqf(x,m1,V1)
        sse=(m1-x)*inv(V1)*(m1-x)';
    end
    
    function [c,ceq] = mycon(x,p)
    % [THotIn, THotOut TColdInFI TColdOut];
    % [1       2       3         4]
    % h_HotIn-h_HotOut+h_ColdIn-h_ColdOut
        c = [];     % Compute nonlinear inequalities at x.
        ceq = [CO2.h(p(1), x(1)+273.15)-CO2.h(p(2), x(2)+273.15)+CO2.h(p(3), x(3)+273.15)-CO2.h(p(4), x(4)+273.15)];   % Compute nonlinear equalities at x.
    end
end