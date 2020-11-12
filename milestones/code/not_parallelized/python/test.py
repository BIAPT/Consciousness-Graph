from wpli import *


#setup variables
input_path = "D:\\Raphael Christin\\Blain lab\\data\\MDFA\\Resting state analysis\\MDFA10\\DATA"
output_path = "C:\\Users\\rapha\\OneDrive\\Documents\\School\\Research\\test_python\\results"
name = "MDFA10"
sessions = ["T1"]
states = ['baseline']

file_format = '.set'
channel_order_path = "C:\\Users\\rapha\\OneDrive\\Documents\\Consciousness-Graph\\milestones\\code\\not_parallelized\\python\\biapt_egi129.csv"


#create patient object
mdfa10 = Patient(name, input_path, output_path, sessions, states, file_format)


#calculate wpli
mdfa10.calculate_wpli(fmin = 8, fmax = 13, channel_order_path = channel_order_path)

#plot and save results
mdfa10.plot_wpli()
