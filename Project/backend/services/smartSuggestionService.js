const db = require('../db');

/**
 * SMART SUGGESTIONS SERVICE
 * Phễu lọc 4 lớp: Context → Safety → Scoring → Boosting
 */

/**
 * Get smart suggestions for user (dish and/or drink)
 * @param {number} userId 
 * @param {object} options - {type: 'dish'|'drink'|'both', limit: 5|10|null}
 * @returns {Promise<Array>} Sorted suggestions with scores
 */
async function getSmartSuggestions(userId, options = {}) {
    const { type = 'both', limit = 10 } = options;
    
    // === LAYER 1: CONTEXT ===
    const context = await getContext(userId);
    
    if (!context) {
        throw new Error('Unable to get user context');
    }
    
    const suggestions = [];
    
    // When type='both', each type gets the full limit (not split)
    // So if limit=5, get 5 dishes + 5 drinks = 10 total
    // If limit=10, get 10 dishes + 10 drinks = 20 total
    
    // Get dish suggestions
    if (type === 'dish' || type === 'both') {
        const dishSuggestions = await getDishSuggestions(userId, context, limit);
        suggestions.push(...dishSuggestions);
    }
    
    // Get drink suggestions
    if (type === 'drink' || type === 'both') {
        const drinkSuggestions = await getDrinkSuggestions(userId, context, limit);
        suggestions.push(...drinkSuggestions);
    }
    
    // When type='both', don't limit total - keep all dishes and drinks
    // When type='dish' or 'drink', apply limit
    const finalSuggestions = (type === 'both') ? suggestions : (limit ? suggestions.slice(0, limit) : suggestions);
    
    // Log suggestion history
    await logSuggestionHistory(userId, type, limit, context, finalSuggestions);
    
    return finalSuggestions;
}

/**
 * LAYER 1: Get user context (gaps, weather, conditions, meal period)
 */
async function getContext(userId) {
    const result = await db.query(`
        SELECT 
            u.user_id,
            u.weight_kg,
            u.gender,
            -- Daily targets and current intake
            COALESCE(up.daily_protein_target, 0) as protein_target,
            COALESCE(up.daily_fat_target, 0) as fat_target,
            COALESCE(up.daily_carb_target, 0) as carb_target,
            COALESCE(up.daily_water_target, 0) as water_target,
            COALESCE(ds.total_protein, 0) as protein_current,
            COALESCE(ds.total_fat, 0) as fat_current,
            COALESCE(ds.total_carbs, 0) as carb_current,
            COALESCE(ds.total_water, 0) as water_current,
            -- Gaps (what's missing)
            GREATEST(COALESCE(up.daily_protein_target, 0) - COALESCE(ds.total_protein, 0), 0) as protein_gap,
            GREATEST(COALESCE(up.daily_fat_target, 0) - COALESCE(ds.total_fat, 0), 0) as fat_gap,
            GREATEST(COALESCE(up.daily_carb_target, 0) - COALESCE(ds.total_carbs, 0), 0) as carb_gap,
            GREATEST(COALESCE(up.daily_water_target, 0) - COALESCE(ds.total_water, 0), 0) as water_gap,
            -- Weather data
            us.weather_last_data as weather_data,
            us.weather_city,
            -- Meal times
            us.meal_time_breakfast,
            us.meal_time_lunch,
            us.meal_time_dinner,
            us.meal_time_snack
        FROM "User" u
        LEFT JOIN UserProfile up ON u.user_id = up.user_id
        LEFT JOIN DailySummary ds ON u.user_id = ds.user_id 
            AND ds.date = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date
        LEFT JOIN usersetting us ON u.user_id = us.user_id
        WHERE u.user_id = $1
    `, [userId]);
    
    if (result.rows.length === 0) return null;
    
    const row = result.rows[0];
    
    // Parse weather data
    let weather = null;
    if (row.weather_data) {
        try {
            const rawWeather = typeof row.weather_data === 'string' 
                ? JSON.parse(row.weather_data) 
                : row.weather_data;
            
            // Normalize OpenWeatherMap format to flat structure
            if (rawWeather) {
                weather = {
                    temp: rawWeather.main?.temp,
                    humidity: rawWeather.main?.humidity,
                    pressure: rawWeather.main?.pressure,
                    weather: rawWeather.weather?.[0]?.main,
                    description: rawWeather.weather?.[0]?.description,
                    icon: rawWeather.weather?.[0]?.icon,
                    // Keep full object for reference
                    main: rawWeather.main,
                    weather_array: rawWeather.weather
                };
            }
        } catch (e) {
            console.error('Failed to parse weather_data:', e);
        }
    }
    
    // Get current meal period
    const mealPeriodResult = await db.query(
        'SELECT get_current_meal_period($1) as meal_period',
        [userId]
    );
    const mealPeriod = mealPeriodResult.rows[0]?.meal_period || 'breakfast';
    
    // Get user health conditions
    const conditionsResult = await db.query(`
        SELECT hc.condition_id, hc.condition_name
        FROM userhealthcondition uhc
        JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
        WHERE uhc.user_id = $1 AND uhc.status = 'active'
    `, [userId]);
    
    const conditions = conditionsResult.rows.map(r => ({
        id: r.condition_id,
        name: r.condition_name
    }));
    
    return {
        userId,
        weight: row.weight_kg,
        gender: row.gender,
        gaps: {
            protein: row.protein_gap,
            fat: row.fat_gap,
            carb: row.carb_gap,
            water: row.water_gap
        },
        weather: weather,
        mealPeriod: mealPeriod,
        conditions: conditions
    };
}

