/**
 * dishController.js
 * 
 * Controller for Dish Management System
 * Handles HTTP requests and responses for dish operations
 */

const dishService = require('../services/dishService');
const db = require('../db');

const dishController = {
  /**
   * GET /api/dishes
   * Get all dishes with optional filters
   */
  async getAllDishes(req, res) {
    try {
      const filters = {
        category: req.query.category,
        isTemplate: req.query.isTemplate === 'true' ? true : req.query.isTemplate === 'false' ? false : undefined,
        isPublic: req.query.isPublic === 'true' ? true : req.query.isPublic === 'false' ? false : undefined,
        userId: req.query.userId ? parseInt(req.query.userId) : undefined,
        search: req.query.search,
        limit: req.query.limit ? parseInt(req.query.limit) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset) : undefined
      };

      const dishes = await dishService.getAllDishes(filters);

      res.json({
        success: true,
        data: dishes,
        count: dishes.length
      });
    } catch (error) {
      console.error('Error in getAllDishes controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch dishes',
        error: error.message
      });
    }
  },

  /**
   * GET /api/dishes/:id
   * Get a single dish by ID with full details
   */
  async getDishById(req, res) {
    try {
      const dishId = parseInt(req.params.id);

      if (isNaN(dishId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid dish ID'
        });
      }

      const dish = await dishService.getDishById(dishId);

      if (!dish) {
        return res.status(404).json({
          success: false,
          message: 'Dish not found'
        });
      }

      res.json({
        success: true,
        data: dish
      });
    } catch (error) {
      console.error('Error in getDishById controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch dish',
        error: error.message
      });
    }
  },

  /**
   * POST /api/dishes
   * Create a new dish
   * Body: { name, vietnameseName, description, category, servingSizeG, imageUrl, ingredients }
   */
  async createDish(req, res) {
    try {
      const { name, vietnameseName, description, category, servingSizeG, imageUrl, isTemplate, isPublic, ingredients } = req.body;

      console.log('Creating dish with data:', {
        name,
        category,
        servingSizeG,
        ingredientsCount: ingredients?.length || 0,
        ingredients: ingredients
      });

      // Validation
      if (!name) {
        return res.status(400).json({
          success: false,
          message: 'Dish name is required'
        });
      }

      // Determine creator (user or admin)
      const dishData = {
        name,
        vietnameseName,
        description,
        category,
        servingSizeG,
        imageUrl,
        isTemplate,
        isPublic,
        createdByUser: req.user?.user_id || null,  // From auth middleware
        createdByAdmin: req.admin?.admin_id || null  // From admin auth middleware
      };

      // Ensure at least one creator is set
      if (!dishData.createdByUser && !dishData.createdByAdmin) {
        return res.status(401).json({
          success: false,
          message: 'Authentication required'
        });
      }

      const dish = await dishService.createDish(dishData);
      console.log('Dish created with ID:', dish.dish_id);

      // If ingredients provided, add them and calculate nutrients
      if (ingredients && Array.isArray(ingredients) && ingredients.length > 0) {
        console.log('Adding ingredients to dish:', dish.dish_id);
        await dishService.addIngredients(dish.dish_id, ingredients);
        console.log('Recalculating nutrients for dish:', dish.dish_id);
        await dishService.recalculateNutrients(dish.dish_id);
        console.log('Nutrients calculated successfully');
      } else {
        console.log('No ingredients provided for dish:', dish.dish_id);
      }

      res.status(201).json({
        success: true,
        message: 'Dish created successfully',
        data: dish
      });
    } catch (error) {
      console.error('Error in createDish controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create dish',
        error: error.message
      });
    }
  },

  /**
   * PUT /api/dishes/:id
   * Update an existing dish
   */
  async updateDish(req, res) {
    try {
      const dishId = parseInt(req.params.id);

      if (isNaN(dishId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid dish ID'
        });
      }

      // Check if dish exists and user has permission
      const existingDish = await dishService.getDishById(dishId);

      if (!existingDish) {
        return res.status(404).json({
          success: false,
          message: 'Dish not found'
        });
      }

      // Permission check: admins can edit all, users can only edit their own
      const isAdmin = !!req.admin;
      const isOwner = req.user && existingDish.created_by_user === req.user.user_id;

      if (!isAdmin && !isOwner) {
        return res.status(403).json({
          success: false,
          message: 'You do not have permission to edit this dish'
        });
      }

      const dishData = {
        name: req.body.name,
        vietnameseName: req.body.vietnameseName,
        description: req.body.description,
        category: req.body.category,
        servingSizeG: req.body.servingSizeG,
        imageUrl: req.body.imageUrl,
        isTemplate: req.body.isTemplate,
        isPublic: req.body.isPublic
      };

      const updatedDish = await dishService.updateDish(dishId, dishData);

      res.json({
        success: true,
        message: 'Dish updated successfully',
        data: updatedDish
      });
    } catch (error) {
      console.error('Error in updateDish controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update dish',
        error: error.message
      });
    }
  },

  /**
   * DELETE /api/dishes/:id
   * Delete a dish (soft delete for users, hard delete for admins if forced)
   */
  async deleteDish(req, res) {
    try {
      const dishId = parseInt(req.params.id);
      const hardDelete = req.query.hard === 'true';

      if (isNaN(dishId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid dish ID'
        });
      }

      // Check if dish exists and user has permission
      const existingDish = await dishService.getDishById(dishId);

      if (!existingDish) {
        return res.status(404).json({
          success: false,
          message: 'Dish not found'
        });
      }

      // Permission check
      const isAdmin = !!req.admin;
      const isOwner = req.user && existingDish.created_by_user === req.user.user_id;
      const isUserCreated = existingDish.created_by_user !== null && existingDish.created_by_admin === null;

      if (!isAdmin && !isOwner) {
        return res.status(403).json({
          success: false,
          message: 'You do not have permission to delete this dish'
        });
      }

      // Check if dish is used in meals
      const usageCheck = await db.query(
        'SELECT COUNT(*) as count FROM MealItem WHERE dish_id = $1',
        [dishId]
      );
      const isUsedInMeals = parseInt(usageCheck.rows[0].count) > 0;

      // User-created dishes: hard delete only if not used in meals
      // Admin template dishes: always soft delete if used in meals
      let shouldHardDelete = false;
      
      if (isUserCreated && !isUsedInMeals) {
        shouldHardDelete = true; // User dish, not in use → hard delete
      } else if (isUserCreated && isUsedInMeals) {
        // User dish but in use → force soft delete for data integrity
        shouldHardDelete = false;
      } else if (isAdmin && hardDelete && !isUsedInMeals) {
        shouldHardDelete = true; // Admin force delete, not in use → allow
      } else {
        shouldHardDelete = false; // Default: soft delete
      }

      console.log(`Deleting dish ${dishId}: isUserCreated=${isUserCreated}, isUsedInMeals=${isUsedInMeals}, hardDelete=${shouldHardDelete}`);

      await dishService.deleteDish(dishId, shouldHardDelete);

      res.json({
        success: true,
        message: shouldHardDelete 
          ? 'Dish permanently deleted' 
          : (isUsedInMeals 
              ? 'Dish marked as deleted (cannot permanently delete - used in meal history)' 
              : 'Dish deleted successfully')
      });
    } catch (error) {
      console.error('Error in deleteDish controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete dish',
        error: error.message
      });
    }
  },

  /**
   * POST /api/dishes/:id/ingredients
   * Add an ingredient to a dish
   */
  async addIngredient(req, res) {
    try {
      const dishId = parseInt(req.params.id);
      const { foodId, weightG, notes, displayOrder } = req.body;

      if (isNaN(dishId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid dish ID'
        });
      }

      if (!foodId || !weightG) {
        return res.status(400).json({
          success: false,
          message: 'Food ID and weight are required'
        });
      }

      // Check if dish exists and user has permission
      const existingDish = await dishService.getDishById(dishId);

      if (!existingDish) {
        return res.status(404).json({
          success: false,
          message: 'Dish not found'
        });
      }

      const isAdmin = !!req.admin;
      const isOwner = req.user && existingDish.created_by_user === req.user.user_id;

      if (!isAdmin && !isOwner) {
        return res.status(403).json({
          success: false,
          message: 'You do not have permission to modify this dish'
        });
      }

      const ingredient = await dishService.addIngredient(dishId, {
        foodId: parseInt(foodId),
        weightG: parseFloat(weightG),
        notes,
        displayOrder: displayOrder !== undefined ? parseInt(displayOrder) : undefined
      });

      res.status(201).json({
        success: true,
        message: 'Ingredient added successfully',
        data: ingredient
      });
    } catch (error) {
      console.error('Error in addIngredient controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to add ingredient',
        error: error.message
      });
    }
  },

  /**
   * PUT /api/dishes/ingredients/:ingredientId
   * Update an ingredient
   */
  async updateIngredient(req, res) {
    try {
      const ingredientId = parseInt(req.params.ingredientId);
      const { weightG, notes, displayOrder } = req.body;

      if (isNaN(ingredientId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid ingredient ID'
        });
      }

      const ingredientData = {
        weightG: weightG !== undefined ? parseFloat(weightG) : undefined,
        notes,
        displayOrder: displayOrder !== undefined ? parseInt(displayOrder) : undefined
      };

      const updatedIngredient = await dishService.updateIngredient(ingredientId, ingredientData);

      if (!updatedIngredient) {
        return res.status(404).json({
          success: false,
          message: 'Ingredient not found'
        });
      }

      res.json({
        success: true,
        message: 'Ingredient updated successfully',
        data: updatedIngredient
      });
    } catch (error) {
      console.error('Error in updateIngredient controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update ingredient',
        error: error.message
      });
    }
  },

  /**
   * DELETE /api/dishes/ingredients/:ingredientId
   * Remove an ingredient from a dish
   */
  async removeIngredient(req, res) {
    try {
      const ingredientId = parseInt(req.params.ingredientId);

      if (isNaN(ingredientId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid ingredient ID'
        });
      }

      const success = await dishService.removeIngredient(ingredientId);

      if (!success) {
        return res.status(404).json({
          success: false,
          message: 'Ingredient not found'
        });
      }

      res.json({
        success: true,
        message: 'Ingredient removed successfully'
      });
    } catch (error) {
      console.error('Error in removeIngredient controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to remove ingredient',
        error: error.message
      });
    }
  },

  /**
   * GET /api/dishes/:id/nutrients
   * Get all nutrients for a dish
   */
  async getDishNutrients(req, res) {
    try {
      const dishId = parseInt(req.params.id);

      if (isNaN(dishId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid dish ID'
        });
      }

      const nutrients = await dishService.getDishNutrients(dishId);

      res.json({
        success: true,
        data: nutrients,
        count: nutrients.length
      });
    } catch (error) {
      console.error('Error in getDishNutrients controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch nutrients',
        error: error.message
      });
    }
  },

  /**
   * POST /api/dishes/:id/recalculate
   * Manually recalculate nutrients for a dish
   */
  async recalculateNutrients(req, res) {
    try {
      const dishId = parseInt(req.params.id);

      if (isNaN(dishId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid dish ID'
        });
      }

      await dishService.recalculateNutrients(dishId);

      res.json({
        success: true,
        message: 'Nutrients recalculated successfully'
      });
    } catch (error) {
      console.error('Error in recalculateNutrients controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to recalculate nutrients',
        error: error.message
      });
    }
  },

  /**
   * GET /api/dishes/stats/dashboard
   * Get dish statistics for admin dashboard
   */
  async getDashboardStats(req, res) {
    try {
      const stats = await dishService.getDashboardStats();

      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('Error in getDashboardStats controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch dashboard statistics',
        error: error.message
      });
    }
  },

  /**
   * GET /api/dishes/popular
   * Get popular dishes (most logged)
   */
  async getPopularDishes(req, res) {
    try {
      const limit = req.query.limit ? parseInt(req.query.limit) : 10;
      const dishes = await dishService.getPopularDishes(limit);

      res.json({
        success: true,
        data: dishes
      });
    } catch (error) {
      console.error('Error in getPopularDishes controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch popular dishes',
        error: error.message
      });
    }
  },

  /**
   * GET /api/dishes/search
   * Search dishes by name (for meal logging)
   */
  async searchDishes(req, res) {
    try {
      const { q, limit } = req.query;

      if (!q) {
        return res.status(400).json({
          success: false,
          message: 'Search query (q) is required'
        });
      }

      const dishes = await dishService.searchDishes(
        q,
        limit ? parseInt(limit) : 20
      );

      res.json({
        success: true,
        data: dishes,
        count: dishes.length
      });
    } catch (error) {
      console.error('Error in searchDishes controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to search dishes',
        error: error.message
      });
    }
  },

  /**
   * POST /api/dishes/admin/:id/approve
   * Approve user dish to make it public template (admin only)
   */
  async approveDish(req, res) {
    try {
      const dishId = parseInt(req.params.id);

      // Update dish to be public template
      const result = await dishService.updateDish(dishId, {
        is_public: true,
        is_template: true
      });

      if (result) {
        res.json({
          success: true,
          message: 'Dish approved successfully',
          data: result
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'Dish not found'
        });
      }
    } catch (error) {
      console.error('Error in approveDish controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to approve dish',
        error: error.message
      });
    }
  },

  /**
   * GET /api/dishes/categories
   * Get all dish categories with counts
   */
  async getCategories(req, res) {
    try {
      const categories = await dishService.getCategories();

      res.json({
        success: true,
        data: categories
      });
    } catch (error) {
      console.error('Error in getCategories controller:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch categories',
        error: error.message
      });
    }
  }
};

module.exports = dishController;
