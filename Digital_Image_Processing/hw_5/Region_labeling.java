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
import java.util.Formatter;
import java.util.Locale;

import java.awt.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import regions.*;
import sun.java2d.loops.DrawLine;
 
public class Region_labeling implements PlugInFilter {

	
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
		ColorProcessor cp__ = new ColorProcessor(width, height);
		cp__ = (ColorProcessor) rclb.makeLabelImage(true);
		ImagePlus win7 = new ImagePlus("Recovered_contour", cp__);
		win7.show();
		
		for (BinaryRegion r : trueRegions) {
			List<Point> pnts = new ArrayList<Point>();
			pnts = r.getOuterContour().getPointList();
			boolean first = true;
			Point start_point = new Point();
			for (Point p: pnts) {
				cp.putPixel(p.x, p.y, -15662644);
			}
			findGeometry(ip, r, rclb);
			/*byte[] code = encodeChainCode(pnts);
			String str = "Chain code for region:" + Arrays.toString(code);
			IJ.log(str);

			
			ColorProcessor cp_1 = new ColorProcessor(width, height);
			List<Point> pnts_rec = new ArrayList<Point>();
			pnts_rec = recoverChainCode(code, start_point);
			for (Point p_: pnts_rec) {
				cp_1.putPixel(p_.x, p_.y, -15662361);
			}
			/*ImagePlus win6 = new ImagePlus("Recovered_contour", cp_1);
			win6.show();*/
			
		}
		ImagePlus win4 = new ImagePlus("inverted", cp);
		win4.show(); 
		
	}
	
	static double moment(ImageProcessor ip,int p,int q, BinaryRegion reg, RegionContourLabeling rclb) {
		double Mpq = 0.0;
		int lb = reg. getLabel();
		for (int v = 0; v < ip.getHeight(); v++) {
			for (int u = 0; u < ip.getWidth(); u++) {
				if (rclb.getLabel(u,v) == lb) {
					Mpq += Math.pow(u, p) * Math.pow(v, q);
			}
		}
		}
		return Mpq;
	}
	
	static double centralMoment(ImageProcessor ip,int p,int q, BinaryRegion reg, RegionContourLabeling rclb)
	{
		double m00 = moment(ip, 0, 0, reg, rclb); // region area
		double xCtr = moment(ip, 1, 0, reg, rclb) / m00;
		double yCtr = moment(ip, 0, 1, reg, rclb) / m00;
		double cMpq = 0.0;
		int lb = reg. getLabel();
		for (int v = 0; v < ip.getHeight(); v++) {
			for (int u = 0; u < ip.getWidth(); u++) {
				if (rclb.getLabel(u,v) == lb) {
					cMpq +=	Math.pow(u - xCtr, p) *	Math.pow(v - yCtr, q);
				}
			}
		}
		return cMpq;
	}
	
	static void findGeometry(ImageProcessor ip, BinaryRegion reg, RegionContourLabeling rclb)
	{
		double dx = 0.;
		double dy = 0.;
		double A = 2*centralMoment(ip, 1, 1, reg, rclb);
		double B = centralMoment(ip, 2, 0, reg, rclb) - centralMoment(ip, 0, 2, reg, rclb);
		if (A!=B) {
			dx = Math.sqrt(1./2.*(1.+B/Math.sqrt((Math.pow(A, 2)+Math.pow(B, 2)))));
			if (A >= 0){
				dy = Math.sqrt(1./2.*(1.-B/Math.sqrt((Math.pow(A, 2)+Math.pow(B, 2)))));
			}
			else {
				dy = -Math.sqrt(1/2*(1-B/Math.sqrt((Math.pow(A, 2)+Math.pow(B, 2)))));
			}
		}
		
		double m20 = centralMoment(ip, 2, 0, reg, rclb);
		double m02 = centralMoment(ip, 0, 2, reg, rclb);
		double m11 = centralMoment(ip, 1, 1, reg, rclb);
		double ecc = (m20 + m02 + Math.sqrt(Math.pow((m20-m02),2) + 4*Math.pow(m11,2) ))/(m20 + m02 - Math.sqrt(Math.pow((m20-m02),2) + 4*Math.pow(m11,2) ));
		
		Formatter fm = new Formatter(new StringBuilder(), Locale.US);
		fm.format("Normalized xd (orient) = %.2f", dx);
		fm.format(", Normalized yd (orient) = %.2f", dy);
		fm.format(", Eccentricity = %.2f", ecc );
		String s = fm.toString();
		fm.close();
		IJ.log(s);
		
		double m00 = moment(ip, 0, 0, reg, rclb); // region area
		double xCtr = moment(ip, 1, 0, reg, rclb) / m00;
		double yCtr = moment(ip, 0, 1, reg, rclb) / m00;
		ip.drawLine((int)xCtr, (int)yCtr, (int)xCtr + (int)(dx*50), (int)yCtr + (int)(dy*50));
		ip.drawOval((int)xCtr-5,(int)yCtr-5,10,10);
		Rectangle rec = reg.getBoundingBox();
		ip.drawOval(rec.x, rec.y, rec.height, rec.width);
		ImagePlus win4 = new ImagePlus("inverted", ip);
		win4.show(); 
	}

}
