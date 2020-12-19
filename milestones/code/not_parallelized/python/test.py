from wpli import *


#setup variables
input_path = "C:/Users/rapha/OneDrive/Documents/School/Research/test_python/data_deb_wpli/372_103_LEFT_20201009"
output_path = "C:/Users/rapha/OneDrive/Documents/School/Research/test_python/results/deb_wpli"
name = "372_103_LEFT_20201009"
sessions = ["T1"]
states = ['baseline']
adds = ""

file_format = '.set'
#channel_order_path = "C:/Users/rapha/OneDrive/Documents/Consciousness-Graph/milestones/code/not_parallelized/python/biapt_egi129.csv"


#create patient object
patient_deb = Patient(name, input_path, output_path, sessions, states, file_format, adds)


#calculate wpli
patient_deb.calculate_debiased_wpli(fmin = 8, fmax = 13, n_windows = 300)

#plot and save results
patient_deb.plot_deb_wpli()
