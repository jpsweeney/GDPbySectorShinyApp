bea.api.key = "75133F81-A1D8-42EB-ABCA-05F42BD63D0D"

## nominal table: http://www.bea.gov/iTable/iTable.cfm?ReqID=9&step=1#reqid=9&step=3&isuri=1&903=35
## real table: http://www.bea.gov/iTable/iTable.cfm?ReqID=9&step=1#reqid=9&step=3&isuri=1&903=36
## table 35 nominal
## table 36 real
## for personal income table use 58
library(RCurl)
library(jsonlite)
library(lubridate)
library(grid)
library(gridExtra)
library(ggplot2)

setwd("~/Documents/Economics")

## get nominal GDP data

reqn <- paste("http://www.bea.gov/api/data/?&UserID=", bea.api.key, 
              "&method=GETDATA&DATASETNAME=NIPA&TABLEID=35&FREQUENCY=Q&YEAR=X", "&ResultFormat=json", sep="")
resn <- fromJSON(getURL(reqn))
datan <- resn$BEA$Results$Data

## get real GDP data

req <- paste("http://www.bea.gov/api/data/?&UserID=", bea.api.key, 
             "&method=GETDATA&DATASETNAME=NIPA&TABLEID=36&FREQUENCY=Q&YEAR=X", "&ResultFormat=json", sep="")
res <- fromJSON(getURL(req))
data <- res$BEA$Results$Data

## Clean and order nominal data

valuen <- gsub(",", "", datan[,8])
valuesn <- as.numeric(valuen)
catsn <- datan[,4]
linen <- datan[,3]

periods <- datan[,5]
periods2 <- gsub("Q1", "-Mar-1", periods) 
periods3 <- gsub("Q2", "-Jun-1", periods2) 
periods4 <- gsub("Q3", "-Sep-1", periods3) 
periods5 <- gsub("Q4", "-Dec-1gdp", periods4) 
datesn <- ymd(periods5)

dfn <- data.frame(linen, catsn, datesn, valuesn)
sectorsn <- split(dfn, dfn$linen)

## Clean and order real data

value <- gsub(",", "", data[,8])
values <- as.numeric(value)
cats <- data[,4]
line <- data[,3]

periods <- data[,5]
periods2 <- gsub("Q1", "-Mar-1", periods) 
periods3 <- gsub("Q2", "-Jun-1", periods2) 
periods4 <- gsub("Q3", "-Sep-1", periods3) 
periods5 <- gsub("Q4", "-Dec-1", periods4) 
dates <- ymd(periods5)

df <- data.frame(line, cats, dates, values)
sectors <- split(df, df$line)

## get q/q growth rates
growthrate <- function(x) {
        a <- diff(x, difference = 1)
        z <- a/x[1:length(x)-1]
        print(z, digits = 2)
}

G <- NULL
for(i in (1:62)) {G[i] <- as.character(sectorsn[[i]][1,1])}

H <- NULL
for(i in (1:62)) {H[i] <- as.character(sectors[[i]][1,1])}

I <- cbind(G, H)

gdpn = function(number, quarters=40){
        xn <- sectorsn[[number]]
        xn <- xn[order(xn[,3]),]
        growthn <- (1+(growthrate(xn$valuesn)))^4-1
        xgrowthn <- cbind(xn[2:nrow(xn),], growthn)
        xgrowthn <- xgrowthn[(nrow(xgrowthn)-quarters):nrow(xgrowthn),]
        share = round(xn[length(xn[,4]),4]/
                              sectorsn[[1]][length(sectorsn[[1]][,4]),4], 3)
        g <- ggplot(xgrowthn, aes(datesn,growthn)) + geom_path() + stat_smooth()
        g <- g + ggtitle(sectorsn[[number]][2,2])
        nominalchart = g + annotate("text", x=xgrowthn[quarters-12,3], y= -0.03, 
                                    label = paste("Share of GDP =", share))+ ylab("Nom Q Ann Growth") + xlab("Date")                                                                              
        nominalchart
}

