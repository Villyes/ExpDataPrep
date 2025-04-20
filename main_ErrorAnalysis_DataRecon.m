% villyes
% error analysis: measurement uncertainty
% data reconciliation: correcting experimental values (only temperatures) for matching hot and cold side while taking into account measurement uncertainty

load('example_data.mat');

%% 
% experimental data is in Pa gauge pressure and °C, change to Pa_abs and K
h_Hin=CO2.h(tab.pHotIn+1.013*10^5,tab.THotIn+273.15);
h_Hout=CO2.h(tab.pHotOut+1.013*10^5,tab.THotOut+273.15);
h_Cin=CO2.h(tab.pColdIn+1.013*10^5,tab.TColdInFI+273.15);
h_Cout=CO2.h(tab.pColdOut+1.013*10^5,tab.TColdOut+273.15);

tab.QHot=tab.mCO2.*(h_Hout-h_Hin);
tab.QCold=tab.mCO2.*(h_Cout-h_Cin);

tab.Qtot=NaN(height(tab),1);
tab.THotIn_corr=NaN(height(tab),1);
tab.THotOut_corr=NaN(height(tab),1);
tab.TColdIn_corr=NaN(height(tab),1);
tab.TColdOut_corr=NaN(height(tab),1);

% Uncertainty acc. to measurement devices
THotIn_err=max(2.5,0.0075*tab.THotIn);
THotOut_err=0.15+0.002*tab.THotOut;
TColdIn_err=0.5+0.005*tab.TColdInFI;
TColdOut_err=0.15+0.002*tab.THotOut;

for i=1:height(tab)
    [tab.THotIn_corr(i), tab.THotOut_corr(i), tab.TColdIn_corr(i), tab.TColdOut_corr(i)]=correctTs(tab.THotIn(i), tab.THotOut(i), tab.TColdInFI(i), tab.TColdOut(i), THotIn_err(i), THotOut_err(i), TColdIn_err(i), TColdOut_err(i), tab.pHotIn(i)+1.013*10^5, tab.pHotOut(i)+1.013*10^5, tab.pColdIn(i)+1.013*10^5, tab.pColdOut(i)+1.013*10^5);
end

h_Hin=CO2.h(tab.pHotIn+1.013*10^5,tab.THotIn_corr+273.15);
h_Hout=CO2.h(tab.pHotOut+1.013*10^5,tab.THotOut_corr+273.15);

tab.Qtot=tab.mCO2.*(h_Hout-h_Hin);


tab=tab(~(tab.THotOut_corr<(CO2.Tc-273.15)),:); %sorting out condensing

disp('Data reconciliation done.')

clear h_Hin h_Hout h_Cin h_Cout THotIn_err THotOut_err TColdIn_err TColdOut_err