# 🏥 MIMIC-IV Clinical Data Analysis
### Advanced SQL Analysis on Real Clinical Data — Oriented to AI in Healthcare

---

## 📋 Project Overview

This project applies advanced SQL to **MIMIC-IV Demo**, a real anonymised clinical dataset from Beth Israel Deaconess Medical Center (Boston), widely used as the gold standard for healthcare AI research.

Unlike synthetic datasets, MIMIC-IV contains real clinical complexity: timestamp-based records, missing data, administrative coding inconsistencies, and multi-dimensional patient trajectories. Working with it requires not just SQL skills, but clinical and analytical judgment.

> This is the second project in a learning path toward **AI Product Management and AI Strategy in Healthcare**, following the [Healthcare SQL Analysis](https://github.com/DaniHernanz/healthcare-sql-analysis) project built on synthetic data.

---

## 🗂️ Dataset

**MIMIC-IV Demo** — Medical Information Mart for Intensive Care
PhysioNet · Beth Israel Deaconess Medical Center · Google BigQuery

| Table | Description |
|---|---|
| `admissions` | Hospital admissions with timestamps, type, location, insurance, and mortality flag |
| `patients` | Demographics: gender, anchor age, year group, date of death |

**Key differences from synthetic data:**
- Timestamps (not just dates) → requires `TIMESTAMP_DIFF()` instead of date subtraction
- Real anonymisation: `anchor_age`, `anchor_year` instead of direct birth dates
- Missing and unknown values as clinically meaningful signals
- Multiple admission types reflecting real hospital coding practices

---

## 🔧 Technical Skills Applied

| Concept | Applied in |
|---|---|
| Aggregation + GROUP BY + HAVING | Questions 1, 2, 3, 4, 5 |
| TIMESTAMP_DIFF() | Questions 2, 4, 9 |
| AVG() on binary flag for mortality rate | Questions 1, 3, 5, 6, 7 |
| JOIN between admissions and patients | Questions 6, 7, 8, 9 |
| CTE (Common Table Expression) | Question 8 |
| Scalar subquery in WHERE | Question 9 |
| Multi-column ORDER BY | Questions 5, 6, 7 |

---

## 🏢 Clinical Business Questions Answered

### Q1 — Mortality by Admission Type
> How many admissions are there per admission type and what is the hospital mortality rate for each?

**Finding:** EW EMER. concentrates the highest volume of admissions, but URGENT shows the highest mortality rate — volume and mortality do not go hand in hand. This suggests URGENT patients present with greater clinical complexity, not just greater urgency.

**AI relevance:** Admission type is a strong predictor variable for triage and risk prediction models.

---

### Q2 — Average Length of Stay in Hours by Admission Type
> What is the average length of stay in hours per admission type?

**Finding:** URGENT admissions show the longest average stay, consistent with the highest mortality rate found in Q1 — reinforcing the clinical complexity profile of this group.

**AI relevance:** Length of stay is a key operational KPI and a relevant feature in hospital resource optimisation models.

---

### Q3 — Mortality Rate by Insurance Type
> What percentage of patients died during admission by insurance type?

**Finding:** Medicare concentrates the highest total deaths by volume (patients over 65), but Medicaid shows the highest mortality rate — pointing to worse access to preventive care among lower-income patients.

**AI relevance:** Insurance type is a proxy for socioeconomic status. Detecting mortality differences by insurance is fundamental in healthcare AI equity models to identify and mitigate systematic biases.

---

### Q4 — Multi-Admission Patients and Time Span
> Which patients had more than one admission and how many days elapsed between their first and last admission?

**Finding:** 48 patients with recurrent admissions identified. The time span between first and last admission varies significantly — a key variable for chronic disease management models.

**AI relevance:** Recurrent patients over extended periods are the central profile of chronic disease management AI models. Identifying them and measuring their trajectory is the first step before training any readmission prediction model.

---

### Q5 — Mortality by Admission Source
> What is the distribution of admissions by source location and what is the mortality rate for each?

**Finding:** The highest mortality profile corresponds to emergency admissions (EW EMER.) with unknown source ("Information Not Available"). Missing values in this field are not just noise — they carry clinical meaning and could introduce systematic bias in predictive models.

**AI relevance:** Data quality is one of the most critical challenges in healthcare AI. Missing data must be handled carefully to avoid underestimating real patient risk in predictive models.

---

### Q6 — Mortality by Gender and Admission Type (JOIN)
> What is the hospital mortality rate by gender and admission type?

**Finding:** Male patients with URGENT admissions show the highest mortality rate. Emergency-type admissions systematically concentrate higher mortality regardless of gender, although male patients show higher rates across most admission types.

**AI relevance:** Detecting systematic differences by gender is fundamental for identifying potential biases in predictive models — a model trained without considering this variable could underestimate risk in certain groups.

---

### Q7 — Average Age by Admission Type and Mortality (JOIN)
> What is the average patient age per admission type and its associated mortality?

**Finding:** Age does not show a clear correlation with mortality — admission type is the dominant factor. This suggests that in a predictive model, admission type should carry more weight than age as a predictor variable.

**AI relevance:** Using age as a risk proxy without considering clinical context could generate biased predictions. Exploratory analysis like this is essential before defining features for an AI model.

---

### Q8 — High-Risk Patient Identification (CTE)
> Which patients have more than 2 admissions AND at least one recorded in-hospital death?

**Finding:** Only 4 patients meet both criteria simultaneously. No clear pattern is observed by age or gender — suggesting that high-risk chronic profiles are determined by clinical complexity rather than demographic factors.

**AI relevance:** Multi-criteria risk stratification is the most direct healthcare AI use case. The CTE structure allows risk criteria to be defined modularly and adjusted dynamically based on clinical context.

---

### Q9 — Patients with Above-Average Length of Stay (Subquery)
> Which patients have a length of stay above the overall average?

**Finding:** 99 admissions exceed the average length of stay — approximately one third of the total. No clear pattern by gender or age, suggesting prolonged stays are driven by clinical factors such as diagnosis or admission type rather than demographics.

**AI relevance:** Length-of-stay prediction models enable hospitals to anticipate bed needs and plan discharges proactively. The scalar subquery dynamically recalculates the threshold from real data, making the analysis robust to dataset changes.

---

## 💡 Key Insights

- **Data quality is clinical signal:** missing or unknown values in MIMIC are not noise — they carry clinical meaning and must be handled carefully in AI model design
- **Volume ≠ risk:** the admission type with the most admissions does not have the highest mortality rate — a critical distinction for resource allocation models
- **Socioeconomic proxies matter:** insurance type correlates with mortality outcomes, raising important equity considerations for AI models
- **Age is not always a strong predictor:** admission type consistently outperforms age as a mortality predictor — a key feature engineering insight
- **TIMESTAMP_DIFF** enables temporal clinical analysis essential for real-world healthcare AI feature engineering

---

## 🚀 Context & Next Steps

This project is part of a self-directed learning path combining a scientific background (Chemistry), healthcare business expertise (MBA in Medical Technologies), AI & Innovation training, and hands-on technical development in SQL, Python, and process automation.

Clinical data is at the core of this learning path. Healthcare generates some of the most complex, sensitive, and high-stakes data in any industry — understanding how to query, interpret, and extract value from it is a foundational skill for anyone working at the intersection of AI and health. Projects like this one bridge the gap between technical SQL skills and real clinical decision-making context.

**Previous project:** [Healthcare SQL Analysis](https://github.com/DaniHernanz/healthcare-sql-analysis) — synthetic clinical dataset
**Next:** Python-based analysis and machine learning applied to clinical data

---

## 🛠️ How to Run

1. Create a free account at [PhysioNet](https://physionet.org) and complete the CITI credentialing course
2. Request access to MIMIC-IV Demo via Google BigQuery
3. In [Google BigQuery](https://console.cloud.google.com/bigquery), star the project `physionet-data`
4. Navigate to `physionet-data.mimic_demo_core`
5. Copy any query from `mimic_iv_clinical_analysis.sql` into the BigQuery editor and run

---

*Built with Google BigQuery · MIMIC-IV Demo · Oriented toward Healthcare AI*
