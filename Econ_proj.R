library(foreign)
library(dplyr)
library(plm)
library(ggplot2)
library(sandwich)
library(lmtest)
dta<-read.dta('D:/UTD/2ndsem/Econometrics/guns.dta')
View(dta)

cor(dta)


sum(is.na(dta))

hist(dta$vio)

grouped<- dta %>%group_by(stateid) %>%summarise(mur_avg=mean(mur))%>%arrange(desc(mur_avg))
                                                                                                                 
View(grouped)
dta$year<-as.factor(dta$year)
dta$stateid<-as.factor(dta$stateid)
dta$shall<-as.integer(dta$shall)
dta1<-dta%>%filter(stateid=='11'|stateid=='22'|stateid=='48'|stateid=='32'|stateid=='28'|stateid=='13'|stateid=='6'|stateid=='1'|
               stateid=='36'|stateid=='12')
dta1$stateid<-as.factor(dta1$stateid)
dta1$year<-as.numeric(dta1$year)
View(dta1)
ggplot(data=dta1,mapping=aes(x=year,y=mur,colour=stateid))+geom_line()
sapply(grouped,class)
ggplot(data=dta1,mapping=aes(x=stateid,y=mur))+geom_boxplot()

ggplot(data=dta1,mapping=aes(x=year,y=pop,colour=stateid))+geom_line()

ggplot(data=dta1,mapping=aes(x=year,y=density,colour=stateid))+geom_line()
ggplot(data=dta1,mapping=aes(x=year,y=avginc,colour=stateid))+geom_line()
ggplot(data=dta1,mapping=aes(x=year,y=incarc_rate,colour=stateid))+geom_line()


datapanel<-pdata.frame(dta,index=c("stateid","year"))
View(datapanel)
#model building
#model- Violent crime rate -fe

dta$lnvio<-log(dta$vio)
dta$lnmur<-log(dta$mur)
dta$rob<-log(dta$rob)
View(dta)
pooled<-plm(lnvio~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064,data=datapanel,model="pooling")
coeftest(pooled, vcov=vcovHC(pooled,type="HC1"))
fe<-plm(lnvio~shall+incarc_rate+density+avginc+pop+pw1064+pb1064,data=datapanel,model="within")
fete<-plm(lnvio~shall+incarc_rate+density+avginc+pop+pw1064+pb1064+year,data=dta,index=c("stateid"),model="within")
re<-plm(lnvio~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064,data=datapanel,model="random")
# Hausman test 
phtest(fete,re)
summary(pooled)
summary(fe)
summary(fete)
summary(re)
View(dta)
# robbery rate
pooled<-plm(lnrob~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064,data=datapanel,model="pooling")
fe<-plm(lnrob~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064,data=datapanel,model="within")
fete<-plm(lnrob~shall+incarc_rate+density+avginc+pop+pw1064+pb1064+year,data=dta,index=c("stateid"))

re<-plm(lnrob~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064,data=datapanel,model="random")
phtest(fete,re)
summary(pooled)
summary(fe)
summary(fete)
summary(re)
#Murder rate
pooled<-plm(lnmur~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064,data=datapanel,model="pooling")
fe<-plm(lnmur~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064,data=datapanel,model="within")
fete<-plm(lnmur~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064+year,data=dta,index=c(stateid),model="within")
re<-plm(lnmur~shall+incarc_rate+density+avginc+pop+pm1029+pw1064+pb1064,data=datapanel,model="random")

phtest(fete,re)
summary(pooled)
summary(fe)
summary(fete)
summary(re)