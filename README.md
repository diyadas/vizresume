# vizresume

This repo creates a visual resume, based on input data from a 
Google spreadsheet. The goal in using a Google spreadsheet was to make it easy 
to update. Activities one month or longer are graphed as bars; less than one 
month are represented by Font Awesome icons.

An example of the output:
![alt text](https://diyadas.github.io/files/resume-diya-das.png)

## Preparation
### Data entry and preparation with Google Sheets
1. Create a copy of this spreadsheet: https://goo.gl/yKMeKC.

2. Fill out Sheet1 for each activity. Sheet 2 contains lists for data validation to reduce typos.
 - "name": how to label the activity on the plot
 - "full name": not displayed, for your records only; sometimes the name has to be an abbreviation
  - "wraplen": the number of characters at which to wrap the "name" of the activity, both variables are relevant only for bar plots. This requires custom input because this tended to vary greatly in my own use: you might have to play around with this value.
 - "pt": is this to be a point? Automatically calculated; used to filter Google spreadsheet when debugging or choosing y1 and y2. Not used by app.
 - "org": what organization was the activity affiliated with? These organizations are used for the color groupings.
 - "category": what class of activity is this? This is used for faceting in the plot. The facets can be reordered in the app.
 - "type": what type of activity is this? This is only used for Font Awesome icons.
 - "start" and "end": dates of involvement. All activities need both start and end dates.
 - "y1" and "y2": manually choose y axis coordinates for bars. This is needed for offsets so bars don't overlap. Typically, y2 = y1 + 1, but I chose to deviate from this for the "Academic Position" category and used double-height bars.
 
3. Publish the Google Sheet. Note that publishing is not the same as making it shareable via a link. Publishing exposes the sheet to the API needed to read the data. If you are uncomfortable with this, there is an option to submit your data as a text file.

### Running the app
1. Binder integration is coming *soon* but in the mean time, you can source `install.R` to install the necessary packages:
- `shiny`: This is a Shiny app.
- `dplyr`: Used for data grouping to center within facets.
- `ggplot2`: Used for graphing.
- `scales`: Used for transparency (`alpha`).
- `googlesheets`: Used to extract data from a Google spreadsheet.
- `stringr`: Used for wrapping labels.
- `emojifont`: Used for Font Awesome icons (as text annotations, because of difficulty posed by custom scalable shapes in ggplot2).
- `cowplot`: Used for graphing (`theme_nothing`).
- `gridExtra`: Used for graphics layout.
- `shinyjqui`: Adds responsiveness to facet on category.

2. Within RStudio, open `app.R` and click Run this app.

3. Enter the URL of the published spreadsheet (Hint: it should start with docs.google.com/spreadsheets) or upload a text file.

## History (and credit where credit is due)
My colleague Nelle Varoquaux (@nelle) encouraged me to record my
achievements in a Google spreadsheet for a long time. This came to a head
when she shared a spreadsheet our colleagues had put together to record our 
activities for our funders. Months later, our colleague Chris Holdgraf 
(@choldgraf) shared a timeline generated from this spreadsheet, 
filtered for his own activities. He turned it into a GitHub repo that used 
Binder to run a Jupyter notebook, but I wanted to customize the output to add
more features. 

Having more experience with graphing in R, I just decided to write my own code. 
I then decided I was going to fully explore the capabilities of ggplot, and I also
wanted to see if I could do a graphics layout entirely in R, since I often use Adobe
Illustrator for layouts. It became a project, [which I had resolved to do less of](https://github.com/diyadas/say-no-to-projects)
but I had fun and I learned things about ggplot, grid graphics, and Google Sheets
integration with R.

Thanks are also due to my colleagues Rebecca Barter (@rlbarter), Sara Stoudt 
(@sastoudt) and Kevin Keys (@klkeys) for handling ggplot queries, and all the 
lovely people on StackOverflow who asked and answered questions about graphics 
layouts.

This particular iteration as an app owes its existence to an audience member at the
R-Ladies SF meetup who asked if I had any intention of turning my script into an app.

## What's next
- Binder support.
- Move data visualization-specific variables from Google sheets input into Shiny app input.
- Document available options for FontAwesome icons. Did someone make a Shiny app for this?
- Hyperlinks / tooltips to provide more details, for individual activities.
