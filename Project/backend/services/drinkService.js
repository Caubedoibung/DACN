const db = require('../db');

function slugify(text = '') {
  return text
    .toString()
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // strip accents
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .replace(/-{2,}/g, '-');
}

async function attachNutrients(drinks) {
  const drinkIds = drinks.map((row) => row.drink_id);
  if (!drinkIds.length) return drinks;
  const nutrientsRes = await db.query(
    `
    SELECT dn.drink_id, n.nutrient_code, dn.amount_per_100ml
    FROM DrinkNutrient dn
    JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
    WHERE dn.drink_id = ANY($1::int[])
  `,
    [drinkIds]
  );

  const nutrientMap = nutrientsRes.rows.reduce((acc, item) => {
    if (!acc[item.drink_id]) acc[item.drink_id] = {};
    acc[item.drink_id][item.nutrient_code] = Number(item.amount_per_100ml);
    return acc;
  }, {});

  return drinks.map((drink) => {
    drink.nutrients = nutrientMap[drink.drink_id] || {};
    return drink;
  });
}

async function syncDrinkIngredients(client, drinkId, ingredients = []) {
  await client.query('DELETE FROM DrinkIngredient WHERE drink_id = $1', [drinkId]);
  for (const ingredient of ingredients) {
    const foodId = parseInt(ingredient.food_id, 10);
    const amount = Number(ingredient.amount_g);
    if (!foodId || isNaN(amount) || amount <= 0) continue;
    await client.query(
      `
      INSERT INTO DrinkIngredient (drink_id, food_id, amount_g, display_order, notes)
      VALUES ($1,$2,$3,$4,$5)
    `,
      [
        drinkId,
        foodId,
        amount,
        ingredient.display_order ?? 0,
        ingredient.notes || null,
      ]
    );
  }
}

async function calculateDrinkNutrients(client, drinkId, totalVolume) {
  const normalizedVolume = Number(totalVolume) > 0 ? Number(totalVolume) : 100;
  await client.query(
    `
    INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
    SELECT $1, fn.nutrient_id,
           CASE
             WHEN $2 > 0 THEN SUM(di.amount_g * fn.amount_per_100g / 100.0) * 100.0 / $2
             ELSE 0
           END AS amount_per_100ml
    FROM DrinkIngredient di
    JOIN FoodNutrient fn ON fn.food_id = di.food_id
    WHERE di.drink_id = $1
    GROUP BY fn.nutrient_id
    ON CONFLICT (drink_id, nutrient_id)
    DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml
  `,
    [drinkId, normalizedVolume]
  );
}

async function listPublicDrinks() {
  const drinksRes = await db.query(`
    SELECT drink_id, name, vietnamese_name, description, category, base_liquid,
           default_volume_ml, default_temperature, hydration_ratio, caffeine_mg,
           sugar_free, image_url, created_by_user, is_public
    FROM Drink
    WHERE is_public = TRUE
    ORDER BY category NULLS LAST, name
  `);
  return attachNutrients(drinksRes.rows);
}

async function listDrinksForUser(userId) {
  const drinksRes = await db.query(
    `
    SELECT drink_id, name, vietnamese_name, description, category, base_liquid,
           default_volume_ml, default_temperature, hydration_ratio, caffeine_mg,
           sugar_free, image_url, is_public, created_by_user
    FROM Drink
    WHERE is_public = TRUE OR created_by_user = $1
    ORDER BY CASE WHEN is_public THEN 0 ELSE 1 END, created_at DESC
  `,
    [userId]
  );
  return attachNutrients(drinksRes.rows);
}

async function listAdminDrinks() {
  const res = await db.query(`
    SELECT d.*, COALESCE(ds.log_count, 0) AS log_count,
           COALESCE(ds.unique_users, 0) AS unique_users,
           ds.last_logged_at
    FROM Drink d
    LEFT JOIN DrinkStatistics ds ON ds.drink_id = d.drink_id
    ORDER BY d.created_at DESC
  `);
  return res.rows;
}

async function getDrinkById(drinkId) {
  const res = await db.query(`SELECT * FROM Drink WHERE drink_id = $1`, [
    drinkId,
  ]);
  return res.rows[0] || null;
}