/**
 * Get dish suggestions with 4-layer filtering
 */
async function getDishSuggestions(userId, context, limit) {
    const query = `
        WITH 
        -- Get user preferences (allergies, dislikes, favorites)
        user_prefs AS (
            SELECT food_id, preference_type, intensity
            FROM user_food_preferences
            WHERE user_id = $1
        ),
        -- Get recent eating history (for diversity penalty)
        recent_history AS (
            SELECT item_id, COUNT(*) as days_eaten
            FROM user_eating_history
            WHERE user_id = $1 
                AND item_type = 'dish'
                AND eaten_date >= (CURRENT_DATE - INTERVAL '7 days')
            GROUP BY item_id
        ),
        -- Get user active conditions
        user_conditions AS (
            SELECT hc.condition_id
            FROM userhealthcondition uhc
            JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
            WHERE uhc.user_id = $1 AND uhc.status = 'active'
        ),
        -- LAYER 2: SAFETY WALL - Filter dangerous dishes
        safe_dishes AS (
            SELECT DISTINCT d.dish_id
            FROM dish d
            WHERE 
                -- Not avoided by user conditions (dish level)
                NOT EXISTS (
                    SELECT 1 FROM conditiondishrecommendation cdr
                    JOIN user_conditions uc ON cdr.condition_id = uc.condition_id
                    WHERE cdr.dish_id = d.dish_id
                        AND cdr.recommendation_type = 'avoid'
                )
                -- Not containing avoided foods (ingredient level)
                AND NOT EXISTS (
                    SELECT 1 FROM dishingredient di
                    JOIN conditionfoodrecommendation cfr ON di.food_id = cfr.food_id
                    JOIN user_conditions uc ON cfr.condition_id = uc.condition_id
                    WHERE di.dish_id = d.dish_id
                        AND cfr.recommendation_type = 'avoid'
                )
                -- Not containing allergic foods
                AND NOT EXISTS (
                    SELECT 1 FROM dishingredient di
                    JOIN user_prefs up ON di.food_id = up.food_id
                    WHERE di.dish_id = d.dish_id
                        AND up.preference_type = 'allergy'
                )
        ),
        -- LAYER 3: NUTRIENT SCORING - Calculate how well dish fills gaps
        scored_dishes AS (
            SELECT 
                d.dish_id,
                d.name,
                d.vietnamese_name,
                d.description,
                d.image_url,
                d.category,
                -- Get macros
                COALESCE(SUM(CASE WHEN n.nutrient_code = 'PROCNT' THEN dn.amount_per_100g ELSE 0 END), 0) as protein,
                COALESCE(SUM(CASE WHEN n.nutrient_code = 'FAT' THEN dn.amount_per_100g ELSE 0 END), 0) as fat,
                COALESCE(SUM(CASE WHEN n.nutrient_code = 'CHOCDF' THEN dn.amount_per_100g ELSE 0 END), 0) as carb,
                COALESCE(SUM(CASE WHEN n.nutrient_code = 'VITC' THEN dn.amount_per_100g ELSE 0 END), 0) as vitamin_c,
                COALESCE(SUM(CASE WHEN n.nutrient_code = 'ENERC_KCAL' THEN dn.amount_per_100g ELSE 0 END), 0) as calories,
                -- SCORING FORMULA: (dish_nutrient / gap) * weight
                (
                    (COALESCE(SUM(CASE WHEN n.nutrient_code = 'PROCNT' THEN dn.amount_per_100g ELSE 0 END), 0) / GREATEST($2::numeric, 1)) * 0.4 +
                    (COALESCE(SUM(CASE WHEN n.nutrient_code = 'FAT' THEN dn.amount_per_100g ELSE 0 END), 0) / GREATEST($3::numeric, 1)) * 0.3 +
                    (COALESCE(SUM(CASE WHEN n.nutrient_code = 'CHOCDF' THEN dn.amount_per_100g ELSE 0 END), 0) / GREATEST($4::numeric, 1)) * 0.3
                ) as nutrient_score
            FROM safe_dishes sd
            JOIN dish d ON sd.dish_id = d.dish_id
            LEFT JOIN dishnutrient dn ON d.dish_id = dn.dish_id
            LEFT JOIN nutrient n ON dn.nutrient_id = n.nutrient_id
            GROUP BY d.dish_id, d.name, d.vietnamese_name, d.description, d.image_url, d.category
        ),
        -- LAYER 4: ENVIRONMENTAL BOOSTING + Diversity Penalty + Preferences
        final_scored AS (
            SELECT 
                sd.*,
                -- Diversity penalty
                CASE 
                    WHEN COALESCE(rh.days_eaten, 0) >= 5 THEN 0.0
                    WHEN COALESCE(rh.days_eaten, 0) = 4 THEN 0.3
                    WHEN COALESCE(rh.days_eaten, 0) = 3 THEN 0.5
                    WHEN COALESCE(rh.days_eaten, 0) = 2 THEN 0.8
                    ELSE 1.0
                END as diversity_penalty,
                -- Preference boost
                CASE 
                    WHEN EXISTS (
                        SELECT 1 FROM dishingredient di
                        JOIN user_prefs up ON di.food_id = up.food_id
                        WHERE di.dish_id = sd.dish_id AND up.preference_type = 'favorite'
                    ) THEN 1.3
                    WHEN EXISTS (
                        SELECT 1 FROM dishingredient di
                        JOIN user_prefs up ON di.food_id = up.food_id
                        WHERE di.dish_id = sd.dish_id AND up.preference_type = 'dislike'
                    ) THEN 0.5
                    ELSE 1.0
                END as preference_boost,
                -- Weather boost
                CASE
                    -- Cold weather: boost hot soups, vitamin C
                    WHEN $5::numeric < 20 OR $6 = 'Rain' THEN
                        CASE 
                            WHEN sd.category IN ('soup', 'hot_pot', 'stew') THEN 1.5
                            WHEN sd.vitamin_c > 10 THEN 1.3
                            ELSE 1.0
                        END
                    -- Hot weather: boost light, hydrating foods
                    WHEN $5::numeric > 30 AND $7::integer > 70 THEN
                        CASE
                            WHEN sd.category IN ('salad', 'cold_dish', 'fruit') THEN 1.4
                            WHEN sd.fat < 10 THEN 1.2
                            ELSE 1.0
                        END
                    ELSE 1.0
                END as weather_boost,
                -- Recommended boost
                CASE
                    WHEN EXISTS (
                        SELECT 1 FROM conditiondishrecommendation cdr
                        JOIN user_conditions uc ON cdr.condition_id = uc.condition_id
                        WHERE cdr.dish_id = sd.dish_id
                            AND cdr.recommendation_type = 'recommend'
                    ) THEN 1.2
                    ELSE 1.0
                END as recommended_boost
            FROM scored_dishes sd
            LEFT JOIN recent_history rh ON sd.dish_id = rh.item_id
        )
        SELECT 
            dish_id,
            name,
            vietnamese_name,
            description,
            image_url,
            category,
            protein,
            fat,
            carb,
            vitamin_c,
            calories,
            -- FINAL SCORE
            ROUND((nutrient_score * diversity_penalty * preference_boost * weather_boost * recommended_boost)::numeric, 2) as score,
            diversity_penalty,
            preference_boost,
            weather_boost,
            recommended_boost
        FROM final_scored
        WHERE diversity_penalty > 0 -- Filter out eaten 5+ days
        ORDER BY score DESC
        LIMIT $8
    `;
    
    const result = await db.query(query, [
        userId,
        parseFloat(context.gaps.protein) || 1,
        parseFloat(context.gaps.fat) || 1,
        parseFloat(context.gaps.carb) || 1,
        parseFloat(context.weather?.temp) || 25,
        context.weather?.weather || 'Clear',
        parseInt(context.weather?.humidity) || 60,
        limit || 999
    ]);
    
    return result.rows.map(row => ({
        item_type: 'dish',
        item_id: row.dish_id,
        name: row.name,
        vietnamese_name: row.vietnamese_name,
        description: row.description,
        image_url: row.image_url,
        category: row.category,
        nutrients: {
            protein: parseFloat(row.protein),
            fat: parseFloat(row.fat),
            carb: parseFloat(row.carb),
            vitamin_c: parseFloat(row.vitamin_c),
            calories: parseFloat(row.calories)
        },
        score: parseFloat(row.score),
        score_breakdown: {
            diversity_penalty: parseFloat(row.diversity_penalty),
            preference_boost: parseFloat(row.preference_boost),
            weather_boost: parseFloat(row.weather_boost),
            recommended_boost: parseFloat(row.recommended_boost)
        }
    }));
}

