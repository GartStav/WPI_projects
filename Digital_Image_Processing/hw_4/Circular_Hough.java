/* Hough Transform
 * Implementation based on Hemerson Pistori Hough Transform (pistori@ec.ucdb.br)
 */

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
 
public class Circular_Hough implements PlugInFilter {
	
	public int setup(String arg, ImagePlus im) {
		return DOES_ALL + NO_CHANGES;
	}
	
	int circlesToDetetct = 3;
	int minRadius = 10;
	int maxRadius = 40;
	int deltaRadius = 2;
		
    int width;
    int height;
    double[][][] accumArray;
    Point centers[];
    int radiuses[];
	
	public void run(ImageProcessor ipOrig) {
		
		width = ipOrig.getWidth();
        height = ipOrig.getHeight();
		byte[] pixels = (byte[])ipOrig.getPixels();
		int depth = ((maxRadius-minRadius)/deltaRadius)+1;
        
        int incDen = Math.round (8F * minRadius); 

        int[][][] table = new int[2][incDen][depth];

        int tableSize = 0;
        for(int r = minRadius; r <= maxRadius; r = r+deltaRadius) {
        	tableSize = 0;
            for(int incNun = 0; incNun < incDen; incNun++) {
                double angle = (2*Math.PI * (double)incNun) / (double)incDen;
                int indexR = (r-minRadius)/deltaRadius;
                int rcos = (int)Math.round ((double)r * Math.cos (angle));
                int rsin = (int)Math.round ((double)r * Math.sin (angle));
                if((tableSize == 0) | (rcos != table[0][tableSize][indexR]) & (rsin != table[1][tableSize][indexR])) {
                	table[0][tableSize][indexR] = rcos;
                	table[1][tableSize][indexR] = rsin;
                	tableSize++;
                }
            }
        }

        accumArray = new double[width][height][depth];

        int k = width - 1;
        int l = height - 1;

        for(int y = 1; y < l; y++) {
            for(int x = 1; x < k; x++) {
                for(int r = minRadius; r <= maxRadius; r = r+deltaRadius) {
                    if( pixels[(x)+(y)*width] != 0 )  {// Edge pixel found
                        int indexR=(r-minRadius)/deltaRadius;
                        for(int i = 0; i < tableSize; i++) {

                            int a = x + table[1][i][indexR]; 
                            int b = y + table[0][i][indexR]; 
                            if((b >= 0) & (b < height) & (a >= 0) & (a < width)) {
                            	accumArray[a][b][indexR] += 1;
                            }
                        }

                    }
                }
            }
        }
            
        ImageProcessor res_ip = new FloatProcessor(width, height);
        
        if(centers == null) {
			getCenters(circlesToDetetct);
		}
        
        for (int i = 0; i < circlesToDetetct; i++) {
        	res_ip.drawOval(centers[i].x-radiuses[i], centers[i].y-radiuses[i], 2*radiuses[i], 2*radiuses[i]);
        }
        
        new ImagePlus("Hough results", res_ip).show();
    }

	    private void getCenters (int maxCircles) {
	        centers = new Point[maxCircles];
	        radiuses = new int[maxCircles];
	        int xMax = 0;
	        int yMax = 0;
	        int rMax = 0;
	        for(int c = 0; c < maxCircles; c++) {
	            double counterMax = -1;
	            for(int radius = minRadius;radius <= maxRadius;radius = radius+deltaRadius) {
	                int indexR = (radius-minRadius)/deltaRadius;
	                for(int y = 0; y < height; y++) {
	                    for(int x = 0; x < width; x++) {
	                        if(accumArray[x][y][indexR] > counterMax) {
	                            counterMax = accumArray[x][y][indexR];
	                            xMax = x;
	                            yMax = y;
	                            rMax = radius;
	                        }
	                    }
	                }
	            }
	            centers[c] = new Point (xMax, yMax);
	            radiuses[c] = rMax;
	            removeNoise(xMax,yMax,rMax);
	        }
	    }

	    private void removeNoise(int x,int y, int radius) {
	        double halfRadius = radius / 2.0F;
	        double halfSquared = halfRadius*halfRadius;
	        int y1 = (int)Math.floor ((double)y - halfRadius);
	        int y2 = (int)Math.ceil ((double)y + halfRadius) + 1;
	        int x1 = (int)Math.floor ((double)x - halfRadius);
	        int x2 = (int)Math.ceil ((double)x + halfRadius) + 1;
	        if(y1 < 0)
	            y1 = 0;
	        if(y2 > height)
	            y2 = height;
	        if(x1 < 0)
	            x1 = 0;
	        if(x2 > width)
	            x2 = width;
	        for(int r = minRadius;r <= maxRadius;r = r+deltaRadius) {
	            int indexR = (r-minRadius)/deltaRadius;
	            for(int i = y1; i < y2; i++) {
	                for(int j = x1; j < x2; j++) {	      	     
	                    if(Math.pow (j - x, 2D) + Math.pow (i - y, 2D) < halfSquared) {
	                    	accumArray[j][i][indexR] = 0.0D;
	                    }
	                }
	            }
	        }

	    }
	
} 