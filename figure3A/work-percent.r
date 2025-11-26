library(ggplot2)
library(ggpubr)
library(car)
library(purrr)

data <- read.table("input-data-percent.txt",header = TRUE)
data <- data.frame(tissue = data$tissue, sub = data$sub, 
                 num = as.numeric(data$num), stringsAsFactors = FALSE)
data %>% split(.$tissue) %>% map(~leveneTest(num ~ sub, data = .x, center = mean))
data$Sub <- factor(data$sub, levels = c("PmiA","PmiB","PmiAB","aNull"))
#pdf(file="Fig3A-percent.pdf")
p<- ggplot(data, aes(x = tissue, y = num, fill = Sub)) + scale_fill_manual(values =c("#9C6D6E","#B19748","#6F8F7F","#6794A8"))+
    geom_bar(stat = "summary", fun = mean, color = "black",position = position_dodge()) +
    theme_set(theme_bw())+
    theme(panel.background = element_blank(),
       panel.grid = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text.x = element_text(angle = 45,vjust = 0.85,hjust = 0.75,size=12,colour = "black"),
        axis.text.y=element_text(size=12,colour="black"),
        axis.title.y = element_text(size = 12),
        axis.title.x = element_text(size=12),
        plot.title = element_text(hjust = 0.5),
        legend.position="top",
        legend.title=element_blank(),
        legend.text = element_text(colour = "black",size = 12)
          )+ 
  scale_y_continuous(breaks = seq(0,1, by=0.1))+  
  scale_x_discrete(labels = c("Inflorescences","Leaf blades","Leaf sheaths","Roots","Mature seeds","Seedlings","Shoots","Stems"))+
  ylab("Percent")+
  xlab("Tissues")+
    stat_summary(fun.data = 'mean_se', geom = "errorbar", colour = "black",
                 width = 0.25,position = position_dodge( .9))
p1 <- p + stat_compare_means(aes(label =..p.format..),method = "wilcox.test", method.args = list(var.equal = TRUE))     
ggsave(p1, filename="Fig3A.pdf", width=4, height=4)
#dev.off
