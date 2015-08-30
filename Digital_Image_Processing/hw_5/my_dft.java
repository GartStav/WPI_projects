import ij.IJ;
import ij.process.*;
import ij.ImagePlus;
import ij.gui.GenericDialog;
import ij.plugin.filter.Convolver;
import ij.plugin.filter.PlugInFilter;
import ij.process.ByteProcessor;
import ij.process.FloatProcessor;
import ij.process.ImageProcessor;
import java.awt.*;
import dft.*;
 
public class my_dft implements PlugInFilter {


	
	public int setup(String arg, ImagePlus im) {

		return DOES_ALL + NO_CHANGES;
	}

	public void run(ImageProcessor ip) {

		FloatProcessor ipf = (FloatProcessor) ip.convertToFloat();
		Dft2d dft_ = new Dft2d(ipf);
		
		
		ImagePlus win5 = new ImagePlus("dft", ipf);
		win5.show();
		
		FloatProcessor ipf_n = (FloatProcessor) ipf.duplicate();
		Dft2d_inv dft2 = new Dft2d_inv(ipf_n,dft_.getReal(),dft_.getImag());
		FloatProcessor ipf_n_ = new FloatProcessor(ip.getWidth(), ip.getHeight(), dft2.getReal());

		ImageProcessor pi_ = ip.duplicate();
		ByteProcessor pi = (ByteProcessor) pi_.convertToByte(true);
		pi = dft_.makePowerImage();

		ImagePlus win2 = new ImagePlus("spectrum", pi);
		win2.show();
		
		ipf_n_ = (FloatProcessor) ipf_n_.rotateLeft();
		ipf_n_ = (FloatProcessor) ipf_n_.rotateLeft();
		ImagePlus win3 = new ImagePlus("inverted", ipf_n_);
		win3.show();
		
	}


}
