## Plan for the project
We will be scoping down this project in term of uncertainty.

## Goal
Describe the functional graph of awareness. 

To do so we will use anesthesia as a perturbator to disrupt awareness in healthy participant. We will then create a model able to be fed different graphs and learning from their characteristic the most important feature for detecting awareness state (i.e. resting state, loss-of-consciousness, pre-recovery of consciousness, recovery of consciousness). The most useful feature will then be used to create a graph of awareness.

## Dataset
- 9 Healthy adult undergoing anesthesia and recovering : [subset of this bigger study](https://pubmed-ncbi-nlm-nih-gov.proxy3.library.mcgill.ca/28638328/)

## Graphs Studied
- Amplitude Enveloppe Correlation
- Weighted Phase Lag Index
- Directed Phase Lag Index

Each of these graphs can go through the following transformation:
- identiy (No transformation)
- Keep the top X% of connection
- Keep the lower X% of connection
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
- Unconsciouss
- -30 minutes before recovery of consciousness
- -10 minutes before recovery of consciousness
- -5 minutes before recovery of consciousness
- +30 minutes after recovery of consciousness
- +30 minutes after recovery of consciousness

see the [preprint titled Brain network motifs are markers of loss and recovery of consciousness](https://www.biorxiv.org/content/10.1101/2020.03.16.993659v1.full) for more information on both the participants and the calculation of these features.

To start we will only look at **one** graph with **one** transformation:
- dpli with the identity transformation (no transformation)

Once the pipeline will be working well for this one graph this is when we can do the permutation between the different graphs and the transformation to search the space for the optimal graph of awareness.

## Phase 2


## Significance
The graph that best describe awareness is a permutation of these parameter. By doing a search in this space using a model we will be able to create this graph that may or may not be an hybrid of different graphs type. This graph can then be used in patient with a disorder of consciousness undergoing the same anesthethic pertubration protocol to characterize their awareness state. This is important because in this population the standard is to use behavioral sign of awareness to assess its presence.
