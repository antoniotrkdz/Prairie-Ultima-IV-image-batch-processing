
macro "Nostromo v6" {

// "Batch MAX Align and Process Folders and Subfolders" Antonio Trabalza - MRC - 2015
//
// Refer to the individual macro file for more info.

// For other kinds of processing,
// edit the processFile() function at the end of this macro.
   
   // requires("1.44e"); // classic ImageJ compatibility.
   if (nImages() > 0) exit("ERROR ! Before starting, please close all image windows !");
   // Checks that no image windows are open.
   srcDir = getDirectory("Choose a Directory ");
   trgDir = srcDir + "Stitching_ready_tiffs";
   trgDir2 = srcDir + "Processed_MAX_Projections";
   if (File.exists(trgDir) || (trgDir2))
   exit("ERROR ! Destination directories already exist; if you relly want, remove them and then run this macro again"); 
   File.makeDirectory(trgDir);
   File.makeDirectory(trgDir2);   
   setBatchMode(true);
   run("Bio-Formats Macro Extensions");
   Dialog.create("Options");
  	Dialog.addCheckbox("StackReg", true);
  	Dialog.addCheckbox("Median Filter", true);
  	Dialog.show();
   	align = Dialog.getCheckbox();
   	filter = Dialog.getCheckbox();
   count = 0;
   countFiles(srcDir);
   n = 0;
   processFiles(srcDir);
   //print(count+" files processed");
   
   function countFiles(srcDir) {
      list = getFileList(srcDir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], File.separator))
              countFiles(""+srcDir+list[i]);
          else
              count++;
      }
  }

   function processFiles(srcDir) {
      list = getFileList(srcDir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], File.separator))
              processFiles(""+srcDir+list[i]);
          else {
             showProgress(n++, count);
             path = srcDir+list[i];
             processFile(path);
          }
      }
  }
  
  function processFile(path) {
   
   // zoom value is stored in row 57 as per "1", "2", etc. 	
   // Zoom 1 = microns per pixels: 0.588235294117647
   // Zoom 2 = microns per pixels: 0.294067245037119
   // Zoom 3 = microns per pixels: 0.196038609069362
   // Zoom 4 = microns per pixels: 0.147027323885178
   
   if (endsWith(path, ".ome.tif")) {
	   
	   id = File.getName(path); 
	   newMAXname = "MAX_" + substring(id,0,indexOf(id,"_Cycle"))+".tif";
	   ROIname = substring(id,(lastIndexOf(id,"-0")+2),indexOf(id,"_Cycle"));
	   //newMAXname ="MAX_" + substring(id,0,lastIndexOf(id,".xml")) +".tif";
	
	   if (!File.exists(trgDir2 + File.separator + newMAXname ) && !File.exists(trgDir + File.separator + id)) {
	   	run("Bio-Formats Importer", "open=[" + path + "] color_mode=Default open_all_series view=[Standard ImageJ] stack_order=Default");
	   	//run("Image Sequence...", "open=[" + path + "] number=count starting=1 increment=1 scale=100 file=[] or=[] sort");
		if(nSlices > 1){
	   	if (align==true) run("StackReg", "transformation=[Rigid Body]"); // for classic ImageJ compatibility add a space after StackReg.
		
		// Uses Bio-Formats to print the chosen file's metadata to the Log.

    	// !!!!!IMPORTANT!!!!!
		// It DOESN'T work with Bio-Formats versions 5.1.0 and 5.1.1 !!!
	   	// Use either 5.0.8 or 5.1.2 (relased 28 May 2015).

	   	  Ext.setId(path);
		  Ext.getImageCount(imageCount);
		  positionX = newArray(imageCount);
		  positionY = newArray(imageCount);
		  positionZ = newArray(imageCount);
		  used_path = newArray(imageCount);
		  		  
		  Ext.getPixelsPhysicalSizeX(pxsize); //Gets the microns per pixels value.
  		  
		  //px=toString(pxsize,9); // (DEBUG) max usable decimal positions. 
		  //print(px);
		  //pxf = parseFloat(px);
		  
		  zoomDir = newArray("Zoom1", "Zoom2", "Zoom3", "Zoom4+");
		  for (z=0; z<zoomDir.length; z++) {
		    if (!File.exists(trgDir + File.separator + zoomDir[z]))
		       File.makeDirectory(trgDir + File.separator + zoomDir[z]);
			}
		  for (no=0; no<imageCount; no++) {
  	  		Ext.getSizeX(sizeX);
			Ext.getSizeY(sizeY);
			Ext.getPlanePositionX(positionX[no], no);
  	  		Ext.getPlanePositionY(positionY[no], no);
  	  		Ext.getPlanePositionZ(positionZ[no], no);
  	  		pixsX = (positionX[no]/pxsize); // Conversion of the micron coordinates in pixel coordinates.
  	  		//invY = (positionY[no] * -1); // Inversion of coordinates.
  	  		inv_pixsY = ((positionY[no]/pxsize)* -1); // Conversion and Inversion.
  	  		r_pixsZ = round((positionZ[no]/pxsize)); // Rounding and Conversion.
  	  		//round_Z = round(positionZ[no]); // Rounding.
  	  		
  	  		Ext.getUsedFile(no, used_path[no]); // Gets the no'th filename part of this dataset.
			// Nostromo! truncate the name of the file!
	  		used = substring(used_path[no],(lastIndexOf(used_path[no], File.separator)+1),indexOf(used_path[no],".ome.tif")); //Ahoy!
  	  		setSlice(no + 1);
			run("Copy");
			newImage(used, "16-bit Black", sizeX, sizeY, 1);
			run("Paste");
			
  	  		//TNC = used + ".tif" + "," + positionX[no] + "," + invY + "," + positionZ[no]; // TrakEM2 output format
  	  		TNC = used + ".tif" + "," + pixsX + "," + inv_pixsY + "," + r_pixsZ; // TrakEM2 alternative output format
  	  		//TNC = used + ".tif" + "; ; " + "(" + pixsX + "," + inv_pixsY + "," + round_Z + ")"; //stitching plugin output format
			
			if (pxsize >= 0.588235) { // coping with unpleasant ImageJ rounding (6 digits)- Zoom1
			   setFont("SansSerif", 18, " antialiased");
			   setColor("white");
			   drawString("z1." + ROIname, 0, 22);
			   drawString("z1." + ROIname, (sizeX-51), 22);
			   drawString("z1." + ROIname, (sizeX-51), sizeY);
			   drawString("z1." + ROIname, 0, sizeY);
			   saveAs("TIFF", trgDir + File.separator + zoomDir[0] + File.separator + used + ".tif");
			   
			   //tableZ1 = File.open(trgDir + File.separator + zoomDir[0] + File.separator + "CoordinatesZ1.txt");
   			   //print(tableZ1,TNC);
 			   //File.close(tableZ1);
 			    			   
   			   // Using the File.open() and print() functions to save to a text file.
   			   // The file is closed using File.close(f) or automatically with its equivalent when the macro exits.
   			   // Currently only one file can be open at a time.
   			   
   			   tableZ1 = trgDir + File.separator + zoomDir[0] + File.separator + "CoordinatesZ1.txt";
   			   File.append(TNC,tableZ1); // Truncated Name Coordinates.
   			   }
   			else if (pxsize >= 0.294067) { // Zoom2
			   setFont("SansSerif", 18, " antialiased");
			   setColor("white");
			   drawString("z2." + ROIname, 0, 22);
			   drawString("z2." + ROIname, (sizeX-51), 22);
               drawString("z2." + ROIname, (sizeX-51), sizeY);
			   drawString("z2." + ROIname, 0, sizeY);
			   saveAs("TIFF", trgDir + File.separator + zoomDir[1] + File.separator + used + ".tif");
			   tableZ2 = trgDir + File.separator + zoomDir[1] + File.separator + "CoordinatesZ2.txt";
   			   File.append(TNC,tableZ2);
   			   }
		   	else if (pxsize >= 0.196039) { // Zoom3
			   setFont("SansSerif", 18, " antialiased");
			   setColor("white");
			   drawString("z3." + ROIname, 0, 22);
			   drawString("z3." + ROIname, (sizeX-51), 22);
			   drawString("z3." + ROIname, (sizeX-51), sizeY);
			   drawString("z3." + ROIname, 0, sizeY);
			   saveAs("TIFF", trgDir + File.separator + zoomDir[2] + File.separator + used + ".tif");
			   tableZ3 = trgDir + File.separator + zoomDir[2] + File.separator + "CoordinatesZ3.txt";
   			   File.append(TNC,tableZ3);
   			   }
			else { // Zoom4+
		   	   setFont("SansSerif", 18, " antialiased");
			   setColor("white");
			   drawString("z4+" + ROIname, 0, 22);
		   	   drawString("z4+" + ROIname, (sizeX-51), 22);
		   	   drawString("z4+" + ROIname, (sizeX-51), sizeY);
		   	   drawString("z4+" + ROIname, 0, sizeY);
		   	   saveAs("TIFF", trgDir + File.separator + zoomDir[3] + File.separator + used + ".tif");
		   	   tableZ4 = trgDir + File.separator + zoomDir[3] + File.separator + "CoordinatesZ4+.txt";
   			   File.append(TNC,tableZ4);
			   }
			close();
	   		}
		
	   	run("Z Project...", "start=1 stop=" + nSlices + " projection=[Max Intensity]");
	   	if (filter==true) run("Median...", "radius=1");
	   	run("8-bit");
	   	saveAs("TIFF", trgDir2 + File.separator + newMAXname);
        Ext.close();
      	}
      close();
      }
  	}
}
}