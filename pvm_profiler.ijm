
// global variables that are set if the correction macro is used
var l_cor_x = 0;
var r_cor_x = 0;

var l_cor_bg = 0;
var r_cor_bg = 0;

// these need to be global so they stay when a correction is applied
var l_bg_end = 0;
var r_bg_start = 0;


// main function to identify peaks and background
function findValues() {
	Overlay.clear;	
	Plot.getValues(x, y);
	fn = getTitle();
	peak_dist = 2; // distance in uM from the peak when background starts
	

	if (l_cor_x == 0) {
		// if no correction is applied to x, find maximum automatically
		// extract left half of the plot
		left = Array.slice(y,0,y.length/2-1);

		// find maximum of left half
		l_max_a = Array.findMaxima(left, 100); //get index of all maxima
		// exit script if no peak was found
		if (l_max_a.length == 0) {
			exit("could not find a left peak. Make sure the middle of the line is in the middle of the PVM.");
		}
		
		
		l_max_index = l_max_a[0]; //get index of highest maximum

	} else {
		// if x is corrected set it manually
		// find index of corrected peak
		for (i=0; i<x.length; i++) {
			if (x[i] >= l_cor_x) {
				l_max_index = i-1;
				break;
			}
		}
		
	}

	// get x and y values for the index
	l_max_x = x[l_max_index];
	l_max_y = y[l_max_index];

	if (l_cor_bg == 0) { // if no correction is applied to left bg
		// Get the mean fluorescence in left background
		l_bg = newArray(0);
		
		for (i=0; i<x.length; i++) {
			// if the x pos of index i is too close to left peak, exit loop
			if (x[i] > l_max_x-peak_dist) {
				l_bg_end = i;
				break;
			} else { // if not add y value to background array
				// create a temp. array containing the y value of the current index i
				tmp = newArray(1);
				tmp[0] = y[i];
				// add that array to the l_bg array
				l_bg = Array.concat(l_bg,tmp);
		
			}
		}
	Array.getStatistics(l_bg, min, max, l_bg_mean, stdDev);
	} else { // if correction is applied just set it
		l_bg_mean = l_cor_bg;
	}
	
	

	//repeat the same for the right side
	if (r_cor_x == 0) {

		right = Array.slice(y,y.length/2+1,y.length);
		right_x = Array.slice(x,x.length/2+1,x.length);

		r_max_a = Array.findMaxima(right, 100);
		
		// exit script if no peak was found
		if (r_max_a.length == 0) {
			exit("could not find a right peak. Make sure the middle of the line is in the middle of the PVM.");
		}
		
		r_max_index = r_max_a[0]+y.length/2+1;

	} else {
		// if x is corrected set it manually
		// find index of corrected peak
		for (i=0; i<x.length; i++) {
			if (x[i] >= r_cor_x) {
				r_max_index = i-1;
				break;
			}
		}
	}

	
	// get x and y values for the index
	r_max_x = x[r_max_index]; 
	r_max_y = y[r_max_index];	

	if (r_cor_bg == 0) {
		// Get the mean fluorescence in right background
		r_bg = newArray(0);
		
		for (i=0; i<x.length; i++) {
			// if the x pos of index i is too close to left peak, exit loop
			if (x[i] < r_max_x+peak_dist) {
				continue;
			} else { // if not add y value to background array
				// create a temp. array containing the y value of the current index i
				tmp = newArray(1);
				tmp[0] = y[i];
				// add that array to the l_bg array
				r_bg = Array.concat(r_bg,tmp);
		
				//remember start of bg area
				if (r_bg_start == 0) {r_bg_start = i;}
			}
		}

		Array.getStatistics(r_bg, min, max, r_bg_mean, stdDev);
	} else {
		r_bg_mean = r_cor_bg;
	}


	// mark the halfline
	leer = 0;
	Plot.getLimits(xMin, xMax, yMin, yMax);
	toUnscaled(xMin, yMin);
	toUnscaled(xMax, yMax);
	
	x1 = x[x.length/2];
	toUnscaled(x1, leer);
	setLineWidth(1);	
	Overlay.drawLine(x1, yMin, x1, yMax);
	setColor("gray");
	setLineWidth(3);	

	//mark the left background level
	
	l_bg_mean_us = l_bg_mean;
	l_bg_end_us = x[l_bg_end];
	toUnscaled(l_bg_end_us, l_bg_mean_us);

	Overlay.drawLine(xMin, l_bg_mean_us, l_bg_end_us, l_bg_mean_us);	

	
	//mark the right background level

	r_bg_mean_us = r_bg_mean;
	r_bg_start_us = x[r_bg_start];
	toUnscaled(r_bg_start_us, r_bg_mean_us);

	Overlay.drawLine(r_bg_start_us, r_bg_mean_us, xMax, r_bg_mean_us);
	setColor("blue");	
	
	// mark the positions with red line
	x_vals = newArray(l_max_x,r_max_x);
	y_vals = newArray(l_max_y,r_max_y);
	toUnscaled(x_vals, y_vals);

	Overlay.drawLine(x_vals[0]-3, y_vals[0], x_vals[0]+3, y_vals[0]);
	Overlay.drawLine(x_vals[1]-3, y_vals[1], x_vals[1]+3, y_vals[1]);
	setColor("red");


	setFont("sans serif", 12);
	setColor("red");
	
	Overlay.drawString("Blue: Background; Red: peaks; Grey: midline. Correct peaks with 'c'. Data is automatically in clipboard. ", 5, 15);
	Overlay.show;
	
	//Plot.addText("If you like the guess just paste in excel\n If not meassure manually", 0.2, 0.7);
	
	// calculate average fluorescence
	avg_fl = (((l_max_y-l_bg_mean)+(r_max_y - r_bg_mean))/2);
	
	
	
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	ts="aa";	
	ts = ""+dayOfMonth+"."+month+"."+year+" "+hour+":"+minute+":"+second+"";
	
	output = ""+fn + "\t" + ts + "\t" + l_bg_mean + "\t" + l_max_y + "\t" + r_max_y+ "\t" + r_bg_mean+ "\t" + avg_fl	;
	
	String.copy(output);	
}

// this macro allows correction of the peaks. 
macro "correct_l_peak [c]" {
	getCursorLoc(cur_x, cur_y, cur_z, flags); //get mouse pos
	toScaled(cur_x, cur_y); // convert to plot coordinates

	Plot.getLimits(xMin, xMax, yMin, yMax);
	if (cur_x < xMax/2) {
		// cursor is on the left half
		l_cor_x = cur_x;	
		
	} else {
		// cursor is on the right half
		r_cor_x = cur_x;		
	}
	findValues();
	
}

// this macro allows correction of the backgrounds. 
macro "correct_l_peak [v]" {

	getCursorLoc(cur_x, cur_y, cur_z, flags); //get mouse pos
	toScaled(cur_x, cur_y); // convert to plot coordinates

	Plot.getLimits(xMin, xMax, yMin, yMax);
	if (cur_x < xMax/2) {
		// cursor is on the left half
		l_cor_bg = cur_y;
	} else {
		// cursor is on the right half
		r_cor_bg = cur_y;	
	}
	findValues();
	
}

macro "teststuff" {


}

macro "PVM_intensity [q]"{
		
	l_cor_x = 0;
	r_cor_x = 0;
	l_cor_bg = 0;
	r_cor_bg = 0;
	l_bg_end = 0;
	r_bg_start = 0;
	run("Plot Profile");
	
	findValues();
}
//makePoint(x[l_max[0]], y[l_max[0]]);
