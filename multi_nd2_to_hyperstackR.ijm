// Multiple nd2 to hyperstack
// author: Masak Takaine

// This FIJI macro converts multiple Nikon nd2 files in a source directory into a hyperstack file that is readable in ImageJ/FIJI.
// The resultant hyperstack file is saved in a destination directory.
// As input, nd2 files composed of two channel images are assumed. 
// Z-stack of images will be compressed into a single xy image using the maximum intensity projection method.

macro "Multi-nd2_to_hyperstack" {
	
#@ String(label="Date of experiments, e.g., 221102") edate
#@ String(label="Choose the type of hyperstack", choices={"8-bit", "16-bit", "RGB"}, style="radioButtonHorizontal") typeh
#@ File (label="Choose source folder", style="directory") dirS0
#@ File (label="Choose destination folder", style="directory") dirD0
#@ String(label="Hide/Show the active image? The Show slows the analysis.", choices={"hide","show"}, style="radioButtonHorizontal") sbm

setBatchMode(sbm); // hides the active image, required ImageJ 1.48h or later
dirS = dirS0 + File.separator; // "File.separator" returns the file name separator character depending on the OS system used.
dirD = dirD0 + File.separator;
imagefilelist = getFileList(dirS);

for (i = 0; i < imagefilelist.length; i++) { 
   currFile = dirS + imagefilelist[i];
    if((endsWith(currFile, ".nd2"))||(endsWith(currFile, ".oib"))||(endsWith(currFile, ".zvi"))) { // process if files ending with .oib or .nd2, or .zvi
		run("Bio-Formats Macro Extensions"); 
		Ext.openImagePlus(currFile)}
	else if ((endsWith(currFile, ".tif"))||(endsWith(currFile, ".tiff"))) {// process if files ending with .tif or .tiff (hyperstack files)
			open(currFile); 
		}
currfileid = getImageID();

if (typeh != "RGB"){
	typed = "grayscale-mode";  // typed: Disply mode of hyperstack
} else {
	typed = "color-mode";
}

//When the first file, create a blank hyperstack file
	if (i == 0) {  
		getDimensions(imwidth, imheight, nchannels, imslices, frames);
		newImage("HyperStack", ""+typeh+" "+typed+"", imwidth, imheight, nchannels, imagefilelist.length, 1);
				}
				
selectImage(currfileid);
run("Z Project...", "projection=[Max Intensity]");
title2 = getTitle();
run("Split Channels");
c1 = "C1-" + title2; 
c2 = "C2-" + title2;

selectWindow(c1);
ch1id = getImageID();
ch1_label = getTitle();
run("Select All");
run("Copy");
close();

selectWindow("HyperStack");
Stack.setPosition(1, i+1, 1);
run("Paste");
run("Set Label...", "label="+ch1_label+"");

selectWindow(c2);
ch2id = getImageID();
ch2_label = getTitle();
run("Select All");
run("Copy");
close();

selectWindow("HyperStack");
Stack.setPosition(2, i+1, 1);
run("Paste");
run("Set Label...", "label="+ch2_label+"");

selectImage(currfileid);
close();
}
selectWindow("HyperStack");
run("Select None");
if (typeh != "RGB"){
	Stack.setChannel(1);
	run("Grays");
	Stack.setChannel(2);
	run("Grays");
}
saveAs("Tiff", dirD+ edate + "_"+getTitle());
run("Close");
run("Close All");
	showMessage(" ", "<html>"+"<font size=+2>Process completed<br>");
}