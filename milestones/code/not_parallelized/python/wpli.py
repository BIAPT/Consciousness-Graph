import mne
from mne.connectivity import spectral_connectivity
import matplotlib
import matplotlib.pyplot as plt
import numpy
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
        self.input_path = input_path + '/' + name
        self.output_path = output_path + '/' + name
        self.sessions = sessions
        self.states = states
        self.file_format = file_format
        self.wpli_freqs = []
        self.wpli_plot_freqs = []
        self.dpli_freqs = []
        self.dpli_plot_freqs = []
        self.aec_freqs = []
        self.aec_plot_freqs = []

    def calculate_wpli(self, fmin, fmax, channel_order_path):
        #calculate wpli if not already done
        if [fmin, fmax] not in self.wpli_freqs:
            #set channel order and regions
            channels = pandas.read_csv(channel_order_path)
            channel_order = channels['label'].to_list()
            channel_region = channnels['region'].to_list()

            for session in self.sessions:
                #iterate through sesions
                for state in self.states:
                    #iterate through states
                    #load the data
                    file_path = self.input_path + '/' + session + '/' + state + self.file_format
                    if self.file_format == '.set': raw_data = mne.io.read_raw_eeglab(file_path, preload = False, uint16_codec = 'utf-8').reorder_channels(channel_order)
                    elif self.file_format == '.edf': raw_data = mne.io.read_raw_edf(file_path, preload = False, uint16_codec = 'utf-8').reorder_channels(channel_order)
                    events = mne.find_events(raw_data, shortest_event = 1)
                    epochs = mne.Epochs(raw_data, events)
                    sfreq = raw_data['sfreq']
                    epochs.load_data()
                    #compute the matrix
                    wpli, freqs, times, n_epochs, n_tapers = spectral_connectivity(epochs, method='wpli', mode='multitaper', sfreq = sfreq, fmin=fmin, fmax=fmax)
                    #save the matrix
                    wpli_df = pandads.DataFrame(wpli)
                    #create indexes
                    ind = pandas.Index(channel_region)
                    wpli_df.set_axis(ind, axis = 0)
                    wpli_df.set_axis(ind, axis = 1)
                    #save dataframe
                    wpli_df.to_csv(self.output_path + '/' + session + '/' + state + '_' + fmin + '-' + fmax + '.csv')

            # update wpli freqs list
            self.wpli_freqs.append([fmin, fmax])
            return True
        else :
            return True

    def get_wpli(self, fmin, fmax, session, state):
        #return wpli matrix as pandas DataFrame
        if [fmin, fmax] in self.wpli_freqs:
            return pandas.read_csv(self.output_path + '/' + session + '/' + state + '_' + fmin + '-' + fmax + '.csv')
        else :
            return None

    def plot_wpli(self):
        #plot all the available wpli matrices
        for session in self.sessions:
            #iterate through sesions
            for state in self.states:
                #iterate through states
                for [fmin, fmax] in self.wpli_freqs :
                    #load the data
                    wpli_df = pandas.read_csv(self.output_path + '/' + session + '/' + state + '_' + fmin + '-' + fmax + '.csv')
                    regions = wpli_df.index.to_list()
                    matrix = wpli_df.as_matrix()
                    #create plot

                    fig, ax = plt.subplots()
                    im = ax.imshow(matrix)

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
                    ax.set_title("wpli matrix of " + self.name + ", session " + session + ", "  + state ', ' + fmin + '-' + fmax + ' Hz')
                    #plot and save
                    fig.tight_layout()
                    plt.savefig(self.output_path + '/' + session + '/' + state + '_' + fmin + '-' + fmax + '.png')
