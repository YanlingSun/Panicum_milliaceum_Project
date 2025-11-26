library(tidyr)
library(ggplot2)
library(ggpubr)
library(ggsignif)

dataBP <- read.table("buddingPanicle-colli-pha-pma-pmb.expression",header=T)
dataBP$Log <- log2(dataBP$Expression+1)
compaired <- list(c("Pha","PmiA"),c("Pha","PmiB"),c("PmiA","PmiB"))
p1 <- ggplot(dataBP, aes(Group,Log,fill=Group))+
     geom_boxplot(,width=0.5,lwd=0.5,outlier.shape=NA)+
     scale_fill_manual(values =c("salmon","cadetblue","burlywood3"))+
     scale_y_continuous(breaks = seq(0,12, by=2))+
     theme_set(theme_bw())+
     theme(plot.title=element_text(size=15),
        axis.text.x=element_text(size=15,angle=0),
        axis.text.y=element_text(size=15),
        axis.title.x=element_text(size = 15),
        axis.title.y=element_text(size = 15),
        axis.line=element_line(colour="black"),
        legend.position="none",
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank()
        )+
    labs(x='Budding Panicle', y= 'log2(TPM)')+
    geom_signif(comparisons = compaired,step_increase = 0.1,map_signif_level = F,test = wilcox.test,y_position = c(11.5,11.5,11.5),tip_length = c(c(0.02, 0.02),c(0.02, 0.02),c(0.02, 0.02))
    )+
    coord_cartesian(ylim=c(0,16))
ggsave(p1, filename="buddingPanicle-pha-pma-pmb-boxplot-pvalue.pdf", width=3, height=3)

dataSh <- read.table("shoot-colli-pha-pma-pmb.expression",header=T)
dataSh$Log <- log2(dataSh$Expression+1)
compaired <- list(c("Pha","PmiA"),c("Pha","PmiB"),c("PmiA","PmiB"))
p2 <- ggplot(dataSh, aes(Group,Log,fill=Group))+
    geom_boxplot(,width=0.5,lwd=0.5,outlier.shape=NA)+
    scale_fill_manual(values =c("salmon","cadetblue","burlywood3"))+
    scale_y_continuous(breaks = seq(0,12, by=2))+
    theme_set(theme_bw())+
    theme(plot.title=element_text(size=16),
        axis.text.x=element_text(size=12,angle=0),
        axis.text.y=element_text(size=12),
        axis.title.x=element_text(size = 14),
        axis.title.y=element_text(size = 14),
        axis.line=element_line(colour="black"),
        legend.position="none",
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank()
        )+
    labs(x='Shoot', y= 'log2(TPM)')+
    geom_signif(comparisons = compaired,step_increase = 0.1,map_signif_level = F,test = wilcox.test,y_position = c(11,11,11),tip_length = c(c(0.02, 0.02),c(0.02, 0.02),c(0.02, 0.02))
    )+
    coord_cartesian(ylim=c(0,15))
ggsave(p2, filename="shoot-pha-pma-pmb-boxplot-pvalue.pdf", width=3, height=3)

