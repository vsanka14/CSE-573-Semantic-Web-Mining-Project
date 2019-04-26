# load libraries
install.packages("Matrix")
install.packages("irlba")
install.packages("topicmodels")
install.packages("ROCR")

require(Matrix)
library(ROCR)
library(topicmodels)
library(irlba)

# load files
users<-read.csv("../data/users.csv")
likes<-read.csv("../data/likes.csv")
ul<-read.csv("../data/users-likes.csv")

# construct the matrix
ul$user_row<-match(ul$userid,users$userid)
ul$like_row<-match(ul$likeid,likes$likeid)

M<-sparseMatrix(i=ul$user_row,j=ul$like_row,x=1)
rownames(M)<-users$userid
colnames(M)<-likes$name
rm(ul,likes)

# Matrix trimming
while (T){
  i<-sum(dim(M))
  M<-M[rowSums(M)>=50, colSums(M)>=150]
  if (sum(dim(M))==i) break
}
users <- users[match(rownames(M),users$userid), ]

# Start predictions
set.seed(seed=68)
n_folds<-10                # set number of folds
k<-50                      # set k
vars<-colnames(users)[-1]  # choose variables to predict

folds <- sample(1:n_folds, size = nrow(users), replace = T)

results<-list()
for (fold in 1:n_folds){ 
  print(paste("Cross-validated predictions, fold:", fold))
  test <- folds == fold
  
  # if you want to use SVD:
  Msvd <- irlba(M[!test, ], nv = k)
  v_rot <- unclass(varimax(Msvd$v)$loadings)
  predictors <- as.data.frame(as.matrix(M %*% v_rot))
  
  # if you want to use LDA, comment out the SVD lines above, and uncomment two lines below
  #Mlda <- LDA(M[!test, ], control = list(alpha = 1, delta = .1, seed=68), k = k, method = "Gibbs")
  #predictors <- as.data.frame(posterior(Mlda,M, control = list(alpha = 1, delta = .1))$topics)
  
  for (var in vars){
    results[[var]]<-rep(NA, n = nrow(users))
    # check if the variable is dichotomous
    if (length(unique(na.omit(users[,var]))) ==2) {    
      fit <- glm(users[,var]~., data = predictors, subset = !test, family = "binomial")
      results[[var]][test] <- predict(fit, predictors[test, ], type = "response")
    } else {
      fit<-glm(users[,var]~., data = predictors, subset = !test)
      results[[var]][test] <- predict(fit, predictors[test, ])
    }
    print(paste(" Variable", var, "done."))
  }
}

compute_accuracy <- function(ground_truth, predicted){
  if (length(unique(na.omit(ground_truth))) ==2) {
    f<-which(!is.na(ground_truth))
    temp <- prediction(predicted[f], ground_truth[f])
    return(performance(temp,"auc")@y.values)
  } else {return(cor(ground_truth, predicted,use = "pairwise"))}
}

accuracies<-list()
for (var in vars) accuracies[[var]]<-compute_accuracy(users[,var], results[[var]])
accuracies