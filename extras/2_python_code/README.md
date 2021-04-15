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
sys.path.append(os.path.abspath("path/to/wpli.py"))
import wpli
```
This will import the code contained in wpli.py for further usage  
One also needs to have the mne python library installed. Instructions to install mne can be found at the mne [github](https://github.com/mne-tools/mne-python)
### Available functions and class

