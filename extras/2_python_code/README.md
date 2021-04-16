# Documentation
## Aim
The purpose of this library is to be able to process EEG signals in python instead of matlab. The EEG processing relies heavily on the MNE python library, found [here](https://github.com/mne-tools/mne-python)
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
The wpli.py file introduces the Patient class, which contains information about all the necessary information about a patient. 
It has the following attributes: 
- name : the name/number of the patient, same as the folder that hosts the data
- input_path : the path to the data files of the patient 
   - should be ordered in the following way : input/path/name/session(s)/state(s)  
   the states are .set or .edf files or some other data format  
   there can be many sessions snd states
