SELECT
  core_glucose.patientunitstayid
  , core_glucose.labresultoffset
  , core_glucose.labresult
  , core_glucose.labresulttext
  , poc_glucose.labresultoffset
  , poc_glucose.labresult
  , poc_glucose.labresulttext
FROM `physionet-data.eicu_crd.lab` core_glucose
INNER JOIN `physionet-data.eicu_crd.lab` poc_glucose ON
  poc_glucose.patientunitstayid = core_glucose.patientunitstayid AND
  poc_glucose.labname = 'bedside glucose' AND
  ABS(poc_glucose.labresultoffset - core_glucose.labresultoffset) < 60
WHERE
  core_glucose.labname = 'glucose'