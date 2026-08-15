library(shiny)
library(keras)
library(tensorflow)
library(jpeg)
library(png)
library(jsonlite)

# ---- Deployment / startup checks ----
required_packages <- c("shiny", "keras", "tensorflow", "jpeg", "png", "jsonlite")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "Missing required R packages: ",
      paste(missing_packages, collapse = ", "),
      ". Install them before starting the application."
    )
  )
}

model_general_path <- file.path("models", "keras_model.h5")
model_specific_path <- file.path("models", "keras_model_2.h5")

if (!file.exists(model_general_path) || !file.exists(model_specific_path)) {
  stop(
    "Model files were not found. Expected: models/keras_model.h5 and models/keras_model_2.h5"
  )
}

# --------------- بارگذاری هر دو مدل هوش مصنوعی ---------------
model_general <- load_model_hdf5(file.path("models", "keras_model.h5"))
model_specific <- load_model_hdf5(file.path("models", "keras_model_2.h5"))

# برچسب‌ها
labels_general <- c("Historical", "Natural")

labels_specific <- c(
  "Alamut_Castle",           # 0
  "Ali_Qapu_Gate",           # 1
  "Aminiha_Hosseiniyeh",     # 2
  "Andej_Village",           # 3
  "Barajin_Forest_Park",     # 4
  "Chehel_Sotoun",           # 5
  "Haj_Kazem_Ab_Anbar",      # 6
  "Hamdallah_Mustawfi_Tomb", # 7
  "Il_Chupan_Waterfall",     # 8
  "Jameh_Mosque",            # 9
  "Kantor_Church",           # 10
  "Niaq_Stone_Eyvan",        # 11
  "Nineh_Rud_Valley",        # 12
  "Ovan_Lake",               # 13
  "Qajar_Bathhouse",         # 14
  "Saad_al_Saltaneh",        # 15
  "Safavid_Garden",          # 16
  "Yeleh_Gonbad_Hot_Spring"  # 17
)

# تابع پیش‌پردازش تصویر (دقیقاً مشابه Teachable Machine)
preprocess_tm_image <- function(image_path) {
  img <- image_load(image_path, target_size = c(224, 224))
  img_array <- image_to_array(img)
  img_array <- array_reshape(img_array, c(1, 224, 224, 3))
  img_array <- (img_array / 127.5) - 1
  return(img_array)
}

