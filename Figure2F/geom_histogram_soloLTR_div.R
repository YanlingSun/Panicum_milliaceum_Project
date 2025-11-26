setwd("C:/Users/Y/Documents/坚果云同步/同步_新/Project_Jinshu7/Article/2.Figure/2F")
library(ggplot2)

data <- read.delim("solo.div2", header=T, sep="\t")
#type	value
#PmiA	0.00
data$type=factor(data$type, levels=c("PmiB","PmiA"))

p1 <- ggplot(data, aes(x=div, fill=type)) + 
  geom_histogram(position="identity", binwidth=1, alpha=0.8) + 
  #geom_density(alpha=0.5, size=0.5) + 
  theme_bw() + 
  theme(
    #背景
    panel.border=element_blank(),  
    panel.grid=element_blank(),  
    axis.line=element_line(size=0.5, colour="black"), 
    #图例
    legend.text=element_text(face="plain", colour="black", size=15),  #图例子标题的字体属性
    legend.title=element_blank(),  #不显示图例总标题
    #legend.position='top',  #图例位置
    #坐标轴
    axis.text.x=element_text(hjust=0.5, angle=0, colour="black", size=15),  #x轴向左调整(hjust=1), 设置字体和大小
    axis.text.y=element_text(size=15, face="plain", colour="black"),  #y轴刻度的字体、大小、样式
    axis.title.x=element_text(size=15, face="plain"),  #y轴标题的字体属性
    axis.title.y=element_text(size=15, face="plain"),  #y轴标题的字体属性
    #axis.line=element_line(colour="black", size=1),  #x=0轴和y=0轴加粗显示
  ) + 
  xlab("Divergence of solo LTRs (%)") + 
  ylab("Count") 

p1

ggsave(p1, filename="solo.div2.pdf", width=5, height=2)
#ggsave(p1, filename="intact_LTR_time_distri.png", width=6, height=2.5, dpi=300)  ###
