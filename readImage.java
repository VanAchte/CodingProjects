/*
 * Project 1
 */

import java.awt.image.BufferedImage;
import java.lang.Object.*;
import javax.swing.*;
import java.io.*;
import java.util.*;
import javax.imageio.ImageIO;
import java.awt.image.DataBufferByte;

public class readImage {
	int imageCount = 1;
	double intensityBins[] = new double[26];
	double intensityMatrix[][] = new double[100][26];
	double colorCodeBins[] = new double[64];
	double colorCodeMatrix[][] = new double[100][64];

	/*
	 * Each image is retrieved from the file. The height and width are found for
	 * the image and the getIntensity and getColorCode methods are called.
	 */
	public readImage() {
		while (imageCount < 101) {
			// // the line that reads the image file
			// ///////////////////
			// ///your code///
			// //////////////////
			BufferedImage img = null;
			try {
				img = ImageIO
						.read(new File("src/image/" + imageCount + ".jpg"));       // Get the image file from the folder

				int[][] pixelData = new int[img.getHeight() * img.getWidth()][3];
				int[] rgb;
				System.out.println("Image height = " + img.getHeight()
						+ "\nImage width = " + img.getWidth());
				int counter = 0;
				for (int i = 0; i < img.getHeight(); i++) {
					for (int j = 0; j < img.getWidth(); j++) {
						rgb = getPixelData(img, j, i);
						double intensity = computeIntensity(rgb[0], rgb[1],   // Get the intensity
								rgb[2]);
						addToBins((int) intensity);                   // Add intensity to bins
						addToBinsCC(rgb[0], rgb[1], rgb[2]);          // Add color code to CC bins
						intensityMatrix[imageCount] = intensityBins;  // Write bins into matrix
						colorCodeMatrix[imageCount] = colorCodeBins;  // Write CC bins into CC matrix
//						for(int a = 0; a < 25; a++) {
//							System.out.println("intensityMatrix[imageCount][a] = " + intensityMatrix[imageCount][a]);
//						}
						System.out.println("Intensity = " + intensity);
						for (int k = 0; k < rgb.length; k++) {
							pixelData[counter][k] = rgb[k];
							System.out
									.println("pixelData[counter][k] = rgb[k] = "
											+ pixelData[counter][k]);
						}
						counter++;
					}
				}
				writeIntensity();                   
				writeColorCode();
				int totalPixels = 0;
				for (int p = 0; p < intensityBins.length; p++) {
					System.out.println("Intensity Bins Value = "
							+ intensityBins[p]);
					totalPixels += intensityBins[p];
				}
				System.out.println("Total pixels = " + totalPixels);
				totalPixels = 0;
		        for(int l = 0; l < colorCodeBins.length; l++) {
		        	System.out.println("ColorCodeBins = " + colorCodeBins[l]);
		        	totalPixels += colorCodeBins[l];
		        }
		        System.out.println("Total pixels = " + totalPixels);
				imageCount++;
			} catch (IOException e) {
				System.out.println("Error occurred when reading the file.");
			}
		}
	}

	private void addToBinsCC(int red, int green, int blue) {
		int[] redBinary = convertBinary(red);
		int[] greenBinary = convertBinary(green);
		int[] blueBinary = convertBinary(blue);
		System.out.println("Red = " + red);
		for (int i = 0; i < redBinary.length; i++) {

			System.out.print(redBinary[i]);
		}
		System.out.println();
		int[] transCC = new int[6]; // Set transCC size to 6 for 2 bits from
									// each color to be added together
		transCC = setTransCC(transCC, redBinary, greenBinary, blueBinary);

		System.out.print("transCC[] = ");
		for (int i = 0; i < 6; i++) {
			System.out.print(transCC[i]);
		}
		System.out.println();
		int decimalRep = binaryToDecimal(transCC);  // Convert the transformed CC number to the 6 bit decimal number
		System.out.println("decimalRep = " + decimalRep);
        colorCodeBins[decimalRep]++;                  // Add 1 to total pixels at the converted decimal number bin

	}

	private int binaryToDecimal(int[] transCC) {
		int total = 0;
		int binaryVal = 1;
		for (int i = transCC.length - 1; i >= 0; i--) {
			if (transCC[i] == 1) {
				total += binaryVal;
			}
			binaryVal *= 2;
		}
		return total;
	}

