# Caso4_Predicting_Customer_Churn
Caso 4


## Descripción general

Este repositorio contiene el desarrollo completo del **Caso 4: Predicción y prevención de la deserción de clientes en QWE Inc.**, cuyo objetivo fue **identificar los factores determinantes del abandono de clientes** mediante la estimación de un **modelo logit de probabilidad de churn**.  

QWE Inc. es una empresa dedicada a ofrecer servicios de gestión de presencia en línea para pequeñas y medianas compañías. A partir de su base de datos histórica, se aplicaron técnicas de analítica de datos para detectar patrones de comportamiento que permitan implementar una estrategias de retención proactiva y reducir la pérdida de usuarios.

---

## Estructura del repositorio

- Caso4_PredictingCustomer_Documento.pdf → Informe final del caso (análisis, resultados y conclusiones)

- Codigo.R → Script principal en R con la limpieza, modelado y evaluación

- DATA.xlsx → Base de datos original utilizada para el análisis (6.347 observaciones)


## Resumen metodológico

1. **Preparación de datos:**  
   Limpieza e importación de la base `DATA.xlsx`, creación del marco analítico `model_data` y verificación de la variable objetivo (`churn_1_yes_0_no`).

2. **Análisis descriptivo:**  
   Cálculo de estadísticas por grupo de churn y generación de una tabla descriptiva (`gt()`) para comparar características entre clientes retenidos y desertores.

3. **Estimación del modelo logit:**  
   Aplicación de un modelo de regresión logística para predecir la probabilidad de abandono en función de variables como satisfacción (CHI), uso de la plataforma, soporte y antigüedad.

4. **Evaluación del modelo:**  
   Cálculo de métricas de desempeño (R² = 0.0440, accuracy ≈ 94.9%), matriz de confusión, residuos y curva ROC para validar su capacidad predictiva.

---

## Principales hallazgos

- Los clientes menos satisfechos (CHI bajo o decreciente) y con menor actividad reciente presentan mayor probabilidad de abandono.  
- La inactividad prolongada y el aumento en los casos de soporte son señales tempranas de riesgo.  
- El modelo logit permite a QWE Inc. anticipar el churn y priorizar acciones preventivas, optimizando recursos de retención.

---

## Conclusión general

El modelo desarrollado, aunque con un poder explicativo moderado (R² de 0.0440), ofrece una herramienta predictiva confiable para la toma de decisiones en QWE Inc.  
Permite pasar de una gestión reactiva del cliente a una estrategia proactiva de fidelización basada en datos, centrada en monitorear la satisfacción y la actividad de uso del servicio.

---

## Autores

Proyecto elaborado por:
- Juan Sebastian Cardenas
- Valery Ramirez
- Paula Rodriguez
Analítica de Negocios 

Pontificia Universidad Javeriana – 2025-2  
Profesor: **Juan Nicolás Velásquez Rey**
