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

public class CBIR extends JFrame implements ItemListener {

	private JLabel photographLabel = new JLabel(); // container to hold a large
	private JButton[] button; // creates an array of JButtons
	private JCheckBox[] relevantButton;
	private int[] buttonOrder = new int[101]; // creates an array to keep up
												// with the image order
	private int[] relativeButtonOrder = new int[101];
	private double[] imageSize = new double[101]; // keeps up with the image
													// sizes
	private GridLayout gridLayout1;
	private GridLayout gridLayout2;
	private GridLayout gridLayout3;
	private GridLayout gridLayout4;
	private GridBagLayout gridBagLayout1;
	GridBagConstraints constraints;
	private JPanel panelBottom1;
	private JPanel panelBottom2;
	private JPanel panelTop;
	private JPanel buttonPanel;
	private Double[][] intensityMatrix = new Double[100][26];
	private Double[][] colorCodeMatrix = new Double[100][65];
	private Double[][] intensityAndCCMatrix = new Double[100][90];
	private Map<Double, Integer> distanceMap;
	private Map<Double, Integer> distanceMap2;
	int picNo = 0;
	int imageCount = 1; // keeps up with the number of images displayed since
						// the first page.
	int pageNo = 1;

	public static void main(String args[]) {
		new readImage();
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
			distanceMap2 = new HashMap<Double, Integer>();
			double d = 0;
			int compareImage = 0;
			int pic = (picNo - 1);
			int picIntensity = 0;
			double picSize = imageSize[pic];

			// For each pixel in the color matrix place, compute the distance
			for (int i = 0; i < 100; i++) {
				for (int j = 0; j < 64; j++) {
					d += Math.abs((colorCodeMatrix[pic][j] / imageSize[pic + 1])
									- (colorCodeMatrix[i][j] / imageSize[i + 1]));
				}

				distance[i + 1] = d;
				distanceMap2.put(d, i + 1);
				d = 0;
			}

			Arrays.sort(distance);
//			  for(int i = 1; i < 101; i++){
//		    	   button[i] = new JButton();
//		       }

			for (int i = 1; i < 101; i++) {
	        	button[i].setSize(70, 90); 
	       		int height = button[i].getHeight();
	       		int width = button[i].getWidth();
	       		button[i].setOpaque(false);
	    		button[i].setContentAreaFilled(false);
	    		button[i].setBorderPainted(false);

				ImageIcon icon;
				int test = distanceMap2.get(distance[i]);
				icon = new ImageIcon(getClass().getResource(
						"image/" + distanceMap2.get(distance[i]) + ".jpg"));

				if (icon != null) {
	                //button[i] = new JButton();
	            	button[i].setIcon(icon);
	                button[i].addActionListener(new IconButtonHandler(i, icon));
	                buttonOrder[i] = i;
	                imageSize[i] = (Double)(double)(icon.getIconHeight() *  icon.getIconWidth());

					button[i] = new JButton(icon);
					panelBottom1.add(button[i]);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap2.get(distance[i]), icon));
					buttonOrder[i] = i;
				}
			}

			int imageButNo = 0;
			panelBottom1.removeAll();
			for (int i = 1; i < 21; i++) {
				imageButNo = buttonOrder[i];
				panelBottom1.add(button[imageButNo]);
			}
			panelBottom1.revalidate();
			panelBottom1.repaint();


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
		gridLayout1 = new GridLayout(5, 4, 5, 5);
		gridLayout2 = new GridLayout(2, 1, 5, 5);
		gridLayout3 = new GridLayout(1, 2, 5, 5);
		gridLayout4 = new GridLayout(2, 2, 1, 1);
		
		
		gridBagLayout1 = new GridBagLayout();
		constraints = new GridBagConstraints();
		setGridBagConstraints();
		
		
