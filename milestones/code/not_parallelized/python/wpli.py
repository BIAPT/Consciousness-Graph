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

    def __init__(self, name, input_path, output_path, sessions, states, file_format):
        #set up the patient data
        self.name = name
        self.input_path = input_path
        self.output_path = output_path
        self.sessions = sessions
        self.states = states
        self.file_format = file_format
        self.wpli_freqs = []
        self.wpli_plot_freqs = []
        self.dpli_freqs = []
        self.dpli_plot_freqs = []
        self.aec_freqs = []
        self.aec_plot_freqs = []

    def calculate_wpli(self, fmin, fmax, channel_order_path, windows = True):#does not work, produces a triangular matrix
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
                    if windows : file_path = self.input_path + '\\' + session + '\\' + self.name + "_" + session + "_" + \
                        state + "_EC" + self.file_format
                    else:
                        file_path = self.input_path + '/' + session + '/' + self.name + \
                            "_" + session + "_" + state + "_EC" + self.file_format

                    #load the data
                    if self.file_format == '.set': raw_data = mne.io.read_raw_eeglab(file_path, preload = False, uint16_codec = 'utf-8')
                    elif self.file_format == '.edf': raw_data = mne.io.read_raw_edf(file_path, preload = False)
                    
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
                    events, event_ids = mne.events_from_annotations(raw_data)
                    epochs = mne.Epochs(raw_data, events)
                    sfreq = raw_data.info['sfreq']
                    epochs.load_data()
                    #compute the matrix
                    wpli, freqs, times, n_epochs, n_tapers = spectral_connectivity(epochs, method='wpli', mode='fourier', sfreq = sfreq, fmin=fmin, fmax=fmax)
                    #save the matrix
                    wpli_avg = avg_mats(wpli)
                    wpli_df = pandas.DataFrame(wpli_avg)
                    #create indexes
                    ind = pandas.Index(channel_region)
                    wpli_df.set_axis(ind, axis = 0, inplace = True)
                    wpli_df.set_axis(ind, axis = 1, inplace = True)
                    
                    if windows : 
                        wpli_df.to_csv(self.output_path + '\\' + self.name + '\\' + session + '\\' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')
                    else:
                        wpli_df.to_csv(self.output_path + '/' + self.name + '/'+ session + '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')
                    

            # update wpli freqs list
            self.wpli_freqs.append([fmin, fmax])
            return True
        else :
            return True

    def get_wpli(self, fmin, fmax, session, state, windows = True):
        #return wpli matrix as pandas DataFrame
        if [fmin, fmax] in self.wpli_freqs:
            if windows : 
                return pandas.read_csv(self.output_path + '\\' + self.name + '\\' + session + '\\' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')
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
                    if windows : 
                        wpli_df = pandas.read_csv(self.output_path + '\\' + self.name + '\\' +
                                                  session + '\\' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')
                    
                    else :
                        wpli_df = pandas.read_csv(self.output_path + '/' + self.name + '/' +
                                                  session + '/' + state + '_' + str(fmin) + '-' + str(fmax) + '.csv')

                    wpli_df = wpli_df.set_index('Unnamed: 0')
                    #print(wpli_df.head())
                    
                    regions = wpli_df.index.to_list()
                    matrix = wpli_df.to_numpy()
                    #print(matrix)
                    #create plot

                    fig, ax = plt.subplots()
                    im = ax.imshow(np.real(matrix))

                    #create colorbar
                    cbar = ax.figure.colorbar(im, ax = ax, cmap = 'cividis')

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




def avg_mats(wpli):
    x, y, z = wpli.shape
    x = int(x)
    y = int(y)
    z = int(z)
    wpli_sum = np.zeros((x, y))
    for i in range(z):
        wpli_sum += wpli[:, :, i]
        
    return wpli_sum / z
