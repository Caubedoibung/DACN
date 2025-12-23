import os
from fastapi import FastAPI, HTTPException, Request, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
import uvicorn
import google.generativeai as genai
from PIL import Image
import io
import json

# Import ChatbotAssistant từ assistant.py
from assistant import ChatbotAssistant 

load_dotenv() # Tải các biến môi trường từ tệp .env

app = FastAPI()

ALLOWED_ORIGINS = [
    "http://localhost:5500",  # Dev server
    "http://127.0.0.1:5500",  # Dev server alternative
    "http://localhost:8081",  # Production server
    "http://127.0.0.1:8081",  # Production server alternative
    "http://127.0.0.1:127",   # Add this for the client origin
    "*"  # Tạm thời cho phép tất cả origin trong quá trình phát triển
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Lấy API Key từ biến môi trường
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY chưa được thiết lập trong file .env hoặc tệp .env không tồn tại/không đọc được")

# Khởi tạo ChatbotAssistant (lazy-load mode)
try:
    chatbot_assistant = ChatbotAssistant(api_key=GEMINI_API_KEY)
    print("✅ ChatbotAssistant ready (models will be loaded on first request)\n")
except Exception as e:
    print(f"⚠️  Warning: ChatbotAssistant initialization issue: {e}")
    print("Server will start anyway. API calls may fail if network/quota issues persist.\n")
    chatbot_assistant = None  # Allow server to start

# Model Pydantic để validate dữ liệu đầu vào cho API
class ChatRequest(BaseModel):
    question: str
    history: list[dict[str, str]] = []

    class Config:
        schema_extra = {
            "example": {
                "question": "Cho tôi biết về rùa biển",
                "history": [
                    {"role": "user", "content": "Xin chào"},
                    {"role": "assistant", "content": "Chào bạn! Tôi có thể giúp gì cho bạn?"}
                ]
            }
        }

@app.post("/chat")
async def chat_endpoint(chat_request: ChatRequest):
    try:
        # Validate input
        if not chat_request.question.strip():
            raise HTTPException(
                status_code=400,
                detail="Câu hỏi không được để trống"
            )
            
        answer = await chatbot_assistant.get_response(chat_request.question, chat_request.history)
        return {"answer": answer}
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        print(f"Lỗi trong chat_endpoint khi gọi assistant.get_response: {e}")
        raise HTTPException(
            status_code=500, 
            detail="Xin lỗi, có lỗi xảy ra khi xử lý yêu cầu của bạn. Vui lòng thử lại sau."
        )

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.post("/analyze-image")
async def analyze_image_endpoint(file: UploadFile = File(...)):
    """
    Phân tích hình ảnh thức ăn/đồ uống bằng Gemini Vision AI
    
    Accepts: multipart/form-data với field "image"
    Returns: JSON với danh sách món ăn/đồ uống và nutrients
    """
    try:
        if not chatbot_assistant:
            raise HTTPException(
                status_code=503,
                detail="ChatbotAssistant chưa sẵn sàng"
            )
        
        # Đọc file ảnh
        image_bytes = await file.read()
        
        if len(image_bytes) == 0:
            raise HTTPException(status_code=400, detail="File ảnh rỗng")
        
        # Phân tích ảnh
        result = await chatbot_assistant.analyze_food_image(image_bytes)
        
        return result
        
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        print(f"[analyze_image_endpoint] Error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Lỗi khi phân tích ảnh: {str(e)}"
        )

@app.post("/analyze-nutrition")
async def analyze_nutrition(request: Request):
    """
    Analyze food nutrition from image using Gemini Vision
    Accepts both multipart file upload and base64 encoded image
    Returns detailed nutrition breakdown or error if not food
    """
    try:
        # Check if request is JSON (base64) or multipart
        content_type = request.headers.get('content-type', '')
        
        if 'application/json' in content_type:
            # Handle base64 image from JSON
            body = await request.json()
            # Developer simulation: if caller supplies a simulated_result, return it directly
            if isinstance(body, dict) and body.get('simulate') and body.get('simulated_result'):
                return body.get('simulated_result')
            base64_image = body.get('image')
            if not base64_image:
                raise HTTPException(status_code=400, detail="No image data provided")
            
            # Decode base64
            import base64
            image_data = base64.b64decode(base64_image)
            image = Image.open(io.BytesIO(image_data))
        else:
            # Handle multipart file upload
            form = await request.form()
            file = form.get('file')
            if not file:
                raise HTTPException(status_code=400, detail="No file uploaded")
            
            image_data = await file.read()
            image = Image.open(io.BytesIO(image_data))
        
        # Configure Gemini for vision
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel('gemini-2.0-flash')
        
        # Define the nutrient list for analysis
        nutrients_prompt = """
Phân tích dinh dưỡng của món ăn trong ảnh này. Trả về JSON với format:
{
  "is_food": true/false,
  "food_name": "tên món ăn (tiếng Việt)",
  "confidence": 0.0-1.0,
  "nutrients": [
    {"nutrient_code": "VITC", "nutrient_name": "Vitamin C", "amount": 50.5, "unit": "mg"},
    {"nutrient_code": "MIN_CA", "nutrient_name": "Calcium", "amount": 200.0, "unit": "mg"},
    ...
  ]
}

CHỈ phân tích các VITAMIN, MINERAL, MACRONUTRIENTS, FIBER, FATTY ACIDS và AMINO ACID sau (dùng ĐÚNG nutrient_code):

VITAMINS:
- VITB1: Vitamin B1 (Thiamine) - mg
- VITD: Vitamin D - IU
- VITC: Vitamin C - mg
- VITB2: Vitamin B2 (Riboflavin) - mg
- VITK: Vitamin K - µg
- VITE: Vitamin E - mg
- VITB9: Vitamin B9 (Folate) - µg
- VITA: Vitamin A - µg
- VITB6: Vitamin B6 (Pyridoxine) - mg
- VITB12: Vitamin B12 (Cobalamin) - µg
- VITB7: Vitamin B7 (Biotin) - µg
- VITB5: Vitamin B5 (Pantothenic acid) - mg
- VITB3: Vitamin B3 (Niacin) - mg

MINERALS:
- MIN_FE: Iron (Fe) - mg
- MIN_I: Iodine (I) - µg
- MIN_K: Potassium (K) - mg
- MIN_CR: Chromium (Cr) - µg
- MIN_NA: Sodium (Na) - mg
- MIN_MN: Manganese (Mn) - mg
- MIN_ZN: Zinc (Zn) - mg
- MIN_MO: Molybdenum (Mo) - µg
- MIN_P: Phosphorus (P) - mg
- MIN_SE: Selenium (Se) - µg
- MIN_CA: Calcium (Ca) - mg
- MIN_CU: Copper (Cu) - mg
- MIN_MG: Magnesium (Mg) - mg
- MIN_F: Fluoride (F) - mg

MACRONUTRIENTS & FIBER (luôn luôn trả về nếu có dữ liệu):
- ENERC_KCAL: Calories - kcal
- PROCNT: Protein - g
- CHOCDF: Total Carbohydrate - g
- FAT: Total Fat - g
- FIBTG: Total Fiber - g

FATTY ACIDS (chỉ thêm khi nhìn thấy món ăn giàu chất béo):
- TOTAL_FAT: Tổng chất béo - g
- MUFA: Monounsaturated Fatty Acids - g
- PUFA: Polyunsaturated Fatty Acids - g
- LA: Linoleic Acid (Omega-6) - g
- ALA: Alpha-linolenic Acid (Omega-3) - g
- EPA_DHA: EPA + DHA (Omega-3) - g

AMINO ACIDS (8 axit amin thiết yếu, đơn vị mg – dùng khi món ăn giàu protein):
- HIS, ILE, LEU, LYS, MET, PHE, THR, TRP, VAL

Quy tắc:
- Nếu KHÔNG phải món ăn: {"is_food": false, "food_name": null, "confidence": 0, "nutrients": []}
- Nếu là món ăn: ước lượng khẩu phần chuẩn (100-300g) và tính toán dinh dưỡng
- CHỈ bao gồm nutrients CÓ GIÁ TRỊ đáng kể (>0)
- Dùng ĐÚNG nutrient_code từ danh sách trên
- Trả về JSON hợp lệ, KHÔNG markdown
"""
        
        response = model.generate_content([nutrients_prompt, image])
        
        # Parse JSON response
        response_text = response.text.strip()
        
        # Remove markdown code blocks if present
        if response_text.startswith('```'):
            lines = response_text.split('\n')
            response_text = '\n'.join(lines[1:-1]) if len(lines) > 2 else response_text
            if response_text.startswith('json'):
                response_text = response_text[4:].strip()
        
        result = json.loads(response_text)
        
        # Validate response structure
        if 'is_food' not in result:
            raise ValueError("Invalid response structure")
        
        return result
        
    except json.JSONDecodeError as je:
        print(f"JSON decode error: {je}, Response: {response_text[:500]}")
        return {
            "is_food": False,
            "food_name": None,
            "confidence": 0,
            "nutrients": [],
            "error": "Failed to parse nutrition data"
        }
    except Exception as e:
        print(f"Error analyzing nutrition: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Lỗi khi phân tích ảnh: {str(e)}"
        )

if __name__ == "__main__":
    print("Khởi động server với uvicorn...")
    uvicorn.run(app, host="0.0.0.0", port=8000) 