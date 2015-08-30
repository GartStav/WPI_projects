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

 
public class Laplacian_Edge_detection implements PlugInFilter {
	
	double sigma = 8.0f;
	public int setup(String arg, ImagePlus im) {
		return DOES_ALL + NO_CHANGES;
	}

	public void run(ImageProcessor ipOrig) {
		
		final float[] filt2 = {-0.5f,0.0f,0.5f};
		float gradient_threshold = 2.0f;
		
		int h = ipOrig.getHeight();
		int w = ipOrig.getWidth();
		
		float[] H = makeGaussKernel1d(sigma);	
		int size = H.length;
		
		ImageProcessor ip_gaus_ = ipOrig.duplicate();
		ByteProcessor ip_gaus = (ByteProcessor) ip_gaus_.convertToByte(true);
		
		Convolver cv = new Convolver();
		cv.setNormalize(true);
		cv.convolve(ip_gaus, H, 1, size);
		cv.convolve(ip_gaus, H, size, 1);
		
		ImageProcessor ipX = ip_gaus.duplicate();
		FloatProcessor Ix = (FloatProcessor) ipX.convertToFloat();
		
		ImageProcessor ipY = ip_gaus.duplicate();
		FloatProcessor Iy = (FloatProcessor) ipY.convertToFloat();
		
		Ix = convolve1h(Ix,filt2,false);
		Iy = convolve1v(Iy,filt2, false);
		Ix.sqr();
		Iy.sqr();
		Ix.copyBits(Iy, 0, 0, Blitter.ADD);
		Ix.sqrt();
		ImagePlus win_mag = new ImagePlus("Gradient magnitude ", Ix);
		win_mag.show();
		
		ImageProcessor ip_grad_threshold_ = ipOrig.duplicate();
		ByteProcessor ip_grad_threshold = (ByteProcessor) ip_grad_threshold_.convertToByte(true);
		
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				ip_grad_threshold.putPixel(u, v, 0);
			}
		}
		
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				int p_ = Ix.getPixel(u, v);
				float p = Float.intBitsToFloat(p_);
				if (p < gradient_threshold){
					ip_grad_threshold.putPixel(u, v, 0);
				}
				else
				{
					ip_grad_threshold.putPixel(u, v, 255);
				}
			}
		}
		ImagePlus win_mag_t = new ImagePlus("Gradient magnitude with threshold", ip_grad_threshold);
		win_mag_t.show();
		
		final float[] filt = {1.0f,-2.0f,1.0f};
		
		ImageProcessor ipX2 = ip_gaus.duplicate();
		FloatProcessor Ix2 = (FloatProcessor) ipX2.convertToFloat();
		
		ImageProcessor ipY2 = ip_gaus.duplicate();
		FloatProcessor Iy2 = (FloatProcessor) ipY2.convertToFloat();
		
		//ImagePlus win4 = new ImagePlus("gaus22", ipX);
		//win4.show();
		
		Ix2 = convolve1h(Ix2,filt,false);
		Iy2 = convolve1v(Iy2,filt,false);
		//Ix.sqr();
		//Iy.sqr();
		Ix2.copyBits(Iy2, 0, 0, Blitter.ADD);
		//Ix.sqrt();
		ImagePlus win = new ImagePlus("Laplacian", Ix2);
		win.show();
		
		ImageProcessor ip_crossings_ = ipOrig.duplicate();
		ByteProcessor ip_crossings = (ByteProcessor) ip_crossings_.convertToByte(true);
		
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				ip_crossings.putPixel(u, v, 0);
			}
		}
		
		for (int u = 1; u < w-1; u++) {
			for (int v = 1; v < h-1; v++) {
				int rightPixel = Ix2.getPixel(u-1, v);
				int middlePixel = Ix2.getPixel(u, v);
				int LeftPixel = Ix2.getPixel(u+1, v);
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
				int rightPixel = Ix2.getPixel(u, v-1);
				int middlePixel = Ix2.getPixel(u, v);
				int LeftPixel = Ix2.getPixel(u, v+1);
				if ( ((rightPixel < 0) && (LeftPixel > 0)) || ((rightPixel > 0) && (LeftPixel < 0)) ) {
					ip_crossings.putPixel(u, v, 255);
				}
			}
		}
		
		ImagePlus win2 = new ImagePlus("Zero-crossings", ip_crossings);
		win2.show();
		
		ImageProcessor resulting_ = ipOrig.duplicate();
		ByteProcessor resulting = (ByteProcessor) resulting_.convertToByte(true);
		
		for (int u = 1; u < w-1; u++) {
			for (int v = 1; v < h-1; v++) {
				int p1 = ip_grad_threshold.getPixel(u, v);
				int p2 = ip_crossings.getPixel(u, v);
				if ((p1 == p2) && (p1 == 255)) {
					resulting.putPixel(u, v, 255);
				}
				else {
					resulting.putPixel(u, v, 0);
				}
			}
		}
		ImagePlus win_res = new ImagePlus("Laplacian", resulting);
		win_res.show();
		
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
