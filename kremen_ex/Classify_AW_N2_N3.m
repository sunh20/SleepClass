%% Function - Classify_AW_N2_N3
%----------------------------------------------------------------------
% About: 
% This function analyzes one day and night of intracranial EEG (iEEG)
% data using Power in Band (PIB) features
% and produces an unsupervised classification into 
% sleep stages - AWAKE, N2, N3.
%
%----------------------------------------------------------------------
% Limitations:
% - It is optimized to work well on at least a day and night of data that
% contain at least several examples (epochs) of balanced sleep profile. 
% Optimal use is for sonsecutive 24 hours (day by day) scoring.
% from each class (AWAKE, N2, N3).
% - It engages median filtering, so it is not able to detect short 
% arrousals.
%
%----------------------------------------------------------------------
% Usage:
% [Scores_by_automata] = Classify_AW_N2_N3(Features)
% Features is a matrix of features of all available iEEG electrodes
%         1st dimension - number of electrodes (must be > 0)
%         2nd dimension - number of epochs for features extracted
%                         in 30 seconds long epochs (recommended > 2880)
%         3rd dimension - vector of PIB features (1..8)
%          
%         3rd dimension assumes PIB features:
%          'Delta Relative';'Theta Relative';'Alpha Relative';
%          'Beta Relative';'30-55Hz Relative';'65-115 Hz Relative';
%          '125-175 Hz Relative';'185-235 Hz Relative'
%
% [Scores_by_automata] - is a vector of scores for each epoch returned
%                        by the algorithm
%                      6 - AWAKE
%                      3 - NREM 2
%                      2 - NREM 3
%                      using a plot(Scores_by_automata) should plot 
%                      a hypnogram like graph where awake is top, NREM3
%                      as deeper sleep is on the bottom
%
%----------------------------------------------------------------------
% Created by: 
% Vaclav Kremen, M.Sc.Eng., Ph.D., MSEL, Mayo Clinic, Rochester, MN, USA
% Kremen.Vaclav@mayo.edu
%----------------------------------------------------------------------
% Copyright (c) 2017-2018, Mayo Foundation for Medical Education 
% and Research (MFMER), All rights reserved. Academic, non-commercial 
% use of this software is allowed with expressed permission of the 
% developers. MFMER and the developers disclaim all implied warranties of 
% merchantability and fitness for a particular purpose with respect 
% to this software, its application, and any verbal or
% written statements regarding its use. The software may not be 
% distributed to third parties without consent of MFMER. 
% Use of this software constitutes acceptance of these terms and 
% acceptance of all risk and liability arising from the software?s use.
% 
% Contributors: Vaclav Kremen, Benjamin Brinkmann, 
% Matt Stead, Jamie Van Gompel, Gregory Worrell.
%----------------------------------------------------------------------