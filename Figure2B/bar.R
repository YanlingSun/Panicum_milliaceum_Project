library(data.table)
library(ggplot2)

setwd("C:/Users/Y/Documents/坚果云同步/同步_新/Project_Jinshu7/Article/2.Figure代码整理/Figure2B")

Others <- c(118842181,131366952)
Exon <- c(43330064,46434556)
Other_repeat <- c(46735995,60995549)
LTR_unknown <- c(22672292,27691441)
LTR_Copia <- c(	7255590,8277604)
LTR_Gypsy <- c(110806721,179617200)
Species <- letters[1:2]

(dt1 <- data.table(Species,LTR_Gypsy,LTR_Copia,LTR_unknown,Other_repeat,Exon,Others))
(dt2 <- melt(dt1,id.vars=c('Species')))
dt2 <- dt2[order(Species,-variable)]
dt2[,dui_y:=cumsum(value)-value/2,by=.(Species)]
dt2

p <- ggplot(dt2, aes(x=Species,y=value,fill=variable)) + 
  geom_bar(stat='identity', position='stack', size=0.2, color="black", alpha=0.7) + 
  #	geom_text(aes(y=dui_y,label=value), size=3, col='white') + 
  #	labs(title='Bar with Stack', x='', y='') + 
  theme(legend.justification = 'right', 
        legend.position = 'right', 
        legend.key.height = unit(0.5,'cm'), 
        #panel.background = element_blank(), 
        #axis.ticks = element_blank(), 
        #axis.text.y = element_blank()
        ) + 
  scale_fill_manual(values=c("red","orange","#00CED1","#9ACD32","#00BFFF","#1E90FF"))

ggsave(p, filename="out.pdf", width=6, height=5)