//		setLayout(gridBagLayout1);
//	      c.weightx = 1;
//	      c.weighty = 1;
//	      c.gridx = 0;
//	      c.gridy = 0;
//	      c.anchor = GridBagConstraints.SOUTHWEST;
//	      gridBagLayout1.setConstraints(B1,c);
//	      B1.setBackground(Color.cyan);
//	      add(B1);
//	      c.weightx = 0;
//	      c.gridx = 1;
//	      c.anchor = GridBagConstraints.NORTH;
//	      c.fill = GridBagConstraints.BOTH;
//	      gridBagLayout1.setConstraints(B2,c);
//	      B2.setBackground(Color.pink);
//	      add(B2);
//	      B1.addActionListener(this);
//	      B2.addActionListener(this);
		setLayout(gridLayout2);
		panelBottom1.setLayout(gridLayout1);
		//panelBottom1.setLayout(gridBagLayout1);
		panelBottom2.setLayout(gridLayout1);
		panelTop.setLayout(gridLayout3);
		add(panelTop);
		add(panelBottom1);
		photographLabel.setVerticalTextPosition(JLabel.BOTTOM);
		photographLabel.setHorizontalTextPosition(JLabel.CENTER);
		photographLabel.setHorizontalAlignment(JLabel.CENTER);

		photographLabel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
		buttonPanel.setLayout(gridLayout4);
		buttonPanel.setPreferredSize(new Dimension(20,20));
		panelTop.add(photographLabel);

		panelTop.add(buttonPanel);
		JButton previousPage = new JButton("Previous Page");
		JButton nextPage = new JButton("Next Page");
		JButton intensity = new JButton("Intensity");
		JButton colorCode = new JButton("Color Code");
		
		/////////////////TEST
		JButton refresh = new JButton("Refresh");
		JButton intensityAndCC = new JButton("Intensity + Color Code");
		
		buttonPanel.add(previousPage);
		buttonPanel.add(nextPage);
		buttonPanel.add(intensity);
		buttonPanel.add(colorCode);
		buttonPanel.add(refresh);
		buttonPanel.add(intensityAndCC);
		
		nextPage.addActionListener(new nextPageHandler());
		previousPage.addActionListener(new previousPageHandler());
		intensity.addActionListener(new intensityHandler());
		colorCode.addActionListener(new colorCodeHandler());
		refresh.addActionListener(new refreshHandler());
		intensityAndCC.addActionListener(new intensityAndCCHandler());
		
		//Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
		setSize(1170, 950);
		// this centers the frame on the screen
		setLocationRelativeTo(null);

		button = new JButton[101];
		relevantButton = new JCheckBox[101];
		
        //relevantButton.setMnemonic(KeyEvent.VK_G);
        //relevantButton.setSelected(true);
		
		/*
		 * This for loop goes through the images in the database and stores them
		 * as icons and adds the images to JButtons and then to the JButton
		 * array
		 */
//		c.fill = GridBagConstraints.HORIZONTAL;
//		c.gridx = 0;
//		c.gridy = 0;
		
