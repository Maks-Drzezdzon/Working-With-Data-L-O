library(tidyverse)
library(readxl) # read xlsx
library(feather) # file format lib
library(skimr) # summary statistics for larger data sets
library(car)
library(nortest)
library(psych)

# Maksymilian Drzezdzon

####################
# Data Exploration # 
####################

# loading data
df = read_excel('idepen_proj_stats.xlsx')
df = read_feather('idepen_proj_stats.feather')

# basic exploration
head(df)
summary(df)
glimpse(df)
colnames(df)
# how many missing values are in each col
map(df , ~sum(is.na(.)))

# looking at cols with potential problems 
unique(df$PHONE)
unique(df$...10) # found potential issues

unique(df$JOB) # found potential issues
unique(df$UNIVERSITY)
unique(df$SCHOOL_NAT)
unique(df$ACADEMIC_PROGRAM)

unique(df$EDU_FATHER) 
# found potential issues a field with a value of 0, 
# however this could indicate something else such as an absent parent, 
# it will be left as is
unique(df$OCC_FATHER) # found potential issues, ^
unique(df$EDU_MOTHER) # found potential issues, ^
unique(df$OCC_MOTHER) # found potential issues, ^
#########################
# variables of interest #
#########################

colnames(df)

# looking for odd values which can be found easily via unique, such as negative values on exams etc

unique(df$SISBEN) # found potential issues
unique(df$INTERNET)
unique(df$TV)
unique(df$COMPUTER)
unique(df$WASHING_MCH)
unique(df$CAR)
unique(df$MIC_OVEN)
unique(df$DVD)
unique(df$FRESH)
unique(df$PHONE)
unique(df$MOBILE)

# Saber 11 EXAMS - no issues found
unique(df$MAT_S11) # maths
unique(df$CR_S11) # critical reading
unique(df$CC_S11) # citizen competencies
unique(df$BIO_S11) # biology
unique(df$ENG_S11) # communication in English

# SABER PRO EXAMS - no issues found
unique(df$CR_PRO) # critical reading
unique(df$QR_PRO) # quantitative reasoning
unique(df$CC_PRO) # citizen competencies
unique(df$WC_PRO) # written communication
unique(df$ENG_PRO) # communication in English


#################
# Data Cleaning # 
#################

# column is completely empty and serves no purpose 
df = df[,!names(df) %in% c("...10")]

# fixing inconsistency
df$SISBEN[df$SISBEN == "It is not classified by the SISBEN"] = "Level NA"
df$SISBEN[df$SISBEN == "Esta clasificada en otro Level del SISBEN"] = "Level NA"

df$SISBEN[df$SISBEN == "Level NA"] = 0
df$SISBEN[df$SISBEN == "0"] = 0
df$SISBEN[df$SISBEN == "Level 1"] = 1
df$SISBEN[df$SISBEN == "Level 2"] = 2
df$SISBEN[df$SISBEN == "Level 3"] = 3


df$JOB[df$JOB == "0"] = "No"

df$INTERNET[df$INTERNET == "Yes"] = 1
df$INTERNET[df$INTERNET == "No"] = 0

df$TV[df$TV == "Yes"] = 1
df$TV[df$TV == "No"] = 0

df$COMPUTER[df$COMPUTER == "Yes"] = 1
df$COMPUTER[df$COMPUTER == "No"] = 0

df$WASHING_MCH[df$WASHING_MCH == "Yes"] = 1
df$WASHING_MCH[df$WASHING_MCH == "No"] = 0

df$MIC_OVEN[df$MIC_OVEN == "Yes"] = 1
df$MIC_OVEN[df$MIC_OVEN == "No"] = 0

df$CAR[df$CAR == "Yes"] = 1
df$CAR[df$CAR == "No"] = 0

df$DVD[df$DVD == "Yes"] = 1
df$DVD[df$DVD == "No"] = 0

df$FRESH[df$FRESH == "Yes"] = 1
df$FRESH[df$FRESH == "No"] = 0

df$PHONE[df$PHONE == "Yes"] = 1
df$PHONE[df$PHONE == "No"] = 0

df$MOBILE[df$MOBILE == "Yes"] = 1
df$MOBILE[df$MOBILE == "No"] = 0