/**
 * Get drink suggestions (similar logic to dishes)
 */
async function getDrinkSuggestions(userId, context, limit) {
    // Similar to getDishSuggestions but for drinks
    const query = `
        WITH 
        user_prefs AS (
            SELECT food_id, preference_type
            FROM user_food_preferences
            WHERE user_id = $1
        ),
        recent_history AS (
            SELECT item_id, COUNT(*) as days_drunk
            FROM user_eating_history
            WHERE user_id = $1 
                AND item_type = 'drink'
                AND eaten_date >= (CURRENT_DATE - INTERVAL '7 days')
            GROUP BY item_id
        ),
        user_conditions AS (
            SELECT condition_id
            FROM userhealthcondition
            WHERE user_id = $1 AND status = 'active'
        ),
        safe_drinks AS (
            SELECT DISTINCT d.drink_id
            FROM drink d
            WHERE 
                NOT EXISTS (
                    SELECT 1 FROM conditiondrinkrecommendation cdr
                    JOIN user_conditions uc ON cdr.condition_id = uc.condition_id
                    WHERE cdr.drink_id = d.drink_id
                        AND cdr.recommendation_type = 'avoid'
                )
        ),
        scored_drinks AS (
            SELECT 
                d.drink_id,
                d.name,
                d.vietnamese_name,
                d.description,
                d.hydration_ratio,
                d.image_url,
                d.category,
                -- Water gap is most important for drinks
                ($2::numeric / 1000.0) * d.hydration_ratio as hydration_score
            FROM safe_drinks sd
            JOIN drink d ON sd.drink_id = d.drink_id
        ),
        final_scored AS (
            SELECT 
                sd.*,
                CASE 
                    WHEN COALESCE(rh.days_drunk, 0) >= 5 THEN 0.0
                    WHEN COALESCE(rh.days_drunk, 0) = 4 THEN 0.3
                    WHEN COALESCE(rh.days_drunk, 0) = 3 THEN 0.5
                    WHEN COALESCE(rh.days_drunk, 0) = 2 THEN 0.8
                    ELSE 1.0
                END as diversity_penalty,
                CASE
                    WHEN $3::numeric > 30 AND $4::integer > 70 THEN
                        CASE 
                            WHEN sd.hydration_ratio >= 1.0 THEN 1.5
                            ELSE 1.0
                        END
                    WHEN $3::numeric < 20 THEN
                        CASE
                            WHEN sd.category IN ('hot', 'tea', 'coffee') THEN 1.3
                            ELSE 1.0
                        END
                    ELSE 1.0
                END as weather_boost,
                CASE
                    WHEN EXISTS (
                        SELECT 1 FROM conditiondrinkrecommendation cdr
                        JOIN user_conditions uc ON cdr.condition_id = uc.condition_id
                        WHERE cdr.drink_id = sd.drink_id
                            AND cdr.recommendation_type = 'recommend'
                    ) THEN 1.2
                    ELSE 1.0
                END as recommended_boost,
                -- Get nutrients from drinknutrient table
                (SELECT amount_per_100ml FROM drinknutrient WHERE drink_id = sd.drink_id AND nutrient_id = 2 LIMIT 1) as protein_per_100ml,
                (SELECT amount_per_100ml FROM drinknutrient WHERE drink_id = sd.drink_id AND nutrient_id = 4 LIMIT 1) as carb_per_100ml,
                (SELECT amount_per_100ml FROM drinknutrient WHERE drink_id = sd.drink_id AND nutrient_id = 3 LIMIT 1) as fat_per_100ml
            FROM scored_drinks sd
            LEFT JOIN recent_history rh ON sd.drink_id = rh.item_id
        )
        SELECT 
            drink_id,
            name,
            vietnamese_name,
            description,
            hydration_ratio,
            image_url,
            category,
            ROUND((hydration_score * diversity_penalty * weather_boost * recommended_boost)::numeric, 2) as score,
            diversity_penalty,
            weather_boost,
            recommended_boost,
            protein_per_100ml,
            carb_per_100ml,
            fat_per_100ml
        FROM final_scored
        WHERE diversity_penalty > 0
        ORDER BY score DESC
        LIMIT $5
    `;
    
    const result = await db.query(query, [
        userId,
        parseFloat(context.gaps.water) || 1000,
        parseFloat(context.weather?.temp) || 25,
        parseInt(context.weather?.humidity) || 60,
        limit || 999
    ]);
    
    return result.rows.map(row => ({
        item_type: 'drink',
        item_id: row.drink_id,
        name: row.name,
        vietnamese_name: row.vietnamese_name,
        description: row.description,
        image_url: row.image_url,
        category: row.category,
        hydration_ratio: parseFloat(row.hydration_ratio),
        score: parseFloat(row.score),
        nutrients: {
            protein: row.protein_per_100ml ? (parseFloat(row.protein_per_100ml) * 2.5) : 0, // per 250ml
            carb: row.carb_per_100ml ? (parseFloat(row.carb_per_100ml) * 2.5) : 0,
            fat: row.fat_per_100ml ? (parseFloat(row.fat_per_100ml) * 2.5) : 0,
            water: parseFloat(row.hydration_ratio) * 250 // 250ml × hydration_ratio
        },
        score_breakdown: {
            diversity_penalty: parseFloat(row.diversity_penalty),
            weather_boost: parseFloat(row.weather_boost),
            recommended_boost: parseFloat(row.recommended_boost)
        }
    }));
}/**
 * Log suggestion history for analytics
 */