//		for (int i = 1; i < 101; i++) {
//			ImageIcon icon;
//			icon = new ImageIcon(getClass().getResource("image/" + i + ".jpg"));
//			   Image img = icon.getImage();  
//			   Image newimg = img.getScaledInstance( icon.getIconWidth(), icon.getIconHeight(),  java.awt.Image.SCALE_SMOOTH ) ;  
//			   icon = new ImageIcon( newimg );
//			if (icon != null) {
//				//button[i].setSize(20, 15);
//				//button[i].setPreferredSize(new Dimension(1, 1));
//				//c.fill = GridBagConstraints.HORIZONTAL;
////			if(i % 5 == 0) {
////				c.gridx++;
////			} else if(i % 4 == 0) {
////				c.gridy++;
////			}
//				
//				button[i] = new JButton(icon);
//				relevantButton[i] = new JCheckBox("Relevant");
//				relevantButton[i].addItemListener(this);
//				//panelBottom1.add(button[i]);
//				button[i].addActionListener(new IconButtonHandler(i, icon));
//				buttonOrder[i] = i;
//				
//				//relevantButton[i] = i;
//                
//				//System.out.println("height = " + button[i].getHeight() + "\nwidth = " + button[i].getWidth());
//			}
//		}
		  for(int i = 1; i < 101; i++){
	    	   button[i] = new JButton();
	       }
	      
	        
	        /*This for loop goes through the images in the database and stores them as icons and adds
	         * the images to JButtons and then to the JButton array
	        */
	        
	       
	       
	        for (int i = 1; i < 101; i++) {
	        	button[i].setSize(70, 90); 
	       		int height = button[i].getHeight();
	       		int width = button[i].getWidth();
	       		button[i].setOpaque(false);
	    		button[i].setContentAreaFilled(false);
	    		button[i].setBorderPainted(false);
	    		
	        	ImageIcon icon2;
	            icon2 = new ImageIcon(getClass().getResource("image/" + i + ".jpg"));
	            Image img = icon2.getImage();
	            Image newimg = img.getScaledInstance(width + 120, height,  java.awt.Image.SCALE_SMOOTH ) ;
	            ImageIcon icon;
	            icon = new ImageIcon(newimg);
	                 
	             if(icon != null){				
	                //button[i] = new JButton();
	            	button[i].setIcon(icon);
	                button[i].addActionListener(new IconButtonHandler(i, icon));
	                buttonOrder[i] = i;
	                imageSize[i] = (Double)(double)(icon.getIconHeight() *  icon.getIconWidth());
	            }//end if
	        }//end for
		readIntensityFile();
		readColorCodeFile();
		displayFirstPage();
		this.validate();
	}

	private void setGridBagConstraints() {
         constraints.gridwidth = 4;
         constraints.gridheight = 5;
		//		for(int i = 1; i < 101; i++) {
//		constraints.gridx = 5;
//		constraints.gridy = 4;
//		constraints.weightx = 0.1;
//		constraints.weighty = 0.1;
//		constraints.fill = GridBagConstraints.BOTH;
//		}
//		int imageButNo = 0;
//		panelBottom1.removeAll();
//			// System.out.println(button[i]);
//			imageButNo = buttonOrder[i];
////			if(i % 5 == 0) {
////				constraints.gridy++;
////				
////			} else if(i % 4 == 0) {
////				constraints.gridx++;
////			}
//			//constraints.fill = GridBagConstraints.HORIZONTAL;
//			panelBottom1.add(button[imageButNo]);
//			panelBottom1.add(relevantButton[imageButNo]);
//			imageCount++;
//		
//		panelBottom1.revalidate();
//		panelBottom1.repaint();
		
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
						intensityAndCCMatrix[lineNumber][binCount] = i;
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
						if(binCount < 64) {
						    intensityAndCCMatrix[lineNumber][binCount + 26] = i;
						}
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
			//panelBottom1.add(relevantButton[imageButNo]);
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
				ImageIcon icon;
				icon = new ImageIcon(getClass().getResource(
						"image/" + distanceMap.get(distance[i]) + ".jpg"));

				if (icon != null) {
					button[i] = new JButton(icon);
					panelBottom1.add(button[i]);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap.get(distance[i]), icon));
					buttonOrder[i] = i;
					panelBottom1.add(button[i]);
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
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}// end if
		}
	}

	private class refreshHandler implements ActionListener {

		public void actionPerformed(ActionEvent e) {
			  for(int i = 1; i < 101; i++){
		    	   button[i] = new JButton();
		       }
		      
		        
		        /*This for loop goes through the images in the database and stores them as icons and adds
		         * the images to JButtons and then to the JButton array
		        */
		        
		       
		       
		        for (int i = 1; i < 101; i++) {
		        	button[i].setSize(70, 90); 
		       		int height = button[i].getHeight();
		       		int width = button[i].getWidth();
		       		button[i].setOpaque(false);
		    		button[i].setContentAreaFilled(false);
		    		button[i].setBorderPainted(false);
		    		
		        	ImageIcon icon2;
		            icon2 = new ImageIcon(getClass().getResource("image/" + i + ".jpg"));
		            Image img = icon2.getImage();
		            Image newimg = img.getScaledInstance(width + 120, height,  java.awt.Image.SCALE_SMOOTH ) ;
		            ImageIcon icon;
		            icon = new ImageIcon(newimg);
		                 
		             if(icon != null){				
		                //button[i] = new JButton();
		            	button[i].setIcon(icon);
		                button[i].addActionListener(new IconButtonHandler(i, icon));
		                buttonOrder[i] = i;
		                imageSize[i] = (Double)(double)(icon.getIconHeight() *  icon.getIconWidth());
		            }//end if
		        }//end for
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
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}// end if

		}

	}
	
	private class intensityAndCCHandler implements ActionListener {

		public void actionPerformed(ActionEvent e) {
			
			double[] distance = new double[101];
			distanceMap = new HashMap<Double, Integer>();
			double d = 0;
			int compareImage = 0;
			int pic = (picNo - 1);
			int picIntensity = 0;
			double picSize = imageSize[pic];

			for (int i = 0; i < 100; i++) {
				for (int j = 1; j < 90; j++) {

					d += Math
							.abs((intensityAndCCMatrix[pic][j] / imageSize[pic + 1])
									- (intensityAndCCMatrix[i][j] / imageSize[i + 1]));
				}
				distance[i + 1] = d;
				distanceMap.put(d, i + 1);
				d = 0;
			}
			Arrays.sort(distance);
			for (int i = 1; i < 101; i++) {
				ImageIcon icon;
				icon = new ImageIcon(getClass().getResource(
						"image/" + distanceMap.get(distance[i]) + ".jpg"));

				if (icon != null) {
					button[i] = new JButton(icon);
					relevantButton[i] = new JCheckBox();
					panelBottom1.add(button[i]);
					panelBottom1.add(relevantButton[i]);
					button[i].addActionListener(new IconButtonHandler(
							distanceMap.get(distance[i]), icon));
					buttonOrder[i] = i;
					panelBottom1.add(button[i]);
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
					panelBottom1.add(relevantButton[i]);
					imageCount++;
				}// end for i
				panelBottom1.revalidate();
				panelBottom1.repaint();
			}// end if

		}

	}

	public void itemStateChanged(ItemEvent e) {
		// TODO Auto-generated method stub
		
	}
}


