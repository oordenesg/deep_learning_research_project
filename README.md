# Deep Learning Research Project

## Aim and Objectives

The use of artificial intelligence techniques have allowed the financial sector to apply algorithms and techniques that improve the predictive capacity of models in the area of credit risk. Additionally, the decrease in technological costs has allowed financial institutions to develop more robust models using a greater volume of data.

This project presents different Deep Learning algorithms applied to the area of credit risk. In each of them, various structures are evaluated as well as different values for the hyperparameters. In this work, three techniques were also applied on categorical variables as well as an oversampling technique was used in order to avoid bias in the results. The first contribution of this work was to address the various weaknesses found in previous studies that have applied deep learning techniques within the area of credit risk. This made it possible to avoid bias in the results and make fair comparisons between the proposed models.

The second contribution of this study is the comparison between the three encoding techniques applied in the categorical variables. With this, it was possible to determine which of them is the most suitable for this particular problem. The third contribution was the correct application of oversampling and 10-fold Crossvalidation techniques, which were not correctly applied in previous studies analysed. The use of these methods together made it possible to avoid biases in the results of the models. Finally, the fourth contribution is the comparison of both different structures within the same model as well as the comparison between different models. With this, it was possible to select the most suitable algorithm for this data set as well as to discard different structures that are not adequate to improve the performance of the evaluation metrics.

## FrameWork and Metrics

The standard flow of any data science project was used in this project.

<p align="center">
<img src = "https://user-images.githubusercontent.com/76072249/123530853-2a39c180-d6cd-11eb-92f7-e911bd315fcb.png" width="500" height="120">
</p>
To measure the performance of the proposed models, the following metrics were used.
<p align="center">
<img src = "https://user-images.githubusercontent.com/76072249/123530871-50f7f800-d6cd-11eb-976f-fe0f2f7091ec.png" width = "500" height = "160">
</p>

## Data Analysis

An exploratory analysis was carried out in order to know the characteristics of the attributes. The data set contains.

- 45,000 instances and 25 attributes. 3 categorical variables and 20 numerical variables.
- Categorical variables with low cardinality.
- Customer information between the months of April and September 2016.

<p align="center">
<img src ="https://user-images.githubusercontent.com/76072249/123530989-b3052d00-d6ce-11eb-95fa-3ff09217f67d.png" width = "360" height = "150">
 </p>

The main insights obtained at this stage:

- No outliers were found.
- High proportion of non-default clients.
- Categories without a clear description within some attributes.
- There are dynamic variables that are highly correlated with each other.
<p align="center">
<img src = "https://user-images.githubusercontent.com/76072249/123530972-691c4700-d6ce-11eb-8d03-fc75708a102a.png" width = "450" height = "180">
  </p>
  
## Data Transformation

1. Encoding Techniques.
  
- The One-Hot, Frequency and Target Mean encoding techniques were applied in the three categorical variables.
- ML and DP Algorithms performance vary based on the way in which the categorical data is encoded. How the results vary according to these techniques.

2. Oversampling

- Unbalanced data set. The SMOTE oversampling technique was applied in the minority class (default customers).
- The goal was to prevent overfitting given the number of non-default customers.


3. 10-fold Crossvalidation

- This process divided the dataset 10 into parts. Of all of them, 9 were used to train the model while the remaining set was used in the testing stage
- The SMOTE oversampling technique was applied only within the training sets

## Data Modelling – Artificial Neural Network (ANN)

This base model allowed:
- Establish a baseline
- Verify the effectiveness of the SMOTE oversampling technique as well as the encoding techniques
- Determine the appropriate number of neurons

<p align="center">
<img src = "https://user-images.githubusercontent.com/76072249/123574405-c16e4a00-d79d-11eb-8290-07cf3cb79aa6.png" width = "420" height = "150">
</p>

The results showed that:
- SMOTE was necessary to prevent overfitting
- One-Hot encoding performed best
- For the network with SMOTE, the best performance was obtained using a number of neurons similar to the amount of input


#### Table 2: ANN model results
 
| Oversampling | Encoding       | Accuracy Test | ROC AUC |Precision| Recall |F1     | PR AUC|
| :---         |     :---:      |      :---:    | :---:   |  :---:  | :---:  |:---:  | :---: |
| No SMOTE     | Target Mean    |81.7%          |77.4%    |64.4%    |39.9%   |49.3%  |58.9%  |
| No SMOTE     | Frequency      |81.7%          |77.4%    |64.9%    |39.6%   |49.1%  |59.0%  |
| No SMOTE     | One-Hot        |81.8%          |77.6%    |65.1%    |39.7%   |49.3%  |59.1%  |
| SMOTE        | Target Mean    |75.3%          |79.4%    |46.4%    |66.9%   |54.8%  |60.4%  |
| SMOTE        | Frequency      |75.0%          |79.4%    |45.4%    |66.4%   |54.3%  |59.9%  |
| SMOTE        | One-Hot        |75.0%          |79.8%    |46.0%    |67.7%   |54.7%  |60.4%  |

