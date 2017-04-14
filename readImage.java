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
	double colorCodeBins[] = new double[65];
	double colorCodeMatrix[][] = new double[100][65];

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
						.read(new File("src/images/" + imageCount + ".jpg"));
				int[][] pixelData = new int[img.getHeight() * img.getWidth()][3];
				int[] rgb;

				int counter = 0;
				for (int i = 0; i < img.getHeight(); i++) {
					for (int j = 0; j < img.getWidth(); j++) {
						rgb = getPixelData(img, j, i);
						double intensity = computeIntensity(rgb[0], rgb[1], rgb[2]);
						addToBins((int) intensity); // Add intensity to bins
						addToBinsCC(rgb[0], rgb[1], rgb[2]); // Add color code
																// to CC bins

						for (int k = 0; k < rgb.length; k++) {
							pixelData[counter][k] = rgb[k];
						}
						counter++;
					}
				}

				int totalPixels = 0;
				for (int q = 1; q < 26; q++) { // Start at 0 for first bin with
												// values, end at bin 24
					intensityMatrix[imageCount - 1][q] = intensityBins[q];
					intensityBins[q] = 0; // Reset values to 0 in the bins
					totalPixels += intensityMatrix[imageCount-1][q];
				}
				intensityMatrix[imageCount-1][0] = totalPixels;
				totalPixels = 0;

				for (int q = 0; q < 64; q++) {
					colorCodeMatrix[imageCount-1][q] = colorCodeBins[q]; // Write CC bins into CC matrix
					totalPixels += colorCodeBins[q];
					colorCodeBins[q] = 0; // Reset values for the next iteration
				}
				colorCodeMatrix[imageCount-1][64] = totalPixels;

			} catch (IOException e) {
				System.out.println("Error occurred when reading the file.");
			}

			imageCount++;
		}
		writeIntensity();
		writeColorCode();
	}

	private void addToBinsCC(int red, int green, int blue) {
		int[] redBinary = convertBinary(red);
		int[] greenBinary = convertBinary(green);
		int[] blueBinary = convertBinary(blue);
		int[] transCC = new int[6]; // Set transCC size to 6 for 2 bits from
									// each color to be added together
		transCC = setTransCC(transCC, redBinary, greenBinary, blueBinary);

		int decimalRep = binaryToDecimal(transCC); // Convert the transformed CC
													// number to the 6 bit
													// decimal number
		colorCodeBins[decimalRep]++; // Add 1 to total pixels at the converted
										// decimal number bin

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
			if (range >= 250) {
				intensityBins[histBin]++;
				added = true;
			} else if (intensity < range) {
				intensityBins[histBin]++;
				added = true;
			} else {
				range += 10;
				histBin++;
			}
		}

	}

	public int[] convertBinary(int no) {

		int i = 0, temp[] = new int[9];
		int binary[] = new int[9];
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

		return rgb;
	}


	// This method writes the contents of the colorCode matrix to a file named
	// colorCodes.txt.
	public void writeColorCode() {
		// ///////////////////
		// /your code///
		// ///////////////
		String fileName = "colorCodes.txt";
		try {
			// Assuming default encoding.
			FileWriter fileWriter = new FileWriter(fileName);

			BufferedWriter bufferedWriter = new BufferedWriter(fileWriter); // Wrap
																			// FileWriter
																			// in
																			// BufferedWriter.

			int size = 100;

			for (int i = 0; i < size; i++) {
				for (int j = 0; j < 65; j++) {
					String toPrint = "" + (int) colorCodeMatrix[i][j];
					bufferedWriter.write(toPrint);
					bufferedWriter.write(" ");
				}
				bufferedWriter.newLine();
			}
			bufferedWriter.close();
		} catch (IOException ex) {
			System.out.println("Error writing to file '" + fileName + "'");
		}
	}

	// This method writes the contents of the intensity matrix to a file called
	// intensity.txt
	public void writeIntensity() {
		// ///////////////////
		// /your code///
		// ///////////////

		String fileName = "intensity.txt";
		try {
			// Assuming default encoding.
			FileWriter fileWriter = new FileWriter(fileName);

			BufferedWriter bufferedWriter = new BufferedWriter(fileWriter); 

			int size = 100;
			int totalPixels = 0;
			for (int i = 0; i < size; i++) {
				for (int j = 0; j < 26; j++) {
					String toPrint = "" + (int) intensityMatrix[i][j];
					bufferedWriter.write(toPrint);
					bufferedWriter.write(" ");
				}
				bufferedWriter.newLine();
			}
			bufferedWriter.close();
		} catch (IOException ex) {
			System.out.println("Error writing to file '" + fileName + "'");
		}
	}

	public static void main(String[] args) {
		new readImage();
	}

}