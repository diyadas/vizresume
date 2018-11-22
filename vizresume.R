#title: Visual Resume (Timelines)
#author: Diya Das
#Date: 2018-11-21

library(ggplot2)
library(scales)

df <- data.frame(
  x1 = (c("Sep 2008", "Aug 2012", "May 2018")),
  x2 = (c("Jun 2012", "May 2018", "Nov 2018")),
  y1 = c(0, 0, 0),
  y2 = c(1, 1, 1),
  category = c(rep("Academic Position", 3)),
  rect_labels = c("AB", "PhD", "Postdoc"))
ggplot() +
  scale_x_date(labels = date_format("%m-%Y")) +
  scale_y_continuous(name = "y") +
  geom_rect(data = df, mapping = aes(xmin = as.Date(paste(1, x1), "%d %b %Y"),
                                     xmax = as.Date(paste(1, x2), "%d %b %Y"),
                                     ymin = y1, ymax = y2, fill = category),
            color = "black", alpha = 0.5) +
  geom_text(data = df, aes(x = as.Date(paste(1, x1), "%d %b %Y") +
                             (as.Date(paste(1, x2), "%d %b %Y") -
                                as.Date(paste(1, x1), "%d %b %Y")) / 2,
                           y = y1 + (y2 - y1) / 2, label = rect_labels),
            size = 4) +
  xlab("Year") + ylab("Academic Position")  +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        panel.background = element_blank(),
        legend.position = "none")