# --------------- رابط کاربری (UI) ---------------
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      @import url('https://cdn.jsdelivr.net/gh/rastikerdar/vazirmatn@v3.3.0/Vazirmatn-font-face.css');
      
      /* تنظیمات کلی برای جلوگیری از اسکرول افقی و خالی شدن صفحه */
      html, body {
        overflow-x: hidden !important;
        width: 100% !important;
        max-width: 100% !important;
        margin: 0 !important;
        padding: 0 !important;
        background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
        background-attachment: fixed;
        font-family: 'Vazirmatn', Tahoma, sans-serif;
        min-height: 100vh;
      }
      
      /* این کانتینر اصلی استایل شیشه‌ای و راست‌چین را نگه می‌دارد بدون اینکه صفحه را خراب کند */
      .container-fluid {
        direction: rtl !important;
        text-align: right !important;
        padding-left: 15px !important;
        padding-right: 15px !important;
        max-width: 100% !important;
        width: 100% !important;
        margin: 0 auto !important;
        box-sizing: border-box;
      }
      
      /* اصلاح ساختار گرید با Flexbox برای جلوگیری از به‌هم ریختن */
      .row {
        display: flex !important;
        flex-wrap: wrap !important;
        margin-left: 0 !important;
        margin-right: 0 !important;
        width: 100% !important;
      }
      .col-sm-5, .col-sm-7 {
        max-width: 100% !important;
        padding-left: 10px !important;
        padding-right: 10px !important;
        box-sizing: border-box !important;
      }
      
      /* استایل هدر شیشه‌ای */
      .navbar-custom {
        background: rgba(255, 255, 255, 0.08);
        backdrop-filter: blur(12px);
        border-bottom: 1px solid rgba(255,255,255,0.1);
        color: white;
        padding: 20px 0;
        text-align: center;
        border-radius: 0 0 20px 20px;
        box-shadow: 0 4px 25px rgba(0,0,0,0.3);
        margin-bottom: 30px;
        width: 100%;
        display: block;
      }
      
      .navbar-custom h2 { text-shadow: 0 2px 5px rgba(0,0,0,0.3); letter-spacing: 1px; margin: 0;}
      .navbar-custom p { opacity: 0.8; margin-top: 10px; }
      
      /* کارت‌های شیشه‌ای */
      .glass-card {
        background: rgba(255, 255, 255, 0.08);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border-radius: 20px;
        padding: 30px;
        border: 1px solid rgba(255, 255, 255, 0.15);
        box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.3);
        min-height: 450px;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        display: flex;
        flex-direction: column;
        color: white;
        width: 100%;
        box-sizing: border-box;
      }
      
      .glass-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 12px 40px 0 rgba(31, 38, 135, 0.5);
      }
      
      /* استایل آپلود */
      .upload-container {
        border: 2px dashed rgba(255,255,255,0.3);
        border-radius: 12px;
        padding: 30px 10px;
        text-align: center;
        background: rgba(255,255,255,0.05);
        transition: all 0.3s;
      }
      .upload-container:hover {
        border-color: #ffffff;
        background: rgba(255,255,255,0.15);
      }
      
      .btn-file {
        background: rgba(255,255,255,0.2) !important;
        border: 1px solid rgba(255,255,255,0.3) !important;
        color: white !important;
      }
      .btn-file:hover {
        background: rgba(255,255,255,0.3) !important;
      }
      
      /* لودینگ */
      .loader {
        border: 4px solid rgba(255,255,255,0.2);
        border-top: 4px solid #ffffff;
        border-radius: 50%;
        width: 60px;
        height: 60px;
        animation: spin 1s linear infinite;
        margin: 40px auto 20px auto;
      }
      @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
      
      /* باکس‌های نتیجه */
      .result-box {
        margin-top: 15px;
        padding: 20px;
        border-radius: 15px;
        text-align: center;
        animation: slideUp 0.5s ease-out;
        border: 1px solid;
        width: 100%;
        box-sizing: border-box;
      }
      @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
      
      .res-historical { background: rgba(243, 156, 18, 0.15); border-color: #f39c12; color: #f1c40f; }
      .res-natural { background: rgba(46, 204, 113, 0.15); border-color: #2ecc71; color: #2ecc71; }
      .res-place { background: rgba(52, 152, 219, 0.15); border-color: #3498db; color: #5dade2; }
      
      .conf-bar-bg { width: 100%; background: rgba(255,255,255,0.2); border-radius: 8px; margin-top: 10px; height: 10px; overflow: hidden; }
      .conf-bar-fill { height: 10px; border-radius: 8px; transition: width 1.5s cubic-bezier(0.22, 1, 0.36, 1); }
      
      .final-img {
        max-width: 100%;
        max-height: 300px;
        width: auto;
        height: auto;
        border-radius: 15px;
        box-shadow: 0 8px 20px rgba(0,0,0,0.4);
        object-fit: cover;
        display: block;
        margin: 0 auto 20px auto;
        border: 1px solid rgba(255,255,255,0.1);
      }
      
      .result-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        width: 100%;
      }
      @media (max-width: 768px) {
        .result-grid { grid-template-columns: 1fr; }
      }
    "))
  ),
  
  # هدر
  div(class = "navbar-custom",
      h2(style="font-weight: bold; font-size: 28px;", "سیستم پردازش بینایی ماشین"),
      p(style="font-size: 16px;", "تشخیص خودکار اماکن تاریخی / طبیعی و تعیین مکان دقیق")
  ),
  
  # محتوای اصلی
  div(class = "container-fluid",
      fluidRow(
        # ستون سمت راست : آپلود
        column(width = 5,
               div(class = "glass-card",
                   h3("بارگذاری تصویر", style="margin-bottom: 20px; font-weight: bold;"),
                   div(class = "upload-container",
                       icon("cloud-upload-alt", class="fa-3x", style="color: rgba(255,255,255,0.5); margin-bottom:15px;"),
                       fileInput("image_upload", "", 
                                 accept = c("image/jpeg", "image/png"), 
                                 buttonLabel = "انتخاب عکس...", 
                                 placeholder = "هیچ عکسی انتخاب نشده")
                   ),
                   hr(style="border-color: rgba(255,255,255,0.1); margin-top: 30px;"),
                   p("💡 راهنمای سیستم:", style="font-weight: bold; opacity: 0.9;"),
                   p(style="opacity: 0.7; font-size: 14px;", 
                     "عکس خود را انتخاب کنید. سیستم با دو مدل مجزا، ابتدا نوع مکان (تاریخی یا طبیعی) و سپس مکان دقیق را پیش‌بینی می‌کند.")
               )
        ),
        
        # ستون سمت چپ : خروجی
        column(width = 7,
               div(class = "glass-card", style="justify-content: center;",
                   uiOutput("main_display")
               )
        )
      )
  )
)

