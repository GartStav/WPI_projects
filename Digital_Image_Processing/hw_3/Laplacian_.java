import ij.IJ;
import ij.process.*;
import ij.ImagePlus;
import ij.gui.GenericDialog;
import ij.plugin.filter.Convolver;
import ij.plugin.filter.PlugInFilter;
import ij.process.FloatProcessor;
import ij.process.ImageProcessor;
import static java.lang.Math.pow;

 
public class Laplacian_ implements PlugInFilter {
	
	double sigma = 4.0f;
	public int setup(String arg, ImagePlus im) {
		return DOES_ALL + NO_CHANGES;
	}

	public void run(ImageProcessor ipOrig) {
		
		final float[] filt = {1.0f,-2.0f,1.0f};
		//final float[] filt = {-0.5f,0.0f,0.5f};
		
		float[] H = makeGaussKernel1d(sigma);
		int size = H.length;
		
		ImageProcessor ip_gaus_ = ipOrig.duplicate();
		ByteProcessor ip_gaus = (ByteProcessor) ip_gaus_.convertToByte(true);
		//ImagePlus win3 = new ImagePlus("gaus", ip_gaus);
		//win3.show();
		
		Convolver cv = new Convolver();
		cv.setNormalize(true);
		cv.convolve(ip_gaus, H, 1, size);
		cv.convolve(ip_gaus, H, size, 1);
		
		ImageProcessor ipX = ip_gaus.duplicate();
		FloatProcessor Ix = (FloatProcessor) ipX.convertToFloat();
		
		ImageProcessor ipY = ip_gaus.duplicate();
		FloatProcessor Iy = (FloatProcessor) ipY.convertToFloat();
		
		//ImagePlus win4 = new ImagePlus("gaus22", ipX);
		//win4.show();
		
		Ix = convolve1h(Ix,filt,false);
		Iy = convolve1v(Iy,filt,false);
		//Ix.sqr();
		//Iy.sqr();
		Ix.copyBits(Iy, 0, 0, Blitter.ADD);
		//Ix.sqrt();
		ImagePlus win = new ImagePlus("Laplacian", Ix);
		win.show();
		
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
	
	/*static FloatProcessor convolve2(FloatProcessor p, float[] h) {
		convolve1h(p,h);
		convolve1v(p,h);
		return p;
	}*/
	
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
		
