/* Project 1
 */

import java.awt.BorderLayout;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.KeyEvent;
import java.awt.image.BufferedImage;
import java.awt.*;
import java.util.*;
import java.io.*;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.swing.*;

public class CBIR extends JFrame {

	private JLabel photographLabel = new JLabel(); // container to hold a large
	private JButton[] button; // creates an array of JButtons
	private JCheckBox[] relevantButton;
	private int[] buttonOrder = new int[101]; // creates an array to keep up
												// with the image order
	private double[] imageSize = new double[101]; // keeps up with the image
													// sizes
	private GridLayout gridLayout1;
	private GridLayout gridLayout2;
	private GridLayout gridLayout3;
	private GridLayout gridLayout4;
	String lastMethod = "null";
	boolean selectedRelevant[] = new boolean[101];

	private JPanel panelBottom1;
	private JPanel panelBottom2;
	private JPanel panelTop;
	private JPanel buttonPanel;
	private Double[][] intensityMatrix = new Double[100][26];
	private Double[][] colorCodeMatrix = new Double[100][65];
	private Double[][] intensityAndCCMatrix = new Double[100][90];
	private Double[] weight = new Double[101];
	private Double[][] relevantImages;
	private Map<Double, Integer> distanceMap;
	private Map<Double, Integer> distanceMap2;
	private Map<Double, Integer> distanceMap3;
	int picNo = 0;
	int imageCount = 1; // keeps up with the number of images displayed since
						// the first page.
	int pageNo = 1;
	boolean relevantSelected = false;
	boolean newWeight = false;

