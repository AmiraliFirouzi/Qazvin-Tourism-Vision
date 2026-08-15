# Qazvin Tourism Vision

<p align="center">
  <strong>AI-Powered Tourist Landmark Recognition with MobileNetV1, TensorFlow/Keras and R Shiny</strong>
</p>

<p align="center">
  <a href="YOUR_LIVE_DEMO_URL">🚀 Live Demo</a>
  &nbsp;•&nbsp;
  <a href="#overview">Overview</a>
  &nbsp;•&nbsp;
  <a href="#architecture">Architecture</a>
  &nbsp;•&nbsp;
  <a href="#local-setup">Local Setup</a>
</p>

---

## Overview

**Qazvin Tourism Vision** is an interactive computer vision application built with **R Shiny** for recognizing tourist locations in Qazvin, Iran from uploaded images.

The application uses two trained image-classification models:

1. **General classifier** — predicts whether the image represents a **Historical** or **Natural** location.
2. **Specific classifier** — predicts the specific Qazvin tourist location among **18 classes**.

The final result is presented through a Persian, right-to-left, responsive Shiny dashboard with confidence scores.

> **Note:** This repository contains the trained HDF5 model artifacts supplied with the project. Reported model performance should only be added after evaluation metrics are available.

## Demo

### 🚀 Live Demo

**[Open the live application](YOUR_LIVE_DEMO_URL)**

> Replace `YOUR_LIVE_DEMO_URL` after deployment.

## Key Features

- Image upload using JPEG/PNG
- Two-stage image classification
- Historical vs. Natural classification
- Fine-grained recognition of 18 Qazvin tourist locations
- Confidence score visualization
- Persian RTL user interface
- Responsive dashboard layout
- TensorFlow/Keras inference inside R Shiny

## Recognized Locations

The specific classifier contains these 18 classes:

| # | Location |
|---:|---|
| 0 | Alamut Castle |
| 1 | Ali Qapu Gate |
| 2 | Aminiha Hosseiniyeh |
| 3 | Andej Village |
| 4 | Barajin Forest Park |
| 5 | Chehel Sotoun |
| 6 | Haj Kazem Ab Anbar |
| 7 | Hamdallah Mustawfi Tomb |
| 8 | Il Chupan Waterfall |
| 9 | Jameh Mosque |
| 10 | Kantor Church |
| 11 | Niaq Stone Eyvan |
| 12 | Nineh Rud Valley |
| 13 | Ovan Lake |
| 14 | Qajar Bathhouse |
| 15 | Saad al Saltaneh |
| 16 | Safavid Garden |
| 17 | Yeleh Gonbad Hot Spring |

## Architecture

```text
                Uploaded Image
                      │
                      ▼
             Image Preprocessing
                224 × 224 × 3
                      │
              Normalization [-1, 1]
                      │
                      ▼
              ┌───────────────┐
              │   Model 1     │
              │ General Class │
              └───────┬───────┘
                      │
             Historical / Natural
                      │
                      ▼
              ┌───────────────┐
              │   Model 2     │
              │ Specific Class│
              └───────┬───────┘
                      │
                      ▼
              Qazvin Landmark
                 + Confidence
```

The application preprocesses uploaded images to **224×224 RGB** and applies the same normalization used by the original training workflow: `(pixel / 127.5) - 1`.

## Technology Stack

- **R**
- **Shiny**
- **TensorFlow**
- **Keras**
- **MobileNetV1**
- **Computer Vision**
- **HDF5**
- **HTML/CSS**
- **Responsive UI**

## Project Structure

```text
Qazvin-Tourism-Vision/
│
├── app.R
├── models/
│   ├── keras_model.h5
│   └── keras_model_2.h5
│
├── screenshots/
│   └── .gitkeep
│
├── README.md
├── DESCRIPTION
├── deploy.R
├── .gitignore
└── LICENSE
```

## Local Setup

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/Qazvin-Tourism-Vision.git
cd Qazvin-Tourism-Vision
```

### 2. Install R dependencies

Run in R:

```r
install.packages(c(
  "shiny",
  "keras",
  "tensorflow",
  "jpeg",
  "png",
  "jsonlite"
))
```

Then configure TensorFlow/Keras according to the versions supported by your R environment.

### 3. Run the application

From the project directory:

```r
shiny::runApp()
```

The application should open in your browser.

## Deployment

The application is designed to be deployed as an R Shiny application. A typical deployment workflow is:

```r
# install.packages("rsconnect")
library(rsconnect)

# Configure your account once, then:
rsconnect::deployApp()
```

The deployment environment must provide compatible R, Keras and TensorFlow dependencies. See [`DEPLOYMENT.md`](DEPLOYMENT.md) for the smoke-test and deployment checklist.

## Screenshots

Add screenshots of the final dashboard to the `screenshots/` directory and update this section.

Example:

```text
screenshots/
├── dashboard.png
└── prediction.png
```

Then embed them in this README:

```markdown
![Dashboard](screenshots/dashboard.png)
![Prediction](screenshots/prediction.png)
```

## Project Scope

This project focuses on **image classification and interactive inference**, not object detection or image segmentation. The application expects an uploaded image and returns the highest-probability class from the trained models.

## Reproducibility

The repository includes the trained HDF5 model files used by the Shiny application. Training code, dataset provenance, train/validation/test splits, augmentation settings and quantitative evaluation metrics are not included in this repository unless added separately.

For a research-oriented version, these components should be documented and versioned as part of the training pipeline.

## Author

**Amirali Firouzi**

Computer Vision • Machine Learning • R Shiny

- GitHub: `https://github.com/AmiraliFirouzi`
- LinkedIn: `www.linkedin.com/in/amirali-firouzi-2b714335a`

---

⭐ If you find this project useful, consider giving the repository a star.
