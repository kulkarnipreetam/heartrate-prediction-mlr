# 🚴‍♂️ Modeling Gym Equipment User Heartrate with Multiple Linear Regression

The study aims to model how various exercise and personal factors influence heartrate during cycling, helping fitness trainers tailor safe workout programs for individuals with cardiovascular concerns.

---

## 🔍 Problem Description

For individuals with cardiovascular disease, particularly older adults, monitoring exercise intensity is critical to avoid complications. Heartrate (beats per minute) serves as a key indicator of workout intensity and stamina limits. This project analyzes heartrate data collected at the Maverick Activities Center to identify significant predictors of heartrate during cycling exercise.

---

## 📊 Variables

- **Response Variable:**
  - **Heartrate (beats per minute)**
- **Predictors:**
  - **RPM (x₁):** Revolutions per minute on the cycling machine  
  - **Incline level (x₂):** Difficulty level of the exercise  
  - **Weight (x₃):** Weight of the person performing the exercise  
  - **Age (x₄):** Age of the person performing the exercise  

---

## 📉 Data Exploration & Correlations

- Heartrate showed **low correlation** with RPM (r = 0.071), with possible outliers near 120 RPM.
- Heartrate and Incline level demonstrated a moderate **positive trend** (r = 0.398).
- Heartrate and Weight displayed a **negative but weak correlation**, with scattered values.
- Heartrate and Age exhibited a **strong negative correlation** (r = -0.641), suggesting heartrate decreases as age increases, potentially with a slight curvilinear effect.

---

## 🔍 Model Assumptions & Diagnostics

- Residual vs. predictor plots showed **no curvature**, supporting linear relationships.
- Potential outliers noted for Age (50-60 years) and RPM (110-120 RPM), but overall no serious deviations.
- Residuals vs. predicted values plot indicated **constant variance** (no funnel shape).
- Normal probability plot confirmed **normality of residuals**.
- Modified Levene’s and normality tests supported adequacy of the MLR model form.
- No data transformations were necessary.

---

## 🔄 Interaction Terms & Multicollinearity

- Based on partial regression plots, these three interaction terms were considered for inclusion:  
  - \( x₁  x₂ \) (RPM × Incline level)  
  - \( x₁  x₄ \) (RPM × Age)  
  - \( x₂  x₃ \) (Incline level × Weight)  

- Predictors and interaction terms were standardized before constructing interaction variables.  
- Correlation analysis revealed:  
  - High correlation of \( x₁  x₂ \) and \( x₂  x₃ \) with Incline level.  
  - High correlation of \( x₁  x₄ \) with Age.  
- After standardization, none of the interaction terms had correlations exceeding 0.7 with predictors, indicating **no serious multicollinearity concerns**.

---

## 🔍 Model Selection & Final Models

- Employed **backward deletion**, **best subsets**, and **stepwise regression** methods to identify optimal models.  
- Two candidate models were finalized for comparison:

| Model | Equation                                      | Predictors                |
|-------|-----------------------------------------------|----------------------------|
| A     | ŷ = 143.773 + 1.276 x₂ − 1.025 x₄          | Incline level & Age        |
| B     | ŷ = 154.444 − 1.102 x₄                      | Age only                   |

- Diagnostic checks for outliers, leverage, and influential points were conducted for both models.
  
| Metric           | Model A                           | Model B                      |
|:------------------|:---------------------------------:|:------------------------------:|
| # Of predictors  | 2                               | 1                            |
| R²               | 0.5076                          | 0.4112                       |
| Adjusted R²      | 0.4768                          | 0.3933                       |
| Residuals vs. ŷ  | Constant variance               | Constant variance            |
| Residuals vs. Predictors | No curvature seen             | No curvature seen            |
| Normal Probability Plot (NPP) | Slightly right skewed; close to normality | Slightly left skewed; close to normality |
| VIF              | All VIFs are less than 5        | Only one predictor; VIF not an issue |
| Mallows’ Cₚ      | 1.996                           | 5.112                        |
| AIC              | 190.887                        | 195.145                      |
| SBC              | 195.553                        | 198.255                      |
| x-outliers       | 5                               | 4                            |
| y-outliers       | None                            | None                         |
| Influence        | None of the outliers are influential | One outlier influential      |
- Model A demonstrated:  
  - Higher \( R² \) and adjusted \( R² \) values.  
  - Lower Mallows'  Cₚ , AIC, and SBC compared to Model B.  
  - Presence of outliers that were **not influential**, thus retained.

---

## 🏁 Final Model

The selected model (Model A) is:

ŷ = 143.773 + 1.276 x₂ − 1.025 x₄

- The coefficient **1.276** indicates the expected increase in mean heartrate per unit increase in Incline level, holding Age constant.  
- The coefficient **−1.025** indicates the expected decrease in mean heartrate per unit increase in Age, holding Incline level constant.

This model explains approximately **50.76%** of the variability in heartrate.

---
## 💬 Final Discussion & Recommendations

- Model A, with predictors Age and Incline level, is the best fit based on statistical criteria and diagnostic checks.
- Five outliers were identified but none had undue influence on the model.
- The relatively modest \(R²\) suggests room for improvement with additional predictors.
- Future work could include variables such as:
  - **BMI (Body Mass Index):** To account for obesity effects on heartrate.
  - **Smoking status:** As a binary predictor impacting cardiovascular response.

---


## Important Notice

The code in this repository is proprietary and protected by copyright law. Unauthorized copying, distribution, or use of this code is strictly prohibited. By accessing this repository, you agree to the following terms:

- **Do Not Copy:** You are not permitted to copy any part of this code for any purpose.
- **Do Not Distribute:** You are not permitted to distribute this code, in whole or in part, to any third party.
- **Do Not Use:** You are not permitted to use this code, in whole or in part, for any purpose without explicit permission from the owner.

If you have any questions or require permission, please contact the repository owner.

Thank you for your cooperation.
