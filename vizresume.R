#title: Visual Resume (Timelines)
#author: Diya Das
#Date: 2018-11-21

library(dplyr)
library(ggplot2)
library(scales)
library(grid)
library(googlesheets)
library(stringr)

df <- gs_read(ss = gs_title("Resume - projects and achievements"), 
              ws = "Sheet1")
tlorder <- na.omit(gs_read(ss = gs_title("Resume - projects and achievements"), 
              ws = "Sheet2")$Timeline)
df$category <- factor(df$category, levels = tlorder)
df <- df %>% group_by(category) %>% mutate(
  y1n = y1 - mean(y1),
  y2n = y2 - mean(y1))
df$name_wrap <- mapply(function(name, wraplen) str_wrap(name, wraplen),
                      df$name,
                      df$wraplen)

df_rect <- df %>% filter(as.character(start) != as.character(end))
df_point <- df %>% filter(as.character(start) == as.character(end))

no_style <- theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        panel.background = element_blank())

p <- ggplot() +
  scale_x_date(labels = date_format("%m-%Y")) +
  geom_rect(data = df, 
            mapping = aes(xmin = as.Date(paste(1, start), "%d %b %Y"),
                          xmax = as.Date(paste(1, end), "%d %b %Y"),
                          ymin = y1n, ymax = y2n, 
                          fill = wrap_format(28)(org)),
            color = "grey", alpha = 0.5) + labs(fill='Organization') +
  geom_text(data = df_rect, aes(x = as.Date(paste(1, start), "%d %b %Y") +
                             (as.Date(paste(1, end), "%d %b %Y") -
                                as.Date(paste(1, start), "%d %b %Y")) / 2,
                           y = y1n + (y2n - y1n) / 2, 
                           label = name_wrap), size = 3, lineheight = 0.7) + 
  facet_grid(category ~ ., switch = "y", labeller = label_wrap_gen(width=20)) +
  labs(x = "Year", y = "")  + no_style
p
