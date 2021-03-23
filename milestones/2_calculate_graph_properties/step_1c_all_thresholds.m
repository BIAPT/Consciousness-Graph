%{ 

    Raphael Christin 12/02/2021
    
    script to loop over a range of thresholds and compute graph theory
    properties from aec, wpli and dpli matrices
    
%}

clear; %keep only variables from this experiment
thresholds = 0.05:0.05:0.7; %range of thresholds
modes = {'wpli', 'dpli','aec'};%'wpli', 'dpli', 

for t=1:length(thresholds)
    current_threshold = thresholds(t);%get current threshold
    for m=1:length(modes)
        mode=modes{m};
        step_1_generate_network_properties;
    end
end