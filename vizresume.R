#title: Visual Resume (Timelines)
#author: Diya Das
#Date: 2018-11-21

library(dplyr)
library(ggplot2)
library(scales)
library(grid)

# df <- data.frame(
#   start = c("Sep 2008", "Aug 2012", "May 2018", "Sep 2012", "Mar 2013", "Jan 2014"),
#   end = c("Jun 2012", "May 2018", "Nov 2018", "May 2015", "May 2015", "May 2015"),
#   y1 = c(0, 0, 0, 0, 1, 2),
#   y2 = c(3, 3, 3, 1, 2, 3),
#   category = c(rep("Academic Position", 3), rep("Community Involvement", 3)),
#   name = c("AB\nPrinceton University", "PhD\nUC Berkeley", 
#                   "Postdoc\nUC Berkeley", "Finance Committee, EYH", 
#                   "Finance Agent, EYH", "Signatory, EYH"),
#   org = c("Princeton University", "UC Berkeley", "UC Berkeley", "EYH", "EYH", "EYH"))

df <- gs_read(ss = gs_title("Resume - projects and achievements"), ws = "Sheet1")

df_rect <- df %>% filter(as.character(start) != as.character(end))
df_point <- df %>% filter(as.character(start) == as.character(end))

no_style <- theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        panel.background = element_blank(),
        legend.position = "none")

p <- ggplot() +
  scale_x_date(labels = date_format("%m-%Y")) +
  geom_rect(data = df_rect, 
            mapping = aes(xmin = as.Date(paste(1, start), "%d %b %Y"),
                          xmax = as.Date(paste(1, end), "%d %b %Y"),
                          ymin = y1, ymax = y2, fill = org),
            color = "black", alpha = 0.5) +
  geom_text(data = df_rect, aes(x = as.Date(paste(1, start), "%d %b %Y") +
                             (as.Date(paste(1, end), "%d %b %Y") -
                                as.Date(paste(1, start), "%d %b %Y")) / 2,
                           y = y1 + (y2 - y1) / 2, label = name),
            size = 4) + facet_grid(category ~ ., switch = "y") +
  labs(x = "Year", y = "")  + no_style
p
