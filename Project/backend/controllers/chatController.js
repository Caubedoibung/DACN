const db = require('../db');
const axios = require('axios');
const FormData = require('form-data');
const manualNutritionService = require('../services/manualNutritionService');
const { toVietnamDate } = require('../utils/dateHelper');

// Chatbot API base URL
const CHATBOT_API_URL = process.env.CHATBOT_API_URL || 'http://localhost:8000';

/**
 * Get or create chatbot conversation for user
 */
exports.getOrCreateConversation = async (req, res) => {
  try {
    if (!req.user || !req.user.user_id) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    const userId = req.user.user_id;

    // Try to get most recent conversation
    let result = await db.query(
      `SELECT conversation_id, title, created_at, updated_at 
       FROM ChatbotConversation 
       WHERE user_id = $1 
       ORDER BY updated_at DESC 
       LIMIT 1`,
      [userId]
    );

    if (result.rows.length === 0) {
      // Create new conversation
      result = await db.query(
        `INSERT INTO ChatbotConversation (user_id, title) 
         VALUES ($1, 'New conversation') 
         RETURNING conversation_id, title, created_at, updated_at`,
        [userId]
      );
    }

    res.json({ conversation: result.rows[0] });
  } catch (error) {
    console.error('Error getting/creating conversation:', error);
    res.status(500).json({ error: 'Failed to get conversation' });
  }
};

/**
 * Get messages for a conversation
 */
exports.getMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user.user_id;

    // Verify conversation belongs to user
    const convCheck = await db.query(
      'SELECT 1 FROM ChatbotConversation WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await db.query(
      `SELECT message_id, sender, message_text, image_url, nutrition_data, is_approved, created_at
       FROM ChatbotMessage
       WHERE conversation_id = $1
       ORDER BY created_at ASC`,
      [conversationId]
    );

    res.json({ messages: result.rows });
  } catch (error) {
    console.error('Error getting messages:', error);
    res.status(500).json({ error: 'Failed to get messages' });
  }
};

/**
 * Send text message to chatbot
 */
exports.sendMessage = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { message } = req.body;
    const userId = req.user.user_id;

    // Verify conversation belongs to user
    const convCheck = await db.query(
      'SELECT 1 FROM ChatbotConversation WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Save user message
    const userMsg = await db.query(
      `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
       VALUES ($1, 'user', $2)
       RETURNING message_id, sender, message_text, created_at`,
      [conversationId, message]
    );

    // Get conversation history for context
    const history = await db.query(
      `SELECT sender, message_text 
       FROM ChatbotMessage 
       WHERE conversation_id = $1 
       ORDER BY created_at ASC 
       LIMIT 20`,
      [conversationId]
    );

    // Call chatbot API
    try {
      const chatResponse = await axios.post(`${CHATBOT_API_URL}/chat`, {
        question: message,
        history: history.rows.map(m => ({
          role: m.sender === 'user' ? 'user' : 'assistant',
          content: m.message_text
        }))
      });

      const botReply = chatResponse.data.answer || chatResponse.data.response || 'Xin lỗi, tôi không thể xử lý yêu cầu này.';

      // Save bot response
      const botMsg = await db.query(
        `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
         VALUES ($1, 'bot', $2)
         RETURNING message_id, sender, message_text, created_at`,
        [conversationId, botReply]
      );

      res.json({
        userMessage: userMsg.rows[0],
        botMessage: botMsg.rows[0]
      });
    } catch (chatError) {
      console.error('Chatbot API error:', chatError);
      
      // Fallback response
      const botMsg = await db.query(
        `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
         VALUES ($1, 'bot', $2)
         RETURNING message_id, sender, message_text, created_at`,
        [conversationId, 'I apologize, I am temporarily unavailable. Please try again later.']
      );

      res.json({
        userMessage: userMsg.rows[0],
        botMessage: botMsg.rows[0]
      });
    }
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
};

/**
 * Analyze food image with AI
 */
