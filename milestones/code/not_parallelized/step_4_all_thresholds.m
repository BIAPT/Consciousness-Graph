%{ 

    Raphael Christin 12/02/2021
    
    script to loop over a range of thresholds and compute graph theory
    properties from aec, wpli and dpli matrices
    
%}

clear; %keep only variables from this experiment
thresholds = 0.05:0.05:0.7; %range of thresholds

for t=1:length(thresholds)
    current_threshold = thresholds(t);%get current threshold
    
    mode='wpli';%run for wpli at this threshold
    step_3b_generate_network_properties;
    
    mode='dpli';%same for dpli
    step_3b_generate_network_properties;
    
    mode='aec';%same for aec
    step_3b_generate_network_properties;
end