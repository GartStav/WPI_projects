import ij.IJ;
import ij.process.*;
import ij.ImagePlus;
import ij.gui.GenericDialog;
import ij.plugin.filter.Convolver;
import ij.plugin.filter.PlugInFilter;
import ij.process.FloatProcessor;
import ij.process.ImageProcessor;
import static java.lang.Math.pow;

 
public class Zero_crossings implements PlugInFilter {
	
	double sigma = 1.0f;
	public int setup(String arg, ImagePlus im) {
		return DOES_ALL + NO_CHANGES;
	}

	public void run(ImageProcessor ipOrig) {
		
		final float[] filt = {1.0f,-2.0f,1.0f};
		//final float[] filt = {-0.5f,0.0f,0.5f};
		
		ImageProcessor ipX = ipOrig.duplicate();
		FloatProcessor Ix = (FloatProcessor) ipX.convertToFloat();
		
		int h = ipOrig.getHeight();
		int w = ipOrig.getWidth();
		
		ImageProcessor ip_crossings_ = ipOrig.duplicate();
		ByteProcessor ip_crossings = (ByteProcessor) ip_crossings_.convertToByte(true);
		
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				ip_crossings.putPixel(u, v, 0);
			}
		}
		
		for (int u = 1; u < w-1; u++) {
			for (int v = 1; v < h-1; v++) {
				int rightPixel = Ix.getPixel(u-1, v);
				int middlePixel = Ix.getPixel(u, v);
				int LeftPixel = Ix.getPixel(u+1, v);
				if ( ((rightPixel < 0) && (LeftPixel > 0)) || ((rightPixel > 0) && (LeftPixel < 0)) ) {
					ip_crossings.putPixel(u, v, 255);
				}
				else {
					ip_crossings.putPixel(u, v, 0);
				}
			}
		}
		
		for (int u = 1; u < w-1; u++) {
			for (int v = 1; v < h-1; v++) {
				int rightPixel = Ix.getPixel(u, v-1);
				int middlePixel = Ix.getPixel(u, v);
				int LeftPixel = Ix.getPixel(u, v+1);
				if ( ((rightPixel < 0) && (LeftPixel > 0)) || ((rightPixel > 0) && (LeftPixel < 0)) ) {
					ip_crossings.putPixel(u, v, 255);
				}
			}
		}
		
		ImagePlus win2 = new ImagePlus("Zero-crossings", ip_crossings);
		win2.show();
		
	}
	
	static FloatProcessor convolve1h(FloatProcessor p, float[] h, boolean norm) {
		Convolver conv = new Convolver();
		conv.setNormalize(norm);
		conv.convolve(p, h, 1, h.length);
		return p;
	}

	static FloatProcessor convolve1v(FloatProcessor p, float[] h, boolean norm) {
		Convolver conv = new Convolver();
		conv.setNormalize(norm);
		conv.convolve(p, h, h.length, 1);
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

