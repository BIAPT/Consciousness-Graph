import mne
from mne.connectivity import spectral_connectivity
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pandas

class Patient:
    # class to store and structure the patients
    # it has the following attributes:
    # name : the name/number of the patient, same as the folder that hosts the data
    # input_path : the path to the data files of the patient
    #              should be ordered in the following way : input/path/name/session(s)/state(s)
    #              the states are .set or .edf files or some other data format
    #              there can be many sessions snd states
    # output_path : output path for the computations on the data
    # sessions : list of the sessions that the patient went through, ordered in folders of the same name as specified in the input_path
    # states : list of the states in each session, stored as files of the same name in the path
    # file_format : format of the state files
    # wpli dpli and aec are boolean variable to keep track of if the corresponding matrices have been computed

    def __init__(self, name, input_path, output_path, sessions, states, file_format, adds="_EC"):
        #set up the patient data
        self.name = name
        self.input_path = input_path
        self.output_path = output_path
        self.sessions = sessions
        self.states = states
        self.file_format = file_format
        self.adds = adds
        self.wpli_freqs = []
        self.wpli_plot_freqs = []
        self.deb_wpli_freqs = []
        self.deb_wpli_plot_freqs = []
        self.dpli_freqs = []
        self.dpli_plot_freqs = []
        self.aec_freqs = []
        self.aec_plot_freqs = []

    def calculate_wpli(self, fmin, fmax, channel_order_path, n_windows):
        #calculate wpli if not already done
        if [fmin, fmax] not in self.wpli_freqs:
            #set channel order and regions
            channels = pandas.read_csv(channel_order_path, sep=r'\s*,\s*')
            channel_order = channels['label'].to_list()

            for session in self.sessions:
                #iterate through sesions
                for state in self.states:
                    #iterate through states
                    #set correct path
                    file_path = self.input_path + '/' + session + '/' + self.name + \
                        "_" + session + "_" + state + self.adds + self.file_format

                    #load the data
                    if self.file_format == '.set': raw_data = mne.io.read_raw_eeglab(file_path, preload=False, uint16_codec='utf-8')
                    elif self.file_format == '.edf': raw_data = mne.io.read_raw_edf(file_path, preload=False)
                    
                    # drop unnecessary channels

                    for i in channel_order:
                        if i not in raw_data.ch_names:
                            channels = channels[channels.label != i]

                    #reload channel order and region
                    channel_order = channels['label'].to_list()
                    channel_region = channels['region'].to_list()

                    #reorder channels 

                    raw_data = raw_data.reorder_channels(channel_order)

                    #setup for wpli
                    #events = mne.find_events(raw_data, stim_channel = 'Cz')
                    sfreq = raw_data.info['sfreq']
                    cwt_freqs = np.arange(8,14)
                    cwt_n_cycles = 1
                    step_size = raw_data.n_times/n_windows/sfreq #get step size according to number of windows
                    overlap = 10.0 - step_size
                    events = mne.make_fixed_length_events(raw_data, duration=10.0, overlap=overlap)
                    epochs = mne.Epochs(raw_data, events)
                    #channels_array = np.array(channel_order)
                    #, indices = (channels_array, channels_array)
                    epochs.load_data()
                    #compute the matrix
                    wpli, freqs, times, n_epochs, n_tapers = spectral_connectivity(
                        epochs, method='wpli', mode='fourier', cwt_freqs=cwt_freqs, cwt_n_cycles=cwt_n_cycles,
                        sfreq=sfreq, fmin=fmin, fmax=fmax, tmin=0.0)
                    #save the matrix
                    #wpli_avg = wpli
                    wpli_avg = avg_mats(wpli)
                    wpli_complete = wpli_avg + wpli_avg.T
                    
                    wpli_df = pandas.DataFrame(wpli_complete)
                    #create indexes
                    ind = pandas.Index(channel_region)
                    wpli_df.set_axis(ind, axis = 0, inplace = True)
                    wpli_df.set_axis(ind, axis = 1, inplace = True)
                    
                    
                    wpli_df.to_csv(self.output_path + '/' + self.name + '/'+ session + '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')
                    

            # update wpli freqs list
            self.wpli_freqs.append([fmin, fmax])
            #print(wpli_df.to_numpy().max())
            return True
        else :
            return True

    def get_wpli(self, fmin, fmax, session, state):
        #return wpli matrix as pandas DataFrame
        if [fmin, fmax] in self.wpli_freqs:
            
            return pandas.read_csv(self.output_path + '/' + self.name + '/' + session + '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')
        else :
            return None

    def plot_wpli(self, windows = True):#works 
        #plot all the available wpli matrices
        for session in self.sessions:
            #iterate through sesions
            for state in self.states:
                #iterate through states
                for [fmin, fmax] in self.wpli_freqs :
                    #load the data
                    
                    wpli_df = pandas.read_csv(self.output_path + '/' + self.name + '/' +
                                        session + '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')

                    wpli_df = wpli_df.set_index('Unnamed: 0')
                    #print(wpli_df.head())
                    
                    regions = wpli_df.index.to_list()
                    matrix = wpli_df.to_numpy()
                    #print(matrix)
                    #create plot

                    fig, ax = plt.subplots()
                    norm = matplotlib.cm.colors.Normalize(vmax=matrix.max(), vmin=matrix.min())
                    im = ax.imshow(np.real(matrix), cmap=matplotlib.cm.jet, norm = norm)

                    #create colorbar
                    cbar = ax.figure.colorbar(im, ax = ax)
                    

                    # We want to show all ticks...
                    ax.set_xticks(np.arange(len(regions)))
                    ax.set_yticks(np.arange(len(regions)))
                    # ... and label them with the respective list entries
                    ax.set_xticklabels(regions)
                    ax.set_yticklabels(regions)

                    # Rotate the tick labels and set their alignment.
                    plt.setp(ax.get_xticklabels(), rotation=45, ha="right", rotation_mode="anchor")
                    #set title
                    ax.set_title("wpli matrix of " + self.name + ", session " + session + ", "  + state + ', ' + str(fmin) + '-' + str(fmax) + ' Hz')
                    #plot and save
                    fig.tight_layout()
                    plt.savefig(self.output_path + '/' + self.name + '/' + session +
                                '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.png')


    def calculate_debiased_wpli(self, fmin, fmax, n_windows):
       #calculate deb_wpli if not already done
       if [fmin, fmax] not in self.deb_wpli_freqs:
            #set channel order and regions
            #channels = pandas.read_csv(channel_order_path, sep=r'\s*,\s*')
            #channel_order = channels['label'].to_list()

            for session in self.sessions:
                #iterate through sesions
                for state in self.states:
                    #iterate through states
                    #set correct path
                    file_path = self.input_path + '/' + session + '/' + self.name + \
                        "_" + session + "_" + state + self.adds + self.file_format

                    #load the data
                    if self.file_format == '.set':
                        raw_data = mne.io.read_raw_eeglab(
                            file_path, preload=False, uint16_codec='utf-8')
                    elif self.file_format == '.edf': raw_data = mne.io.read_raw_edf(file_path, preload=False)

                    # drop unnecessary channels

                    #for i in channel_order:
                        #if i not in raw_data.ch_names:
                            #channels = channels[channels.label != i]

                    #reload channel order and region
                    #channel_order = channels['label'].to_list()
                    #channel_region = channels['region'].to_list()

                    #reorder channels

                    #raw_data = raw_data.reorder_channels(channel_order)

                    #setup for wpli
                    #events = mne.find_events(raw_data, stim_channel = 'Cz')
                    sfreq = raw_data.info['sfreq']
                    #cwt_freqs = np.arange(8, 14)
                    #cwt_n_cycles = 1
                    # get step size according to number of windows
                    step_size = raw_data.n_times/n_windows/sfreq
                    overlap = 10.0 - step_size
                    events = mne.make_fixed_length_events(
                        raw_data, duration=10.0, overlap=overlap)
                    epochs = mne.Epochs(raw_data, events)
                    #channels_array = np.array(channel_order)
                    #, indices = (channels_array, channels_array)
                    epochs.load_data()
                    #compute the matrix
                    deb_wpli, freqs, times, n_epochs, n_tapers = spectral_connectivity(
                        epochs, method='wpli2_debiased', mode='fourier',
                        sfreq=sfreq, fmin=fmin, fmax=fmax, tmin=0.0)
                    #save the matrix
                    #wpli_avg = wpli
                    deb_wpli_avg = avg_mats(deb_wpli)
                    deb_wpli_complete = deb_wpli_avg + deb_wpli_avg.T

                    deb_wpli_df = pandas.DataFrame(deb_wpli_complete)
                    #create indexes
                    #ind = pandas.Index(channel_region)
                    #wpli_df.set_axis(ind, axis=0, inplace=True)
                    #wpli_df.set_axis(ind, axis=1, inplace=True)

                    deb_wpli_df.to_csv(self.output_path + '/' + self.name + '/' + session +
                                   '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')

            # update wpli freqs list
            self.deb_wpli_freqs.append([fmin, fmax])
            #print(wpli_df.to_numpy().max())
        
            return True


    def plot_deb_wpli(self, windows = True):#works 
        #plot all the available wpli matrices
        for session in self.sessions:
            #iterate through sesions
            for state in self.states:
                #iterate through states
                for [fmin, fmax] in self.deb_wpli_freqs :
                    #load the data
                    
                    deb_wpli_df = pandas.read_csv(self.output_path + '/' + self.name + '/' +
                                        session + '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')

                    deb_wpli_df = deb_wpli_df.set_index('Unnamed: 0')
                    #print(wpli_df.head())
                    
                    #regions = wpli_df.index.to_list()
                    matrix = deb_wpli_df.to_numpy()
                    x,y = matrix.shape
                    #print(matrix)
                    #create plot

                    fig, ax = plt.subplots()
                    norm = matplotlib.cm.colors.Normalize(vmax=0.1, vmin=-0.1)
                    im = ax.imshow(np.real(matrix), cmap=matplotlib.cm.jet, norm = norm)

                    #create colorbar
                    cbar = ax.figure.colorbar(im, ax = ax)
                    

                    # We want to show all ticks...
                    ax.set_xticks(np.arange(x))
                    ax.set_yticks(np.arange(y))
                    # ... and label them with the respective list entries
                    #ax.set_xticklabels(regions)
                    #ax.set_yticklabels(regions)

                    # Rotate the tick labels and set their alignment.
                    #plt.setp(ax.get_xticklabels(), rotation=45, ha="right", rotation_mode="anchor")
                    #set title
                    ax.set_title("debiased wpli matrix of " + self.name + ", session " + session + ", "  + state + ', ' + str(fmin) + '-' + str(fmax) + ' Hz')
                    #plot and save
                    fig.tight_layout()
                    plt.savefig(self.output_path + '/' + self.name + '/' + session +
                                '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.png')




def avg_mats(wpli):
    if len(wpli.shape) == 4:
        x,y,z,w = wpli.shape
        w = int(w)
    else:
        x, y, z = wpli.shape
    x = int(x)
    y = int(y)
    z = int(z)
    wpli_sum = np.zeros((x, y))
    if len(wpli.shape) == 4:
        for i in range(z):
            for j in range(w):
                wpli_sum += wpli[:,:,i,j]
        
        return wpli_sum / (w*z)

    else:
        for i in range(z):
            wpli_sum += wpli[:, :, i]
        
        return wpli_sum / z
        
    
