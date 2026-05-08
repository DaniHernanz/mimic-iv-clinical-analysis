-- ============================================================
-- MIMIC-IV Demo: Análisis de datos clínicos reales
-- Herramienta: Google BigQuery
-- ============================================================

-- ------------------------------------------------------------
-- PREGUNTA 1: ¿Cuántos ingresos hay por tipo de admisión
--             y cuál es la mortalidad hospitalaria de cada uno?
-- ------------------------------------------------------------
-- Relevancia: Conocer el volumen y la mortalidad por tipo de
-- admisión es fundamental para priorizar recursos hospitalarios
-- y entrenar modelos de IA de triaje y predicción de riesgo.
-- Hallazgo: EW EMER. concentra el mayor volumen de ingresos,
-- mientras que URGENT presenta la mayor tasa de mortalidad —
-- volumen y mortalidad no van necesariamente de la mano.
-- ------------------------------------------------------------

SELECT
    a.admission_type,
    COUNT(a.hadm_id)              AS number_admissions,
    SUM(a.hospital_expire_flag)   AS number_deaths,
    AVG(a.hospital_expire_flag)   AS mortality_rate
FROM `physionet-data.mimic_demo_core.admissions` a
GROUP BY a.admission_type
ORDER BY COUNT(a.hadm_id) DESC, AVG(a.hospital_expire_flag);


-- ------------------------------------------------------------
-- PREGUNTA 2: ¿Cuál es la estancia media en horas
--             por tipo de admisión?
-- ------------------------------------------------------------
-- Relevancia: La estancia media es un KPI operativo clave en
-- gestión hospitalaria y una variable predictora relevante en
-- modelos de IA de optimización de camas y recursos.
-- Hallazgo: URGENT presenta la mayor estancia media, consistente
-- con su mayor tasa de mortalidad — apunta a pacientes de mayor
-- complejidad clínica, no solo urgencia temporal.
-- ------------------------------------------------------------

SELECT
    a.admission_type,
    AVG(TIMESTAMP_DIFF(a.dischtime, a.admittime, HOUR)) AS average_stay_hours
FROM `physionet-data.mimic_demo_core.admissions` a
GROUP BY a.admission_type
ORDER BY AVG(TIMESTAMP_DIFF(a.dischtime, a.admittime, HOUR)) DESC;


-- ------------------------------------------------------------
-- PREGUNTA 3: ¿Qué porcentaje de pacientes fallecieron
--             durante el ingreso según su tipo de seguro?
-- ------------------------------------------------------------
-- Relevancia: El tipo de seguro médico es un proxy de nivel
-- socioeconómico. Detectar diferencias en mortalidad por seguro
-- es fundamental en modelos de IA de equidad sanitaria para
-- identificar sesgos y diseñar intervenciones más justas.
-- Hallazgo: Medicare concentra el mayor volumen de muertes
-- por volumen de ingresos (mayores de 65 años), pero Medicaid
-- presenta el mayor porcentaje de mortalidad — apunta a peor
-- acceso a atención preventiva en pacientes con menos recursos.
-- ------------------------------------------------------------

SELECT
    a.insurance,
    SUM(a.hospital_expire_flag)                           AS total_deaths,
    AVG(a.hospital_expire_flag) * 100                     AS percentage_death
FROM `physionet-data.mimic_demo_core.admissions` a
GROUP BY a.insurance
ORDER BY AVG(a.hospital_expire_flag) * 100 DESC, SUM(a.hospital_expire_flag) DESC;


-- ------------------------------------------------------------
-- PREGUNTA 4: ¿Cuáles son los pacientes que han
--             tenido más de un ingreso y cuánto tiempo en
--	    días ha pasado entre su primer y último ingreso?
-- ------------------------------------------------------------
-- Relevancia: Los pacientes con múltiples ingresos a lo largo
-- del tiempo son el perfil central de los modelos de gestión
-- de enfermedades crónicas — identificarlos y medir su
-- trayectoria es el primer paso antes de entrenar cualquier
-- modelo predictivo de reingreso.
-- Hallazgo: Se ha visto que hay un total de 48 pacientes con 
-- ingresos recurrentes.
-- ------------------------------------------------------------

SELECT
    a.subject_id,
    TIMESTAMP_DIFF(MAX(a.admittime),MIN(a.admittime),DAY) AS tiempo_entre_ingresos
FROM `physionet-data.mimic_demo_core.admissions` a
GROUP BY a.subject_id
HAVING COUNT(a.admittime) > 1
ORDER BY TIMESTAMP_DIFF(MAX(a.admittime),MIN(a.admittime),DAY) DESC;


-- ------------------------------------------------------------
-- PREGUNTA 5: ¿Cuál es la distribución de ingresos por
--             lugar de procedencia y qué mortalidad tiene cada
--	    uno?
-- ------------------------------------------------------------
-- Relevancia: -- Relevancia: Conocer la procedencia de los pacientes con mayor
-- mortalidad permite a los hospitales priorizar recursos y protocolos
-- de atención. Es también una variable predictora relevante en
-- modelos de IA de triaje y detección temprana de riesgo.
-- Hallazgo: El perfil con mayor mortalidad corresponde a ingresos
-- de emergencia (EW EMER.) con procedencia desconocida — lo que
-- puede indicar pacientes en estado crítico sin tiempo para
-- registrar información administrativa correctamente. La ausencia
-- de datos también es una señal clínica relevante.
-- Hallazgo: -- Hallazgo: El perfil con mayor tasa de mortalidad corresponde
-- a ingresos de emergencia (EW EMER.) con procedencia desconocida
-- ("Information Not Available"). Esto tiene dos lecturas:
-- clínicamente, sugiere pacientes que llegan en estado crítico
-- sin tiempo para registrar información; desde la perspectiva
-- del dato, es una señal de alerta — si este campo se usara
-- como variable en un modelo predictivo, los valores faltantes
-- podrían introducir un sesgo sistemático que infraestimaría
-- el riesgo real de estos pacientes.
-- ------------------------------------------------------------

