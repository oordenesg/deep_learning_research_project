############################# LSTM DNN Model ##################################################
## Function LSTM_DNN.test.training
## Parameters:  
## list: data input
## epochs: number of epochs
## units1.sea: Number of units within the cell (LSTM)
## units1.sta: Number of neuros within the first hidden layer (DNN)
## units1.sta: Number of neuros within the second hidden layer (DNN)

library(keras)
library(yardstick)
library(dplyr)

LSTM_DNN.test.training<-function(list,epochs,units1.sea,units1.sta,units2.sta){
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
    
    # Seasonal and static
    df.training.seasonal<-df.training%>%select(PAY_1:PAY_AMT6)
    df.training.static<-df.training%>%select(LIMIT_BAL:AGE)
    
    df.training.seasonal<-as.matrix(df.training.seasonal)
    df.training.static<-as.matrix(df.training.static)
    
    dimnames(df.training.seasonal)<-NULL
    dimnames(df.training.static)<-NULL
    
    df.training.seasonal<-df.training.seasonal%>% array(dim = c(nrow(df.training.seasonal),6,3)) #array_reshape(df.training,c(nrow(df.training),6,3))
    
    
    #Validation
    
    df.validation<-df%>%filter(SET.IS == "TEST")%>%select(c(LIMIT_BAL:DEFAULT))
    df.validation.targer<-as.matrix(df.validation%>%select(DEFAULT))
    df.validation<-df.validation%>%select(LIMIT_BAL:PAY_AMT6)
    
    # Seasonal and static
    df.validation.seasonal<-df.validation%>%select(PAY_1:PAY_AMT6)
    df.validation.static<-df.validation%>%select(LIMIT_BAL:AGE)
    
    df.validation.seasonal<-as.matrix(df.validation.seasonal)
    df.validation.static<-as.matrix(df.validation.static)
    
    dimnames(df.validation.seasonal)<-NULL
    dimnames(df.validation.static)<-NULL
    
    df.validation.seasonal <- df.validation.seasonal %>% array(dim = c(nrow(df.validation.seasonal),6,3))
    
    
    ###  LSTM DNN Model ########
    use_session_with_seed(1) # Same seed
    options(keras.view_metrics = FALSE) # Show the loss and gain chart
    
    seasonal.input <- layer_input(shape = c(6,3), name = "seasonal") #Dynamic branch
    static.input <- layer_input(dim(df.training.static)[2], name = "static") #Static branch
    
    model.seasonal<-seasonal.input%>%layer_lstm(units = units1.sea,input_shape = c(6,3)) #input shape
    
    model.static<-static.input%>%
      layer_flatten(input_shape = dim(df.training.static)[2])%>%
      layer_dense(units = units1.sta, activation = "relu", use_bias = TRUE)%>%
      layer_dense(units = units2.sta, activation = "relu", use_bias = TRUE)
    
    combined_model<-layer_concatenate(c(model.seasonal,model.static))%>%
      layer_dense(units = 1,activation = "sigmoid") #output
    
    model<-keras_model(inputs = c(seasonal.input, static.input), outputs = combined_model)
    
    model %>% compile(
      loss = 'binary_crossentropy',
      optimizer = 'adam',
      metrics = 'accuracy'
    )
    
    history<-model %>% fit(
      x =list(df.training.seasonal,df.training.static), 
      y = df.training.targer, 
      batch_size = 32,
      epochs = epochs,
      verbose = 0,
      validation_data = list(list(df.validation.seasonal,df.validation.static), df.validation.targer)
    )
    
    
    results.epochs.loss[,i]<-history$metrics$loss           # loss per epoch training
    results.epochs.accuracy[,i]<-history$metrics$acc        # accuracy per epoch training
    
    results.epochs.val_loss[,i]<-history$metrics$val_loss   # loss per epoch validation
    results.epochs.val_accuracy[,i]<-history$metrics$val_acc  #accuracy per epoch validation
    
    
    predictions<-as.data.frame(model%>%predict(list(df.validation.seasonal,df.validation.static)))
    predictions<-predictions%>%mutate(class = ifelse(V1 > 0.5,1,0))%>%select(class)
    colnames(predictions)<-NULL
    predictions<-as.matrix(predictions)   # Predictions
    
    predictions.prob<-model%>%predict(list(df.validation.seasonal,df.validation.static))%>% as.vector() # Prob Predictions
    
    predictions.training<-as.data.frame(model%>%predict(list(df.training.seasonal,df.training.static)))
    predictions.training<-predictions.training%>%mutate(class = ifelse(V1 > 0.5,1,0))%>%select(class)
    colnames(predictions.training)<-NULL
    predictions.training<-as.matrix(predictions.training)   # Predictions Training
    
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
    
    results.times[i,2]<-Sys.time() #Time
    results.times[i,3]<-(results.times[i,2]-results.times[i,1])/60   #Time
  }
  return(list(results.epochs.loss,results.epochs.accuracy,results.epochs.val_loss,results.epochs.val_accuracy,results.predictions,results.metrics,results.times))
}

#### Results using datasets with Target Mean, Frequency and One-Hot encoding

results.lstm_dnn.targetmean.2000.20<-LSTM_DNN.test.training(kfold.targetMean.scale,2000,20,5,5) 
results.lstm_dnn.frequency.2000.20<-LSTM_DNN.test.training(kfold.frequencyEncoding.scale,2000,20,5,5)
results.lstm_dnn.onehot.2000.20<-LSTM_DNN.test.training(kfold.onehotEncoding.scale,2000,20,9,9)