async function getDrinkDetail(drinkId, userId) {
  const res = await db.query(
    `
    SELECT *,
           (created_by_user = $2) AS is_owner
    FROM Drink
    WHERE drink_id = $1
  `,
    [drinkId, userId]
  );
  const drink = res.rows[0];
  if (!drink) return null;
  if (!drink.is_public && drink.created_by_user !== userId) return null;

  const ingredientsRes = await db.query(
    `
    SELECT di.drink_ingredient_id, di.food_id, di.amount_g, di.notes,
           f.name, f.category, f.image_url
    FROM DrinkIngredient di
    JOIN Food f ON f.food_id = di.food_id
    WHERE di.drink_id = $1
    ORDER BY di.display_order, di.drink_ingredient_id
  `,
    [drinkId]
  );

  // Get nutrition details for each ingredient
  const ingredientsWithNutrition = await Promise.all(
    ingredientsRes.rows.map(async (ingredient) => {
      try {
        const nutritionRes = await db.query(
          `
          SELECT n.nutrient_id, n.nutrient_code, n.name, n.unit,
                 fn.amount_per_100g * $1 / 100.0 AS amount_in_ingredient
          FROM FoodNutrient fn
          JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
          WHERE fn.food_id = $2
          ORDER BY n.nutrient_code
        `,
          [ingredient.amount_g, ingredient.food_id]
        );
        ingredient.nutrition = nutritionRes.rows || [];
      } catch (err) {
        console.error(`[drinkService] Error loading nutrition for ingredient ${ingredient.food_id}:`, err);
        ingredient.nutrition = [];
      }
      return ingredient;
    })
  );

  let nutrientsRes = await db.query(
    `
    SELECT n.nutrient_id, n.nutrient_code, n.name, n.unit,
           dn.amount_per_100ml
    FROM DrinkNutrient dn
    JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
    WHERE dn.drink_id = $1
    ORDER BY n.nutrient_code
  `,
    [drinkId]
  );

  if (nutrientsRes.rowCount === 0) {
    nutrientsRes = await db.query(
      `
      SELECT n.nutrient_id,
             n.nutrient_code,
             n.name,
             n.unit,
             CASE
               WHEN COALESCE(d.default_volume_ml, 0) > 0
                 THEN SUM(di.amount_g * fn.amount_per_100g / 100.0) * 100.0 / d.default_volume_ml
               ELSE 0
             END AS amount_per_100ml
      FROM DrinkIngredient di
      JOIN FoodNutrient fn ON fn.food_id = di.food_id
      JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
      JOIN Drink d ON d.drink_id = di.drink_id
      WHERE di.drink_id = $1
      GROUP BY n.nutrient_id, n.nutrient_code, n.name, n.unit, d.default_volume_ml
      ORDER BY n.nutrient_code
    `,
      [drinkId]
    );
  }

  drink.ingredients = ingredientsWithNutrition;
  drink.nutrient_details = nutrientsRes.rows;
  return drink;
}

