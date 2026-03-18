# 📁  Nutrition System

Status Python FastAPI AI Image Processing REST API

Hệ thống **Chatbot AI phân tích hình ảnh và cung cấp thông tin dinh dưỡng**.
Ứng dụng cho phép người dùng **đặt câu hỏi về thực phẩm hoặc tải lên hình ảnh món ăn** để AI phân tích và trả về thông tin liên quan.

Tính năng • Kiến trúc • Công nghệ • Cài đặt
Python – ngôn ngữ chính

FastAPI – framework backend

REST API – kiến trúc API

Google Generative AI – xử lý chatbot AI

Pillow (PIL) – xử lý hình ảnh

Uvicorn – server chạy FastAPI

Swagger/OpenAPI – tài liệu API tự động

python-dotenv – quản lý biến môi trường
---

# 📋 Giới thiệu

**AI Chatbot Nutrition System** là hệ thống chatbot sử dụng AI giúp người dùng tìm hiểu thông tin về thực phẩm và dinh dưỡng.

Hệ thống được xây dựng nhằm mục đích **học tập và thực hành phát triển Backend API**.

Ứng dụng hỗ trợ:

📂 Gửi câu hỏi về thực phẩm hoặc dinh dưỡng
🤖 Chatbot AI trả lời tự động
📷 Phân tích hình ảnh món ăn
⚡ API REST dễ dàng tích hợp với Frontend
🔐 Quản lý API Key thông qua biến môi trường

---

# ✨ Tính năng chính

| Tính năng              | Mô tả                                      | Trạng thái   |
| ---------------------- | ------------------------------------------ | ------------ |
| 🤖 AI Chatbot          | Trả lời câu hỏi về thực phẩm và dinh dưỡng | ✅ Hoàn thành |
| 📷 Phân tích hình ảnh  | Upload hình ảnh món ăn và AI phân tích     | ✅ Hoàn thành |
| ⚡ REST API             | Xây dựng API bằng FastAPI                  | ✅ Hoàn thành |
| 📄 API Documentation   | Tự động sinh Swagger                       | ✅ Hoàn thành |
| 💬 Lưu lịch sử chat    | Lưu lại lịch sử người dùng                 | ✅ Hoàn thành |
| 🔐 Xác thực người dùng | JWT Authentication                         | ✅ Hoàn thành |
| 📊 Dashboard           | Thống kê dữ liệu người dùng                | ✅ Hoàn thành |

---

# 🏛 Kiến trúc hệ thống

High-Level Architecture

Client (Frontend / Postman)
↓
FastAPI Backend
↓
AI Processing (Google Generative AI)
↓
Image Processing (Pillow)

---

# 🛠 Tech Stack

## Backend

| Technology           | Purpose                     |
| -------------------- | --------------------------- |
| Python               | Ngôn ngữ lập trình          |
| FastAPI              | Framework xây dựng REST API |
| Uvicorn              | ASGI Server                 |
| Google Generative AI | AI chatbot xử lý nội dung   |
| Pillow (PIL)         | Xử lý hình ảnh              |
| Python-dotenv        | Quản lý biến môi trường     |

---

## AI Processing

| Technology           | Purpose                                   |
| -------------------- | ----------------------------------------- |
| Google Generative AI | Phân tích nội dung và trả lời câu hỏi     |
| Prompt Engineering   | Điều chỉnh prompt để AI trả lời chính xác |

---

## Development Tools

| Tool    | Purpose             |
| ------- | ------------------- |
| VS Code | IDE phát triển      |
| Postman | Test API            |
| Git     | Quản lý source code |
| GitHub  | Quản lý project     |

---

# 📂 Cấu trúc dự án

```
DACN-main/
AI-CHATBOT-NUTRITION-SYSTEM/
│
├── app/                            # Main FastAPI Application
│   ├── main.py                     # Entry point (FastAPI app)
│   ├── api/                        # API routes
│   │   ├── routes/                 # Endpoint definitions
│   │   │   ├── chatbot.py          # Chatbot Q&A APIs
│   │   │   └── image.py            # Image upload & analysis APIs
│   │   └── dependencies.py         # Shared dependencies
│   │
│   ├── core/                       # Core configurations
│   │   ├── config.py               # Environment variables
│   │   └── security.py             # Auth / middleware (if any)
│   │
│   ├── models/                     # Data models (Pydantic)
│   │   ├── request.py              # Request schemas
│   │   └── response.py             # Response schemas
│   │
│   ├── services/                   # Business logic layer
│   │   ├── chatbot_service.py      # NLP / AI processing
│   │   ├── image_service.py        # Image processing logic
│   │   └── nutrition_service.py    # Nutrition analysis logic
│   │
│   ├── utils/                      # Helper functions
│   │   ├── image_processing.py     # Preprocessing images
│   │   └── constants.py            # Static values
│   │
│   └── ai/                         # AI models & integrations
│       ├── model_loader.py         # Load ML/DL models
│       └── inference.py            # Prediction logic
│
├── data/                           # Dataset / sample images
│   └── sample_images/
│
├── tests/                          # Unit tests
│   └── test_api.py
│
├── requirements.txt                # Python dependencies
├── Dockerfile                      # Containerization
└── README.md
```

---

# 🚀 Hướng dẫn cài đặt

## Yêu cầu hệ thống

Python 3.10+
pip
Git

---

# 1️⃣ Clone project

```
git clone https://github.com/your-username/ai-chatbot-nutrition.git
cd DACN-main
```

---

# 2️⃣ Tạo môi trường ảo

```
python -m venv venv
```

Kích hoạt môi trường

Windows

```
venv\Scripts\activate
```

Mac / Linux

```
source venv/bin/activate
```

---

# 3️⃣ Cài đặt thư viện

```
pip install -r requirements.txt
```

---

# 4️⃣ Cấu hình API Key

Tạo file `.env`

```
GOOGLE_API_KEY=your_api_key_here
```

---

# ▶️ Chạy ứng dụng

Khởi chạy server FastAPI

```
uvicorn main:app --reload
```

Sau khi chạy thành công:

API Server

```
http://localhost:8000
```

Swagger API Documentation

```
http://localhost:8000/docs
```

---

# 📚 API Documentation

API được document tự động bằng **Swagger**.

Truy cập:

```
http://localhost:8000/docs
```

### Các API chính

| Method | Endpoint       | Description             |
| ------ | -------------- | ----------------------- |
| POST   | /chat          | Gửi câu hỏi tới chatbot |
| POST   | /analyze-image | Upload hình ảnh món ăn  |
| GET    | /              | Kiểm tra server         |

---

# 🔐 Bảo mật

API Key Authentication: sử dụng API key để truy cập AI
Environment Variables: lưu thông tin nhạy cảm trong `.env`
Input Validation: kiểm tra dữ liệu đầu vào

---

# 👨‍💻 Tác giả 

**Trần Khánh Huy**

 Backend Developer

💻 Chuyên ngành: Công nghệ phần mềm

📘 facebbook: https://www.facebook.com/tran.khanh.huy.728622?locale=vi_VN

📧 Email: huymt0401@gmail.com

💼 LinkedIn: https://www.linkedin.com/in/tr%E1%BA%A7n-huy-792316373/

🐙 GitHub: https://github.com/Caubedoibung

---
# 📄 License

Dự án được xây dựng cho mục đích **học tập và nghiên cứu**.

---

⭐ Nếu project hữu ích hãy cho mình một **Star trên GitHub** nhé ⭐

🚧 Dự án vẫn đang trong quá trình phát triển 🚧
