# PVM-profiler
simple, unpolished Fiji script to meassure T. gondii PVM fluorescence intensity.

## Goal of the script
Fluorescence intensity at the T. gondii PVM is usually meassured manually by drawing to line profiles through the PV and taking the mean of all peaks substracted by the background, which is defined as the average fluorescence before the peak. This method was described by Khaminets et al. 2010 (doi.org/10.1111/j.1462-5822.2010.01443.x). This is a labor intensive process, since every point has to be manually marked and the intensity values entered into excel or some other calculation software. 
With this software I automated the identification of the PVM peaks and the background after drawing the line profile in a macro for Fiji

## Features
* Automatic recognition of the left and right peak of the line profile
* Automatic calculation of the background fluorescence intensity
* Option to correct peaks and background
* Automatic copy of determined values to the system clipboard, ready to be pasted to excel for further calculation


## Usage
1. Install Fiji with Imagej 1.53c (other versions and ImageJ alone might also work)
2. Go to Plugins -> Macros -> Install and select PVM_profiler.ijm
Shortcuts q, c and v are now bound by macros from this script. You might need to change the binding in the .ijm file if you need these keys
3. Open an image containing PVMs and switch to you channel of interest
4. Select the line tool
I recomment double clicking the tool and selecting a line width of 3. This averages the profile over 3 pixel.
5. Draw a line through a PV. Take care that the middle of the line is in the middle of the PVM and leave some space left and right of the PVM
! Caution: Your clipboard will be filled with data without asking, so make sure to have nothing important in there
6. Press q. The script now open the profile plot and analyses it. The analysis is done in a fairly simple (and maybe a bit messy) way, but for me so far it worked well
7. The peaks are marked with red bars and the background with blue bars. If you are happy with the results switch over to your table program of choice and paste the values. The script copies the file name, a timestamp, the left background, left peak, right peak, right background and the average fluorecence substracted by the backgrounds in that order seperated by tabs.
8. If you are not happy you can adjust the peak positions with "c" and the backgrounds with "v". The new values are then automatically in your clipboard