SELECT
    a.admission_type, a.admission_location,
    SUM(a.hospital_expire_flag) AS total_death,
    AVG(a.hospital_expire_flag)*100 AS mortality_rate
FROM `physionet-data.mimic_demo_core.admissions` a
GROUP BY a.admission_type, a.admission_location
ORDER BY AVG(a.hospital_expire_flag)*100 DESC, SUM(a.hospital_expire_flag) DESC;


-- ------------------------------------------------------------
-- PREGUNTA 7: ¿Cuál es la edad media de los pacientes según
-- el tipo de admisión y su mortalidad?
-- ------------------------------------------------------------
-- Relevancia: La edad es una variable comúnmente usada en modelos
-- de predicción hospitalaria. Sin embargo, incluirla sin saber si es realmente
-- importante puede meter ruido al modelo. Con este análisis podemos ver
-- si la edad tiene un peso real o si está subordinada a otras variables como
-- el tipo de admisión, algo crítico para el diseño de modelos de IA.
-- Hallazgo: Se ha visto que la edad media no está claramente relacionada con
-- la mortalidad y el tipo de admisión sí. Con esto se ve que en el modelo predictivo
-- debe tener más peso el tipo de admisión como variable predictora y que, el 
-- usar la edad como riesgo inherente sin considerar el contexto clínico puede
-- generar predicciones sesgadas.
-- ------------------------------------------------------------

SELECT
    a.admission_type,
    AVG(a.hospital_expire_flag)*100 AS mortality_rate,
    AVG(p.anchor_age) AS average_age
FROM `physionet-data.mimic_demo_core.admissions` a
JOIN `physionet-data.mimic_demo_core.patients` p
ON p.subject_id = a.subject_id
GROUP BY a.admission_type
ORDER BY AVG(a.hospital_expire_flag)*100 DESC;


-- ------------------------------------------------------------
-- PREGUNTA 8: ¿Cuáles son los pacientes de alto riesgo? Define
-- alto riesgo como: más de 2 ingresos y mortalidad registrada en
-- al menos uno de ellos.
-- ------------------------------------------------------------
-- Relevancia: Identificar pacientes de alto riesgo multicritério
-- (múltiples ingresos + mortalidad registrada) es el caso de uso
-- más directo de IA en salud — permite priorizar intervenciones
-- preventivas antes de que el paciente vuelva a urgencias. La CTE
-- permite definir criterios de riesgo de forma modular y escalable,
-- lo que facilita ajustar los umbrales según el contexto clínico.
-- Hallazgo: Solo 4 pacientes cumplen ambos criterios simultáneamente
-- en este dataset. El número de ingresos no muestra correlación clara
-- con la edad o el género — lo que sugiere que el perfil de paciente
-- crónico de alto riesgo no está determinado por factores demográficos
-- sino por la complejidad clínica de su historial.
-- ------------------------------------------------------------

WITH high_risk AS (
SELECT a.subject_id, 
COUNT(a.admittime) AS number_of_admissions,
SUM(a.hospital_expire_flag) AS mortality
FROM `physionet-data.mimic_demo_core.admissions` a
GROUP BY a.subject_id
HAVING COUNT(a.admittime) > 2 AND SUM(a.hospital_expire_flag) >= 1
)
SELECT hr.subject_id, hr.number_of_admissions, hr.mortality, p.gender, p.anchor_age
FROM high_risk hr
JOIN `physionet-data.mimic_demo_core.patients` p
ON p.subject_id = hr.subject_id
ORDER BY hr.number_of_admissions DESC;


-- ------------------------------------------------------------
-- PREGUNTA 9: ¿Qué pacientes tienen una estancia superior
-- a la media general de todos los ingresos?
-- ------------------------------------------------------------
-- Relevancia: Detectar ingresos con estancia superior a la media
-- es un indicador de complejidad clínica y un caso de uso directo
-- de IA en gestión hospitalaria — los modelos de predicción de
-- estancia prolongada permiten anticipar necesidades de camas,
-- recursos y planificación de altas. La subquery es la técnica más 
-- eficiente para este tipo de comparación, ya que el umbral se 
-- recalcula automáticamente con datos reales en lugar de usar un valor fijo.
-- Hallazgo: 99 ingresos superan la estancia media — aproximadamente
-- un tercio del total. No se observa un patrón claro por género o
-- edad, lo que sugiere que la estancia prolongada está determinada
-- por factores clínicos más complejos que los demográficos, como
-- el diagnóstico o el tipo de admisión — variables que deberían
-- incluirse en un modelo predictivo de estancia.
-- ------------------------------------------------------------

SELECT a.subject_id, p.gender, p.anchor_age, TIMESTAMP_DIFF(a.dischtime, a.admittime, DAY) AS estancia
FROM physionet-data.mimic_demo_core.admissions a
JOIN `physionet-data.mimic_demo_core.patients` p
ON p.subject_id = hr.subject_id
WHERE TIMESTAMP_DIFF (a.dischtime, a.admittime, DAY) > (
	SELECT AVG(TIMESTAMP_DIFF(dischtime, admittime, DAY))
	FROM physionet-data.mimic_demo_core.admissions
)
ORDER BY TIMESTAMP_DIFF(a.dischtime, a.admittime, DAY) DESC;
