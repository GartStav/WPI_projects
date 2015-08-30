import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
 
public class AutoContrast_quantiles implements PlugInFilter {
	
	public int setup (String arg, ImagePlus im) {
		return DOES_8G;
	}
	
	public void run (ImageProcessor ip) {
		int a_max = 255;
		int a_min = 0;
		int w = ip.getWidth();
		int h = ip.getHeight();
		int a_high = a_min;
		int a_low = a_max;
		
		int[] H = new int[256]; 
		int[] CH = new int[256];
		
		// compute histogram
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				int i = ip.getPixel(u, v);
				H[i] = H[i] + 1;
			}
		}
		
		CH[0] = H[0];
		// compute cumulative histogram
		for (int i = 1; i < 256; i++) {
			CH[i] = H[i] + CH[i - 1];
		}
		
		int pixel_num = CH[255];
		double percentile_low = (0.01*pixel_num);
		double percentile_high = (0.99*pixel_num);
		
		int s_low = 0;
		int s_high = 0;
		for (int i = 1; i < 256; i++) {
			if (CH[i] < percentile_low)
				s_low = i;
		}
		
		for (int i = 255; i >= 0; i -= 1) {
			if (CH[i] > percentile_high)
				s_high = i;
		}
		
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				int a = ip.getPixel(u, v);
				if (a > a_high)
					a_high = a;
				if (a < a_low)
					a_low = a;
			}
		}
		
		if (a_high != a_low) {
			for (int u = 0; u < w; u++) {
				for (int v = 0; v < h; v++) {
					int a = ip.getPixel(u, v);
					int p = a_min + (a - a_low) * (a_max - a_min) / (a_high - a_low);
					if (a < s_low)
						p = a_min;
					if (a > s_high)
						p = a_max;
					ip.putPixel(u, v, p);
				}
			}
		}
		int s = ip.getHeight();
		
	}
}