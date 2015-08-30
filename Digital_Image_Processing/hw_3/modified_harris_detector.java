import harris.HarrisCornerDetector;
import ij.IJ;
import ij.ImagePlus;
import ij.gui.GenericDialog;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
import static java.lang.Math.pow;

 
public class modified_harris_detector implements PlugInFilter {
	
	ImagePlus im;
	static float alpha = HarrisCornerDetector.DEFAULT_ALPHA;
	static int threshold = HarrisCornerDetector.DEFAULT_THRESHOLD;
	static int nmax = 0; //points to show
	
	int a_max = 255;
	int a_min = 0;
	int a_high = a_min;
	int a_low = a_max;

	
	public int setup(String arg, ImagePlus im) {
		this.im = im;
		if (arg.equals("about")) {
			showAbout();
			return DONE;
		}
		return DOES_8G + NO_CHANGES;
	}

	public void run(ImageProcessor ip) {
		int w = ip.getWidth();
		int h = ip.getHeight();
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				int a = ip.getPixel(u, v);
				if (a > a_high)
					a_high = a;
				if (a < a_low)
					a_low = a;
			}
		}
		if (!showDialog()) return; //dialog canceled or error
		HarrisCornerDetector hcd = new HarrisCornerDetector(ip,alpha,threshold);
		hcd.findCorners();
		ImageProcessor result = hcd.showCornerPoints(ip);
		ImagePlus win = new ImagePlus("Corners from " + im.getTitle(), result);
		win.show();
	}

	void showAbout() {
		String cn = getClass().getName();
		IJ.showMessage("About "+cn+" ...", "Harris Corner Detector");
	}
		
	private boolean showDialog() {
		// display dialog, and return false if canceled or in error.
		GenericDialog dlg = new GenericDialog("Harris Corner Detector", IJ.getInstance());
		float def_alpha = HarrisCornerDetector.DEFAULT_ALPHA;
		dlg.addNumericField("Alpha (default: "+def_alpha+")", alpha, 3);
		
		double x = ((double)(a_high-a_low))/(a_max-a_min);
		int modified_threshold = (int)( 12745*pow(x,6)+7430*pow(x,2)-175 );
		
		int def_threshold = modified_threshold;//HarrisCornerDetector.DEFAULT_THRESHOLD;
		dlg.addNumericField("Threshold (default: "+def_threshold+ ")", def_threshold, 0);
		dlg.addNumericField("Max. points (0 = show all)", nmax, 0);
		dlg.showDialog();
		if(dlg.wasCanceled())
			return false;
		if(dlg.invalidNumber()) {
			IJ.showMessage("Error", "Invalid input number");
			return false;
		}
		alpha = (float) dlg.getNextNumber();
		threshold = (int) dlg.getNextNumber();
		nmax = (int) dlg.getNextNumber();
		return true;
	}
}