	private int[] setTransCC(int[] transCC, int[] redBinary, int[] greenBinary,
			int[] blueBinary) {

		for (int i = 0; i < 6; i++) {
			int index = i % 2;
			if (i < 2) {
				transCC[i] = redBinary[index];
			} else if (i < 4) {
				transCC[i] = greenBinary[index];
			} else if (i < 6) {
				transCC[i] = blueBinary[index];
			}
		}

		return transCC;
	}

	private void addToBins(int intensity) {
		int range = 10;
		int histBin = 1;
		boolean added = false;
		while (range > 250 || added == false) {
			if (intensity < range) {
				intensityBins[histBin]++;
				added = true;
			} else {
				range += 10;
				histBin++;
			}
		}

	}

	public int[] convertBinary(int no) {

		int i = 0, temp[] = new int[8];
		int binary[] = new int[8];
		while (no > 0 && i < binary.length) {
			temp[i++] = no % 2;
			no /= 2;
		}
		binary = new int[i];
		int k = 0;
		for (int j = i - 1; j >= 0; j--) {
			binary[k++] = temp[j];
		}

		if (binary.length < 8) {
			int fullBinRep[] = new int[8];
			int fullBinSize = fullBinRep.length - 1;
			for (int j = binary.length - 1; j >= 0; j--) {
				fullBinRep[fullBinSize] = binary[j];
				fullBinSize--;
			}
			return fullBinRep;
		}
		return binary;
	}

	public static double computeIntensity(int red, int green, int blue) {
		return (.299 * red) + (.587 * green) + (.114 * blue);
	}

	private static int[] getPixelData(BufferedImage img, int x, int y) {
		int argb = img.getRGB(x, y);

		int rgb[] = new int[] { (argb >> 16) & 0xff, // red
				(argb >> 8) & 0xff, // green
				(argb) & 0xff // blue
		};

		System.out.println("rgb: " + rgb[0] + " " + rgb[1] + " " + rgb[2]);
		return rgb;
	}

	// intensity method

	public void getIntensity(BufferedImage image, int height, int width) {

		// ///////////////////
		// /your code///
		// ///////////////

	}

	// color code method
	public void getColorCode(BufferedImage image, int height, int width) {
		// ///////////////////
		// /your code///
		// ///////////////
	}

	// /////////////////////////////////////////////
	// add other functions you think are necessary//
	// /////////////////////////////////////////////

	// This method writes the contents of the colorCode matrix to a file named
	// colorCodes.txt.
	public void writeColorCode() {
		// ///////////////////
		// /your code///
		// ///////////////
	}

	// This method writes the contents of the intensity matrix to a file called
	// intensity.txt
	public void writeIntensity() {
		// ///////////////////
		// /your code///
		// ///////////////
		
		String fileName = "src/intensity.txt";
		 try {
	            // Assuming default encoding.
	            FileWriter fileWriter =
	                new FileWriter(fileName);

	            BufferedWriter bufferedWriter =               
	                new BufferedWriter(fileWriter);           //Wrap FileWriter in BufferedWriter.


	            int size = 100;
	            bufferedWriter.write("Intensity File");
	            bufferedWriter.newLine();
	            bufferedWriter.write("Number of Pixels in Each Bin:");
	            bufferedWriter.newLine();
	            for(int i = 0; i < size; i++) {
	            	bufferedWriter.write("Image #" + i);
	            	bufferedWriter.newLine();
	            	bufferedWriter.write("         Row " + 0);
	                for(int j = 1; j < 26; j++) {
	                	bufferedWriter.write("Row " + j);
	                }
	                bufferedWriter.newLine();
	                bufferedWriter.write("          ");
	                for(int j = 0; j < 26; j++) {
	                	
	                	bufferedWriter.write("     ");
	                }
	                bufferedWriter.newLine();
	            }
	            bufferedWriter.close();
	        }
	        catch(IOException ex) {
	            System.out.println(
	                "Error writing to file '"
	                + fileName + "'");
	        }
	    }

	public static void main(String[] args) {
		new readImage();
	}

}
