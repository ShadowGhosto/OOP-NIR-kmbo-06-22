library("reticulate")
library("caret")
library("dplyr")
#Необходимые модули Python
pd <- import("pandas")
np <- import("numpy")
model_selection <- import("sklearn.model_selection")
linear_model <- import("sklearn.linear_model")
ensemble <- import("sklearn.ensemble")

#Считывание данных из CSV-файла
data = pd$read_csv('C:/Users/Иван/Desktop/уник/R/StudentsPerformance.csv')

#Соответствующие столбцы и строки с отсутствующими значениями
data_sel <- data[ ,c("gender", "race/ethnicity", "parental level of education", "lunch", "test preparation course", "math score", "reading score", "writing score")]
data_sel <- na.omit(data_sel)
data_sel$race_ethnicity <- ifelse(data_sel$`race/ethnicity` == "group C", 0, 1)

#Новый столбец и факторную переменную на основе столбца "раса/этническая принадлежность"
Race_ethnicity = factor(data_sel[ ,c("race/ethnicity")])
X_data = data[ ,c("gender", "parental level of education", "lunch", "test preparation course", "math score", "reading score", "writing score")]

#Данные на обучающие и тестовые наборы
train_test_split <- model_selection$train_test_split(X_data, Race_ethnicity, train_size = 0.7, random_state = 123L)
X_train <- train_test_split[[1]]
X_test <- train_test_split[[2]]
y_train <- train_test_split[[3]]
y_test <- train_test_split[[4]]

#Определенние переменных в коэффициенты
X_train$gender <- factor(X_train$gender)
X_test$gender <- factor(X_test$gender)
y_train <- factor(y_train)
y_test <- factor(y_test)

#Замена категориальных переменных на Фиктивные переменных, используя обучающие данные
dummyvars <- dummyVars(" ~ .", data = X_train[, c("gender", "parental level of education", "lunch", "test preparation course")])
X_train_dummy <- predict(dummyvars, newdata = X_train)
X_test_dummy <- predict(dummyvars, newdata = X_test)

#Прогноз на основе данных тестирования с помощью линейной регрессии
logreg <- linear_model$LogisticRegression()
logreg$fit(X_train_dummy, y_train)
y_pred <- logreg$predict(X_test_dummy)
y_pred <- factor(y_pred, levels = levels(y_test))
#Точность, отзыв и оценку F1, используя метод линейной регрессии
print(confusion_matrix <- confusionMatrix(y_pred, y_test)$table)
print(precision <- confusion_matrix[3, 3] / sum(confusion_matrix[, 3]))# 0.5148515
print(recall <- confusion_matrix[3, 3] / sum(confusion_matrix[3, ]))# 0.3421053
print(F1 <- 2 * precision * recall / (precision + recall))# 0.4110672


#Пример использования Random Forest
rf <- ensemble$RandomForestClassifier(n_estimators = 100L, random_state = 123L)
rf$fit(X_train_dummy, y_train)
y_pred <- rf$predict(X_test_dummy)
y_pred <- factor(y_pred, levels = levels(y_test))
#Точность, отзыв и оценку F1, используя метод случайный лес
print(confusion_matrix <- confusionMatrix(y_pred, y_test)$table)
print(precision <- confusion_matrix[3, 3] / sum(confusion_matrix[, 3]))# 0.4356436
print(recall <- confusion_matrix[3, 3] / sum(confusion_matrix[3, ]))# 0.3697479
print(F1 <- 2 * precision * recall / (precision + recall))# 0.4

#Различные комбинации гиперпараметров для случайного дерева с шагом 50 в параметре n_estimators
param_grid <- list(n_estimators = c(50L, 100L, 150L, 200L, 250L))
rf <- ensemble$RandomForestClassifier(random_state = 123L)
rf_grid <- model_selection$GridSearchCV(rf, param_grid = param_grid, cv = 5L, scoring = "f1_macro")
rf_grid$fit(X_train_dummy, y_train)
#Вывод лучших значений для шага 50 в параметре n_estimators 
print(rf_grid$best_params_)
#Прогноз на основе данных тестирования с помощью случайного дерева с шагом 50 в параметре n_estimators
rf_best <- ensemble$RandomForestClassifier(n_estimators = rf_grid$best_params_$n_estimators, random_state = 123L)
rf_best$fit(X_train_dummy, y_train)

y_pred <- rf_best$predict(X_test_dummy)
y_pred <- factor(y_pred, levels = levels(y_test))
#Точность, отзыв и оценку F1, используя метод случайный лес с шагом 50 
print(confusion_matrix <- confusionMatrix(y_pred, y_test)$table)
print(precision <- confusion_matrix[3, 3] / sum(confusion_matrix[, 3]))# 0.4356436
print(recall <- confusion_matrix[3, 3] / sum(confusion_matrix[3, ]))# 0.3697479
print(F1 <- 2 * precision * recall / (precision + recall))# 0.4

#Различные комбинации гиперпараметров для случайного дерева с шагом 10 в параметре n_estimators
param_grid <- list(n_estimators = c(10L, 20L, 30L, 40L, 50L, 60L, 70L, 80L, 90L))
rf <- ensemble$RandomForestClassifier(random_state = 123L)
rf_grid <- model_selection$GridSearchCV(rf, param_grid = param_grid, cv = 5L, scoring = "f1_macro")
rf_grid$fit(X_train_dummy, y_train)
#Вывод лучших значений для шага 10 в параметре n_estimators
print(rf_grid$best_params_)
#Прогноз на основе данных тестирования с помощью случайного дерева с шагом 10 в параметре n_estimators
rf_best <- ensemble$RandomForestClassifier(n_estimators = rf_grid$best_params_$n_estimators, random_state = 123L)
rf_best$fit(X_train_dummy, y_train)

