import java.awt.Dialog;
import ij.gui.NewImage;
import ij.IJ;
import ij.ImagePlus;
import ij.plugin.filter.Convolver;
import ij.plugin.filter.PlugInFilter;
import ij.plugin.filter.RankFilters;
import ij.plugin.filter.UnsharpMask;
import ij.plugin.filter.GaussianBlur;
import ij.WindowManager;
import ij.gui.GenericDialog;
import ij.process.*;
 
public class Gaussian_Blur implements PlugInFilter {
	private final int flags = DOES_ALL;
	double sigma = 2.5;
	
	public int setup (String arg, ImagePlus im) {
		return flags;
	}
	
	public void run (ImageProcessor ip) {
		if (runDialog()) {
			float[] H = creatGaussKernel(sigma);	
			int size = H.length;
			ImageProcessor copy = ip.duplicate();
			
			Convolver cv = new Convolver();
			cv.setNormalize(true);
			cv.convolve(ip, H, 1, size);
			cv.convolve(ip, H, size, 1);
		}
	}
	
	float[] creatGaussKernel(double sigma)
	{
//		create the kernel
		int radius = (int) (3.0*sigma); // kernel radius
		float[] kernel = new float[2*radius+1];
		
//		fill the kernel
		double sigma2 = sigma * sigma;
		for (int i=0; i<kernel.length; i++)
		{
			double r = radius - i;
			kernel[i] = (float) Math.exp(-0.5*(r*r) / sigma2);
		}
		return kernel;
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
		GenericDialog gd = new GenericDialog("Gaussian Blur");
		gd.addNumericField("Sigma value:", sigma, 2);
		gd.showDialog();
		if (gd.wasCanceled())
			return false;
		else {
			sigma = gd.getNextNumber();
			return true;
		}
	}
		
}