results=vector(mode="list", 10L)
for (i in 1:10){
	load(paste0(i, ".Rdata"))
	results[[i]]=output
}
save(results, file="combinedresults.Rdata")