async function upsertDrink(payload, adminId) {
  const {
    drink_id,
    name,
    vietnamese_name,
    description,
    category,
    base_liquid,
    default_volume_ml,
    default_temperature,
    hydration_ratio,
    caffeine_mg,
    sugar_free,
    is_template,
    is_public,
    image_url,
    ingredients = [],
  } = payload;

  if (!name) {
    throw new Error('name is required');
  }

  const client = await db.pool.connect();
  let baseSlug = payload.slug || slugify(vietnamese_name || name);
  if (!baseSlug) {
    throw new Error('Unable to generate slug');
  }
  let slug = baseSlug;
  let suffix = 1;
  if (drink_id) {
    // When updating, ensure slug is unique except for current drink
    let check = await client.query(
      'SELECT drink_id FROM Drink WHERE slug = $1 AND drink_id <> $2',
      [slug, drink_id]
    );
    while (check.rowCount > 0) {
      slug = `${baseSlug}-${suffix++}`;
      check = await client.query(
        'SELECT drink_id FROM Drink WHERE slug = $1 AND drink_id <> $2',
        [slug, drink_id]
      );
    }
  } else {
    // When creating, ensure slug is unique
    let check = await client.query(
      'SELECT drink_id FROM Drink WHERE slug = $1',
      [slug]
    );
    while (check.rowCount > 0) {
      slug = `${baseSlug}-${suffix++}`;
      check = await client.query(
        'SELECT drink_id FROM Drink WHERE slug = $1',
        [slug]
      );
    }
  }
  try {
    await client.query('BEGIN');

    // Kiểm tra trùng slug khi thêm mới hoặc cập nhật
    if (drink_id) {
      const check = await client.query(
        'SELECT drink_id FROM Drink WHERE slug = $1 AND drink_id <> $2',
        [slug, drink_id]
      );
      if (check.rowCount > 0) {
        throw new Error('Tên hoặc slug đã tồn tại cho đồ uống khác');
      }
      const res = await client.query(
        `
        UPDATE Drink
        SET name = $2,
            vietnamese_name = $3,
            description = $4,
            category = $5,
            base_liquid = $6,
            default_volume_ml = COALESCE($7, default_volume_ml),
            default_temperature = COALESCE($8, default_temperature),
            hydration_ratio = COALESCE($9, hydration_ratio),
            caffeine_mg = COALESCE($10, caffeine_mg),
            sugar_free = COALESCE($11, sugar_free),
            is_template = COALESCE($12, is_template),
            is_public = COALESCE($13, is_public),
            image_url = COALESCE($14, image_url),
            slug = $15,
            updated_at = NOW()
        WHERE drink_id = $1
        RETURNING *
      `,
        [
          drink_id,
          name,
          vietnamese_name,
          description,
          category,
          base_liquid,
          default_volume_ml,
          default_temperature,
          hydration_ratio,
          caffeine_mg,
          sugar_free,
          is_template,
          is_public,
          image_url,
          slug,
        ]
      );
      drink = res.rows[0];
    } else {
      const check = await client.query(
        'SELECT drink_id FROM Drink WHERE slug = $1',
        [slug]
      );
      if (check.rowCount > 0) {
        throw new Error('Tên hoặc slug đã tồn tại');
      }
      const res = await client.query(
        `
        INSERT INTO Drink (
          name, vietnamese_name, description, category, base_liquid,
          default_volume_ml, default_temperature, hydration_ratio, caffeine_mg,
          sugar_free, is_template, is_public, image_url, slug, created_by_admin
        ) VALUES (
          $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15
        )
        RETURNING *
      `,
        [
          name,
          vietnamese_name,
          description,
          category,
          base_liquid,
          default_volume_ml || 250,
          default_temperature || 'cold',
          hydration_ratio || 1,
          caffeine_mg || 0,
          sugar_free ?? false,
          is_template ?? true,
          is_public ?? true,
          image_url,
          slug,
          adminId || null,
        ]
      );
      drink = res.rows[0];
    }

    const drinkId = drink.drink_id;
    if (Array.isArray(payload.ingredients)) {
      if (payload.ingredients.length > 0) {
        await syncDrinkIngredients(client, drinkId, payload.ingredients);
        const totalVolume = drink.default_volume_ml || 250;
        await calculateDrinkNutrients(client, drinkId, totalVolume);
      }
      // Nếu truyền vào mảng rỗng, không xóa nguyên liệu cũ, giữ nguyên kcal
    }

    await client.query('COMMIT');
    return drink;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function deleteDrink(drinkId) {
  await db.query(`DELETE FROM Drink WHERE drink_id = $1`, [drinkId]);
}

async function deleteUserDrink(drinkId, userId) {
  const res = await db.query(
    `DELETE FROM Drink WHERE drink_id = $1 AND created_by_user = $2 RETURNING drink_id`,
    [drinkId, userId]
  );
  return res.rowCount > 0;
}

async function getPublicDrinkById(drinkId) {
  const res = await db.query(
    `SELECT * FROM Drink WHERE drink_id = $1 AND is_public = TRUE`,
    [drinkId]
  );
  return res.rows[0] || null;
}

async function createCustomDrink(userId, payload) {
  const {
    name,
    vietnamese_name,
    description,
    category,
    base_liquid,
    default_volume_ml,
    hydration_ratio,
    caffeine_mg,
    sugar_free,
    image_url,
    ingredients = [],
  } = payload;

  if (!name) throw new Error('Tên đồ uống là bắt buộc');
  if (!ingredients.length) throw new Error('Vui lòng chọn ít nhất một nguyên liệu');

  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    const slug = slugify(`${name}-${Date.now()}`);
    const drinkRes = await client.query(
      `
      INSERT INTO Drink (
        name, vietnamese_name, description, category, base_liquid,
        default_volume_ml, default_temperature, hydration_ratio, caffeine_mg,
        sugar_free, is_template, is_public, image_url, slug, created_by_user
      )
      VALUES (
        $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,FALSE,FALSE,$11,$12,$13
      )
      RETURNING drink_id
    `,
      [
        name,
        vietnamese_name,
        description,
        category,
        base_liquid,
        default_volume_ml || 250,
        payload.default_temperature || 'cold',
        hydration_ratio || 1,
        caffeine_mg || 0,
        sugar_free ?? false,
        image_url,
        slug,
        userId,
      ]
    );

    const drinkId = drinkRes.rows[0].drink_id;

    await syncDrinkIngredients(client, drinkId, ingredients);

    const totalVolume =
      default_volume_ml ||
      ingredients.reduce((sum, ing) => sum + Number(ing.amount_g || 0), 0) ||
      100;

    await calculateDrinkNutrients(client, drinkId, totalVolume);

    await client.query('COMMIT');
    return getDrinkById(drinkId);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = {
  listPublicDrinks,
  listDrinksForUser,
  listAdminDrinks,
  getDrinkById,
  getDrinkDetail,
  getPublicDrinkById,
  upsertDrink,
  deleteDrink,
  deleteUserDrink,
  createCustomDrink,
};

