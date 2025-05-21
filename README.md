# Biometric Identification using ECG Signals

## 📖 Project Overview
This repository contains the code and methodologies for biometric identification based on Electrocardiogram (ECG) signals. The project is part of a **Final Year Thesis (TFG)** and aims to explore signal processing, feature extraction, and classification techniques for ECG-based authentication.

## ⚙️ Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/andreapradas/TFG_Biometrics_ECG.git
   cd TFG_Biometrics_ECG
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
Preprocessing: FIR high pass filter, Gaussian Notch filter, Baseline Wander Removal filter and Band pass filter.
Feature Extraction: Pan-Tompkins QRS detection, DWT, and AC+DCT.
Machine Learning: KNN and Random Forest classifiers.
## 📜 References
MIT-BIH Arrhythmia Database: https://www.physionet.org/content/mitdb/





## 📩 Contact
For any questions or contributions, feel free to reach out!

🔹 Author: Andrea Pradas Agujetas
🔹 Institution: CEU San Pablo
🔹 Email: apradasagujetas@gmail.com