# Consciousness-Graph
Repository for the study of consciousness using graph theory  
## Project aim  
Comparing between different ways to build a graph for the graph-theoretical analysis of patients undergoing propofol-induced anesthesia. 
## Dataset
- 9 Healthy adult undergoing anesthesia and recovering : [subset of this bigger study](https://pubmed-ncbi-nlm-nih-gov.proxy3.library.mcgill.ca/28638328/)

## Graphs Studied
- Amplitude Enveloppe Correlation
- Weighted Phase Lag Index
- Directed Phase Lag Index

Each of these graphs will go through the following transformation:
- Keep the top X% of connection
- Minimal Spanning Graph of top connections
- Orthogonal Minimum Spanning Tree thresholding

## Phase 1 of the project:
Describe statistically the difference in the following feature for the graphs studied:
- global efficiency
- clustering coefficient
- modularity
- small worldness

over the following epochs:
- Baseline
- Induction of the anesthetic protocol
- Unconscioussness
- -5 minutes before recovery of consciousness
- +30 minutes after recovery of consciousness
- +60 minutes after recovery of consciousness
- +90 minutes after recovery of consciousness
- +120 minutes after recovery of consciousness
- +150 minutes after recovery of consciousness
- +180 minutes after recovery of consciousness

see the [preprint titled Brain network motifs are markers of loss and recovery of consciousness](https://www.biorxiv.org/content/10.1101/2020.03.16.993659v1.full) for more information on both the participants and the calculation of these features.

## Significance
The graph that best describe awareness is a permutation of these parameter. By doing a search in this space using a model we will be able to create this graph that may or may not be an hybrid of different graphs type. This graph can then be used in patient with a disorder of consciousness undergoing the same anesthethic pertubration protocol to characterize their awareness state. This is important because in this population the standard is to use behavioral sign of awareness to assess its presence.

## Using the code
