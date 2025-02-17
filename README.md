<h1>PlotEyeFix</h1>

<b>PlotEyeFix</b> is an R package for visualizing eye tracking data. It produces plots of individual respondents' fixations on a stimulus screen, with color (red-blue) indicating the order of the fixations. The package allows users to plot one or more trials.

<h2>Installation</h2>
You can install <b>PlotEyeFix</b> directly from GitHub using the <b>devtools</b> or <b>remotes</b> package. Once you have installed one of these packages, install <b>PlotEyeFix</b> from GitHub using:

```r
devtools::install_github("libbyjenke/PlotEyeFix")
```

<h2>Example</h2>

```r
# Load the PlotEyeFix package
library(PlotEyeFix)
#Load other packages
library(dplyr)
library(png)

# Get data (in the package) ready for analysis
data(sample_data, package="PlotEyeFix")
fix_data <- sample_data[, c("Respondent.Name","Fixation.X","Fixation.Y","trial_num")]
fix_data <- fix_data |>
  rename(
    fixX = `Fixation.X`,
    fixY = `Fixation.Y`,
    subjID = `Respondent.Name`
  )

# Define path to stimulus image
image_path <- readPNG(system.file("data", "stimulus_screen.png", package = "PlotEyeFix"))

# Define width and height of eye tracker
eyetracker_width <- 1920
eyetracker_height <- 1080

# Define trial(s) of interest
trial_num <- 1

# Define output path
output_path <- file.path(tempdir(),"ET_output/{subjID}_trial_{trial_num}.png")

PlotEyeFix(fix_data, image_path, eyetracker_width, eyetracker_height, trial_num, output_path) 
```
You should now have a series of plots, each one with a single respondents' data for a single stimulus screen. The plot colors each fixation by its order, such that earlier fixations are red and later fixations are blue.

You can see that Respondent 2's fixations are down and to the right of where they would be expected if the respondent were looking at the stimuli. This is because the calibration step was (purposefully) not done properly, leading to an offset of the respondent's fixations.

<h2>Applications</h2>
For a framework for applications and more on using eye tracking in the social sciences, see this paper:
<br>
<ul>
<li>Libby Jenke and Nicolette Sullivan. "Attention and Political Choice: A Foundation for Eye Tracking in Political Science." Forthcoming at <i>Political Analysis</i>. <a href="https://osf.io/preprints/socarxiv/ns48h">Working paper</a></li>
</ul>
