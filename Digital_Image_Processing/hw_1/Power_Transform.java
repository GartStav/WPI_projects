// for the spine.jpg the best result was acquired by using Gamma = 0.6
// fro the runway.jpg the best result was acquired by using Gamma = 5.8

import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
 
public class Power_Transform  implements PlugInFilter {
	
	public int setup (String arg, ImagePlus im) {
		return DOES_8G;
	}
	
	public void run (ImageProcessor ip) {
		int w = ip.getWidth();
		int h = ip.getHeight();
		double gamma = 6.0;
		
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				int p = ip.getPixel(u, v);
				int new_val = (int)(255*(Math.pow((double)p/255, gamma)));
				ip.putPixel(u, v, new_val);
			}
		}
	}
}