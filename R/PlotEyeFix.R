#' PlotEyeFix function
#' Written by Libby Jenke
#'
#' @description This function takes fixation coordinates for a specific trial and plots them on top of a stimulus image.
#' The fixation points are scaled to fit the image dimensions, and a color gradient 
#' is applied to indicate the order of fixations (from red to blue).
#' @param fix_data A data frame containing the fixation coordinates. The data frame 
#'   should have at least two columns: `fixX` (x-coordinates), `fixY` (y-coordinates), 
#'   and `trial_num` (trial identifier).
#' @param image_path A string specifying the path to the stimulus image file (e.g., ".png").
#'   Note: this image must be as shown on the eye tracker screen. 
#'   For example, if showing a portrait-oriented image on a landscape-oriented eye tracker,
#'   there will be margins on either side of the image that must be incorporated into the 
#'   image dimensions. Otherwise, the scaling factor to match the image with the fixations 
#'   will be incorrect.
#' @param eyetracker_width The width of the eye tracker screen (in pixels).
#' @param eyetracker_height The height of the eye tracker screen (in pixels).
#' @param trial_num The trial number to focus on.
#' @param output_path A string specifying the directory and base file name where the plot will be saved.
#'   You can include `{subjID}` and `{trial_num}` as placeholders that will be replaced by the actual subject 
#'   ID and trial number (e.g., to create a folder containing all subjects' plotted fixations, use
#'   "output/{subjID}_trial_{trial_num}.png").
#' 
#' @return This function does not return any value. It generates and saves a plot 
#'   with fixation points overlaid on the stimulus image.
#' 
#' @import ggplot2
#' @importFrom magick image_read image_info
#' @importFrom grid rasterGrob
#' @importFrom dplyr %>%
#'
#' @export 
#' 
PlotEyeFix <- function(fix_data, image_path, eyetracker_width, eyetracker_height, trial_num, output_path) {
  
  # Read in the stimulus image
  stimulus_screen <- image_read(image_path)
  
  # Get dimensions of the image
  img_info <- image_info(stimulus_screen)
  img_width <- img_info$width
  img_height <- img_info$height
  
  # Scale fixation points to fit image dimensions 
  fix_data$fixX_img <- fix_data$fixX * (img_width / eyetracker_width) 
  fix_data$fixY_img <- fix_data$fixY * (img_height / eyetracker_height) 
  
  # Print image dimensions and check range of fixation points 
  cat("Image width:", img_width, "Image height:", img_height, "\n")
  cat("Fixation X range:", range(fix_data$fixX_img), "\n")
  cat("Fixation Y range:", range(fix_data$fixY_img), "\n")
  
  # Convert image to a raster object for ggplot
  img_grob <- rasterGrob(stimulus_screen, interpolate = TRUE)
  
  # Filter data for the specified trial number
  trial_data <- fix_data[fix_data$trial_num == trial_num, ]
  
  # Define subjects
  subject <- unique(trial_data$subjID)
  
  # Plot for each subject in the specified trial
  for (subjID in subject) {
    subj_data <- trial_data[trial_data$subjID == subjID, ]
    
    # Create fixation order from sequence of rows
    subj_data$fix_order <- seq_along(subj_data$fixX_img)
    
    # Create a ggplot with image and fixation points
    plot <- ggplot() +
      # Add image to plot
      annotation_custom(img_grob, xmin = 0, xmax = img_width, ymin = 0, ymax = img_height) +
      # Add fixations to plot
      geom_point(data = subj_data, aes(x = fixX_img, y = fixY_img, color = fix_order), size = 3) +
      # Add color (red to blue for the order of fixations)
      scale_color_gradient(low = "red", high = "blue") +
      # Label the legend
      labs(color = "Fixation Order") +
      # Remove axis labels and ticks
      theme_void() +
      # Remove margins so image fits perfectly
      theme(plot.margin = margin(0, 0, 0, 0)) +
      # Set plot limits to match image dimensions
      xlim(0, img_width) +
      ylim(0, img_height)+
      # Use coord_fixed to maintain aspect ratio 
     coord_fixed(ratio = 1, xlim = c(0, img_width), ylim = c(0, img_height))
    
    print(plot)
    
    # Save the plot as an image with the subject ID and trial number in the filename
    output_filename <- gsub("\\{subjID\\}", subjID, output_path)
    output_filename <- gsub("\\{trial_num\\}", trial_num, output_filename)
    
    # Save the plot
    ggsave(output_filename, plot = plot, width = img_width / 100, height = img_height / 100, units = "in", dpi = 300)
  }
}

