# Biometric Identification using ECG Signals

## 📖 Project Overview
This repository contains the code and methodologies for biometric identification based on Electrocardiogram (ECG) signals. The project is part of a **Final Year Thesis (TFG)** and aims to explore signal processing, feature extraction, and classification techniques for ECG-based authentication.

## ⚙️ Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/Biometrics-by-ECG.git
   cd Biometrics-by-ECG
## 🚀 Usage
Run main.m to execute the entire pipeline:
matlab
Copiar
Editar
run('main.m')
The pipeline follows these steps:
Load ECG signals from the MIT-BIH database.
Apply preprocessing filters to remove noise and baseline wander.
Extract relevant features using DWT, Autocorrelation + DCT, and Pan-Tompkins.
Train classification models using KNN and Random Forest.
Generate visualizations and performance metrics.
## 📊 Results
The extracted features and classification results will be stored in the outputs folder.
Performance metrics include accuracy, precision, recall, and F1-score.
Example output graphs can be found in outputs/.
## 🏆 Key Features
Preprocessing: FIR filters, Gaussian Notch Filter, Baseline Wander Removal.
Feature Extraction: Pan-Tompkins QRS detection, DWT, and AC+DCT.
Machine Learning: KNN and Random Forest classifiers.
## 📜 References
MIT-BIH Arrhythmia Database: https://www.physionet.org/content/mitdb/
Wavelet-based feature extraction for ECG: [Relevant Papers]
Pan-Tompkins Algorithm: [Relevant Papers]
## 📩 Contact
For any questions or contributions, feel free to reach out!

🔹 Author: Your Name
🔹 Institution: Your University
🔹 Email: your.email@example.com