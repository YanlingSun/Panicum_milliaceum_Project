library(ggplot2)

setwd("C:/Users/Y/Documents/坚果云同步/同步_新/Project_Jinshu7/Article/2.Figure/2E")
data <- read.delim("LTR_family.stat.4R", header=T, sep="\t")
data$type = factor(data$type, levels=c('RLX','RLC','RLG'))

p1 <- ggplot(data, aes(x=log(PmiA), y=log(PmiB), shape=type, color=log(ratio))) + 
  geom_point(size=1) + 
  geom_abline(slope = 1, intercept = 0, size = 0.2, col = "red") + 
  scale_color_gradient(low="green", high="blue") + 
  scale_shape_manual(values=c(17,15,16)) + 
  #
  theme_bw() + 
  theme(
    #图例
    panel.grid=element_blank(), 
    legend.position=c(0.95,0.05), 
    legend.justification=c(1,0), 
    legend.background=element_rect(fill='white', colour='black'), 
    legend.text=element_text(face="plain", colour="black", size=20), 
    #坐标轴
    axis.text.x=element_text(hjust=0.5, angle=0, colour="black", size=20),  #x轴向左调整(hjust=1), 设置字体和大小
    axis.text.y=element_text(size=20, face="plain", colour="black"),  #y轴刻度的字体、大小、样式
    axis.title.x=element_text(size=20, face="plain"),  #y轴标题的字体属性
    axis.title.y=element_text(size=20, face="plain"),  #y轴标题的字体属性
    #axis.line=element_line(colour="black", size=1),  #x=0轴和y=0轴加粗显示
  ) + 
  #坐标轴
  scale_y_continuous(limits=c(4,16), breaks=seq(4,16,4)) + 
  scale_x_continuous(limits=c(4,16), breaks=seq(0,16,4)) + 
  ylab("log(size) of LTR family in B") + 
  xlab("log(size) of LTR family in A")

#	geom_vline(xintercept = 1) +
#	geom_hline(yintercept = 1) + 
#	geom_smooth() 
#	geom_smooth(method = lm) 

p1

ggsave(p1, filename="LTR_family.stat.pdf", width=5, height=5)
