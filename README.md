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
- Load ECG signals from the MIT-BIH and PTB databases (pre-filtered in the stored structure).
- Apply preprocessing filters to remove noise and baseline wander.
- Extract relevant features using DWT, Autocorrelation + DCT, and Pan-Tompkins algorithms.
- Train classification models using K-Nearest Neighbors (KNN).
- Generate visualizations and performance metrics.

## 📊 Results
- Extracted features and classification results are stored in the `outputs` folder.
- Performance metrics include accuracy, precision, recall, and F1-score.
- Example output graphs can be found in the `outputs/` directory.

## 🏆 Key Features
- **Preprocessing:** FIR high pass filter, Gaussian Notch filter, Baseline Wander Removal filter, and Band pass filter.
- **Feature Extraction:** Pan-Tompkins QRS detection, Discrete Wavelet Transform (DWT), and Autocorrelation + DCT.
- **Machine Learning:** K-Nearest Neighbors (KNN) classifier.

## 📜 References
- MIT-BIH Arrhythmia Database: https://www.physionet.org/content/mitdb/
- PTB Diagnostic ECG Database: https://www.physionet.org/content/ptbdb/
- Pilia, N., Nagel, C., Lenis, G., Becker, S., Dössel, O., Loewe, A. (2021). ECGdeli - An Open Source ECG Delineation Toolbox for   MATLAB.  SoftwareX 13:100639.  https://doi.org/10.1016/j.softx.2020.100639  
- Pan, J., & Tompkins, W. J. (1985). A real-time QRS detection algorithm. IEEE Transactions on Biomedical Engineering, (3), 230-236.
- Mallat, S. (1999). A Wavelet Tour of Signal Processing. Academic Press.

## 📩 Contact
For any questions or contributions, feel free to reach out!

Author: Andrea Pradas Agujetas  
Institution: CEU San Pablo  
Email: apradasagujetas@gmail.com


## 📩 Contact
For any questions or contributions, feel free to reach out!

🔹 Author: Andrea Pradas Agujetas
🔹 Institution: CEU San Pablo
🔹 Email: apradasagujetas@gmail.com