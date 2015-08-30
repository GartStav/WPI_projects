import harris.HarrisCornerDetector;
import ij.IJ;
import ij.process.*;
import ij.ImagePlus;
import ij.gui.GenericDialog;
import ij.plugin.filter.Convolver;
import ij.plugin.filter.PlugInFilter;
import ij.process.FloatProcessor;
import ij.process.ImageProcessor;
import static java.lang.Math.pow;

 
public class Gradient_magnitude implements PlugInFilter {
	
	double sigma = 8;
	
	public int setup(String arg, ImagePlus im) {
		return DOES_ALL + NO_CHANGES;
	}

	public void run(ImageProcessor ipOrig) {
		final float[] filt = {-0.5f,0.0f,0.5f};
			
		float[] H = makeGaussKernel1d(sigma);	
		int size = H.length;
		
		ImageProcessor ip_gaus = ipOrig.duplicate();
		
		Convolver cv = new Convolver();
		cv.setNormalize(false);
		cv.convolve(ip_gaus, H, 1, size);
		cv.convolve(ip_gaus, H, size, 1);
		
		ImageProcessor ipX = ip_gaus.duplicate();
		FloatProcessor Ix = (FloatProcessor) ipX.convertToFloat();
		
		ImageProcessor ipY = ip_gaus.duplicate();
		FloatProcessor Iy = (FloatProcessor) ipY.convertToFloat();
		
		Ix = convolve1h(Ix,filt);
		Iy = convolve1v(Iy,filt);
		Ix.sqr();
		Iy.sqr();
		Ix.copyBits(Iy, 0, 0, Blitter.ADD);
		Ix.sqrt();
		ImagePlus win = new ImagePlus("Gradient magnitude ", Ix);
		win.show();
	}
	
	static FloatProcessor convolve1h(FloatProcessor p, float[] h) {
		Convolver conv = new Convolver();
		conv.setNormalize(false);
		conv.convolve(p, h, 1, h.length);
		return p;
	}

	static FloatProcessor convolve1v(FloatProcessor p, float[] h) {
		Convolver conv = new Convolver();
		conv.setNormalize(false);
		conv.convolve(p, h, h.length, 1);
		return p;
	}
	
	static FloatProcessor convolve2(FloatProcessor p, float[] h) {
		convolve1h(p,h);
		convolve1v(p,h);
		return p;
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
}