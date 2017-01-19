rm(list = ls())

# ����������� �������
library(dplyr)
library(tidyr)
library(ggplot2)
library(nortest)
library(corrplot)
library(tictoc)
library(irr)

# �������� ������� ����������
getwd()
# setwd("d:/Oleh/�������������/Points")
# setwd("D:/D/�������������/Points")

# ���������� ������
points <- read.table("������/points.txt", 
                     header = F, 
                     col.names = c("x", "y"), 
                     sep = ";")

###############################################################################
# ��������� �������� ������
###############################################################################
limMin <- 0                      # ������� �������
limMax <- 600                    # ������� �������
p <- 15                          # ���-�� ����� ��� ������� �����������
st <- dim(points)[1]/p           # ���-�� ������������
k <- rep(1:15, times = dim(points)[1]/p)        # ������ ����
student <- rep(1:st, each = dim(points)[1]/st)  # ����� ����������� 

# ����������� ������
points <- tbl_df(cbind(points, k, student))
colnames(points) <- c("x", "y", "k", 'student')

summary(points)                  # ������� ������������ ����������

points[which(points$x>600 | points$y>600),] # ����� ��������
# ������ ������
exclude <- c(5, 14, 15, 20, 22, 24, 34, 37, 42, 44, 48)
'%!in%' <- function(x,y)!('%in%'(x,y)) # ������� ��������� ��� "not in"

# ���������� ������������ �� ������ "exclude"
points <- points %>% 
        filter(x <= 600, y <= 600) %>% 
        filter(student %!in%  exclude) %>%
        select(-student) 

# ���������� ������ ���� � ������ �����������
st <- dim(points)[1]/p
student <- rep(1:st, each = dim(points)[1]/st)

points <- mutate(points, 
                 student = student,
                 k =  k)

###############################################################################
# ��������� ����� ��������� ������������
###############################################################################
addStudents <- 1000 # ���-�� ����� ������������

set.seed(998)           # ��� ����������������� ���������� ������ ������
x <- rnorm(addStudents * p, 300, 73) # ���������� "x" �� ����. �����.
set.seed(999)           # ��� ����������������� ���������� ������ ������
y <- rnorm(addStudents * p, 300, 73) # ���������� "y" �� ����. �����.
range(x); range(y)

# ��������� ������ � ������ �������������
st <- st + addStudents # ���-�� ������������ ����� ���������� �����
student <- rep((st-addStudents+1):st, each = p) # ������ ����� ������������
k <- rep(1:15, times = addStudents) # ����� ���� ��� ����� ������������

pointsNew <- tbl_df(cbind(x, y, k, student)) # ���������� ������ ����� ������
points <- bind_rows(points, pointsNew) # ���������� ����� ������ �� �������

# ����� ���� ������
points <- mutate(points,
                 x = as.integer(x),
                 y = as.integer(y),
                 k = as.factor(k),
                 student = as.factor(student))

# ������� ����� ��������

xMin <- min(points$x)
xMax <- max(points$x)

yMin <- min(points$y)
yMax <- max(points$y)

range(points$x * (xMax - xMin) + xMin)
range(points$y * (yMax - yMin) + yMin)

points <- mutate(points,

                 k = as.factor(k),
                 r = sqrt(x^2+y^2),
                 alpha = acos(y/r) * 180 / pi
                 
                 # cosAlpha = y/r,
                 # xn = (x - min(x))/(max(x)-min(x)),
                 # yn = (y - min(y))/(max(y)-min(y)),
)


points
range(points$x); range(points$y)

check <- mutate(points,
       
        xReinc = r*sin(alpha * pi / 180),
        yReinc = r*cos(alpha * pi / 180)
       # k = as.factor(k),
       # r = sqrt(x^2+y^2),
       # alpha = acos(y/r) * 180 / pi
       
       # cosAlpha = y/r,
       # xn = (x - min(x))/(max(x)-min(x)),
       # yn = (y - min(y))/(max(y)-min(y)),
)
check

sum(check$x - check$xReinc)
identical(check$x, as.integer(check$xReinc))

# �������� �������� ��� ���������
pointsUn <- gather(points, "xy", "coord", 1:2) %>%
    mutate(k = as.factor(k),
           student = as.factor(student),
           xy = as.factor(xy))

# �������� �������� ��� ����������
pointsUnFeature <- gather(points, "feature", "value", 5:6) %>%
        mutate(k = as.factor(k),
               student = as.factor(student),
               feature = as.factor(feature))