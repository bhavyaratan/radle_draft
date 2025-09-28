.PHONY: r-setup anonymize analysis figures leak-check

r-setup:
	Rscript scripts/install_packages.R

anonymize:
	Rscript scripts/anonymize_csvs.R --in data/raw --out data/processed

analysis:
	Rscript scripts/accuracy_analysis.R
	Rscript scripts/mixed_effects_logistic_regression.R || true
	Rscript scripts/repeatability_tests.R || true

figures:
	Rscript scripts/make_figures.R

leak-check:
	Rscript scripts/validate_no_leakage.R