async function logSuggestionHistory(userId, type, limit, context, suggestions) {
    try {
        await db.query(`
            INSERT INTO suggestion_history (
                user_id, suggestion_type, limit_count, 
                context_snapshot, suggestions
            ) VALUES ($1, $2, $3, $4, $5)
        `, [
            userId,
            type,
            limit,
            JSON.stringify(context),
            JSON.stringify(suggestions.map(s => ({
                item_id: s.item_id,
                item_type: s.item_type,
                score: s.score
            })))
        ]);
    } catch (err) {
        console.error('Failed to log suggestion history:', err);
    }
}

/**
 * Pin a suggestion
 */
async function pinSuggestion(userId, itemType, itemId, mealPeriod) {
    // Get current meal period if not provided
    if (!mealPeriod) {
        const result = await db.query(
            'SELECT get_current_meal_period($1) as meal_period',
            [userId]
        );
        mealPeriod = result.rows[0]?.meal_period || 'breakfast';
    }
    
    // Unpin previous item of same type (only 1 dish + 1 drink allowed)
    await db.query(`
        DELETE FROM user_pinned_suggestions
        WHERE user_id = $1 AND item_type = $2
    `, [userId, itemType]);
    
    // Pin new item
    const result = await db.query(`
        INSERT INTO user_pinned_suggestions (
            user_id, item_type, item_id, meal_period
        ) VALUES ($1, $2, $3, $4)
        RETURNING *
    `, [userId, itemType, itemId, mealPeriod]);
    
    return result.rows[0];
}

