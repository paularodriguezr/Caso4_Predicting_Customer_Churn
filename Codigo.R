install.packages(c("tidyverse", "readxl", "janitor", "broom", "gt", "modelsummary", "margins"))

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

# Guardar tabla descriptiva como imagen (usa gt + webshot2)
if (!requireNamespace("webshot2", quietly = TRUE)) install.packages("webshot2")

desc_table <- desc_by_churn %>%
  mutate(across(where(is.numeric), ~round(., 2))) %>%
  gt()

gtsave(desc_table, "desc_by_churn.png")

# ===============================
# 4. Modelo de regresión logística
# ===============================

logit_model <- glm(
  churn ~ customer_age_months +
    chi_now + chi_change +
    cases_now + cases_change +
    priority_now +
    logins_change + blogs_change + views_change +
    days_since_last_login_change,
  data = model_data,
  family = binomial(link = "logit")
)

summary(logit_model)

# Tabla bonita con coeficientes, OR, IC y significancia
if (!requireNamespace("webshot2", quietly = TRUE)) install.packages("webshot2")

tidy_mod <- broom::tidy(logit_model, conf.int = TRUE) %>%
  mutate(
    OR       = exp(estimate),
    OR_low   = exp(conf.low),
    OR_high  = exp(conf.high),
    signif   = case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01  ~ "**",
      p.value < 0.05  ~ "*",
      TRUE            ~ ""
    ),
    estimate_lbl = sprintf("%.3f%s", estimate, signif),
    OR_lbl       = sprintf("%.3f (%.3f - %.3f)", OR, OR_low, OR_high)
  ) %>%
  select(term, Coef = estimate_lbl, `Std. Error` = std.error, `Odds Ratio (95% CI)` = OR_lbl, `p-value` = p.value)

reg_table_gt <- tidy_mod %>%
  gt(rowname_col = "term") %>%
  cols_label(
    term = "",
    Coef = "Coeficiente (sig.)",
    `Std. Error` = "Std. Error",
    `Odds Ratio (95% CI)` = "Odds Ratio (95% CI)",
    `p-value` = "p-value"
  ) %>%
  fmt_number(columns = vars(`Std. Error`, `p-value`), decimals = 3) %>%
  tab_header(
    title = "Modelo Logit de Probabilidad de Churn",
    subtitle = "Coeficientes, Odds Ratios e intervalos de confianza"
  ) %>%
  tab_source_note("Significancia: *** p<0.001, ** p<0.01, * p<0.05")

gtsave(reg_table_gt, "tabla_regresion_logit.png")

# ===============================
# 5. Metricas Globales del Modelo
# ===============================
null_model <- glm(churn ~ 1, data = model_data, family = binomial(link = "logit"))
mcfadden_r2 <- 1 - as.numeric(logLik(logit_model) / logLik(null_model))

glance_info <- broom::glance(logit_model)

tabla_glance_modelo <- tibble::tibble(
  Modelo = "Modelo Logit",
  Pseudo_R2_McFadden = round(mcfadden_r2, 4),
  AIC  = round(glance_info$AIC, 1),
  BIC  = round(glance_info$BIC, 1),
  logLik = round(as.numeric(logLik(logit_model)), 3),
  n_obs  = glance_info$nobs
)

tabla_glance_modelo

# Guardar como imagen (gt + webshot2)
if (!requireNamespace("webshot2", quietly = TRUE)) install.packages("webshot2")

tabla_glance_gt <- tabla_glance_modelo %>%
  gt() %>%
  cols_label(
    Modelo = "Modelo",
    Pseudo_R2_McFadden = "Pseudo R² (McFadden)",
    AIC = "AIC",
    BIC = "BIC",
    logLik = "logLik",
    n_obs = "n"
  ) %>%
  fmt_number(columns = vars(`Pseudo_R2_McFadden`), decimals = 4) %>%
  fmt_number(columns = vars(`AIC`, `BIC`), decimals = 1) %>%
  fmt_number(columns = vars(`logLik`), decimals = 3) %>%
  tab_header(
    title = "Tabla de métricas globales del modelo",
    subtitle = "Pseudo R² de McFadden y medidas de ajuste"
  )

gtsave(tabla_glance_gt, "tabla_glance_modelo.png")

# ------------------------------------------------------------
# 6) Efectos marginales promedio
# ------------------------------------------------------------
ame_obj <- margins::margins(logit_model)
ame_sum <- summary(ame_obj)
print(ame_sum)

# Guardar tabla CSV
write.csv(as.data.frame(ame_sum),
          file = "efectos_marginales_promedio.csv",
          row.names = FALSE)

# Tabla bonita
ame_gt <- as.data.frame(ame_sum) %>%
  mutate(across(where(is.numeric), round, 4)) %>%
  gt() %>%
  tab_header(
    title = "Efectos Marginales Promedio del Modelo Logit",
    subtitle = "Interpretación del impacto promedio de cada variable sobre la probabilidad de churn"
  )

gtsave(ame_gt, "efectos_marginales_promedio.png")


# ------------------------------------------------------------
# 7) Probabilidades predichas y matriz de confusión
# ------------------------------------------------------------
model_data <- model_data %>%
  mutate(
    p_hat = predict(logit_model, type = "response"),
    churn_pred = ifelse(p_hat >= 0.5, 1, 0)
  )

# Matriz de confusión
conf_matrix <- table(Real = model_data$churn, Predicho = model_data$churn_pred)
accuracy <- mean(model_data$churn == model_data$churn_pred)

print(conf_matrix)
print(paste("Accuracy del modelo:", round(accuracy, 4)))

# Guardar matriz y resultado
write.csv(as.data.frame(conf_matrix), "matriz_confusion.csv", row.names = FALSE)

conf_gt <- as.data.frame(conf_matrix) %>%
  gt() %>%
  tab_header(
    title = "Matriz de Confusión del Modelo Logit",
    subtitle = paste("Accuracy del modelo:", round(accuracy, 4))
  )

gtsave(conf_gt, "matriz_confusion.png")


# ------------------------------------------------------------
# 8) Gráfico de residuos estandarizados vs probabilidad predicha
# ------------------------------------------------------------
# Crear residuos estandarizados
res_std <- rstandard(logit_model, type = "deviance")

# Crear dataframe para graficar
df_res2 <- tibble(
  prob_predicha = model_data$p_hat,
  resid_estandarizado = res_std
)

# Graficar residuos estandarizados
p_res2 <- ggplot(df_res2, aes(x = prob_predicha, y = resid_estandarizado)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, color = "blue", linetype = "dashed") +
  labs(
    x = "Probabilidad predicha de churn",
    y = "Residuos estandarizados",
    title = "Gráfico de residuos estandarizados vs probabilidad predicha"
  ) +
  theme_minimal()

ggsave("grafico_residuos_estandarizados.png", p_res2, width = 7, height = 4)
