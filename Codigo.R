
library(tidyverse)
library(readxl)
library(janitor)
library(broom)
library(gt)
library(modelsummary)
library(margins)

# ===============================
# 1. Importar datos
# ===============================

data_raw <- read_excel("DATA.xlsx")

# limpiar nombres de columnas
data <- data_raw %>%
  clean_names()

# estructura
glimpse(data)

#primeras filas
head(data)


# ===============================
# 2. Preparar datos del modelo
# ===============================

model_data <- data %>%
  transmute(
    # Variable dependiente (Y)
    churn = churn_1_yes_0_no,

    # Variables explicativas (X)
    customer_age_months = customer_age_in_months,  # antigüedad del cliente en meses
    chi_now      = chi_score_month_0,              # CHI actual
    chi_change   = chi_score_0_1,                  # cambio en CHI
    cases_now    = support_cases_month_0,          # # casos de soporte actuales
    cases_change = support_cases_0_1,              # cambio en # de casos
    priority_now = sp_month_0,                     # prioridad promedio de soporte hoy
    priority_change = sp_0_1,                      # cambio en prioridad
    logins_change = logins_0_1,                    # cambios en logins
    blogs_change  = blog_articles_0_1,             # cambios en blogs publicados
    views_change  = views_0_1,                     # cambios en views
    days_since_last_login_change = days_since_last_login_0_1  # cambio días sin login
  )


glimpse(model_data)

#distribución de churn
table(model_data$churn, useNA = "ifany")

# tasa promedio de churn
mean(model_data$churn)



# ===============================
# 3. Estadísticas descriptivas
# ===============================

# Descriptivos globales
summary(model_data)

# Descriptivos por grupo de churn
desc_by_churn <- model_data %>%
  group_by(churn) %>%
  summarise(
    n = n(),
    avg_age          = mean(customer_age_months, na.rm = TRUE),
    avg_chi_now      = mean(chi_now, na.rm = TRUE),
    avg_chi_change   = mean(chi_change, na.rm = TRUE),
    avg_cases_now    = mean(cases_now, na.rm = TRUE),
    avg_priority_now = mean(priority_now, na.rm = TRUE),
    avg_logins_change = mean(logins_change, na.rm = TRUE),
    avg_views_change  = mean(views_change, na.rm = TRUE),
    avg_days_since_last_login_change = mean(days_since_last_login_change, na.rm = TRUE)
  )

desc_by_churn