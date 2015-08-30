import java.awt.Dialog;

import ij.IJ;
import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.WindowManager;
import ij.gui.GenericDialog;
import ij.process.*;
 
// open files bridge.gif, cell_colony.gif, gel.gif
public class histogram_spec_averages implements PlugInFilter {
	ImagePlus fIm = null;
	ImagePlus sIm = null;
	ImagePlus tIm = null;
	
	public int setup (String arg, ImagePlus im) {
		return DOES_ALL;
	}
	
	public void run (ImageProcessor ipA) {
		if (runDialog()) {
			ImageProcessor ipB = fIm.getProcessor().convertToByte(false);
			ImageProcessor ipC = sIm.getProcessor().convertToByte(false);
			ImageProcessor ipD = tIm.getProcessor().convertToByte(false);
			int[] hA = ipA.getHistogram();
			int[] hB = ipB.getHistogram();
			int[] hC = ipC.getHistogram();
			int[] hD = ipD.getHistogram();
			int k = hA.length;
			int[] hAverage = new int[k];
			for (int i = 0; i < k; i++) {
				hAverage[i] = hB[i] + hC[i] + hD[i];
				hAverage[i] = hAverage[i]/3;
			}
			int[] F = matchHistograms(hA, hAverage);
			ipA.applyTable(F);
		}
	}
	
	public int[] matchHistograms(int[] hA, int[] hB) {
		int k = hA.length;
		int m = hB.length;
		int[] fun = new int[k];
		if (k == m) {
			double[] PA = sdf(hA);
			double[] PB = sdf(hB);
			for (int i = 0; i < k; i++){
				int j = k - 1;
				do {
					fun[i] = j;
					j = j-1;
				} while ((j >= 0) && (PA[i] <= PB[j]));
			}
		}
		return fun;
	}
	
	boolean runDialog() {
		// get list of open images
		int[] windowList = WindowManager.getIDList();
		if (windowList == null) {
			IJ.noImage();
			return false;
		}
		
		// get all image titles
		String[] windowTitles = new String[windowList.length];
		for (int i = 0; i < windowList.length; i++) {
			ImagePlus im = WindowManager.getImage(windowList[i]);
			if (im == null)
				windowTitles[i] = "untitled";
			else
				windowTitles[i] = im.getShortTitle();
			}

		// create dialog and show
		GenericDialog gd = new GenericDialog("Histogram Matching");
		gd.addChoice("First image:", windowTitles, windowTitles[0]);
		gd.addChoice("Second image:", windowTitles, windowTitles[0]);
		gd.addChoice("Third image:", windowTitles, windowTitles[0]);
		//gd.addNumericField("Alpha value [0..1]:", alpha, 2);
		gd.showDialog();
		if (gd.wasCanceled())
			return false;
		else {
			int fgIdx = gd.getNextChoiceIndex();
			fIm = WindowManager.getImage(windowList[fgIdx]);
			fgIdx = gd.getNextChoiceIndex();
			sIm = WindowManager.getImage(windowList[fgIdx]);
			fgIdx = gd.getNextChoiceIndex();
			tIm = WindowManager.getImage(windowList[fgIdx]);
			//alpha = gd.getNextNumber();
			return true;
		}
	}

	public double[] sdf(int[] hist) {
		int k = hist.length;
		int n = 0;
		double[] P = new double[k];
		for (int i = 1; i < k; i++) n += hist[i];
		P[0] = (double)hist[0]/n;
		for (int i = 1; i < 256; i++) {
			P[i] = (double)hist[i]/n + P[i - 1];
		}
		return P;
	}
		
}