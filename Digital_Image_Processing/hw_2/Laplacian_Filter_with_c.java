import java.awt.Dialog;

import ij.IJ;
import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.WindowManager;
import ij.gui.GenericDialog;
import ij.process.*;
 
public class Laplacian_Filter_with_c implements PlugInFilter {
	double c = 0.1;
	
	public int setup (String arg, ImagePlus im) {
		return DOES_ALL;
	}
	
	public void run (ImageProcessor orig) {
		if (runDialog()) {
			int w = orig.getWidth();
			int h = orig.getHeight();
			double[][] filter = {
					{0, c/4, 0},
					{c/4, 1-c, c/4},
					{0, c/4, 0}
			};
			double[][] filter2 = {
					{-1, -1, -1},
					{-1, 8, -1},
					{-1, -1, -1}
			};
			double[][] filter3 = {
					{0, -1, 0},
					{-1, 4, -1},
					{0, -1, 0}
			};
			ImageProcessor copy = orig.duplicate();
			
			for (int v = 1; v < h-1; v++){
				for (int u = 1; u < w-1; u++) {
					double sum = 0;
					for (int i = -1; i <= 1; i++) {
						for (int j = -1; j <= 1; j++) {
							int p = copy.getPixel(u+i, v+j);
							double m = filter[i+1][j+1];
							sum += m*p;
						}
					}
					int p_o = orig.getPixel(u, v);
					int q = (int)Math.round(sum);
					if (sum < 0) 
						sum = 0;
					if (sum > 255)
						sum = 255;
					orig.putPixel(u, v, q);
				}
			}
			
		}
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
		GenericDialog gd = new GenericDialog("Laplacian Filter");
		gd.addNumericField("C value:", c, 2);
		gd.showDialog();
		if (gd.wasCanceled())
			return false;
		else {
			c = gd.getNextNumber();
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