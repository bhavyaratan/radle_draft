# Radiology’s Last Exam (RadLE) – Public Repo (Anonymized Results & Analysis)

This repository publishes **anonymized results, figures (you add), and analysis code** for the RadLE v1 study.
All public tables here are de-identified; **no ground-truth diagnoses, free text, image filenames, or spotter names** are present.
This follows the manuscript’s Data Availability policy (dataset withheld to prevent model contamination). fileciteturn0file0turn0file1

## Quickstart

```bash
make r-setup                       # install R deps with renv
make analysis ACCURACY_INPUT=data/processed/diagnoses_anonymized.csv
make figures FIG_INPUT=data/processed/diagnoses_anonymized.csv
make leak-check                    # scan processed CSVs for banned terms
```

## Structure
- `data/raw/` *(gitignored)* – keep any raw exports locally (never push)
- `data/private/` *(gitignored)* – `salt.txt`, `banned_terms.txt` (your banlist), optional `case_key.csv`
- `data/processed/` – **anonymized** CSVs ready for publication
- `scripts/` – R scripts (anonymization, analysis, figures, validation)
- `docs/figures/` – empty folder to place figures you export
- `.github/workflows/r.yml` – CI: package setup + leakage guard

## Privacy defaults
- `scripts/anonymize_csvs.R` drops ID/file/diagnosis/reasoning/free‑text columns and **hashes** `Case_ID` → `case_uid` using a private salt in `data/private/salt.txt` (not committed).
- `scripts/validate_no_leakage.R` greps all **text columns** in `data/processed/*.csv` against `data/private/banned_terms.txt` and fails if any match is found.

## Licenses
- **Code:** MIT (LICENSE-CODE)
- **Anonymized tables & your figures:** CC BY 4.0 (LICENSE-DATA)

*Generated on 2025-09-28.*
