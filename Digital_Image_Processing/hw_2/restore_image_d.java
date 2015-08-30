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
 
public class restore_image_d implements PlugInFilter {
	private final int flags = DOES_ALL;
	double sigma = 2.5;
	double a = 1;
	
	public int setup (String arg, ImagePlus im) {
		return flags;
	}
	
	public void run (ImageProcessor ip) {
		if (runDialog()) {
			int h = ip.getHeight();
			int w = ip.getWidth();
			int[] iArray = null,p = null;
			
			ImagePlus imRed = NewImage.createByteImage("Red image", w, h, 1, NewImage.FILL_WHITE);
			ImageProcessor ipRed = imRed.getProcessor();
			
			ImagePlus imGreen = NewImage.createByteImage("Red image", w, h, 1, NewImage.FILL_WHITE);
			ImageProcessor ipGreen = imGreen.getProcessor();
			
			ImagePlus imBlue = NewImage.createByteImage("Red image", w, h, 1, NewImage.FILL_WHITE);
			ImageProcessor ipBlue = imBlue.getProcessor();
			
			for(int v=0; v<h; v++){
				for(int u=0; u<w; u++){
					p = ip.getPixel(u, v,iArray);
					ipRed.putPixel(u, v, p[0]);
					ipGreen.putPixel(u, v, p[1]);
					ipBlue.putPixel(u, v, p[2]);
				}
			}
			
			unsharpMask(ipRed,a);
			unsharpMask(ipGreen,a);
			unsharpMask(ipBlue,a);
			
			for(int v=0; v<h; v++){
				for(int u=0; u<w; u++){
					p[0] = ipRed.getPixel(u, v);
					p[1] = ipGreen.getPixel(u, v);
					p[2] = ipBlue.getPixel(u, v);
					ip.putPixel(u, v, p);
				}
			}
		}
	}
	
	public void unsharpMask(ImageProcessor ip, double a) 
	{
		ImageProcessor ip_res = ip.convertToFloat();
		
		ImageProcessor ip_gaus = ip_res.duplicate();
		GaussianBlur gb = new GaussianBlur();
		gb.blurGaussian(ip_gaus, sigma, sigma, 0.02);
				
		ip_res.multiply(1+a);
		ip_gaus.multiply(a);
		ip_res.copyBits(ip_gaus, 0, 0, Blitter.SUBTRACT);
		
		ip.insert(ip_res.convertToByte(false), 0, 0);
		
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
		GenericDialog gd = new GenericDialog("Unsharp Masking");
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