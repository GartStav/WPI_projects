import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
 
public class Median_Threshold implements PlugInFilter {
	
	public int setup (String arg, ImagePlus im) {
		return DOES_8G;
	}
	
	public void run (ImageProcessor ip) {
		int[] H = new int[256]; 
		int[] CH = new int[256];
		int w = ip.getWidth();
		int h = ip.getHeight();
		
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
		
		// compute median of the histogram
		int i = 0;
		int num_pixels = CH[255];
		while (CH[i] < (int)num_pixels/2) {
			i++;
		}
		int median = i;		
		
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				int p = ip.getPixel(u, v);
				if (p > median)
					p = 255;
				else
					p = 0;		
				ip.putPixel(u, v, p);
			}
		}
	}
}