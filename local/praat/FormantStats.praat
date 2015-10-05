# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This script attempts to get robust measurements of vowel formants.
#      wren gayle romano <wrengr@indiana.edu>       ~ 2011.04.01
#
# To gain robust measurements we first drop some leading and trailing
# portion of the selected vowel, divide the remaining length into
# a small number of equal width time slices (i.e., 2--5), and compute
# aggregate measurements for each slice. For each measurement we
# take a decent number of samples (e.g., 20) distributed evenly in
# time, and return the mean value and sample standard deviation.
# The reported time for each measurement is given at the middle of
# the slice. In order to be sure that Praat is confident in its
# computation of the formant values, we also track the mean bandwidths
# for each formant and print warnings if the bandwidths for F1 or
# F2 ever goes above 200Hz or 300Hz.
#
# In Praat 5.2.11 we can use real arrays like foo[x] but this feature
# isn't available in older versions of Praat. This is why we use
# pseudo-arrays like foo'x' which take advantage of string interpolation
# and the string-based instead of term-based nature of Praat scripts.
# This offends my programming sensibilities, but what can you do
# eh; Praat is hardly a reasonable programming language.

# ~~~~~ Configurable Parameters
# You can change the defaults here, and change the per-run values
# in the form.
form Statistical formant analysis
    natural  Number_of_measures               3
    natural  Number_of_samples_per_measure    25
    positive Drop_from_start_(%)              0.20
    positive Drop_from_end_(%)                0.25
    
    comment  The maximum formant should vary for males, females, children
    natural  Maximum_formant_(Hz)             5500
    comment  The number of formants may need to vary to ensure good bandwidths
    natural  Number_of_formants               5
    
    comment  These options configure the format of the script output:
    boolean  Clear_info_pane_before_printing  0
    boolean  Print_selection_times            1
    boolean  Print_script_configuration       1
    boolean  Print_column_headers             1
    boolean  Print_raw_samples_(not_measures) 0
endform

# Undo form variable name munging
qtyMeasures           = number_of_measures
qtySamplesPerMeasure  = number_of_samples_per_measure
dropFromStart_percent = drop_from_start
dropFromEnd_percent   = drop_from_end
maxFormant_Hz         = maximum_formant
qtyFormants           = number_of_formants

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# TODO: adjust maxFormant_Hz and qtyFormants (and save the old ones to restore them at the end)

# ~~~~~ Get timing information
selectionTimeStart_s  = Get start of selection
selectionTimeEnd_s    = Get end of selection
selectionTimeLength_s = Get selection length

effectiveTimeStart_s
    ... = selectionTimeStart_s + dropFromStart_percent * selectionTimeLength_s
effectiveTimeEnd_s
    ... = selectionTimeEnd_s - dropFromEnd_percent * selectionTimeLength_s
effectiveTimeLength_s
    ... = effectiveTimeEnd_s - effectiveTimeStart_s
if effectiveTimeLength_s < 0
    exit Error: The effective duration is negative.
        ... The sum of the percent dropped from the start
        ... ('dropFromStart_percent') and the end ('dropFromEnd_percent')
        ... must be less than 1
endif

measureWidth_s = effectiveTimeLength_s / qtyMeasures
sampleWidth_s  = measureWidth_s / qtySamplesPerMeasure


# ~~~~~ Print the configuration and the header for the measurements
if 'clear_info_pane_before_printing'
    clearinfo
endif
if 'print_selection_times'
    duration = 1000 * 'selectionTimeLength_s:6'
    printline #
        ... Selected from 'selectionTimeStart_s' to 'selectionTimeEnd_s'
        ... (duration is about 'duration' ms)
endif
if 'print_script_configuration'
    printline #
        ... qtyMeasures='qtyMeasures'
        ... qtySamplesPerMeasure='qtySamplesPerMeasure' 
        ... dropFromStart_percent='dropFromStart_percent' 
        ... dropFromEnd_percent='dropFromEnd_percent'
        ... maxFormant_Hz='maxFormant_Hz'
        ... qtyFormants='qtyFormants'
