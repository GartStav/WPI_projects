import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;
 
public class GrayLevel_Modification implements PlugInFilter {
	
	public int setup (String arg, ImagePlus im) {
		return DOES_8G;
	}
	
	public void run (ImageProcessor ip) {
		int w = ip.getWidth();
		int h = ip.getHeight();
		
		for (int u = 0; u < w; u++) {
			for (int v = 0; v < h; v++) {
				int p = ip.getPixel(u, v);
				ip.putPixel(u, v, (int)(16*Math.sqrt(p)));
			}
		}
	}
}