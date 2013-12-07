#--------------------------------------
# Bing He, Stephen Cristiano 2013-12-06
#--------------------------------------
# summary FACS ouput scores
# This R script summerizes the output
## from BFAC and calculate the 
## accuracy
## specificity and sensitivity
#------------------------------

b <- read.table("matchscores_NC_005363.1.obj.txt",sep="\t",header=F)
e1 <- read.table("matchscores_NC_010473.1.obj.txt",sep="\t",header=F)
e2 <- read.table("matchscores_NC_020518.1.obj.txt",sep="\t",header=F)

score <- cbind(b[,2],e1[,2],e2[,2])
colnames(score) <- c("bdello","ecoli1","ecoli2")

classification <- apply(score,1,function(temp) {
		if(max(temp) <= 0.8) {
			return(0)
		}
		class = which(temp == max(temp))
		if(length(class) == 1) {
			return(class[1])
		}
		else {
			return(sample(class,1))
		}
	})

accuracy <- (sum(classification[1:5000] == 1) + sum(classification[5001:10000] == 2))/10000

senE <- (sum(classification[5001:10000] == 2))/5000

specE <- (sum(classification[1:5000] == 1) + sum(classification[1:5000] == 0) +  sum(classification[1:5000] == 3))/10000

senB <- (sum(classification[1:5000] == 1))/5000

specB <- (sum(classification[5001:10000] == 2) + sum(classification[5001:10000] == 0) +  sum(classification[5001:10000] == 3))/10000

write.table(c(accuracy , senE , specE ,senB ,specB ), file="summaryStat.txt",append=T,sep="\t")
print(c(accuracy , senE , specE ,senB ,specB ))
