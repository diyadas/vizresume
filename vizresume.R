# Title: Visual Resume (Timelines)
# Author: Diya Das
# Last revised: Sat Dec  8 23:16:53 2018

library(dplyr)
library(ggplot2)
library(scales)
library(grid)
library(googlesheets)
library(stringr)
library(emojifont)
library(cowplot)
library(gridExtra)

load.fontawesome(font = "Font Awesome 5 Free-Solid-900.otf") #icons 
fa <- data.frame(type = c("Award", "Poster", "Publication", 
                           "Software", "Talk", "Workshop"),
                 fnt = fontawesome(c('fa-trophy', 'fa-pie-chart', 
                                     'fa-pencil', 
                                   'fa-code', 'fa-comment', 
                                   'fa-wrench')))

df <- gs_read(ss = gs_title("Resume - projects and achievements"), 
              ws = "Sheet1")
tlorder <- na.omit(gs_read(ss = gs_title("Resume - projects and achievements"), 
              ws = "Sheet2")$Timeline)
df$category <- factor(df$category, levels = tlorder)
df <- df %>% group_by(category) %>% mutate(
  y1n = y1 - mean(y1),
  y2n = y2 - mean(y1)) %>% ungroup()
df$name_wrap <- mapply(function(name, wraplen) str_wrap(name, wraplen),
                      df$name,
                      df$wraplen)

for (x in unique(df$org)) df <- add_row(df, category = df$category[1],
                                        type = "Publication",
                                        wraplen = 1, org = x)

df_rect <- df %>% filter(as.character(start) != as.character(end) | is.na(start))
df_point <- df %>% filter(as.character(start) == as.character(end) | is.na(start))
df_point <- left_join(df_point, fa)

no_style <- theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y.left = element_blank(),
        axis.title.y = element_blank(),
        strip.text = element_text(face="bold"),
        text = element_text(size=8),
        axis.text.x=element_text(size=8),
        plot.margin=unit(c(0,0,5.5,0),"pt"),
        plot.title = element_blank()
        ) 

p <- ggplot() +
  scale_x_date(labels = date_format("%Y"), date_breaks = "1 year") +
  geom_rect(data = df_rect, 
            mapping = aes(xmin = as.Date(paste(1, start), "%d %b %Y"),
                          xmax = as.Date(paste(1, end), "%d %b %Y"),
                          ymin = y1n, ymax = y2n, 
                          fill = wrap_format(40)(org)),
            color = "grey", alpha = 0.5) + labs(fill='Organization') + 
  guides(fill = guide_legend(ncol=2)) +
  geom_text(data = df_rect, aes(x = as.Date(paste(1, start), "%d %b %Y") +
                             (as.Date(paste(1, end), "%d %b %Y") -
                                as.Date(paste(1, start), "%d %b %Y")) / 2,
                           y = y1n + (y2n - y1n) / 2, 
                           label = name_wrap), size = 2.8, lineheight = 0.7) + 
  geom_text(data = df_point,  aes(x = as.Date(paste(1, start), "%d %b %Y"),
                                  y = (y1n + y2n)/2, 
                                  colour = wrap_format(40)(org),
                                  label = fnt), 
            alpha = 0.5, family='fontawesome-webfont') +
  scale_colour_discrete(guide = 'none') + 
  facet_grid(category ~ ., switch = "y", labeller = label_wrap_gen(width = 20)) +
  labs(x = "Year", y = "")  + no_style 

# Legend Extraction Code from Luciano Selzer
## https://stackoverflow.com/a/11886071/743568
g_legend <- function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}
legend <- g_legend(p)

annot_point <- data.frame(fa, x = rep(0, nrow(fa)), y = nrow(fa):1)

icon_plot <- ggplot(data.frame()) + geom_point() + xlim(0, 1) + ylim(0.5, 6.5)+
  geom_text(data = annot_point,  aes(x = x,
                                     y = y,
                                     label = fnt), alpha = 0.5,
            family='fontawesome-webfont') +
  geom_text(data = annot_point,  aes(x = x + 0.1,
                                     y = y,
                                     label = type),
            hjust = 0, size = 2.8) + theme_nothing() 

png(filename = "resume.png", width = 9.5 , height = 6.6, units = "in", res = 320)
lay <- rbind(c(1,1,1),
             c(2,2,3))
grid.arrange(grobs = list(ggplotGrob(p + theme(legend.position = "none")),
                          legend,
                          ggplotGrob(icon_plot)), 
             layout_matrix = lay,
             heights = unit(c(5.2, 1), c("in", "in")))
dev.off()

