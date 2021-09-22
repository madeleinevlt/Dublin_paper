library(png)
library(grid)
library(dbscan)
library(readr)
library(ggplot2)
library(extrafont)
loadfonts()

data<- read_csv("metadata.csv")

borders <- read_delim("borders.csv", ";", escape_double = FALSE, trim_ws = TRUE)

data$image="NA"


for (i in 1:length(data$cluster)) {
  color=data[i,]$color
  print(color)
  if (data[i,]$matrix=="milk") {
    data[i,]$image="b"
  }
  else if (data[i,]$matrix=="cow") {
    data[i,]$image="c"
  }
  else {
    data[i,]$image="a"
  }
  
}


pX=cbind(data$x,data$y)
pXtest2=pX
d <- pointdensity(pXtest2, eps = .01, type = "density")
plot(pXtest2, pch = 19, main = "Density (eps = .5)", cex = d*5)
u=ifelse(d > 0.55,'red','green')
plot(pXtest2, pch = 19, main = "Density (eps = .1)", col= u)

for (i in 1:261) {
  while (d[i]>0.55) {
    pXtest2[i,1]=pXtest2[i,1]+runif(1,-0.02,0.02)
    pXtest2[i,2]=pXtest2[i,2]+runif(1,-0.02,0.02)
    d <- pointdensity(pXtest2, eps = .01, type = "density")
  }
}


img <- readPNG("matrix_paper.png")
g <- rasterGrob(img, interpolate=TRUE)

img2 <- readPNG("gradient.PNG")
g2 <- rasterGrob(img2, interpolate=TRUE)

img3 <- readPNG("arrow.png")
g3 <- rasterGrob(img3, interpolate=TRUE)


test = pXtest2
test2= data.frame(long=borders$long, lat=borders$lat)

p=ggplot(data=as.data.frame(test),aes(V1,V2)) +
  geom_path(data = test2, aes(x=long, y = lat)) +
  geom_text(label = data$image, family = "untitled-font-1", col=data$color, size=data$size) +
  annotation_custom(g2,xmin=6.64, xmax=6.99, ymin=45.25, ymax=Inf) + 
  annotation_custom(g, xmin=6.8, xmax=7.02, ymin=46.02, ymax=47) + 
  annotation_custom(g3, xmin=5.4, xmax=5.55, ymin=47, ymax=47.3) + 
  annotate("text",x=5.5,y=46.9,label='atop(bold("Region 1"))', parse=TRUE) +
  annotate("text",x=6.1,y=47.2,label='atop(bold("Region 2"))', parse=TRUE) +
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.background = element_blank(),
        axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())


ggsave("testplot2.pdf", plot=p,fonts="untitled-font-1")        
p
dev.off()
Sys.setenv(R_GSCMD = "C:/Program Files/gs/gs9.54.0/bin/gswin64c.exe")
embed_fonts("testplot2.pdf", outfile="testplot2_embed.pdf")