endif
if 'print_column_headers'
    if 'print_raw_samples'
        print measure
        print 'tab$'time_s
        print 'tab$'F0_Hz
        print 'tab$'F1_Hz'tab$'F1_BW
        print 'tab$'F2_Hz'tab$'F2_BW
        print 'tab$'F3_Hz'tab$'F3_BW
        print 'tab$'F4_Hz'tab$'F4_BW
        printline
    else
        print time_s
        print 'tab$'mean_F0_Hz'tab$'SD_F0_Hz
        print 'tab$'mean_F1_Hz'tab$'SD_F1_Hz'tab$'mean_F1_BW'tab$'SD_F1_BW
        print 'tab$'mean_F2_Hz'tab$'SD_F2_Hz'tab$'mean_F2_BW'tab$'SD_F2_BW
        print 'tab$'mean_F3_Hz'tab$'SD_F3_Hz'tab$'mean_F3_BW'tab$'SD_F3_BW
        print 'tab$'mean_F4_Hz'tab$'SD_F4_Hz'tab$'mean_F4_BW'tab$'SD_F4_BW
        printline
    endif
endif


# ~~~~~ Compute the measurements
# Sample-standard-deviation estimator for a Gaussian distribution is:
#
#     sampleSigma_X   = sqrt( (sum_{x \in X} (x - X_mean)^2 ) / (|X| + 1) )
#
# Which is different from the standard-deviation estimator for a
# Gaussian distribution (i.e., when you've sampled every point and
# don't need to account for "OOV" sample values), which is:
#
#     standardSigma_X = sqrt( (sum_{x \in X} (x - X_mean)^2 ) / |X| )
#
# A online calculation of SD can be computed by:
#
#    s_j def= sum_{k\in 1..N} (x_k)^j  # N.B. s_0 == N
#
#    sampleSigma_X   = sqrt( (s_0*s_2 - (s_1)^2)/(s_0 * (s_0-1)) )
#    standardSigma_X = sqrt( (s_0*s_2 - (s_1)^2)/(s_0 * s_0) )
#                      == (s_0)^{-2} * sqrt(s_0*s_2 - (s_1)^2)
#
# But this is succeptible to rounding error, overflow, and underflow.
# So, to be more accurate we perform that calculation as:
#
#    A_0 = 0
#    A_i = A_{i-1} + 1/i * (x_i - A_{i-1})
#    mean = A_n
#
#    Q_0 = 0
#    Q_i = Q_{i-1} + (i-1)/i * (x_i - A_{i-1})^2
#          == Q_{i-1} + (x_i - A_{i-1}) * (x_i - A_i)
#    sampleSigma   = sqrt( 1/(n-1) * Q_n )
#    standardSigma = sqrt( 1/n     * Q_n )
#
# We could also try using the commands:
#
#     select Formant hallo
#     mean = Get mean... {formant number} {start time (s)} {end time (s)} Hertz
#     sd = Get standard deviation... {formant} {start} {stop} Hertz
#
#     pitch = Get mean... 0 0 Hertz Parabolic

