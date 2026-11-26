# Sentinel IR System — ML Incident Classification

This project now includes a working machine-learning incident classifier integrated with the existing Django incident-reporting flow.

## ML model

- TF-IDF text vectorization (unigrams + bigrams)
- Logistic Regression classifier
- Four existing incident categories:
  - `fire`
  - `med`
  - `sec`
  - `accident`

The reporter's selected incident type is **not silently overwritten**. The ML model classifies the description as decision support, and the prediction + confidence are saved in `Incident.operator_notes` and returned by the reporting API.

## 1. Open the correct project folder

PowerShell:

```powershell
cd "C:\path\to\RCI_Sentinel"
```

Check:

```powershell
dir manage.py
```

You should see `manage.py`.

## 2. Configure local environment

Create a local configuration from the example only if you do not already have
one:

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

`.env` is ignored by Git. For local development, set `DEBUG=True` in `.env`;
you can leave `SECRET_KEY` blank because Django generates a temporary key in
debug mode. Preserve any existing `.env` values. For production, use
`DEBUG=False` and set a persistent secret. The setup batch file enables debug
only for its own Django check when no `DEBUG` environment variable is already
set; it does not change `.env`. The chatbot remains disabled until
`GEMINI_API_KEY` is configured.

## 3. Install project dependencies

If you do not already have a project virtual environment, create one:

```powershell
py -m venv .venv
```

Install dependencies into the project environment:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

## 4. Train/retrain the model

From the folder containing `manage.py`:

```powershell
.\.venv\Scripts\python.exe core\ml\train_model.py
```

This creates:

```text
core/ml/incident_classifier.joblib
core/ml/training_metrics.json
```

The supplied dataset contains 120 labeled examples (30 per category). The included training run uses an 80/20 stratified hold-out test split. Its measured accuracy was 83.33% on that small demonstration test set. This is not a claim of production accuracy; replace/expand the dataset with real, reviewed school incident reports for research evaluation.

## 5. Check Django

```powershell
.\.venv\Scripts\python.exe manage.py check
```

Then:

```powershell
.\.venv\Scripts\python.exe manage.py runserver
```

Open:

```text
http://127.0.0.1:8000/
```

## 6. How ML is used when reporting

When a reporter submits an incident:

```text
Description
   ↓
TF-IDF
   ↓
Logistic Regression
   ↓
Predicted category + confidence
   ↓
Incident is saved
   ↓
ML result is stored in operator notes
   ↓
API returns ML result
```

Example stored notes:

```text
Severity: high
ML Classification: Medical (med)
ML Confidence: 91.20%
Reporter Selected Type: med
```

The success screen also shows:

```text
ML: Medical — Confidence 91.20%
```

## 7. Test the classifier without submitting an incident

The project has this endpoint:

```text
POST /api/classify-incident/
```

It accepts JSON:

```json
{
  "description": "A student fainted and is unconscious."
}
```

It returns the predicted category, label, confidence, and ranked alternatives.

## 8. Retraining with your own data

Edit:

```text
core/ml/incident_dataset.csv
```

Keep these columns:

```csv
description,category
```

Allowed category values:

```text
fire
med
sec
accident
```

Then retrain:

```powershell
.\.venv\Scripts\python.exe core\ml\train_model.py
```

Restart Django after retraining.

## Important

The ML model is a decision-support classifier. It should not replace human emergency judgment. The existing reporter-selected category remains the stored incident category so the current system behavior and database remain compatible.
