library(tidyr)
library(ggplot2)
library(ggpubr)
library(ggsignif)

dataBP <- read.table("buddingPanicle-group-all-pha-pmi.expression",header=T)
dataBP$Log <- log2(dataBP$Expression+1)
compaired <- list(c("2HPmiA","4LPmiA"),c("3HPmiB","5LPmiB"),c("1HPha","6LPha"))
p1 <- ggplot(dataBP, aes(Group,Log,fill=Group))+
    geom_boxplot(,width=0.5,lwd=0.5,outlier.shape=NA)+
    scale_fill_manual(values =c("salmon","cadetblue","burlywood3","cadetblue3","burlywood","salmon"))+
    scale_y_continuous(breaks = seq(0,12, by=2))+
    theme_set(theme_bw())+
    theme(plot.title=element_text(size=18),
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
    theme(legend.position="none")+
    labs(x='', y= 'log2(TPM)')+
    geom_signif(comparisons = compaired,
        step_increase = 0.1,
        map_signif_level = F,
        test = wilcox.test,
        y_position = c(11,11,11),
        tip_length = c(c(0.02, 0.02),c(0.02, 0.02),c(0.02, 0.02))
        )+
    coord_cartesian(ylim=c(0,15))
ggsave(p1, filename="buddingPanicle-cl-pha-pma-pmb.pdf", width=4, height=4)

 
dataSh <- read.table("shoot-group-all-pha-pmi.expression",header=T)
dataSh$Log <- log2(dataSh$Expression+1)
compaired <- list(c("2HPmiA","4LPmiA"),c("3HPmiB","5LPmiB"),c("1HPha","6LPha"))
p2 <- ggplot(dataSh, aes(Group,Log,fill=Group))+
    geom_boxplot(,width=0.5,lwd=0.5,outlier.shape=NA)+
    scale_fill_manual(values =c("salmon","cadetblue","burlywood3","cadetblue3","burlywood","salmon"))+
    scale_y_continuous(breaks = seq(0,12, by=2))+
    theme_set(theme_bw())+
    theme(plot.title=element_text(size=18),
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
    theme(legend.position="none")+
    labs(x='', y= 'log2(TPM)')+
    geom_signif(comparisons = compaired,
        step_increase = 0.1,
        map_signif_level = F,
        test = wilcox.test,
        y_position = c(11,11,11),
        tip_length = c(c(0.02, 0.02),c(0.02, 0.02),c(0.02, 0.02))
        )+
    coord_cartesian(ylim=c(0,15))
ggsave(p2, filename="shoot-cl-pha-pma-pmb.pdf", width=4, height=4)