for m from 1 to qtyMeasures
    qtyUndefined_Hz_of_F0 = 0
    for f from 0 to 4
        mean_Hz_of_F'f' = 0
        q_Hz_of_F'f'    = 0
    endfor
    for f from 1 to 4
        mean_BW_of_F'f' = 0
        q_BW_of_F'f'    = 0
    endfor
    for f from 1 to 2
        qtyCautions_BW_of_F'f' = 0
        qtyWarnings_BW_of_F'f' = 0
    endfor
    for s from 1 to qtySamplesPerMeasure
        time = effectiveTimeStart_s
             ... + ((m-1) * measureWidth_s) + ((s-1) * sampleWidth_s)
        Move cursor to... 'time'
        # TODO: how to keep from redrawing every time?
        if 'print_raw_samples'
            print 'm''tab$''time'
        endif
        
        ## Would this work?
        # if f == 0
        #     sample = Get pitch
        #     if sample = undefined
        #         qtyUndefined_Hz_of_F0 = qtyUndefined_Hz_of_F0 + 1
        #     else
        #         if 'print_raw_samples'
        #             print 'tab$''sample'
        #         else
        #             old_mean_Hz_of_Ff = mean_Hz_of_F'f'
        #
        #             mean_Hz_of_F'f'   = mean_Hz_of_F'f'
        #                 ... + ((sample - mean_Hz_of_F'f')
        #                 ... / (s - qtyUndefined_Hz_of_F0))
        #
        #             q_Hz_of_F'f' = q_Hz_of_F'f'
        #                 ... + ((sample - old_mean_Hz_of_Ff)
        #                 ... * (sample - mean_Hz_of_F'f'))
        #         endif
        #     endif
        # else
        #     {...}
        # endif
        # {...}
        # if f == 0
        #     mean_Hz = mean_Hz_of_F'f'
        #     print 'tab$''mean_Hz:0'
        #     sd_Hz = sqrt (q_Hz_of_F'f'
        #         ... / (qtySamplesPerMeasure - 1 - qtyUndefined_Hz_of_F0))
        #     print 'tab$''sd_Hz:2'
        # else
        #     {...}
        # endif
            
        for f from 0 to 4
            if f == 0
                sample = Get pitch
                if sample = undefined
                    # TODO: find some way still average the rest of them (cleanly)
                    qtyUndefined_Hz_of_F0 = qtyUndefined_Hz_of_F0 + 1
                endif
            else
                sample = Get formant... 'f'
            endif
            
            if 'print_raw_samples'
                print 'tab$''sample'
            else
                old_mean_Hz_of_Ff = mean_Hz_of_F'f'
                mean_Hz_of_F'f'   = mean_Hz_of_F'f'
                                  ... + ((sample - mean_Hz_of_F'f') / s)
                q_Hz_of_F'f'      = q_Hz_of_F'f'
                                  ... + ((sample - old_mean_Hz_of_Ff)
                                  ... * (sample - mean_Hz_of_F'f'))
            endif
            
            if f > 0
                bandwidth = Get bandwidth... 'f'
                             
                if 'print_raw_samples'
                    print 'tab$''bandwidth'
                else
                    old_mean_BW_of_Ff = mean_BW_of_F'f'
                    mean_BW_of_F'f'   = mean_BW_of_F'f'
                                      ... + ((bandwidth - mean_BW_of_F'f') / s)
                    q_BW_of_F'f'      = q_BW_of_F'f'
                                      ... + ((bandwidth - old_mean_BW_of_Ff)
                                      ... * (bandwidth - mean_BW_of_F'f'))
                endif
                
                if f == 1 or f == 2
                    if bandwidth > 200
                        if bandwidth > 300
                            qtyWarnings_BW_of_F'f' =
                                ... qtyWarnings_BW_of_F'f' + 1
                        else
                            qtyCautions_BW_of_F'f' =
                                ... qtyCautions_BW_of_F'f' + 1
                        endif
                    endif
                endif
            endif
        endfor
        if 'print_raw_samples'
            printline
        endif
    endfor
    
    if 'print_raw_samples'
        # Do nothing
    else
        time = effectiveTimeStart_s + ((m-1 + 0.5) * measureWidth_s)
        print 'time'
        
        for f from 0 to 4
            mean_Hz = mean_Hz_of_F'f'
            print 'tab$''mean_Hz:0'
            
            sd_Hz = sqrt( q_Hz_of_F'f' / (qtySamplesPerMeasure - 1) )
            print 'tab$''sd_Hz:2'
            
            if f > 0
                mean_BW = mean_BW_of_F'f'
                print 'tab$''mean_BW:0'
                
                sd_BW = sqrt( q_BW_of_F'f' / (qtySamplesPerMeasure - 1) )
                print 'tab$''sd_BW:2'
            endif
        endfor
        printline
    endif
    
    if qtyUndefined_Hz_of_F0 > 0
        printline # Warning:
                ... The fundamental frequency is undefined
                ... for 'qtyUndefined_Hz_of_F0'
                ... of 'qtySamplesPerMeasure' samples.
    endif
    for f from 1 to 2
        if qtyWarnings_BW_of_F'f' > 0
            qtyWarnings = qtyWarnings_BW_of_F'f'
            printline # Warning:
                ... The bandwidth of formant 'f' is over 300
                ... for 'qtyWarnings' of 'qtySamplesPerMeasure' samples.
        endif
        if qtyCautions_BW_of_F'f' > 0
            qtyCautions = qtyCautions_BW_of_F'f'
            printline # Caution:
                ... The bandwidth of formant 'f' is over 200 (but below 300)
                ... for 'qtyCautions' of 'qtySamplesPerMeasure' samples.
        endif
    endfor
endfor
printline

# ~~~~~ Reset the selection
Select... 'selectionTimeStart_s' 'selectionTimeEnd_s'
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
