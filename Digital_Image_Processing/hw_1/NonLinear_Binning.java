import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
 
public class NonLinear_Binning implements PlugInFilter {
	
	public int setup (String arg, ImagePlus im) {
		return DOES_8G;
	}
	
	public void run (ImageProcessor ip) {
		//int K = 256;
		int B = 10;
		// spits (upper borders) for 8 bit image
		int[] a_j = {10, 23, 56, 72, 97, 129, 150, 178, 211};
		int[] H = new int[B]; 
		int w = ip.getWidth();
		int h = ip.getHeight();
		
		// compute histogram
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				int a = ip.getPixel(u, v);
				int i = 0;
				int k = 0;
				while (a >= a_j[k]) {
					k += 1;
					i = k;
					if (k == 9)
						break;
				}
				H[i] = H[i] + 1;
			}
		}
		int s = ip.getHeight();
		
	}
}