
############################# LSTM DNN Model ##################################################
## Function ANN.test.training
## Parameters:  
## list: data input
## epochs: number of epochs
## units: Number of neuros within the hidden layer

library(keras)
library(yardstick)
library(dplyr)


ANN.test.training<-function(list,epochs,units){
  ## Empty dataframes to save the results. According to the number of epochs 
  results.epochs.loss<-matrix(ncol = 10,nrow = epochs)  #ncol number of folds, nrow = number of epochs 
  results.epochs.accuracy<-matrix(ncol = 10,nrow = epochs)  #ncol number of folds, nrow = number of epochs 
  
  results.epochs.val_loss<-matrix(ncol = 10,nrow = epochs)
  results.epochs.val_accuracy<-matrix(ncol = 10,nrow = epochs)
  
  results.predictions<-list()
  results.training<-list()
  
  results.metrics<-setNames(data.frame(matrix(ncol = 7,nrow = 10)),c("Acurracy Test","Acurracy Training","AUC","PR AUC","Precision","Recall","F1"))
  results.times<-setNames(data.frame(matrix(ncol = 3,nrow = 10)),c("start","end","end_time"))
  
  for(i in 1:length(list)){
    results.times[i,1]<-Sys.time()
    ### Prepare data ######
    df<-list[[i]]
    df$DEFAULT<-as.numeric(as.character(df$DEFAULT))
    #Training
    df.training<-df%>%filter(SET.IS == "TRAINING")%>%select(c(LIMIT_BAL:DEFAULT))
    df.training.targer<-as.matrix(df.training%>%select(DEFAULT))
    df.training<-df.training%>%select(LIMIT_BAL:PAY_AMT6)
    df.training<-as.matrix(df.training)
    dimnames(df.training)<-NULL
    
    #Validation
    df.validation<-df%>%filter(SET.IS == "TEST")%>%select(c(LIMIT_BAL:DEFAULT))
    df.validation.targer<-as.matrix(df.validation%>%select(DEFAULT))
    df.validation<-df.validation%>%select(LIMIT_BAL:PAY_AMT6)
    df.validation<-as.matrix(df.validation)
    dimnames(df.validation)<-NULL
    
    ###  ANN Model ########
    use_session_with_seed(1) # Same seed
    options(keras.view_metrics = FALSE) # doen't show the loss and gain chart
    
    model<-keras_model_sequential()%>%
      layer_flatten(input_shape = dim(df.training)[2])%>%  #input layer
      layer_dense(units = units, activation = "relu", use_bias = TRUE)%>% #hidden laye
      layer_dense(1,activation = "sigmoid", use_bias = TRUE) #output layer
    
    model %>% 
      compile(loss = "binary_crossentropy",optimizer = "adam",metrics = "accuracy")
    
    history<-model %>% 
      fit(
        df.training,     
        df.training.targer,
        epochs = epochs,
        batch_size = 32,
        verbose = 0,  # Print the epochs 
        validation_split = 0,
        validation_data = list(df.validation, df.validation.targer))
    
    results.epochs.loss[,i]<-history$metrics$loss           # loss per epoch training
    results.epochs.accuracy[,i]<-history$metrics$acc        # accuracy per epoch training
    
    results.epochs.val_loss[,i]<-history$metrics$val_loss   # loss per epoch validation
    results.epochs.val_accuracy[,i]<-history$metrics$val_acc  #accuracy per epoch validation
    
    predictions<-model%>%predict_classes(df.validation)       # Predictions
    predictions.prob<-model%>%predict_proba(df.validation) %>% as.vector()  # Prob Predictions 
    
    predictions.training<-model%>%predict_classes(df.training)    # Predictions Training
    
    results.predictions[[i]]<-tibble::tibble(
      Real = as.factor(df.validation.targer),
      Estimate = as.factor(predictions),
      Prob = predictions.prob)
    
    results.training[[i]]<-tibble::tibble(
      Real.training = as.factor(df.training.targer),
      Estimate.training = as.factor(predictions.training))
    
    options(yardstick.event_first = FALSE)

    results.metrics[i,1]<-data.frame(results.predictions[[i]] %>%  yardstick::metrics(Real, Estimate))[1,3] #accuracy test
    results.metrics[i,2]<-data.frame(results.training[[i]] %>%  yardstick::metrics(Real.training, Estimate.training))[1,3] #accuracy training
    results.metrics[i,3]<-data.frame(results.predictions[[i]] %>% yardstick::roc_auc(Real, Prob))[,3] # ROC AUC
    results.metrics[i,4]<-data.frame(results.predictions[[i]] %>% mutate(Estimate=as.numeric(as.character(Estimate)))%>%yardstick::pr_auc(Real,Estimate))[3] # PR AUC
    results.metrics[i,5]<-data.frame(results.predictions[[i]] %>% yardstick::precision(Real, Estimate))[,3] #Precision
    results.metrics[i,6]<-data.frame(results.predictions[[i]] %>% yardstick::recall(Real, Estimate))[,3] # Recall
    results.metrics[i,7]<-data.frame(results.predictions[[i]] %>% yardstick::f_meas(Real, Estimate, beta = 1))[,3] # F1
    
    results.times[i,2]<-Sys.time()
    results.times[i,3]<-(results.times[i,2]-results.times[i,1])/60
  }
  return(list(results.epochs.loss,results.epochs.accuracy,results.epochs.val_loss,results.epochs.val_accuracy,results.predictions,results.metrics,results.times))
}



