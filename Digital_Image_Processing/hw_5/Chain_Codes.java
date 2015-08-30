import ij.IJ;
import ij.process.*;
import ij.ImagePlus;
import ij.gui.GenericDialog;
import ij.plugin.filter.Convolver;
import ij.plugin.filter.PlugInFilter;
import ij.process.ByteProcessor;
import ij.process.ColorProcessor;
import ij.process.FloatProcessor;
import ij.process.ImageProcessor;

import java.awt.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import regions.*;
 
public class Chain_Codes implements PlugInFilter {

	
	public int setup(String arg, ImagePlus im) {

		return DOES_ALL + NO_CHANGES;
	}

	public void run(ImageProcessor ip) {

		int width = ip.getWidth();
		int height = ip.getHeight();
		
		RegionContourLabeling rclb = new RegionContourLabeling((ByteProcessor)ip.convertToByte(true));
		List<BinaryRegion> trueRegions = new ArrayList<BinaryRegion>();
		List<BinaryRegion> allRegions = new ArrayList<BinaryRegion>(rclb.getRegions());
		for (BinaryRegion r : allRegions) {
			if (r.getSize() > 100) {
				trueRegions.add(r);
			}
		}
		

		ColorProcessor cp = new ColorProcessor(width, height);

		for (BinaryRegion r : trueRegions) {
			List<Point> pnts = new ArrayList<Point>();
			pnts = r.getOuterContour().getPointList();
			boolean first = true;
			Point start_point = new Point();
			for (Point p: pnts) {
				if (first) {
					first = false;
					start_point.x = p.x;
					start_point.y = p.y;
				}
				cp.putPixel(p.x, p.y, -15662644);
			}
			byte[] code = encodeChainCode(pnts);
			String str = "Chain code for region:" + Arrays.toString(code);
			IJ.log(str);

			
			ColorProcessor cp_1 = new ColorProcessor(width, height);
			List<Point> pnts_rec = new ArrayList<Point>();
			pnts_rec = recoverChainCode(code, start_point);
			for (Point p_: pnts_rec) {
				cp_1.putPixel(p_.x, p_.y, -15662361);
			}
			ImagePlus win6 = new ImagePlus("Recovered_contour", cp_1);
			win6.show();
			
		}
		ImagePlus win4 = new ImagePlus("All contours", cp);
		win4.show(); 
		
	}
	
	byte[] encodeChainCode(List<Point> pnts) {
		int m = pnts.size();
		byte[] code = new byte[m];
		if (m>1) {
			boolean first = true;
			Point prev = new Point();
			int i = 0;
			for (Point p: pnts) {
				if (first) {
					first = false;
					prev.x = p.x;
					prev.y = p.y;
				}
				else {
					int delta_x = p.x - prev.x;
					int delta_y = p.y - prev.y;
					
					byte value = 0;
					if ((delta_x == 1) && (delta_y == 0)) value = 0;
					if ((delta_x == 1) && (delta_y == 1)) value = 1;
					if ((delta_x == 0) && (delta_y == 1)) value = 2;
					if ((delta_x == -1) && (delta_y == 1)) value = 3;
					if ((delta_x == -1) && (delta_y == 0)) value = 4;
					if ((delta_x == -1) && (delta_y == -1)) value = 5;
					if ((delta_x == 0) && (delta_y == -1)) value = 6;
					if ((delta_x == 1) && (delta_y == -1)) value = 7;
					code[i] = value;
					
					prev.x = p.x;
					prev.y = p.y;
					i++;
				}
			}
		}
		return code;
	}

	List<Point> recoverChainCode(byte[] code, Point start_p) {
		List<Point> pnts = new ArrayList<Point>();
		int m = code.length;
		if (m>1) {
			boolean first = true;
			pnts.add(start_p);
			Point prev_p = new Point();
			prev_p.x = start_p.x;
			prev_p.y = start_p.y;
			
			for (int i = 0; i<m; i++){
				int delta_x = 0;
				int delta_y = 0;
				if (code[i]==0) {
						delta_x = 1;
						delta_y = 0;}
				if (code[i]==1) {
						delta_x = 1;
						delta_y = 1;}
				if (code[i]==2) {
						delta_x = 0;
						delta_y = 1;}
				if (code[i]==3) {
						delta_x = -1;
						delta_y = 1;}
				if (code[i]==4) {
						delta_x = -1;
						delta_y = 0;}
				if (code[i]==5) {
						delta_x = -1;
						delta_y = -1;}
				if (code[i]==6) {
						delta_x = 0;
						delta_y = -1;}
				if (code[i]==7) {
						delta_x = 1;
						delta_y = -1;
				}
				Point next_p = new Point();

				next_p.x = prev_p.x + delta_x;
				next_p.y = prev_p.y + delta_y;
				pnts.add(next_p);
				prev_p.x = next_p.x;
				prev_p.y = next_p.y;
			}
			
			
		}
		return pnts;
	}

}
