# vizresume

This repo creates a visual resume, based on input data from a 
Google spreadsheet. The goal in using a Google spreadsheet was to make it easy 
to update. Activities one month or longer are graphed as bars; less than one 
month are represented by Font Awesome icons.

An example of the output:
![alt text](https://diyadas.github.io/files/resume-diya-das.png)

## Preparation
### Creating the Google Spreadsheet
1. Create a copy of this spreadsheet: https://goo.gl/yKMeKC; rename it to 
"Resume - projects and achievements". Should you title it something else, you'll
need to update line 12 of the R script.

2. In Sheet2, change the categories for data validation as you desire. 
 - "Type" corresponds to allowed values for "type" on Sheet1. This is relevant only for activities of duration less than one month.
 - "Timeline" corresponds to allowed values for "category" on Sheet1, but in the order by which to facet.

3. Fill out Sheet1 for each activity.
 - "name": what you want to call the activity
 - "full name": not displayed, for your records only; sometimes the name has to be an abbreviation
  - "wraplen": the number of characters at which to wrap the "name" of the activity, both variables are relevant only for bar plots. This requires custom input because it was sub-optimal to use RNGs to offset data: you might have to play around with this value.
 - "pt": is this to be a point? Automatically calculated; used to filter Google spreadsheet when debugging or choosing y1 and y2. Not used by R script.
 - "org": what organization was the activity affiliated with?
 - "category": what class of activity is this? This is used for faceting in the final plot.
 - "type": what type of activity is this? This is only used for Font Awesome icons.
 - "start" and "end": dates of involvement. All activities need both start and end dates.
 - "y1" and "y2": manually choose y axis coordinates for bars. This is needed for offsets so bars don't overlap. Typically, y2 = y1 + 1, but I chose to deviate from this for the "Academic Position" category and used double-height bars.

### Running the script
1. Install the following R packages:
- `dplyr`: Used for data grouping to center within facets.
- `ggplot2`: Used for graphing.
- `scales`: Used for transparency (`alpha`).
- `grid`: Used for graphics layout.
- `googlesheets`: Used to extract data from a Google spreadsheet.
- `stringr`: Used for wrapping labels.
- `emojifont`: Used for Font Awesome icons (as text annotations, because I couldn't figure out custom scalable shapes in ggplot2...).
- `cowplot`: Used for graphing (`theme_nothing`).
- `gridExtra`: Used for graphics layout.

2. Download [`Font Awesome 5 Free-Solid-900.otf`](https://fontawesome.com/how-to-use/on-the-desktop/setup/getting-started) and move it to the `fonts` subdirectory of the `emojifont` package.

3. `source('vizresume.R')`

## History (and credit where credit is due)
My colleague Nelle Varoquaux (@nelle) has been encouraging me to record my 
achievements in a Google spreadsheet for ... a long time. This came to a head 
when she shared a spreadsheet our colleagues had put together to record our 
activities for our funders. Months later, our colleague Chris Holdgraf 
(@choldgraf) shared a timeline generated from this spreadsheet, 
filtered for his own activities. He turned it into a GitHub repo that used 
Binder to run a Jupyter notebook...but I wanted to customize the output to add 
more features. 

Having more experience with graphing in R, I just decided to write my own code. 
I then decided I was going to fully explore the capabilities of ggplot since I 
don't use it consistently, and I also wanted to see if I could do a graphics 
layout entirely in R, since I often use Adobe Illustrator for layouts. It became
a PROJECT [(oops)](https://github.com/diyadas/say-no-to-projects). I had fun and
I learned things about ggplot, grid graphics, and Google Sheets integration with
R. 

Thanks are also due to my colleagues Rebecca Barter (@rlbarter), Sara Stoudt 
(@sastoudt) and Kevin Keys (@klkeys) for handling ggplot queries, and all the 
lovely people on StackOverflow who asked and answered questions about graphics 
layouts.

## What's next
- Hyperlinks / tooltips to provide more details, for individual activities.