Having  validated  the  relevance  of  oversampling,  we  eval-uated  the  importance  of  the  categorical  variables  in  the  dataset with SMOTE. To do this, we removed the non-numericalattributes  and  evaluated  neural  networks  with  8,  15  and  21hidden layers.

#### Table 3: ANN model results without categorical variables
 
| Metric    | ANN 8 Hidden Layers | ANN 15 Hidden Layers | ANN 21 Hidden Layers|
| :---      |     :---:           |      :---:           | :---:               | 
| Accuracy  | 67.8%               |71.2%                 |73.0%                |
| ROC       | 70.1%               |72.3%                 |74.3%                |
| Precision | 38.3%               |40.8%                 |43.4%                |
| Recall    | 55.5%               |59.3%                 |62.6%                |
| F1        | 45.3%               |48.3%                 |51.2%                |
| PRC       | 49.5%               |75.0%                 |54.9%                |



## Data Modelling - Deep Neural Network (DNN)

This model was developed using the insights obtained from the previous model.
- Evaluate different structures within the network
- Validate the use of the dropout technique
- Determine the most suitable encoding technique

<p align="center">
<img src = "https://user-images.githubusercontent.com/76072249/123666680-6e30e180-d807-11eb-808b-38eda59b9267.png" width = "420" height = "150">
</p>

The results showed that:

- Dropout was not necessary. There were no signs of overfitting
- One-Hot encoding performed best (Again)
- The network with 6 hidden layers obtained the best results

#### Table 3: DNN model results
| Dropout      | Hidden Layers  | Encoding      |Accuracy Test| ROC AUC |Precision| Recall |F1     | PR AUC|
| :---         |     :---:      |      :---:    |    :---:    | :---:   |  :---:  | :---:  |:---:  | :---: |
| No           | 2              |One-Hot        |74.9%        |82.9%    |46.2%    |75.0%   |57.1%  |63.4%  |
| Yes          | 2              |One-Hot        |78.5%        |79.1%    |51.7%    |57.9%   |54.6%  |59.5%  |
| No           | 4              |One-Hot        |77.9%        |87.3%    |50.3%    |83.8%   |62.8%  |68.8%  |
| Yes          | 4              |One-Hot        |78.9%        |78.7%    |52.6%    |57.8%   |55.0%  |59.9%  |
| No           | 6              |One-Hot        |78.9%        |89.6%    |51.6%    |91.1%   |65.9%  |72.4%  |
| Yes          | 6              |One-Hot        |78.9%        |78.7%    |52.6%    |57.8%   |55.0%  |59.9%  |


## Data Modelling - Long Short Term Memory Model (LSTM)

In this model the dynamic and static characteristics of the data were evaluated. This allowed us.
- Validate the importance of categorical variables
- Use the dynamic characteristics of customer credit information
- Determine the most suitable encoding technique

<p align="center">
<img src = "https://user-images.githubusercontent.com/76072249/123881359-7aee2c00-d912-11eb-8c65-740a63cf60cb.png" width = "400" height = "150">
</p>

The results showed that:
- LSTM + DNN model is more accurate in identifying default customers (Compared to LSTM).
- One-Hot encoding performed best (Again)
- The categorical variables are relevant to identify the default clients.


#### Table 4: LSTM model results
| Metric      | LSTM | LSTM + DNN Target Mean |LSTM + DN Frequency| LSTM + DNN One-Hot|
| :---        |:---: | :---:                  |    :---:          | :---:             | 
| Accuracy    |77.1% |76.2%                   |76.0%              |75.8%              |
| ROC AUC     |82.6% |83.4%                   |83.3%              |83.8%              |
| Precision   |49.2% |48.0%                   |47.7%              |47.4%              |
| Recall      |70.2% |73.4%                   |73.9%              |75.6%              |
| F1          |57.8% |58.0%                   |57.9%              |58.2%              |
| PRC AUC     |63.0% |63.7%                   |63.8%              |64.2%              |

## Results

<p align="center">
<img src = "https://user-images.githubusercontent.com/76072249/123967273-27b4c180-d984-11eb-89fc-64435f8680a0.png" width = "420" height = "150">
</p>
<p align="center">
<img src = "https://user-images.githubusercontent.com/76072249/123967411-4915ad80-d984-11eb-8737-dcca1e47acc2.png" width = "420" height = "150">
</p>

- The Deep Learning models performed better compared to the base ANN model. 
- The ANN model demonstrated that the use of the SMOTE oversampling technique is suitable for this project.
- In general, the network with six hidden layers had the highest performance in all evaluation metrics.
- In all models, One-Hot encoding is the most suitable technique for this dataset.
- LSTM and LSTM-DNN models, on average, are 4 times more expensive during the training stage compared to the DNN model with six neurons.

## Conclusion

- One of the main contributions of this project was to have addressed the different limitations found in various studies that used this dataset.
- The models proposed and applied in this project are suitable for the credit risk industry.
- The encoding techniques were only applied in the categorical attributes. However, these techniques could also have been applied in numerical variables such as Age.
- In terms of oversampling techniques, there are other methods like ADASYN that can be analysed.
- Expand the range of values for hyperparameters and use more activation functions.
- Evaluate the application of an autoencoder model to detect anomalies.




