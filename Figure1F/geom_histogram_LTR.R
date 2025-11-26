library(ggplot2)

setwd("D:/坚果云同步/同步_新/Project_Jinshu7/Article/2.Figure代码整理/Figure1F")
data <- read.table('Pmi.TE.div.count', header=T)

p1 <- ggplot(data, aes(x=Div, y=Count/Size*100000000, fill=Sub, alpha=0.5)) + 
  geom_bar(stat="identity", width=0.5, position="identity") + 
  theme_bw() + 
  theme(
    #坐标轴
    axis.text.x=element_text(size=15, hjust=0.5, angle=0, colour="black"),  #x轴向左调整(hjust=1), 设置字体和大小
    axis.text.y=element_text(size=15, face="plain", colour="black"),  #y轴刻度的字体、大小、样式
    axis.title.x=element_text(size=15, face="plain"),  #y轴标题的字体属性
    axis.title.y=element_text(size=15, face="plain"),  #y轴标题的字体属性
    axis.line=element_line(colour="black", size=1),  #x=0轴和y=0轴加粗显示
    #图例
    legend.text=element_text(face="plain", colour="black", size=12),  #图例子标题的字体属性
    legend.title=element_blank(),  #不显示图例总标题
    #legend.position="right", legend.box="horizontal",  #图例位置
    legend.position="none",  #不显示图例
    #背景
    panel.border=element_blank(),  #去除默认填充的灰色
    panel.grid.major=element_blank(),  #不显示网格线
    panel.grid.minor = element_blank()) +  #不显示网格线
  
  ylab("Count/100Mb") + 
  xlab("TE divergence (%)")

p1
  
ggsave(p1, filename="Pmi.TE.div.count.pdf", width=6, height=5)
