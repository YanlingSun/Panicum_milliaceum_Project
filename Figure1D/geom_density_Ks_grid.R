library(ggplot2)

setwd("C:/Users/Y/Documents/坚果云同步/同步_新/Project_Jinshu7/Article/2.Figure/1D")
data <- read.delim("all.Ks.filter", header=T, sep="\t")

data$type = factor(data$type)
p1 <- ggplot(data, aes(x=Ks, fill=type)) + 
  geom_density(alpha=0.5) + 
  facet_grid(chr ~ .) + 
  theme_bw() + 
  theme(
    #背景
    panel.grid=element_blank(), 
    panel.border=element_blank(), 
    axis.line=element_line(size=0.5, colour="black"), 
    #图例
    legend.text=element_text(face="plain", colour="black", size=20),  #图例子标题的字体属性
    legend.title=element_blank(),  #不显示图例总标题
    legend.position='top',  #图例位置
    #坐标轴
    axis.text.x=element_text(hjust=0.5, angle=0, colour="black", size=20),  #x轴向左调整(hjust=1), 设置字体和大小
    axis.text.y=element_text(size=20, face="plain", colour="black"),  #y轴刻度的字体、大小、样式
    axis.title.x=element_text(size=20, face="plain"),  #y轴标题的字体属性
    axis.title.y=element_text(size=20, face="plain"),  #y轴标题的字体属性
    #axis.line=element_line(colour="black", size=1),  #x=0轴和y=0轴加粗显示
  ) + 
  #坐标轴
  scale_y_continuous(limits=c(0,21), breaks=seq(0,15,15)) + 
  #	scale_x_continuous(limits=c(0,2), breaks=seq(0,2,0.1)) +
  ylab("Density") + 
  xlab("Ks")

p1

ggsave(p1, filename="all.Ks.filter.pdf", width=5, height=10)
