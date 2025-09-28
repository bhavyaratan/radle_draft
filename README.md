# Radiology’s Last Exam (RadLE)
**Benchmarking Frontier Multimodal AI Against Human Experts in Radiology**

## 📖 Overview
Radiology’s Last Exam (RadLE) is a benchmark designed to rigorously evaluate the diagnostic performance of **generalist multimodal AI systems** against human radiologists. Unlike common public datasets (e.g., CheXpert, MIMIC-CXR) that emphasize frequent pathologies, RadLE focuses on **complex, expert-level “spot diagnosis” cases** encountered in real-world radiology practice.  

This project introduces:  
- A curated dataset of 50 challenging radiological cases across CT, MRI, and X-ray.  
- Systematic evaluation of frontier AI models (GPT-5, Gemini 2.5 Pro, ChatGPT-o3, Grok-4, Claude Opus 4.1).  
- Comparative performance against board-certified radiologists and trainees.  
- A **taxonomy of visual reasoning errors** to characterize AI diagnostic failures.  

> **Key finding:** Board-certified radiologists achieved 83% accuracy, compared to 30% for the best-performing AI (GPT-5). This highlights a significant performance gap and the risks of unsupervised clinical use.

---

## ✨ Features
- **Expert-Level Dataset**: 50 curated cases spanning cardiothoracic, gastrointestinal, genitourinary, musculoskeletal, neuro/head & neck, and pediatric systems.  
- **Benchmarking Protocol**: Evaluations run via web interfaces and API modes for reproducibility.  
- **Error Taxonomy**: Structured framework covering perceptual, interpretive, and communication errors, plus cognitive bias modifiers.  
- **Statistical Analysis**: Accuracy, reproducibility, inter-reader reliability, and latency costs assessed systematically.  
- **Open Science Spirit**: While the dataset is not publicly released to prevent model contamination, external groups may request access for evaluation.

---

## 🚀 Getting Started

### Prerequisites
- R (≥ 4.5.0) with required packages:
  - `lme4` (mixed-effects models)  
  - `irr` (reliability statistics)  
  - `ggplot2` (visualizations)  

### Build Instructions
Clone the repository and open the manuscript draft (`radle.pdf`) for details.  
Evaluation code and statistical analysis scripts are provided in the repository.

```bash
git clone https://github.com/<your-org>/radle.git
cd radle
```

---

## 📊 Results Summary
- **Radiologists**: 83% mean accuracy  
- **Trainees**: 45% mean accuracy  
- **Best AI (GPT-5)**: 30% mean accuracy  
- Minimal gains from “high reasoning effort” modes despite significant latency costs.  
- Error taxonomy shows frequent **under-detection, over-detection, mislocalization, and premature closure** errors in AI reasoning.  

---

## 📑 Citation
If you use RadLE in your work, please cite:

```
@article{datta2025radle,
  title={Radiology’s Last Exam (RadLE): Benchmarking Frontier Multimodal AI Against Human Experts and a Taxonomy of Visual Reasoning Errors in Radiology},
  author={Datta, Suvrankar and Buchireddygari, Divya and Kaza, Lakshmi Vennela Chowdary and ... and Maroo, Bhavya Ratan and Agrawal, Anurag},
  journal={Preprint},
  year={2025}
}
```

---

## 🤝 Contributing
We welcome contributions from radiologists, researchers, and AI developers. You can:  
- Propose new benchmark cases.  
- Suggest refinements to the error taxonomy.  
- Contribute evaluation code or statistical tools.  

Please open a pull request or contact the corresponding authors.

---

## 📬 Contact
For dataset evaluation requests or collaborations:  
- Suvrankar Datta – suvrankar.datta@ashoka.edu.in  
- Divya Buchireddy – divyabuchireddy@gmail.com  
- CRASH Lab – crashlab.kcdha@gmail.com  
