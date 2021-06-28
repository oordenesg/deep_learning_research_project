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
<img src = "https://user-images.githubusercontent.com/76072249/123530972-691c4700-d6ce-11eb-8d03-fc75708a102a.png" width = "500" height = "180">
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





