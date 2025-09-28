# Data (public)

- All CSVs in `data/processed/` are **anonymized** (no ground-truth labels, no free text).
- Columns like `filename`, `path`, `Diagnosis*`, `Reasoning*`, `Answer`, `Correct_Answer`, `Prediction`, etc. are removed upstream.
- `case_uid` and `Case_ID` are salted hashes; original IDs are never published.

Files included:
- `diagnoses_anonymized.csv` — normalized table for analysis scripts (hashed Case_ID + model columns).
- `ai_web_interface_results_anon.csv` — hashed per-case results from web interface.
- `api_reasoning_summary_anon.csv` — hashed API summary (no text).
- `api_reasoning_latency_anon.csv` — hashed API latency (no text).
- `gpt5_api_final_anon.csv` — hashed API export shell (no text).

> If you run anonymization yourself, put your raw files in `data/raw/` and run `scripts/anonymize_csvs.R`.
