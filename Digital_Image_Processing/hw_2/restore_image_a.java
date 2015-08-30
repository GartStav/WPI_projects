import java.awt.Dialog;

import ij.IJ;
import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.plugin.filter.RankFilters;
import ij.plugin.filter.UnsharpMask;
import ij.WindowManager;
import ij.gui.GenericDialog;
import ij.process.*;
 
public class restore_image_a implements PlugInFilter {

	public int setup (String arg, ImagePlus im) {
		return DOES_ALL;
	}
	
	public void run (ImageProcessor orig) {
		
		RankFilters rf = new RankFilters();
		double radius = 1;
		rf.rank(orig, radius, RankFilters.MEDIAN);
		
	}
		
}
	
	
	
	
	
	
	
	