/**
 * Unpin a suggestion
 */
async function unpinSuggestion(userId, itemType, itemId) {
    await db.query(`
        DELETE FROM user_pinned_suggestions
        WHERE user_id = $1 AND item_type = $2 AND item_id = $3
    `, [userId, itemType, itemId]);
}

/**
 * Get pinned suggestions for user
 */
async function getPinnedSuggestions(userId) {
    const result = await db.query(`
        SELECT 
            ups.*,
            CASE 
                WHEN ups.item_type = 'dish' THEN d.name
                WHEN ups.item_type = 'drink' THEN dr.name
            END as name,
            CASE 
                WHEN ups.item_type = 'dish' THEN d.image_url
                WHEN ups.item_type = 'drink' THEN dr.image_url
            END as image_url
        FROM user_pinned_suggestions ups
        LEFT JOIN dish d ON ups.item_type = 'dish' AND ups.item_id = d.dish_id
        LEFT JOIN drink dr ON ups.item_type = 'drink' AND ups.item_id = dr.drink_id
        WHERE ups.user_id = $1 AND ups.expires_at > NOW()
    `, [userId]);
    
    return result.rows;
}

/**
 * Unpin when user adds meal/drink
 */
async function unpinOnAdd(userId, itemType, itemId) {
    await unpinSuggestion(userId, itemType, itemId);
    
    // Also add to eating history for diversity tracking
    await db.query(`
        INSERT INTO user_eating_history (
            user_id, eaten_date, item_type, item_id, meal_period
        ) 
        SELECT $1, CURRENT_DATE, $2, $3, get_current_meal_period($1)
        ON CONFLICT DO NOTHING
    `, [userId, itemType, itemId]);
}