# saving file into feather while working on project
# it offers faster load times, however its not used
# to store data long term
write_feather(df, 'idepen_proj_stats.feather')
df = read_feather('idepen_proj_stats.feather')

#########################
# Testing for normality #
#########################


# fragmenting data
df_pro_exams =  data.frame(df$CR_PRO, df$QR_PRO, df$CC_PRO, df$WC_PRO, df$ENG_PRO)
summary(df_pro_exams)
# anderson-darling normality test is used over shapiro-wilks
# because it has a limitation of 5000 records 
# for comparison both give the same result
shapiro.test(df_pro_exams$df.CR_PRO[0:5000])
ad.test(df_pro_exams$df.CR_PRO)
ad.test(df_pro_exams$df.QR_PRO)
ad.test(df_pro_exams$df.CC_PRO)
ad.test(df_pro_exams$df.WC_PRO)
ad.test(df_pro_exams$df.ENG_PRO)
# p < 2.2e-16
qqPlot(df_pro_exams$df.CR_PRO, ylab = "critical reading exam scores")
qqPlot(df_pro_exams$df.QR_PRO, ylab = "quantitative reasoning exam scores")
qqPlot(df_pro_exams$df.CC_PRO, ylab = "citizen competencies exam scores")
qqPlot(df_pro_exams$df.WC_PRO, ylab = "written communication exam scores")
qqPlot(df_pro_exams$df.ENG_PRO, ylab = "communication in English exam scores")

hist(df_pro_exams$df.CR_PRO, xlab = "critical reading exam scores")
hist(df_pro_exams$df.QR_PRO, xlab = "quantitative reasoning exam scores")
hist(df_pro_exams$df.CC_PRO, xlab = "citizen competencies exam scores")
hist(df_pro_exams$df.WC_PRO, xlab = "written communication exam scores")
hist(df_pro_exams$df.ENG_PRO, xlab = "communication in English exam scores")

Boxplot(df_pro_exams$df.CR_PRO, ylab = "critical reading exam scores")
Boxplot(df_pro_exams$df.QR_PRO, ylab = "quantitative reasoning exam scores")
Boxplot(df_pro_exams$df.CC_PRO, ylab = "citizen competencies exam scores")
Boxplot(df_pro_exams$df.WC_PRO, ylab = "written communication exam scores")
Boxplot(df_pro_exams$df.ENG_PRO, ylab = "communication in English exam scores")

# from the visualizations, p-value and a-value the pro exams are NOT normally distributed

df_saber_exams =  data.frame(df$MAT_S11, df$CR_S11, df$CC_S11, df$BIO_S11, df$ENG_S11)
summary(df_saber_exams)

ad.test(df_saber_exams$df.MAT_S11)
ad.test(df_saber_exams$df.CR_S11)
ad.test(df_saber_exams$df.CC_S11)
ad.test(df_saber_exams$df.BIO_S11)
ad.test(df_saber_exams$df.ENG_S11)
# p < 2.2e-16

hist(df_saber_exams$df.MAT_S11, xlab = "maths exam scores")
hist(df_saber_exams$df.CR_S11, xlab = "critical reading exam scores")
hist(df_saber_exams$df.CC_S11, xlab = "citizen competencies exam scores")
hist(df_saber_exams$df.BIO_S11, xlab = "biology exam scores")
hist(df_saber_exams$df.ENG_S11, xlab = "communication in English exam scores")

boxplot(df_saber_exams$df.MAT_S11, ylab = "Maths Exam scores exam scores")
boxplot(df_saber_exams$df.CR_S11, ylab = "critical reading exam scores")
boxplot(df_saber_exams$df.CC_S11, ylab = "citizen competencies exam scores")
boxplot(df_saber_exams$df.BIO_S11, ylab = "biology exam scores")
boxplot(df_saber_exams$df.ENG_S11, ylab = "communication in English exam scores")

# even though the p value in normality test doesnt confirm normality, the low A value and
# visualizations confirm a normally distribution 

# testing
df_sisben = sapply(df_sisben, as.double)
glimpse(df_sisben)

df_sisben =  data.frame(df$SISBEN, df$INTERNET, df$TV, df$COMPUTER, df$WASHING_MCH, df$CAR, df$MIC_OVEN, df$DVD, df$FRESH, df$PHONE, df$MOBILE)

