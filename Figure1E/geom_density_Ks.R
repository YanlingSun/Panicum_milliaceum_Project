library(ggplot2)
library(Cairo)
#CairoPNG("Ks_distribution.png", width = 2000, height = 1000)
CairoPDF("Ks_distribution.pdf", 6, 3)

data <- read.delim("all.Ks.filter", header = T, sep = "\t")
data$type = factor(data$type)
ggplot(data, aes(x = Ks, fill = type)) +
	geom_density(alpha = 0.5) +  
	theme_bw() +  
	theme(panel.grid = element_blank()) + 
	theme(panel.border = element_blank()) +
	theme(axis.line = element_line(size = 0.5, colour = "black")) + 
#	theme(legend.position = "none") +  
#	facet_grid(chr ~ .) + 
#	scale_y_continuous(limits = c(0, 4), breaks = seq(0, 4, 0.5)) +
#	scale_x_continuous(limits = c(0, 2), breaks = seq(0, 2, 0.1)) +
	xlab("Ks") +
	ylab("Density") 

dev.off()

