# Prairie-Ultima-IV-image-batch-processing
FIJI/ImageJ Macro for sorting batch of stacks acquired from Praire Ultima IV two-photon microscopes.

The macro is needed to sort the stack of images acquired with Praire Ultima IV systems into a useful set of data to be visualised with TrackEM2 FIJI plugin.

To use it simply copy the file into /macro subfolder and install it via the macro drop down menu option "install".

This macro batch processes all the files in a folder and any subfolders in that folder. Use it to process a session/timepoint (_a, _b, etc.). It saves its output in two subfolders called "Processed_Max_Projections" and "Stitching_ready_tiffs" (divided into four zoom subfolders, 40x only). It gets the filename, x, y and z coordinates (together with some other values) from the .xml metadata file in the ROI subfolder and stores these values as a comma separated list text file named "CoordinatesZ(n).txt" in each zoom folder. It  saves the single plane images sequentially, makes the MAX projection, converts all to 8-bit and finally saves them. The dialog at the beginning sets wether to run the StackReg plugin to align the images in the stack and/or to filter them (Median filter pixel value 1). 

The vesion 5 does not write the ROI number at the four corners leaving the images unaltered. Please refer to the "How to use Stitching macro.txt" file for a guide on how to use the output of this macro to get 3D mosaics.

The version 6 also writes the zoom value and the ROI number at the four corners of the images ready to be stitched. Please note that it actually draws these information on the image, so in this extent it is "destructive" macro.

Please refer to the "How to use Stitching macro.txt" file for a guide on how to use the output of this macro to get 3D mosaics.