help("hist")
barplot(as.numeric(df_sisben$df.SISBEN), breaks=5)
hist(as.numeric(df_sisben$df.INTERNET), breaks=2)
hist(df_sisben$df.TV)
hist(df_sisben$df.COMPUTER)
hist(df_sisben$df.WASHING_MCH)

#######################
# Dimension Reduction #
#######################
prepare_matrix_data = df[,!names(df) %in% c("ACADEMIC_PROGRAM", "UNIVERSITY", "Cod_SPro", 
                                            "SCHOOL_TYPE", "SCHOOL_NAT", "SCHOOL_NAME", 
                                            "JOB", "REVENUE", "OCC_MOTHER",
                                            "OCC_FATHER", "EDU_MOTHER", "EDU_FATHER", "COD_S11", 
                                            "GENDER", "PEOPLE_HOUSE", "STRATUM",
                                            "SEL", "SEL_IHE", "QUARTILE", "2ND_DECILE",
                                            "WC_PRO", "PERCENTILE", "G_SC")]


prepare_matrix_data_tests = df[,!names(df) %in% c("ACADEMIC_PROGRAM", "UNIVERSITY", "Cod_SPro", 
                                                  "SCHOOL_TYPE", "SCHOOL_NAT", "SCHOOL_NAME", 
                                                  "JOB", "REVENUE", "OCC_MOTHER",
                                                  "OCC_FATHER", "EDU_MOTHER", "EDU_FATHER", "COD_S11", 
                                                  "GENDER", "PEOPLE_HOUSE", "STRATUM", "INTERNET",
                                                  "TV", "COMPUTER", "WASHING_MCH", "MIC_OVEN",
                                                  "CAR", "DVD", "FRESH", "PHONE", "MOBILE", 
                                                  "SEL", "SEL_IHE", "QUARTILE", "2ND_DECILE",
                                                  "WC_PRO", "PERCENTILE", "G_SC")]

glimpse(prepare_matrix_data)
glimpse(prepare_matrix_data_tests)

tests_matrix = sapply(prepare_matrix_data_tests, as.double)
matrix_data = sapply(prepare_matrix_data, as.double)
heatmap(cor(tests_matrix), Rowv = NA, Colv = NA)
heatmap(cor(matrix_data), Rowv = NA, Colv = NA)

cortest.bartlett(cor(tests_matrix), n=nrow(prepare_matrix_data_tests))
cortest.bartlett(cor(matrix_data), n=nrow(prepare_matrix_data))


result = corrplot::cor.mtest(cor(matrix_data), conf.level = .95)
corrplot::corrplot(cor(matrix_data), method="square", p.mat = result$p, type="lower", sig.level = .05)


KMOS(tests_matrix)
KMOS(matrix_data)

help(principal)

#There are 4 factors to extract
unique(df$SISBEN)
facsol = psych::fa(matrix_data, nfactors=4, obs=NA, n.iter=1, rotate="varimax", fm="pa")

#Create your scree plot
plot(facsol$values, type = "b")

#Print the Variance accounted for by each factor/component
facsol$Vaccounted
#Output the Eigenvalues
facsol$values 

#Print the components with loadings
psych::print.psych(facsol,cut=0.3, sort=TRUE)

#Print sorted list of loadings
fa.sort(facsol$loading)

#create a diagram showing the factors and how the manifest variables load
fa.diagram(facsol)






#Apply rotation to try to refine the component structure
facsolrot =  principal(matrix_data, nfactors = 4, rotate = "varimax")
#output the components
psych::print.psych(facsolrot, cut = 0.3, sort = TRUE)
#output the commonalities
facsolrot$communality

facsolrot$loadings
pre_rotation_loadings







PCA_data = sapply(prepare_matrix_data, as.double)
glimpse(PCA_data)
classes = factor(df$SISBEN)
# normalize data so larger values dont overweight smaller ones
dfPCA = prcomp(scale(PCA_data[, -1]))
# view PCA statistics
summary(dfPCA)
# this is used to see how many of the variables can be dropped and at what cost
# the cumulative proportion increases with each PC component
# for instance pc27 offers less than 1% up from pc26 making it not very useful
# you can then pick a cut off point to see how many components can be dropped

# the cut off for this analysis will be pc16-17 which allows the prediction of upto 90-92% the last 9-10 pc components only contribute 8-10%


plot(dfPCA$x, col=classes)