exports.analyzeFoodImage = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user.user_id;
    const { image } = req.body; // base64 image

    if (!image) {
      return res.status(400).json({ error: 'No image provided' });
    }

    // Verify conversation belongs to user
    const convCheck = await db.query(
      'SELECT 1 FROM ChatbotConversation WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Convert base64 to buffer and save as file
    const fs = require('fs');
    const path = require('path');
    const buffer = Buffer.from(image, 'base64');
    const filename = `food-${Date.now()}.jpg`;
    const filepath = path.join('uploads', 'chat', filename);
    
    // Ensure directory exists
    const dir = path.dirname(filepath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    fs.writeFileSync(filepath, buffer);

    // Save user message with image
    const imageUrl = `/uploads/chat/${filename}`;
    const userMsg = await db.query(
      `INSERT INTO ChatbotMessage (conversation_id, sender, message_text, image_url)
       VALUES ($1, 'user', 'Phân tích dinh dưỡng ảnh này', $2)
       RETURNING message_id, sender, message_text, image_url, created_at`,
      [conversationId, imageUrl]
    );

    // Call AI nutrition analysis
    try {
      const FormData = require('form-data');
      const formData = new FormData();
      formData.append('file', buffer, { filename: 'food.jpg', contentType: 'image/jpeg' });

      const analysisResponse = await axios.post(
        `${CHATBOT_API_URL}/analyze-nutrition`,
        formData,
        {
          headers: formData.getHeaders(),
          timeout: 30000
        }
      );

      const analysis = analysisResponse.data;

      if (!analysis.is_food) {
        // Not food - save bot rejection message
        const botMsg = await db.query(
          `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
           VALUES ($1, 'bot', $2)
           RETURNING message_id, sender, message_text, created_at`,
          [conversationId, 'Xin lỗi, tôi không nhận diện được thực phẩm trong ảnh này. Vui lòng thử lại với ảnh món ăn rõ ràng hơn.']
        );

        return res.json({
          userMessage: userMsg.rows[0],
          botMessage: botMsg.rows[0],
          isFood: false
        });
      }

      // Save nutrition analysis
      const nutritionData = {
        food_name: analysis.food_name,
        confidence: analysis.confidence,
        nutrients: analysis.nutrients
      };

      const botMsg = await db.query(
        `INSERT INTO ChatbotMessage (conversation_id, sender, message_text, nutrition_data)
         VALUES ($1, 'bot', $2, $3)
         RETURNING message_id, sender, message_text, nutrition_data, created_at`,
        [
          conversationId,
          `Tôi đã phân tích món: ${analysis.food_name}. Vui lòng xác nhận kết quả dinh dưỡng bên dưới.`,
          JSON.stringify(nutritionData)
        ]
      );

      res.json({
        userMessage: userMsg.rows[0],
        botMessage: botMsg.rows[0],
        isFood: true,
        nutritionData
      });
    } catch (aiError) {
      console.error('AI analysis error:', aiError);
      
      const botMsg = await db.query(
        `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
         VALUES ($1, 'bot', $2)
         RETURNING message_id, sender, message_text, created_at`,
        [conversationId, 'Xin lỗi, đã có lỗi xảy ra khi phân tích ảnh. Vui lòng thử lại.']
      );

      res.json({
        userMessage: userMsg.rows[0],
        botMessage: botMsg.rows[0],
        isFood: false,
        error: 'Analysis failed'
      });
    }
  } catch (error) {
    console.error('Error analyzing food image:', error);
    res.status(500).json({ error: 'Failed to analyze image' });
  }
};

/**
 * Approve or reject nutrition analysis
 */
exports.approveNutrition = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { approved } = req.body;
    const userId = req.user.user_id;

    // Get message with nutrition data
    const msgResult = await db.query(
      `SELECT cm.*, cc.user_id
       FROM ChatbotMessage cm
       JOIN ChatbotConversation cc ON cc.conversation_id = cm.conversation_id
       WHERE cm.message_id = $1`,
      [messageId]
    );

    if (msgResult.rows.length === 0) {
      return res.status(404).json({ error: 'Message not found' });
    }

    const message = msgResult.rows[0];

    if (message.user_id !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (!message.nutrition_data) {
      return res.status(400).json({ error: 'No nutrition data in this message' });
    }

    // Update approval status
    await db.query(
      'UPDATE ChatbotMessage SET is_approved = $1 WHERE message_id = $2',
      [approved, messageId]
    );

    if (approved) {
      const nutritionData = message.nutrition_data || {};
      const manualResult = await manualNutritionService.saveManualIntake({
        userId,
        nutrients: nutritionData.nutrients || [],
        foodName: nutritionData.food_name,
        source: 'chatbot',
        sourceRef: String(messageId),
        date: message.created_at
          ? toVietnamDate(new Date(message.created_at))
          : undefined
      });

      res.json({
        success: true,
        approved: true,
        today: manualResult.todayTotals
      });
    } else {
      res.json({
        success: true,
        approved: false
      });
    }
  } catch (error) {
    console.error('Error approving nutrition:', error);
    res.status(500).json({ error: 'Failed to approve nutrition data' });
  }
};
