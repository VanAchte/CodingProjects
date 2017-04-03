/* Project 1
 */

import java.awt.BorderLayout;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
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
import javax.swing.AbstractAction;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JToolBar;
import javax.swing.SwingUtilities;
import javax.swing.SwingWorker;
import javax.swing.*;

public class CBIR extends JFrame {

	private JLabel photographLabel = new JLabel(); // container to hold a large
	private JButton[] button; // creates an array of JButtons
	private int[] buttonOrder = new int[101]; // creates an array to keep up
												// with the image order
	private double[] imageSize = new double[101]; // keeps up with the image
													// sizes
	private GridLayout gridLayout1;
	private GridLayout gridLayout2;
	private GridLayout gridLayout3;
	private GridLayout gridLayout4;
	private JPanel panelBottom1;
	private JPanel panelBottom2;
	private JPanel panelTop;
	private JPanel buttonPanel;
	private Double[][] intensityMatrix = new Double[101][26];
	private Double[][] colorCodeMatrix = new Double[100][65];
	private Map<Double, LinkedList<Integer>> map;
	int picNo = 0;
	int imageCount = 1; // keeps up with the number of images displayed since
						// the first page.
	int pageNo = 1;

	public static void main(String args[]) {

		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				CBIR app = new CBIR();
				app.setVisible(true);
			}
		});
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
			double[] distance = new double[101];
			map = new HashMap<Double, LinkedList<Integer>>();
			double d = 0;
			int compareImage = 0;
			int pic = (picNo - 1);
			int picIntensity = 0;
			double picSize = imageSize[pic];
		    
			
			// ///////////////////
			// /your code///
			// ///////////////
		}
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
		gridLayout4 = new GridLayout(2, 3, 5, 5);
		setLayout(gridLayout2);
		panelBottom1.setLayout(gridLayout1);
		panelBottom2.setLayout(gridLayout1);
		panelTop.setLayout(gridLayout3);
		add(panelTop);
		add(panelBottom1);
		photographLabel.setVerticalTextPosition(JLabel.BOTTOM);
		photographLabel.setHorizontalTextPosition(JLabel.CENTER);
		photographLabel.setHorizontalAlignment(JLabel.CENTER);
		photographLabel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
		buttonPanel.setLayout(gridLayout4);
		panelTop.add(photographLabel);

		panelTop.add(buttonPanel);
		JButton previousPage = new JButton("Previous Page");
		JButton nextPage = new JButton("Next Page");
		JButton intensity = new JButton("Intensity");
		JButton colorCode = new JButton("Color Code");
		buttonPanel.add(previousPage);
		buttonPanel.add(nextPage);
		buttonPanel.add(intensity);
		buttonPanel.add(colorCode);

		nextPage.addActionListener(new nextPageHandler());
		previousPage.addActionListener(new previousPageHandler());
		intensity.addActionListener(new intensityHandler());
		colorCode.addActionListener(new colorCodeHandler());
		setSize(1100, 750);
		// this centers the frame on the screen
		setLocationRelativeTo(null);

		button = new JButton[101];
		/*
		 * This for loop goes through the images in the database and stores them
		 * as icons and adds the images to JButtons and then to the JButton
		 * array
		 */
		for (int i = 1; i < 101; i++) {
			ImageIcon icon;
			icon = new ImageIcon(getClass().getResource("image/" + i + ".jpg"));

			if (icon != null) {
				button[i] = new JButton(icon);
				// panelBottom1.add(button[i]);
				button[i].addActionListener(new IconButtonHandler(i, icon));
				buttonOrder[i] = i;
			}
		}

		readIntensityFile();
		readColorCodeFile();
		displayFirstPage();
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
			while (read.hasNextLine()) {          // Run through every line in the file
				int binCount = 0;                 // Keep track of when we are accessing the next bin
				while (read.hasNextInt()) {       // Keep reading in the pixel values in the bin till the line is empty
					if (binCount == 0) {
						imageSize[lineNumber+1] = read.nextDouble();
						binCount++;
					} else {

						double i = read.nextDouble();
						System.out.println(i);
						intensityMatrix[lineNumber][binCount] = i;
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

			while (read.hasNextLine()) {          // Run through every line in the file
				int binCount = 0;                 // Keep track of when we are accessing the next bin
				while (read.hasNextInt()) {       // Keep reading in the pixel values in the bin till the line is empty
					if (binCount == 65) {
						imageSize[lineNumber+1] = read.nextDouble();
						binCount++;
					} else {

						double i = read.nextDouble();
						System.out.println(i);
						colorCodeMatrix[lineNumber][binCount] = i;
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
			double[] distance = new double[101];
			map = new HashMap<Double, LinkedList<Integer>>();
			double d = 0;
			int compareImage = 0;
			int pic = (picNo - 1);
			int picIntensity = 0;
			double picSize = imageSize[pic];
			System.out.println("pic = " + pic + " compareImage = " + compareImage);

			for (int i = 0; i < 100; i++) {
				for (int j = 1; j < 26; j++) {
					intensityMatrix[i][j] = 2.3;
				}
			}

            //distance[pic] = 
			// ///////////////////
			// /your code///
			// ///////////////
			

		}
	}
}
