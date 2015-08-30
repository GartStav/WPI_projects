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
 
public class Gaussian_Blur_Or_Sharpen implements PlugInFilter {
	private final int flags = DOES_ALL;
	double sigma = 2.5;
	double weight = 1;
	
	public int setup (String arg, ImagePlus im) {
		return flags;
	}
	
	public void run (ImageProcessor ip) {
		if (runDialog()) {
			int h = ip.getHeight();
			int w = ip.getWidth();
			
			float[] H = makeGaussKernel1d(sigma);	
			int size = H.length;
			
			ImageProcessor ip_res = ip.convertToFloat();
			
			ImageProcessor ip_gaus = ip_res.duplicate();
			
			Convolver cv = new Convolver();
			cv.setNormalize(true);
			cv.convolve(ip_gaus, H, 1, size);
			cv.convolve(ip_gaus, H, size, 1);
					
			
			ip_res.multiply(1+weight);
			ip_gaus.multiply(weight);
			ip_res.copyBits(ip_gaus, 0, 0, Blitter.SUBTRACT);
			ip.insert(ip_res.convertToByte(false), 0, 0);		
		
		}
	}
	
	float[] makeGaussKernel1d(double sigma)
	{
//		create the kernel
		int radius = (int) (3.0*sigma);
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
		gd.addNumericField("w value:", weight, 2);
		gd.showDialog();
		if (gd.wasCanceled())
			return false;
		else {
			sigma = gd.getNextNumber();
			weight = gd.getNextNumber();
			return true;
		}
	}
		
}