/**
 * Add/update user food preference
 */
async function setFoodPreference(userId, foodId, preferenceType, intensity = 3, notes = null) {
    const result = await db.query(`
        INSERT INTO user_food_preferences (
            user_id, food_id, preference_type, intensity, notes
        ) VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (user_id, food_id) 
        DO UPDATE SET 
            preference_type = EXCLUDED.preference_type,
            intensity = EXCLUDED.intensity,
            notes = EXCLUDED.notes,
            updated_at = NOW()
        RETURNING *
    `, [userId, foodId, preferenceType, intensity, notes]);
    
    return result.rows[0];
}

/**
 * Get user food preferences
 */
async function getFoodPreferences(userId, preferenceType = null) {
    let query = `
        SELECT 
            ufp.*,
            f.name as food_name
        FROM user_food_preferences ufp
        JOIN food f ON ufp.food_id = f.food_id
        WHERE ufp.user_id = $1
    `;
    
    const params = [userId];
    
    if (preferenceType) {
        query += ` AND ufp.preference_type = $2`;
        params.push(preferenceType);
    }
    
    query += ` ORDER BY ufp.updated_at DESC`;
    
    const result = await db.query(query, params);
    return result.rows;
}

module.exports = {
    getSmartSuggestions,
    pinSuggestion,
    unpinSuggestion,
    getPinnedSuggestions,
    unpinOnAdd,
    setFoodPreference,
    getFoodPreferences,
    getContext
};