y_pred <- rf_best$predict(X_test_dummy)
y_pred <- factor(y_pred, levels = levels(y_test))
#Точность, отзыв и оценку F1, используя метод случайный лес с шагом 10
print(confusion_matrix <- confusionMatrix(y_pred, y_test)$table)
print(precision <- confusion_matrix[3, 3] / sum(confusion_matrix[, 3]))# 0.4455446
print(recall <- confusion_matrix[3, 3] / sum(confusion_matrix[3, ]))# 0.3571429
print(F1 <- 2 * precision * recall / (precision + recall))# 0.3964758
#Недостаточном количеством данных для обучения модели, особенно если в данных присутствует много шума и несбалансированных классов.
#Неправильным выбором гиперпараметров модели, таких как количество деревьев и их глубина.





##### Можно попытаться увеличить точность модели с помощью добавление других гиперпараметров и анализа важности признаков:
param_grid <- list(n_estimators = c(50L, 100L, 150L, 200L, 250L),
                   max_depth = c(3L, 5L, 7L, 9L, 11L),
                   min_samples_split = c(2L, 5L, 10L, 15L, 20L),
                   min_samples_leaf = c(1L, 2L, 4L, 8L, 16L),
                   max_features = c(5L, 10L, "sqrt", "log2", NULL))
rf <- ensemble$RandomForestClassifier(random_state = 123L)
rf_grid <- model_selection$GridSearchCV(rf, param_grid = param_grid, cv = 5L, scoring = "f1_macro")
rf_grid$fit(X_train_dummy, y_train)
#Вывод лучших значений для шага 50 в параметре n_estimators 
print(rf_grid$best_params_)
#Прогноз на основе данных тестирования с помощью случайного дерева с шагом 50 в параметре n_estimators
rf_best <- ensemble$RandomForestClassifier(n_estimators=150L, 
                                           max_depth=9L,
                                           min_samples_split=20L,
                                           min_samples_leaf=2L,
                                           max_features="sqrt",
                                           random_state=123L)
rf_best$fit(X_train_dummy, y_train)

importance <- rf_best$feature_importances_

sorted_indices <- order(importance, decreasing = TRUE)


top_features <- sorted_indices[1:4]
X_train_top <- X_train_dummy[, top_features]
X_test_top <- X_test_dummy[, top_features]

rf_top <- ensemble$RandomForestClassifier(n_estimators = 150L, max_depth = 9L, min_samples_split = 20L, min_samples_leaf = 2L, max_features = "sqrt", random_state = 123L)
rf_top$fit(X_train_top, y_train)


y_pred <- rf_top$predict(X_test_top)
y_pred <- factor(y_pred, levels = levels(y_test))
#Точность, отзыв и оценку F1, используя метод случайный лес с шагом 50 
print(confusion_matrix <- confusionMatrix(y_pred, y_test)$table)
print(precision <- confusion_matrix[3, 3] / sum(confusion_matrix[, 3]))# 0.9306931
print(recall <- confusion_matrix[3, 3] / sum(confusion_matrix[3, ]))# 0.3574144
print(F1 <- 2 * precision * recall / (precision + recall))# 0.5164835

#Различные комбинации гиперпараметров для случайного дерева с шагом 10 в параметре n_estimators
param_grid <- list(n_estimators = c(10L, 20L, 30L, 40L, 50L, 60L, 70L, 80L),
                   max_depth = c(3L, 5L, 7L, 9L, 11L),
                   min_samples_split = c(2L, 5L, 10L, 15L, 20L),
                   min_samples_leaf = c(1L, 2L, 4L, 8L, 16L),
                   max_features = c(5L, 10L, "sqrt", "log2", NULL))
rf <- ensemble$RandomForestClassifier(random_state = 123L)
rf_grid <- model_selection$GridSearchCV(rf, param_grid = param_grid, cv = 5L, scoring = "f1_macro")
rf_grid$fit(X_train_dummy, y_train)
#Вывод лучших значений для шага 10 в параметре n_estimators
print(rf_grid$best_params_)
#Прогноз на основе данных тестирования с помощью случайного дерева с шагом 10 в параметре n_estimators
rf_best <- ensemble$RandomForestClassifier(n_estimators=80L, 
                                           max_depth=9L,
                                           min_samples_split=2L,
                                           min_samples_leaf=1L,
                                           max_features="sqrt",
                                           random_state=123L)
rf_best$fit(X_train_dummy, y_train)

importance <- rf_best$feature_importances_

sorted_indices <- order(importance, decreasing = TRUE)


top_features <- sorted_indices[1:4]
X_train_top <- X_train_dummy[, top_features]
X_test_top <- X_test_dummy[, top_features]

rf_top <- ensemble$RandomForestClassifier(n_estimators = 80L, max_depth = 9L, min_samples_split = 2L, min_samples_leaf = 1L, max_features = "sqrt", random_state = 123L)
rf_top$fit(X_train_top, y_train)


y_pred <- rf_top$predict(X_test_top)
y_pred <- factor(y_pred, levels = levels(y_test))
#Точность, отзыв и оценку F1, используя метод случайный лес с шагом 10
print(confusion_matrix <- confusionMatrix(y_pred, y_test)$table)
print(precision <- confusion_matrix[3, 3] / sum(confusion_matrix[, 3]))# 0.8613861
print(recall <- confusion_matrix[3, 3] / sum(confusion_matrix[3, ]))# 0.3411765
print(F1 <- 2 * precision * recall / (precision + recall))# 0.488764
## Добавление новых параметров привело к улучшениям моделей

###Вывод: Основываясь на данных исследования Students performance in exams можно сделать вывод о том, 
#что лучшим типом классификатора является Random Forest так как имеет большую точность чем LogisticRegression 