############### ANN Target Mean Encoding with SMOTE 300 epochs#########################
results.ann.targetmean.1.300.nosmote<-ANN.test.training(kfold.targetMean.scale.nosmote,300,1)
results.ann.targetmean.5.300.nosmote<-ANN.test.training(kfold.targetMean.scale.nosmote,300,5)
results.ann.targetmean.10.300.nosmote<-ANN.test.training(kfold.targetMean.scale.nosmote,300,10)
results.ann.targetmean.15.300.nosmote<-ANN.test.training(kfold.targetMean.scale.nosmote,300,15)
results.ann.targetmean.20.300.nosmote<-ANN.test.training(kfold.targetMean.scale.nosmote,300,20)
results.ann.targetmean.23.300.nosmote<-ANN.test.training(kfold.targetMean.scale.nosmote,300,23)


############### ANN Frequency Encoding with SMOTE 300 epochs ###########################
results.ann.frequency.1.300.nosmote<-ANN.test.training(kfold.frequencyEncoding.scale.nosmote,300,1)
results.ann.frequency.5.300.nosmote<-ANN.test.training(kfold.frequencyEncoding.scale.nosmote,300,5)
results.ann.frequency.10.300.nosmote<-ANN.test.training(kfold.frequencyEncoding.scale.nosmote,300,10)
results.ann.frequency.15.300.nosmote<-ANN.test.training(kfold.frequencyEncoding.scale.nosmote,300,15)
results.ann.frequency.20.300.nosmote<-ANN.test.training(kfold.frequencyEncoding.scale.nosmote,300,20)
results.ann.frequency.23.300.nosmote<-ANN.test.training(kfold.frequencyEncoding.scale.nosmote,300,23)

############### ANN One-Hot Encoding with SMOTE 300 epochs #############################

results.ann.onehot.1.300.nosmote<-ANN.test.training(kfold.onehotEncoding.sale.nosmote,300,1)
results.ann.onehot.6.300.nosmote<-ANN.test.training(kfold.onehotEncoding.sale.nosmote,300,6)
results.ann.onehot.12.300.nosmote<-ANN.test.training(kfold.onehotEncoding.sale.nosmote,300,12)
results.ann.onehot.18.300.nosmote<-ANN.test.training(kfold.onehotEncoding.sale.nosmote,300,18)
results.ann.onehot.23.300.nosmote<-ANN.test.training(kfold.onehotEncoding.sale.nosmote,300,23)
results.ann.onehot.27.300.nosmote<-ANN.test.training(kfold.onehotEncoding.sale.nosmote,300,27)