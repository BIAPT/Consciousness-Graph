# Documentation
## Aim
The purpose of this library is to be able to process EEG signals in python instead of matlab. The EEG processing relies heavily on the MNE python library, found [here](https://github.com/mne-tools/mne-python). The [pandas](https://pandas.pydata.org/) library is also required to be installed. 
## Architecture
- The wpli.py file contains the bulk of the code, which will be discussed later.
- The test.py file contains examples of the use of the functions and structures present in the wpli.py file
## Usage
### Importing wpli.py
To use the code, one needs to import the wpli.py file at the beginning of their python file, as follows : 
```python
import sys
import os
sys.path.append(os.path.abspath("path/to/folder"))
import wpli
```
This will import the code contained in wpli.py for further usage  
Of course, one needs to replace the path/to/folder with the absolute path to this folder (which contains wpli.py) on their machine  
One also needs to have the mne python library installed. Instructions to install mne can be found at the mne [github](https://github.com/mne-tools/mne-python)
### Available functions and class
#### Patient class
The wpli.py file introduces the Patient class, which contains information about all the necessary information about a patient. 
It has the following attributes: 
- name : the name/number of the patient, same as the folder that hosts the data
- input_path : the path to the data files of the patient 
   - should be ordered in the following way : input/path/name/session(s)/state(s)  
   the states are .set or .edf files or some other data format  
   there can be many sessions snd states
- output_path : output path for the computations on the data
- sessions : list of the sessions that the patient went through, ordered in folders of the same name as specified in the input_path
- states : list of the states in each session, stored as files of the same name in the path
- file_format : format of the state files : .set or .edf at the moment 
- adds : additions to the name of each file, defaults to "_EC" for eyes closed
The constructor can be used as follows to create a patient : 
```python
patient = Patient(name, input_path, output_path, sessions, states, file_format, adds)
```
with all the variables in the constructor representing the attributes described earlier 
#### Functions
The Patient class has several function that can be called on a Patient object.  
The calculate_wpli function calculates the wpli for every epoch of every session for the patient, for the specified parameters, if it has not been done already.  
It has the following parameters: 
- fmin and fmax represent the minimum and maximum frequency of the analysis (for example fmin=8 and fmax=13 for the alpha band)
- channel_order_path represents the path to a csv file containing the desired order of the channels and their associated brain region
- n_windows represents the desired number of analysis widows in each epoch
The calculate_wpli function can be called as follows: 
```python
patient.calculate_wpli(fmin=8, fmax=13, channel_order_path = "path/to/file", n_windows = 300)
```
The calculated wpli matrices will be stored in the output_path of the patient csv files, readable through [pandas.read_csv](https://pandas.pydata.org/docs/reference/api/pandas.read_csv.html?highlight=read_csv)
The plot_wpli function plots all wpli matrices available as color-graded matrices and saves them in the output_path of the patient.  
It can be called as follows : 
```python
patient.plot_wpli()
```
The calculate_debiased_wpli function also calculates wpli for evey epoch of every session of the patient, with the same parameters as the calculate_wpli function, except the channel_order_path is ommited (could be added for functionality later on).  
It can be called as follows: 
```python
patient.calculate_debiased_wpli(fmin=8, fmax=13, n_windows=300)
```
The calculated matrices will also be saved in the output_path of the patient.  
The plot_deb_wpli function is similar to the plot_wpli function, but for debiased wpli. It can be called as follows: 
```python
patient.plot_deb_wpli
```
The calculation of the wpli relies on the mne python library, specifically the [spectral_connectivity module](https://mne.tools/stable/auto_examples/connectivity/plot_sensor_connectivity.html#sphx-glr-auto-examples-connectivity-plot-sensor-connectivity-py)  
### Anticipated future aims
Following are what I believed should be added to be more useful.  
- Support for dPLI and AEC, AEC is already supported by [mne](https://mne.tools/stable/auto_examples/connectivity/plot_mne_inverse_envelope_correlation.html#sphx-glr-auto-examples-connectivity-plot-mne-inverse-envelope-correlation-py)
- Add support for surrogate signal computations
- Maybe add window duration and overlap as parameters for the matrix calculations instead of n_windows
- Add more functionality as needed, [mne](https://mne.tools/stable/index.html) already has a lot of functionality so it would be a good idea to base any code of that if possible.  
### Notes
No other notes at this time.  
Written by Raphaël Christin, raphael.christin@mail.mcgill.ca