gdp = function(number, quarters=40){
        renumber <- which(I[,2] == I[number,1])
        x <- sectors[[renumber]]
        xn <- sectorsn[[number]]
        x <- x[order(x[,3]),]
        xn <- xn[order(xn[,3]),]
        growth <- (1+(growthrate(x$values)))^4-1
        xgrowth <- cbind(x[2:nrow(x),], growth)
        xgrowth <- xgrowth[(nrow(xgrowth)-quarters):nrow(xgrowth),]
        share = round(xn[length(xn[,4]),4]/
                              sectorsn[[1]][length(sectorsn[[1]][,4]),4], 3)
        g <- ggplot(xgrowth, aes(dates,growth)) + geom_path() + stat_smooth()
        g <- g + ggtitle(sectors[[renumber]][2,2]) 
        realchart = g + annotate("text", x=xgrowth[quarters-12, 3],y=-.03, 
                                 label = paste("Share of GDP =", share)) + ylab("Real Q Ann Growth") + xlab("Date")                                                                                 
        realchart
}

both = function(number, quarters=40){
        plot1 <- gdpn(number=number, quarters=quarters)
        plot2 <- gdp(number=number, quarters=quarters)
        grid.arrange(plot1,plot2,nrow=2)
}

gdpnlevel = function(number, quarters=40){
        levn <- data.frame(sectorsn[[number]])
        levn <- levn[order(levn[,3]),]
        loglev <- data.frame(seq(1:length(levn[,1])),levn[,3], log(levn[,4]))
        colnames(loglev) <- c("Index", "Date", "Sector")
        loglev <- loglev[(nrow(loglev) - quarters):nrow(loglev),]
        regression <- lm(Sector ~ Index, data=loglev)
        pred <- summary(regression)$coef[1] + 
                summary(regression)$coef[2]*loglev$Index
        slope <- round(summary(regression)$coef[2] * 4,3)
        label <- paste("Slope =",slope)
        loglev <- data.frame(loglev, pred)
        share = round(sectorsn[[number]][length(sectorsn[[number]][,4]),4]/
                              sectorsn[[1]][length(sectorsn[[1]][,4]),4], 3)
        p <- ggplot(loglev, aes(Date)) + geom_line(aes(y=pred)) 
        p <- p + geom_line(aes(y=Sector, colour="Sector"))
        p <- p + ggtitle(sectorsn[[number]][2,2]) + ylab("Nom Log Lev") + xlab("Date")
        p <- p + theme(legend.position="none")
        p + annotate("text", x=loglev[quarters-12,2], y = min((loglev[,3])+.3), label=label)
}

gdplevel = function(number, quarters=40){
        renumber <- which(I[,2] == I[number,1])
        lev <- data.frame(sectors[[renumber]])
        lev <- lev[order(lev[,3]),]
        loglev <- data.frame(seq(1:length(lev[,1])),lev[,3], log(lev[,4]))
        colnames(loglev) <- c("Index", "Date", "Sector")
        loglev <- loglev[(nrow(loglev) - quarters):nrow(loglev),]
        regression <- lm(Sector ~ Index, data=loglev)
        pred <- summary(regression)$coef[1] + 
                summary(regression)$coef[2]*loglev$Index
        slope <- round(summary(regression)$coef[2] * 4,3)
        label <- paste("Slope =",slope)
        loglev <- data.frame(loglev, pred)
        share = round(sectorsn[[number]][length(sectorsn[[number]][,4]),4]/
                              sectorsn[[1]][length(sectorsn[[1]][,4]),4], 3)
        p <- ggplot(loglev, aes(Date)) + geom_line(aes(y=pred)) 
        p <- p + geom_line(aes(y=Sector, colour="Sector"))
        p <- p + ggtitle(sectors[[renumber]][2,2]) + ylab("Real Log Lev") + xlab("Date")
        p <- p + theme(legend.position="none")
        p + annotate("text", x=loglev[quarters-12,2], y = min((loglev[,3])+.1), label=label)
}

bothlev = function(number, quarters=40){
        plot1 <- gdpnlevel(number=number, quarters=quarters)
        plot2 <- gdplevel(number=number, quarters=quarters)
        grid.arrange(plot1,plot2,nrow=2)
}

List <- NULL
List2 <- NULL
for(i in 1:62) {List[i] = as.character(sectorsn[[i]][1,2])}
for(i in 1:62) {List2[i] = as.character(sectorsn[[i]][1,1])}
L2 <- cbind(List, seq(1:62))


shinyServer(
        function(input, output) {
                output$oid1 <- renderPrint({input$id1})
                output$oids <- renderPrint({input$dropbox})
                output$chart <- renderPlot({both(as.numeric(L2[L2[,1] == input$dropbox,2]),input$id1)})
                output$chart2 <- renderPlot({bothlev(as.numeric(L2[L2[,1] == input$dropbox,2]), input$id1)})
        }        
)