	public static void main(String args[]) {
		new readImage();
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				CBIR app = new CBIR();
				app.setVisible(true);
			}
		});
	}

	public CBIR() {
		// The following lines set up the interface including the layout of the
		// buttons and JPanels.
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setTitle("Icon Demo: Please Select an Image");
		panelBottom1 = new JPanel();
		panelBottom2 = new JPanel();
		panelTop = new JPanel();
		buttonPanel = new JPanel();
		gridLayout1 = new GridLayout(4, 5, 5, 5);
		gridLayout2 = new GridLayout(2, 1, 5, 5);
		gridLayout3 = new GridLayout(1, 2, 5, 5);
		gridLayout4 = new GridLayout(2, 2, 1, 1);

		setLayout(gridLayout2);
		panelBottom1.setLayout(gridLayout1);
		// panelBottom1.setLayout(gridBagLayout1);
		panelBottom2.setLayout(gridLayout1);
		panelTop.setLayout(gridLayout3);
		add(panelTop);
		add(panelBottom1);
		photographLabel.setVerticalTextPosition(JLabel.BOTTOM);
		photographLabel.setHorizontalTextPosition(JLabel.CENTER);
		photographLabel.setHorizontalAlignment(JLabel.CENTER);

		photographLabel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
		buttonPanel.setLayout(gridLayout4);
		buttonPanel.setPreferredSize(new Dimension(20, 20));
		panelTop.add(photographLabel);

		panelTop.add(buttonPanel);
		JButton previousPage = new JButton("Previous Page");
		JButton nextPage = new JButton("Next Page");
		JButton intensity = new JButton("Intensity");
		JButton colorCode = new JButton("Color Code");

		JButton refresh = new JButton("Refresh");
		JButton intensityAndCC = new JButton("Intensity + Color Code");
		JCheckBox relevance = new JCheckBox("Relevant");
		buttonPanel.add(previousPage);
		buttonPanel.add(nextPage);
		buttonPanel.add(intensity);
		buttonPanel.add(colorCode);
		buttonPanel.add(refresh);
		buttonPanel.add(intensityAndCC);
		buttonPanel.add(relevance);

		nextPage.addActionListener(new nextPageHandler());
		previousPage.addActionListener(new previousPageHandler());
		intensity.addActionListener(new intensityHandler());
		colorCode.addActionListener(new colorCodeHandler());
		refresh.addActionListener(new refreshHandler());
		intensityAndCC.addActionListener(new intensityAndCCHandler());
		relevance.addItemListener(new relevanceHandler());

		// Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
		setSize(1170, 950);
		// this centers the frame on the screen
		setLocationRelativeTo(null);

		button = new JButton[101];
		relevantButton = new JCheckBox[101];

		// Fill boolean array and weight array
		for (int i = 0; i < 101; i++) {
			selectedRelevant[i] = false;
		}
		for (int i = 0; i < weight.length; i++) {
			weight[i] = 1.0 / 89.0;
		}

		/*
		 * This for loop goes through the images in the database and stores them
		 * as icons and adds the images to JButtons and then to the JButton
		 * array
		 */

		for (int i = 1; i < 101; i++) {
			button[i] = new JButton();
			relevantButton[i] = new JCheckBox("Relevant");
			button[i].setSize(70, 90);
			int height = button[i].getHeight();
			int width = button[i].getWidth();
			button[i].setOpaque(false);
			button[i].setContentAreaFilled(false);
			button[i].setBorderPainted(false);

			ImageIcon icon2;
			icon2 = new ImageIcon(getClass().getResource("image/" + i + ".jpg"));
			Image img = icon2.getImage();
			Image newimg = img.getScaledInstance(width + 120, height,
					java.awt.Image.SCALE_SMOOTH);
			ImageIcon icon;
			icon = new ImageIcon(newimg);

			if (icon != null) {
				button[i].setIcon(icon);
				button[i].addActionListener(new IconButtonHandler(i, icon));
				buttonOrder[i] = i;
				imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
						.getIconWidth());
			}// end if
		}// end for
		readIntensityFile();

		readColorCodeFile();
		displayFirstPage();
		this.validate();
		normalization();
	}

	/*
	 * This method opens the intensity text file containing the intensity matrix
	 * with the histogram bin values for each image. The contents of the matrix
	 * are processed and stored in a two dimensional array called
	 * intensityMatrix.
	 */
	public void readIntensityFile() {

		StringTokenizer token;
		Scanner read;
		Double intensityBin;
		String line = "";
		int lineNumber = 0;
		try {
			read = new Scanner(new File("src/intensity.txt"));
			// ///////////////////
			// /your code///
			// ///////////////
			while (read.hasNextLine()) { // Run through every line in the file
				int binCount = 0; // Keep track of when we are accessing the
									// next bin
				while (read.hasNextInt()) { // Keep reading in the pixel values
											// in the bin till the line is empty
					if (binCount == 0) {
						imageSize[lineNumber + 1] = read.nextDouble();
						binCount++;
					} else {
						double i = read.nextDouble();
						intensityMatrix[lineNumber][binCount] = i;
						// intensityAndCCMatrix[lineNumber][binCount] = i;
						binCount++;
						if (binCount % 26 == 0) {
							lineNumber++;
							binCount = 0;
						}
					}
				}
				line = read.nextLine();
			}

		} catch (FileNotFoundException EE) {
			System.out.println("The file intensity.txt does not exist");
		}
		System.out.println();
	}

	/*
	 * This method opens the color code text file containing the color code
	 * matrix with the histogram bin values for each image. The contents of the
	 * matrix are processed and stored in a two dimensional array called
	 * colorCodeMatrix.
	 */
	private void readColorCodeFile() {
		StringTokenizer token;
		Scanner read;
		Double colorCodeBin;
		String line = "";
		int lineNumber = 0;
		try {
			read = new Scanner(new File("src/colorCodes.txt"));

			// ///////////////////
			// /your code///
			// ///////////////

			while (read.hasNextLine()) { // Run through every line in the file
				int binCount = 0; // Keep track of when we are accessing the
									// next bin
				while (read.hasNextInt()) { // Keep reading in the pixel values
											// in the bin till the line is empty
					if (binCount == 65) {
						imageSize[lineNumber + 1] = read.nextDouble();
						binCount++;
					} else {

						double i = read.nextDouble();
						colorCodeMatrix[lineNumber][binCount] = i;
						// if (binCount < 64) {
						// intensityAndCCMatrix[lineNumber][binCount + 26] = i;
						// }
						binCount++;
						if (binCount % 65 == 0) {
							lineNumber++;
							binCount = 0;

						}
					}
				}
				line = read.nextLine();
			}
		} catch (FileNotFoundException EE) {
			System.out.println("The file colorCodes.txt does not exist");
		}

	}

	/*
	 * This method displays the first twenty images in the panelBottom. The for
	 * loop starts at number one and gets the image number stored in the
	 * buttonOrder array and assigns the value to imageButNo. The button
	 * associated with the image is then added to panelBottom1. The for loop
	 * continues this process until twenty images are displayed in the
	 * panelBottom1
	 */
	private void displayFirstPage() {
		int imageButNo = 0;
		panelBottom1.removeAll();

		for (int i = 1; i < 21; i++) {
			// System.out.println(button[i]);
			imageButNo = buttonOrder[i];
			panelBottom1.add(button[imageButNo]);
			if (relevantSelected) {
				panelBottom1.add(relevantButton[imageButNo]);
			}
			imageCount++;
		}
		panelBottom1.revalidate();
		panelBottom1.repaint();

	}

	/*
	 * This class implements an ActionListener for each iconButton. When an icon
	 * button is clicked, the image on the the button is added to the
	 * photographLabel and the picNo is set to the image number selected and
	 * being displayed.
	 */
	private class IconButtonHandler implements ActionListener {
		int pNo = 0;
		ImageIcon iconUsed;

		IconButtonHandler(int i, ImageIcon j) {
			pNo = i;
			iconUsed = j; // sets the icon to the one used in the button
		}

		public void actionPerformed(ActionEvent e) {
			iconUsed = new ImageIcon(getClass().getResource(
					"image/" + pNo + ".jpg"));
			photographLabel.setIcon(iconUsed);
			picNo = pNo;
		}

	}

	/*
	 * This class implements an ActionListener for the nextPageButton. The last
	 * image number to be displayed is set to the current image count plus 20.
	 * If the endImage number equals 101, then the next page button does not
	 * display any new images because there are only 100 images to be displayed.
	 * The first picture on the next page is the image located in the
	 * buttonOrder array at the imageCount
	 */
	private class nextPageHandler implements ActionListener {

		public void actionPerformed(ActionEvent e) {
			int imageButNo = 0;
			int endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}
		}

	}

	/*
	 * This class implements an ActionListener for the previousPageButton. The
	 * last image number to be displayed is set to the current image count minus
	 * 40. If the endImage number is less than 1, then the previous page button
	 * does not display any new images because the starting image is 1. The
	 * first picture on the next page is the image located in the buttonOrder
	 * array at the imageCount
	 */
	private class previousPageHandler implements ActionListener {

		public void actionPerformed(ActionEvent e) {
			int imageButNo = 0;
			int startImage = imageCount - 40;
			int endImage = imageCount - 20;
			if (startImage >= 1) {
				panelBottom1.removeAll();
				/*
				 * The for loop goes through the buttonOrder array starting with
				 * the startImage value and retrieves the image at that place
				 * and then adds the button to the panelBottom1.
				 */
				for (int i = startImage; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount--;
				}
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}
		}

	}

	/*
	 * This class implements an ActionListener when the user selects the
	 * intensityHandler button. The image number that the user would like to
	 * find similar images for is stored in the variable pic. pic takes the
	 * image number associated with the image selected and subtracts one to
	 * account for the fact that the intensityMatrix starts with zero and not
	 * one. The size of the image is retrieved from the imageSize array. The
	 * selected image's intensity bin values are compared to all the other
	 * image's intensity bin values and a score is determined for how well the
	 * images compare. The images are then arranged from most similar to the
	 * least.
	 */

	private class intensityHandler implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			lastMethod = "I"; // For the relevance button
			double[] distance = new double[101];
			distanceMap = new HashMap<Double, Integer>();
			double d = 0;
			int compareImage = 0;
			int pic = (picNo - 1);
			int picIntensity = 0;
			double picSize = imageSize[pic];

			for (int i = 0; i < 100; i++) {
				for (int j = 1; j < 26; j++) {
					d += Math
							.abs((intensityMatrix[pic][j] / imageSize[pic + 1])
									- (intensityMatrix[i][j] / imageSize[i + 1]));
				}
				distance[i + 1] = d;
				distanceMap.put(d, i + 1);
				d = 0;
			}
			Arrays.sort(distance);

			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);
				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + distanceMap.get(distance[i]) + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);
				if (icon != null) {
					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap.get(distance[i]), icon));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());

				}
			}
			// repopulate the buttons
			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);
			}// end for i
			int imageButNo = 0;
			int endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}// end if
		}
	}

	/*
	 * This class implements an ActionListener when the user selects the
	 * colorCode button. The image number that the user would like to find
	 * similar images for is stored in the variable pic. pic takes the image
	 * number associated with the image selected and subtracts one to account
	 * for the fact that the intensityMatrix starts with zero and not one. The
	 * size of the image is retrieved from the imageSize array. The selected
	 * image's intensity bin values are compared to all the other image's
	 * intensity bin values and a score is determined for how well the images
	 * compare. The images are then arranged from most similar to the least.
	 */
	private class colorCodeHandler implements ActionListener {

		public void actionPerformed(ActionEvent e) {
			lastMethod = "CC";
			double[] distance = new double[101];
			distanceMap2 = new HashMap<Double, Integer>();
			double d = 0;
			int compareImage = 0;
			int pic = (picNo - 1);
			int picIntensity = 0;
			double picSize = imageSize[pic];

			// For each pixel in the color matrix place, compute the distance
			for (int i = 0; i < 100; i++) {
				for (int j = 0; j < 64; j++) {
					d += Math
							.abs((colorCodeMatrix[pic][j] / imageSize[pic + 1])
									- (colorCodeMatrix[i][j] / imageSize[i + 1]));
				}

				distance[i + 1] = d;
				distanceMap2.put(d, i + 1);
				d = 0;
			}

			Arrays.sort(distance);

			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);
				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + distanceMap2.get(distance[i]) + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);
				if (icon != null) {

					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap2.get(distance[i]), icon));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());

				}
			}

			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);
			}// end for i
			int imageButNo = 0;
			int endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}

		}

	}

	private class refreshHandler implements ActionListener {

		public void actionPerformed(ActionEvent e) {

			/*
			 * This for loop goes through the images in the database and stores
			 * them as icons and adds the images to JButtons and then to the
			 * JButton array
			 */

			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);

				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + i + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);

				if (icon != null) {
					// button[i] = new JButton();
					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(i, icon));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());
				}// end if
			}// end for
				// repopulate the buttons
			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);
			}// end for i
			int imageButNo = 0;
			int endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}// end if
			lastMethod = "R";
		}
	}

	private class intensityAndCCHandler implements ActionListener, ItemListener {
		public void actionPerformed(ActionEvent e) {
			lastMethod = "I+CC";
			if (newWeight) {
				calcWeight();
			}
			Double[] distance = new Double[101];
			distanceMap3 = new HashMap<Double, Integer>();
			Double d = 0.0;
			int compareImage = 0;
			int pic = (picNo);
			int picIntensity = 0;
			double picSize = imageSize[pic + 1];

			for (int i = 0; i < 100; i++) {
				Double temp[] = intensityAndCCMatrix[pic - 1];
				Double temp2[] = intensityAndCCMatrix[i];
				for (int j = 0; j < 89; j++) {
					Double r1 = temp[j] / imageSize[pic + 1];
					Double r2 = temp2[j] / imageSize[i + 1];
					d += (weight[i] * Math.abs(r1 - r2));
				}

				distance[i + 1] = d;
				distanceMap3.put(d, i + 1);
				d = 0.0;
			}
			distance[0] = 0.0;
			Arrays.sort(distance);

			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);

				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + distanceMap3.get(distance[i]) + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);
				if (icon != null) {
					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap3.get(distance[i]), icon));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());
				}
			}
			// repopulate the buttons
			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);

			}// end for i
				// Set the 20 images the user sees to the first 20
			int imageButNo = 0;
			int endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}
			
		}





		public void itemStateChanged(ItemEvent e) {
			System.out.println("State Change");

		}
		private double getMin(Double[] standardDev) {
			double lowest = (double) Integer.MAX_VALUE;
			for(int i = 0; i < standardDev.length; i++) {
				if(standardDev[i] < lowest && standardDev[i] != 0) {
					lowest = standardDev[i];
				}
			}
			return lowest;
		}
	}

	private void calcWeight() {
		List<Integer> indicesOfRelevant = new ArrayList<Integer>();
		Double[] standardDev = new Double[89];
		Double[] updatedWeight = new Double[89];
		for (int i = 0; i < selectedRelevant.length; i++) {
			selectedRelevant[picNo] = true;
			if (selectedRelevant[i]) {
				indicesOfRelevant.add(i);
			}
		}
		relevantImages = new Double[indicesOfRelevant.size()][89];
		Double[] average = new Double[89];
		for (int i = 0; i < average.length; i++) {
			average[i] = 0.0;
			standardDev[i] = 0.0;
		}
		for (int i = 0; i < indicesOfRelevant.size(); i++) {
			for (int j = 0; j < 89; j++) {
				double test = indicesOfRelevant
						.get(i) - 1;
				relevantImages[i][j] = intensityAndCCMatrix[indicesOfRelevant
						.get(i) - 1][j];

			}
		}
		//Calculate Average
		for (int i = 0; i < 89; i++) {
			for (int j = 0; j < indicesOfRelevant.size(); j++) {
				average[i] += relevantImages[j][i];
			}
			average[i] /= indicesOfRelevant.size();
		}
		// calculate std
		for (int j = 0; j < 89; j++) {
			for (int i = 0; i < indicesOfRelevant.size(); i++) {
				standardDev[j] += Math
						.pow(Math.abs(relevantImages[i][j] - average[j]), 2);

			}// end i
			standardDev[j] = Math.sqrt(standardDev[j]/indicesOfRelevant.size());

		}// end j
		double min;
		if (standardDev[0] != 0.0)
			min = standardDev[0];
		else
			min = 1;
		for (int i = 1; i < 89; i++) {
			if ((min > standardDev[i]) && (standardDev[i] != 0.0))
				min = standardDev[i];
		}// end if

		for (int i = 0; i < 89; i++) {
			if ((standardDev[i] == 0.0) && (average[i] != 0.0)) {
				standardDev[i] = min * 0.5;
			}

		}// end for

		//calculate the updated weight 
        Double sum = 0.0;
        for (int i = 0; i < 89; i++){
            if (standardDev[i] != 0.0)
                updatedWeight[i] = 1/standardDev[i];
            else if(standardDev[i] == 0.0){
                 updatedWeight[i] = 0.0;
           }//end if
            sum += updatedWeight[i];
        }//end for i

        for(int i = 0; i < 89; i++) {
        	weight[i] = updatedWeight[i] / sum;
        }
		System.out.println();
		// calculate weight
		// average
		// std
		// add to new matrix all of the buttons selected.
		// normalize weight

		
		
	}
	

	/*
	 * Normalizes all of the features from both intensity and color code
	 * matrices
	 */
	public void normalization() {
		Double[][] featureSet = new Double[101][89];
		Double[] average = new Double[89];
		Double[] standardDev = new Double[89];

		Arrays.fill(average, 0.0);
		Arrays.fill(standardDev, 0.0);

		// set all of the photo bins into one 2d array
		for (int j = 1; j < 101; j++) {
			for (int i = 0; i < 25; i++) {
				featureSet[j][i] = intensityMatrix[j - 1][i + 1] / imageSize[j];
			}// end for
			for (int i = 25; i < 89; i++) {
				featureSet[j][i] = colorCodeMatrix[j - 1][i - 25]
						/ imageSize[j];
			}// end for

		}// end for j

		// calc average
		for (int j = 0; j < 89; j++) {
			for (int i = 1; i < 101; i++) {
				average[j] += featureSet[i][j];
			}// end i
			average[j] /= 100;
		}// end j

		// calc standard dev.
		for (int j = 0; j < 89; j++) {
			for (int i = 1; i < 101; i++) {
				standardDev[j] += Math.pow(
						Math.abs(featureSet[i][j] - average[j]), 2);

			}// end i
			standardDev[j] /= 100; // size - 1
			standardDev[j] = Math.sqrt(standardDev[j]);

		}// end j
			// check zero case
		double min;
		if (standardDev[0] != 0.0)
			min = standardDev[0];
		else
			min = 1;
		for (int i = 1; i < 89; i++) {
			if ((min > standardDev[i]) && (standardDev[i] != 0.0))
				min = standardDev[i];
		}// end if

		for (int i = 0; i < 89; i++) {
			if ((standardDev[i] == 0.0) && (average[i] != 0.0)) {
				standardDev[i] = min * 0.5;
			}// end if

		}// end for
			// normalize featureSet

		for (int i = 1; i < 101; i++) {
			for (int j = 0; j < 89; j++) {
				if (standardDev[j] == 0.0) {
					intensityAndCCMatrix[i - 1][j] = 0.0;
				} else
					intensityAndCCMatrix[i - 1][j] = (featureSet[i][j] - average[j])
							/ standardDev[j];
			}// end for j
		}// end for i
	}// end normalizationCalculator

	private class relevanceHandler implements ActionListener, ItemListener {

		public void actionPerformed(ActionEvent e) {

		}

		public void itemStateChanged(ItemEvent e) {
			if (e.getStateChange() == ItemEvent.DESELECTED) {
				relevantSelected = false; // Set flag for rebuilding of the
											// buttons for without JCheckBox
											// buttons
			} else {
				relevantSelected = true;
			}
			setRelevanceButtons();
		}
	}

	private void setRelevanceButtons() {
		switch (lastMethod) {
		case "R":
			/*
			 * This for loop goes through the images in the database and stores
			 * them as icons and adds the images to JButtons and then to the
			 * JButton array
			 */

			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				relevantButton[i] = new JCheckBox();
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);

				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + i + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);

				if (icon != null) {
					// button[i] = new JButton();
					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(i, icon));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());
				}// end if
			}// end for
				// repopulate the buttons
			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);
			}// end for i
			int imageButNo = 0;
			int endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}// end if
			break;
		case "null":
			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				relevantButton[i] = new JCheckBox("Relevant");
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);

				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + i + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);

				if (icon != null) {
					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(i, icon));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());
				}// end if
			}// end for
				// repopulate the buttons
			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);
			}// end for i
			imageButNo = 0;
			endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}// end if

			break;
		case "I":
			double[] distance = new double[101];
			distanceMap = new HashMap<Double, Integer>();
			double d = 0;
			int compareImage = 0;
			int pic = (picNo - 1);
			int picIntensity = 0;
			double picSize = imageSize[pic];

			for (int i = 0; i < 100; i++) {
				for (int j = 1; j < 26; j++) {
					d += Math
							.abs((intensityMatrix[pic][j] / imageSize[pic + 1])
									- (intensityMatrix[i][j] / imageSize[i + 1]));
				}
				distance[i + 1] = d;
				distanceMap.put(d, i + 1);
				d = 0;
			}
			Arrays.sort(distance);

			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				relevantButton[i] = new JCheckBox("Relevant");
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);

				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + distanceMap.get(distance[i]) + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);
				if (icon != null) {
					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap.get(distance[i]), icon));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());

				}
			}
			// repopulate the buttons
			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);
				panelBottom1.add(relevantButton[i]);
			}// end for i
			imageButNo = 0;
			endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}// end if
			break;
		case "I+CC":

			distance = new double[101];
			distanceMap3 = new HashMap<Double, Integer>();
			d = 0.0;
			compareImage = 0;
			pic = (picNo);
			picIntensity = 0;
			picSize = imageSize[pic + 1];
			// normalization();

			for (int i = 0; i < 100; i++) {
				Double temp[] = intensityAndCCMatrix[pic - 1];
				Double temp2[] = intensityAndCCMatrix[i];

				for (int j = 0; j < 89; j++) {
					Double r1 = temp[j] / imageSize[pic + 1];
					Double r2 = temp2[j] / imageSize[i + 1];
					d += (weight[i] * Math.abs(r1 - r2));
				}

				distance[i + 1] = d;
				distanceMap3.put(d, i + 1);
				d = 0.0;
			}
			distance[0] = 0.0;
			Arrays.sort(distance);
			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				relevantButton[i] = new JCheckBox("Relevant");
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);

				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + distanceMap3.get(distance[i]) + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);
				if (icon != null) {
					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap3.get(distance[i]), icon));
					relevantButton[i].addActionListener(new weightHandler());
					relevantButton[i].setActionCommand(String.valueOf(i));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());
				}
			}
			// repopulate the buttons
			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);
			}// end for i
			imageButNo = 0;
			endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						// relevance.addItemListener(new relevanceHandler());
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}
			break;
		case "CC":
			distance = new double[101];
			distanceMap2 = new HashMap<Double, Integer>();
			d = 0;
			compareImage = 0;
			pic = (picNo - 1);
			picIntensity = 0;
			picSize = imageSize[pic];

			// For each pixel in the color matrix place, compute the distance
			for (int i = 0; i < 100; i++) {
				for (int j = 0; j < 64; j++) {
					d += Math
							.abs((colorCodeMatrix[pic][j] / imageSize[pic + 1])
									- (colorCodeMatrix[i][j] / imageSize[i + 1]));
				}

				distance[i + 1] = d;
				distanceMap2.put(d, i + 1);
				d = 0;
			}

			Arrays.sort(distance);

			for (int i = 1; i < 101; i++) {
				button[i] = new JButton();
				relevantButton[i] = new JCheckBox("Relevant");
				button[i].setSize(70, 90);
				int height = button[i].getHeight();
				int width = button[i].getWidth();
				button[i].setOpaque(false);
				button[i].setContentAreaFilled(false);
				button[i].setBorderPainted(false);
				ImageIcon icon2;
				icon2 = new ImageIcon(getClass().getResource(
						"image/" + distanceMap2.get(distance[i]) + ".jpg"));
				Image img = icon2.getImage();
				Image newimg = img.getScaledInstance(width + 120, height,
						java.awt.Image.SCALE_SMOOTH);
				ImageIcon icon;
				icon = new ImageIcon(newimg);
				if (icon != null) {
					button[i].setIcon(icon);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap2.get(distance[i]), icon));
					buttonOrder[i] = i;
					imageSize[i] = (Double) (double) (icon.getIconHeight() * icon
							.getIconWidth());

				}
			}

			imageCount = 1;
			for (int i = imageCount; i < 21; i++) {
				panelBottom1.add(button[buttonOrder[i]]);
			}// end for i
			imageButNo = 0;
			endImage = imageCount + 20;
			if (endImage <= 101) {
				panelBottom1.removeAll();
				for (int i = imageCount; i < endImage; i++) {
					imageButNo = buttonOrder[i];
					panelBottom1.add(button[imageButNo]);
					if (relevantSelected) {
						panelBottom1.add(relevantButton[imageButNo]);
					}
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}
		}
	}

	private class weightHandler implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			int imgSelected = Integer.parseInt(e.getActionCommand());
			if (selectedRelevant[imgSelected] == false) {
				selectedRelevant[imgSelected] = true;
				newWeight = true;
			} else {
				selectedRelevant[imgSelected] = false;
			}

			System.out.println(imgSelected);
			System.out.println("Selected = " + selectedRelevant[imgSelected]);
		}

	}

}