# --------------- منطق سرور (Server) ---------------
server <- function(input, output, session) {
  
  app_state <- reactiveVal("waiting")
  prediction_data <- reactiveVal(NULL)
  
  # تست اولیه مدل‌ها
  observe({
    tryCatch({
      # Only verify that the model objects can be accessed at startup.
      # Actual inference is performed after an image is uploaded.
      print("✅ مدل‌های هوش مصنوعی با موفقیت بارگذاری شدند.")
    }, error = function(e) {
      print(paste("❌ خطا در آماده‌سازی مدل‌ها:", e$message))
    })
  })
  
  observeEvent(input$image_upload, {
    req(input$image_upload)
    app_state("processing")
    img_path <- input$image_upload$datapath
    
    tryCatch({
      input_data <- preprocess_tm_image(img_path)
      
      # پیش‌بینی با مدل اول (عمومی)
      pred_general <- model_general %>% predict(input_data)
      idx_general <- which.max(pred_general)
      label_general <- labels_general[idx_general]
      conf_general <- as.numeric(pred_general[1, idx_general]) * 100
      
      # پیش‌بینی با مدل دوم (مکان)
      pred_specific <- model_specific %>% predict(input_data)
      idx_specific <- which.max(pred_specific)
      label_specific <- labels_specific[idx_specific]
      conf_specific <- as.numeric(pred_specific[1, idx_specific]) * 100
      
      # کدگذاری تصویر برای نمایش
      raw_img <- readBin(img_path, "raw", file.info(img_path)$size)
      ext <- tools::file_ext(img_path)
      mime <- ifelse(tolower(ext) == "png", "image/png", "image/jpeg")
      b64_img <- paste0("data:", mime, ";base64,", jsonlite::base64_enc(raw_img))
      
      prediction_data(list(
        img_b64 = b64_img,
        general_label = label_general,
        general_conf = conf_general,
        specific_label = label_specific,
        specific_conf = conf_specific
      ))
      app_state("done")
      
    }, error = function(e) {
      print(paste("❌ خطا:", e$message))
      prediction_data(e$message)
      app_state("error")
    })
  })
  
  output$main_display <- renderUI({
    state <- app_state()
    
    if (state == "waiting") {
      return(div(style="text-align: center; opacity: 0.7;",
                 icon("image", class="fa-5x", style="color: rgba(255,255,255,0.4);"),
                 h4(style="margin-top: 20px;", "منتظر دریافت تصویر...")
      ))
    }
    
    if (state == "processing") {
      return(div(
        div(class = "loader"),
        h4("در حال استخراج ویژگی‌ها و تحلیل توسط شبکه عصبی...", style="text-align: center;")
      ))
    }
    
    if (state == "error") {
      return(div(style="background: rgba(220, 53, 69, 0.2); border: 1px solid #dc3545; color: #ffb4b4; padding: 20px; border-radius: 10px;",
                 h4("خطا در پردازش!"),
                 p(prediction_data())
      ))
    }
    
    if (state == "done") {
      res <- prediction_data()
      
      # استایل باکس عمومی
      if (res$general_label == "Historical") {
        box_class_g <- "res-historical"
        title_g <- "🏛️ مکان تاریخی (Historical)"
        bar_color_g <- "#f39c12"
      } else {
        box_class_g <- "res-natural"
        title_g <- "🌿 مکان طبیعی (Natural)"
        bar_color_g <- "#2ecc71"
      }
      
      # باکس مکان دقیق
      box_class_s <- "res-place"
      title_s <- paste0("📍 ", res$specific_label)
      bar_color_s <- "#3498db"
      
      # نمایش هر دو نتیجه به صورت دو ستونی (در موبایل یک ستون)
      div(style="text-align: center; max-width: 100%;",
          tags$img(src = res$img_b64, class = "final-img"),
          
          div(class = "result-grid",
              # نتیجه مدل اول
              div(class = paste("result-box", box_class_g),
                  h3(style="margin-top: 0; font-weight: bold; font-size: 20px;", title_g),
                  h4(style="opacity: 0.9; margin-top: 5px;", sprintf("اطمینان: %.1f%%", res$general_conf)),
                  div(class = "conf-bar-bg",
                      div(class = "conf-bar-fill", style = sprintf("width: %s%%; background-color: %s;", res$general_conf, bar_color_g))
                  )
              ),
              # نتیجه مدل دوم
              div(class = paste("result-box", box_class_s),
                  h3(style="margin-top: 0; font-weight: bold; font-size: 20px;", title_s),
                  h4(style="opacity: 0.9; margin-top: 5px;", sprintf("اطمینان: %.1f%%", res$specific_conf)),
                  div(class = "conf-bar-bg",
                      div(class = "conf-bar-fill", style = sprintf("width: %s%%; background-color: %s;", res$specific_conf, bar_color_s))
                  )
              )
          )
      )
    }
  })
}

shinyApp(ui = ui, server = server)