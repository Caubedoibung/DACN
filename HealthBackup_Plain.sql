--
-- PostgreSQL database dump
--

\restrict u32gY70U2ENUoeX217dG0bbJvNOrRPAzsYCeDUSYrkUKQdc5RRSKvzGKIsZe5cj

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2025-12-02 20:14:24

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 447 (class 1255 OID 24083)
-- Name: adjust_daily_summary_on_meal_entry_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.adjust_daily_summary_on_meal_entry_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user INT;
    v_date DATE;
    v_cal NUMERIC;
    v_prot NUMERIC;
    v_fat NUMERIC;
    v_carb NUMERIC;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_user := NEW.user_id;
        v_date := NEW.entry_date;
        v_cal := COALESCE(NEW.kcal, 0);
        v_prot := COALESCE(NEW.protein, 0);
        v_fat := COALESCE(NEW.fat, 0);
        v_carb := COALESCE(NEW.carbs, 0);
        
        -- Upsert DailySummary
        INSERT INTO DailySummary(user_id, date, total_calories, total_protein, total_fat, total_carbs)
        VALUES (v_user, v_date, v_cal, v_prot, v_fat, v_carb)
        ON CONFLICT (user_id, date) DO UPDATE
        SET total_calories = DailySummary.total_calories + EXCLUDED.total_calories,
            total_protein = DailySummary.total_protein + EXCLUDED.total_protein,
            total_fat = DailySummary.total_fat + EXCLUDED.total_fat,
            total_carbs = DailySummary.total_carbs + EXCLUDED.total_carbs;
        
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Decrement old values
        v_user := OLD.user_id;
        v_date := OLD.entry_date;
        v_cal := COALESCE(OLD.kcal, 0);
        v_prot := COALESCE(OLD.protein, 0);
        v_fat := COALESCE(OLD.fat, 0);
        v_carb := COALESCE(OLD.carbs, 0);
        
        UPDATE DailySummary SET
            total_calories = GREATEST(total_calories - v_cal, 0),
            total_protein = GREATEST(total_protein - v_prot, 0),
            total_fat = GREATEST(total_fat - v_fat, 0),
            total_carbs = GREATEST(total_carbs - v_carb, 0)
        WHERE user_id = v_user AND date = v_date;
        
        -- Increment new values
        v_user := NEW.user_id;
        v_date := NEW.entry_date;
        v_cal := COALESCE(NEW.kcal, 0);
        v_prot := COALESCE(NEW.protein, 0);
        v_fat := COALESCE(NEW.fat, 0);
        v_carb := COALESCE(NEW.carbs, 0);
        
        INSERT INTO DailySummary(user_id, date, total_calories, total_protein, total_fat, total_carbs)
        VALUES (v_user, v_date, v_cal, v_prot, v_fat, v_carb)
        ON CONFLICT (user_id, date) DO UPDATE
        SET total_calories = DailySummary.total_calories + EXCLUDED.total_calories,
            total_protein = DailySummary.total_protein + EXCLUDED.total_protein,
            total_fat = DailySummary.total_fat + EXCLUDED.total_fat,
            total_carbs = DailySummary.total_carbs + EXCLUDED.total_carbs;
        
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        v_user := OLD.user_id;
        v_date := OLD.entry_date;
        v_cal := COALESCE(OLD.kcal, 0);
        v_prot := COALESCE(OLD.protein, 0);
        v_fat := COALESCE(OLD.fat, 0);
        v_carb := COALESCE(OLD.carbs, 0);
        
        UPDATE DailySummary SET
            total_calories = GREATEST(total_calories - v_cal, 0),
            total_protein = GREATEST(total_protein - v_prot, 0),
            total_fat = GREATEST(total_fat - v_fat, 0),
            total_carbs = GREATEST(total_carbs - v_carb, 0)
        WHERE user_id = v_user AND date = v_date;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.adjust_daily_summary_on_meal_entry_change() OWNER TO postgres;

--
-- TOC entry 488 (class 1255 OID 21467)
-- Name: adjust_daily_summary_on_mealitem_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.adjust_daily_summary_on_mealitem_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
        v_user INT;
        v_date DATE;
BEGIN
        IF TG_OP = 'INSERT' THEN
                SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
                PERFORM upsert_daily_summary(v_user, v_date, NEW.calories, NEW.protein, NEW.fat, NEW.carbs);
                RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
                SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
                -- if meal_date or user changed, handle decrement on old row and increment on new
                IF (OLD.meal_id IS DISTINCT FROM NEW.meal_id) THEN
                        -- decrement old
                        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = OLD.meal_id;
                        UPDATE DailySummary SET total_calories = GREATEST(total_calories - COALESCE(OLD.calories,0),0), total_protein = GREATEST(total_protein - COALESCE(OLD.protein,0),0), total_fat = GREATEST(total_fat - COALESCE(OLD.fat,0),0), total_carbs = GREATEST(total_carbs - COALESCE(OLD.carbs,0),0) WHERE user_id = v_user AND date = v_date;
                        -- increment new
                        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
                        PERFORM upsert_daily_summary(v_user, v_date, NEW.calories, NEW.protein, NEW.fat, NEW.carbs);
                ELSE
                        -- same meal: apply delta
                        UPDATE DailySummary SET
                            total_calories = GREATEST(total_calories + COALESCE(NEW.calories,0) - COALESCE(OLD.calories,0),0),
                            total_protein = GREATEST(total_protein + COALESCE(NEW.protein,0) - COALESCE(OLD.protein,0),0),
                            total_fat = GREATEST(total_fat + COALESCE(NEW.fat,0) - COALESCE(OLD.fat,0),0),
                            total_carbs = GREATEST(total_carbs + COALESCE(NEW.carbs,0) - COALESCE(OLD.carbs,0),0)
                        WHERE user_id = v_user AND date = v_date;
                END IF;
                RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
            SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = OLD.meal_id;
            UPDATE DailySummary SET total_calories = GREATEST(total_calories - COALESCE(OLD.calories,0),0), total_protein = GREATEST(total_protein - COALESCE(OLD.protein,0),0), total_fat = GREATEST(total_fat - COALESCE(OLD.fat,0),0), total_carbs = GREATEST(total_carbs - COALESCE(OLD.carbs,0),0) WHERE user_id = v_user AND date = v_date;
                RETURN OLD;
        END IF;
        RETURN NULL;
END;
$$;


ALTER FUNCTION public.adjust_daily_summary_on_mealitem_change() OWNER TO postgres;

--
-- TOC entry 481 (class 1255 OID 24619)
-- Name: calculate_all_drink_nutrients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_all_drink_nutrients() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_drink_record RECORD;
    v_total_count INT := 0;
BEGIN
    FOR v_drink_record IN 
        SELECT DISTINCT drink_id 
        FROM drinkingredient 
        ORDER BY drink_id
    LOOP
        PERFORM calculate_drink_nutrients(v_drink_record.drink_id);
        v_total_count := v_total_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Hoàn thành! Đã tính toán dinh dưỡng cho % drinks', v_total_count;
END;
$$;


ALTER FUNCTION public.calculate_all_drink_nutrients() OWNER TO postgres;

--
-- TOC entry 436 (class 1255 OID 22051)
-- Name: calculate_bmi_and_score(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_bmi_and_score() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    calculated_bmi NUMERIC(4,2);
    score INT;
    category VARCHAR(20);
BEGIN
    -- Calculate BMI
    IF NEW.weight_kg IS NOT NULL AND NEW.height_cm IS NOT NULL AND NEW.height_cm > 0 THEN
        calculated_bmi := NEW.weight_kg / ((NEW.height_cm / 100.0) * (NEW.height_cm / 100.0));
        NEW.bmi := calculated_bmi;
        
        -- Calculate BMI score (1-10) and category
        -- WHO BMI categories with scoring
        IF calculated_bmi < 16.0 THEN
            score := 2; category := 'severely_underweight';
        ELSIF calculated_bmi < 17.0 THEN
            score := 3; category := 'underweight';
        ELSIF calculated_bmi < 18.5 THEN
            score := 5; category := 'mild_underweight';
        ELSIF calculated_bmi >= 18.5 AND calculated_bmi < 21.0 THEN
            score := 9; category := 'normal';
        ELSIF calculated_bmi >= 21.0 AND calculated_bmi < 25.0 THEN
            score := 10; category := 'optimal'; -- Peak score
        ELSIF calculated_bmi >= 25.0 AND calculated_bmi < 27.0 THEN
            score := 8; category := 'normal_high';
        ELSIF calculated_bmi >= 27.0 AND calculated_bmi < 30.0 THEN
            score := 6; category := 'overweight';
        ELSIF calculated_bmi >= 30.0 AND calculated_bmi < 35.0 THEN
            score := 4; category := 'obese_class_1';
        ELSIF calculated_bmi >= 35.0 AND calculated_bmi < 40.0 THEN
            score := 2; category := 'obese_class_2';
        ELSE
            score := 1; category := 'obese_class_3';
        END IF;
        
        NEW.bmi_score := score;
        NEW.bmi_category := category;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_bmi_and_score() OWNER TO postgres;

--
-- TOC entry 416 (class 1255 OID 24082)
-- Name: calculate_daily_nutrient_intake(integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_daily_nutrient_intake(p_user_id integer, p_date date) RETURNS TABLE(nutrient_type character varying, nutrient_id integer, nutrient_code character varying, nutrient_name character varying, current_amount numeric, target_amount numeric, unit character varying, percentage numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Calculate nutrient intake from meals for all nutrient types
    -- Use meal_entries (new system) UNION MealItem (old system for backward compatibility)
    RETURN QUERY
    WITH meal_items_today AS (
        -- New system: meal_entries
        SELECT me.food_id, me.weight_g
        FROM meal_entries me
        WHERE me.user_id = p_user_id AND me.entry_date = p_date
        UNION ALL
        -- Old system: MealItem (for backward compatibility)
        SELECT mi.food_id, mi.weight_g
        FROM MealItem mi
        JOIN Meal m ON m.meal_id = mi.meal_id
        WHERE m.user_id = p_user_id AND m.meal_date = p_date
    ),
    vitamin_intake AS (
        SELECT 
            'vitamin'::VARCHAR(20) as nutrient_type,
            v.vitamin_id::INT as nutrient_id,
            v.code as nutrient_code,
            v.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 0) as target_amount,
            v.unit,
            CASE 
                WHEN COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(uvr.recommended, v.recommended_daily::NUMERIC, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Vitamin v
        LEFT JOIN UserVitaminRequirement uvr ON uvr.vitamin_id = v.vitamin_id AND uvr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY v.vitamin_id, v.code, v.name, v.unit, v.recommended_daily, uvr.recommended
    ),
    mineral_intake AS (
        SELECT 
            'mineral'::VARCHAR(20) as nutrient_type,
            m.mineral_id::INT as nutrient_id,
            m.code as nutrient_code,
            m.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 0) as target_amount,
            m.unit,
            CASE 
                WHEN COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(umr.recommended, m.recommended_daily::NUMERIC, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Mineral m
        LEFT JOIN UserMineralRequirement umr ON umr.mineral_id = m.mineral_id AND umr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(REPLACE(m.code, 'MIN_', ''))
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY m.mineral_id, m.code, m.name, m.unit, m.recommended_daily, umr.recommended
    ),
    -- FIXED: Use 'AMINO_' prefix to match Nutrient table codes
    amino_acid_intake AS (
        SELECT 
            'amino_acid'::VARCHAR(20) as nutrient_type,
            aa.amino_acid_id::INT as nutrient_id,
            aa.code as nutrient_code,
            aa.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(uar.recommended, 0) as target_amount,
            'mg'::VARCHAR(20) as unit,
            CASE 
                WHEN COALESCE(uar.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(uar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM AminoAcid aa
        LEFT JOIN UserAminoRequirement uar ON uar.amino_acid_id = aa.amino_acid_id AND uar.user_id = p_user_id
        -- FIX: AminoAcid.code is 'LEU' but Nutrient.nutrient_code is 'AMINO_LEU'
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER('AMINO_' || aa.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY aa.amino_acid_id, aa.code, aa.name, uar.recommended
    ),
    -- Read from UserFiberIntake (populated by trigger) instead of recalculating from FoodNutrient
    fiber_intake AS (
        SELECT 
            'fiber'::VARCHAR(20) as nutrient_type,
            f.fiber_id::INT as nutrient_id,
            f.code as nutrient_code,
            f.name as nutrient_name,
            COALESCE(ufi.amount, 0) as current_amount,
            COALESCE(ufr.recommended, 0) as target_amount,
            f.unit,
            CASE 
                WHEN COALESCE(ufr.recommended, 0) > 0 
                THEN (COALESCE(ufi.amount, 0) / COALESCE(ufr.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Fiber f
        LEFT JOIN UserFiberRequirement ufr ON ufr.fiber_id = f.fiber_id AND ufr.user_id = p_user_id
        LEFT JOIN UserFiberIntake ufi ON ufi.fiber_id = f.fiber_id AND ufi.user_id = p_user_id AND ufi.date = p_date
    ),
    -- Read from UserFattyAcidIntake (populated by trigger) instead of recalculating from FoodNutrient
    fatty_acid_intake AS (
        SELECT 
            'fatty_acid'::VARCHAR(20) as nutrient_type,
            fa.fatty_acid_id::INT as nutrient_id,
            fa.code as nutrient_code,
            fa.name as nutrient_name,
            COALESCE(ufai.amount, 0) as current_amount,
            COALESCE(ufar.recommended, 0) as target_amount,
            fa.unit,
            CASE 
                WHEN COALESCE(ufar.recommended, 0) > 0 
                THEN (COALESCE(ufai.amount, 0) / COALESCE(ufar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM FattyAcid fa
        LEFT JOIN UserFattyAcidRequirement ufar ON ufar.fatty_acid_id = fa.fatty_acid_id AND ufar.user_id = p_user_id
        LEFT JOIN UserFattyAcidIntake ufai ON ufai.fatty_acid_id = fa.fatty_acid_id AND ufai.user_id = p_user_id AND ufai.date = p_date
    )
    SELECT * FROM vitamin_intake
    UNION ALL
    SELECT * FROM mineral_intake
    UNION ALL
    SELECT * FROM amino_acid_intake
    UNION ALL
    SELECT * FROM fiber_intake
    UNION ALL
    SELECT * FROM fatty_acid_intake;
END;
$$;


ALTER FUNCTION public.calculate_daily_nutrient_intake(p_user_id integer, p_date date) OWNER TO postgres;

--
-- TOC entry 427 (class 1255 OID 22822)
-- Name: calculate_dish_nutrients(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_dish_nutrients(p_dish_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total_weight NUMERIC;
    v_nutrient RECORD;
    v_amount NUMERIC;
BEGIN
    -- Get total weight of all ingredients in the dish
    SELECT SUM(weight_g) INTO v_total_weight
    FROM DishIngredient
    WHERE dish_id = p_dish_id;
    
    -- If no ingredients, clear all nutrients and return
    IF v_total_weight IS NULL OR v_total_weight = 0 THEN
        DELETE FROM DishNutrient WHERE dish_id = p_dish_id;
        RETURN;
    END IF;
    
    -- For each nutrient in the system, calculate the dish's content
    FOR v_nutrient IN SELECT nutrient_id FROM Nutrient LOOP
        -- Sum up contributions from all ingredients
        -- Formula: (ingredient_weight * nutrient_per_100g / 100) for each ingredient
        -- Then normalize to per 100g of total dish weight
        SELECT SUM(
            di.weight_g * COALESCE(fn.amount_per_100g, 0) / 100.0
        ) * 100.0 / v_total_weight
        INTO v_amount
        FROM DishIngredient di
        LEFT JOIN FoodNutrient fn ON fn.food_id = di.food_id 
            AND fn.nutrient_id = v_nutrient.nutrient_id
        WHERE di.dish_id = p_dish_id;
        
        -- Upsert into DishNutrient
        IF v_amount IS NOT NULL AND v_amount > 0 THEN
            INSERT INTO DishNutrient(dish_id, nutrient_id, amount_per_100g, calculated_at)
            VALUES (p_dish_id, v_nutrient.nutrient_id, ROUND(v_amount, 6), NOW())
            ON CONFLICT (dish_id, nutrient_id) DO UPDATE
            SET amount_per_100g = EXCLUDED.amount_per_100g,
                calculated_at = EXCLUDED.calculated_at;
        ELSE
            -- Remove zero/null nutrients to keep table clean
            DELETE FROM DishNutrient 
            WHERE dish_id = p_dish_id AND nutrient_id = v_nutrient.nutrient_id;
        END IF;
    END LOOP;
    
    -- Update dish's updated_at timestamp
    UPDATE Dish SET updated_at = NOW() WHERE dish_id = p_dish_id;
END;
$$;


ALTER FUNCTION public.calculate_dish_nutrients(p_dish_id integer) OWNER TO postgres;

--
-- TOC entry 430 (class 1255 OID 24618)
-- Name: calculate_drink_nutrients(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_drink_nutrients(p_drink_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total_volume_ml NUMERIC;
    v_total_weight_g NUMERIC;
BEGIN
    SELECT COALESCE(default_volume_ml, 250) 
    INTO v_total_volume_ml
    FROM drink 
    WHERE drink_id = p_drink_id;
    
    SELECT COALESCE(SUM(amount_g), 0)
    INTO v_total_weight_g
    FROM drinkingredient
    WHERE drink_id = p_drink_id;
    
    IF v_total_weight_g = 0 THEN
        RAISE NOTICE 'Drink ID % không có nguyên liệu nào', p_drink_id;
        RETURN;
    END IF;
    
    DELETE FROM drinknutrient WHERE drink_id = p_drink_id;
    
    INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml)
    SELECT 
        di.drink_id,
        fn.nutrient_id,
        ROUND(
            (SUM(fn.amount_per_100g * di.amount_g / 100.0) / v_total_volume_ml * 100)::numeric,
            6
        ) AS amount_per_100ml
    FROM drinkingredient di
    INNER JOIN foodnutrient fn ON di.food_id = fn.food_id
    WHERE di.drink_id = p_drink_id
    GROUP BY di.drink_id, fn.nutrient_id
    HAVING SUM(fn.amount_per_100g * di.amount_g / 100.0) > 0;
    
    RAISE NOTICE 'Đã tính toán dinh dưỡng cho Drink ID %: % nutrients', 
                 p_drink_id, 
                 (SELECT COUNT(*) FROM drinknutrient WHERE drink_id = p_drink_id);
END;
$$;


ALTER FUNCTION public.calculate_drink_nutrients(p_drink_id integer) OWNER TO postgres;

--
-- TOC entry 460 (class 1255 OID 22390)
-- Name: calculate_treatment_duration(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_treatment_duration() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.treatment_end_date IS NOT NULL AND NEW.treatment_start_date IS NOT NULL THEN
        NEW.treatment_duration_days := NEW.treatment_end_date - NEW.treatment_start_date;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_treatment_duration() OWNER TO postgres;

--
-- TOC entry 492 (class 1255 OID 22019)
-- Name: check_and_notify_nutrient_deficiencies(integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_and_notify_nutrient_deficiencies(p_user_id integer, p_date date DEFAULT CURRENT_DATE) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_nutrient RECORD;
    v_notification_count INT := 0;
    v_title TEXT;
    v_message TEXT;
    v_severity VARCHAR(20);
BEGIN
    -- Check nutrients at end of day (e.g., 8pm or later)
    FOR v_nutrient IN 
        SELECT * FROM calculate_daily_nutrient_intake(p_user_id, p_date)
        WHERE percentage < 50 -- Less than 50% of target
    LOOP
        -- Determine severity based on percentage
        IF v_nutrient.percentage < 25 THEN
            v_severity := 'critical';
            v_title := '⚠️ Thiếu hụt nghiêm trọng: ' || v_nutrient.nutrient_name;
            v_message := 'Bạn chỉ đạt ' || ROUND(v_nutrient.percentage, 0) || '% nhu cầu ' || v_nutrient.nutrient_name || 
                        ' (' || ROUND(v_nutrient.current_amount, 1) || '/' || ROUND(v_nutrient.target_amount, 1) || ' ' || v_nutrient.unit || 
                        '). Hãy bổ sung ngay!';
        ELSIF v_nutrient.percentage < 50 THEN
            v_severity := 'warning';
            v_title := '⚡ Cần bổ sung: ' || v_nutrient.nutrient_name;
            v_message := 'Bạn đã đạt ' || ROUND(v_nutrient.percentage, 0) || '% nhu cầu ' || v_nutrient.nutrient_name || 
                        ' (' || ROUND(v_nutrient.current_amount, 1) || '/' || ROUND(v_nutrient.target_amount, 1) || ' ' || v_nutrient.unit || 
                        '). Còn ' || ROUND(v_nutrient.target_amount - v_nutrient.current_amount, 1) || ' ' || v_nutrient.unit || ' nữa.';
        ELSE
            CONTINUE; -- Skip if not deficient
        END IF;

        -- Insert notification if not already exists today
        INSERT INTO UserNutrientNotification(
            user_id, nutrient_type, nutrient_id, nutrient_name,
            notification_type, title, message, severity, is_read,
            metadata
        )
        SELECT 
            p_user_id, 
            v_nutrient.nutrient_type, 
            v_nutrient.nutrient_id, 
            v_nutrient.nutrient_name,
            'deficiency_warning',
            v_title,
            v_message,
            v_severity,
            FALSE,
            jsonb_build_object(
                'date', p_date,
                'current_amount', v_nutrient.current_amount,
                'target_amount', v_nutrient.target_amount,
                'unit', v_nutrient.unit,
                'percentage', v_nutrient.percentage,
                'nutrient_code', v_nutrient.nutrient_code
            )
        WHERE NOT EXISTS (
            SELECT 1 FROM UserNutrientNotification
            WHERE user_id = p_user_id 
            AND nutrient_type = v_nutrient.nutrient_type
            AND nutrient_id = v_nutrient.nutrient_id
            AND notification_type = 'deficiency_warning'
            AND DATE(created_at) = p_date
        );

        IF FOUND THEN
            v_notification_count := v_notification_count + 1;
        END IF;
    END LOOP;

    RETURN v_notification_count;
END;
$$;


ALTER FUNCTION public.check_and_notify_nutrient_deficiencies(p_user_id integer, p_date date) OWNER TO postgres;

--
-- TOC entry 480 (class 1255 OID 24103)
-- Name: check_and_reset_water_if_new_day(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_and_reset_water_if_new_day(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_last_reset_date DATE;
    v_current_date DATE;
    v_user_timezone TEXT := 'Asia/Ho_Chi_Minh';
BEGIN
    -- Get current date in Vietnam timezone
    v_current_date := (NOW() AT TIME ZONE v_user_timezone)::DATE;
    
    -- Get last reset date from UserSetting or use a default
    SELECT COALESCE(
        (value::json->>'last_water_reset_date')::DATE,
        '1970-01-01'::DATE
    ) INTO v_last_reset_date
    FROM UserSetting
    WHERE user_id = p_user_id AND key = 'water_reset';
    
    -- If no setting exists, create it
    IF v_last_reset_date IS NULL THEN
        INSERT INTO UserSetting (user_id, key, value, updated_at)
        VALUES (p_user_id, 'water_reset', '{"last_water_reset_date": "1970-01-01"}'::json, NOW())
        ON CONFLICT (user_id, key) DO NOTHING;
        v_last_reset_date := '1970-01-01'::DATE;
    END IF;
    
    -- If date has changed (new day), reset water
    IF v_current_date > v_last_reset_date THEN
        -- Reset total_water in DailySummary for today
        UPDATE DailySummary
        SET total_water = 0
        WHERE user_id = p_user_id 
          AND date = v_current_date;
        
        -- Update last reset date
        INSERT INTO UserSetting (user_id, key, value, updated_at)
        VALUES (p_user_id, 'water_reset', json_build_object('last_water_reset_date', v_current_date), NOW())
        ON CONFLICT (user_id, key) DO UPDATE
        SET value = json_build_object('last_water_reset_date', v_current_date),
            updated_at = NOW();
        
        RAISE NOTICE 'Water reset for user % on date %', p_user_id, v_current_date;
    END IF;
END;
$$;


ALTER FUNCTION public.check_and_reset_water_if_new_day(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 450 (class 1255 OID 24060)
-- Name: check_drug_nutrient_interaction(integer, timestamp without time zone, integer[], integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_drug_nutrient_interaction(p_user_id integer, p_meal_time timestamp without time zone, p_food_ids integer[] DEFAULT NULL::integer[], p_drink_id integer DEFAULT NULL::integer) RETURNS TABLE(drug_id integer, drug_name_vi character varying, nutrient_id integer, nutrient_name character varying, warning_message_vi text, warning_message_en text, severity character varying, medication_time timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_window_start TIMESTAMP;
    v_window_end TIMESTAMP;
BEGIN
    -- Kiểm tra các lần uống thuốc trong vòng +/- 2 giờ (hoặc theo cấu hình)
    FOR drug_id, drug_name_vi, nutrient_id, nutrient_name, warning_message_vi, warning_message_en, severity, medication_time IN
        SELECT DISTINCT
            d.drug_id,
            d.name_vi,
            nc.nutrient_id,
            n.name,
            nc.warning_message_vi,
            nc.warning_message_en,
            nc.severity,
            ml.taken_at
        FROM MedicationLog ml
        JOIN Drug d ON d.drug_id = ml.drug_id
        JOIN DrugNutrientContraindication nc ON nc.drug_id = d.drug_id
        JOIN Nutrient n ON n.nutrient_id = nc.nutrient_id
        WHERE ml.user_id = p_user_id
          AND ml.status = 'taken'
          AND ml.taken_at IS NOT NULL
          AND ml.taken_at >= (p_meal_time - INTERVAL '1 hour' * COALESCE(nc.avoid_hours_before, 0))
          AND ml.taken_at <= (p_meal_time + INTERVAL '1 hour' * COALESCE(nc.avoid_hours_after, 2))
        LOOP
            -- Kiểm tra xem meal/drink có chứa nutrient này không
            IF p_food_ids IS NOT NULL AND array_length(p_food_ids, 1) > 0 THEN
                IF EXISTS (
                    SELECT 1
                    FROM FoodNutrient fn
                    WHERE fn.food_id = ANY(p_food_ids)
                      AND fn.nutrient_id = nutrient_id
                      AND fn.amount_per_100g > 0
                ) THEN
                    RETURN QUERY SELECT drug_id, drug_name_vi, nutrient_id, nutrient_name, warning_message_vi, warning_message_en, severity, medication_time;
                END IF;
            END IF;

            -- Kiểm tra drink
            IF p_drink_id IS NOT NULL THEN
                IF EXISTS (
                    SELECT 1
                    FROM DrinkNutrient dn
                    WHERE dn.drink_id = p_drink_id
                      AND dn.nutrient_id = nutrient_id
                      AND dn.amount_per_100ml > 0
                ) THEN
                    RETURN QUERY SELECT drug_id, drug_name_vi, nutrient_id, nutrient_name, warning_message_vi, warning_message_en, severity, medication_time;
                END IF;
            END IF;
        END LOOP;

    RETURN;
END;
$$;


ALTER FUNCTION public.check_drug_nutrient_interaction(p_user_id integer, p_meal_time timestamp without time zone, p_food_ids integer[], p_drink_id integer) OWNER TO postgres;

--
-- TOC entry 6576 (class 0 OID 0)
-- Dependencies: 450
-- Name: FUNCTION check_drug_nutrient_interaction(p_user_id integer, p_meal_time timestamp without time zone, p_food_ids integer[], p_drink_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.check_drug_nutrient_interaction(p_user_id integer, p_meal_time timestamp without time zone, p_food_ids integer[], p_drink_id integer) IS 'Kiểm tra tương tác thuốc-dinh dưỡng real-time khi user thêm meal/drink';


--
-- TOC entry 411 (class 1255 OID 21969)
-- Name: compute_and_upsert_fiber_fattyintake(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_and_upsert_fiber_fattyintake() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user INT;
    v_date DATE;
    rec RECORD;
    v_weight_factor NUMERIC;
    v_food_id INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = OLD.meal_id;
        v_food_id := OLD.food_id;
        v_weight_factor := OLD.weight_g / 100.0;
    ELSE
        SELECT meal_date, user_id INTO v_date, v_user FROM Meal WHERE meal_id = NEW.meal_id;
        v_food_id := NEW.food_id;
        v_weight_factor := NEW.weight_g / 100.0;
    END IF;

    IF v_food_id IS NULL OR v_user IS NULL OR v_date IS NULL THEN
        RETURN NULL;
    END IF;

    FOR rec IN
        SELECT nm.fiber_id, nm.fatty_acid_id, nm.factor, fn.amount_per_100g
        FROM FoodNutrient fn
        JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = v_food_id
    LOOP
        IF rec.fiber_id IS NOT NULL THEN
            PERFORM upsert_user_fiber_intake_specific(v_user, v_date, rec.fiber_id, COALESCE(rec.amount_per_100g,0) * COALESCE(rec.factor,1.0) * v_weight_factor);
        END IF;
        IF rec.fatty_acid_id IS NOT NULL THEN
            PERFORM upsert_user_fatty_intake_specific(v_user, v_date, rec.fatty_acid_id, COALESCE(rec.amount_per_100g,0) * COALESCE(rec.factor,1.0) * v_weight_factor);
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$;


ALTER FUNCTION public.compute_and_upsert_fiber_fattyintake() OWNER TO postgres;

--
-- TOC entry 434 (class 1255 OID 24078)
-- Name: compute_and_upsert_fiber_fattyintake_meal_entries(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_and_upsert_fiber_fattyintake_meal_entries() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user INT;
    v_date DATE;
    rec RECORD;
    v_weight_factor NUMERIC;
    v_food_id INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_user := OLD.user_id;
        v_date := OLD.entry_date;
        v_food_id := OLD.food_id;
        v_weight_factor := COALESCE(OLD.weight_g, 0) / 100.0;
    ELSE
        v_user := NEW.user_id;
        v_date := NEW.entry_date;
        v_food_id := NEW.food_id;
        v_weight_factor := COALESCE(NEW.weight_g, 0) / 100.0;
    END IF;

    IF v_food_id IS NULL OR v_user IS NULL OR v_date IS NULL THEN
        RETURN COALESCE(NEW, OLD);
    END IF;

    -- Calculate fiber and fatty acid intake from FoodNutrient using NutrientMapping
    FOR rec IN
        SELECT nm.fiber_id, nm.fatty_acid_id, nm.factor, fn.amount_per_100g
        FROM FoodNutrient fn
        JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = v_food_id
    LOOP
        IF rec.fiber_id IS NOT NULL THEN
            PERFORM upsert_user_fiber_intake_specific(
                v_user, 
                v_date, 
                rec.fiber_id, 
                COALESCE(rec.amount_per_100g, 0) * COALESCE(rec.factor, 1.0) * v_weight_factor
            );
        END IF;
        IF rec.fatty_acid_id IS NOT NULL THEN
            PERFORM upsert_user_fatty_intake_specific(
                v_user, 
                v_date, 
                rec.fatty_acid_id, 
                COALESCE(rec.amount_per_100g, 0) * COALESCE(rec.factor, 1.0) * v_weight_factor
            );
        END IF;
    END LOOP;

    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION public.compute_and_upsert_fiber_fattyintake_meal_entries() OWNER TO postgres;

--
-- TOC entry 415 (class 1255 OID 21465)
-- Name: compute_mealitem_nutrients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_mealitem_nutrients() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_kcal NUMERIC := 0;
    v_protein NUMERIC := 0;
    v_fat NUMERIC := 0;
    v_carb NUMERIC := 0;
BEGIN
    -- Case 1: MealItem has a dish_id (using composed dish)
    IF NEW.dish_id IS NOT NULL THEN
        -- Get nutrients from DishNutrient table
        SELECT dn.amount_per_100g INTO v_kcal
        FROM DishNutrient dn
        JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = NEW.dish_id AND n.nutrient_code = 'ENERC_KCAL'
        LIMIT 1;
        
        SELECT dn.amount_per_100g INTO v_protein
        FROM DishNutrient dn
        JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = NEW.dish_id AND n.nutrient_code = 'PROCNT'
        LIMIT 1;
        
        SELECT dn.amount_per_100g INTO v_fat
        FROM DishNutrient dn
        JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = NEW.dish_id AND n.nutrient_code = 'FAT'
        LIMIT 1;
        
        SELECT dn.amount_per_100g INTO v_carb
        FROM DishNutrient dn
        JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = NEW.dish_id AND n.nutrient_code = 'CHOCDF'
        LIMIT 1;
        
        -- Fallback to name-based lookup if code not found
        IF v_kcal IS NULL OR v_kcal = 0 THEN
            SELECT dn.amount_per_100g INTO v_kcal 
            FROM DishNutrient dn 
            JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id 
            WHERE dn.dish_id = NEW.dish_id 
            AND (LOWER(n.name) LIKE '%calor%' OR LOWER(n.name) LIKE '%energy%')
            LIMIT 1;
        END IF;
        IF v_protein IS NULL OR v_protein = 0 THEN
            SELECT dn.amount_per_100g INTO v_protein 
            FROM DishNutrient dn 
            JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id 
            WHERE dn.dish_id = NEW.dish_id AND LOWER(n.name) LIKE '%protein%'
            LIMIT 1;
        END IF;
        IF v_fat IS NULL OR v_fat = 0 THEN
            SELECT dn.amount_per_100g INTO v_fat 
            FROM DishNutrient dn 
            JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id 
            WHERE dn.dish_id = NEW.dish_id AND LOWER(n.name) LIKE '%fat%'
            LIMIT 1;
        END IF;
        IF v_carb IS NULL OR v_carb = 0 THEN
            SELECT dn.amount_per_100g INTO v_carb 
            FROM DishNutrient dn 
            JOIN Nutrient n ON n.nutrient_id = dn.nutrient_id 
            WHERE dn.dish_id = NEW.dish_id 
            AND (LOWER(n.name) LIKE '%carb%' OR LOWER(n.name) LIKE '%carbo%')
            LIMIT 1;
        END IF;
    
    -- Case 2: MealItem has a food_id (traditional individual food)
    ELSIF NEW.food_id IS NOT NULL THEN
        -- Use existing food nutrient lookup (keep original logic)
        SELECT fn.amount_per_100g INTO v_kcal
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id AND n.nutrient_code = 'ENERC_KCAL'
        LIMIT 1;
        
        SELECT fn.amount_per_100g INTO v_protein
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id AND n.nutrient_code = 'PROCNT'
        LIMIT 1;
        
        SELECT fn.amount_per_100g INTO v_fat
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id AND n.nutrient_code = 'FAT'
        LIMIT 1;
        
        SELECT fn.amount_per_100g INTO v_carb
        FROM FoodNutrient fn
        JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
        WHERE fn.food_id = NEW.food_id AND n.nutrient_code = 'CHOCDF'
        LIMIT 1;
        
        -- Fallback name-based lookup
        IF v_kcal IS NULL OR v_kcal = 0 THEN
            SELECT fn.amount_per_100g INTO v_kcal 
            FROM FoodNutrient fn 
            JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
            WHERE fn.food_id = NEW.food_id 
            AND (LOWER(n.name) LIKE '%calor%' OR LOWER(n.name) LIKE '%energy%')
            LIMIT 1;
        END IF;
        IF v_protein IS NULL OR v_protein = 0 THEN
            SELECT fn.amount_per_100g INTO v_protein 
            FROM FoodNutrient fn 
            JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
            WHERE fn.food_id = NEW.food_id AND LOWER(n.name) LIKE '%protein%'
            LIMIT 1;
        END IF;
        IF v_fat IS NULL OR v_fat = 0 THEN
            SELECT fn.amount_per_100g INTO v_fat 
            FROM FoodNutrient fn 
            JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
            WHERE fn.food_id = NEW.food_id AND LOWER(n.name) LIKE '%fat%'
            LIMIT 1;
        END IF;
        IF v_carb IS NULL OR v_carb = 0 THEN
            SELECT fn.amount_per_100g INTO v_carb 
            FROM FoodNutrient fn 
            JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
            WHERE fn.food_id = NEW.food_id 
            AND (LOWER(n.name) LIKE '%carb%' OR LOWER(n.name) LIKE '%carbo%')
            LIMIT 1;
        END IF;
    
    -- Case 3: Neither food_id nor dish_id provided (should not happen due to constraint)
    ELSE
        NEW.calories := 0;
        NEW.protein := 0;
        NEW.fat := 0;
        NEW.carbs := 0;
        RETURN NEW;
    END IF;
    
    -- Null-safe coalescing
    v_kcal := COALESCE(v_kcal, 0);
    v_protein := COALESCE(v_protein, 0);
    v_fat := COALESCE(v_fat, 0);
    v_carb := COALESCE(v_carb, 0);
    
    -- Compute per item (weight_g is serving weight)
    NEW.calories := ROUND((v_kcal * NEW.weight_g) / 100.0, 2);
    NEW.protein := ROUND((v_protein * NEW.weight_g) / 100.0, 2);
    NEW.fat := ROUND((v_fat * NEW.weight_g) / 100.0, 2);
    NEW.carbs := ROUND((v_carb * NEW.weight_g) / 100.0, 2);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.compute_mealitem_nutrients() OWNER TO postgres;

--
-- TOC entry 432 (class 1255 OID 23786)
-- Name: compute_user_amino_requirement(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_user_amino_requirement(p_user_id integer, p_amino_id integer) RETURNS TABLE(base numeric, multiplier numeric, recommended numeric, unit text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
    v_per_kg BOOLEAN;
BEGIN
    -- pick the most specific AminoRequirement row matching sex/age if present
    SELECT ar.amount, ar.unit, ar.per_kg INTO v_base, v_unit, v_per_kg
    FROM AminoRequirement ar
    WHERE ar.amino_acid_id = p_amino_id
      AND (ar.sex IS NULL OR lower(ar.sex) = lower( (SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id) ) OR lower(ar.sex) = 'both')
      AND ( (ar.age_min IS NULL AND ar.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(ar.age_min, -9999) AND COALESCE(ar.age_max, 99999)
          ) )
    ORDER BY (ar.age_min IS NOT NULL) DESC, (ar.age_max IS NOT NULL) DESC
    LIMIT 1;

    IF v_base IS NULL THEN
        RETURN; -- no recommendation available
    END IF;

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    -- activity and goal heuristics (light): scale multiplier similar to vitamins/minerals
    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.2, 0.20 );
    END IF;
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN v_mult := v_mult + 0.03; ELSIF lower(v_goal) = 'gain_weight' THEN v_mult := v_mult - 0.01; END IF;
    END IF;
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN v_mult := v_mult + 0.02; END IF;

    -- compute final recommended number, handling per-kg
    IF v_per_kg = TRUE THEN
        IF v_weight IS NULL THEN
            RETURN; -- can't compute per-kg without weight
        END IF;

        -- (Non-SQL logs removed below)
        -- PS D:\app> cd D:\app\my_diary
        -- PS D:\app\my_diary> flutter analyze
        -- Analyzing my_diary...
        -- 8 issues found. (ran in 4.8s)
        -- PS D:\app\my_diary>

        RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_weight * v_mult, 3), v_unit;
    ELSE
        RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_mult, 3), v_unit;
    END IF;
END;
$$;


ALTER FUNCTION public.compute_user_amino_requirement(p_user_id integer, p_amino_id integer) OWNER TO postgres;

--
-- TOC entry 412 (class 1255 OID 23914)
-- Name: compute_user_fattyacid_requirement(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_user_fattyacid_requirement(p_user_id integer, p_fa_id integer) RETURNS TABLE(base numeric, multiplier numeric, recommended numeric, unit text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_req RECORD;
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
    v_rec NUMERIC;
    v_energy_kcal NUMERIC;
    v_code TEXT;
    v_base_pct NUMERIC;
BEGIN
    SELECT * INTO v_req FROM FattyAcidRequirement r
    WHERE r.fatty_acid_id = p_fa_id
      AND (r.sex IS NULL OR lower(r.sex) = lower((SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id)))
      AND ( (r.age_min IS NULL AND r.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(r.age_min, -9999) AND COALESCE(r.age_max, 99999)
          ) )
    LIMIT 1;

    IF v_req IS NULL THEN RETURN; END IF;

    v_base := v_req.base_value;
    v_unit := COALESCE(v_req.unit, 'g');

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, COALESCE(up.tdee,0), COALESCE(up.daily_calorie_target,0), u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_tdee, v_energy_kcal, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.10, 0.10 );
    END IF;
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN v_mult := v_mult + 0.03;
        ELSIF lower(v_goal) = 'gain_weight' THEN v_mult := v_mult - 0.02; END IF;
    END IF;
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN v_mult := v_mult + 0.02; END IF;

    -- Determine a sensible energy baseline (TDEE > daily_calorie_target > fallback 2000)
    IF v_tdee IS NULL OR v_tdee = 0 THEN
        v_tdee := v_energy_kcal;
    END IF;
    IF v_tdee IS NULL OR v_tdee = 0 THEN
        v_tdee := 2000; -- fallback kcal/day
    END IF;

    -- fetch canonical code for special-case nutrients (EPA/DHA/CHOLESTEROL)
    SELECT code INTO v_code FROM FattyAcid WHERE fatty_acid_id = p_fa_id LIMIT 1;

    IF v_req.is_energy_pct THEN
        -- convert energy percent (0-100) into grams of fat: grams = (pct/100 * kcal) / 9
        -- start with configured pct or base_value if stored as pct
        v_base_pct := COALESCE(v_req.energy_pct, v_req.base_value, 0);

        -- Apply demographic/activity adjustments for total fat group as requested:
        -- Male: +10% total fat
        -- Age 51-70: -5% total energy from fat
        -- Activity >= 1.725: +5% total energy from fat
        IF v_gender IS NOT NULL AND lower(v_gender) LIKE 'm%' THEN
            v_base_pct := v_base_pct * 1.10; -- +10%
        END IF;
        IF v_age IS NOT NULL AND v_age BETWEEN 51 AND 70 THEN
            v_base_pct := v_base_pct * 0.95; -- -5%
        END IF;
        IF v_activity IS NOT NULL AND v_activity >= 1.725 THEN
            v_base_pct := v_base_pct * 1.05; -- +5%
        END IF;

        -- final recommended grams from energy percent
        v_rec := ROUND( (COALESCE(v_base_pct,0) / 100.0) * v_tdee / 9.0 * v_mult, 3);
        v_base := v_base_pct; -- report base as pct
        v_unit := 'g';
    ELSE
        -- handle special mg-based nutrients (EPA/DHA combined and Cholesterol)
        IF v_code IS NOT NULL AND (upper(v_code) = 'EPA' OR upper(v_code) = 'DHA' OR upper(v_code) = 'EPA_DHA' OR upper(v_code) = 'EPA+DHA') THEN
            -- EPA+DHA baseline: 250 mg; males +100 mg
            v_rec := ROUND( (COALESCE(v_req.base_value,250) + CASE WHEN lower(v_gender) LIKE 'm%' THEN 100 ELSE 0 END) * v_mult , 0);
            v_base := COALESCE(v_req.base_value,250);
            v_unit := 'mg';
        ELSIF v_code IS NOT NULL AND upper(v_code) = 'CHOLESTEROL' THEN
            -- Cholesterol mg: default 300 mg, reduce to 200 mg for age 51-70
            v_rec := COALESCE(v_req.base_value,300);
            IF v_age IS NOT NULL AND v_age BETWEEN 51 AND 70 THEN
                v_rec := v_rec - 100;
            END IF;
            v_rec := ROUND(v_rec * v_mult, 0);
            v_base := COALESCE(v_req.base_value,300);
            v_unit := 'mg';
        ELSE
            -- standard gram-based or per-kg rules
            IF v_req.is_per_kg THEN
                IF v_weight IS NOT NULL THEN
                    v_rec := ROUND( COALESCE(v_base,0) * v_weight * v_mult, 3);
                ELSE
                    v_rec := NULL;
                END IF;
            ELSE
                v_rec := ROUND( COALESCE(v_base,0) * v_mult, 3);
            END IF;
        END IF;
    END IF;

    RETURN QUERY SELECT v_base, v_mult, v_rec, v_unit;
END;
$$;


ALTER FUNCTION public.compute_user_fattyacid_requirement(p_user_id integer, p_fa_id integer) OWNER TO postgres;

--
-- TOC entry 469 (class 1255 OID 23913)
-- Name: compute_user_fiber_requirement(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_user_fiber_requirement(p_user_id integer, p_fiber_id integer) RETURNS TABLE(base numeric, multiplier numeric, recommended numeric, unit text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
    v_req RECORD;
    v_rec NUMERIC;
BEGIN
    SELECT * INTO v_req FROM FiberRequirement r
    WHERE r.fiber_id = p_fiber_id
      AND (r.sex IS NULL OR lower(r.sex) = lower((SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id)))
      AND ( (r.age_min IS NULL AND r.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(r.age_min, -9999) AND COALESCE(r.age_max, 99999)
          ) )
    LIMIT 1;

    IF v_req IS NULL THEN
        -- nothing found
        RETURN;
    END IF;

    v_base := v_req.base_value;
    v_unit := COALESCE(v_req.unit, 'g');

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, COALESCE(up.tdee,0), u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_tdee, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    -- small activity/goal/gender multipliers to adjust fiber needs
    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.10, 0.10 );
    END IF;
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN v_mult := v_mult + 0.05;
        ELSIF lower(v_goal) = 'gain_weight' THEN v_mult := v_mult - 0.02; END IF;
    END IF;
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN v_mult := v_mult + 0.02; END IF;

    -- per-kg: multiply base_value by weight if required
    IF v_req.is_per_kg THEN
        IF v_weight IS NOT NULL THEN
            v_rec := ROUND(COALESCE(v_base,0) * v_weight * v_mult, 3);
        ELSE
            v_rec := NULL;
        END IF;
    ELSE
        v_rec := ROUND(COALESCE(v_base,0) * v_mult, 3);
    END IF;

    RETURN QUERY SELECT v_base, v_mult, v_rec, v_unit;
END;
$$;


ALTER FUNCTION public.compute_user_fiber_requirement(p_user_id integer, p_fiber_id integer) OWNER TO postgres;

--
-- TOC entry 444 (class 1255 OID 21578)
-- Name: compute_user_mineral_requirement(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_user_mineral_requirement(p_user_id integer, p_mineral_id integer) RETURNS TABLE(base numeric, multiplier numeric, recommended numeric, unit text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
BEGIN
    SELECT r.rda_value, r.unit INTO v_base, v_unit
    FROM MineralRDA r
    WHERE r.mineral_id = p_mineral_id
      AND (r.sex IS NULL OR lower(r.sex) = lower((SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id)))
      AND ( (r.age_min IS NULL AND r.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(r.age_min, -9999) AND COALESCE(r.age_max, 99999)
          ) )
    LIMIT 1;

    IF v_base IS NULL THEN
        SELECT m2.recommended_daily, m2.unit INTO v_base, v_unit FROM Mineral m2 WHERE m2.mineral_id = p_mineral_id;
    END IF;
    IF v_base IS NULL THEN
        RETURN;
    END IF;

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, COALESCE(up.tdee,0), u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_tdee, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.15, 0.15 );
    END IF;

    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN
            v_mult := v_mult + 0.03;
        ELSIF lower(v_goal) = 'gain_weight' THEN
            v_mult := v_mult - 0.01;
        END IF;
    END IF;

    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN
        v_mult := v_mult + 0.02;
    END IF;

    IF v_mult < 0.5 THEN v_mult := 0.5; END IF;
    IF v_mult > 2.0 THEN v_mult := 2.0; END IF;

    RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_mult, 3), v_unit;
END;
$$;


ALTER FUNCTION public.compute_user_mineral_requirement(p_user_id integer, p_mineral_id integer) OWNER TO postgres;

--
-- TOC entry 417 (class 1255 OID 21497)
-- Name: compute_user_vitamin_requirement(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_user_vitamin_requirement(p_user_id integer, p_vitamin_id integer) RETURNS TABLE(base numeric, multiplier numeric, recommended numeric, unit text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_base NUMERIC;
    v_unit TEXT;
    v_gender TEXT;
    v_goal TEXT;
    v_activity NUMERIC;
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_age INT;
    v_mult NUMERIC := 1.0;
BEGIN
    -- prefer age/sex-specific RDA if available in VitaminRDA, otherwise fall back to Vitamin.recommended_daily
    SELECT r.rda_value, r.unit INTO v_base, v_unit
    FROM VitaminRDA r
    WHERE r.vitamin_id = p_vitamin_id
      AND (r.sex IS NULL OR lower(r.sex) = lower((SELECT COALESCE(u.gender,'') FROM "User" u WHERE u.user_id = p_user_id)))
      AND ( (r.age_min IS NULL AND r.age_max IS NULL) OR (
            (SELECT COALESCE(u.age,0) FROM "User" u WHERE u.user_id = p_user_id) BETWEEN COALESCE(r.age_min, -9999) AND COALESCE(r.age_max, 99999)
          ) )
    LIMIT 1;

    IF v_base IS NULL THEN
        SELECT v2.recommended_daily, v2.unit INTO v_base, v_unit FROM Vitamin v2 WHERE v2.vitamin_id = p_vitamin_id;
    END IF;
    IF v_base IS NULL THEN
        RETURN; -- vitamin not found
    END IF;

    SELECT u.gender, up.goal_type, COALESCE(up.activity_factor,1.2), u.weight_kg, COALESCE(up.tdee,0), u.age
    INTO v_gender, v_goal, v_activity, v_weight, v_tdee, v_age
    FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = p_user_id;

    IF v_activity IS NULL THEN v_activity := 1.2; END IF;

    -- activity adjustment: small increase for more active users (scaled, capped)
    IF v_activity > 1.2 THEN
        v_mult := v_mult + LEAST( (v_activity - 1.2) * 0.25, 0.20 );
    END IF;

    -- goal adjustment: slight changes for weight goals
    IF v_goal IS NOT NULL THEN
        IF lower(v_goal) = 'lose_weight' THEN
            v_mult := v_mult + 0.05; -- modest increase for dieting demands
        ELSIF lower(v_goal) = 'gain_weight' THEN
            v_mult := v_mult - 0.02; -- small decrease
        END IF;
    END IF;

    -- gender example tweak (optional): small increase for males on average
    IF v_gender IS NOT NULL AND lower(v_gender) = 'male' THEN
        v_mult := v_mult + 0.02;
    END IF;

    -- clamp sensible multiplier bounds
    IF v_mult < 0.5 THEN v_mult := 0.5; END IF;
    IF v_mult > 2.0 THEN v_mult := 2.0; END IF;

    RETURN QUERY SELECT v_base, v_mult, ROUND(v_base * v_mult, 3), v_unit;
END;
$$;


ALTER FUNCTION public.compute_user_vitamin_requirement(p_user_id integer, p_vitamin_id integer) OWNER TO postgres;

--
-- TOC entry 487 (class 1255 OID 21470)
-- Name: compute_userprofile_daily_water_target(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compute_userprofile_daily_water_target() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_weight NUMERIC;
    v_tdee NUMERIC;
    v_activity NUMERIC;
    v_water_ml NUMERIC;
BEGIN
    -- load weight from User table
    SELECT weight_kg INTO v_weight FROM "User" WHERE user_id = NEW.user_id;

    v_tdee := NEW.tdee;
    v_activity := NEW.activity_factor;

    -- if any required value is missing, do not overwrite manual value
    IF v_weight IS NULL OR v_tdee IS NULL OR v_activity IS NULL THEN
        RETURN NEW;
    END IF;

    -- compute using agreed formula and ensure non-negative
    v_water_ml := ROUND( (v_tdee * 1.0) + (v_weight * 5 * (v_activity - 1.2)), 2 );
    v_water_ml := GREATEST(v_water_ml, 0);

    NEW.daily_water_target := v_water_ml;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.compute_userprofile_daily_water_target() OWNER TO postgres;

--
-- TOC entry 486 (class 1255 OID 21498)
-- Name: convert_rda_unit(numeric, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.convert_rda_unit(p_value numeric, p_from_unit text, p_to_unit text, p_vitamin_code text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    f TEXT := upper(coalesce(p_from_unit,''));
    t TEXT := upper(coalesce(p_to_unit,''));
    code TEXT := upper(coalesce(p_vitamin_code,''));
BEGIN
    IF p_value IS NULL OR f = '' OR t = '' OR f = t THEN RETURN p_value; END IF;
    -- mg <-> µg
    IF f = 'MG' AND t IN ('UG','UG/ML','MCG') THEN
        RETURN p_value * 1000;
    ELSIF (f = 'UG' OR f = 'MCG') AND t = 'MG' THEN
        RETURN p_value / 1000;
    END IF;
    -- IU conversions (limited support for common vitamins)
    IF f = 'IU' AND t IN ('UG','MCG') THEN
        -- Vitamin D: 1 IU = 0.025 µg
        IF code = 'VITD' THEN
            RETURN p_value * 0.025;
        END IF;
        -- Vitamin A (retinol): 1 IU = 0.3 µg retinol
        IF code = 'VITA' THEN
            RETURN p_value * 0.3;
        END IF;
        -- Vitamin E (alpha-tocopherol): approximate 1 IU ≈ 0.67 mg -> convert to µg
        IF code = 'VITE' AND t IN ('MG') THEN
            RETURN p_value * 0.67;
        END IF;
    END IF;
    -- fallback: no conversion known
    RETURN p_value;
END;
$$;


ALTER FUNCTION public.convert_rda_unit(p_value numeric, p_from_unit text, p_to_unit text, p_vitamin_code text) OWNER TO postgres;

--
-- TOC entry 495 (class 1255 OID 24504)
-- Name: create_friendship(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_friendship(p_user1_id integer, p_user2_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user1_id INT;
    v_user2_id INT;
BEGIN
    -- Ensure user1_id < user2_id
    IF p_user1_id < p_user2_id THEN
        v_user1_id := p_user1_id;
        v_user2_id := p_user2_id;
    ELSE
        v_user1_id := p_user2_id;
        v_user2_id := p_user1_id;
    END IF;
    
    -- Insert friendship
    INSERT INTO Friendship (user1_id, user2_id)
    VALUES (v_user1_id, v_user2_id)
    ON CONFLICT (user1_id, user2_id) DO NOTHING;
    
    -- Update friend request status
    UPDATE FriendRequest
    SET status = 'accepted',
        updated_at = NOW()
    WHERE ((sender_id = p_user1_id AND receiver_id = p_user2_id) OR
           (sender_id = p_user2_id AND receiver_id = p_user1_id))
      AND status = 'pending';
END;
$$;


ALTER FUNCTION public.create_friendship(p_user1_id integer, p_user2_id integer) OWNER TO postgres;

--
-- TOC entry 476 (class 1255 OID 24106)
-- Name: ensure_daily_summary_water_reset(integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ensure_daily_summary_water_reset(p_user_id integer, p_date date) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user_timezone TEXT := 'Asia/Ho_Chi_Minh';
    v_vietnam_date DATE;
BEGIN
    -- Get current date in Vietnam timezone
    v_vietnam_date := (NOW() AT TIME ZONE v_user_timezone)::DATE;
    
    -- If the requested date is today and water hasn't been reset, reset it
    IF p_date = v_vietnam_date THEN
        PERFORM check_and_reset_water_if_new_day(p_user_id);
    END IF;
END;
$$;


ALTER FUNCTION public.ensure_daily_summary_water_reset(p_user_id integer, p_date date) OWNER TO postgres;

--
-- TOC entry 451 (class 1255 OID 23119)
-- Name: get_admin_permissions(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_admin_permissions(p_admin_id integer) RETURNS TABLE(permission_name character varying, permission_description text, resource character varying, action character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT p.name, p.description, p.resource, p.action
    FROM adminrole ar
    JOIN rolepermission rp ON ar.role_name = rp.role_name
    JOIN permission p ON rp.permission_id = p.permission_id
    WHERE ar.admin_id = p_admin_id
    ORDER BY p.resource, p.action;
END;
$$;


ALTER FUNCTION public.get_admin_permissions(p_admin_id integer) OWNER TO postgres;

--
-- TOC entry 429 (class 1255 OID 22829)
-- Name: get_dish_ingredient_count(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_dish_ingredient_count(p_dish_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM DishIngredient WHERE dish_id = p_dish_id;
    RETURN COALESCE(v_count, 0);
END;
$$;


ALTER FUNCTION public.get_dish_ingredient_count(p_dish_id integer) OWNER TO postgres;

--
-- TOC entry 440 (class 1255 OID 22828)
-- Name: get_dish_total_weight(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_dish_total_weight(p_dish_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT SUM(weight_g) INTO v_total FROM DishIngredient WHERE dish_id = p_dish_id;
    RETURN COALESCE(v_total, 0);
END;
$$;


ALTER FUNCTION public.get_dish_total_weight(p_dish_id integer) OWNER TO postgres;

--
-- TOC entry 457 (class 1255 OID 24061)
-- Name: get_drugs_for_condition(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_drugs_for_condition(p_condition_id integer) RETURNS TABLE(drug_id integer, name_vi character varying, name_en character varying, generic_name character varying, drug_class character varying, image_url text, is_primary boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.drug_id,
        d.name_vi,
        d.name_en,
        d.generic_name,
        d.drug_class,
        d.image_url,
        dhc.is_primary
    FROM Drug d
    JOIN DrugHealthCondition dhc ON dhc.drug_id = d.drug_id
    WHERE dhc.condition_id = p_condition_id
      AND d.is_active = TRUE
    ORDER BY dhc.is_primary DESC, d.name_vi;
END;
$$;


ALTER FUNCTION public.get_drugs_for_condition(p_condition_id integer) OWNER TO postgres;

--
-- TOC entry 6577 (class 0 OID 0)
-- Dependencies: 457
-- Name: FUNCTION get_drugs_for_condition(p_condition_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.get_drugs_for_condition(p_condition_id integer) IS 'Lấy danh sách thuốc điều trị một bệnh cụ thể';


--
-- TOC entry 470 (class 1255 OID 24062)
-- Name: get_medication_history_stats(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_medication_history_stats(p_user_id integer, p_start_date date DEFAULT NULL::date, p_end_date date DEFAULT NULL::date) RETURNS TABLE(drug_id integer, drug_name_vi character varying, total_taken integer, total_skipped integer, total_pending integer, on_time_count integer, late_count integer, earliest_taken timestamp without time zone, latest_taken timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.drug_id,
        d.name_vi,
        COUNT(*) FILTER (WHERE ml.status = 'taken')::INT AS total_taken,
        COUNT(*) FILTER (WHERE ml.status = 'skipped')::INT AS total_skipped,
        COUNT(*) FILTER (WHERE ml.status = 'pending')::INT AS total_pending,
        COUNT(*) FILTER (WHERE ml.status = 'taken' AND ml.taken_at <= (ml.medication_date::TIMESTAMP + ml.medication_time + INTERVAL '30 minutes'))::INT AS on_time_count,
        COUNT(*) FILTER (WHERE ml.status = 'taken' AND ml.taken_at > (ml.medication_date::TIMESTAMP + ml.medication_time + INTERVAL '30 minutes'))::INT AS late_count,
        MIN(ml.taken_at) FILTER (WHERE ml.status = 'taken') AS earliest_taken,
        MAX(ml.taken_at) FILTER (WHERE ml.status = 'taken') AS latest_taken
    FROM MedicationLog ml
    JOIN Drug d ON d.drug_id = ml.drug_id
    WHERE ml.user_id = p_user_id
      AND (p_start_date IS NULL OR ml.medication_date >= p_start_date)
      AND (p_end_date IS NULL OR ml.medication_date <= p_end_date)
    GROUP BY d.drug_id, d.name_vi
    ORDER BY total_taken DESC;
END;
$$;


ALTER FUNCTION public.get_medication_history_stats(p_user_id integer, p_start_date date, p_end_date date) OWNER TO postgres;

--
-- TOC entry 6578 (class 0 OID 0)
-- Dependencies: 470
-- Name: FUNCTION get_medication_history_stats(p_user_id integer, p_start_date date, p_end_date date); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.get_medication_history_stats(p_user_id integer, p_start_date date, p_end_date date) IS 'Thống kê lịch sử uống thuốc của user';


--
-- TOC entry 490 (class 1255 OID 24609)
-- Name: get_or_create_private_conversation(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_or_create_private_conversation(p_user1_id integer, p_user2_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user1_id INT;
    v_user2_id INT;
    v_conversation_id INT;
    v_friendship_exists BOOLEAN;
BEGIN
    -- Check if users are friends
    IF p_user1_id < p_user2_id THEN
        v_user1_id := p_user1_id;
        v_user2_id := p_user2_id;
    ELSE
        v_user1_id := p_user2_id;
        v_user2_id := p_user1_id;
    END IF;
    
    -- Check if friendship exists
    SELECT EXISTS(
        SELECT 1 FROM Friendship 
        WHERE user1_id = v_user1_id AND user2_id = v_user2_id
    ) INTO v_friendship_exists;
    
    IF NOT v_friendship_exists THEN
        RAISE EXCEPTION 'Users must be friends to start a private conversation';
    END IF;
    
    -- Get or create conversation
    SELECT conversation_id INTO v_conversation_id
    FROM PrivateConversation
    WHERE user1_id = v_user1_id AND user2_id = v_user2_id;
    
    IF v_conversation_id IS NULL THEN
        INSERT INTO PrivateConversation (user1_id, user2_id)
        VALUES (v_user1_id, v_user2_id)
        RETURNING conversation_id INTO v_conversation_id;
    END IF;
    
    RETURN v_conversation_id;
END;
$$;


ALTER FUNCTION public.get_or_create_private_conversation(p_user1_id integer, p_user2_id integer) OWNER TO postgres;

--
-- TOC entry 471 (class 1255 OID 22830)
-- Name: get_user_custom_dish_count(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_custom_dish_count(p_user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Dish WHERE created_by_user = p_user_id;
    RETURN COALESCE(v_count, 0);
END;
$$;


ALTER FUNCTION public.get_user_custom_dish_count(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 482 (class 1255 OID 24612)
-- Name: get_user_friends(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_friends(p_user_id integer) RETURNS TABLE(friendship_id integer, friend_id integer, created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.friendship_id,
        CASE 
            WHEN f.user1_id = p_user_id THEN f.user2_id
            ELSE f.user1_id
        END AS friend_id,
        f.created_at
    FROM Friendship f
    WHERE f.user1_id = p_user_id OR f.user2_id = p_user_id;
END;
$$;


ALTER FUNCTION public.get_user_friends(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 485 (class 1255 OID 23118)
-- Name: has_permission(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.has_permission(p_admin_id integer, p_permission_name character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1
        FROM adminrole ar
        JOIN rolepermission rp ON ar.role_name = rp.role_name
        JOIN permission p ON rp.permission_id = p.permission_id
        WHERE ar.admin_id = p_admin_id
        AND p.name = p_permission_name
    ) INTO v_has_permission;
    
    RETURN v_has_permission;
END;
$$;


ALTER FUNCTION public.has_permission(p_admin_id integer, p_permission_name character varying) OWNER TO postgres;

--
-- TOC entry 467 (class 1255 OID 24085)
-- Name: log_user_activity(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_user_activity(p_user_id integer, p_action text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_user_id IS NULL OR p_action IS NULL THEN RETURN; END IF;
    INSERT INTO UserActivityLog (user_id, action, log_time)
    VALUES (p_user_id, p_action, NOW())
    ON CONFLICT DO NOTHING; -- Ignore duplicates if any
EXCEPTION
    WHEN OTHERS THEN
        -- Silently ignore errors to not break main operations
        NULL;
END;
$$;


ALTER FUNCTION public.log_user_activity(p_user_id integer, p_action text) OWNER TO postgres;

--
-- TOC entry 484 (class 1255 OID 22871)
-- Name: notify_dish_approved(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_dish_approved() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- When dish becomes public (approved)
    IF NEW.is_public = TRUE AND OLD.is_public = FALSE AND NEW.created_by_user IS NOT NULL THEN
        INSERT INTO dishnotification (
            user_id,
            dish_id,
            notification_type,
            title,
            message
        ) VALUES (
            NEW.created_by_user,
            NEW.dish_id,
            'dish_approved',
            'Món ăn đã được phê duyệt! 🎉',
            FORMAT('Chúc mừng! Món "%s" của bạn đã được phê duyệt và hiện đã công khai cho mọi người sử dụng.', COALESCE(NEW.vietnamese_name, NEW.name))
        );
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_dish_approved() OWNER TO postgres;

--
-- TOC entry 493 (class 1255 OID 22870)
-- Name: notify_dish_created(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_dish_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Notify the creator
    IF NEW.created_by_user IS NOT NULL THEN
        INSERT INTO dishnotification (
            user_id,
            dish_id,
            notification_type,
            title,
            message
        ) VALUES (
            NEW.created_by_user,
            NEW.dish_id,
            'dish_created',
            'Món ăn đã được tạo thành công',
            FORMAT('Món "%s" của bạn đã được tạo thành công! Món ăn đang chờ phê duyệt từ quản trị viên.', COALESCE(NEW.vietnamese_name, NEW.name))
        );
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_dish_created() OWNER TO postgres;

--
-- TOC entry 473 (class 1255 OID 22872)
-- Name: notify_dish_popular(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_dish_popular() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_dish_name VARCHAR(200);
    v_user_id INTEGER;
BEGIN
    -- When dish reaches 10 times logged
    IF NEW.total_times_logged >= 10 AND OLD.total_times_logged < 10 THEN
        SELECT COALESCE(vietnamese_name, name), created_by_user INTO v_dish_name, v_user_id
        FROM dish WHERE dish_id = NEW.dish_id;
        
        IF v_user_id IS NOT NULL THEN
            INSERT INTO dishnotification (
                user_id,
                dish_id,
                notification_type,
                title,
                message
            ) VALUES (
                v_user_id,
                NEW.dish_id,
                'dish_popular',
                'Món ăn của bạn đang được yêu thích! ⭐',
                FORMAT('Món "%s" của bạn đã được ghi nhận %s lần! Cảm ơn bạn đã chia sẻ công thức tuyệt vời.', 
                       v_dish_name, NEW.total_times_logged)
            );
        END IF;
    END IF;
    
    -- Milestone notifications: 50, 100, 500 times
    IF NEW.total_times_logged >= 50 AND OLD.total_times_logged < 50 THEN
        SELECT COALESCE(vietnamese_name, name), created_by_user INTO v_dish_name, v_user_id
        FROM dish WHERE dish_id = NEW.dish_id;
        
        IF v_user_id IS NOT NULL THEN
            INSERT INTO dishnotification (
                user_id,
                dish_id,
                notification_type,
                title,
                message
            ) VALUES (
                v_user_id,
                NEW.dish_id,
                'dish_popular',
                'Món ăn siêu phổ biến! 🌟',
                FORMAT('Wow! Món "%s" đã đạt %s lần ghi nhận. Bạn thật tuyệt vời!', 
                       v_dish_name, NEW.total_times_logged)
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_dish_popular() OWNER TO postgres;

--
-- TOC entry 463 (class 1255 OID 21472)
-- Name: notify_user_weight_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_user_weight_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- if the user has a UserProfile row, do a no-op update to fire the UserProfile triggers
    IF EXISTS (SELECT 1 FROM UserProfile WHERE user_id = NEW.user_id) THEN
        UPDATE UserProfile SET tdee = tdee WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_user_weight_change() OWNER TO postgres;

--
-- TOC entry 502 (class 1255 OID 23787)
-- Name: refresh_user_amino_requirements(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_user_amino_requirements(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    a RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    FOR a IN SELECT amino_acid_id FROM AminoAcid LOOP
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_amino_requirement(p_user_id, a.amino_acid_id);
        -- upsert if computed (v_rec may be NULL if cannot compute)
        IF v_rec IS NOT NULL THEN
            INSERT INTO UserAminoRequirement(user_id, amino_acid_id, base, multiplier, recommended, unit, updated_at)
            VALUES (p_user_id, a.amino_acid_id, v_base, v_mult, v_rec, v_unit, NOW())
            ON CONFLICT (user_id, amino_acid_id) DO UPDATE
            SET base = EXCLUDED.base,
                multiplier = EXCLUDED.multiplier,
                recommended = EXCLUDED.recommended,
                unit = EXCLUDED.unit,
                updated_at = EXCLUDED.updated_at;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION public.refresh_user_amino_requirements(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 423 (class 1255 OID 23917)
-- Name: refresh_user_fatty_requirements(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_user_fatty_requirements(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    FOR v IN SELECT fatty_acid_id FROM FattyAcid LOOP
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_fattyacid_requirement(p_user_id, v.fatty_acid_id);
        INSERT INTO UserFattyAcidRequirement(user_id, fatty_acid_id, base, multiplier, recommended, unit, updated_at)
        VALUES (p_user_id, v.fatty_acid_id, v_base, v_mult, v_rec, v_unit, NOW())
        ON CONFLICT (user_id, fatty_acid_id) DO UPDATE
        SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
    END LOOP;
END;
$$;


ALTER FUNCTION public.refresh_user_fatty_requirements(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 464 (class 1255 OID 23916)
-- Name: refresh_user_fiber_requirements(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_user_fiber_requirements(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    FOR v IN SELECT fiber_id FROM Fiber LOOP
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_fiber_requirement(p_user_id, v.fiber_id);
        INSERT INTO UserFiberRequirement(user_id, fiber_id, base, multiplier, recommended, unit, updated_at)
        VALUES (p_user_id, v.fiber_id, v_base, v_mult, v_rec, v_unit, NOW())
        ON CONFLICT (user_id, fiber_id) DO UPDATE
        SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
    END LOOP;
END;
$$;


ALTER FUNCTION public.refresh_user_fiber_requirements(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 462 (class 1255 OID 21599)
-- Name: refresh_user_mineral_requirements(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_user_mineral_requirements(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    FOR v IN SELECT mineral_id FROM Mineral LOOP
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_mineral_requirement(p_user_id, v.mineral_id);
        INSERT INTO UserMineralRequirement(user_id, mineral_id, base, multiplier, recommended, unit, updated_at)
        VALUES (p_user_id, v.mineral_id, v_base, v_mult, v_rec, v_unit, NOW())
        ON CONFLICT (user_id, mineral_id) DO UPDATE
        SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
    END LOOP;
END;
$$;


ALTER FUNCTION public.refresh_user_mineral_requirements(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 499 (class 1255 OID 21519)
-- Name: refresh_user_vitamin_requirements(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_user_vitamin_requirements(p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v RECORD;
    v_base NUMERIC;
    v_mult NUMERIC;
    v_rec NUMERIC;
    v_unit TEXT;
BEGIN
    IF p_user_id IS NULL THEN
        RETURN;
    END IF;

    FOR v IN SELECT vitamin_id FROM Vitamin LOOP
        -- compute using existing helper
        SELECT base, multiplier, recommended, unit INTO v_base, v_mult, v_rec, v_unit FROM compute_user_vitamin_requirement(p_user_id, v.vitamin_id);
        -- upsert into cache table
        INSERT INTO UserVitaminRequirement(user_id, vitamin_id, base, multiplier, recommended, unit, updated_at)
        VALUES (p_user_id, v.vitamin_id, v_base, v_mult, v_rec, v_unit, NOW())
        ON CONFLICT (user_id, vitamin_id) DO UPDATE
        SET base = EXCLUDED.base, multiplier = EXCLUDED.multiplier, recommended = EXCLUDED.recommended, unit = EXCLUDED.unit, updated_at = EXCLUDED.updated_at;
    END LOOP;
END;
$$;


ALTER FUNCTION public.refresh_user_vitamin_requirements(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 501 (class 1255 OID 24102)
-- Name: reset_daily_water_utc7(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reset_daily_water_utc7() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_reset_date DATE;
BEGIN
    -- Get current date in UTC+7 (Vietnam time)
    -- PostgreSQL stores timestamps in UTC, so we need to convert
    -- Vietnam is UTC+7, so we subtract 7 hours from UTC to get Vietnam time
    v_reset_date := (NOW() AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
    
    -- Delete all WaterLog entries for yesterday (in Vietnam time)
    -- This effectively resets the water tracking
    -- Actually, we don't delete - we just ensure DailySummary.total_water is reset
    -- The reset happens by checking if the date has changed
    
    -- Update DailySummary to reset total_water for the new day
    -- This is handled by the application logic, but we can add a trigger
    -- that ensures water is reset when date changes
    
    RAISE NOTICE 'Water reset check for date: %', v_reset_date;
END;
$$;


ALTER FUNCTION public.reset_daily_water_utc7() OWNER TO postgres;

--
-- TOC entry 441 (class 1255 OID 21604)
-- Name: seed_core_minerals(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.seed_core_minerals() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE v_count INT := 0;
BEGIN
    PERFORM upsert_mineral('MIN_CA','Calcium (Ca)','Calcium for bones and teeth','mg',1000);
    PERFORM upsert_mineral('MIN_P','Phosphorus (P)','Phosphorus for bone and energy metabolism','mg',700);
    PERFORM upsert_mineral('MIN_MG','Magnesium (Mg)','Magnesium for muscle and nerve function','mg',310);
    PERFORM upsert_mineral('MIN_K','Potassium (K)','Potassium electrolyte','mg',4700);
    PERFORM upsert_mineral('MIN_NA','Sodium (Na)','Sodium electrolyte','mg',1500);
    PERFORM upsert_mineral('MIN_FE','Iron (Fe)','Iron for hemoglobin','mg',18);
    PERFORM upsert_mineral('MIN_ZN','Zinc (Zn)','Zinc for immune function','mg',11);
    PERFORM upsert_mineral('MIN_CU','Copper (Cu)','Copper cofactor','mg',0.9);
    PERFORM upsert_mineral('MIN_MN','Manganese (Mn)','Manganese cofactor','mg',2.3);
    PERFORM upsert_mineral('MIN_I','Iodine (I)','Iodine for thyroid','µg',150);
    PERFORM upsert_mineral('MIN_SE','Selenium (Se)','Selenium antioxidant','µg',55);
    PERFORM upsert_mineral('MIN_CR','Chromium (Cr)','Chromium for metabolism','µg',35);
    PERFORM upsert_mineral('MIN_MO','Molybdenum (Mo)','Molybdenum enzyme cofactor','µg',45);
    PERFORM upsert_mineral('MIN_F','Fluoride (F)','Fluoride for dental health','mg',3.0);
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;


ALTER FUNCTION public.seed_core_minerals() OWNER TO postgres;

--
-- TOC entry 408 (class 1255 OID 21524)
-- Name: seed_core_vitamins(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.seed_core_vitamins() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INT := 0;
BEGIN
    -- List provided: Vitamin A, D, E, K, C, B1, B2, B3, B5, B6, B7, B9, B12
    PERFORM upsert_vitamin('VITA','Vitamin A','Retinol and provitamin A compounds','µg',700);
    PERFORM upsert_vitamin('VITD','Vitamin D','Supports calcium metabolism and bone health','IU',600);
    PERFORM upsert_vitamin('VITE','Vitamin E','Antioxidant (tocopherols)','mg',15);
    PERFORM upsert_vitamin('VITK','Vitamin K','Needed for blood clotting (K1/K2)','µg',120);
    PERFORM upsert_vitamin('VITC','Vitamin C','Ascorbic acid, antioxidant','mg',75);
    PERFORM upsert_vitamin('VITB1','Vitamin B1 (Thiamine)','Supports energy metabolism','mg',1.2);
    PERFORM upsert_vitamin('VITB2','Vitamin B2 (Riboflavin)','Important for energy production','mg',1.3);
    PERFORM upsert_vitamin('VITB3','Vitamin B3 (Niacin)','Supports metabolism and skin health','mg',16);
    PERFORM upsert_vitamin('VITB5','Vitamin B5 (Pantothenic acid)','Component of coenzyme A','mg',5);
    PERFORM upsert_vitamin('VITB6','Vitamin B6 (Pyridoxine)','Supports metabolism and brain health','mg',1.3);
    PERFORM upsert_vitamin('VITB7','Vitamin B7 (Biotin)','Plays a role in macronutrient metabolism','µg',30);
    PERFORM upsert_vitamin('VITB9','Vitamin B9 (Folate)','Key for cell division and DNA synthesis','µg',400);
    PERFORM upsert_vitamin('VITB12','Vitamin B12 (Cobalamin)','Important for nerve function and blood formation','µg',2.4);

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;


ALTER FUNCTION public.seed_core_vitamins() OWNER TO postgres;

--
-- TOC entry 454 (class 1255 OID 22053)
-- Name: sync_latest_measurement_to_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_latest_measurement_to_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update User table with latest measurement
    UPDATE "User"
    SET 
        weight_kg = NEW.weight_kg,
        height_cm = NEW.height_cm
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sync_latest_measurement_to_user() OWNER TO postgres;

--
-- TOC entry 468 (class 1255 OID 24104)
-- Name: trg_check_water_reset_on_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_check_water_reset_on_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check and reset water if new day
    PERFORM check_and_reset_water_if_new_day(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_check_water_reset_on_log() OWNER TO postgres;

--
-- TOC entry 425 (class 1255 OID 24098)
-- Name: trg_log_body_measurement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_body_measurement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'body_measurement_recorded');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_body_measurement() OWNER TO postgres;

--
-- TOC entry 433 (class 1255 OID 24090)
-- Name: trg_log_dish_created(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_dish_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(NEW.created_by_user, 'dish_created');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_dish_created() OWNER TO postgres;

--
-- TOC entry 459 (class 1255 OID 24092)
-- Name: trg_log_drink_created(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_drink_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.created_by_user IS NOT NULL THEN
        PERFORM log_user_activity(NEW.created_by_user, 'drink_created');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_drink_created() OWNER TO postgres;

--
-- TOC entry 409 (class 1255 OID 24100)
-- Name: trg_log_health_condition_added(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_health_condition_added() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'health_condition_added');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_health_condition_added() OWNER TO postgres;

--
-- TOC entry 421 (class 1255 OID 24086)
-- Name: trg_log_meal_created(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_meal_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user_id INT;
BEGIN
    SELECT user_id INTO v_user_id FROM Meal WHERE meal_id = NEW.meal_id;
    IF v_user_id IS NOT NULL THEN
        PERFORM log_user_activity(v_user_id, 'meal_created');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_meal_created() OWNER TO postgres;

--
-- TOC entry 466 (class 1255 OID 24088)
-- Name: trg_log_meal_entry_created(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_meal_entry_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'meal_entry_created');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_meal_entry_created() OWNER TO postgres;

--
-- TOC entry 500 (class 1255 OID 24096)
-- Name: trg_log_medication_taken(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_medication_taken() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'medication_taken');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_medication_taken() OWNER TO postgres;

--
-- TOC entry 422 (class 1255 OID 24094)
-- Name: trg_log_water_logged(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_water_logged() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        PERFORM log_user_activity(NEW.user_id, 'water_logged');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_water_logged() OWNER TO postgres;

--
-- TOC entry 437 (class 1255 OID 22823)
-- Name: trg_recalc_dish_nutrients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_recalc_dish_nutrients() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM calculate_dish_nutrients(OLD.dish_id);
        RETURN OLD;
    ELSE
        PERFORM calculate_dish_nutrients(NEW.dish_id);
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION public.trg_recalc_dish_nutrients() OWNER TO postgres;

--
-- TOC entry 414 (class 1255 OID 23789)
-- Name: trg_refresh_user_amino_from_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_amino_from_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_amino_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_amino_from_user() OWNER TO postgres;

--
-- TOC entry 465 (class 1255 OID 23788)
-- Name: trg_refresh_user_amino_from_userprofile(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_amino_from_userprofile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_amino_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_amino_from_userprofile() OWNER TO postgres;

--
-- TOC entry 494 (class 1255 OID 23921)
-- Name: trg_refresh_user_fatty_from_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_fatty_from_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_fatty_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_fatty_from_user() OWNER TO postgres;

--
-- TOC entry 439 (class 1255 OID 23919)
-- Name: trg_refresh_user_fatty_from_userprofile(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_fatty_from_userprofile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_fatty_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_fatty_from_userprofile() OWNER TO postgres;

--
-- TOC entry 456 (class 1255 OID 23920)
-- Name: trg_refresh_user_fiber_from_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_fiber_from_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_fiber_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_fiber_from_user() OWNER TO postgres;

--
-- TOC entry 443 (class 1255 OID 23918)
-- Name: trg_refresh_user_fiber_from_userprofile(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_fiber_from_userprofile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_fiber_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_fiber_from_userprofile() OWNER TO postgres;

--
-- TOC entry 446 (class 1255 OID 21601)
-- Name: trg_refresh_user_minerals_from_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_minerals_from_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_mineral_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_minerals_from_user() OWNER TO postgres;

--
-- TOC entry 483 (class 1255 OID 21600)
-- Name: trg_refresh_user_minerals_from_userprofile(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_minerals_from_userprofile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_mineral_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_minerals_from_userprofile() OWNER TO postgres;

--
-- TOC entry 489 (class 1255 OID 21521)
-- Name: trg_refresh_user_vitamins_from_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_vitamins_from_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM refresh_user_vitamin_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_vitamins_from_user() OWNER TO postgres;

--
-- TOC entry 461 (class 1255 OID 21520)
-- Name: trg_refresh_user_vitamins_from_userprofile(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_refresh_user_vitamins_from_userprofile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- refresh for the affected user
    PERFORM refresh_user_vitamin_requirements(NEW.user_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_refresh_user_vitamins_from_userprofile() OWNER TO postgres;

--
-- TOC entry 438 (class 1255 OID 24620)
-- Name: trigger_recalculate_drink_nutrients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_recalculate_drink_nutrients() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM calculate_drink_nutrients(OLD.drink_id);
        RETURN OLD;
    ELSE
        PERFORM calculate_drink_nutrients(NEW.drink_id);
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION public.trigger_recalculate_drink_nutrients() OWNER TO postgres;

--
-- TOC entry 420 (class 1255 OID 22161)
-- Name: update_conversation_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_conversation_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_TABLE_NAME = 'ChatbotMessage' THEN
        UPDATE ChatbotConversation 
        SET updated_at = NOW() 
        WHERE conversation_id = NEW.conversation_id;
    ELSIF TG_TABLE_NAME = 'AdminMessage' THEN
        UPDATE AdminConversation 
        SET updated_at = NOW() 
        WHERE admin_conversation_id = NEW.admin_conversation_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_conversation_timestamp() OWNER TO postgres;

--
-- TOC entry 448 (class 1255 OID 22826)
-- Name: update_dish_statistics(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_dish_statistics() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_dish_id INT;
    v_user_id INT;
BEGIN
    IF TG_OP = 'INSERT' AND NEW.dish_id IS NOT NULL THEN
        v_dish_id := NEW.dish_id;
        SELECT user_id INTO v_user_id FROM Meal WHERE meal_id = NEW.meal_id;
        
        -- Upsert statistics
        INSERT INTO DishStatistics(dish_id, total_times_logged, unique_users_count, last_logged_at)
        VALUES (v_dish_id, 1, 1, NOW())
        ON CONFLICT (dish_id) DO UPDATE
        SET total_times_logged = DishStatistics.total_times_logged + 1,
            last_logged_at = NOW(),
            unique_users_count = (
                SELECT COUNT(DISTINCT m.user_id)
                FROM MealItem mi
                JOIN Meal m ON m.meal_id = mi.meal_id
                WHERE mi.dish_id = v_dish_id
            ),
            updated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_dish_statistics() OWNER TO postgres;

--
-- TOC entry 477 (class 1255 OID 24068)
-- Name: update_drug_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_drug_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_drug_updated_at() OWNER TO postgres;

--
-- TOC entry 475 (class 1255 OID 22189)
-- Name: update_food_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_food_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_food_timestamp() OWNER TO postgres;

--
-- TOC entry 458 (class 1255 OID 24505)
-- Name: update_friend_request_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_friend_request_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_friend_request_timestamp() OWNER TO postgres;

--
-- TOC entry 478 (class 1255 OID 22020)
-- Name: update_nutrient_tracking(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_nutrient_tracking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user_id INT;
    v_meal_date DATE;
BEGIN
    -- Get user_id and meal_date from the meal
    SELECT m.user_id, m.meal_date INTO v_user_id, v_meal_date
    FROM Meal m WHERE m.meal_id = COALESCE(NEW.meal_id, OLD.meal_id);

    -- Refresh tracking for this user and date
    -- This will be done via backend API call after meal operations
    -- But we can insert a placeholder here
    
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION public.update_nutrient_tracking() OWNER TO postgres;

--
-- TOC entry 424 (class 1255 OID 24610)
-- Name: update_private_conversation_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_private_conversation_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE PrivateConversation
    SET updated_at = NOW()
    WHERE conversation_id = NEW.conversation_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_private_conversation_timestamp() OWNER TO postgres;

--
-- TOC entry 426 (class 1255 OID 22464)
-- Name: update_recipe_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_recipe_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_recipe_timestamp() OWNER TO postgres;

--
-- TOC entry 498 (class 1255 OID 21466)
-- Name: upsert_daily_summary(integer, date, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_daily_summary(p_user_id integer, p_date date, p_cal numeric, p_prot numeric, p_fat numeric, p_carb numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
        INSERT INTO DailySummary(user_id, date, total_calories, total_protein, total_fat, total_carbs)
        VALUES (p_user_id, p_date, COALESCE(p_cal,0), COALESCE(p_prot,0), COALESCE(p_fat,0), COALESCE(p_carb,0))
        ON CONFLICT (user_id, date) DO UPDATE
        SET total_calories = DailySummary.total_calories + EXCLUDED.total_calories,
            total_protein = DailySummary.total_protein + EXCLUDED.total_protein,
            total_fat = DailySummary.total_fat + EXCLUDED.total_fat,
            total_carbs = DailySummary.total_carbs + EXCLUDED.total_carbs;
END;
$$;


ALTER FUNCTION public.upsert_daily_summary(p_user_id integer, p_date date, p_cal numeric, p_prot numeric, p_fat numeric, p_carb numeric) OWNER TO postgres;

--
-- TOC entry 431 (class 1255 OID 21576)
-- Name: upsert_mineral(text, text, text, text, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_mineral(p_code text, p_name text, p_description text, p_unit text, p_recommended numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO Mineral(code,name,description,unit,recommended_daily,created_by_admin)
    VALUES (p_code, p_name, p_description, p_unit, p_recommended, NULL)
    ON CONFLICT (code) DO UPDATE
    SET name = EXCLUDED.name,
        description = EXCLUDED.description,
        unit = EXCLUDED.unit,
        recommended_daily = EXCLUDED.recommended_daily
    RETURNING mineral_id INTO v_id;
    RETURN v_id;
END;
$$;


ALTER FUNCTION public.upsert_mineral(p_code text, p_name text, p_description text, p_unit text, p_recommended numeric) OWNER TO postgres;

--
-- TOC entry 418 (class 1255 OID 21577)
-- Name: upsert_mineral_by_name(text, text, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_mineral_by_name(p_name text, p_unit text, p_recommended numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_code TEXT := 'MIN' || regexp_replace(upper(coalesce(p_name,'')), '[^A-Z0-9]', '', 'g');
BEGIN
    RETURN upsert_mineral(v_code, p_name, NULL, p_unit, p_recommended);
END;
$$;


ALTER FUNCTION public.upsert_mineral_by_name(p_name text, p_unit text, p_recommended numeric) OWNER TO postgres;

--
-- TOC entry 497 (class 1255 OID 23927)
-- Name: upsert_user_fatty_intake(integer, date, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_user_fatty_intake(p_user integer, p_date date, p_amount numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_fa_id INT;
BEGIN
    -- prefer a FattyAcid with code 'TOTAL_FAT' else do nothing
    SELECT fatty_acid_id INTO v_fa_id FROM FattyAcid WHERE code = 'TOTAL_FAT' LIMIT 1;
    IF v_fa_id IS NULL THEN RETURN; END IF;

    INSERT INTO UserFattyAcidIntake(user_id, date, fatty_acid_id, amount)
    VALUES (p_user, p_date, v_fa_id, COALESCE(p_amount,0))
    ON CONFLICT (user_id, date, fatty_acid_id) DO UPDATE
    SET amount = COALESCE(UserFattyAcidIntake.amount,0) + EXCLUDED.amount;
END;
$$;


ALTER FUNCTION public.upsert_user_fatty_intake(p_user integer, p_date date, p_amount numeric) OWNER TO postgres;

--
-- TOC entry 453 (class 1255 OID 21968)
-- Name: upsert_user_fatty_intake_specific(integer, date, integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_user_fatty_intake_specific(p_user integer, p_date date, p_fatty_id integer, p_amount numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_fatty_id IS NULL THEN RETURN; END IF;
    INSERT INTO UserFattyAcidIntake(user_id, date, fatty_acid_id, amount)
    VALUES (p_user, p_date, p_fatty_id, COALESCE(p_amount,0))
    ON CONFLICT (user_id, date, fatty_acid_id) DO UPDATE
    SET amount = COALESCE(UserFattyAcidIntake.amount,0) + EXCLUDED.amount;
END;
$$;


ALTER FUNCTION public.upsert_user_fatty_intake_specific(p_user integer, p_date date, p_fatty_id integer, p_amount numeric) OWNER TO postgres;

--
-- TOC entry 413 (class 1255 OID 23926)
-- Name: upsert_user_fiber_intake(integer, date, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_user_fiber_intake(p_user integer, p_date date, p_amount numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_fiber_id INT;
BEGIN
    -- prefer a Fiber with code 'TOTAL_FIBER' else do nothing
    SELECT fiber_id INTO v_fiber_id FROM Fiber WHERE code = 'TOTAL_FIBER' LIMIT 1;
    IF v_fiber_id IS NULL THEN RETURN; END IF;

    INSERT INTO UserFiberIntake(user_id, date, fiber_id, amount)
    VALUES (p_user, p_date, v_fiber_id, COALESCE(p_amount,0))
    ON CONFLICT (user_id, date, fiber_id) DO UPDATE
    SET amount = COALESCE(UserFiberIntake.amount,0) + EXCLUDED.amount;
END;
$$;


ALTER FUNCTION public.upsert_user_fiber_intake(p_user integer, p_date date, p_amount numeric) OWNER TO postgres;

--
-- TOC entry 428 (class 1255 OID 21967)
-- Name: upsert_user_fiber_intake_specific(integer, date, integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_user_fiber_intake_specific(p_user integer, p_date date, p_fiber_id integer, p_amount numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_fiber_id IS NULL THEN RETURN; END IF;
    INSERT INTO UserFiberIntake(user_id, date, fiber_id, amount)
    VALUES (p_user, p_date, p_fiber_id, COALESCE(p_amount,0))
    ON CONFLICT (user_id, date, fiber_id) DO UPDATE
    SET amount = COALESCE(UserFiberIntake.amount,0) + EXCLUDED.amount;
END;
$$;


ALTER FUNCTION public.upsert_user_fiber_intake_specific(p_user integer, p_date date, p_fiber_id integer, p_amount numeric) OWNER TO postgres;

--
-- TOC entry 419 (class 1255 OID 21495)
-- Name: upsert_vitamin(text, text, text, text, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_vitamin(p_code text, p_name text, p_description text, p_unit text, p_recommended numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO Vitamin(code,name,description,unit,recommended_daily,created_by_admin)
    VALUES (p_code, p_name, p_description, p_unit, p_recommended, NULL)
    ON CONFLICT (code) DO UPDATE
    SET name = EXCLUDED.name,
        description = EXCLUDED.description,
        unit = EXCLUDED.unit,
        recommended_daily = EXCLUDED.recommended_daily
    RETURNING vitamin_id INTO v_id;
    RETURN v_id;
END;
$$;


ALTER FUNCTION public.upsert_vitamin(p_code text, p_name text, p_description text, p_unit text, p_recommended numeric) OWNER TO postgres;

--
-- TOC entry 479 (class 1255 OID 21496)
-- Name: upsert_vitamin_by_name(text, text, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_vitamin_by_name(p_name text, p_unit text, p_recommended numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_code TEXT := 'VIT' || regexp_replace(upper(coalesce(p_name,'')), '[^A-Z0-9]', '', 'g');
BEGIN
    RETURN upsert_vitamin(v_code, p_name, NULL, p_unit, p_recommended);
END;
$$;


ALTER FUNCTION public.upsert_vitamin_by_name(p_name text, p_unit text, p_recommended numeric) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 21089)
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    user_id integer NOT NULL,
    full_name character varying(100),
    email character varying(100) NOT NULL,
    password_hash text NOT NULL,
    age integer,
    gender character varying(10),
    height_cm numeric(5,2),
    weight_kg numeric(5,2),
    created_at timestamp without time zone DEFAULT now(),
    last_login timestamp with time zone,
    activity_level text,
    diet_type text,
    allergies text,
    health_goals text,
    goal_type text,
    goal_weight numeric,
    activity_factor numeric,
    bmr numeric,
    tdee numeric,
    daily_calorie_target numeric,
    daily_protein_target numeric,
    daily_fat_target numeric,
    daily_carb_target numeric,
    daily_water_target numeric,
    is_deleted boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    avatar_url text,
    CONSTRAINT "User_age_check" CHECK ((age > 0)),
    CONSTRAINT "User_gender_check" CHECK (((gender)::text = ANY ((ARRAY['male'::character varying, 'female'::character varying, 'other'::character varying])::text[]))),
    CONSTRAINT "User_height_cm_check" CHECK ((height_cm > (0)::numeric)),
    CONSTRAINT "User_weight_kg_check" CHECK ((weight_kg > (0)::numeric))
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- TOC entry 6579 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "User".avatar_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."User".avatar_url IS 'URL to user profile avatar image';


--
-- TOC entry 219 (class 1259 OID 21088)
-- Name: User_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."User_user_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."User_user_id_seq" OWNER TO postgres;

--
-- TOC entry 6580 (class 0 OID 0)
-- Dependencies: 219
-- Name: User_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."User_user_id_seq" OWNED BY public."User".user_id;


--
-- TOC entry 305 (class 1259 OID 22096)
-- Name: adminconversation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adminconversation (
    admin_conversation_id integer NOT NULL,
    user_id integer NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying,
    subject character varying(200),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT adminconversation_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'resolved'::character varying, 'archived'::character varying])::text[])))
);


ALTER TABLE public.adminconversation OWNER TO postgres;

--
-- TOC entry 6581 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE adminconversation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.adminconversation IS 'Conversation threads between users and admin support';


--
-- TOC entry 307 (class 1259 OID 22117)
-- Name: adminmessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adminmessage (
    admin_message_id integer NOT NULL,
    admin_conversation_id integer NOT NULL,
    sender_type character varying(20) NOT NULL,
    sender_id integer NOT NULL,
    message_text text,
    image_url text,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT adminmessage_sender_type_check CHECK (((sender_type)::text = ANY ((ARRAY['user'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.adminmessage OWNER TO postgres;

--
-- TOC entry 6582 (class 0 OID 0)
-- Dependencies: 307
-- Name: TABLE adminmessage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.adminmessage IS 'Messages in admin conversations, bidirectional user-admin chat';


--
-- TOC entry 311 (class 1259 OID 22168)
-- Name: active_admin_conversations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.active_admin_conversations AS
 SELECT admin_conversation_id,
    user_id,
    status,
    subject,
    created_at,
    updated_at,
    ( SELECT count(*) AS count
           FROM public.adminmessage
          WHERE ((adminmessage.admin_conversation_id = ac.admin_conversation_id) AND ((adminmessage.sender_type)::text = 'user'::text) AND (adminmessage.is_read = false))) AS unread_count,
    ( SELECT adminmessage.message_text
           FROM public.adminmessage
          WHERE (adminmessage.admin_conversation_id = ac.admin_conversation_id)
          ORDER BY adminmessage.created_at DESC
         LIMIT 1) AS last_message
   FROM public.adminconversation ac
  WHERE ((status)::text = 'active'::text)
  ORDER BY updated_at DESC;


ALTER VIEW public.active_admin_conversations OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 21160)
-- Name: admin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin (
    admin_id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    is_deleted boolean DEFAULT false
);


ALTER TABLE public.admin OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 21159)
-- Name: admin_admin_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_admin_id_seq OWNER TO postgres;

--
-- TOC entry 6583 (class 0 OID 0)
-- Dependencies: 225
-- Name: admin_admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_admin_id_seq OWNED BY public.admin.admin_id;


--
-- TOC entry 366 (class 1259 OID 22921)
-- Name: admin_verification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_verification (
    verification_id integer NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    code text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.admin_verification OWNER TO postgres;

--
-- TOC entry 365 (class 1259 OID 22920)
-- Name: admin_verification_verification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_verification_verification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_verification_verification_id_seq OWNER TO postgres;

--
-- TOC entry 6584 (class 0 OID 0)
-- Dependencies: 365
-- Name: admin_verification_verification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_verification_verification_id_seq OWNED BY public.admin_verification.verification_id;


--
-- TOC entry 304 (class 1259 OID 22095)
-- Name: adminconversation_admin_conversation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adminconversation_admin_conversation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adminconversation_admin_conversation_id_seq OWNER TO postgres;

--
-- TOC entry 6585 (class 0 OID 0)
-- Dependencies: 304
-- Name: adminconversation_admin_conversation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adminconversation_admin_conversation_id_seq OWNED BY public.adminconversation.admin_conversation_id;


--
-- TOC entry 306 (class 1259 OID 22116)
-- Name: adminmessage_admin_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adminmessage_admin_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adminmessage_admin_message_id_seq OWNER TO postgres;

--
-- TOC entry 6586 (class 0 OID 0)
-- Dependencies: 306
-- Name: adminmessage_admin_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adminmessage_admin_message_id_seq OWNED BY public.adminmessage.admin_message_id;


--
-- TOC entry 229 (class 1259 OID 21185)
-- Name: adminrole; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adminrole (
    admin_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE public.adminrole OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 21786)
-- Name: aminoacid; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aminoacid (
    amino_acid_id integer NOT NULL,
    code character varying(32) NOT NULL,
    name character varying(128) NOT NULL,
    hex_color character varying(7) NOT NULL,
    home_display boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.aminoacid OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 21785)
-- Name: aminoacid_amino_acid_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aminoacid_amino_acid_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aminoacid_amino_acid_id_seq OWNER TO postgres;

--
-- TOC entry 6587 (class 0 OID 0)
-- Dependencies: 277
-- Name: aminoacid_amino_acid_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aminoacid_amino_acid_id_seq OWNED BY public.aminoacid.amino_acid_id;


--
-- TOC entry 280 (class 1259 OID 21802)
-- Name: aminorequirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aminorequirement (
    amino_requirement_id integer NOT NULL,
    amino_acid_id integer NOT NULL,
    sex character varying(16) DEFAULT 'both'::character varying,
    age_min integer,
    age_max integer,
    per_kg boolean DEFAULT false NOT NULL,
    amount numeric NOT NULL,
    unit character varying(16) DEFAULT 'mg'::character varying,
    notes text
);


ALTER TABLE public.aminorequirement OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 21801)
-- Name: aminorequirement_amino_requirement_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aminorequirement_amino_requirement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aminorequirement_amino_requirement_id_seq OWNER TO postgres;

--
-- TOC entry 6588 (class 0 OID 0)
-- Dependencies: 279
-- Name: aminorequirement_amino_requirement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aminorequirement_amino_requirement_id_seq OWNED BY public.aminorequirement.amino_requirement_id;


--
-- TOC entry 299 (class 1259 OID 22030)
-- Name: bodymeasurement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bodymeasurement (
    measurement_id integer NOT NULL,
    user_id integer,
    measurement_date timestamp without time zone DEFAULT now(),
    weight_kg numeric(5,2),
    height_cm numeric(5,2),
    bmi numeric(4,2),
    bmi_score integer,
    bmi_category character varying(20),
    source character varying(50) DEFAULT 'manual'::character varying,
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT bodymeasurement_bmi_score_check CHECK (((bmi_score >= 1) AND (bmi_score <= 10))),
    CONSTRAINT bodymeasurement_height_cm_check CHECK ((height_cm > (0)::numeric)),
    CONSTRAINT bodymeasurement_weight_kg_check CHECK ((weight_kg > (0)::numeric))
);


ALTER TABLE public.bodymeasurement OWNER TO postgres;

--
-- TOC entry 6589 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE bodymeasurement; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.bodymeasurement IS 'Stores historical body measurements with automatic BMI calculation and health scoring';


--
-- TOC entry 6590 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN bodymeasurement.bmi_score; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.bodymeasurement.bmi_score IS 'Health score 1-10 where 10 is optimal BMI (21-25)';


--
-- TOC entry 6591 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN bodymeasurement.bmi_category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.bodymeasurement.bmi_category IS 'WHO BMI classification category';


--
-- TOC entry 298 (class 1259 OID 22029)
-- Name: bodymeasurement_measurement_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bodymeasurement_measurement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bodymeasurement_measurement_id_seq OWNER TO postgres;

--
-- TOC entry 6592 (class 0 OID 0)
-- Dependencies: 298
-- Name: bodymeasurement_measurement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bodymeasurement_measurement_id_seq OWNED BY public.bodymeasurement.measurement_id;


--
-- TOC entry 301 (class 1259 OID 22056)
-- Name: chatbotconversation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chatbotconversation (
    conversation_id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying(200) DEFAULT 'New conversation'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.chatbotconversation OWNER TO postgres;

--
-- TOC entry 6593 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE chatbotconversation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.chatbotconversation IS 'Stores chatbot conversation threads for each user';


--
-- TOC entry 300 (class 1259 OID 22055)
-- Name: chatbotconversation_conversation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chatbotconversation_conversation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chatbotconversation_conversation_id_seq OWNER TO postgres;

--
-- TOC entry 6594 (class 0 OID 0)
-- Dependencies: 300
-- Name: chatbotconversation_conversation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chatbotconversation_conversation_id_seq OWNED BY public.chatbotconversation.conversation_id;


--
-- TOC entry 303 (class 1259 OID 22075)
-- Name: chatbotmessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chatbotmessage (
    message_id integer NOT NULL,
    conversation_id integer NOT NULL,
    sender character varying(20) NOT NULL,
    message_text text,
    image_url text,
    nutrition_data jsonb,
    is_approved boolean,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT chatbotmessage_sender_check CHECK (((sender)::text = ANY ((ARRAY['user'::character varying, 'bot'::character varying])::text[])))
);


ALTER TABLE public.chatbotmessage OWNER TO postgres;

--
-- TOC entry 6595 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE chatbotmessage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.chatbotmessage IS 'Individual messages in chatbot conversations, supports text and images';


--
-- TOC entry 6596 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN chatbotmessage.nutrition_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.chatbotmessage.nutrition_data IS 'JSONB array of analyzed nutrients with IDs, names, amounts, units';


--
-- TOC entry 6597 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN chatbotmessage.is_approved; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.chatbotmessage.is_approved IS 'NULL=pending approval, TRUE=saved to daily totals, FALSE=rejected';


--
-- TOC entry 302 (class 1259 OID 22074)
-- Name: chatbotmessage_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chatbotmessage_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chatbotmessage_message_id_seq OWNER TO postgres;

--
-- TOC entry 6598 (class 0 OID 0)
-- Dependencies: 302
-- Name: chatbotmessage_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chatbotmessage_message_id_seq OWNED BY public.chatbotmessage.message_id;


--
-- TOC entry 398 (class 1259 OID 24508)
-- Name: communitymessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.communitymessage (
    message_id integer NOT NULL,
    user_id integer NOT NULL,
    message_text text,
    image_url text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    is_deleted boolean DEFAULT false,
    deleted_at timestamp without time zone
);


ALTER TABLE public.communitymessage OWNER TO postgres;

--
-- TOC entry 6599 (class 0 OID 0)
-- Dependencies: 398
-- Name: TABLE communitymessage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.communitymessage IS 'Public community chat messages where users share experiences';


--
-- TOC entry 400 (class 1259 OID 24530)
-- Name: messagereaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messagereaction (
    reaction_id integer NOT NULL,
    message_type character varying(20) NOT NULL,
    message_id integer NOT NULL,
    user_id integer NOT NULL,
    reaction_type character varying(20) DEFAULT 'like'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT messagereaction_message_type_check CHECK (((message_type)::text = ANY ((ARRAY['community'::character varying, 'private'::character varying, 'chatbot'::character varying, 'admin'::character varying])::text[]))),
    CONSTRAINT messagereaction_reaction_type_check CHECK (((reaction_type)::text = ANY ((ARRAY['like'::character varying, 'love'::character varying, 'laugh'::character varying, 'wow'::character varying, 'sad'::character varying, 'angry'::character varying])::text[])))
);


ALTER TABLE public.messagereaction OWNER TO postgres;

--
-- TOC entry 6600 (class 0 OID 0)
-- Dependencies: 400
-- Name: TABLE messagereaction; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.messagereaction IS 'Reactions to messages (community, private, chatbot, admin)';


--
-- TOC entry 6601 (class 0 OID 0)
-- Dependencies: 400
-- Name: COLUMN messagereaction.message_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.messagereaction.message_type IS 'community, private, chatbot, or admin';


--
-- TOC entry 6602 (class 0 OID 0)
-- Dependencies: 400
-- Name: COLUMN messagereaction.reaction_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.messagereaction.reaction_type IS 'like, love, laugh, wow, sad, or angry';


--
-- TOC entry 405 (class 1259 OID 24613)
-- Name: community_messages_with_user_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.community_messages_with_user_info AS
 SELECT cm.message_id,
    cm.user_id,
    u.full_name AS username,
    u.avatar_url,
    u.gender,
    cm.message_text,
    cm.image_url,
    cm.created_at,
    cm.updated_at,
    ( SELECT count(*) AS count
           FROM public.messagereaction mr
          WHERE (((mr.message_type)::text = 'community'::text) AND (mr.message_id = cm.message_id))) AS reaction_count
   FROM (public.communitymessage cm
     JOIN public."User" u ON ((u.user_id = cm.user_id)))
  WHERE (cm.is_deleted = false)
  ORDER BY cm.created_at DESC;


ALTER VIEW public.community_messages_with_user_info OWNER TO postgres;

--
-- TOC entry 397 (class 1259 OID 24507)
-- Name: communitymessage_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.communitymessage_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.communitymessage_message_id_seq OWNER TO postgres;

--
-- TOC entry 6603 (class 0 OID 0)
-- Dependencies: 397
-- Name: communitymessage_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.communitymessage_message_id_seq OWNED BY public.communitymessage.message_id;


--
-- TOC entry 327 (class 1259 OID 22361)
-- Name: conditioneffectlog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conditioneffectlog (
    log_id integer NOT NULL,
    user_id integer,
    condition_id integer,
    nutrient_id integer,
    effect_type character varying(10),
    adjustment_percent numeric(5,2),
    original_rda numeric(10,2),
    adjusted_rda numeric(10,2),
    applied_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.conditioneffectlog OWNER TO postgres;

--
-- TOC entry 326 (class 1259 OID 22360)
-- Name: conditioneffectlog_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conditioneffectlog_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conditioneffectlog_log_id_seq OWNER TO postgres;

--
-- TOC entry 6604 (class 0 OID 0)
-- Dependencies: 326
-- Name: conditioneffectlog_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conditioneffectlog_log_id_seq OWNED BY public.conditioneffectlog.log_id;


--
-- TOC entry 325 (class 1259 OID 22337)
-- Name: conditionfoodrecommendation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conditionfoodrecommendation (
    recommendation_id integer NOT NULL,
    condition_id integer,
    food_id integer,
    recommendation_type character varying(10) DEFAULT 'avoid'::character varying,
    notes text,
    CONSTRAINT conditionfoodrecommendation_recommendation_type_check CHECK (((recommendation_type)::text = ANY ((ARRAY['recommend'::character varying, 'avoid'::character varying])::text[])))
);


ALTER TABLE public.conditionfoodrecommendation OWNER TO postgres;

--
-- TOC entry 6605 (class 0 OID 0)
-- Dependencies: 325
-- Name: TABLE conditionfoodrecommendation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.conditionfoodrecommendation IS 'Thực phẩm nên ăn/tránh cho từng bệnh';


--
-- TOC entry 324 (class 1259 OID 22336)
-- Name: conditionfoodrecommendation_recommendation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conditionfoodrecommendation_recommendation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conditionfoodrecommendation_recommendation_id_seq OWNER TO postgres;

--
-- TOC entry 6606 (class 0 OID 0)
-- Dependencies: 324
-- Name: conditionfoodrecommendation_recommendation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conditionfoodrecommendation_recommendation_id_seq OWNED BY public.conditionfoodrecommendation.recommendation_id;


--
-- TOC entry 323 (class 1259 OID 22313)
-- Name: conditionnutrienteffect; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conditionnutrienteffect (
    effect_id integer NOT NULL,
    condition_id integer,
    nutrient_id integer,
    effect_type character varying(10),
    adjustment_percent numeric(5,2) NOT NULL,
    notes text,
    CONSTRAINT conditionnutrienteffect_effect_type_check CHECK (((effect_type)::text = ANY ((ARRAY['increase'::character varying, 'decrease'::character varying])::text[])))
);


ALTER TABLE public.conditionnutrienteffect OWNER TO postgres;

--
-- TOC entry 6607 (class 0 OID 0)
-- Dependencies: 323
-- Name: TABLE conditionnutrienteffect; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.conditionnutrienteffect IS 'Hiệu ứng dinh dưỡng của từng bệnh';


--
-- TOC entry 322 (class 1259 OID 22312)
-- Name: conditionnutrienteffect_effect_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conditionnutrienteffect_effect_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conditionnutrienteffect_effect_id_seq OWNER TO postgres;

--
-- TOC entry 6608 (class 0 OID 0)
-- Dependencies: 322
-- Name: conditionnutrienteffect_effect_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conditionnutrienteffect_effect_id_seq OWNED BY public.conditionnutrienteffect.effect_id;


--
-- TOC entry 246 (class 1259 OID 21334)
-- Name: dailysummary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dailysummary (
    summary_id integer NOT NULL,
    user_id integer,
    date date NOT NULL,
    total_calories numeric(10,2) DEFAULT 0,
    total_protein numeric(10,2) DEFAULT 0,
    total_fiber numeric(10,2) DEFAULT 0,
    total_carbs numeric(10,2) DEFAULT 0,
    total_fat numeric(10,2) DEFAULT 0,
    total_water numeric(10,2) DEFAULT 0
);


ALTER TABLE public.dailysummary OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 21333)
-- Name: dailysummary_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dailysummary_summary_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dailysummary_summary_id_seq OWNER TO postgres;

--
-- TOC entry 6609 (class 0 OID 0)
-- Dependencies: 245
-- Name: dailysummary_summary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dailysummary_summary_id_seq OWNED BY public.dailysummary.summary_id;


--
-- TOC entry 350 (class 1259 OID 22682)
-- Name: dish; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dish (
    dish_id integer NOT NULL,
    name character varying(200) NOT NULL,
    vietnamese_name character varying(200),
    description text,
    category character varying(50),
    serving_size_g numeric(10,2) DEFAULT 100,
    image_url text,
    is_template boolean DEFAULT false,
    is_public boolean DEFAULT true,
    created_by_user integer,
    created_by_admin integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    image_urls jsonb DEFAULT '[]'::jsonb,
    CONSTRAINT dish_check CHECK ((((created_by_user IS NOT NULL) AND (created_by_admin IS NULL)) OR ((created_by_user IS NULL) AND (created_by_admin IS NOT NULL)))),
    CONSTRAINT dish_serving_size_g_check CHECK ((serving_size_g > (0)::numeric))
);


ALTER TABLE public.dish OWNER TO postgres;

--
-- TOC entry 6610 (class 0 OID 0)
-- Dependencies: 350
-- Name: TABLE dish; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dish IS 'Stores complete dish/recipe definitions composed of multiple foods';


--
-- TOC entry 6611 (class 0 OID 0)
-- Dependencies: 350
-- Name: COLUMN dish.is_template; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dish.is_template IS 'True for admin-created standard dishes available to all users';


--
-- TOC entry 6612 (class 0 OID 0)
-- Dependencies: 350
-- Name: COLUMN dish.is_public; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dish.is_public IS 'False for user private dishes, true for shared dishes';


--
-- TOC entry 349 (class 1259 OID 22681)
-- Name: dish_dish_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dish_dish_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dish_dish_id_seq OWNER TO postgres;

--
-- TOC entry 6613 (class 0 OID 0)
-- Dependencies: 349
-- Name: dish_dish_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dish_dish_id_seq OWNED BY public.dish.dish_id;


--
-- TOC entry 358 (class 1259 OID 22797)
-- Name: dishnutrient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishnutrient (
    dish_nutrient_id integer NOT NULL,
    dish_id integer NOT NULL,
    nutrient_id integer NOT NULL,
    amount_per_100g numeric(12,6) DEFAULT 0,
    calculated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.dishnutrient OWNER TO postgres;

--
-- TOC entry 6614 (class 0 OID 0)
-- Dependencies: 358
-- Name: TABLE dishnutrient; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dishnutrient IS 'Pre-calculated nutrient values per 100g of complete dish';


--
-- TOC entry 6615 (class 0 OID 0)
-- Dependencies: 358
-- Name: COLUMN dishnutrient.amount_per_100g; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dishnutrient.amount_per_100g IS 'Nutrient amount per 100g of the complete dish (calculated from ingredients)';


--
-- TOC entry 233 (class 1259 OID 21220)
-- Name: nutrient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nutrient (
    nutrient_id integer NOT NULL,
    name character varying(100) NOT NULL,
    nutrient_code character varying(50),
    unit character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    created_by_admin integer,
    group_name character varying(50),
    image_url text,
    benefits text,
    name_vi character varying(255)
);


ALTER TABLE public.nutrient OWNER TO postgres;

--
-- TOC entry 360 (class 1259 OID 22836)
-- Name: dish_with_macros; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.dish_with_macros AS
 SELECT d.dish_id,
    d.name,
    d.category,
    d.serving_size_g,
    d.is_template,
    COALESCE(kcal.amount_per_100g, (0)::numeric) AS calories_per_100g,
    COALESCE(prot.amount_per_100g, (0)::numeric) AS protein_per_100g,
    COALESCE(fat.amount_per_100g, (0)::numeric) AS fat_per_100g,
    COALESCE(carb.amount_per_100g, (0)::numeric) AS carbs_per_100g
   FROM ((((public.dish d
     LEFT JOIN ( SELECT dn.dish_id,
            dn.amount_per_100g
           FROM (public.dishnutrient dn
             JOIN public.nutrient n ON ((n.nutrient_id = dn.nutrient_id)))
          WHERE ((n.nutrient_code)::text = 'ENERC_KCAL'::text)) kcal ON ((kcal.dish_id = d.dish_id)))
     LEFT JOIN ( SELECT dn.dish_id,
            dn.amount_per_100g
           FROM (public.dishnutrient dn
             JOIN public.nutrient n ON ((n.nutrient_id = dn.nutrient_id)))
          WHERE ((n.nutrient_code)::text = 'PROCNT'::text)) prot ON ((prot.dish_id = d.dish_id)))
     LEFT JOIN ( SELECT dn.dish_id,
            dn.amount_per_100g
           FROM (public.dishnutrient dn
             JOIN public.nutrient n ON ((n.nutrient_id = dn.nutrient_id)))
          WHERE ((n.nutrient_code)::text = 'FAT'::text)) fat ON ((fat.dish_id = d.dish_id)))
     LEFT JOIN ( SELECT dn.dish_id,
            dn.amount_per_100g
           FROM (public.dishnutrient dn
             JOIN public.nutrient n ON ((n.nutrient_id = dn.nutrient_id)))
          WHERE ((n.nutrient_code)::text = 'CHOCDF'::text)) carb ON ((carb.dish_id = d.dish_id)));


ALTER VIEW public.dish_with_macros OWNER TO postgres;

--
-- TOC entry 356 (class 1259 OID 22776)
-- Name: dishstatistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishstatistics (
    stat_id integer NOT NULL,
    dish_id integer NOT NULL,
    total_times_logged integer DEFAULT 0,
    unique_users_count integer DEFAULT 0,
    avg_rating numeric(3,2),
    last_logged_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.dishstatistics OWNER TO postgres;

--
-- TOC entry 6616 (class 0 OID 0)
-- Dependencies: 356
-- Name: TABLE dishstatistics; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dishstatistics IS 'Cached usage statistics for admin dashboard analytics';


--
-- TOC entry 359 (class 1259 OID 22831)
-- Name: dish_with_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.dish_with_stats AS
 SELECT d.dish_id,
    d.name,
    d.vietnamese_name,
    d.description,
    d.category,
    d.serving_size_g,
    d.image_url,
    d.is_template,
    d.is_public,
    d.created_by_user,
    d.created_by_admin,
    d.created_at,
    d.updated_at,
    COALESCE(ds.total_times_logged, 0) AS times_logged,
    COALESCE(ds.unique_users_count, 0) AS unique_users,
    ds.last_logged_at,
    public.get_dish_ingredient_count(d.dish_id) AS ingredient_count,
    public.get_dish_total_weight(d.dish_id) AS total_weight_g
   FROM (public.dish d
     LEFT JOIN public.dishstatistics ds ON ((ds.dish_id = d.dish_id)));


ALTER VIEW public.dish_with_stats OWNER TO postgres;

--
-- TOC entry 354 (class 1259 OID 22746)
-- Name: dishimage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishimage (
    dish_image_id integer NOT NULL,
    dish_id integer NOT NULL,
    image_url text NOT NULL,
    image_type character varying(20) DEFAULT 'photo'::character varying,
    is_primary boolean DEFAULT false,
    display_order integer DEFAULT 0,
    caption text,
    uploaded_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.dishimage OWNER TO postgres;

--
-- TOC entry 6617 (class 0 OID 0)
-- Dependencies: 354
-- Name: TABLE dishimage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dishimage IS 'Stores multiple images per dish for UI display';


--
-- TOC entry 353 (class 1259 OID 22745)
-- Name: dishimage_dish_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dishimage_dish_image_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dishimage_dish_image_id_seq OWNER TO postgres;

--
-- TOC entry 6618 (class 0 OID 0)
-- Dependencies: 353
-- Name: dishimage_dish_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dishimage_dish_image_id_seq OWNED BY public.dishimage.dish_image_id;


--
-- TOC entry 352 (class 1259 OID 22716)
-- Name: dishingredient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishingredient (
    dish_ingredient_id integer NOT NULL,
    dish_id integer NOT NULL,
    food_id integer NOT NULL,
    weight_g numeric(10,2) NOT NULL,
    notes text,
    display_order integer DEFAULT 0,
    CONSTRAINT dishingredient_weight_g_check CHECK ((weight_g > (0)::numeric))
);


ALTER TABLE public.dishingredient OWNER TO postgres;

--
-- TOC entry 6619 (class 0 OID 0)
-- Dependencies: 352
-- Name: TABLE dishingredient; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dishingredient IS 'Junction table mapping dishes to their ingredient foods with weights';


--
-- TOC entry 6620 (class 0 OID 0)
-- Dependencies: 352
-- Name: COLUMN dishingredient.weight_g; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dishingredient.weight_g IS 'Weight in grams of this ingredient in the dish recipe';


--
-- TOC entry 351 (class 1259 OID 22715)
-- Name: dishingredient_dish_ingredient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dishingredient_dish_ingredient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dishingredient_dish_ingredient_id_seq OWNER TO postgres;

--
-- TOC entry 6621 (class 0 OID 0)
-- Dependencies: 351
-- Name: dishingredient_dish_ingredient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dishingredient_dish_ingredient_id_seq OWNED BY public.dishingredient.dish_ingredient_id;


--
-- TOC entry 362 (class 1259 OID 22843)
-- Name: dishnotification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishnotification (
    notification_id integer NOT NULL,
    user_id integer,
    dish_id integer,
    notification_type character varying(50) NOT NULL,
    title character varying(200) NOT NULL,
    message text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    read_at timestamp without time zone
);


ALTER TABLE public.dishnotification OWNER TO postgres;

--
-- TOC entry 361 (class 1259 OID 22842)
-- Name: dishnotification_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dishnotification_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dishnotification_notification_id_seq OWNER TO postgres;

--
-- TOC entry 6622 (class 0 OID 0)
-- Dependencies: 361
-- Name: dishnotification_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dishnotification_notification_id_seq OWNED BY public.dishnotification.notification_id;


--
-- TOC entry 357 (class 1259 OID 22796)
-- Name: dishnutrient_dish_nutrient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dishnutrient_dish_nutrient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dishnutrient_dish_nutrient_id_seq OWNER TO postgres;

--
-- TOC entry 6623 (class 0 OID 0)
-- Dependencies: 357
-- Name: dishnutrient_dish_nutrient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dishnutrient_dish_nutrient_id_seq OWNED BY public.dishnutrient.dish_nutrient_id;


--
-- TOC entry 355 (class 1259 OID 22775)
-- Name: dishstatistics_stat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dishstatistics_stat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dishstatistics_stat_id_seq OWNER TO postgres;

--
-- TOC entry 6624 (class 0 OID 0)
-- Dependencies: 355
-- Name: dishstatistics_stat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dishstatistics_stat_id_seq OWNED BY public.dishstatistics.stat_id;


--
-- TOC entry 379 (class 1259 OID 23793)
-- Name: drink; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drink (
    drink_id integer NOT NULL,
    name character varying(200) NOT NULL,
    vietnamese_name character varying(200),
    slug character varying(120),
    description text,
    category character varying(50),
    base_liquid character varying(100),
    default_volume_ml numeric(10,2) DEFAULT 250,
    default_temperature character varying(20) DEFAULT 'cold'::character varying,
    default_sweetness character varying(20) DEFAULT 'normal'::character varying,
    hydration_ratio numeric(5,2) DEFAULT 1.0,
    caffeine_mg numeric(8,2) DEFAULT 0,
    sugar_free boolean DEFAULT false,
    is_template boolean DEFAULT true,
    is_public boolean DEFAULT true,
    image_url text,
    created_by_user integer,
    created_by_admin integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT drink_default_volume_ml_check CHECK ((default_volume_ml > (0)::numeric)),
    CONSTRAINT drink_hydration_ratio_check CHECK (((hydration_ratio >= (0)::numeric) AND (hydration_ratio <= 1.2)))
);


ALTER TABLE public.drink OWNER TO postgres;

--
-- TOC entry 378 (class 1259 OID 23792)
-- Name: drink_drink_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drink_drink_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drink_drink_id_seq OWNER TO postgres;

--
-- TOC entry 6625 (class 0 OID 0)
-- Dependencies: 378
-- Name: drink_drink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drink_drink_id_seq OWNED BY public.drink.drink_id;


--
-- TOC entry 381 (class 1259 OID 23831)
-- Name: drinkingredient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drinkingredient (
    drink_ingredient_id integer NOT NULL,
    drink_id integer NOT NULL,
    food_id integer NOT NULL,
    amount_g numeric(10,2) NOT NULL,
    unit character varying(16) DEFAULT 'g'::character varying,
    display_order integer DEFAULT 0,
    notes text,
    CONSTRAINT drinkingredient_amount_g_check CHECK ((amount_g > (0)::numeric))
);


ALTER TABLE public.drinkingredient OWNER TO postgres;

--
-- TOC entry 380 (class 1259 OID 23830)
-- Name: drinkingredient_drink_ingredient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drinkingredient_drink_ingredient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drinkingredient_drink_ingredient_id_seq OWNER TO postgres;

--
-- TOC entry 6626 (class 0 OID 0)
-- Dependencies: 380
-- Name: drinkingredient_drink_ingredient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drinkingredient_drink_ingredient_id_seq OWNED BY public.drinkingredient.drink_ingredient_id;


--
-- TOC entry 383 (class 1259 OID 23861)
-- Name: drinknutrient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drinknutrient (
    drink_nutrient_id integer NOT NULL,
    drink_id integer NOT NULL,
    nutrient_id integer NOT NULL,
    amount_per_100ml numeric(12,6) DEFAULT 0
);


ALTER TABLE public.drinknutrient OWNER TO postgres;

--
-- TOC entry 382 (class 1259 OID 23860)
-- Name: drinknutrient_drink_nutrient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drinknutrient_drink_nutrient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drinknutrient_drink_nutrient_id_seq OWNER TO postgres;

--
-- TOC entry 6627 (class 0 OID 0)
-- Dependencies: 382
-- Name: drinknutrient_drink_nutrient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drinknutrient_drink_nutrient_id_seq OWNED BY public.drinknutrient.drink_nutrient_id;


--
-- TOC entry 385 (class 1259 OID 23886)
-- Name: drinkstatistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drinkstatistics (
    stat_id integer NOT NULL,
    drink_id integer NOT NULL,
    log_count integer DEFAULT 0,
    unique_users integer DEFAULT 0,
    last_logged_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.drinkstatistics OWNER TO postgres;

--
-- TOC entry 384 (class 1259 OID 23885)
-- Name: drinkstatistics_stat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drinkstatistics_stat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drinkstatistics_stat_id_seq OWNER TO postgres;

--
-- TOC entry 6628 (class 0 OID 0)
-- Dependencies: 384
-- Name: drinkstatistics_stat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drinkstatistics_stat_id_seq OWNED BY public.drinkstatistics.stat_id;


--
-- TOC entry 387 (class 1259 OID 23970)
-- Name: drug; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drug (
    drug_id integer NOT NULL,
    name_vi character varying(200) NOT NULL,
    name_en character varying(200),
    generic_name character varying(200),
    drug_class character varying(100),
    description text,
    image_url text,
    source_link text,
    dosage_form character varying(50),
    is_active boolean DEFAULT true,
    created_by_admin integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    description_vi text
);


ALTER TABLE public.drug OWNER TO postgres;

--
-- TOC entry 6629 (class 0 OID 0)
-- Dependencies: 387
-- Name: TABLE drug; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.drug IS 'Bảng quản lý thuốc - Admin quản lý';


--
-- TOC entry 386 (class 1259 OID 23969)
-- Name: drug_drug_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drug_drug_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drug_drug_id_seq OWNER TO postgres;

--
-- TOC entry 6630 (class 0 OID 0)
-- Dependencies: 386
-- Name: drug_drug_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drug_drug_id_seq OWNED BY public.drug.drug_id;


--
-- TOC entry 389 (class 1259 OID 23991)
-- Name: drughealthcondition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drughealthcondition (
    drug_condition_id integer NOT NULL,
    drug_id integer NOT NULL,
    condition_id integer NOT NULL,
    treatment_notes text,
    is_primary boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    treatment_notes_vi text
);


ALTER TABLE public.drughealthcondition OWNER TO postgres;

--
-- TOC entry 6631 (class 0 OID 0)
-- Dependencies: 389
-- Name: TABLE drughealthcondition; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.drughealthcondition IS 'Liên kết thuốc với bệnh điều trị';


--
-- TOC entry 388 (class 1259 OID 23990)
-- Name: drughealthcondition_drug_condition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drughealthcondition_drug_condition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drughealthcondition_drug_condition_id_seq OWNER TO postgres;

--
-- TOC entry 6632 (class 0 OID 0)
-- Dependencies: 388
-- Name: drughealthcondition_drug_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drughealthcondition_drug_condition_id_seq OWNED BY public.drughealthcondition.drug_condition_id;


--
-- TOC entry 391 (class 1259 OID 24019)
-- Name: drugnutrientcontraindication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drugnutrientcontraindication (
    contra_id integer NOT NULL,
    drug_id integer NOT NULL,
    nutrient_id integer NOT NULL,
    avoid_hours_before numeric(5,2) DEFAULT 0,
    avoid_hours_after numeric(5,2) DEFAULT 2,
    warning_message_vi text,
    warning_message_en text,
    severity character varying(20) DEFAULT 'moderate'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.drugnutrientcontraindication OWNER TO postgres;

--
-- TOC entry 6633 (class 0 OID 0)
-- Dependencies: 391
-- Name: TABLE drugnutrientcontraindication; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.drugnutrientcontraindication IS 'Tác dụng phụ: thuốc kỵ chất dinh dưỡng nào, trong bao lâu';


--
-- TOC entry 390 (class 1259 OID 24018)
-- Name: drugnutrientcontraindication_contra_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drugnutrientcontraindication_contra_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drugnutrientcontraindication_contra_id_seq OWNER TO postgres;

--
-- TOC entry 6634 (class 0 OID 0)
-- Dependencies: 390
-- Name: drugnutrientcontraindication_contra_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drugnutrientcontraindication_contra_id_seq OWNED BY public.drugnutrientcontraindication.contra_id;


--
-- TOC entry 392 (class 1259 OID 24063)
-- Name: drugstatistics; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.drugstatistics AS
 SELECT count(*) FILTER (WHERE (d.is_active = true)) AS active_drugs,
    count(*) FILTER (WHERE (d.is_active = false)) AS inactive_drugs,
    count(*) AS total_drugs,
    count(DISTINCT dhc.condition_id) AS conditions_covered
   FROM (public.drug d
     LEFT JOIN public.drughealthcondition dhc ON ((dhc.drug_id = d.drug_id)));


ALTER VIEW public.drugstatistics OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 21624)
-- Name: fattyacid; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fattyacid (
    fatty_acid_id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    unit character varying(20) DEFAULT 'g'::character varying,
    hex_color character varying(7),
    home_display boolean DEFAULT false,
    is_user_editable boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.fattyacid OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 21623)
-- Name: fattyacid_fatty_acid_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fattyacid_fatty_acid_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fattyacid_fatty_acid_id_seq OWNER TO postgres;

--
-- TOC entry 6635 (class 0 OID 0)
-- Dependencies: 263
-- Name: fattyacid_fatty_acid_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fattyacid_fatty_acid_id_seq OWNED BY public.fattyacid.fatty_acid_id;


--
-- TOC entry 268 (class 1259 OID 21660)
-- Name: fattyacidrequirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fattyacidrequirement (
    fa_req_id integer NOT NULL,
    fatty_acid_id integer,
    sex character varying(10),
    age_min integer,
    age_max integer,
    base_value numeric(12,6),
    unit character varying(20) DEFAULT 'g'::character varying,
    is_per_kg boolean DEFAULT false,
    is_energy_pct boolean DEFAULT false,
    energy_pct numeric(6,4),
    notes text
);


ALTER TABLE public.fattyacidrequirement OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 21659)
-- Name: fattyacidrequirement_fa_req_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fattyacidrequirement_fa_req_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fattyacidrequirement_fa_req_id_seq OWNER TO postgres;

--
-- TOC entry 6636 (class 0 OID 0)
-- Dependencies: 267
-- Name: fattyacidrequirement_fa_req_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fattyacidrequirement_fa_req_id_seq OWNED BY public.fattyacidrequirement.fa_req_id;


--
-- TOC entry 262 (class 1259 OID 21606)
-- Name: fiber; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fiber (
    fiber_id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    unit character varying(20) DEFAULT 'g'::character varying,
    hex_color character varying(7),
    home_display boolean DEFAULT false,
    is_user_editable boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.fiber OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 21605)
-- Name: fiber_fiber_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fiber_fiber_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fiber_fiber_id_seq OWNER TO postgres;

--
-- TOC entry 6637 (class 0 OID 0)
-- Dependencies: 261
-- Name: fiber_fiber_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fiber_fiber_id_seq OWNED BY public.fiber.fiber_id;


--
-- TOC entry 266 (class 1259 OID 21642)
-- Name: fiberrequirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fiberrequirement (
    fiber_req_id integer NOT NULL,
    fiber_id integer,
    sex character varying(10),
    age_min integer,
    age_max integer,
    base_value numeric(10,6),
    unit character varying(20) DEFAULT 'g'::character varying,
    is_per_kg boolean DEFAULT false,
    is_energy_pct boolean DEFAULT false,
    energy_pct numeric(6,4),
    notes text
);


ALTER TABLE public.fiberrequirement OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 21641)
-- Name: fiberrequirement_fiber_req_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fiberrequirement_fiber_req_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fiberrequirement_fiber_req_id_seq OWNER TO postgres;

--
-- TOC entry 6638 (class 0 OID 0)
-- Dependencies: 265
-- Name: fiberrequirement_fiber_req_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fiberrequirement_fiber_req_id_seq OWNED BY public.fiberrequirement.fiber_req_id;


--
-- TOC entry 231 (class 1259 OID 21203)
-- Name: food; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.food (
    food_id integer NOT NULL,
    name character varying(100) NOT NULL,
    category character varying(50),
    image_url text,
    created_at timestamp without time zone DEFAULT now(),
    created_by_admin integer,
    description text,
    serving_size_g numeric(10,2) DEFAULT 100.00,
    is_verified boolean DEFAULT false,
    is_active boolean DEFAULT true,
    updated_at timestamp without time zone DEFAULT now(),
    created_by_user integer,
    name_vi character varying(255)
);


ALTER TABLE public.food OWNER TO postgres;

--
-- TOC entry 6639 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN food.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.food.description IS 'Detailed description of the food item';


--
-- TOC entry 6640 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN food.serving_size_g; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.food.serving_size_g IS 'Standard serving size in grams';


--
-- TOC entry 6641 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN food.is_verified; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.food.is_verified IS 'Whether the food data has been verified by admin';


--
-- TOC entry 6642 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN food.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.food.is_active IS 'Whether the food is active and available for selection';


--
-- TOC entry 6643 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN food.created_by_user; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.food.created_by_user IS 'User who created this food item (for user-contributed foods)';


--
-- TOC entry 230 (class 1259 OID 21202)
-- Name: food_food_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.food_food_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.food_food_id_seq OWNER TO postgres;

--
-- TOC entry 6644 (class 0 OID 0)
-- Dependencies: 230
-- Name: food_food_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.food_food_id_seq OWNED BY public.food.food_id;


--
-- TOC entry 313 (class 1259 OID 22192)
-- Name: foodcategory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.foodcategory (
    category_id integer NOT NULL,
    category_name character varying(100) NOT NULL,
    description text,
    icon character varying(50),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.foodcategory OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 22191)
-- Name: foodcategory_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.foodcategory_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.foodcategory_category_id_seq OWNER TO postgres;

--
-- TOC entry 6645 (class 0 OID 0)
-- Dependencies: 312
-- Name: foodcategory_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.foodcategory_category_id_seq OWNED BY public.foodcategory.category_id;


--
-- TOC entry 235 (class 1259 OID 21236)
-- Name: foodnutrient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.foodnutrient (
    food_nutrient_id integer NOT NULL,
    food_id integer,
    nutrient_id integer,
    amount_per_100g numeric(10,2) NOT NULL,
    CONSTRAINT foodnutrient_amount_per_100g_check CHECK ((amount_per_100g >= (0)::numeric))
);


ALTER TABLE public.foodnutrient OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 21235)
-- Name: foodnutrient_food_nutrient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.foodnutrient_food_nutrient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.foodnutrient_food_nutrient_id_seq OWNER TO postgres;

--
-- TOC entry 6646 (class 0 OID 0)
-- Dependencies: 234
-- Name: foodnutrient_food_nutrient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.foodnutrient_food_nutrient_id_seq OWNED BY public.foodnutrient.food_nutrient_id;


--
-- TOC entry 237 (class 1259 OID 21256)
-- Name: foodtag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.foodtag (
    tag_id integer NOT NULL,
    tag_name character varying(50) NOT NULL
);


ALTER TABLE public.foodtag OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 21255)
-- Name: foodtag_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.foodtag_tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.foodtag_tag_id_seq OWNER TO postgres;

--
-- TOC entry 6647 (class 0 OID 0)
-- Dependencies: 236
-- Name: foodtag_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.foodtag_tag_id_seq OWNED BY public.foodtag.tag_id;


--
-- TOC entry 238 (class 1259 OID 21264)
-- Name: foodtagmapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.foodtagmapping (
    food_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.foodtagmapping OWNER TO postgres;

--
-- TOC entry 394 (class 1259 OID 24449)
-- Name: friendrequest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friendrequest (
    request_id integer NOT NULL,
    sender_id integer NOT NULL,
    receiver_id integer NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT friendrequest_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'accepted'::character varying, 'rejected'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.friendrequest OWNER TO postgres;

--
-- TOC entry 6648 (class 0 OID 0)
-- Dependencies: 394
-- Name: TABLE friendrequest; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.friendrequest IS 'Friend requests between users with status tracking';


--
-- TOC entry 6649 (class 0 OID 0)
-- Dependencies: 394
-- Name: COLUMN friendrequest.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.friendrequest.status IS 'pending, accepted, rejected, or cancelled';


--
-- TOC entry 393 (class 1259 OID 24448)
-- Name: friendrequest_request_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.friendrequest_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.friendrequest_request_id_seq OWNER TO postgres;

--
-- TOC entry 6650 (class 0 OID 0)
-- Dependencies: 393
-- Name: friendrequest_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.friendrequest_request_id_seq OWNED BY public.friendrequest.request_id;


--
-- TOC entry 396 (class 1259 OID 24479)
-- Name: friendship; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friendship (
    friendship_id integer NOT NULL,
    user1_id integer NOT NULL,
    user2_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT friendship_check CHECK ((user1_id < user2_id))
);


ALTER TABLE public.friendship OWNER TO postgres;

--
-- TOC entry 6651 (class 0 OID 0)
-- Dependencies: 396
-- Name: TABLE friendship; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.friendship IS 'Confirmed friendships (bidirectional, user1_id < user2_id)';


--
-- TOC entry 395 (class 1259 OID 24478)
-- Name: friendship_friendship_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.friendship_friendship_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.friendship_friendship_id_seq OWNER TO postgres;

--
-- TOC entry 6652 (class 0 OID 0)
-- Dependencies: 395
-- Name: friendship_friendship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.friendship_friendship_id_seq OWNED BY public.friendship.friendship_id;


--
-- TOC entry 315 (class 1259 OID 22226)
-- Name: healthcondition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.healthcondition (
    condition_id integer NOT NULL,
    name_vi character varying(200) NOT NULL,
    name_en character varying(200) NOT NULL,
    category character varying(100),
    description text,
    causes text,
    image_url text,
    treatment_duration_reference character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    condition_code character varying(50),
    condition_name character varying(200),
    description_vi text
);


ALTER TABLE public.healthcondition OWNER TO postgres;

--
-- TOC entry 6653 (class 0 OID 0)
-- Dependencies: 315
-- Name: TABLE healthcondition; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.healthcondition IS 'Danh sách các bệnh/tình trạng sức khỏe';


--
-- TOC entry 314 (class 1259 OID 22225)
-- Name: healthcondition_condition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.healthcondition_condition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.healthcondition_condition_id_seq OWNER TO postgres;

--
-- TOC entry 6654 (class 0 OID 0)
-- Dependencies: 314
-- Name: healthcondition_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.healthcondition_condition_id_seq OWNED BY public.healthcondition.condition_id;


--
-- TOC entry 240 (class 1259 OID 21282)
-- Name: meal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meal (
    meal_id integer NOT NULL,
    user_id integer,
    meal_type character varying(20),
    meal_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    is_favorite boolean DEFAULT false,
    notes text,
    photo_url text,
    photo_recognition_data jsonb,
    CONSTRAINT meal_meal_type_check CHECK (((meal_type)::text = ANY ((ARRAY['breakfast'::character varying, 'lunch'::character varying, 'dinner'::character varying, 'snack'::character varying])::text[])))
);


ALTER TABLE public.meal OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 21890)
-- Name: meal_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meal_entries (
    id integer NOT NULL,
    user_id integer NOT NULL,
    entry_date date DEFAULT CURRENT_DATE NOT NULL,
    meal_type character varying(16) NOT NULL,
    food_id integer,
    weight_g numeric(10,2),
    kcal numeric(10,2) DEFAULT 0,
    carbs numeric(10,2) DEFAULT 0,
    protein numeric(10,2) DEFAULT 0,
    fat numeric(10,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.meal_entries OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 21889)
-- Name: meal_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meal_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.meal_entries_id_seq OWNER TO postgres;

--
-- TOC entry 6655 (class 0 OID 0)
-- Dependencies: 286
-- Name: meal_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meal_entries_id_seq OWNED BY public.meal_entries.id;


--
-- TOC entry 239 (class 1259 OID 21281)
-- Name: meal_meal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meal_meal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.meal_meal_id_seq OWNER TO postgres;

--
-- TOC entry 6656 (class 0 OID 0)
-- Dependencies: 239
-- Name: meal_meal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meal_meal_id_seq OWNED BY public.meal.meal_id;


--
-- TOC entry 242 (class 1259 OID 21298)
-- Name: mealitem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mealitem (
    meal_item_id integer NOT NULL,
    meal_id integer,
    food_id integer,
    weight_g numeric(10,2) NOT NULL,
    calories numeric(10,2) DEFAULT 0,
    protein numeric(10,2) DEFAULT 0,
    fat numeric(10,2) DEFAULT 0,
    carbs numeric(10,2) DEFAULT 0,
    quick_add_count integer DEFAULT 0,
    last_eaten_at timestamp without time zone,
    dish_id integer,
    CONSTRAINT chk_mealitem_food_or_dish CHECK ((((food_id IS NOT NULL) AND (dish_id IS NULL)) OR ((food_id IS NULL) AND (dish_id IS NOT NULL)))),
    CONSTRAINT mealitem_weight_g_check CHECK ((weight_g > (0)::numeric))
);


ALTER TABLE public.mealitem OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 21297)
-- Name: mealitem_meal_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mealitem_meal_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mealitem_meal_item_id_seq OWNER TO postgres;

--
-- TOC entry 6657 (class 0 OID 0)
-- Dependencies: 241
-- Name: mealitem_meal_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mealitem_meal_item_id_seq OWNED BY public.mealitem.meal_item_id;


--
-- TOC entry 244 (class 1259 OID 21318)
-- Name: mealnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mealnote (
    note_id integer NOT NULL,
    meal_id integer,
    note text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.mealnote OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 21317)
-- Name: mealnote_note_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mealnote_note_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mealnote_note_id_seq OWNER TO postgres;

--
-- TOC entry 6658 (class 0 OID 0)
-- Dependencies: 243
-- Name: mealnote_note_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mealnote_note_id_seq OWNED BY public.mealnote.note_id;


--
-- TOC entry 335 (class 1259 OID 22467)
-- Name: mealtemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mealtemplate (
    template_id integer NOT NULL,
    user_id integer,
    template_name character varying(200) NOT NULL,
    description text,
    meal_type character varying(20),
    is_favorite boolean DEFAULT false,
    usage_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT mealtemplate_meal_type_check CHECK (((meal_type)::text = ANY ((ARRAY['breakfast'::character varying, 'lunch'::character varying, 'dinner'::character varying, 'snack'::character varying])::text[])))
);


ALTER TABLE public.mealtemplate OWNER TO postgres;

--
-- TOC entry 334 (class 1259 OID 22466)
-- Name: mealtemplate_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mealtemplate_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mealtemplate_template_id_seq OWNER TO postgres;

--
-- TOC entry 6659 (class 0 OID 0)
-- Dependencies: 334
-- Name: mealtemplate_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mealtemplate_template_id_seq OWNED BY public.mealtemplate.template_id;


--
-- TOC entry 337 (class 1259 OID 22488)
-- Name: mealtemplateitem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mealtemplateitem (
    template_item_id integer NOT NULL,
    template_id integer,
    food_id integer,
    weight_g numeric(10,2) NOT NULL,
    item_order integer DEFAULT 0
);


ALTER TABLE public.mealtemplateitem OWNER TO postgres;

--
-- TOC entry 336 (class 1259 OID 22487)
-- Name: mealtemplateitem_template_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mealtemplateitem_template_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mealtemplateitem_template_item_id_seq OWNER TO postgres;

--
-- TOC entry 6660 (class 0 OID 0)
-- Dependencies: 336
-- Name: mealtemplateitem_template_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mealtemplateitem_template_item_id_seq OWNED BY public.mealtemplateitem.template_item_id;


--
-- TOC entry 321 (class 1259 OID 22289)
-- Name: medicationlog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicationlog (
    log_id integer NOT NULL,
    user_condition_id integer,
    user_id integer,
    medication_date date NOT NULL,
    medication_time time without time zone NOT NULL,
    taken_at timestamp without time zone,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    drug_id integer,
    user_medication_id integer
);


ALTER TABLE public.medicationlog OWNER TO postgres;

--
-- TOC entry 6661 (class 0 OID 0)
-- Dependencies: 321
-- Name: TABLE medicationlog; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.medicationlog IS 'Lịch sử uống thuốc hàng ngày';


--
-- TOC entry 320 (class 1259 OID 22288)
-- Name: medicationlog_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medicationlog_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medicationlog_log_id_seq OWNER TO postgres;

--
-- TOC entry 6662 (class 0 OID 0)
-- Dependencies: 320
-- Name: medicationlog_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medicationlog_log_id_seq OWNED BY public.medicationlog.log_id;


--
-- TOC entry 319 (class 1259 OID 22268)
-- Name: medicationschedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicationschedule (
    medication_id integer NOT NULL,
    user_condition_id integer,
    user_id integer,
    medication_times text[],
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    medication_details jsonb DEFAULT '{}'::jsonb,
    drug_id integer
);


ALTER TABLE public.medicationschedule OWNER TO postgres;

--
-- TOC entry 6663 (class 0 OID 0)
-- Dependencies: 319
-- Name: TABLE medicationschedule; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.medicationschedule IS 'Lịch uống thuốc của user';


--
-- TOC entry 6664 (class 0 OID 0)
-- Dependencies: 319
-- Name: COLUMN medicationschedule.medication_details; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.medicationschedule.medication_details IS 'JSON object containing medication name, dosage, instructions, etc.';


--
-- TOC entry 318 (class 1259 OID 22267)
-- Name: medicationschedule_medication_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medicationschedule_medication_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medicationschedule_medication_id_seq OWNER TO postgres;

--
-- TOC entry 6665 (class 0 OID 0)
-- Dependencies: 318
-- Name: medicationschedule_medication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medicationschedule_medication_id_seq OWNED BY public.medicationschedule.medication_id;


--
-- TOC entry 399 (class 1259 OID 24529)
-- Name: messagereaction_reaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messagereaction_reaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messagereaction_reaction_id_seq OWNER TO postgres;

--
-- TOC entry 6666 (class 0 OID 0)
-- Dependencies: 399
-- Name: messagereaction_reaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messagereaction_reaction_id_seq OWNED BY public.messagereaction.reaction_id;


--
-- TOC entry 257 (class 1259 OID 21541)
-- Name: mineral; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mineral (
    mineral_id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    unit character varying(20) DEFAULT 'mg'::character varying,
    recommended_daily numeric(10,3),
    created_at timestamp without time zone DEFAULT now(),
    created_by_admin integer
);


ALTER TABLE public.mineral OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 21540)
-- Name: mineral_mineral_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mineral_mineral_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mineral_mineral_id_seq OWNER TO postgres;

--
-- TOC entry 6667 (class 0 OID 0)
-- Dependencies: 256
-- Name: mineral_mineral_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mineral_mineral_id_seq OWNED BY public.mineral.mineral_id;


--
-- TOC entry 375 (class 1259 OID 23152)
-- Name: mineralnutrient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mineralnutrient (
    mineral_nutrient_id integer NOT NULL,
    mineral_id integer NOT NULL,
    nutrient_id integer NOT NULL,
    amount numeric(10,3) DEFAULT 0,
    factor numeric(10,6) DEFAULT 1.0,
    notes text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.mineralnutrient OWNER TO postgres;

--
-- TOC entry 374 (class 1259 OID 23151)
-- Name: mineralnutrient_mineral_nutrient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mineralnutrient_mineral_nutrient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mineralnutrient_mineral_nutrient_id_seq OWNER TO postgres;

--
-- TOC entry 6668 (class 0 OID 0)
-- Dependencies: 374
-- Name: mineralnutrient_mineral_nutrient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mineralnutrient_mineral_nutrient_id_seq OWNED BY public.mineralnutrient.mineral_nutrient_id;


--
-- TOC entry 259 (class 1259 OID 21562)
-- Name: mineralrda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mineralrda (
    mineral_rda_id integer NOT NULL,
    mineral_id integer,
    sex character varying(10),
    age_min integer,
    age_max integer,
    rda_value numeric(10,3),
    unit character varying(20),
    notes text
);


ALTER TABLE public.mineralrda OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 21561)
-- Name: mineralrda_mineral_rda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mineralrda_mineral_rda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mineralrda_mineral_rda_id_seq OWNER TO postgres;

--
-- TOC entry 6669 (class 0 OID 0)
-- Dependencies: 258
-- Name: mineralrda_mineral_rda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mineralrda_mineral_rda_id_seq OWNED BY public.mineralrda.mineral_rda_id;


--
-- TOC entry 232 (class 1259 OID 21219)
-- Name: nutrient_nutrient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nutrient_nutrient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nutrient_nutrient_id_seq OWNER TO postgres;

--
-- TOC entry 6670 (class 0 OID 0)
-- Dependencies: 232
-- Name: nutrient_nutrient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nutrient_nutrient_id_seq OWNED BY public.nutrient.nutrient_id;


--
-- TOC entry 291 (class 1259 OID 21945)
-- Name: nutrientcontraindication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nutrientcontraindication (
    contra_id integer NOT NULL,
    nutrient_id integer,
    condition_name character varying(100) NOT NULL,
    note text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.nutrientcontraindication OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 21944)
-- Name: nutrientcontraindication_contra_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nutrientcontraindication_contra_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nutrientcontraindication_contra_id_seq OWNER TO postgres;

--
-- TOC entry 6671 (class 0 OID 0)
-- Dependencies: 290
-- Name: nutrientcontraindication_contra_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nutrientcontraindication_contra_id_seq OWNED BY public.nutrientcontraindication.contra_id;


--
-- TOC entry 292 (class 1259 OID 21963)
-- Name: nutrientgroupstats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.nutrientgroupstats AS
 SELECT COALESCE(group_name, 'Uncategorized'::character varying) AS group_name,
    count(*) AS total
   FROM public.nutrient
  GROUP BY COALESCE(group_name, 'Uncategorized'::character varying)
  ORDER BY (count(*)) DESC;


ALTER VIEW public.nutrientgroupstats OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 21758)
-- Name: nutrientmapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nutrientmapping (
    mapping_id integer NOT NULL,
    nutrient_id integer,
    fiber_id integer,
    fatty_acid_id integer,
    factor numeric(10,6) DEFAULT 1.0,
    notes text
);


ALTER TABLE public.nutrientmapping OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 21757)
-- Name: nutrientmapping_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nutrientmapping_mapping_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nutrientmapping_mapping_id_seq OWNER TO postgres;

--
-- TOC entry 6672 (class 0 OID 0)
-- Dependencies: 275
-- Name: nutrientmapping_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nutrientmapping_mapping_id_seq OWNED BY public.nutrientmapping.mapping_id;


--
-- TOC entry 309 (class 1259 OID 22141)
-- Name: nutritionanalysis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nutritionanalysis (
    analysis_id integer NOT NULL,
    user_id integer,
    image_url text NOT NULL,
    food_name character varying(200),
    confidence_score numeric(3,2),
    nutrients jsonb NOT NULL,
    is_approved boolean,
    approved_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.nutritionanalysis OWNER TO postgres;

--
-- TOC entry 6673 (class 0 OID 0)
-- Dependencies: 309
-- Name: TABLE nutritionanalysis; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.nutritionanalysis IS 'AI-analyzed nutrition data from food images with approval workflow';


--
-- TOC entry 6674 (class 0 OID 0)
-- Dependencies: 309
-- Name: COLUMN nutritionanalysis.confidence_score; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nutritionanalysis.confidence_score IS 'AI confidence level (0.00-1.00) for food recognition';


--
-- TOC entry 308 (class 1259 OID 22140)
-- Name: nutritionanalysis_analysis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nutritionanalysis_analysis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nutritionanalysis_analysis_id_seq OWNER TO postgres;

--
-- TOC entry 6675 (class 0 OID 0)
-- Dependencies: 308
-- Name: nutritionanalysis_analysis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nutritionanalysis_analysis_id_seq OWNED BY public.nutritionanalysis.analysis_id;


--
-- TOC entry 342 (class 1259 OID 22581)
-- Name: passwordchangecode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.passwordchangecode (
    id integer NOT NULL,
    user_id integer,
    code character varying(12) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    used_at timestamp with time zone,
    expires_at timestamp with time zone NOT NULL
);


ALTER TABLE public.passwordchangecode OWNER TO postgres;

--
-- TOC entry 341 (class 1259 OID 22580)
-- Name: passwordchangecode_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.passwordchangecode_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.passwordchangecode_id_seq OWNER TO postgres;

--
-- TOC entry 6676 (class 0 OID 0)
-- Dependencies: 341
-- Name: passwordchangecode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.passwordchangecode_id_seq OWNED BY public.passwordchangecode.id;


--
-- TOC entry 369 (class 1259 OID 23082)
-- Name: permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permission (
    permission_id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    resource character varying(50) NOT NULL,
    action character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.permission OWNER TO postgres;

--
-- TOC entry 368 (class 1259 OID 23081)
-- Name: permission_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.permission_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permission_permission_id_seq OWNER TO postgres;

--
-- TOC entry 6677 (class 0 OID 0)
-- Dependencies: 368
-- Name: permission_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.permission_permission_id_seq OWNED BY public.permission.permission_id;


--
-- TOC entry 329 (class 1259 OID 22400)
-- Name: portionsize; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.portionsize (
    portion_id integer NOT NULL,
    food_id integer,
    portion_name character varying(100) NOT NULL,
    portion_name_vi character varying(100),
    weight_g numeric(10,2) NOT NULL,
    is_common boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.portionsize OWNER TO postgres;

--
-- TOC entry 328 (class 1259 OID 22399)
-- Name: portionsize_portion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.portionsize_portion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.portionsize_portion_id_seq OWNER TO postgres;

--
-- TOC entry 6678 (class 0 OID 0)
-- Dependencies: 328
-- Name: portionsize_portion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.portionsize_portion_id_seq OWNED BY public.portionsize.portion_id;


--
-- TOC entry 402 (class 1259 OID 24555)
-- Name: privateconversation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.privateconversation (
    conversation_id integer NOT NULL,
    user1_id integer NOT NULL,
    user2_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT privateconversation_check CHECK ((user1_id < user2_id))
);


ALTER TABLE public.privateconversation OWNER TO postgres;

--
-- TOC entry 6679 (class 0 OID 0)
-- Dependencies: 402
-- Name: TABLE privateconversation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.privateconversation IS 'Private conversations between friends';


--
-- TOC entry 401 (class 1259 OID 24554)
-- Name: privateconversation_conversation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.privateconversation_conversation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.privateconversation_conversation_id_seq OWNER TO postgres;

--
-- TOC entry 6680 (class 0 OID 0)
-- Dependencies: 401
-- Name: privateconversation_conversation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.privateconversation_conversation_id_seq OWNED BY public.privateconversation.conversation_id;


--
-- TOC entry 404 (class 1259 OID 24582)
-- Name: privatemessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.privatemessage (
    message_id integer NOT NULL,
    conversation_id integer NOT NULL,
    sender_id integer NOT NULL,
    message_text text,
    image_url text,
    is_read boolean DEFAULT false,
    read_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.privatemessage OWNER TO postgres;

--
-- TOC entry 6681 (class 0 OID 0)
-- Dependencies: 404
-- Name: TABLE privatemessage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.privatemessage IS 'Messages in private conversations between friends';


--
-- TOC entry 403 (class 1259 OID 24581)
-- Name: privatemessage_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.privatemessage_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.privatemessage_message_id_seq OWNER TO postgres;

--
-- TOC entry 6682 (class 0 OID 0)
-- Dependencies: 403
-- Name: privatemessage_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.privatemessage_message_id_seq OWNED BY public.privatemessage.message_id;


--
-- TOC entry 310 (class 1259 OID 22164)
-- Name: recent_chatbot_conversations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.recent_chatbot_conversations AS
 SELECT conversation_id,
    user_id,
    title,
    created_at,
    updated_at,
    ( SELECT chatbotmessage.message_text
           FROM public.chatbotmessage
          WHERE (chatbotmessage.conversation_id = c.conversation_id)
          ORDER BY chatbotmessage.created_at DESC
         LIMIT 1) AS last_message,
    ( SELECT count(*) AS count
           FROM public.chatbotmessage
          WHERE (chatbotmessage.conversation_id = c.conversation_id)) AS message_count
   FROM public.chatbotconversation c
  ORDER BY updated_at DESC;


ALTER VIEW public.recent_chatbot_conversations OWNER TO postgres;

--
-- TOC entry 331 (class 1259 OID 22418)
-- Name: recipe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe (
    recipe_id integer NOT NULL,
    user_id integer,
    recipe_name character varying(200) NOT NULL,
    description text,
    servings integer DEFAULT 1,
    prep_time_minutes integer,
    cook_time_minutes integer,
    instructions text,
    image_url text,
    is_public boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.recipe OWNER TO postgres;

--
-- TOC entry 330 (class 1259 OID 22417)
-- Name: recipe_recipe_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recipe_recipe_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipe_recipe_id_seq OWNER TO postgres;

--
-- TOC entry 6683 (class 0 OID 0)
-- Dependencies: 330
-- Name: recipe_recipe_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipe_recipe_id_seq OWNED BY public.recipe.recipe_id;


--
-- TOC entry 333 (class 1259 OID 22438)
-- Name: recipeingredient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipeingredient (
    recipe_ingredient_id integer NOT NULL,
    recipe_id integer,
    food_id integer,
    weight_g numeric(10,2) NOT NULL,
    ingredient_order integer DEFAULT 0,
    notes text
);


ALTER TABLE public.recipeingredient OWNER TO postgres;

--
-- TOC entry 332 (class 1259 OID 22437)
-- Name: recipeingredient_recipe_ingredient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recipeingredient_recipe_ingredient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipeingredient_recipe_ingredient_id_seq OWNER TO postgres;

--
-- TOC entry 6684 (class 0 OID 0)
-- Dependencies: 332
-- Name: recipeingredient_recipe_ingredient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipeingredient_recipe_ingredient_id_seq OWNED BY public.recipeingredient.recipe_ingredient_id;


--
-- TOC entry 339 (class 1259 OID 22517)
-- Name: recipenutritionsummary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.recipenutritionsummary AS
 SELECT r.recipe_id,
    r.recipe_name,
    r.servings,
    sum(((fn.amount_per_100g * ri.weight_g) / (100)::numeric)) AS total_calories_kcal,
    sum(
        CASE
            WHEN ((n.name)::text = 'Protein'::text) THEN ((fn.amount_per_100g * ri.weight_g) / (100)::numeric)
            ELSE (0)::numeric
        END) AS total_protein_g,
    sum(
        CASE
            WHEN ((n.name)::text = 'Carbohydrate, by difference'::text) THEN ((fn.amount_per_100g * ri.weight_g) / (100)::numeric)
            ELSE (0)::numeric
        END) AS total_carbs_g,
    sum(
        CASE
            WHEN ((n.name)::text = 'Total lipid (fat)'::text) THEN ((fn.amount_per_100g * ri.weight_g) / (100)::numeric)
            ELSE (0)::numeric
        END) AS total_fat_g
   FROM (((public.recipe r
     JOIN public.recipeingredient ri ON ((r.recipe_id = ri.recipe_id)))
     JOIN public.foodnutrient fn ON ((ri.food_id = fn.food_id)))
     JOIN public.nutrient n ON ((fn.nutrient_id = n.nutrient_id)))
  WHERE ((n.name)::text = ANY ((ARRAY['Energy'::character varying, 'Protein'::character varying, 'Carbohydrate, by difference'::character varying, 'Total lipid (fat)'::character varying])::text[]))
  GROUP BY r.recipe_id, r.recipe_name, r.servings;


ALTER VIEW public.recipenutritionsummary OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 21175)
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    role_id integer NOT NULL,
    role_name character varying(50) NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 21174)
-- Name: role_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.role_role_id_seq OWNER TO postgres;

--
-- TOC entry 6685 (class 0 OID 0)
-- Dependencies: 227
-- Name: role_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_role_id_seq OWNED BY public.role.role_id;


--
-- TOC entry 371 (class 1259 OID 23098)
-- Name: rolepermission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolepermission (
    role_permission_id integer NOT NULL,
    role_name character varying(50),
    permission_id integer,
    granted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rolepermission OWNER TO postgres;

--
-- TOC entry 370 (class 1259 OID 23097)
-- Name: rolepermission_role_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolepermission_role_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rolepermission_role_permission_id_seq OWNER TO postgres;

--
-- TOC entry 6686 (class 0 OID 0)
-- Dependencies: 370
-- Name: rolepermission_role_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolepermission_role_permission_id_seq OWNED BY public.rolepermission.role_permission_id;


--
-- TOC entry 248 (class 1259 OID 21353)
-- Name: suggestion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suggestion (
    suggestion_id integer NOT NULL,
    user_id integer,
    date date NOT NULL,
    nutrient_id integer,
    deficiency_amount numeric(10,2),
    suggested_food_id integer,
    note text
);


ALTER TABLE public.suggestion OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 21352)
-- Name: suggestion_suggestion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suggestion_suggestion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suggestion_suggestion_id_seq OWNER TO postgres;

--
-- TOC entry 6687 (class 0 OID 0)
-- Dependencies: 247
-- Name: suggestion_suggestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suggestion_suggestion_id_seq OWNED BY public.suggestion.suggestion_id;


--
-- TOC entry 363 (class 1259 OID 22914)
-- Name: user_accessible_dishes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_accessible_dishes AS
 SELECT d.dish_id,
    d.name,
    d.vietnamese_name,
    d.description,
    d.category,
    d.serving_size_g,
    d.image_url,
    d.is_template,
    d.is_public,
    d.created_by_user,
    d.created_by_admin,
    d.created_at,
    d.updated_at,
    d.image_urls,
        CASE
            WHEN (d.created_by_admin IS NOT NULL) THEN 'admin'::text
            WHEN (d.created_by_user IS NOT NULL) THEN 'user'::text
            ELSE 'unknown'::text
        END AS created_by_type,
    u.full_name AS creator_name
   FROM (public.dish d
     LEFT JOIN public."User" u ON ((u.user_id = d.created_by_user)))
  WHERE ((d.is_public = true) OR (d.created_by_user IS NOT NULL));


ALTER VIEW public.user_accessible_dishes OWNER TO postgres;

--
-- TOC entry 6688 (class 0 OID 0)
-- Dependencies: 363
-- Name: VIEW user_accessible_dishes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.user_accessible_dishes IS 'Shows all dishes accessible to users (public + their own private dishes)';


--
-- TOC entry 343 (class 1259 OID 22602)
-- Name: user_account_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_account_status (
    user_id integer NOT NULL,
    is_blocked boolean DEFAULT false NOT NULL,
    blocked_reason text,
    blocked_at timestamp with time zone,
    blocked_by_admin integer,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_account_status OWNER TO postgres;

--
-- TOC entry 345 (class 1259 OID 22625)
-- Name: user_block_event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_block_event (
    block_event_id integer NOT NULL,
    user_id integer,
    event_type character varying(20) NOT NULL,
    reason text,
    admin_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_block_event_event_type_check CHECK (((event_type)::text = ANY ((ARRAY['block'::character varying, 'unblock'::character varying])::text[])))
);


ALTER TABLE public.user_block_event OWNER TO postgres;

--
-- TOC entry 344 (class 1259 OID 22624)
-- Name: user_block_event_block_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_block_event_block_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_block_event_block_event_id_seq OWNER TO postgres;

--
-- TOC entry 6689 (class 0 OID 0)
-- Dependencies: 344
-- Name: user_block_event_block_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_block_event_block_event_id_seq OWNED BY public.user_block_event.block_event_id;


--
-- TOC entry 289 (class 1259 OID 21912)
-- Name: user_meal_summaries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_meal_summaries (
    id integer NOT NULL,
    user_id integer NOT NULL,
    summary_date date DEFAULT CURRENT_DATE NOT NULL,
    meal_type character varying(16) NOT NULL,
    consumed_kcal numeric(12,2) DEFAULT 0,
    consumed_carbs numeric(12,2) DEFAULT 0,
    consumed_protein numeric(12,2) DEFAULT 0,
    consumed_fat numeric(12,2) DEFAULT 0,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_meal_summaries OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 21911)
-- Name: user_meal_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_meal_summaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_meal_summaries_id_seq OWNER TO postgres;

--
-- TOC entry 6690 (class 0 OID 0)
-- Dependencies: 288
-- Name: user_meal_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_meal_summaries_id_seq OWNED BY public.user_meal_summaries.id;


--
-- TOC entry 285 (class 1259 OID 21866)
-- Name: user_meal_targets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_meal_targets (
    id integer NOT NULL,
    user_id integer NOT NULL,
    target_date date DEFAULT CURRENT_DATE NOT NULL,
    meal_type character varying(16) NOT NULL,
    target_kcal numeric(10,2) DEFAULT 0,
    target_carbs numeric(10,2) DEFAULT 0,
    target_protein numeric(10,2) DEFAULT 0,
    target_fat numeric(10,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_meal_targets OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 21865)
-- Name: user_meal_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_meal_targets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_meal_targets_id_seq OWNER TO postgres;

--
-- TOC entry 6691 (class 0 OID 0)
-- Dependencies: 284
-- Name: user_meal_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_meal_targets_id_seq OWNED BY public.user_meal_targets.id;


--
-- TOC entry 347 (class 1259 OID 22650)
-- Name: user_unblock_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_unblock_request (
    request_id integer NOT NULL,
    user_id integer,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    message text,
    admin_response text,
    decided_at timestamp with time zone,
    decided_by_admin integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_unblock_request_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.user_unblock_request OWNER TO postgres;

--
-- TOC entry 346 (class 1259 OID 22649)
-- Name: user_unblock_request_request_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_unblock_request_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_unblock_request_request_id_seq OWNER TO postgres;

--
-- TOC entry 6692 (class 0 OID 0)
-- Dependencies: 346
-- Name: user_unblock_request_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_unblock_request_request_id_seq OWNED BY public.user_unblock_request.request_id;


--
-- TOC entry 224 (class 1259 OID 21144)
-- Name: useractivitylog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.useractivitylog (
    log_id integer NOT NULL,
    user_id integer,
    action text,
    log_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.useractivitylog OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 21143)
-- Name: useractivitylog_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.useractivitylog_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.useractivitylog_log_id_seq OWNER TO postgres;

--
-- TOC entry 6693 (class 0 OID 0)
-- Dependencies: 223
-- Name: useractivitylog_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.useractivitylog_log_id_seq OWNED BY public.useractivitylog.log_id;


--
-- TOC entry 283 (class 1259 OID 21843)
-- Name: useraminointake; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.useraminointake (
    intake_id bigint NOT NULL,
    user_id integer,
    amino_acid_id integer,
    amount numeric NOT NULL,
    unit character varying(16) DEFAULT 'mg'::character varying,
    source text,
    recorded_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.useraminointake OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 21842)
-- Name: useraminointake_intake_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.useraminointake_intake_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.useraminointake_intake_id_seq OWNER TO postgres;

--
-- TOC entry 6694 (class 0 OID 0)
-- Dependencies: 282
-- Name: useraminointake_intake_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.useraminointake_intake_id_seq OWNED BY public.useraminointake.intake_id;


--
-- TOC entry 281 (class 1259 OID 21822)
-- Name: useraminorequirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.useraminorequirement (
    user_id integer NOT NULL,
    amino_acid_id integer NOT NULL,
    base numeric,
    multiplier numeric,
    recommended numeric,
    unit text,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.useraminorequirement OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 21738)
-- Name: userfattyacidintake; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userfattyacidintake (
    intake_id integer NOT NULL,
    user_id integer,
    date date NOT NULL,
    fatty_acid_id integer,
    amount numeric(12,4) DEFAULT 0
);


ALTER TABLE public.userfattyacidintake OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 21737)
-- Name: userfattyacidintake_intake_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.userfattyacidintake_intake_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.userfattyacidintake_intake_id_seq OWNER TO postgres;

--
-- TOC entry 6695 (class 0 OID 0)
-- Dependencies: 273
-- Name: userfattyacidintake_intake_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.userfattyacidintake_intake_id_seq OWNED BY public.userfattyacidintake.intake_id;


--
-- TOC entry 270 (class 1259 OID 21697)
-- Name: userfattyacidrequirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userfattyacidrequirement (
    user_id integer NOT NULL,
    fatty_acid_id integer NOT NULL,
    base numeric,
    multiplier numeric,
    recommended numeric,
    unit text,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.userfattyacidrequirement OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 21718)
-- Name: userfiberintake; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userfiberintake (
    intake_id integer NOT NULL,
    user_id integer,
    date date NOT NULL,
    fiber_id integer,
    amount numeric(12,4) DEFAULT 0
);


ALTER TABLE public.userfiberintake OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 21717)
-- Name: userfiberintake_intake_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.userfiberintake_intake_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.userfiberintake_intake_id_seq OWNER TO postgres;

--
-- TOC entry 6696 (class 0 OID 0)
-- Dependencies: 271
-- Name: userfiberintake_intake_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.userfiberintake_intake_id_seq OWNED BY public.userfiberintake.intake_id;


--
-- TOC entry 269 (class 1259 OID 21677)
-- Name: userfiberrequirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userfiberrequirement (
    user_id integer NOT NULL,
    fiber_id integer NOT NULL,
    base numeric,
    multiplier numeric,
    recommended numeric,
    unit text,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.userfiberrequirement OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 21393)
-- Name: usergoal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usergoal (
    goal_id integer NOT NULL,
    user_id integer,
    goal_type character varying(20) NOT NULL,
    goal_weight numeric(5,2),
    activity_factor numeric(3,2),
    bmr numeric(10,2),
    tdee numeric(10,2),
    daily_calorie_target numeric(10,2),
    daily_protein_target numeric(10,2),
    daily_fat_target numeric(10,2),
    daily_carb_target numeric(10,2),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usergoal OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 21392)
-- Name: usergoal_goal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usergoal_goal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usergoal_goal_id_seq OWNER TO postgres;

--
-- TOC entry 6697 (class 0 OID 0)
-- Dependencies: 249
-- Name: usergoal_goal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usergoal_goal_id_seq OWNED BY public.usergoal.goal_id;


--
-- TOC entry 317 (class 1259 OID 22242)
-- Name: userhealthcondition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userhealthcondition (
    user_condition_id integer NOT NULL,
    user_id integer,
    condition_id integer,
    diagnosed_date date DEFAULT CURRENT_DATE,
    treatment_start_date date DEFAULT CURRENT_DATE,
    treatment_end_date date,
    treatment_duration_days integer,
    status character varying(20) DEFAULT 'active'::character varying,
    notes text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.userhealthcondition OWNER TO postgres;

--
-- TOC entry 6698 (class 0 OID 0)
-- Dependencies: 317
-- Name: TABLE userhealthcondition; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.userhealthcondition IS 'Bệnh mà user đang mắc';


--
-- TOC entry 316 (class 1259 OID 22241)
-- Name: userhealthcondition_user_condition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.userhealthcondition_user_condition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.userhealthcondition_user_condition_id_seq OWNER TO postgres;

--
-- TOC entry 6699 (class 0 OID 0)
-- Dependencies: 316
-- Name: userhealthcondition_user_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.userhealthcondition_user_condition_id_seq OWNED BY public.userhealthcondition.user_condition_id;


--
-- TOC entry 407 (class 1259 OID 29003)
-- Name: usermedication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usermedication (
    user_medication_id integer NOT NULL,
    user_id integer NOT NULL,
    medication_name character varying(200) NOT NULL,
    dosage character varying(100),
    frequency character varying(100),
    start_date date,
    end_date date,
    status character varying(20) DEFAULT 'active'::character varying,
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usermedication OWNER TO postgres;

--
-- TOC entry 406 (class 1259 OID 29002)
-- Name: usermedication_user_medication_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usermedication_user_medication_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usermedication_user_medication_id_seq OWNER TO postgres;

--
-- TOC entry 6700 (class 0 OID 0)
-- Dependencies: 406
-- Name: usermedication_user_medication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usermedication_user_medication_id_seq OWNED BY public.usermedication.user_medication_id;


--
-- TOC entry 260 (class 1259 OID 21579)
-- Name: usermineralrequirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usermineralrequirement (
    user_id integer NOT NULL,
    mineral_id integer NOT NULL,
    base numeric,
    multiplier numeric,
    recommended numeric,
    unit text,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usermineralrequirement OWNER TO postgres;

--
-- TOC entry 377 (class 1259 OID 23753)
-- Name: usernutrientmanuallog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usernutrientmanuallog (
    log_id integer NOT NULL,
    user_id integer NOT NULL,
    log_date date DEFAULT CURRENT_DATE NOT NULL,
    nutrient_id integer NOT NULL,
    nutrient_type character varying(20) NOT NULL,
    nutrient_code character varying(50) NOT NULL,
    nutrient_name character varying(150),
    unit character varying(20),
    amount numeric(14,4) DEFAULT 0 NOT NULL,
    source character varying(30),
    source_ref text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.usernutrientmanuallog OWNER TO postgres;

--
-- TOC entry 376 (class 1259 OID 23752)
-- Name: usernutrientmanuallog_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usernutrientmanuallog_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usernutrientmanuallog_log_id_seq OWNER TO postgres;

--
-- TOC entry 6701 (class 0 OID 0)
-- Dependencies: 376
-- Name: usernutrientmanuallog_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usernutrientmanuallog_log_id_seq OWNED BY public.usernutrientmanuallog.log_id;


--
-- TOC entry 296 (class 1259 OID 21994)
-- Name: usernutrientnotification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usernutrientnotification (
    notification_id integer NOT NULL,
    user_id integer,
    nutrient_type character varying(20) NOT NULL,
    nutrient_id integer NOT NULL,
    nutrient_name character varying(100),
    notification_type character varying(50) NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    severity character varying(20) DEFAULT 'info'::character varying,
    is_read boolean DEFAULT false,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.usernutrientnotification OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 21993)
-- Name: usernutrientnotification_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usernutrientnotification_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usernutrientnotification_notification_id_seq OWNER TO postgres;

--
-- TOC entry 6702 (class 0 OID 0)
-- Dependencies: 295
-- Name: usernutrientnotification_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usernutrientnotification_notification_id_seq OWNED BY public.usernutrientnotification.notification_id;


--
-- TOC entry 294 (class 1259 OID 21972)
-- Name: usernutrienttracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usernutrienttracking (
    tracking_id integer NOT NULL,
    user_id integer,
    date date DEFAULT CURRENT_DATE NOT NULL,
    nutrient_type character varying(20) NOT NULL,
    nutrient_id integer NOT NULL,
    target_amount numeric(10,3),
    current_amount numeric(10,3) DEFAULT 0,
    unit character varying(20),
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.usernutrienttracking OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 21971)
-- Name: usernutrienttracking_tracking_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usernutrienttracking_tracking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usernutrienttracking_tracking_id_seq OWNER TO postgres;

--
-- TOC entry 6703 (class 0 OID 0)
-- Dependencies: 293
-- Name: usernutrienttracking_tracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usernutrienttracking_tracking_id_seq OWNED BY public.usernutrienttracking.tracking_id;


--
-- TOC entry 221 (class 1259 OID 21107)
-- Name: userprofile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userprofile (
    user_id integer NOT NULL,
    activity_level character varying(50),
    diet_type character varying(50),
    allergies text,
    health_goals text,
    goal_type character varying(20),
    goal_weight numeric(5,2),
    activity_factor numeric(3,2),
    bmr numeric(10,2),
    tdee numeric(10,2),
    daily_calorie_target numeric(10,2),
    daily_protein_target numeric(10,2),
    daily_fat_target numeric(10,2),
    daily_carb_target numeric(10,2),
    daily_water_target numeric(10,2)
);


ALTER TABLE public.userprofile OWNER TO postgres;

--
-- TOC entry 338 (class 1259 OID 22512)
-- Name: userquickaddfoods; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.userquickaddfoods AS
 SELECT m.user_id,
    mi.food_id,
    f.name AS food_name,
    f.name AS food_name_vi,
    count(*) AS times_eaten,
    avg(mi.weight_g) AS avg_portion_g,
    max(m.created_at) AS last_eaten,
    bool_or(m.is_favorite) AS is_favorite
   FROM ((public.mealitem mi
     JOIN public.meal m ON ((mi.meal_id = m.meal_id)))
     JOIN public.food f ON ((mi.food_id = f.food_id)))
  GROUP BY m.user_id, mi.food_id, f.name
 HAVING (count(*) >= 2)
  ORDER BY (count(*)) DESC, (max(m.created_at)) DESC;


ALTER VIEW public.userquickaddfoods OWNER TO postgres;

--
-- TOC entry 340 (class 1259 OID 22559)
-- Name: usersecurity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usersecurity (
    user_id integer NOT NULL,
    twofa_enabled boolean DEFAULT false NOT NULL,
    twofa_secret text,
    lock_threshold integer DEFAULT 5 NOT NULL,
    failed_attempts integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.usersecurity OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 21120)
-- Name: usersetting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usersetting (
    user_id integer NOT NULL,
    theme character varying(20) DEFAULT 'light'::character varying,
    language character varying(10) DEFAULT 'vi'::character varying,
    font_size character varying(20) DEFAULT 'medium'::character varying,
    unit_system character varying(10) DEFAULT 'metric'::character varying,
    seasonal_ui_enabled boolean DEFAULT false,
    seasonal_mode character varying(20) DEFAULT 'auto'::character varying,
    seasonal_custom_bg text,
    falling_leaves_enabled boolean DEFAULT true,
    weather_enabled boolean DEFAULT false,
    weather_city character varying(100),
    weather_last_update timestamp without time zone,
    weather_last_data jsonb,
    background_image_url text,
    calorie_multiplier numeric(4,2),
    macro_protein_pct numeric(5,2),
    macro_fat_pct numeric(5,2),
    macro_carb_pct numeric(5,2),
    wind_direction double precision DEFAULT 0,
    weather_effects_enabled boolean DEFAULT true,
    effect_intensity character varying(20) DEFAULT 'medium'::character varying,
    meal_pct_breakfast numeric(5,2) DEFAULT 25.00,
    meal_pct_lunch numeric(5,2) DEFAULT 35.00,
    meal_pct_snack numeric(5,2) DEFAULT 10.00,
    meal_pct_dinner numeric(5,2) DEFAULT 30.00,
    background_image_enabled boolean DEFAULT false,
    meal_time_breakfast time without time zone DEFAULT '07:00:00'::time without time zone,
    meal_time_lunch time without time zone DEFAULT '11:00:00'::time without time zone,
    meal_time_snack time without time zone DEFAULT '13:00:00'::time without time zone,
    meal_time_dinner time without time zone DEFAULT '18:00:00'::time without time zone
);


ALTER TABLE public.usersetting OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 21499)
-- Name: uservitaminrequirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.uservitaminrequirement (
    user_id integer NOT NULL,
    vitamin_id integer NOT NULL,
    base numeric,
    multiplier numeric,
    recommended numeric,
    unit text,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.uservitaminrequirement OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 21475)
-- Name: vitamin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vitamin (
    vitamin_id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    unit character varying(20) DEFAULT 'mg'::character varying,
    recommended_daily numeric(10,3),
    created_at timestamp without time zone DEFAULT now(),
    created_by_admin integer
);


ALTER TABLE public.vitamin OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 21474)
-- Name: vitamin_vitamin_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vitamin_vitamin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vitamin_vitamin_id_seq OWNER TO postgres;

--
-- TOC entry 6704 (class 0 OID 0)
-- Dependencies: 251
-- Name: vitamin_vitamin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vitamin_vitamin_id_seq OWNED BY public.vitamin.vitamin_id;


--
-- TOC entry 373 (class 1259 OID 23123)
-- Name: vitaminnutrient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vitaminnutrient (
    vitamin_nutrient_id integer NOT NULL,
    vitamin_id integer NOT NULL,
    nutrient_id integer NOT NULL,
    amount numeric(10,3) DEFAULT 0,
    factor numeric(10,6) DEFAULT 1.0,
    notes text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vitaminnutrient OWNER TO postgres;

--
-- TOC entry 372 (class 1259 OID 23122)
-- Name: vitaminnutrient_vitamin_nutrient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vitaminnutrient_vitamin_nutrient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vitaminnutrient_vitamin_nutrient_id_seq OWNER TO postgres;

--
-- TOC entry 6705 (class 0 OID 0)
-- Dependencies: 372
-- Name: vitaminnutrient_vitamin_nutrient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vitaminnutrient_vitamin_nutrient_id_seq OWNED BY public.vitaminnutrient.vitamin_nutrient_id;


--
-- TOC entry 255 (class 1259 OID 21526)
-- Name: vitaminrda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vitaminrda (
    vitamin_rda_id integer NOT NULL,
    vitamin_id integer,
    sex character varying(10),
    age_min integer,
    age_max integer,
    rda_value numeric(10,3),
    unit character varying(20),
    notes text
);


ALTER TABLE public.vitaminrda OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 21525)
-- Name: vitaminrda_vitamin_rda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vitaminrda_vitamin_rda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vitaminrda_vitamin_rda_id_seq OWNER TO postgres;

--
-- TOC entry 6706 (class 0 OID 0)
-- Dependencies: 254
-- Name: vitaminrda_vitamin_rda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vitaminrda_vitamin_rda_id_seq OWNED BY public.vitaminrda.vitamin_rda_id;


--
-- TOC entry 348 (class 1259 OID 22676)
-- Name: vw_user_moderation; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_user_moderation AS
 SELECT u.user_id,
    u.full_name,
    u.email,
    uas.is_blocked,
    uas.blocked_reason,
    uas.blocked_at,
    u.last_login,
    ( SELECT r.status
           FROM public.user_unblock_request r
          WHERE (r.user_id = u.user_id)
          ORDER BY r.created_at DESC
         LIMIT 1) AS latest_request_status
   FROM (public."User" u
     LEFT JOIN public.user_account_status uas ON ((u.user_id = uas.user_id)));


ALTER VIEW public.vw_user_moderation OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 22022)
-- Name: vw_user_nutrient_notifications; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_user_nutrient_notifications AS
 SELECT notification_id,
    user_id,
    nutrient_type,
    nutrient_id,
    nutrient_name,
    notification_type,
    title,
    message,
    severity,
    is_read,
    metadata,
    created_at,
        CASE
            WHEN (created_at > (now() - '01:00:00'::interval)) THEN 'new'::text
            WHEN (created_at > (now() - '24:00:00'::interval)) THEN 'recent'::text
            ELSE 'old'::text
        END AS freshness
   FROM public.usernutrientnotification unn
  ORDER BY created_at DESC;


ALTER VIEW public.vw_user_nutrient_notifications OWNER TO postgres;

--
-- TOC entry 367 (class 1259 OID 22922)
-- Name: waterlog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.waterlog (
    water_log_id integer NOT NULL,
    user_id integer,
    amount_ml numeric NOT NULL,
    log_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    drink_id integer,
    drink_name character varying(200),
    hydration_ratio numeric(5,2) DEFAULT 1.0,
    notes text
);


ALTER TABLE public.waterlog OWNER TO postgres;

--
-- TOC entry 364 (class 1259 OID 22919)
-- Name: waterlog_water_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.waterlog_water_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.waterlog_water_log_id_seq OWNER TO postgres;

--
-- TOC entry 6707 (class 0 OID 0)
-- Dependencies: 364
-- Name: waterlog_water_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.waterlog_water_log_id_seq OWNED BY public.waterlog.water_log_id;


--
-- TOC entry 5341 (class 2604 OID 21092)
-- Name: User user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User" ALTER COLUMN user_id SET DEFAULT nextval('public."User_user_id_seq"'::regclass);


--
-- TOC entry 5367 (class 2604 OID 21163)
-- Name: admin admin_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin ALTER COLUMN admin_id SET DEFAULT nextval('public.admin_admin_id_seq'::regclass);


--
-- TOC entry 5575 (class 2604 OID 22927)
-- Name: admin_verification verification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_verification ALTER COLUMN verification_id SET DEFAULT nextval('public.admin_verification_verification_id_seq'::regclass);


--
-- TOC entry 5491 (class 2604 OID 22099)
-- Name: adminconversation admin_conversation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminconversation ALTER COLUMN admin_conversation_id SET DEFAULT nextval('public.adminconversation_admin_conversation_id_seq'::regclass);


--
-- TOC entry 5495 (class 2604 OID 22120)
-- Name: adminmessage admin_message_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminmessage ALTER COLUMN admin_message_id SET DEFAULT nextval('public.adminmessage_admin_message_id_seq'::regclass);


--
-- TOC entry 5438 (class 2604 OID 21789)
-- Name: aminoacid amino_acid_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aminoacid ALTER COLUMN amino_acid_id SET DEFAULT nextval('public.aminoacid_amino_acid_id_seq'::regclass);


--
-- TOC entry 5441 (class 2604 OID 21805)
-- Name: aminorequirement amino_requirement_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aminorequirement ALTER COLUMN amino_requirement_id SET DEFAULT nextval('public.aminorequirement_amino_requirement_id_seq'::regclass);


--
-- TOC entry 5481 (class 2604 OID 22033)
-- Name: bodymeasurement measurement_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bodymeasurement ALTER COLUMN measurement_id SET DEFAULT nextval('public.bodymeasurement_measurement_id_seq'::regclass);


--
-- TOC entry 5485 (class 2604 OID 22059)
-- Name: chatbotconversation conversation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbotconversation ALTER COLUMN conversation_id SET DEFAULT nextval('public.chatbotconversation_conversation_id_seq'::regclass);


--
-- TOC entry 5489 (class 2604 OID 22078)
-- Name: chatbotmessage message_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbotmessage ALTER COLUMN message_id SET DEFAULT nextval('public.chatbotmessage_message_id_seq'::regclass);


--
-- TOC entry 5635 (class 2604 OID 24511)
-- Name: communitymessage message_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communitymessage ALTER COLUMN message_id SET DEFAULT nextval('public.communitymessage_message_id_seq'::regclass);


--
-- TOC entry 5519 (class 2604 OID 22364)
-- Name: conditioneffectlog log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditioneffectlog ALTER COLUMN log_id SET DEFAULT nextval('public.conditioneffectlog_log_id_seq'::regclass);


--
-- TOC entry 5517 (class 2604 OID 22340)
-- Name: conditionfoodrecommendation recommendation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionfoodrecommendation ALTER COLUMN recommendation_id SET DEFAULT nextval('public.conditionfoodrecommendation_recommendation_id_seq'::regclass);


--
-- TOC entry 5516 (class 2604 OID 22316)
-- Name: conditionnutrienteffect effect_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionnutrienteffect ALTER COLUMN effect_id SET DEFAULT nextval('public.conditionnutrienteffect_effect_id_seq'::regclass);


--
-- TOC entry 5392 (class 2604 OID 21337)
-- Name: dailysummary summary_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dailysummary ALTER COLUMN summary_id SET DEFAULT nextval('public.dailysummary_summary_id_seq'::regclass);


--
-- TOC entry 5551 (class 2604 OID 22685)
-- Name: dish dish_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish ALTER COLUMN dish_id SET DEFAULT nextval('public.dish_dish_id_seq'::regclass);


--
-- TOC entry 5560 (class 2604 OID 22749)
-- Name: dishimage dish_image_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishimage ALTER COLUMN dish_image_id SET DEFAULT nextval('public.dishimage_dish_image_id_seq'::regclass);


--
-- TOC entry 5558 (class 2604 OID 22719)
-- Name: dishingredient dish_ingredient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishingredient ALTER COLUMN dish_ingredient_id SET DEFAULT nextval('public.dishingredient_dish_ingredient_id_seq'::regclass);


--
-- TOC entry 5572 (class 2604 OID 22846)
-- Name: dishnotification notification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnotification ALTER COLUMN notification_id SET DEFAULT nextval('public.dishnotification_notification_id_seq'::regclass);


--
-- TOC entry 5569 (class 2604 OID 22800)
-- Name: dishnutrient dish_nutrient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnutrient ALTER COLUMN dish_nutrient_id SET DEFAULT nextval('public.dishnutrient_dish_nutrient_id_seq'::regclass);


--
-- TOC entry 5565 (class 2604 OID 22779)
-- Name: dishstatistics stat_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishstatistics ALTER COLUMN stat_id SET DEFAULT nextval('public.dishstatistics_stat_id_seq'::regclass);


--
-- TOC entry 5597 (class 2604 OID 23796)
-- Name: drink drink_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drink ALTER COLUMN drink_id SET DEFAULT nextval('public.drink_drink_id_seq'::regclass);


--
-- TOC entry 5608 (class 2604 OID 23834)
-- Name: drinkingredient drink_ingredient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkingredient ALTER COLUMN drink_ingredient_id SET DEFAULT nextval('public.drinkingredient_drink_ingredient_id_seq'::regclass);


--
-- TOC entry 5611 (class 2604 OID 23864)
-- Name: drinknutrient drink_nutrient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinknutrient ALTER COLUMN drink_nutrient_id SET DEFAULT nextval('public.drinknutrient_drink_nutrient_id_seq'::regclass);


--
-- TOC entry 5613 (class 2604 OID 23889)
-- Name: drinkstatistics stat_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkstatistics ALTER COLUMN stat_id SET DEFAULT nextval('public.drinkstatistics_stat_id_seq'::regclass);


--
-- TOC entry 5617 (class 2604 OID 23973)
-- Name: drug drug_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug ALTER COLUMN drug_id SET DEFAULT nextval('public.drug_drug_id_seq'::regclass);


--
-- TOC entry 5621 (class 2604 OID 23994)
-- Name: drughealthcondition drug_condition_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drughealthcondition ALTER COLUMN drug_condition_id SET DEFAULT nextval('public.drughealthcondition_drug_condition_id_seq'::regclass);


--
-- TOC entry 5624 (class 2604 OID 24022)
-- Name: drugnutrientcontraindication contra_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drugnutrientcontraindication ALTER COLUMN contra_id SET DEFAULT nextval('public.drugnutrientcontraindication_contra_id_seq'::regclass);


--
-- TOC entry 5417 (class 2604 OID 21627)
-- Name: fattyacid fatty_acid_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fattyacid ALTER COLUMN fatty_acid_id SET DEFAULT nextval('public.fattyacid_fatty_acid_id_seq'::regclass);


--
-- TOC entry 5426 (class 2604 OID 21663)
-- Name: fattyacidrequirement fa_req_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fattyacidrequirement ALTER COLUMN fa_req_id SET DEFAULT nextval('public.fattyacidrequirement_fa_req_id_seq'::regclass);


--
-- TOC entry 5412 (class 2604 OID 21609)
-- Name: fiber fiber_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fiber ALTER COLUMN fiber_id SET DEFAULT nextval('public.fiber_fiber_id_seq'::regclass);


--
-- TOC entry 5422 (class 2604 OID 21645)
-- Name: fiberrequirement fiber_req_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fiberrequirement ALTER COLUMN fiber_req_id SET DEFAULT nextval('public.fiberrequirement_fiber_req_id_seq'::regclass);


--
-- TOC entry 5371 (class 2604 OID 21206)
-- Name: food food_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food ALTER COLUMN food_id SET DEFAULT nextval('public.food_food_id_seq'::regclass);


--
-- TOC entry 5500 (class 2604 OID 22195)
-- Name: foodcategory category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodcategory ALTER COLUMN category_id SET DEFAULT nextval('public.foodcategory_category_id_seq'::regclass);


--
-- TOC entry 5379 (class 2604 OID 21239)
-- Name: foodnutrient food_nutrient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodnutrient ALTER COLUMN food_nutrient_id SET DEFAULT nextval('public.foodnutrient_food_nutrient_id_seq'::regclass);


--
-- TOC entry 5380 (class 2604 OID 21259)
-- Name: foodtag tag_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodtag ALTER COLUMN tag_id SET DEFAULT nextval('public.foodtag_tag_id_seq'::regclass);


--
-- TOC entry 5629 (class 2604 OID 24452)
-- Name: friendrequest request_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendrequest ALTER COLUMN request_id SET DEFAULT nextval('public.friendrequest_request_id_seq'::regclass);


--
-- TOC entry 5633 (class 2604 OID 24482)
-- Name: friendship friendship_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendship ALTER COLUMN friendship_id SET DEFAULT nextval('public.friendship_friendship_id_seq'::regclass);


--
-- TOC entry 5502 (class 2604 OID 22229)
-- Name: healthcondition condition_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.healthcondition ALTER COLUMN condition_id SET DEFAULT nextval('public.healthcondition_condition_id_seq'::regclass);


--
-- TOC entry 5381 (class 2604 OID 21285)
-- Name: meal meal_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal ALTER COLUMN meal_id SET DEFAULT nextval('public.meal_meal_id_seq'::regclass);


--
-- TOC entry 5457 (class 2604 OID 21893)
-- Name: meal_entries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_entries ALTER COLUMN id SET DEFAULT nextval('public.meal_entries_id_seq'::regclass);


--
-- TOC entry 5384 (class 2604 OID 21301)
-- Name: mealitem meal_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealitem ALTER COLUMN meal_item_id SET DEFAULT nextval('public.mealitem_meal_item_id_seq'::regclass);


--
-- TOC entry 5390 (class 2604 OID 21321)
-- Name: mealnote note_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealnote ALTER COLUMN note_id SET DEFAULT nextval('public.mealnote_note_id_seq'::regclass);


--
-- TOC entry 5531 (class 2604 OID 22470)
-- Name: mealtemplate template_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealtemplate ALTER COLUMN template_id SET DEFAULT nextval('public.mealtemplate_template_id_seq'::regclass);


--
-- TOC entry 5536 (class 2604 OID 22491)
-- Name: mealtemplateitem template_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealtemplateitem ALTER COLUMN template_item_id SET DEFAULT nextval('public.mealtemplateitem_template_item_id_seq'::regclass);


--
-- TOC entry 5513 (class 2604 OID 22292)
-- Name: medicationlog log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationlog ALTER COLUMN log_id SET DEFAULT nextval('public.medicationlog_log_id_seq'::regclass);


--
-- TOC entry 5510 (class 2604 OID 22271)
-- Name: medicationschedule medication_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationschedule ALTER COLUMN medication_id SET DEFAULT nextval('public.medicationschedule_medication_id_seq'::regclass);


--
-- TOC entry 5639 (class 2604 OID 24533)
-- Name: messagereaction reaction_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messagereaction ALTER COLUMN reaction_id SET DEFAULT nextval('public.messagereaction_reaction_id_seq'::regclass);


--
-- TOC entry 5407 (class 2604 OID 21544)
-- Name: mineral mineral_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineral ALTER COLUMN mineral_id SET DEFAULT nextval('public.mineral_mineral_id_seq'::regclass);


--
-- TOC entry 5588 (class 2604 OID 23155)
-- Name: mineralnutrient mineral_nutrient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineralnutrient ALTER COLUMN mineral_nutrient_id SET DEFAULT nextval('public.mineralnutrient_mineral_nutrient_id_seq'::regclass);


--
-- TOC entry 5410 (class 2604 OID 21565)
-- Name: mineralrda mineral_rda_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineralrda ALTER COLUMN mineral_rda_id SET DEFAULT nextval('public.mineralrda_mineral_rda_id_seq'::regclass);


--
-- TOC entry 5377 (class 2604 OID 21223)
-- Name: nutrient nutrient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrient ALTER COLUMN nutrient_id SET DEFAULT nextval('public.nutrient_nutrient_id_seq'::regclass);


--
-- TOC entry 5471 (class 2604 OID 21948)
-- Name: nutrientcontraindication contra_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientcontraindication ALTER COLUMN contra_id SET DEFAULT nextval('public.nutrientcontraindication_contra_id_seq'::regclass);


--
-- TOC entry 5436 (class 2604 OID 21761)
-- Name: nutrientmapping mapping_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientmapping ALTER COLUMN mapping_id SET DEFAULT nextval('public.nutrientmapping_mapping_id_seq'::regclass);


--
-- TOC entry 5498 (class 2604 OID 22144)
-- Name: nutritionanalysis analysis_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutritionanalysis ALTER COLUMN analysis_id SET DEFAULT nextval('public.nutritionanalysis_analysis_id_seq'::regclass);


--
-- TOC entry 5542 (class 2604 OID 22584)
-- Name: passwordchangecode id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passwordchangecode ALTER COLUMN id SET DEFAULT nextval('public.passwordchangecode_id_seq'::regclass);


--
-- TOC entry 5580 (class 2604 OID 23085)
-- Name: permission permission_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permission ALTER COLUMN permission_id SET DEFAULT nextval('public.permission_permission_id_seq'::regclass);


--
-- TOC entry 5521 (class 2604 OID 22403)
-- Name: portionsize portion_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portionsize ALTER COLUMN portion_id SET DEFAULT nextval('public.portionsize_portion_id_seq'::regclass);


--
-- TOC entry 5642 (class 2604 OID 24558)
-- Name: privateconversation conversation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privateconversation ALTER COLUMN conversation_id SET DEFAULT nextval('public.privateconversation_conversation_id_seq'::regclass);


--
-- TOC entry 5645 (class 2604 OID 24585)
-- Name: privatemessage message_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privatemessage ALTER COLUMN message_id SET DEFAULT nextval('public.privatemessage_message_id_seq'::regclass);


--
-- TOC entry 5524 (class 2604 OID 22421)
-- Name: recipe recipe_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe ALTER COLUMN recipe_id SET DEFAULT nextval('public.recipe_recipe_id_seq'::regclass);


--
-- TOC entry 5529 (class 2604 OID 22441)
-- Name: recipeingredient recipe_ingredient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipeingredient ALTER COLUMN recipe_ingredient_id SET DEFAULT nextval('public.recipeingredient_recipe_ingredient_id_seq'::regclass);


--
-- TOC entry 5370 (class 2604 OID 21178)
-- Name: role role_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role ALTER COLUMN role_id SET DEFAULT nextval('public.role_role_id_seq'::regclass);


--
-- TOC entry 5582 (class 2604 OID 23101)
-- Name: rolepermission role_permission_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolepermission ALTER COLUMN role_permission_id SET DEFAULT nextval('public.rolepermission_role_permission_id_seq'::regclass);


--
-- TOC entry 5399 (class 2604 OID 21356)
-- Name: suggestion suggestion_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggestion ALTER COLUMN suggestion_id SET DEFAULT nextval('public.suggestion_suggestion_id_seq'::regclass);


--
-- TOC entry 5546 (class 2604 OID 22628)
-- Name: user_block_event block_event_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_block_event ALTER COLUMN block_event_id SET DEFAULT nextval('public.user_block_event_block_event_id_seq'::regclass);


--
-- TOC entry 5464 (class 2604 OID 21915)
-- Name: user_meal_summaries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_meal_summaries ALTER COLUMN id SET DEFAULT nextval('public.user_meal_summaries_id_seq'::regclass);


--
-- TOC entry 5449 (class 2604 OID 21869)
-- Name: user_meal_targets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_meal_targets ALTER COLUMN id SET DEFAULT nextval('public.user_meal_targets_id_seq'::regclass);


--
-- TOC entry 5548 (class 2604 OID 22653)
-- Name: user_unblock_request request_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_unblock_request ALTER COLUMN request_id SET DEFAULT nextval('public.user_unblock_request_request_id_seq'::regclass);


--
-- TOC entry 5365 (class 2604 OID 21147)
-- Name: useractivitylog log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useractivitylog ALTER COLUMN log_id SET DEFAULT nextval('public.useractivitylog_log_id_seq'::regclass);


--
-- TOC entry 5446 (class 2604 OID 21846)
-- Name: useraminointake intake_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraminointake ALTER COLUMN intake_id SET DEFAULT nextval('public.useraminointake_intake_id_seq'::regclass);


--
-- TOC entry 5434 (class 2604 OID 21741)
-- Name: userfattyacidintake intake_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfattyacidintake ALTER COLUMN intake_id SET DEFAULT nextval('public.userfattyacidintake_intake_id_seq'::regclass);


--
-- TOC entry 5432 (class 2604 OID 21721)
-- Name: userfiberintake intake_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfiberintake ALTER COLUMN intake_id SET DEFAULT nextval('public.userfiberintake_intake_id_seq'::regclass);


--
-- TOC entry 5400 (class 2604 OID 21396)
-- Name: usergoal goal_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usergoal ALTER COLUMN goal_id SET DEFAULT nextval('public.usergoal_goal_id_seq'::regclass);


--
-- TOC entry 5505 (class 2604 OID 22245)
-- Name: userhealthcondition user_condition_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userhealthcondition ALTER COLUMN user_condition_id SET DEFAULT nextval('public.userhealthcondition_user_condition_id_seq'::regclass);


--
-- TOC entry 5648 (class 2604 OID 29006)
-- Name: usermedication user_medication_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermedication ALTER COLUMN user_medication_id SET DEFAULT nextval('public.usermedication_user_medication_id_seq'::regclass);


--
-- TOC entry 5592 (class 2604 OID 23756)
-- Name: usernutrientmanuallog log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrientmanuallog ALTER COLUMN log_id SET DEFAULT nextval('public.usernutrientmanuallog_log_id_seq'::regclass);


--
-- TOC entry 5477 (class 2604 OID 21997)
-- Name: usernutrientnotification notification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrientnotification ALTER COLUMN notification_id SET DEFAULT nextval('public.usernutrientnotification_notification_id_seq'::regclass);


--
-- TOC entry 5473 (class 2604 OID 21975)
-- Name: usernutrienttracking tracking_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrienttracking ALTER COLUMN tracking_id SET DEFAULT nextval('public.usernutrienttracking_tracking_id_seq'::regclass);


--
-- TOC entry 5402 (class 2604 OID 21478)
-- Name: vitamin vitamin_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitamin ALTER COLUMN vitamin_id SET DEFAULT nextval('public.vitamin_vitamin_id_seq'::regclass);


--
-- TOC entry 5584 (class 2604 OID 23126)
-- Name: vitaminnutrient vitamin_nutrient_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitaminnutrient ALTER COLUMN vitamin_nutrient_id SET DEFAULT nextval('public.vitaminnutrient_vitamin_nutrient_id_seq'::regclass);


--
-- TOC entry 5406 (class 2604 OID 21529)
-- Name: vitaminrda vitamin_rda_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitaminrda ALTER COLUMN vitamin_rda_id SET DEFAULT nextval('public.vitaminrda_vitamin_rda_id_seq'::regclass);


--
-- TOC entry 5577 (class 2604 OID 22928)
-- Name: waterlog water_log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waterlog ALTER COLUMN water_log_id SET DEFAULT nextval('public.waterlog_water_log_id_seq'::regclass);


--
-- TOC entry 6395 (class 0 OID 21089)
-- Dependencies: 220
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."User" VALUES (3, 'vmc', 'vmc@gmail.com', '$2a$10$Mmxw2G1Xag49ov9HS/9DYeOb2NbW0eYxaWeeEJzJ0zmJ2Ocp02RPO', 20, 'female', 180.00, 60.00, '2025-11-24 05:23:47.634179', '2025-12-02 02:14:09.113423-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-11-24 05:23:47.634179', NULL);
INSERT INTO public."User" VALUES (2, 'Trương Ngọc Linh', 'truongngoclinh312@gmail.com', '$2a$10$Mm8RcVfF96bAodhPMMUcd.hIRrprvll0j9U06i4Baa8WOKmpmnTWG', 19, 'female', 160.00, 42.00, '2025-11-23 20:43:25.828394', '2025-11-26 16:58:30.11047-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-11-23 20:43:25.828394', NULL);
INSERT INTO public."User" VALUES (4, 'k2', 'truonghoankiet3@gmail.com', '$2a$10$3pjNpQsfJ1SpUFc4hDwhaOUEFkazI2ijpfIbCzo6z505AKSIPqQUa', 21, 'male', 180.00, 60.00, '2025-11-27 04:52:23.478157', '2025-11-27 04:52:30.290034-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-11-27 04:52:23.478157', NULL);
INSERT INTO public."User" VALUES (1, 'k1', 'truonghoankiet1@gmail.com', '$2a$10$OApO5T.eU7fki/0ThPJ.KuxDWUREhS3.b3mGK/SsPlYMZSkkdmEbe', 20, 'male', 174.00, 60.00, '2025-11-19 07:19:15.359239', '2025-11-29 01:38:08.551194-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-11-19 18:29:56.553496', '/uploads/avatars/avatar_1764053523370_1764053523446.jpeg');


--
-- TOC entry 6401 (class 0 OID 21160)
-- Dependencies: 226
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.admin VALUES (1, 'truonghoankiet@gmail.com', '$2a$10$2yLz3oLecSssabunEcrT2.ANxWm9.J60PE1ZRwHwahW/yZv.zATjC', '2025-11-19 07:18:40.627012', false);
INSERT INTO public.admin VALUES (2, 'truonghoankiet3@gmail.com', '$2a$10$4od/qVm8f6a83e3WbnSzZuVjixoLweNbRpTU5SCLZg.PfUeG9IYUu', '2025-11-19 16:30:17.863746', false);


--
-- TOC entry 6531 (class 0 OID 22921)
-- Dependencies: 366
-- Data for Name: admin_verification; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6478 (class 0 OID 22096)
-- Dependencies: 305
-- Data for Name: adminconversation; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.adminconversation VALUES (1, 1, 'active', 'Hỗ trợ khách hàng', '2025-11-19 19:11:13.623869', '2025-11-20 20:28:21.873639');
INSERT INTO public.adminconversation VALUES (2, 2, 'active', 'Hỗ trợ khách hàng', '2025-11-23 20:44:25.160152', '2025-11-23 20:44:25.160152');
INSERT INTO public.adminconversation VALUES (3, 3, 'active', 'Hỗ trợ khách hàng', '2025-11-24 05:24:56.365371', '2025-11-24 05:24:56.365371');
INSERT INTO public.adminconversation VALUES (4, 4, 'active', 'Hỗ trợ khách hàng', '2025-11-27 04:52:32.95183', '2025-11-27 04:52:32.95183');


--
-- TOC entry 6480 (class 0 OID 22117)
-- Dependencies: 307
-- Data for Name: adminmessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.adminmessage VALUES (1, 1, 'user', 1, 'Xin chào', NULL, true, '2025-11-19 19:11:17.739636');
INSERT INTO public.adminmessage VALUES (2, 1, 'user', 1, '123', NULL, true, '2025-11-19 22:55:01.273442');
INSERT INTO public.adminmessage VALUES (3, 1, 'user', 1, 'dfsaf', NULL, true, '2025-11-19 22:55:09.327581');
INSERT INTO public.adminmessage VALUES (4, 1, 'user', 1, 'fa', NULL, true, '2025-11-19 23:34:13.138275');
INSERT INTO public.adminmessage VALUES (7, 1, 'user', 1, 'không có gì', NULL, true, '2025-11-23 20:40:38.741655');
INSERT INTO public.adminmessage VALUES (5, 1, 'admin', 1, 'Chào bạn', NULL, true, '2025-11-20 19:02:03.663145');
INSERT INTO public.adminmessage VALUES (6, 1, 'admin', 1, 'Bạn đang gặp vấn đề gì cần mình hỗ trợ không ?', NULL, true, '2025-11-20 20:28:21.864931');


--
-- TOC entry 6404 (class 0 OID 21185)
-- Dependencies: 229
-- Data for Name: adminrole; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.adminrole VALUES (1, 1);


--
-- TOC entry 6453 (class 0 OID 21786)
-- Dependencies: 278
-- Data for Name: aminoacid; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.aminoacid VALUES (1, 'ILE', 'Isoleucine', '#A8E6A3', true, '2025-11-20 19:11:02.837067-08');
INSERT INTO public.aminoacid VALUES (2, 'PHE', 'Phenylalanine', '#F4A7B9', false, '2025-11-20 19:11:02.837067-08');
INSERT INTO public.aminoacid VALUES (3, 'HIS', 'Histidine', '#B58ED9', false, '2025-11-20 19:11:02.837067-08');
INSERT INTO public.aminoacid VALUES (4, 'LYS', 'Lysine', '#4CC9F0', true, '2025-11-20 19:11:02.837067-08');
INSERT INTO public.aminoacid VALUES (5, 'THR', 'Threonine', '#76D7C4', false, '2025-11-20 19:11:02.837067-08');
INSERT INTO public.aminoacid VALUES (6, 'VAL', 'Valine', '#FFB570', true, '2025-11-20 19:11:02.837067-08');
INSERT INTO public.aminoacid VALUES (7, 'TRP', 'Tryptophan', '#6A5ACD', true, '2025-11-20 19:11:02.837067-08');
INSERT INTO public.aminoacid VALUES (8, 'MET', 'Methionine', '#F6D55C', true, '2025-11-20 19:11:02.837067-08');
INSERT INTO public.aminoacid VALUES (9, 'LEU', 'Leucine', '#E76F51', true, '2025-11-20 19:11:02.837067-08');


--
-- TOC entry 6455 (class 0 OID 21802)
-- Dependencies: 280
-- Data for Name: aminorequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.aminorequirement VALUES (10, 3, NULL, 0, 0, true, 28, 'mg', 'WHO/FAO requirement for infants 0-6 months');
INSERT INTO public.aminorequirement VALUES (11, 3, NULL, 1, 1, true, 20, 'mg', 'WHO/FAO requirement for infants 7-12 months');
INSERT INTO public.aminorequirement VALUES (12, 3, NULL, 1, 3, true, 16, 'mg', 'WHO/FAO requirement for children 1-3 years');
INSERT INTO public.aminorequirement VALUES (13, 3, NULL, 4, 8, true, 15, 'mg', 'WHO/FAO requirement for children 4-8 years');
INSERT INTO public.aminorequirement VALUES (14, 3, NULL, 19, 120, true, 14, 'mg', 'WHO/FAO adult requirement 14 mg/kg/day');
INSERT INTO public.aminorequirement VALUES (15, 1, NULL, 0, 0, true, 46, 'mg', 'WHO/FAO requirement for infants 0-6 months');
INSERT INTO public.aminorequirement VALUES (16, 1, NULL, 1, 1, true, 43, 'mg', 'WHO/FAO requirement for infants 7-12 months');
INSERT INTO public.aminorequirement VALUES (17, 1, NULL, 1, 3, true, 28, 'mg', 'WHO/FAO requirement for children 1-3 years');
INSERT INTO public.aminorequirement VALUES (18, 1, NULL, 4, 8, true, 22, 'mg', 'WHO/FAO requirement for children 4-8 years');
INSERT INTO public.aminorequirement VALUES (19, 1, NULL, 19, 120, true, 19, 'mg', 'WHO/FAO adult requirement 19 mg/kg/day');
INSERT INTO public.aminorequirement VALUES (20, 9, NULL, 0, 0, true, 93, 'mg', 'WHO/FAO requirement for infants 0-6 months');
INSERT INTO public.aminorequirement VALUES (21, 9, NULL, 1, 1, true, 89, 'mg', 'WHO/FAO requirement for infants 7-12 months');
INSERT INTO public.aminorequirement VALUES (22, 9, NULL, 1, 3, true, 63, 'mg', 'WHO/FAO requirement for children 1-3 years');
INSERT INTO public.aminorequirement VALUES (23, 9, NULL, 4, 8, true, 49, 'mg', 'WHO/FAO requirement for children 4-8 years');
INSERT INTO public.aminorequirement VALUES (24, 9, NULL, 19, 120, true, 42, 'mg', 'WHO/FAO adult requirement 42 mg/kg/day');
INSERT INTO public.aminorequirement VALUES (25, 4, NULL, 0, 0, true, 66, 'mg', 'WHO/FAO requirement for infants 0-6 months');
INSERT INTO public.aminorequirement VALUES (26, 4, NULL, 1, 1, true, 64, 'mg', 'WHO/FAO requirement for infants 7-12 months');
INSERT INTO public.aminorequirement VALUES (27, 4, NULL, 1, 3, true, 58, 'mg', 'WHO/FAO requirement for children 1-3 years');
INSERT INTO public.aminorequirement VALUES (28, 4, NULL, 4, 8, true, 45, 'mg', 'WHO/FAO requirement for children 4-8 years');
INSERT INTO public.aminorequirement VALUES (29, 4, NULL, 19, 120, true, 30, 'mg', 'WHO/FAO adult requirement 30 mg/kg/day');
INSERT INTO public.aminorequirement VALUES (30, 8, NULL, 0, 0, true, 33, 'mg', 'WHO/FAO requirement for infants 0-6 months (Met + Cys)');
INSERT INTO public.aminorequirement VALUES (31, 8, NULL, 1, 1, true, 30, 'mg', 'WHO/FAO requirement for infants 7-12 months (Met + Cys)');
INSERT INTO public.aminorequirement VALUES (32, 8, NULL, 1, 3, true, 27, 'mg', 'WHO/FAO requirement for children 1-3 years (Met + Cys)');
INSERT INTO public.aminorequirement VALUES (33, 8, NULL, 4, 8, true, 21, 'mg', 'WHO/FAO requirement for children 4-8 years (Met + Cys)');
INSERT INTO public.aminorequirement VALUES (34, 8, NULL, 19, 120, true, 15, 'mg', 'WHO/FAO adult requirement 15 mg/kg/day (Met + Cys)');
INSERT INTO public.aminorequirement VALUES (35, 2, NULL, 0, 0, true, 52, 'mg', 'WHO/FAO requirement for infants 0-6 months (Phe + Tyr)');
INSERT INTO public.aminorequirement VALUES (36, 2, NULL, 1, 1, true, 46, 'mg', 'WHO/FAO requirement for infants 7-12 months (Phe + Tyr)');
INSERT INTO public.aminorequirement VALUES (37, 2, NULL, 1, 3, true, 41, 'mg', 'WHO/FAO requirement for children 1-3 years (Phe + Tyr)');
INSERT INTO public.aminorequirement VALUES (38, 2, NULL, 4, 8, true, 31, 'mg', 'WHO/FAO requirement for children 4-8 years (Phe + Tyr)');
INSERT INTO public.aminorequirement VALUES (39, 2, NULL, 19, 120, true, 25, 'mg', 'WHO/FAO adult requirement 25 mg/kg/day (Phe + Tyr)');
INSERT INTO public.aminorequirement VALUES (40, 5, NULL, 0, 0, true, 43, 'mg', 'WHO/FAO requirement for infants 0-6 months');
INSERT INTO public.aminorequirement VALUES (41, 5, NULL, 1, 1, true, 35, 'mg', 'WHO/FAO requirement for infants 7-12 months');
INSERT INTO public.aminorequirement VALUES (42, 5, NULL, 1, 3, true, 34, 'mg', 'WHO/FAO requirement for children 1-3 years');
INSERT INTO public.aminorequirement VALUES (43, 5, NULL, 4, 8, true, 28, 'mg', 'WHO/FAO requirement for children 4-8 years');
INSERT INTO public.aminorequirement VALUES (44, 5, NULL, 19, 120, true, 15, 'mg', 'WHO/FAO adult requirement 15 mg/kg/day');
INSERT INTO public.aminorequirement VALUES (45, 7, NULL, 0, 0, true, 12.5, 'mg', 'WHO/FAO requirement for infants 0-6 months');
INSERT INTO public.aminorequirement VALUES (46, 7, NULL, 1, 1, true, 11, 'mg', 'WHO/FAO requirement for infants 7-12 months');
INSERT INTO public.aminorequirement VALUES (47, 7, NULL, 1, 3, true, 8.5, 'mg', 'WHO/FAO requirement for children 1-3 years');
INSERT INTO public.aminorequirement VALUES (48, 7, NULL, 4, 8, true, 6.6, 'mg', 'WHO/FAO requirement for children 4-8 years');
INSERT INTO public.aminorequirement VALUES (49, 7, NULL, 19, 120, true, 4, 'mg', 'WHO/FAO adult requirement 4 mg/kg/day');
INSERT INTO public.aminorequirement VALUES (50, 6, NULL, 0, 0, true, 55, 'mg', 'WHO/FAO requirement for infants 0-6 months');
INSERT INTO public.aminorequirement VALUES (51, 6, NULL, 1, 1, true, 49, 'mg', 'WHO/FAO requirement for infants 7-12 months');
INSERT INTO public.aminorequirement VALUES (52, 6, NULL, 1, 3, true, 37, 'mg', 'WHO/FAO requirement for children 1-3 years');
INSERT INTO public.aminorequirement VALUES (53, 6, NULL, 4, 8, true, 29, 'mg', 'WHO/FAO requirement for children 4-8 years');
INSERT INTO public.aminorequirement VALUES (54, 6, NULL, 19, 120, true, 26, 'mg', 'WHO/FAO adult requirement 26 mg/kg/day');


--
-- TOC entry 6472 (class 0 OID 22030)
-- Dependencies: 299
-- Data for Name: bodymeasurement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.bodymeasurement VALUES (1, 1, '2025-11-19 07:19:57.574968', 60.00, 174.00, 19.82, 9, 'normal', 'profile_update', 'Auto-created from profile update', '2025-11-19 07:19:57.574968');
INSERT INTO public.bodymeasurement VALUES (2, 2, '2025-11-23 20:44:04.627771', 42.00, 160.00, 16.41, 3, 'underweight', 'profile_update', 'Auto-created from profile update', '2025-11-23 20:44:04.627771');
INSERT INTO public.bodymeasurement VALUES (3, 3, '2025-11-24 05:24:39.709436', 60.00, 180.00, 18.52, 9, 'normal', 'profile_update', 'Auto-created from profile update', '2025-11-24 05:24:39.709436');
INSERT INTO public.bodymeasurement VALUES (4, 1, '2025-11-24 22:52:03.733412', 60.00, 174.00, 19.82, 9, 'normal', 'profile_update', 'Auto-created from profile update', '2025-11-24 22:52:03.733412');
INSERT INTO public.bodymeasurement VALUES (5, 1, '2025-11-24 22:52:15.989212', 60.00, 174.00, 19.82, 9, 'normal', 'profile_update', 'Auto-created from profile update', '2025-11-24 22:52:15.989212');
INSERT INTO public.bodymeasurement VALUES (6, 3, '2025-11-29 01:32:36.375268', 60.00, 180.00, 18.52, 9, 'normal', 'profile_update', 'Auto-created from profile update', '2025-11-29 01:32:36.375268');


--
-- TOC entry 6474 (class 0 OID 22056)
-- Dependencies: 301
-- Data for Name: chatbotconversation; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.chatbotconversation VALUES (1, 1, 'New conversation', '2025-11-19 19:11:13.476368', '2025-11-19 19:11:13.476368');
INSERT INTO public.chatbotconversation VALUES (2, 2, 'New conversation', '2025-11-23 20:44:25.100477', '2025-11-23 20:44:25.100477');
INSERT INTO public.chatbotconversation VALUES (3, 3, 'New conversation', '2025-11-24 05:24:56.282746', '2025-11-24 05:24:56.282746');
INSERT INTO public.chatbotconversation VALUES (4, 4, 'New conversation', '2025-11-27 04:52:32.83719', '2025-11-27 04:52:32.83719');


--
-- TOC entry 6476 (class 0 OID 22075)
-- Dependencies: 303
-- Data for Name: chatbotmessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.chatbotmessage VALUES (1, 1, 'user', 'Phân tích dinh dưỡng ảnh này', '/uploads/chat/food-1763624237138.jpg', NULL, NULL, '2025-11-19 23:37:17.141989');
INSERT INTO public.chatbotmessage VALUES (3, 1, 'user', 'Phân tích dinh dưỡng ảnh này', '/uploads/chat/food-1763642795572.jpg', NULL, NULL, '2025-11-20 04:46:35.57444');
INSERT INTO public.chatbotmessage VALUES (2, 1, 'bot', 'Tôi đã phân tích món: Phở Bò. Vui lòng xác nhận kết quả dinh dưỡng bên dưới.', NULL, '{"food_name": "Phở Bò", "nutrients": [{"unit": "mg", "amount": 0.1, "nutrient_code": "VITB1", "nutrient_name": "Vitamin B1 (Thiamine)"}, {"unit": "mg", "amount": 3, "nutrient_code": "VITB3", "nutrient_name": "Vitamin B3 (Niacin)"}, {"unit": "mg", "amount": 0.3, "nutrient_code": "VITB6", "nutrient_name": "Vitamin B6 (Pyridoxine)"}, {"unit": "µg", "amount": 0.8, "nutrient_code": "VITB12", "nutrient_name": "Vitamin B12 (Cobalamin)"}, {"unit": "mg", "amount": 2.5, "nutrient_code": "MIN_FE", "nutrient_name": "Iron (Fe)"}, {"unit": "mg", "amount": 250, "nutrient_code": "MIN_K", "nutrient_name": "Potassium (K)"}, {"unit": "mg", "amount": 800, "nutrient_code": "MIN_NA", "nutrient_name": "Sodium (Na)"}, {"unit": "mg", "amount": 2, "nutrient_code": "MIN_ZN", "nutrient_name": "Zinc (Zn)"}, {"unit": "mg", "amount": 150, "nutrient_code": "MIN_P", "nutrient_name": "Phosphorus (P)"}], "confidence": 0.95}', true, '2025-11-19 23:37:21.135124');
INSERT INTO public.chatbotmessage VALUES (5, 1, 'user', 'Xin chào bạn, bạn có thể tự giới thiệu với bạn được không ?', NULL, NULL, NULL, '2025-11-20 20:13:54.218295');
INSERT INTO public.chatbotmessage VALUES (6, 1, 'bot', 'Chào bạn! Tôi là trợ lý AI về dinh dưỡng của ứng dụng My Diary. Tôi có thể giúp bạn: Tư vấn dinh dưỡng dựa trên tình trạng sức khỏe, Gợi ý thực phẩm/món ăn phù hợp, Giải thích giá trị dinh dưỡng và lợi ích sức khỏe, Hướng dẫn chế độ ăn cho từng bệnh cụ thể, Trả lời câu hỏi về thực phẩm Việt Nam, Phân tích thành phần dinh dưỡng của món ăn, Hãy cho tôi biết bạn cần gì nhé!.', NULL, NULL, NULL, '2025-11-20 20:14:03.700355');
INSERT INTO public.chatbotmessage VALUES (4, 1, 'bot', 'Tôi đã phân tích món: Phở Bò. Vui lòng xác nhận kết quả dinh dưỡng bên dưới.', NULL, '{"food_name": "Phở Bò", "nutrients": [{"unit": "kcal", "amount": 250, "nutrient_code": "ENERC_KCAL", "nutrient_name": "Calories"}, {"unit": "g", "amount": 20, "nutrient_code": "PROCNT", "nutrient_name": "Protein"}, {"unit": "g", "amount": 8, "nutrient_code": "FAT", "nutrient_name": "Total Fat"}, {"unit": "g", "amount": 25, "nutrient_code": "CHOCDF", "nutrient_name": "Total Carbohydrate"}, {"unit": "g", "amount": 1, "nutrient_code": "FIBTG", "nutrient_name": "Total Fiber"}, {"unit": "mg", "amount": 700, "nutrient_code": "MIN_NA", "nutrient_name": "Sodium"}, {"unit": "mg", "amount": 2, "nutrient_code": "MIN_FE", "nutrient_name": "Iron"}, {"unit": "µg", "amount": 1, "nutrient_code": "VITB12", "nutrient_name": "Vitamin B12"}, {"unit": "g", "amount": 0.05, "nutrient_code": "ALA", "nutrient_name": "Alpha-linolenic Acid (Omega-3)"}], "confidence": 0.95}', true, '2025-11-20 04:46:40.792613');


--
-- TOC entry 6562 (class 0 OID 24508)
-- Dependencies: 398
-- Data for Name: communitymessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.communitymessage VALUES (1, 1, 'Chào mọi người', NULL, '2025-11-23 20:40:08.810223', '2025-11-23 20:40:08.810223', false, NULL);
INSERT INTO public.communitymessage VALUES (2, 2, 'Chào bạn', NULL, '2025-11-23 22:04:53.788448', '2025-11-23 22:04:53.788448', false, NULL);
INSERT INTO public.communitymessage VALUES (3, 1, NULL, '/uploads/community/community_1763990202528_1763990202705.png', '2025-11-24 05:16:42.743018', '2025-11-24 05:16:42.743018', false, NULL);
INSERT INTO public.communitymessage VALUES (4, 1, 'trái này là trái gì thế', NULL, '2025-11-24 05:16:57.80768', '2025-11-24 05:16:57.80768', false, NULL);
INSERT INTO public.communitymessage VALUES (5, 1, 'mình không biết trái này là trái gì', NULL, '2025-11-24 05:18:55.640006', '2025-11-24 05:18:55.640006', false, NULL);
INSERT INTO public.communitymessage VALUES (6, 3, NULL, '/uploads/community/community_1763990858300_1763990858309.jpeg', '2025-11-24 05:27:38.359857', '2025-11-24 05:27:38.359857', false, NULL);
INSERT INTO public.communitymessage VALUES (7, 1, 'oh ai đồ vờ mờ cờ', NULL, '2025-11-24 06:27:10.019203', '2025-11-24 06:27:10.019203', false, NULL);
INSERT INTO public.communitymessage VALUES (8, 3, 'chào các em trẻ trâu', NULL, '2025-11-24 06:28:13.633195', '2025-11-24 06:28:13.633195', false, NULL);
INSERT INTO public.communitymessage VALUES (9, 1, NULL, '/uploads/community/community_1764205016031_1764205016443.png', '2025-11-26 16:56:56.493098', '2025-11-26 16:56:56.493098', false, NULL);
INSERT INTO public.communitymessage VALUES (10, 1, 'ok', NULL, '2025-11-27 20:39:18.294409', '2025-11-27 20:39:18.294409', false, NULL);


--
-- TOC entry 6498 (class 0 OID 22361)
-- Dependencies: 327
-- Data for Name: conditioneffectlog; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6496 (class 0 OID 22337)
-- Dependencies: 325
-- Data for Name: conditionfoodrecommendation; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6494 (class 0 OID 22313)
-- Dependencies: 323
-- Data for Name: conditionnutrienteffect; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6421 (class 0 OID 21334)
-- Dependencies: 246
-- Data for Name: dailysummary; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dailysummary VALUES (57, 1, '2025-11-22', 0.00, 0.00, 0.00, 0.00, 0.00, 500.00);
INSERT INTO public.dailysummary VALUES (56, 1, '2025-11-23', 265.00, 9.00, 0.00, 49.00, 3.20, 500.00);
INSERT INTO public.dailysummary VALUES (65, 1, '2025-11-24', 3295.00, 1117.00, 0.00, 1267.00, 1069.60, 0.00);
INSERT INTO public.dailysummary VALUES (70, 3, '2025-11-27', 1000.00, 1000.00, 0.00, 1000.00, 1000.00, 0.00);
INSERT INTO public.dailysummary VALUES (71, 3, '2025-11-29', 1000.00, 1000.00, 0.00, 1000.00, 1000.00, 0.00);
INSERT INTO public.dailysummary VALUES (35, 1, '2025-11-18', 0.00, 0.00, 0.00, 0.00, 0.00, 300.00);
INSERT INTO public.dailysummary VALUES (1, 1, '2025-11-19', 608.90, 25.40, 0.00, 112.60, 6.82, 1300.00);
INSERT INTO public.dailysummary VALUES (23, 1, '2025-11-20', 6693.90, 401.40, 0.00, 583.60, 253.62, 5500.00);
INSERT INTO public.dailysummary VALUES (48, 1, '2025-11-21', 4765.00, 279.00, 0.00, 409.00, 183.20, 1250.00);


--
-- TOC entry 6518 (class 0 OID 22682)
-- Dependencies: 350
-- Data for Name: dish; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dish VALUES (31, 'Beef Noodle Soup (Nam Dinh)', 'Phở Nam Định', 'Phở bò kiểu Nam Định với thịt bò chín', 'Breakfast', 700.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.200961', '[]');
INSERT INTO public.dish VALUES (32, 'Vietnamese Savory Pancake', 'Bánh Khọt', 'Bánh khọt tôm, ăn kèm rau sống', 'Snack', 200.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.200961', '[]');
INSERT INTO public.dish VALUES (33, 'Quang Noodle', 'Mì Quảng', 'Mì Quảng với tôm, thịt, đậu phộng, bánh tráng', 'Lunch', 500.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.200961', '[]');
INSERT INTO public.dish VALUES (34, 'Grilled Pork with Rice Paper', 'Thịt Nướng Cuốn Bánh Tráng', 'Thịt heo nướng cuốn bánh tráng, rau sống', 'Dinner', 300.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.200961', '[]');
INSERT INTO public.dish VALUES (35, 'Stir-fried Chicken with Lemongrass', 'Gà Xào Sả Ớt', 'Gà xào sả ớt thơm cay', 'Dinner', 300.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.200961', '[]');
INSERT INTO public.dish VALUES (36, 'Fish Ball Noodle Soup', 'Bún Cá', 'Bún cá với chả cá, cà chua, mắm tôm', 'Lunch', 550.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.200961', '[]');
INSERT INTO public.dish VALUES (37, 'Fried Tofu with Lemongrass Chili', 'Đậu Hũ Chiên Sả Ớt', 'Đậu hũ chiên giòn sốt sả ớt', 'Vegetarian', 250.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.200961', '[]');
INSERT INTO public.dish VALUES (38, 'Pork Skewers', 'Nem Nướng', 'Nem nướng Nha Trang, ăn kèm bánh tráng', 'Snack', 200.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.200961', '[]');
INSERT INTO public.dish VALUES (1, 'Vietnamese Beef Pho', 'Phở Bò Hà Nội', 'Món phở truyền thống với nước dùng hầm xương bò, thịt bò tái, và rau thơm', 'Breakfast', 700.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (10, 'Sour Fish Soup', 'Canh Chua Cá', 'Canh chua với cá, thơm, cà chua, rau muống, đậu bắp', 'Soup', 400.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (2, 'Broken Rice with Grilled Pork', 'Cơm Tấm Sườn Bì Chả', 'Cơm tấm với sườn nướng, bì, chả trứng, và nước mắm pha', 'Breakfast', 400.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (3, 'Banh Mi Vietnamese Sandwich', 'Bánh Mì Thịt Nguội', 'Bánh mì giòn với pate, thịt nguội, dưa chua, rau thơm', 'Breakfast', 250.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (4, 'Sticky Rice with Chicken', 'Xôi Gà', 'Xôi nếp với gà xé phay, hành phi, nước mắm gừng', 'Breakfast', 300.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (5, 'Bun Cha Hanoi', 'Bún Chả Hà Nội', 'Bún với chả nướng, thịt nướng, nước mắm chua ngọt, rau sống', 'Lunch', 500.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (6, 'Vietnamese Spring Rolls', 'Gỏi Cuốn Tôm Thịt', 'Bánh tráng cuốn tôm, thịt, bún, rau sống, chấm nước mắm', 'Lunch', 200.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (7, 'Grilled Fish in Banana Leaf', 'Cá Nướng Lá Chuối', 'Cá nướng với sả ớt, gói lá chuối, ăn kèm bún và rau', 'Dinner', 350.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (8, 'Caramelized Pork Belly', 'Thịt Kho Tàu', 'Thịt ba chỉ kho với nước dừa, trứng, đường caramel', 'Dinner', 250.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (9, 'Braised Fish in Clay Pot', 'Cá Kho Tộ', 'Cá kho với nước mắm, đường, ớt, ăn với cơm trắng', 'Dinner', 300.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (11, 'Vegetarian Pho', 'Phở Chay', 'Phở với nước dùng nấm, đậu hũ, rau củ', 'Vegetarian', 650.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (12, 'Stir-fried Morning Glory', 'Rau Muống Xào Tỏi', 'Rau muống xào với tỏi, nước mắm hoặc muối', 'Vegetarian', 200.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (13, 'Tofu with Tomato Sauce', 'Đậu Hũ Sốt Cà Chua', 'Đậu hũ chiên giòn, sốt cà chua chua ngọt', 'Vegetarian', 250.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (14, 'Vietnamese Crepe', 'Bánh Xèo', 'Bánh xèo giòn với tôm, thịt, giá đỗ, ăn kèm rau sống', 'Snack', 300.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (15, 'Grilled Rice Paper', 'Bánh Tráng Nướng', 'Bánh tráng nướng với trứng, hành khô, tương ớt', 'Snack', 100.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (16, 'Chicken Congee', 'Cháo Gà', 'Cháo gạo với gà xé, gừng, hành, ăn nhẹ dễ tiêu', 'Light Meal', 400.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (17, 'Fish Porridge', 'Cháo Cá', 'Cháo cá với rau thơm, dầu hành, dễ tiêu hóa', 'Light Meal', 400.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (18, 'Steamed Vegetables Mix', 'Rau Củ Luộc', 'Rau củ luộc: bông cải, cà rốt, súp lơ, ít dầu', 'Light Meal', 300.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (19, 'Grilled Pork Rice Vermicelli', 'Bún Thịt Nướng', 'Bún tươi với thịt heo nướng, rau sống, nước mắm', 'Lunch', 450.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (20, 'Hue Beef Noodle Soup', 'Bún Bò Huế', 'Bún bò cay với chả, giò heo, rau thơm', 'Lunch', 650.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (21, 'Vietnamese Fried Spring Rolls', 'Chả Giò (Nem Rán)', 'Chả giò chiên giòn với nhân thịt, miến, rau củ', 'Snack', 150.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (22, 'Grilled Beef in La Lot Leaves', 'Bò Lá Lốt', 'Thịt bò cuộn lá lốt nướng than', 'Dinner', 200.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (23, 'Stir-fried Beef with Vegetables', 'Bò Xào Rau Củ', 'Thịt bò xào với súp lơ, cà rốt, đậu Hà Lan', 'Dinner', 300.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (24, 'Vietnamese Chicken Salad', 'Gỏi Gà', 'Gỏi gà với bắp cải, cà rốt, rau răm', 'Salad', 250.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (25, 'Steamed Rice Rolls', 'Bánh Cuốn', 'Bánh cuốn nhân thịt, nấm mèo, hành phi', 'Breakfast', 300.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (26, 'Chicken Curry with Bread', 'Cà Ri Gà với Bánh Mì', 'Cà ri gà kiểu Việt, ăn kèm bánh mì', 'Lunch', 400.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (27, 'Shrimp Paste Rice Vermicelli', 'Bún Đậu Mắm Tôm', 'Bún với đậu hũ chiên, chả cốm, mắm tôm', 'Lunch', 450.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (28, 'Duck with Bamboo Shoots', 'Vịt Nấu Măng', 'Vịt nấu măng chua, rau thơm', 'Dinner', 350.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (29, 'Pork Ribs Soup', 'Canh Sườn Hầm', 'Canh sườn heo ninh với củ cải, cà rốt', 'Soup', 400.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');
INSERT INTO public.dish VALUES (30, 'Stir-fried Mixed Vegetables', 'Rau Củ Xào Thập Cẩm', 'Rau củ xào chay: bông cải, cà rốt, nấm', 'Vegetarian', 250.00, NULL, true, true, NULL, 1, '2025-12-01 00:23:21.200961', '2025-12-01 00:23:21.209028', '[]');


--
-- TOC entry 6522 (class 0 OID 22746)
-- Dependencies: 354
-- Data for Name: dishimage; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6520 (class 0 OID 22716)
-- Dependencies: 352
-- Data for Name: dishingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dishingredient VALUES (417, 1, 3008, 250.00, 'Bánh phở tươi', 1);
INSERT INTO public.dishingredient VALUES (418, 1, 3003, 150.00, 'Thịt bò tái', 2);
INSERT INTO public.dishingredient VALUES (419, 1, 3017, 50.00, 'Rau thơm: hành, ngò', 3);
INSERT INTO public.dishingredient VALUES (420, 1, 90, 30.00, 'Giá đỗ', 4);
INSERT INTO public.dishingredient VALUES (421, 2, 3013, 200.00, 'Cơm tấm nấu chín', 1);
INSERT INTO public.dishingredient VALUES (422, 2, 3019, 100.00, 'Sườn heo nướng', 2);
INSERT INTO public.dishingredient VALUES (423, 2, 3004, 20.00, 'Dưa leo cắt lát', 3);
INSERT INTO public.dishingredient VALUES (424, 3, 3014, 150.00, 'Bánh mì que', 1);
INSERT INTO public.dishingredient VALUES (425, 3, 3003, 50.00, 'Pate gan', 2);
INSERT INTO public.dishingredient VALUES (426, 3, 3017, 30.00, 'Rau thơm, dưa chua', 3);
INSERT INTO public.dishingredient VALUES (427, 4, 3020, 200.00, 'Xôi nếp', 1);
INSERT INTO public.dishingredient VALUES (428, 4, 3007, 80.00, 'Gà luộc xé', 2);
INSERT INTO public.dishingredient VALUES (429, 5, 3012, 150.00, 'Bún tươi', 1);
INSERT INTO public.dishingredient VALUES (430, 5, 3019, 120.00, 'Chả/thịt nướng', 2);
INSERT INTO public.dishingredient VALUES (431, 5, 3017, 80.00, 'Rau sống: xà lách, húng', 3);
INSERT INTO public.dishingredient VALUES (432, 6, 3015, 120.00, 'Bánh tráng, bún, tôm', 1);
INSERT INTO public.dishingredient VALUES (433, 6, 3017, 40.00, 'Rau sống', 2);
INSERT INTO public.dishingredient VALUES (434, 7, 3018, 200.00, 'Cá nướng lá chuối', 1);
INSERT INTO public.dishingredient VALUES (435, 7, 3017, 50.00, 'Rau thơm', 2);
INSERT INTO public.dishingredient VALUES (436, 8, 3019, 200.00, 'Thịt ba chỉ kho trứng', 1);
INSERT INTO public.dishingredient VALUES (437, 9, 3018, 250.00, 'Cá kho', 1);
INSERT INTO public.dishingredient VALUES (438, 10, 3016, 400.00, 'Canh chua cá nấu sẵn', 1);
INSERT INTO public.dishingredient VALUES (439, 11, 3008, 250.00, 'Bánh phở', 1);
INSERT INTO public.dishingredient VALUES (440, 11, 13, 100.00, 'Đậu hũ', 2);
INSERT INTO public.dishingredient VALUES (441, 11, 3017, 50.00, 'Rau thơm', 3);
INSERT INTO public.dishingredient VALUES (442, 12, 3017, 200.00, 'Rau muống xào tỏi', 1);
INSERT INTO public.dishingredient VALUES (443, 13, 13, 150.00, 'Đậu hũ chiên', 1);
INSERT INTO public.dishingredient VALUES (444, 13, 3016, 80.00, 'Sốt cà chua', 2);
INSERT INTO public.dishingredient VALUES (445, 14, 3014, 150.00, 'Vỏ bánh xèo', 1);
INSERT INTO public.dishingredient VALUES (446, 14, 3019, 50.00, 'Thịt heo', 2);
INSERT INTO public.dishingredient VALUES (447, 14, 90, 40.00, 'Giá đỗ', 3);
INSERT INTO public.dishingredient VALUES (448, 15, 3015, 100.00, 'Bánh tráng nướng', 1);
INSERT INTO public.dishingredient VALUES (449, 16, 3008, 250.00, 'Cơm/gạo nấu cháo', 1);
INSERT INTO public.dishingredient VALUES (450, 16, 3007, 80.00, 'Gà xé', 2);
INSERT INTO public.dishingredient VALUES (451, 17, 3008, 250.00, 'Gạo nấu cháo', 1);
INSERT INTO public.dishingredient VALUES (452, 17, 3018, 80.00, 'Cá', 2);
INSERT INTO public.dishingredient VALUES (453, 18, 3009, 100.00, 'Súp lơ xanh', 1);
INSERT INTO public.dishingredient VALUES (454, 18, 3001, 100.00, 'Rau bina', 2);
INSERT INTO public.dishingredient VALUES (455, 18, 3017, 100.00, 'Rau muống', 3);
INSERT INTO public.dishingredient VALUES (456, 19, 3012, 150.00, 'Bún tươi', 1);
INSERT INTO public.dishingredient VALUES (457, 19, 3019, 100.00, 'Thịt heo nướng', 2);
INSERT INTO public.dishingredient VALUES (458, 19, 3017, 50.00, 'Rau sống', 3);
INSERT INTO public.dishingredient VALUES (459, 20, 3012, 200.00, 'Bún bò', 1);
INSERT INTO public.dishingredient VALUES (460, 20, 3003, 120.00, 'Thịt bò chín', 2);
INSERT INTO public.dishingredient VALUES (461, 21, 3015, 100.00, 'Bánh tráng cuốn', 1);
INSERT INTO public.dishingredient VALUES (462, 21, 3019, 50.00, 'Thịt heo xay', 2);
INSERT INTO public.dishingredient VALUES (463, 22, 3003, 150.00, 'Thịt bò cuộn lá lốt', 1);
INSERT INTO public.dishingredient VALUES (464, 23, 3003, 120.00, 'Thịt bò', 1);
INSERT INTO public.dishingredient VALUES (465, 23, 3009, 80.00, 'Súp lơ xanh', 2);
INSERT INTO public.dishingredient VALUES (466, 24, 3007, 100.00, 'Gà xé', 1);
INSERT INTO public.dishingredient VALUES (467, 24, 3017, 100.00, 'Bắp cải, cà rốt', 2);
INSERT INTO public.dishingredient VALUES (468, 25, 3014, 200.00, 'Bánh cuốn', 1);
INSERT INTO public.dishingredient VALUES (469, 25, 3019, 50.00, 'Nhân thịt', 2);
INSERT INTO public.dishingredient VALUES (470, 26, 3007, 150.00, 'Gà', 1);
INSERT INTO public.dishingredient VALUES (471, 26, 3014, 100.00, 'Bánh mì', 2);
INSERT INTO public.dishingredient VALUES (472, 27, 3012, 150.00, 'Bún', 1);
INSERT INTO public.dishingredient VALUES (473, 27, 13, 100.00, 'Đậu hũ chiên', 2);
INSERT INTO public.dishingredient VALUES (474, 28, 3007, 150.00, 'Vịt', 1);
INSERT INTO public.dishingredient VALUES (475, 28, 3017, 100.00, 'Măng, rau', 2);
INSERT INTO public.dishingredient VALUES (476, 29, 3019, 150.00, 'Sườn heo', 1);
INSERT INTO public.dishingredient VALUES (477, 29, 3017, 100.00, 'Củ cải, cà rốt', 2);
INSERT INTO public.dishingredient VALUES (478, 30, 3009, 80.00, 'Súp lơ', 1);
INSERT INTO public.dishingredient VALUES (479, 30, 3017, 80.00, 'Rau củ khác', 2);


--
-- TOC entry 6528 (class 0 OID 22843)
-- Dependencies: 362
-- Data for Name: dishnotification; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6526 (class 0 OID 22797)
-- Dependencies: 358
-- Data for Name: dishnutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dishnutrient VALUES (3307, 1, 14, 34.406250, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3309, 1, 23, 25.968750, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3310, 1, 24, 13.875000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3311, 1, 26, 6.250000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3313, 1, 30, 1.250000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3305, 1, 2, 8.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3306, 1, 4, 12.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3308, 1, 15, 8.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3312, 1, 29, 1.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3341, 2, 2, 10.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3349, 2, 3, 6.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3342, 2, 4, 28.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3343, 2, 15, 0.543750, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3345, 2, 26, 1.687500, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3346, 2, 27, 22.375000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3344, 2, 24, 25.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3347, 2, 28, 380.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3348, 2, 29, 1.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3368, 3, 2, 12.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3376, 3, 3, 10.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3369, 3, 4, 35.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3371, 3, 15, 12.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3373, 3, 24, 50.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3395, 4, 2, 13.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3370, 3, 14, 40.695652, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3372, 3, 23, 18.065217, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3374, 3, 29, 2.173913, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3375, 3, 30, 0.869565, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3397, 4, 12, 150.285714, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3398, 4, 23, 0.914286, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3399, 4, 26, 12.857143, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3400, 4, 27, 103.714286, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3402, 4, 3, 5.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3396, 4, 4, 38.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3401, 4, 29, 1.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3411, 5, 2, 14.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3418, 5, 3, 8.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3412, 5, 4, 22.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3414, 5, 15, 12.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3416, 5, 28, 480.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3413, 5, 14, 71.314286, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3415, 5, 24, 34.628571, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3417, 5, 29, 1.600000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3437, 6, 14, 78.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3439, 6, 24, 24.750000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3440, 6, 29, 0.625000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3474, 9, 2, 20.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3478, 9, 3, 8.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3475, 9, 23, 2.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3452, 7, 14, 62.400000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3453, 7, 15, 11.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3476, 9, 27, 320.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3455, 7, 24, 19.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3456, 7, 27, 256.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3457, 7, 28, 680.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3477, 9, 28, 850.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3479, 10, 2, 7.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3480, 10, 15, 28.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3481, 10, 27, 280.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3485, 11, 14, 39.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3486, 11, 15, 10.857500, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3482, 10, 28, 420.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3488, 11, 26, 15.827500, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3489, 11, 27, 0.472500, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3491, 11, 29, 0.437500, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3483, 11, 2, 5.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3517, 13, 26, 21.723913, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3518, 13, 27, 98.623913, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3519, 13, 28, 147.247826, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3484, 11, 4, 13.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3487, 11, 24, 45.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3527, 14, 14, 5.083333, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3528, 14, 15, 1.366667, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3490, 11, 28, 280.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3531, 14, 29, 1.368333, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3510, 12, 2, 3.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3551, 15, 15, 15.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3552, 15, 5, 2.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3511, 12, 14, 312.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3512, 12, 15, 55.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3556, 16, 12, 127.515152, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3557, 16, 23, 0.775758, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3558, 16, 26, 9.090909, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3559, 16, 27, 88.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3560, 16, 29, 0.345455, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3513, 12, 24, 99.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3435, 6, 2, 6.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3442, 6, 3, 2.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3436, 6, 4, 14.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3441, 6, 5, 3.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3438, 6, 15, 18.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3451, 7, 2, 22.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3459, 7, 3, 5.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3454, 7, 23, 2.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3458, 7, 29, 1.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3469, 8, 2, 18.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3473, 8, 3, 20.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3470, 8, 24, 35.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3471, 8, 28, 720.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3472, 8, 29, 2.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3514, 12, 29, 2.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3515, 13, 2, 8.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3516, 13, 15, 28.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3525, 14, 2, 9.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3532, 14, 3, 7.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3526, 14, 4, 20.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3529, 14, 24, 38.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3530, 14, 28, 420.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3549, 15, 2, 5.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3553, 15, 3, 4.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3550, 15, 4, 24.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3554, 16, 2, 6.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3555, 16, 4, 10.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3568, 17, 2, 7.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3571, 17, 26, 9.090909, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3572, 17, 27, 77.575758, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3574, 17, 29, 0.151515, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3661, 22, 2, 22.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3664, 22, 29, 2.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3665, 22, 30, 4.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3666, 23, 2, 18.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3588, 18, 26, 36.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3589, 18, 27, 155.333333, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3590, 18, 29, 2.266667, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3668, 23, 15, 45.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3670, 23, 24, 55.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3607, 19, 14, 52.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3608, 19, 15, 9.166667, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3609, 19, 24, 28.166667, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3682, 24, 2, 16.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3685, 24, 15, 38.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3698, 25, 2, 8.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3703, 25, 3, 3.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3699, 25, 4, 22.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3631, 20, 23, 31.162500, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3632, 20, 24, 1.875000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3701, 25, 28, 320.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3635, 20, 30, 1.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3647, 21, 15, 10.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3648, 21, 24, 11.666667, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3650, 21, 29, 0.733333, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3651, 21, 5, 1.866667, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3662, 22, 23, 83.100000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3663, 22, 24, 5.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3667, 23, 14, 40.640000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3669, 23, 23, 49.860000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3671, 23, 26, 8.400000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3672, 23, 29, 3.232000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3673, 23, 30, 2.400000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3683, 24, 12, 263.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3684, 24, 14, 156.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3686, 24, 23, 1.600000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3687, 24, 24, 49.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3688, 24, 27, 181.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3689, 24, 29, 1.650000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3700, 25, 24, 43.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3702, 25, 29, 1.400000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3575, 17, 3, 2.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3569, 17, 4, 9.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3570, 17, 23, 1.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3573, 17, 28, 190.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3584, 18, 2, 2.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3585, 18, 14, 180.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3586, 18, 15, 65.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3587, 18, 24, 80.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3605, 19, 2, 13.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3612, 19, 3, 7.200000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3606, 19, 4, 20.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3610, 19, 28, 450.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3611, 19, 29, 1.600000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3629, 20, 2, 14.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3636, 20, 3, 6.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3630, 20, 4, 22.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3633, 20, 28, 680.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3634, 20, 29, 2.100000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3645, 21, 2, 12.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3652, 21, 3, 16.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3646, 21, 4, 18.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3649, 21, 28, 420.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3712, 26, 12, 315.600000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3713, 26, 23, 1.920000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3788, 1, 28, 420.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3715, 26, 27, 217.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3716, 26, 29, 0.960000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3790, 2, 1, 165.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3796, 3, 1, 280.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3800, 3, 28, 520.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3728, 27, 15, 6.372000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3729, 27, 26, 13.324000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3730, 27, 27, 0.756000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3732, 27, 29, 1.080000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3802, 4, 1, 210.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3806, 4, 28, 280.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3743, 28, 12, 315.600000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3744, 28, 14, 124.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3745, 28, 15, 22.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3746, 28, 23, 1.920000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3747, 28, 24, 39.600000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3748, 28, 27, 217.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3807, 5, 1, 190.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3988, 5, 5, 2.800000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3759, 29, 14, 124.800000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3760, 29, 15, 22.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3813, 6, 1, 95.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3762, 29, 28, 432.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3763, 29, 29, 2.320000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3998, 6, 27, 150.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3819, 7, 1, 145.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3822, 7, 4, 3.200000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (4003, 7, 12, 450.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4006, 7, 30, 0.800000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3776, 30, 26, 10.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3777, 30, 29, 1.615000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3784, 1, 1, 85.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3786, 1, 3, 2.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3959, 1, 5, 1.200000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3961, 1, 27, 180.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3825, 8, 1, 285.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3828, 8, 4, 8.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3831, 9, 1, 195.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3834, 9, 4, 6.800000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (4021, 9, 29, 1.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3837, 10, 1, 65.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3839, 10, 3, 2.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3840, 10, 4, 5.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3843, 11, 1, 75.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3845, 11, 3, 2.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3847, 11, 5, 2.800000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3849, 12, 1, 42.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3851, 12, 3, 1.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3852, 12, 4, 5.800000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (4040, 12, 5, 2.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3855, 13, 1, 125.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3857, 13, 3, 6.800000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3858, 13, 4, 10.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3859, 13, 24, 85.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3860, 13, 29, 1.800000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3861, 14, 1, 165.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3866, 15, 1, 145.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3870, 15, 28, 380.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3871, 16, 1, 68.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3873, 16, 3, 1.800000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3875, 16, 28, 180.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3876, 17, 1, 72.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3882, 18, 1, 35.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3884, 18, 3, 0.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3885, 18, 4, 6.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (4078, 18, 5, 3.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3889, 19, 1, 155.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3895, 20, 1, 165.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3901, 21, 1, 245.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3906, 22, 1, 185.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3908, 22, 3, 9.800000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3909, 22, 4, 3.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3911, 23, 1, 145.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3913, 23, 3, 6.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3914, 23, 4, 8.200000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3917, 24, 1, 125.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3919, 24, 3, 4.200000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3920, 24, 4, 10.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (4115, 24, 5, 3.800000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3922, 25, 1, 135.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3927, 26, 1, 185.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3710, 26, 2, 18.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3717, 26, 3, 11.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3711, 26, 4, 12.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3714, 26, 24, 45.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (4127, 26, 26, 42.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3932, 27, 1, 165.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3726, 27, 2, 10.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3733, 27, 3, 8.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3727, 27, 4, 20.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3936, 27, 24, 85.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3731, 27, 28, 650.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3937, 28, 1, 155.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3742, 28, 2, 19.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3939, 28, 3, 7.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3940, 28, 4, 6.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3749, 28, 29, 2.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (4139, 28, 30, 2.200000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3942, 29, 1, 95.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3758, 29, 2, 11.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3764, 29, 3, 4.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3945, 29, 4, 5.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3761, 29, 24, 35.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3947, 29, 25, 85.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3948, 30, 1, 55.000000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3772, 30, 2, 3.500000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3950, 30, 3, 2.500000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (3951, 30, 4, 7.800000, '2025-12-01 00:23:21.450029');
INSERT INTO public.dishnutrient VALUES (4150, 30, 5, 3.200000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (3773, 30, 14, 95.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3774, 30, 15, 55.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (3775, 30, 24, 60.000000, '2025-12-01 00:23:21.209028');
INSERT INTO public.dishnutrient VALUES (4154, 31, 1, 88.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4155, 31, 2, 9.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4156, 31, 3, 2.800000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4157, 31, 4, 13.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4158, 31, 28, 450.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4159, 31, 29, 1.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4160, 32, 1, 155.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4161, 32, 2, 8.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4162, 32, 3, 7.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4163, 32, 4, 18.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4164, 32, 28, 380.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4165, 33, 1, 175.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4166, 33, 2, 13.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4167, 33, 3, 8.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4168, 33, 4, 22.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4169, 33, 27, 320.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4170, 33, 28, 520.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4171, 34, 1, 140.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4172, 34, 2, 11.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4173, 34, 3, 6.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4174, 34, 4, 15.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4175, 34, 15, 20.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4176, 35, 1, 165.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4177, 35, 2, 19.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4178, 35, 3, 8.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4179, 35, 4, 5.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4180, 35, 29, 1.800000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4181, 36, 1, 135.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4182, 36, 2, 12.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4183, 36, 3, 5.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4184, 36, 4, 18.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4185, 36, 23, 1.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4186, 36, 28, 550.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4187, 37, 1, 155.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4188, 37, 2, 9.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4189, 37, 3, 10.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4190, 37, 4, 8.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4191, 37, 24, 120.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4192, 38, 1, 185.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4193, 38, 2, 16.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4194, 38, 3, 11.000000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4195, 38, 4, 9.500000, '2025-12-01 00:23:21.524376');
INSERT INTO public.dishnutrient VALUES (4196, 38, 28, 480.000000, '2025-12-01 00:23:21.524376');


--
-- TOC entry 6524 (class 0 OID 22776)
-- Dependencies: 356
-- Data for Name: dishstatistics; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6544 (class 0 OID 23793)
-- Dependencies: 379
-- Data for Name: drink; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.drink VALUES (1, 'Fresh Orange Juice', 'Nước Cam Vắt', NULL, 'Nước cam tươi vắt, giàu vitamin C', 'Juice', 'Water', 250.00, 'Cold', 'normal', 0.95, 0.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (2, 'Sugarcane Juice', 'Nước Mía', NULL, 'Nước mía ép tươi, ngọt mát', 'Juice', 'Water', 300.00, 'Cold', 'normal', 0.92, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (3, 'Coconut Water', 'Nước Dừa Tươi', NULL, 'Nước dừa tươi, bổ sung điện giải', 'Juice', 'Water', 350.00, 'Cold', 'normal', 0.98, 0.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (4, 'Lemon Tea', 'Trà Chanh', NULL, 'Trà đen pha chanh, ít đường', 'Tea', 'Water', 300.00, 'Cold', 'normal', 0.96, 25.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (5, 'Vietnamese Black Coffee', 'Cà Phê Đen', NULL, 'Cà phê phin truyền thống, đắng', 'Coffee', 'Water', 100.00, 'Hot', 'normal', 0.99, 95.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (6, 'Vietnamese Milk Coffee', 'Cà Phê Sữa', NULL, 'Cà phê phin với sữa đặc', 'Coffee', 'Milk', 150.00, 'Hot', 'normal', 0.94, 85.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (7, 'Iced Milk Coffee', 'Cà Phê Sữa Đá', NULL, 'Cà phê sữa pha đá', 'Coffee', 'Milk', 200.00, 'Cold', 'normal', 0.92, 80.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (8, 'Green Tea', 'Trà Xanh', NULL, 'Trà xanh không đường', 'Tea', 'Water', 250.00, 'Hot', 'normal', 0.99, 30.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (9, 'Lotus Tea', 'Trà Sen', NULL, 'Trà sen thơm dịu', 'Tea', 'Water', 250.00, 'Hot', 'normal', 0.99, 20.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (10, 'Jasmine Tea', 'Trà Nhài', NULL, 'Trà hoa nhài thơm', 'Tea', 'Water', 250.00, 'Hot', 'normal', 0.99, 22.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (11, 'Avocado Smoothie', 'Sinh Tố Bơ', NULL, 'Sinh tố bơ với sữa đặc', 'Smoothie', 'Milk', 350.00, 'Cold', 'normal', 0.88, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (12, 'Banana Smoothie', 'Sinh Tố Chuối', NULL, 'Sinh tố chuối với sữa tươi', 'Smoothie', 'Milk', 350.00, 'Cold', 'normal', 0.90, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (13, 'Mango Smoothie', 'Sinh Tố Xoài', NULL, 'Sinh tố xoài tươi', 'Smoothie', 'Milk', 350.00, 'Cold', 'normal', 0.89, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (14, 'Soy Milk', 'Sữa Đậu Nành', NULL, 'Sữa đậu nành tươi, giàu protein', 'Milk', 'Water', 250.00, 'Warm', 'normal', 0.93, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (15, 'Ginger Tea', 'Trà Gừng', NULL, 'Trà gừng ấm bụng', 'Tea', 'Water', 200.00, 'Hot', 'normal', 0.98, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (16, 'Chrysanthemum Tea', 'Trà Hoa Cúc', NULL, 'Trà hoa cúc mát gan', 'Tea', 'Water', 250.00, 'Cold', 'normal', 0.99, 0.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (17, 'Barley Water', 'Nước Lúa Mạch', NULL, 'Nước lúa mạch mát, giải nhiệt', 'Healthy', 'Water', 300.00, 'Cold', 'normal', 0.97, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (18, 'Artichoke Tea', 'Trà Atiso', NULL, 'Trà atiso giải độc gan', 'Healthy', 'Water', 250.00, 'Warm', 'normal', 0.98, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (19, 'Pennywort Juice', 'Nước Rau Má', NULL, 'Nước rau má thanh mát', 'Healthy', 'Water', 250.00, 'Cold', 'normal', 0.96, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (20, 'Plain Water', 'Nước Lọc', NULL, 'Nước lọc tinh khiết', 'Water', 'Water', 250.00, 'Room', 'normal', 1.00, 0.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (21, 'Egg Coffee', 'Cà Phê Trứng', NULL, 'Cà phê đen pha với kem trứng gà', 'Coffee', 'Milk', 150.00, 'Hot', 'normal', 0.90, 85.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (22, 'Coconut Coffee', 'Cà Phê Cốt Dừa', NULL, 'Cà phê pha với cốt dừa', 'Coffee', 'Milk', 200.00, 'Cold', 'normal', 0.88, 75.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (23, 'Fresh Lemon Juice', 'Nước Chanh Tươi', NULL, 'Nước chanh vắt tươi với mật ong', 'Juice', 'Water', 250.00, 'Cold', 'normal', 0.97, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (24, 'Passion Fruit Juice', 'Nước Chanh Dây', NULL, 'Nước chanh leo tươi mát', 'Juice', 'Water', 250.00, 'Cold', 'normal', 0.95, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (25, 'Tamarind Juice', 'Nước Me', NULL, 'Nước me chua ngọt', 'Juice', 'Water', 250.00, 'Cold', 'normal', 0.94, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (26, 'Soursop Smoothie', 'Sinh Tố Mãng Cầu', NULL, 'Sinh tố mãng cầu xiêm với sữa', 'Smoothie', 'Milk', 350.00, 'Cold', 'normal', 0.89, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (27, 'Dragon Fruit Smoothie', 'Sinh Tố Thanh Long', NULL, 'Sinh tố thanh long ruột đỏ', 'Smoothie', 'Milk', 350.00, 'Cold', 'normal', 0.91, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (28, 'Papaya Smoothie', 'Sinh Tố Đu Đủ', NULL, 'Sinh tố đu đủ chín với sữa tươi', 'Smoothie', 'Milk', 350.00, 'Cold', 'normal', 0.90, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (29, 'Watermelon Juice', 'Nước Dưa Hấu', NULL, 'Nước dưa hấu ép tươi', 'Juice', 'Water', 300.00, 'Cold', 'normal', 0.97, 0.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (30, 'Sugarcane with Kumquat', 'Nước Mía Tắc', NULL, 'Nước mía pha với tắc', 'Juice', 'Water', 300.00, 'Cold', 'normal', 0.93, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (31, 'Iced Tea with Lemon', 'Trà Đá Chanh', NULL, 'Trà đen pha đá với chanh', 'Tea', 'Water', 300.00, 'Cold', 'normal', 0.98, 20.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (32, 'Peach Tea', 'Trà Đào', NULL, 'Trà đào ngọt mát', 'Tea', 'Water', 300.00, 'Cold', 'normal', 0.96, 15.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (33, 'Kumquat Honey Tea', 'Trà Tắc Mật Ong', NULL, 'Trà tắc pha mật ong ấm', 'Tea', 'Water', 250.00, 'Warm', 'normal', 0.97, 18.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (34, 'Young Rice Milk', 'Nước Cốm', NULL, 'Nước uống từ cốm xanh', 'Healthy', 'Water', 250.00, 'Cold', 'normal', 0.95, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (35, 'Herbal Tea', 'Trà Thảo Mộc', NULL, 'Trà các loại thảo mộc Việt Nam', 'Healthy', 'Water', 250.00, 'Warm', 'normal', 0.99, 0.00, true, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (36, 'Wintermelon Tea', 'Trà Bí Đao', NULL, 'Trà bí đao mát gan', 'Healthy', 'Water', 250.00, 'Cold', 'normal', 0.97, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (37, 'Black Sesame Milk', 'Sữa Mè Đen', NULL, 'Sữa mè đen bổ dưỡng', 'Milk', 'Water', 250.00, 'Warm', 'normal', 0.92, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (38, 'Peanut Milk', 'Sữa Đậu Phộng', NULL, 'Sữa đậu phộng thơm béo', 'Milk', 'Water', 250.00, 'Warm', 'normal', 0.93, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (39, 'Three-bean Sweet Soup', 'Chè Ba Màu', NULL, 'Chè đậu xanh, đậu đỏ, đậu đen', 'Dessert', 'Milk', 300.00, 'Cold', 'normal', 0.85, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');
INSERT INTO public.drink VALUES (40, 'Grass Jelly Drink', 'Sương Sáo', NULL, 'Thạch sương sáo với đường phèn', 'Dessert', 'Water', 250.00, 'Cold', 'normal', 0.96, 0.00, false, true, true, NULL, NULL, 1, '2025-12-01 00:23:21.454085-08', '2025-12-01 00:23:21.454085-08');


--
-- TOC entry 6546 (class 0 OID 23831)
-- Dependencies: 381
-- Data for Name: drinkingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.drinkingredient VALUES (130, 1, 3005, 200.00, 'ml', 1, 'Nước cam ép tươi');
INSERT INTO public.drinkingredient VALUES (131, 3, 3, 300.00, 'ml', 1, 'Nước dừa tươi');
INSERT INTO public.drinkingredient VALUES (132, 6, 3010, 50.00, 'ml', 1, 'Sữa đặc ngọt');
INSERT INTO public.drinkingredient VALUES (133, 11, 99, 80.00, 'g', 1, 'Bơ tươi');
INSERT INTO public.drinkingredient VALUES (134, 11, 3010, 150.00, 'ml', 2, 'Sữa tươi');
INSERT INTO public.drinkingredient VALUES (135, 12, 3004, 100.00, 'g', 1, 'Chuối chín');
INSERT INTO public.drinkingredient VALUES (136, 12, 3010, 150.00, 'ml', 2, 'Sữa tươi');
INSERT INTO public.drinkingredient VALUES (137, 14, 2, 50.00, 'g', 1, 'Đậu nành');
INSERT INTO public.drinkingredient VALUES (138, 19, 3017, 80.00, 'g', 1, 'Rau má tươi');


--
-- TOC entry 6548 (class 0 OID 23861)
-- Dependencies: 383
-- Data for Name: drinknutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.drinknutrient VALUES (2121, 3, 14, 19.294286);
INSERT INTO public.drinknutrient VALUES (2122, 3, 15, 23.228571);
INSERT INTO public.drinknutrient VALUES (2125, 3, 29, 31.817143);
INSERT INTO public.drinknutrient VALUES (2127, 6, 23, 0.150000);
INSERT INTO public.drinknutrient VALUES (2129, 6, 27, 50.000000);
INSERT INTO public.drinknutrient VALUES (2139, 11, 23, 0.192857);
INSERT INTO public.drinknutrient VALUES (2141, 11, 26, 63.771429);
INSERT INTO public.drinknutrient VALUES (2143, 11, 29, 0.797714);
INSERT INTO public.drinknutrient VALUES (2153, 12, 15, 2.485714);
INSERT INTO public.drinknutrient VALUES (2154, 12, 23, 0.192857);
INSERT INTO public.drinknutrient VALUES (2156, 12, 26, 7.714286);
INSERT INTO public.drinknutrient VALUES (2161, 14, 5, 8.024000);
INSERT INTO public.drinknutrient VALUES (2163, 14, 26, 4.838000);
INSERT INTO public.drinknutrient VALUES (2164, 14, 28, 8.310000);
INSERT INTO public.drinknutrient VALUES (2166, 19, 2, 0.832000);
INSERT INTO public.drinknutrient VALUES (2167, 19, 14, 99.840000);
INSERT INTO public.drinknutrient VALUES (2170, 19, 29, 0.800000);
INSERT INTO public.drinknutrient VALUES (2171, 1, 1, 45.000000);
INSERT INTO public.drinknutrient VALUES (2117, 1, 4, 10.400000);
INSERT INTO public.drinknutrient VALUES (2118, 1, 15, 50.000000);
INSERT INTO public.drinknutrient VALUES (2120, 1, 27, 200.000000);
INSERT INTO public.drinknutrient VALUES (2119, 1, 24, 11.000000);
INSERT INTO public.drinknutrient VALUES (2175, 2, 1, 72.000000);
INSERT INTO public.drinknutrient VALUES (2176, 2, 4, 18.000000);
INSERT INTO public.drinknutrient VALUES (2225, 2, 15, 8.000000);
INSERT INTO public.drinknutrient VALUES (2178, 2, 24, 18.000000);
INSERT INTO public.drinknutrient VALUES (2227, 2, 26, 12.000000);
INSERT INTO public.drinknutrient VALUES (2177, 2, 27, 142.000000);
INSERT INTO public.drinknutrient VALUES (2179, 3, 1, 19.000000);
INSERT INTO public.drinknutrient VALUES (2180, 3, 4, 3.700000);
INSERT INTO public.drinknutrient VALUES (2123, 3, 24, 24.000000);
INSERT INTO public.drinknutrient VALUES (2183, 3, 26, 25.000000);
INSERT INTO public.drinknutrient VALUES (2124, 3, 27, 250.000000);
INSERT INTO public.drinknutrient VALUES (2182, 3, 28, 105.000000);
INSERT INTO public.drinknutrient VALUES (2184, 4, 1, 28.000000);
INSERT INTO public.drinknutrient VALUES (2185, 4, 4, 7.000000);
INSERT INTO public.drinknutrient VALUES (2186, 4, 15, 15.000000);
INSERT INTO public.drinknutrient VALUES (2187, 5, 1, 2.000000);
INSERT INTO public.drinknutrient VALUES (2188, 5, 4, 0.000000);
INSERT INTO public.drinknutrient VALUES (2189, 5, 27, 115.000000);
INSERT INTO public.drinknutrient VALUES (2190, 6, 1, 85.000000);
INSERT INTO public.drinknutrient VALUES (2126, 6, 2, 2.800000);
INSERT INTO public.drinknutrient VALUES (2243, 6, 3, 3.500000);
INSERT INTO public.drinknutrient VALUES (2191, 6, 4, 12.500000);
INSERT INTO public.drinknutrient VALUES (2128, 6, 24, 45.000000);
INSERT INTO public.drinknutrient VALUES (2194, 7, 1, 68.000000);
INSERT INTO public.drinknutrient VALUES (2196, 7, 2, 2.200000);
INSERT INTO public.drinknutrient VALUES (2248, 7, 3, 2.800000);
INSERT INTO public.drinknutrient VALUES (2195, 7, 4, 10.000000);
INSERT INTO public.drinknutrient VALUES (2197, 7, 24, 36.000000);
INSERT INTO public.drinknutrient VALUES (2251, 21, 1, 145.000000);
INSERT INTO public.drinknutrient VALUES (2252, 21, 2, 4.500000);
INSERT INTO public.drinknutrient VALUES (2253, 21, 3, 9.500000);
INSERT INTO public.drinknutrient VALUES (2254, 21, 4, 12.000000);
INSERT INTO public.drinknutrient VALUES (2255, 21, 24, 55.000000);
INSERT INTO public.drinknutrient VALUES (2256, 21, 23, 0.350000);
INSERT INTO public.drinknutrient VALUES (2257, 22, 1, 125.000000);
INSERT INTO public.drinknutrient VALUES (2258, 22, 2, 1.800000);
INSERT INTO public.drinknutrient VALUES (2259, 22, 3, 8.500000);
INSERT INTO public.drinknutrient VALUES (2260, 22, 4, 14.000000);
INSERT INTO public.drinknutrient VALUES (2261, 22, 26, 18.000000);
INSERT INTO public.drinknutrient VALUES (2198, 8, 1, 0.000000);
INSERT INTO public.drinknutrient VALUES (2199, 8, 4, 0.000000);
INSERT INTO public.drinknutrient VALUES (2200, 8, 27, 8.000000);
INSERT INTO public.drinknutrient VALUES (2265, 9, 1, 1.000000);
INSERT INTO public.drinknutrient VALUES (2266, 9, 4, 0.200000);
INSERT INTO public.drinknutrient VALUES (2267, 10, 1, 1.000000);
INSERT INTO public.drinknutrient VALUES (2268, 10, 4, 0.200000);
INSERT INTO public.drinknutrient VALUES (2269, 31, 1, 22.000000);
INSERT INTO public.drinknutrient VALUES (2270, 31, 4, 5.500000);
INSERT INTO public.drinknutrient VALUES (2271, 31, 15, 12.000000);
INSERT INTO public.drinknutrient VALUES (2272, 32, 1, 38.000000);
INSERT INTO public.drinknutrient VALUES (2273, 32, 4, 9.500000);
INSERT INTO public.drinknutrient VALUES (2274, 32, 15, 8.500000);
INSERT INTO public.drinknutrient VALUES (2275, 33, 1, 52.000000);
INSERT INTO public.drinknutrient VALUES (2276, 33, 4, 13.000000);
INSERT INTO public.drinknutrient VALUES (2277, 33, 15, 42.000000);
INSERT INTO public.drinknutrient VALUES (2278, 35, 1, 2.000000);
INSERT INTO public.drinknutrient VALUES (2279, 35, 4, 0.500000);
INSERT INTO public.drinknutrient VALUES (2280, 36, 1, 25.000000);
INSERT INTO public.drinknutrient VALUES (2281, 36, 4, 6.000000);
INSERT INTO public.drinknutrient VALUES (2201, 11, 1, 165.000000);
INSERT INTO public.drinknutrient VALUES (2137, 11, 2, 2.800000);
INSERT INTO public.drinknutrient VALUES (2138, 11, 3, 12.500000);
INSERT INTO public.drinknutrient VALUES (2204, 11, 4, 11.200000);
INSERT INTO public.drinknutrient VALUES (2286, 11, 5, 2.500000);
INSERT INTO public.drinknutrient VALUES (2140, 11, 24, 85.000000);
INSERT INTO public.drinknutrient VALUES (2142, 11, 27, 180.000000);
INSERT INTO public.drinknutrient VALUES (2206, 12, 1, 95.000000);
INSERT INTO public.drinknutrient VALUES (2151, 12, 2, 3.500000);
INSERT INTO public.drinknutrient VALUES (2291, 12, 3, 2.500000);
INSERT INTO public.drinknutrient VALUES (2152, 12, 4, 18.500000);
INSERT INTO public.drinknutrient VALUES (2293, 12, 5, 2.000000);
INSERT INTO public.drinknutrient VALUES (2155, 12, 24, 72.000000);
INSERT INTO public.drinknutrient VALUES (2157, 12, 27, 215.000000);
INSERT INTO public.drinknutrient VALUES (2296, 13, 1, 88.000000);
INSERT INTO public.drinknutrient VALUES (2297, 13, 2, 3.200000);
INSERT INTO public.drinknutrient VALUES (2298, 13, 3, 2.000000);
INSERT INTO public.drinknutrient VALUES (2299, 13, 4, 17.000000);
INSERT INTO public.drinknutrient VALUES (2300, 13, 11, 54.000000);
INSERT INTO public.drinknutrient VALUES (2301, 13, 15, 36.500000);
INSERT INTO public.drinknutrient VALUES (2302, 13, 24, 65.000000);
INSERT INTO public.drinknutrient VALUES (2303, 26, 1, 95.000000);
INSERT INTO public.drinknutrient VALUES (2304, 26, 2, 2.500000);
INSERT INTO public.drinknutrient VALUES (2305, 26, 4, 20.000000);
INSERT INTO public.drinknutrient VALUES (2306, 26, 5, 2.200000);
INSERT INTO public.drinknutrient VALUES (2307, 26, 15, 55.000000);
INSERT INTO public.drinknutrient VALUES (2308, 26, 24, 65.000000);
INSERT INTO public.drinknutrient VALUES (2309, 27, 1, 78.000000);
INSERT INTO public.drinknutrient VALUES (2310, 27, 2, 2.800000);
INSERT INTO public.drinknutrient VALUES (2311, 27, 4, 16.500000);
INSERT INTO public.drinknutrient VALUES (2312, 27, 5, 1.800000);
INSERT INTO public.drinknutrient VALUES (2313, 27, 15, 28.000000);
INSERT INTO public.drinknutrient VALUES (2314, 27, 24, 58.000000);
INSERT INTO public.drinknutrient VALUES (2315, 28, 1, 88.000000);
INSERT INTO public.drinknutrient VALUES (2316, 28, 2, 3.200000);
INSERT INTO public.drinknutrient VALUES (2317, 28, 4, 18.000000);
INSERT INTO public.drinknutrient VALUES (2318, 28, 5, 2.000000);
INSERT INTO public.drinknutrient VALUES (2319, 28, 11, 95.000000);
INSERT INTO public.drinknutrient VALUES (2320, 28, 15, 62.000000);
INSERT INTO public.drinknutrient VALUES (2321, 28, 24, 68.000000);
INSERT INTO public.drinknutrient VALUES (2211, 14, 1, 54.000000);
INSERT INTO public.drinknutrient VALUES (2158, 14, 2, 3.300000);
INSERT INTO public.drinknutrient VALUES (2159, 14, 3, 1.900000);
INSERT INTO public.drinknutrient VALUES (2160, 14, 4, 6.000000);
INSERT INTO public.drinknutrient VALUES (2162, 14, 24, 25.000000);
INSERT INTO public.drinknutrient VALUES (2165, 14, 29, 1.200000);
INSERT INTO public.drinknutrient VALUES (2328, 15, 1, 18.000000);
INSERT INTO public.drinknutrient VALUES (2329, 15, 4, 4.500000);
INSERT INTO public.drinknutrient VALUES (2330, 15, 26, 8.000000);
INSERT INTO public.drinknutrient VALUES (2331, 16, 1, 3.000000);
INSERT INTO public.drinknutrient VALUES (2332, 16, 4, 0.800000);
INSERT INTO public.drinknutrient VALUES (2333, 17, 1, 28.000000);
INSERT INTO public.drinknutrient VALUES (2334, 17, 4, 7.000000);
INSERT INTO public.drinknutrient VALUES (2335, 17, 5, 1.500000);
INSERT INTO public.drinknutrient VALUES (2336, 17, 26, 12.000000);
INSERT INTO public.drinknutrient VALUES (2337, 18, 1, 15.000000);
INSERT INTO public.drinknutrient VALUES (2338, 18, 4, 3.500000);
INSERT INTO public.drinknutrient VALUES (2339, 18, 27, 85.000000);
INSERT INTO public.drinknutrient VALUES (2340, 19, 1, 12.000000);
INSERT INTO public.drinknutrient VALUES (2341, 19, 4, 2.800000);
INSERT INTO public.drinknutrient VALUES (2168, 19, 15, 8.000000);
INSERT INTO public.drinknutrient VALUES (2169, 19, 24, 18.000000);
INSERT INTO public.drinknutrient VALUES (2216, 20, 1, 0.000000);
INSERT INTO public.drinknutrient VALUES (2217, 20, 4, 0.000000);
INSERT INTO public.drinknutrient VALUES (2346, 23, 1, 35.000000);
INSERT INTO public.drinknutrient VALUES (2347, 23, 4, 8.500000);
INSERT INTO public.drinknutrient VALUES (2348, 23, 15, 45.000000);
INSERT INTO public.drinknutrient VALUES (2349, 23, 27, 85.000000);
INSERT INTO public.drinknutrient VALUES (2350, 24, 1, 42.000000);
INSERT INTO public.drinknutrient VALUES (2351, 24, 4, 10.000000);
INSERT INTO public.drinknutrient VALUES (2352, 24, 15, 38.000000);
INSERT INTO public.drinknutrient VALUES (2353, 24, 27, 95.000000);
INSERT INTO public.drinknutrient VALUES (2354, 25, 1, 48.000000);
INSERT INTO public.drinknutrient VALUES (2355, 25, 4, 12.000000);
INSERT INTO public.drinknutrient VALUES (2356, 25, 15, 15.000000);
INSERT INTO public.drinknutrient VALUES (2357, 25, 24, 22.000000);
INSERT INTO public.drinknutrient VALUES (2358, 25, 27, 125.000000);
INSERT INTO public.drinknutrient VALUES (2359, 29, 1, 30.000000);
INSERT INTO public.drinknutrient VALUES (2360, 29, 4, 7.500000);
INSERT INTO public.drinknutrient VALUES (2361, 29, 5, 0.400000);
INSERT INTO public.drinknutrient VALUES (2362, 29, 15, 8.000000);
INSERT INTO public.drinknutrient VALUES (2363, 29, 27, 112.000000);
INSERT INTO public.drinknutrient VALUES (2364, 30, 1, 78.000000);
INSERT INTO public.drinknutrient VALUES (2365, 30, 4, 19.500000);
INSERT INTO public.drinknutrient VALUES (2366, 30, 15, 35.000000);
INSERT INTO public.drinknutrient VALUES (2367, 30, 27, 148.000000);
INSERT INTO public.drinknutrient VALUES (2368, 34, 1, 65.000000);
INSERT INTO public.drinknutrient VALUES (2369, 34, 2, 1.500000);
INSERT INTO public.drinknutrient VALUES (2370, 34, 4, 15.500000);
INSERT INTO public.drinknutrient VALUES (2371, 34, 5, 1.200000);
INSERT INTO public.drinknutrient VALUES (2372, 37, 1, 115.000000);
INSERT INTO public.drinknutrient VALUES (2373, 37, 2, 4.800000);
INSERT INTO public.drinknutrient VALUES (2374, 37, 3, 7.500000);
INSERT INTO public.drinknutrient VALUES (2375, 37, 4, 8.500000);
INSERT INTO public.drinknutrient VALUES (2376, 37, 24, 95.000000);
INSERT INTO public.drinknutrient VALUES (2377, 37, 26, 35.000000);
INSERT INTO public.drinknutrient VALUES (2378, 37, 29, 2.500000);
INSERT INTO public.drinknutrient VALUES (2379, 38, 1, 98.000000);
INSERT INTO public.drinknutrient VALUES (2380, 38, 2, 4.200000);
INSERT INTO public.drinknutrient VALUES (2381, 38, 3, 5.500000);
INSERT INTO public.drinknutrient VALUES (2382, 38, 4, 9.000000);
INSERT INTO public.drinknutrient VALUES (2383, 38, 24, 45.000000);
INSERT INTO public.drinknutrient VALUES (2384, 38, 26, 28.000000);
INSERT INTO public.drinknutrient VALUES (2385, 39, 1, 135.000000);
INSERT INTO public.drinknutrient VALUES (2386, 39, 2, 5.500000);
INSERT INTO public.drinknutrient VALUES (2387, 39, 3, 3.500000);
INSERT INTO public.drinknutrient VALUES (2388, 39, 4, 28.000000);
INSERT INTO public.drinknutrient VALUES (2389, 39, 5, 2.800000);
INSERT INTO public.drinknutrient VALUES (2390, 39, 24, 75.000000);
INSERT INTO public.drinknutrient VALUES (2391, 39, 26, 32.000000);
INSERT INTO public.drinknutrient VALUES (2392, 40, 1, 32.000000);
INSERT INTO public.drinknutrient VALUES (2393, 40, 4, 8.000000);
INSERT INTO public.drinknutrient VALUES (2394, 40, 5, 0.800000);
INSERT INTO public.drinknutrient VALUES (2395, 40, 24, 12.000000);


--
-- TOC entry 6550 (class 0 OID 23886)
-- Dependencies: 385
-- Data for Name: drinkstatistics; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6552 (class 0 OID 23970)
-- Dependencies: 387
-- Data for Name: drug; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.drug VALUES (26, 'Pegfilgrastim', 'Pegfilgrastim', NULL, NULL, 'Long-acting G-CSF for neutropenia', NULL, 'DB00019', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'G-CSF tác dụng kéo dài điều trị giảm bạch cầu');
INSERT INTO public.drug VALUES (27, 'Sargramostim', 'Sargramostim', NULL, NULL, 'GM-CSF for bone marrow recovery', NULL, 'DB00020', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'GM-CSF hỗ trợ phục hồi tủy xương');
INSERT INTO public.drug VALUES (28, 'Peginterferon alfa-2b', 'Peginterferon alfa-2b', NULL, NULL, 'Interferon for Hepatitis C', NULL, 'DB00022', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Interferon điều trị viêm gan C');
INSERT INTO public.drug VALUES (29, 'Asparaginase E. coli', 'Asparaginase Escherichia coli', NULL, NULL, 'Enzyme for acute lymphoblastic leukemia', NULL, 'DB00023', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Enzyme điều trị bạch cầu cấp dòng lympho');
INSERT INTO public.drug VALUES (30, 'Thyrotropin alfa', 'Thyrotropin alfa', NULL, NULL, 'Recombinant TSH for thyroid cancer', NULL, 'DB00024', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'TSH tái tổ hợp điều trị ung thư tuyến giáp');
INSERT INTO public.drug VALUES (2001, 'Metformin', 'Metformin', NULL, NULL, 'Antidiabetic medication', NULL, NULL, NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc đầu tay điều trị tiểu đường, giúp kiểm soát đường huyết.');
INSERT INTO public.drug VALUES (2002, 'Warfarin', 'Warfarin', NULL, NULL, 'Anticoagulant', NULL, NULL, NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc chống đông máu, ngăn ngừa huyết khối.');
INSERT INTO public.drug VALUES (2003, 'Lisinopril', 'Lisinopril', NULL, NULL, 'ACE inhibitor for hypertension', NULL, NULL, NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc ức chế men chuyển dùng trị cao huyết áp.');
INSERT INTO public.drug VALUES (2004, 'Sắt Sulfate', 'Ferrous Sulfate', NULL, NULL, 'Iron supplement', NULL, NULL, NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Viên uống bổ sung sắt điều trị thiếu máu.');
INSERT INTO public.drug VALUES (2005, 'Alendronate', 'Alendronate', NULL, NULL, 'Bisphosphonate for osteoporosis', NULL, NULL, NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc nhóm bisphosphonat điều trị loãng xương.');
INSERT INTO public.drug VALUES (2006, 'Allopurinol', 'Allopurinol', NULL, NULL, 'Uric acid reducer for gout', NULL, NULL, NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc làm giảm nồng độ axit uric trong máu trị Gút.');
INSERT INTO public.drug VALUES (2007, 'Omeprazole', 'Omeprazole', NULL, NULL, 'Proton pump inhibitor', NULL, NULL, NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc ức chế bơm proton giảm axit dạ dày.');
INSERT INTO public.drug VALUES (2008, 'Spironolactone', 'Spironolactone', NULL, NULL, 'Potassium-sparing diuretic', NULL, NULL, NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc lợi tiểu giữ kali.');
INSERT INTO public.drug VALUES (1, 'Lepirudin', 'Lepirudin', NULL, NULL, 'Recombinant hirudin, direct thrombin inhibitor for HIT', NULL, 'DB00001', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc ức chế thrombin trực tiếp điều trị giảm tiểu cầu do heparin');
INSERT INTO public.drug VALUES (4, 'Cetuximab', 'Cetuximab', NULL, NULL, 'Monoclonal antibody for cancer treatment', NULL, 'DB00002', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Kháng thể đơn dòng điều trị ung thư');
INSERT INTO public.drug VALUES (6, 'Dornase alfa', 'Dornase alfa', NULL, NULL, 'DNase enzyme for cystic fibrosis', NULL, 'DB00003', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Enzyme DNase điều trị xơ nang');
INSERT INTO public.drug VALUES (7, 'Denileukin diftitox', 'Denileukin diftitox', NULL, NULL, 'Cytotoxic protein for lymphoma', NULL, 'DB00004', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Protein độc tế bào điều trị lymphoma');
INSERT INTO public.drug VALUES (8, 'Etanercept', 'Etanercept', NULL, NULL, 'TNF inhibitor for autoimmune diseases', NULL, 'DB00005', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc ức chế TNF điều trị bệnh tự miễn');
INSERT INTO public.drug VALUES (9, 'Bivalirudin', 'Bivalirudin', NULL, NULL, 'Direct thrombin inhibitor anticoagulant', NULL, 'DB00006', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc chống đông máu ức chế thrombin trực tiếp');
INSERT INTO public.drug VALUES (24, 'Calcitonin cá hồi', 'Salmon calcitonin', NULL, NULL, 'Hormone for osteoporosis and hypercalcemia', NULL, 'DB00017', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Hormone điều trị loãng xương và tăng canxi máu');
INSERT INTO public.drug VALUES (11, 'Leuprolide', 'Leuprolide', NULL, NULL, 'GnRH analogue for prostate cancer and endometriosis', NULL, 'DB00007', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Chất tương tự GnRH điều trị ung thư tuyến tiền liệt');
INSERT INTO public.drug VALUES (12, 'Peginterferon alfa-2a', 'Peginterferon alfa-2a', NULL, NULL, 'Interferon for Hepatitis C', NULL, 'DB00008', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Interferon điều trị viêm gan C');
INSERT INTO public.drug VALUES (13, 'Alteplase', 'Alteplase', NULL, NULL, 'Tissue plasminogen activator for stroke', NULL, 'DB00009', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc tiêu huyết khối điều trị đột quỵ');
INSERT INTO public.drug VALUES (15, 'Sermorelin', 'Sermorelin', NULL, NULL, 'Growth hormone-releasing hormone analogue', NULL, 'DB00010', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Chất tương tự hormone giải phóng GH');
INSERT INTO public.drug VALUES (16, 'Interferon alfa-n1', 'Interferon alfa-n1', NULL, NULL, 'Natural interferon for viral infections', NULL, 'DB00011', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Interferon tự nhiên điều trị nhiễm virus');
INSERT INTO public.drug VALUES (17, 'Darbepoetin alfa', 'Darbepoetin alfa', NULL, NULL, 'Erythropoiesis-stimulating agent for anemia', NULL, 'DB00012', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc kích thích tạo hồng cầu điều trị thiếu máu');
INSERT INTO public.drug VALUES (18, 'Urokinase', 'Urokinase', NULL, NULL, 'Thrombolytic enzyme', NULL, 'DB00013', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Enzyme tiêu huyết khối');
INSERT INTO public.drug VALUES (20, 'Goserelin', 'Goserelin', NULL, NULL, 'GnRH agonist for prostate and breast cancer', NULL, 'DB00014', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Chất chủ vận GnRH điều trị ung thư');
INSERT INTO public.drug VALUES (21, 'Reteplase', 'Reteplase', NULL, NULL, 'Third-generation thrombolytic agent', NULL, 'DB00015', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'Thuốc tiêu huyết khối thế hệ 3');
INSERT INTO public.drug VALUES (23, 'Erythropoietin', 'Erythropoietin', NULL, NULL, 'Recombinant EPO for anemia', NULL, 'DB00016', NULL, true, NULL, '2025-12-01 00:09:51.246604', '2025-12-01 00:30:31.858877', 'EPO tái tổ hợp điều trị thiếu máu');


--
-- TOC entry 6554 (class 0 OID 23991)
-- Dependencies: 389
-- Data for Name: drughealthcondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.drughealthcondition VALUES (142, 2001, 11, 'Primary treatment for diabetes', true, '2025-12-01 00:29:28.79316', 'Điều trị chính cho bệnh tiểu đường.');
INSERT INTO public.drughealthcondition VALUES (143, 2002, 13, 'Prevents clot development', true, '2025-12-01 00:29:28.79316', 'Ngăn ngừa cục máu đông phát triển.');
INSERT INTO public.drughealthcondition VALUES (144, 2003, 12, 'Controls blood pressure and protects kidneys', true, '2025-12-01 00:29:28.79316', 'Kiểm soát huyết áp và bảo vệ thận.');
INSERT INTO public.drughealthcondition VALUES (145, 2004, 14, 'Iron supplementation', true, '2025-12-01 00:29:28.79316', 'Bổ sung sắt dự trữ cho cơ thể.');
INSERT INTO public.drughealthcondition VALUES (146, 2005, 15, 'Increases bone density', true, '2025-12-01 00:29:28.79316', 'Tăng mật độ xương, giảm nguy cơ gãy xương.');
INSERT INTO public.drughealthcondition VALUES (147, 2006, 16, 'Prevents acute gout attacks', true, '2025-12-01 00:29:28.79316', 'Dự phòng cơn gút cấp.');
INSERT INTO public.drughealthcondition VALUES (148, 2007, 18, 'Reduces heartburn symptoms', true, '2025-12-01 00:29:28.79316', 'Giảm triệu chứng ợ nóng và trào ngược.');
INSERT INTO public.drughealthcondition VALUES (149, 2008, 12, 'For resistant hypertension', false, '2025-12-01 00:29:28.79316', 'Dùng cho trường hợp cao huyết áp kháng trị.');
INSERT INTO public.drughealthcondition VALUES (150, 7, 11, 'Treatment of diabetes mellitus type 2', true, '2025-12-01 00:29:28.79316', 'Điều trị đái tháo đường type 2');
INSERT INTO public.drughealthcondition VALUES (151, 7, 12, 'Treatment of chronic pain', true, '2025-12-01 00:29:28.79316', 'Điều trị đau mãn tính');
INSERT INTO public.drughealthcondition VALUES (152, 27, 37, 'Treatment of bacterial infections', true, '2025-12-01 00:29:28.79316', 'Điều trị nhiễm khuẩn');
INSERT INTO public.drughealthcondition VALUES (153, 27, 25, 'Treatment of bacterial infections', true, '2025-12-01 00:29:28.79316', 'Điều trị nhiễm trùng Salmonella');
INSERT INTO public.drughealthcondition VALUES (154, 1, 13, 'Anticoagulation in HIT patients', true, '2025-12-01 00:29:28.79316', 'Chống đông máu cho bệnh nhân HIT');
INSERT INTO public.drughealthcondition VALUES (155, 9, 13, 'Direct thrombin inhibition', true, '2025-12-01 00:29:28.79316', 'Ức chế thrombin trực tiếp ngăn huyết khối');
INSERT INTO public.drughealthcondition VALUES (156, 13, 13, 'Thrombolysis in acute stroke', true, '2025-12-01 00:29:28.79316', 'Tiêu huyết khối trong đột quỵ cấp');
INSERT INTO public.drughealthcondition VALUES (157, 17, 14, 'Stimulates red blood cell production', true, '2025-12-01 00:29:28.79316', 'Kích thích sản xuất hồng cầu');
INSERT INTO public.drughealthcondition VALUES (158, 23, 14, 'Treatment of anemia in CKD', true, '2025-12-01 00:29:28.79316', 'Điều trị thiếu máu trong bệnh thận mãn');
INSERT INTO public.drughealthcondition VALUES (159, 24, 15, 'Reduces bone resorption', true, '2025-12-01 00:29:28.79316', 'Giảm tiêu xương trong loãng xương');
INSERT INTO public.drughealthcondition VALUES (160, 26, 14, 'Reduces infection risk in neutropenia', false, '2025-12-01 00:29:28.79316', 'Giảm nguy cơ nhiễm trùng khi giảm bạch cầu');
INSERT INTO public.drughealthcondition VALUES (161, 12, 37, 'Treatment of Hepatitis C infection', true, '2025-12-01 00:29:28.79316', 'Điều trị viêm gan C');
INSERT INTO public.drughealthcondition VALUES (162, 28, 37, 'Treatment of Hepatitis C infection', true, '2025-12-01 00:29:28.79316', 'Điều trị viêm gan C');


--
-- TOC entry 6556 (class 0 OID 24019)
-- Dependencies: 391
-- Data for Name: drugnutrientcontraindication; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.drugnutrientcontraindication VALUES (19, 2002, 14, 0.00, 2.00, 'Vitamin K làm giảm tác dụng chống đông của thuốc, dễ gây đông máu lại. Cần ăn lượng ổn định.', 'Vitamin K reduces anticoagulant effect. Maintain consistent intake.', 'High', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (20, 2001, 23, 0.00, 2.00, 'Sử dụng lâu dài làm giảm hấp thu Vitamin B12. Cần bổ sung thêm.', 'Long-term use reduces B12 absorption. Supplement recommended.', 'Medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (21, 2003, 27, 0.00, 2.00, 'Thuốc làm tăng Kali máu. Hạn chế thực phẩm quá giàu Kali để tránh rối loạn nhịp tim.', 'May increase potassium levels. Limit high-K foods.', 'High', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (22, 2008, 27, 0.00, 2.00, 'Nguy cơ tăng Kali máu nghiêm trọng. Tránh ăn nhiều chuối, cam.', 'Severe hyperkalemia risk. Avoid banana, orange.', 'High', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (23, 2005, 24, 0.00, 2.00, 'Canxi làm giảm hấp thu thuốc. Uống thuốc cách bữa ăn hoặc uống bổ sung canxi ít nhất 30 phút.', 'Calcium reduces drug absorption. Separate dosing.', 'High', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (24, 2004, 24, 0.00, 2.00, 'Canxi cản trở hấp thu Sắt. Không uống viên sắt cùng lúc với sữa.', 'Calcium interferes with iron absorption.', 'Medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (25, 2006, 2, 0.00, 2.00, 'Hạn chế đạm động vật giàu purine để thuốc phát huy tác dụng tốt nhất.', 'Limit high-purine animal protein.', 'Medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (26, 7, 30, 0.00, 2.00, 'Tránh kẽm khi dùng Denileukin diftitox', 'Avoid zinc while using Denileukin diftitox', 'medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (27, 27, 24, 0.00, 2.00, 'Tránh canxi khi dùng Sargramostim', 'Avoid calcium while using Sargramostim', 'medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (34, 23, 29, 0.00, 2.00, 'Có thể cần bổ sung sắt', 'Iron supplementation may be needed', 'low', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (28, 27, 29, 0.00, 2.00, 'Tránh sắt khi dùng Sargramostim', 'Avoid iron while using Sargramostim', 'medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (29, 27, 5, 0.00, 2.00, 'Tránh chất xơ khi dùng Sargramostim', 'Avoid fiber while using Sargramostim', 'medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (30, 1, 14, 0.00, 2.00, 'Vitamin K có thể ảnh hưởng chống đông máu', 'Vitamin K may affect anticoagulation', 'medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (31, 9, 14, 0.00, 2.00, 'Theo dõi lượng vitamin K khi dùng thuốc chống đông', 'Monitor vitamin K intake with anticoagulant', 'medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (32, 13, 14, 0.00, 2.00, 'Vitamin K giảm tác dụng tiêu huyết khối', 'Vitamin K reduces thrombolytic effect', 'high', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (33, 17, 29, 0.00, 2.00, 'Theo dõi mức sắt khi dùng EPO', 'Monitor iron levels during EPO therapy', 'medium', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (35, 24, 24, 0.00, 2.00, 'Dùng cùng canxi để cải thiện xương', 'Take with calcium for better bone health', 'low', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (36, 26, 29, 0.00, 2.00, 'Theo dõi sắt khi điều trị giảm bạch cầu', 'Monitor iron during neutropenia treatment', 'low', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (37, 28, 3, 0.00, 2.00, 'Tránh bữa ăn nhiều chất béo khi điều trị', 'Avoid high-fat meals during treatment', 'low', '2025-12-01 00:09:51.256773');
INSERT INTO public.drugnutrientcontraindication VALUES (38, 12, 3, 0.00, 2.00, 'Uống khi đói hoặc với bữa ăn ít béo', 'Take on empty stomach or with low-fat meal', 'low', '2025-12-01 00:09:51.256773');


--
-- TOC entry 6439 (class 0 OID 21624)
-- Dependencies: 264
-- Data for Name: fattyacid; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fattyacid VALUES (1, 'ALA', 'ALA (Alpha-Linolenic Acid)', 'Plant-based omega-3 fatty acid', 'g', '#00CED1', true, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fattyacid VALUES (2, 'EPA', 'EPA (Eicosapentaenoic Acid)', 'Marine omega-3 fatty acid', 'g', '#1E90FF', true, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fattyacid VALUES (3, 'DHA', 'DHA (Docosahexaenoic Acid)', 'Marine omega-3 fatty acid', 'g', '#4169E1', true, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fattyacid VALUES (4, 'EPA_DHA', 'EPA + DHA Combined', 'Combined EPA and DHA', 'g', '#0000CD', true, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fattyacid VALUES (5, 'LA', 'LA (Linoleic Acid)', 'Omega-6 fatty acid', 'g', '#FFA500', false, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fattyacid VALUES (6, 'CHOLESTEROL', 'Cholesterol', 'Dietary cholesterol', 'mg', '#8B0000', false, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fattyacid VALUES (7, 'TOTAL_FAT', 'Total Fat', 'Total fat content', 'g', '#DC143C', true, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fattyacid VALUES (15, 'PUFA', 'Polyunsaturated Fat (PUFA)', 'Polyunsaturated fatty acids', 'g', '#1ABC9C', false, false, '2025-11-20 19:35:46.721858');
INSERT INTO public.fattyacid VALUES (16, 'TRANS_FAT', 'Trans Fat (total)', 'Trans fatty acids', 'g', '#7F8C8D', false, false, '2025-11-20 19:35:46.721858');
INSERT INTO public.fattyacid VALUES (17, 'MUFA', 'Monounsaturated Fat (MUFA)', 'Monounsaturated fatty acids', 'g', '#27AE60', false, false, '2025-11-20 19:35:46.721858');
INSERT INTO public.fattyacid VALUES (18, 'SFA', 'Saturated Fat (SFA)', 'Saturated fatty acids', 'g', '#E74C3C', false, false, '2025-11-20 19:35:46.721858');


--
-- TOC entry 6443 (class 0 OID 21660)
-- Dependencies: 268
-- Data for Name: fattyacidrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fattyacidrequirement VALUES (1, 7, NULL, NULL, NULL, NULL, 'g', false, true, 30.0000, 'Total fat: default 30% of energy (range 25-35%)');
INSERT INTO public.fattyacidrequirement VALUES (2, 18, NULL, NULL, NULL, NULL, 'g', false, true, 10.0000, 'Saturated fat: limit to <10% energy');
INSERT INTO public.fattyacidrequirement VALUES (3, 17, NULL, NULL, NULL, NULL, 'g', false, true, 12.5000, 'MUFA: recommended ~10-15% energy (use 12.5%)');
INSERT INTO public.fattyacidrequirement VALUES (4, 15, NULL, NULL, NULL, NULL, 'g', false, true, 7.5000, 'PUFA: recommended ~5-10% energy (use 7.5%)');
INSERT INTO public.fattyacidrequirement VALUES (5, 4, NULL, NULL, NULL, 250.000000, 'mg', false, false, NULL, 'EPA+DHA baseline: 250 mg/day (adjusted by gender)');
INSERT INTO public.fattyacidrequirement VALUES (6, 5, NULL, NULL, NULL, NULL, 'g', false, true, 5.0000, 'Omega-6 (LA): recommended ~4-6% energy (use 5%)');
INSERT INTO public.fattyacidrequirement VALUES (7, 16, NULL, NULL, NULL, NULL, 'g', false, true, 1.0000, 'Trans fat: target ≤1% energy');
INSERT INTO public.fattyacidrequirement VALUES (8, 6, NULL, NULL, NULL, 300.000000, 'mg', false, false, NULL, 'Cholesterol: default 300 mg/day, reduced for older adults');


--
-- TOC entry 6437 (class 0 OID 21606)
-- Dependencies: 262
-- Data for Name: fiber; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fiber VALUES (1, 'RESISTANT_STARCH', 'Resistant Starch', 'Starch that resists digestion', 'g', '#8B6914', false, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fiber VALUES (2, 'BETA_GLUCAN', 'Beta-Glucan', 'Soluble fiber found in oats and barley', 'g', '#CD853F', false, false, '2025-11-19 07:13:01.565164');
INSERT INTO public.fiber VALUES (5, 'INSOLUBLE_FIBER', 'Insoluble Fiber', 'Adds bulk and supports bowel regularity', 'g', '#8D6E63', false, false, '2025-11-20 19:35:46.721858');
INSERT INTO public.fiber VALUES (6, 'TOTAL_FIBER', 'Total Dietary Fiber', 'Sum of soluble and insoluble fiber', 'g', '#4CAF50', true, false, '2025-11-20 19:35:46.721858');
INSERT INTO public.fiber VALUES (7, 'SOLUBLE_FIBER', 'Soluble Fiber', 'Viscous fiber; aids cholesterol and glycemic control', 'g', '#42A5F5', true, false, '2025-11-20 19:35:46.721858');


--
-- TOC entry 6441 (class 0 OID 21642)
-- Dependencies: 266
-- Data for Name: fiberrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fiberrequirement VALUES (1, 6, NULL, NULL, NULL, 25.000000, 'g', false, false, NULL, 'WHO/FAO recommended total dietary fiber (general adult guidance ~25 g/day)');
INSERT INTO public.fiberrequirement VALUES (2, 7, NULL, NULL, NULL, 7.000000, 'g', false, false, NULL, 'Soluble fiber guidance (approximate)');
INSERT INTO public.fiberrequirement VALUES (3, 5, NULL, NULL, NULL, 15.000000, 'g', false, false, NULL, 'Insoluble fiber guidance (approximate)');
INSERT INTO public.fiberrequirement VALUES (4, 1, NULL, NULL, NULL, 10.000000, 'g', false, false, NULL, 'Resistant starch guidance (approximate)');
INSERT INTO public.fiberrequirement VALUES (5, 2, NULL, NULL, NULL, 3.000000, 'g', false, false, NULL, 'Beta-glucan guidance (oats/barley soluble fiber)');
INSERT INTO public.fiberrequirement VALUES (6, 6, NULL, 1, 3, 19.000000, 'g', false, false, NULL, 'AI for children 1-3 years');
INSERT INTO public.fiberrequirement VALUES (7, 6, NULL, 4, 8, 25.000000, 'g', false, false, NULL, 'AI for children 4-8 years');
INSERT INTO public.fiberrequirement VALUES (8, 6, 'male', 9, 13, 31.000000, 'g', false, false, NULL, 'AI for males 9-13 years');
INSERT INTO public.fiberrequirement VALUES (9, 6, 'male', 14, 18, 38.000000, 'g', false, false, NULL, 'AI for males 14-18 years');
INSERT INTO public.fiberrequirement VALUES (10, 6, 'male', 19, 50, 38.000000, 'g', false, false, NULL, 'AI for adult males 19-50');
INSERT INTO public.fiberrequirement VALUES (11, 6, 'male', 51, 120, 30.000000, 'g', false, false, NULL, 'AI for males 51+');
INSERT INTO public.fiberrequirement VALUES (12, 6, 'female', 9, 13, 26.000000, 'g', false, false, NULL, 'AI for females 9-13 years');
INSERT INTO public.fiberrequirement VALUES (13, 6, 'female', 14, 18, 26.000000, 'g', false, false, NULL, 'AI for females 14-18 years');
INSERT INTO public.fiberrequirement VALUES (14, 6, 'female', 19, 50, 25.000000, 'g', false, false, NULL, 'AI for adult females 19-50');
INSERT INTO public.fiberrequirement VALUES (15, 6, 'female', 51, 120, 21.000000, 'g', false, false, NULL, 'AI for females 51+');


--
-- TOC entry 6406 (class 0 OID 21203)
-- Dependencies: 231
-- Data for Name: food; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.food VALUES (26, 'Gao', 'grains', NULL, '2025-11-19 17:05:28.915881', NULL, 'White rice grains', 100.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (27, 'Gao nep', 'grains', NULL, '2025-11-19 17:05:28.915881', NULL, 'Sticky rice grains', 100.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (28, 'Banh pho', 'grains', NULL, '2025-11-19 17:05:28.915881', NULL, 'Rice noodle sheets', 100.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (29, 'Banh trang', 'grains', NULL, '2025-11-19 17:05:28.915881', NULL, 'Rice paper', 10.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (30, 'Hanh la', 'vegetables', NULL, '2025-11-19 17:05:28.915881', NULL, 'Green onion/scallion', 20.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (31, 'Ngo', 'vegetables', NULL, '2025-11-19 17:05:28.915881', NULL, 'Cilantro/coriander', 10.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (32, 'Rau song', 'vegetables', NULL, '2025-11-19 17:05:28.915881', NULL, 'Fresh vegetables mix', 50.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (33, 'Rau thom', 'vegetables', NULL, '2025-11-19 17:05:28.915881', NULL, 'Mixed aromatic herbs', 20.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (34, 'Dua leo', 'vegetables', NULL, '2025-11-19 17:05:28.915881', NULL, 'Cucumber', 100.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (35, 'Hanh tay', 'vegetables', NULL, '2025-11-19 17:05:28.915881', NULL, 'Onion', 50.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (36, 'Dua', 'fruits', NULL, '2025-11-19 17:05:28.915881', NULL, 'Pineapple', 100.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (37, 'Dau xanh', 'legumes', NULL, '2025-11-19 17:05:28.915881', NULL, 'Mung beans', 50.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (38, 'Nam', 'vegetables', NULL, '2025-11-19 17:05:28.915881', NULL, 'Mushrooms', 50.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (39, 'Hanh phi', 'condiments', NULL, '2025-11-19 17:05:28.915881', NULL, 'Fried shallots', 10.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (40, 'Nuoc mam', 'condiments', NULL, '2025-11-19 17:05:28.915881', NULL, 'Fish sauce', 15.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (41, 'Duong', 'condiments', NULL, '2025-11-19 17:05:28.915881', NULL, 'Sugar', 10.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (42, 'Tieu', 'condiments', NULL, '2025-11-19 17:05:28.915881', NULL, 'Black pepper', 5.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (43, 'Rau cu', 'vegetables', NULL, '2025-11-19 17:05:28.915881', NULL, 'Mixed vegetables', 100.00, false, true, '2025-11-19 17:05:28.915881', NULL, NULL);
INSERT INTO public.food VALUES (44, 'SuperFood Complete™ (Test Food)', 'Test Foods', 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400', '2025-11-19 17:07:01.619202', 1, NULL, 100.00, false, true, '2025-11-19 17:07:01.619202', NULL, NULL);
INSERT INTO public.food VALUES (45, 'Cơm trắng', 'Ngũ cốc', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (46, 'Bánh mì', 'Ngũ cốc', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (47, 'Phở', 'Ngũ cốc', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (48, 'Bún', 'Ngũ cốc', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (49, 'Miến', 'Ngũ cốc', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (50, 'Rau muống', 'Rau củ', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (51, 'Cải thảo', 'Rau củ', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (52, 'Cà chua', 'Rau củ', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (53, 'Dưa chuột', 'Rau củ', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (54, 'Rau cải', 'Rau củ', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (55, 'Chuối', 'Trái cây', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (56, 'Táo', 'Trái cây', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (57, 'Cam', 'Trái cây', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (58, 'Xoài', 'Trái cây', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (59, 'Dưa hấu', 'Trái cây', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (60, 'Thịt lợn', 'Thịt', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (61, 'Thịt gà', 'Thịt', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (62, 'Thịt bò', 'Thịt', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (63, 'Cá', 'Hải sản', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (64, 'Tôm', 'Hải sản', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (65, 'Trứng gà', 'Trứng', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (66, 'Đậu hũ', 'Đậu', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (67, 'Sữa tươi', 'Sữa', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (68, 'Sữa chua', 'Sữa', NULL, '2025-11-19 17:11:14.097879', NULL, NULL, 100.00, false, true, '2025-11-19 17:11:14.097879', NULL, NULL);
INSERT INTO public.food VALUES (69, 'Ultra Food - Complete Nutrition', 'Test/Reference', NULL, '2025-11-19 22:16:40.041203', 1, NULL, 100.00, false, true, '2025-11-19 22:16:40.041203', NULL, NULL);
INSERT INTO public.food VALUES (70, 'Trà đen khô', 'drink_ingredient', NULL, '2025-11-21 01:07:08.078525', NULL, NULL, 100.00, false, true, '2025-11-21 01:07:08.078525', NULL, NULL);
INSERT INTO public.food VALUES (71, 'Syrup đường', 'drink_ingredient', NULL, '2025-11-21 01:07:08.078525', NULL, NULL, 100.00, false, true, '2025-11-21 01:07:08.078525', NULL, NULL);
INSERT INTO public.food VALUES (72, 'Sữa đặc có đường', 'drink_ingredient', NULL, '2025-11-21 01:07:08.078525', NULL, NULL, 100.00, false, true, '2025-11-21 01:07:08.078525', NULL, NULL);
INSERT INTO public.food VALUES (73, 'Sữa tươi thanh trùng', 'drink_ingredient', NULL, '2025-11-21 01:07:08.078525', NULL, NULL, 100.00, false, true, '2025-11-21 01:07:08.078525', NULL, NULL);
INSERT INTO public.food VALUES (74, 'Nước cốt dừa', 'drink_ingredient', NULL, '2025-11-21 01:07:08.078525', NULL, NULL, 100.00, false, true, '2025-11-21 01:07:08.078525', NULL, NULL);
INSERT INTO public.food VALUES (75, 'Nước cam cô đặc', 'drink_ingredient', NULL, '2025-11-21 01:07:08.078525', NULL, NULL, 100.00, false, true, '2025-11-21 01:07:08.078525', NULL, NULL);
INSERT INTO public.food VALUES (1, 'Gao', 'grains', NULL, '2025-11-19 07:13:01.565164', NULL, 'White rice grains', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Mật ong phân tích thành phần');
INSERT INTO public.food VALUES (2, 'Gao nep', 'grains', NULL, '2025-11-19 07:13:01.565164', NULL, 'Sticky rice grains', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Rau họ cải phân tích glucosinolate');
INSERT INTO public.food VALUES (3, 'Banh pho', 'grains', NULL, '2025-11-19 07:13:01.565164', NULL, 'Rice noodle sheets', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Sữa bò tươi ít tinh bột nhiều chất xơ');
INSERT INTO public.food VALUES (4, 'Banh trang', 'grains', NULL, '2025-11-19 07:13:01.565164', NULL, 'Rice paper', 10.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bào ngư');
INSERT INTO public.food VALUES (10, 'Hanh tay', 'vegetables', NULL, '2025-11-19 07:13:01.565164', NULL, 'Onion', 50.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Adobo với mì');
INSERT INTO public.food VALUES (3036, 'Goi Ga (Chicken Salad)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Gỏi gà bắp cải');
INSERT INTO public.food VALUES (3037, 'Chao Tom (Shrimp on Sugarcane)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Chạo tôm');
INSERT INTO public.food VALUES (84, 'Phô mai', 'Sữa', 'https://example.com/cheese.jpg', '2025-11-22 19:10:42.614303', 1, NULL, 100.00, false, true, '2025-11-22 19:10:42.614303', NULL, NULL);
INSERT INTO public.food VALUES (85, 'Cá mòi', 'Hải sản', 'https://example.com/sardine.jpg', '2025-11-22 19:10:42.614303', 1, NULL, 100.00, false, true, '2025-11-22 19:10:42.614303', NULL, NULL);
INSERT INTO public.food VALUES (86, 'Hạnh nhân', 'Hạt', 'https://example.com/almond.jpg', '2025-11-22 19:10:42.614303', 1, NULL, 100.00, false, true, '2025-11-22 19:10:42.614303', NULL, NULL);
INSERT INTO public.food VALUES (87, 'SuperFood Complete™ - Complete Nutrition (100% All Nutrients)', 'Test/Reference', 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400', '2025-11-22 21:58:31.22252', 1, 'Super food chứa 100% tất cả các chất dinh dưỡng cần thiết. Dùng để test và đảm bảo tất cả nutrient được cập nhật đúng. Khẩu phần chuẩn: 100g', 100.00, false, true, '2025-11-22 21:58:31.22252', NULL, NULL);
INSERT INTO public.food VALUES (90, 'Nước có gas', 'Beverages', NULL, '2025-11-25 19:21:40.853343', NULL, 'Nước có gas cacbonic', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Giá cải bông sống');
INSERT INTO public.food VALUES (99, 'Chanh tươi', 'Fruits', NULL, '2025-11-25 19:21:40.853343', NULL, 'Quả chanh vàng/xanh tươi', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bơ hạnh nhân');
INSERT INTO public.food VALUES (100, 'Dưa hấu', 'Fruits', NULL, '2025-11-25 19:21:40.853343', NULL, 'Dưa hấu đỏ tươi', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bánh mì bơ hạnh nhân và mứt');
INSERT INTO public.food VALUES (3038, 'Nem Nuong (Grilled Pork Sausage)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Nem nướng');
INSERT INTO public.food VALUES (3039, 'Dau Hu Sot Ca Chua', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Đậu hũ sốt cà chua');
INSERT INTO public.food VALUES (3040, 'Canh Suon Ham (Pork Rib Soup)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Canh sườn hầm củ cải');
INSERT INTO public.food VALUES (8, 'Rau thom', 'vegetables', NULL, '2025-11-19 07:13:01.565164', NULL, 'Mixed aromatic herbs', 20.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Súp hạt sồi kiểu Apache');
INSERT INTO public.food VALUES (9, 'Dua leo', 'vegetables', NULL, '2025-11-19 07:13:01.565164', NULL, 'Cucumber', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Thực phẩm chay giàu B12 và Folate');
INSERT INTO public.food VALUES (11, 'Dua', 'fruits', NULL, '2025-11-19 07:13:01.565164', NULL, 'Pineapple', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Adobo với cơm');
INSERT INTO public.food VALUES (12, 'Dau xanh', 'legumes', NULL, '2025-11-19 07:13:01.565164', NULL, 'Mung beans', 50.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Chất ngọt từ cây thùa');
INSERT INTO public.food VALUES (13, 'Nam', 'vegetables', NULL, '2025-11-19 07:13:01.565164', NULL, 'Mushrooms', 50.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Thùa nấu chín');
INSERT INTO public.food VALUES (14, 'Hanh phi', 'condiments', NULL, '2025-11-19 07:13:01.565164', NULL, 'Fried shallots', 10.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Thùa sấy khô');
INSERT INTO public.food VALUES (15, 'Nuoc mam', 'condiments', NULL, '2025-11-19 07:13:01.565164', NULL, 'Fish sauce', 15.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Thùa tươi');
INSERT INTO public.food VALUES (16, 'Duong', 'condiments', NULL, '2025-11-19 07:13:01.565164', NULL, 'Sugar', 10.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Kem cá Alaska');
INSERT INTO public.food VALUES (17, 'Tieu', 'condiments', NULL, '2025-11-19 07:13:01.565164', NULL, 'Black pepper', 5.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Kem cá berry Alaska');
INSERT INTO public.food VALUES (18, 'Rau cu', 'vegetables', NULL, '2025-11-19 07:13:01.565164', NULL, 'Mixed vegetables', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Kem thịt tuần lộc Alaska');
INSERT INTO public.food VALUES (19, 'Alcoholic beverage, beer, light', NULL, NULL, '2025-12-01 00:30:31.863845', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bia nhẹ');
INSERT INTO public.food VALUES (20, 'Nam', 'vegetables', NULL, '2025-11-19 07:14:38.240043', NULL, 'Mushrooms', 50.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bia Bud Light');
INSERT INTO public.food VALUES (21, 'Hanh phi', 'condiments', NULL, '2025-11-19 07:14:38.240043', NULL, 'Fried shallots', 10.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bia Budweiser Select');
INSERT INTO public.food VALUES (22, 'Nuoc mam', 'condiments', NULL, '2025-11-19 07:14:38.240043', NULL, 'Fish sauce', 15.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bia nhẹ độ cao');
INSERT INTO public.food VALUES (23, 'Duong', 'condiments', NULL, '2025-11-19 07:14:38.240043', NULL, 'Sugar', 10.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bia nhẹ ít carb');
INSERT INTO public.food VALUES (24, 'Tieu', 'condiments', NULL, '2025-11-19 07:14:38.240043', NULL, 'Black pepper', 5.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bia thường');
INSERT INTO public.food VALUES (25, 'Rau cu', 'vegetables', NULL, '2025-11-19 07:14:38.240043', NULL, 'Mixed vegetables', 100.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Bia Budweiser');
INSERT INTO public.food VALUES (88, 'Nước lọc', 'Beverages', NULL, '2025-11-25 19:21:40.853343', NULL, 'Nước tinh lọc không có tạp chất', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (89, 'Nước khoáng', 'Beverages', NULL, '2025-11-25 19:21:40.853343', NULL, 'Nước khoáng thiên nhiên chứa các khoáng chất', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (91, 'Nước dừa tươi', 'Beverages', NULL, '2025-11-25 19:21:40.853343', NULL, 'Nước dừa xiêm tươi tự nhiên', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (92, 'Nước mía', 'Beverages', NULL, '2025-11-25 19:21:40.853343', NULL, 'Nước ép từ cây mía tươi', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (93, 'Lá trà xanh', 'Beverages', NULL, '2025-11-25 19:21:40.853343', NULL, 'Lá trà xanh khô dùng để pha', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (94, 'Lá trà đen', 'Beverages', NULL, '2025-11-25 19:21:40.853343', NULL, 'Lá trà đen khô', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (95, 'Cà phê bột', 'Beverages', NULL, '2025-11-25 19:21:40.853343', NULL, 'Hạt cà phê rang xay', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (96, 'Sữa tươi nguyên kem', 'Dairy', NULL, '2025-11-25 19:21:40.853343', NULL, 'Sữa bò tươi nguyên chất', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (97, 'Sữa đặc có đường', 'Dairy', NULL, '2025-11-25 19:21:40.853343', NULL, 'Sữa đặc ngọt', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (98, 'Cam tươi', 'Fruits', NULL, '2025-11-25 19:21:40.853343', NULL, 'Quả cam canh tươi', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (101, 'Xoài chín', 'Fruits', NULL, '2025-11-25 19:21:40.853343', NULL, 'Xoài cát Hòa Lộc chín', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (102, 'Bơ (Quả)', 'Fruits', NULL, '2025-11-25 19:21:40.853343', NULL, 'Quả bơ booth chín', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (103, 'Trân châu đen', 'Ingredients', NULL, '2025-11-25 19:21:40.853343', NULL, 'Trân châu bột sắn nấu chín', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (104, 'Sữa chua không đường', 'Dairy', NULL, '2025-11-25 19:21:40.853343', NULL, 'Sữa chua nguyên chất', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (105, 'Rau má', 'Vegetables', NULL, '2025-11-25 19:21:40.853343', NULL, 'Rau má tươi', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (106, 'Đậu nành', 'Legumes', NULL, '2025-11-25 19:21:40.853343', NULL, 'Đậu nành hạt luộc chín', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (107, 'Hạnh nhân sống', 'Nuts', NULL, '2025-11-25 19:21:40.853343', NULL, 'Hạt hạnh nhân nguyên vỏ', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (108, 'Thịt dừa', 'Fruits', NULL, '2025-11-25 19:21:40.853343', NULL, 'Thịt dừa tươi cạo nhuyễn', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (109, 'Đường trắng', 'Sweeteners', NULL, '2025-11-25 19:21:40.853343', NULL, 'Đường mía tinh luyện', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (110, 'Đá lạnh', 'Ingredients', NULL, '2025-11-25 19:21:40.853343', NULL, 'Nước đá đông lạnh', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (111, 'Mật ong', 'Sweeteners', NULL, '2025-11-25 19:21:40.853343', NULL, 'Mật ong nguyên chất', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (112, 'Bột trà sữa', 'Ingredients', NULL, '2025-11-25 19:21:40.853343', NULL, 'Hỗn hợp bột pha trà sữa', 100.00, false, true, '2025-11-25 19:21:40.853343', NULL, NULL);
INSERT INTO public.food VALUES (3001, 'Spinach, cooked', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Rau bina (Cải bó xôi) nấu chín');
INSERT INTO public.food VALUES (3002, 'Kale, raw', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Cải xoăn (Kale) sống');
INSERT INTO public.food VALUES (3003, 'Beef Liver', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Gan bò');
INSERT INTO public.food VALUES (3004, 'Banana', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Chuối');
INSERT INTO public.food VALUES (3005, 'Orange Juice', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Nước cam ép');
INSERT INTO public.food VALUES (3006, 'Yogurt, plain', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Sữa chua không đường');
INSERT INTO public.food VALUES (3007, 'Salmon', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Cá hồi');
INSERT INTO public.food VALUES (3008, 'White Rice, cooked', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Cơm trắng');
INSERT INTO public.food VALUES (3009, 'Broccoli', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Súp lơ xanh');
INSERT INTO public.food VALUES (3010, 'Milk, whole', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Sữa tươi nguyên kem');
INSERT INTO public.food VALUES (3011, 'Pho Bo (Beef Pho)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Phở bò');
INSERT INTO public.food VALUES (3012, 'Bun Cha (Grilled Pork with Noodles)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Bún chả');
INSERT INTO public.food VALUES (3013, 'Com Tam (Broken Rice)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Cơm tấm');
INSERT INTO public.food VALUES (3014, 'Banh Mi (Vietnamese Sandwich)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Bánh mì Việt Nam');
INSERT INTO public.food VALUES (3015, 'Goi Cuon (Fresh Spring Rolls)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Gỏi cuốn');
INSERT INTO public.food VALUES (3016, 'Canh Chua (Sour Soup)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Canh chua cá');
INSERT INTO public.food VALUES (3017, 'Rau Muong Xao Toi (Water Spinach)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Rau muống xào tỏi');
INSERT INTO public.food VALUES (3018, 'Ca Kho To (Caramelized Fish)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Cá kho tộ');
INSERT INTO public.food VALUES (3019, 'Thit Kho Trung (Braised Pork with Eggs)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Thịt kho trứng');
INSERT INTO public.food VALUES (3020, 'Xoi (Sticky Rice)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Xôi');
INSERT INTO public.food VALUES (3021, 'Bun Bo Hue', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Bún bò Huế');
INSERT INTO public.food VALUES (3022, 'Banh Xeo (Sizzling Pancake)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Bánh xèo');
INSERT INTO public.food VALUES (3023, 'Cha Gio (Spring Rolls)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Chả giò');
INSERT INTO public.food VALUES (3024, 'Mi Quang', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Mì Quảng');
INSERT INTO public.food VALUES (3025, 'Cao Lau', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Cao lầu Hội An');
INSERT INTO public.food VALUES (3026, 'Bun Rieu (Crab Noodle Soup)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Bún riêu');
INSERT INTO public.food VALUES (3027, 'Hu Tieu (Pork Noodle Soup)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Hủ tiếu Nam Vang');
INSERT INTO public.food VALUES (3028, 'Banh Cuon (Steamed Rice Rolls)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Bánh cuốn');
INSERT INTO public.food VALUES (3029, 'Che (Sweet Soup)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Chè đậu xanh');
INSERT INTO public.food VALUES (3030, 'Banh Flan (Caramel Custard)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Bánh flan');
INSERT INTO public.food VALUES (3031, 'Bo Luc Lac (Shaking Beef)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Bò lúc lắc');
INSERT INTO public.food VALUES (3032, 'Ga Kho Gung (Braised Chicken)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Gà kho gừng');
INSERT INTO public.food VALUES (3033, 'Canh Khổ Qua (Bitter Melon Soup)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Canh khổ qua nhồi thịt');
INSERT INTO public.food VALUES (3034, 'Thit Kho Tau (Braised Pork)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Thịt kho tàu');
INSERT INTO public.food VALUES (3035, 'Ca Ri Ga (Chicken Curry)', NULL, NULL, '2025-12-01 00:09:51.290414', NULL, NULL, 100.00, true, true, '2025-12-01 00:30:31.867435', NULL, 'Cà ri gà');
INSERT INTO public.food VALUES (5, 'Hanh la', 'vegetables', NULL, '2025-11-19 07:13:01.565164', NULL, 'Green onion/scallion', 20.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Abiyuch sống');
INSERT INTO public.food VALUES (6, 'Ngo', 'vegetables', NULL, '2025-11-19 07:13:01.565164', NULL, 'Cilantro/coriander', 10.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Nước ép acerola');
INSERT INTO public.food VALUES (7, 'Rau song', 'vegetables', NULL, '2025-11-19 07:13:01.565164', NULL, 'Fresh vegetables mix', 50.00, true, true, '2025-12-01 00:30:31.863845', NULL, 'Cherry Tây Ấn (Acerola) sống');


--
-- TOC entry 6484 (class 0 OID 22192)
-- Dependencies: 313
-- Data for Name: foodcategory; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.foodcategory VALUES (1, 'Vegetables', 'All types of vegetables', '🥦', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (2, 'Fruits', 'Fresh and dried fruits', '🍎', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (3, 'Grains', 'Rice, bread, pasta, cereals', '🌾', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (4, 'Protein Foods', 'Meat, poultry, fish, eggs, beans', '🥩', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (5, 'Dairy', 'Milk, cheese, yogurt', '🥛', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (6, 'Oils & Fats', 'Cooking oils, butter, margarine', '🧈', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (7, 'Beverages', 'Drinks and liquids', '🥤', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (8, 'Snacks', 'Chips, crackers, sweets', '🍿', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (9, 'Mixed Dishes', 'Combined food items', '🍱', '2025-11-19 06:55:28.635343');
INSERT INTO public.foodcategory VALUES (10, 'Others', 'Miscellaneous food items', '🍽️', '2025-11-19 06:55:28.635343');


--
-- TOC entry 6410 (class 0 OID 21236)
-- Dependencies: 235
-- Data for Name: foodnutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.foodnutrient VALUES (1035, 2, 26, 24.19);
INSERT INTO public.foodnutrient VALUES (1036, 2, 2, 3.70);
INSERT INTO public.foodnutrient VALUES (1037, 2, 4, 26.21);
INSERT INTO public.foodnutrient VALUES (1038, 2, 5, 40.12);
INSERT INTO public.foodnutrient VALUES (1039, 2, 29, 30.12);
INSERT INTO public.foodnutrient VALUES (1040, 2, 28, 41.55);
INSERT INTO public.foodnutrient VALUES (1041, 2, 24, 38.58);
INSERT INTO public.foodnutrient VALUES (1042, 2, 3, 37.13);
INSERT INTO public.foodnutrient VALUES (1043, 3, 14, 22.51);
INSERT INTO public.foodnutrient VALUES (1044, 3, 15, 27.10);
INSERT INTO public.foodnutrient VALUES (1045, 3, 24, 45.48);
INSERT INTO public.foodnutrient VALUES (1046, 3, 29, 37.12);
INSERT INTO public.foodnutrient VALUES (1047, 3, 27, 12.20);
INSERT INTO public.foodnutrient VALUES (1048, 4, 26, 33.50);
INSERT INTO public.foodnutrient VALUES (1049, 4, 2, 25.93);
INSERT INTO public.foodnutrient VALUES (1050, 4, 28, 48.17);
INSERT INTO public.foodnutrient VALUES (1051, 4, 27, 32.74);
INSERT INTO public.foodnutrient VALUES (1052, 4, 29, 14.28);
INSERT INTO public.foodnutrient VALUES (1053, 4, 5, 25.93);
INSERT INTO public.foodnutrient VALUES (1054, 5, 28, 23.43);
INSERT INTO public.foodnutrient VALUES (1055, 5, 3, 39.04);
INSERT INTO public.foodnutrient VALUES (1056, 5, 5, 16.17);
INSERT INTO public.foodnutrient VALUES (1057, 5, 14, 1.04);
INSERT INTO public.foodnutrient VALUES (1058, 5, 30, 29.39);
INSERT INTO public.foodnutrient VALUES (1059, 5, 24, 40.62);
INSERT INTO public.foodnutrient VALUES (1060, 5, 27, 9.17);
INSERT INTO public.foodnutrient VALUES (1061, 6, 4, 7.54);
INSERT INTO public.foodnutrient VALUES (1062, 6, 30, 34.35);
INSERT INTO public.foodnutrient VALUES (1063, 6, 2, 33.65);
INSERT INTO public.foodnutrient VALUES (1064, 6, 14, 33.19);
INSERT INTO public.foodnutrient VALUES (1065, 7, 28, 44.51);
INSERT INTO public.foodnutrient VALUES (1066, 7, 26, 19.39);
INSERT INTO public.foodnutrient VALUES (1067, 7, 14, 17.61);
INSERT INTO public.foodnutrient VALUES (1068, 7, 30, 26.89);
INSERT INTO public.foodnutrient VALUES (1069, 7, 4, 5.48);
INSERT INTO public.foodnutrient VALUES (1070, 7, 5, 42.24);
INSERT INTO public.foodnutrient VALUES (1071, 7, 2, 24.82);
INSERT INTO public.foodnutrient VALUES (1072, 8, 27, 42.94);
INSERT INTO public.foodnutrient VALUES (1073, 8, 5, 17.50);
INSERT INTO public.foodnutrient VALUES (1074, 8, 2, 0.69);
INSERT INTO public.foodnutrient VALUES (1075, 8, 3, 41.70);
INSERT INTO public.foodnutrient VALUES (1076, 9, 2, 26.83);
INSERT INTO public.foodnutrient VALUES (1077, 9, 15, 22.20);
INSERT INTO public.foodnutrient VALUES (1078, 9, 29, 29.62);
INSERT INTO public.foodnutrient VALUES (1079, 9, 30, 43.07);
INSERT INTO public.foodnutrient VALUES (1080, 9, 4, 32.15);
INSERT INTO public.foodnutrient VALUES (1081, 9, 14, 35.31);
INSERT INTO public.foodnutrient VALUES (1140, 3001, 14, 493.00);
INSERT INTO public.foodnutrient VALUES (1141, 3001, 27, 466.00);
INSERT INTO public.foodnutrient VALUES (1142, 3001, 29, 3.57);
INSERT INTO public.foodnutrient VALUES (1143, 3001, 24, 136.00);
INSERT INTO public.foodnutrient VALUES (1197, 3013, 2, 6.80);
INSERT INTO public.foodnutrient VALUES (1198, 3013, 3, 5.20);
INSERT INTO public.foodnutrient VALUES (1199, 3013, 28, 380.00);
INSERT INTO public.foodnutrient VALUES (1200, 3014, 4, 25.80);
INSERT INTO public.foodnutrient VALUES (1201, 3014, 2, 8.20);
INSERT INTO public.foodnutrient VALUES (1202, 3014, 3, 7.50);
INSERT INTO public.foodnutrient VALUES (1203, 3014, 24, 45.00);
INSERT INTO public.foodnutrient VALUES (1204, 3014, 29, 1.20);
INSERT INTO public.foodnutrient VALUES (1205, 3015, 2, 5.50);
INSERT INTO public.foodnutrient VALUES (1206, 3015, 4, 12.30);
INSERT INTO public.foodnutrient VALUES (1207, 3015, 3, 2.10);
INSERT INTO public.foodnutrient VALUES (1208, 3015, 5, 2.80);
INSERT INTO public.foodnutrient VALUES (1209, 3015, 15, 15.00);
INSERT INTO public.foodnutrient VALUES (1210, 3016, 15, 25.00);
INSERT INTO public.foodnutrient VALUES (1211, 3016, 2, 6.50);
INSERT INTO public.foodnutrient VALUES (1212, 3016, 27, 280.00);
INSERT INTO public.foodnutrient VALUES (1213, 3016, 28, 420.00);
INSERT INTO public.foodnutrient VALUES (1214, 3017, 14, 312.00);
INSERT INTO public.foodnutrient VALUES (1215, 3017, 29, 2.50);
INSERT INTO public.foodnutrient VALUES (1216, 3017, 24, 99.00);
INSERT INTO public.foodnutrient VALUES (1217, 3017, 15, 55.00);
INSERT INTO public.foodnutrient VALUES (1218, 3017, 2, 2.60);
INSERT INTO public.foodnutrient VALUES (1219, 3018, 2, 18.50);
INSERT INTO public.foodnutrient VALUES (1220, 3018, 23, 2.50);
INSERT INTO public.foodnutrient VALUES (1221, 3018, 28, 850.00);
INSERT INTO public.foodnutrient VALUES (1222, 3018, 27, 320.00);
INSERT INTO public.foodnutrient VALUES (1223, 3018, 3, 6.50);
INSERT INTO public.foodnutrient VALUES (1224, 3019, 2, 15.80);
INSERT INTO public.foodnutrient VALUES (1225, 3019, 3, 12.50);
INSERT INTO public.foodnutrient VALUES (1226, 3019, 29, 2.20);
INSERT INTO public.foodnutrient VALUES (1227, 3019, 28, 720.00);
INSERT INTO public.foodnutrient VALUES (1228, 3019, 24, 35.00);
INSERT INTO public.foodnutrient VALUES (1229, 3020, 4, 35.20);
INSERT INTO public.foodnutrient VALUES (1230, 3020, 2, 3.80);
INSERT INTO public.foodnutrient VALUES (1231, 3020, 3, 1.50);
INSERT INTO public.foodnutrient VALUES (1232, 3020, 26, 18.00);
INSERT INTO public.foodnutrient VALUES (1233, 3021, 2, 9.50);
INSERT INTO public.foodnutrient VALUES (1234, 3021, 3, 6.80);
INSERT INTO public.foodnutrient VALUES (1235, 3021, 4, 16.50);
INSERT INTO public.foodnutrient VALUES (1296, 3033, 15, 84.00);
INSERT INTO public.foodnutrient VALUES (1297, 3033, 28, 450.00);
INSERT INTO public.foodnutrient VALUES (1298, 3034, 2, 14.50);
INSERT INTO public.foodnutrient VALUES (1299, 3034, 3, 18.50);
INSERT INTO public.foodnutrient VALUES (1300, 3034, 4, 8.50);
INSERT INTO public.foodnutrient VALUES (1301, 3034, 28, 850.00);
INSERT INTO public.foodnutrient VALUES (1302, 3034, 29, 2.50);
INSERT INTO public.foodnutrient VALUES (1027, 1, 2, 20.30);
INSERT INTO public.foodnutrient VALUES (1028, 1, 24, 21.83);
INSERT INTO public.foodnutrient VALUES (1029, 1, 28, 47.00);
INSERT INTO public.foodnutrient VALUES (1030, 1, 5, 22.83);
INSERT INTO public.foodnutrient VALUES (1031, 1, 29, 29.85);
INSERT INTO public.foodnutrient VALUES (1032, 1, 30, 26.86);
INSERT INTO public.foodnutrient VALUES (1033, 1, 3, 21.77);
INSERT INTO public.foodnutrient VALUES (1034, 1, 14, 41.92);
INSERT INTO public.foodnutrient VALUES (1082, 9, 24, 47.40);
INSERT INTO public.foodnutrient VALUES (1083, 9, 3, 35.73);
INSERT INTO public.foodnutrient VALUES (1084, 10, 15, 29.99);
INSERT INTO public.foodnutrient VALUES (1085, 10, 30, 44.46);
INSERT INTO public.foodnutrient VALUES (1086, 10, 14, 46.01);
INSERT INTO public.foodnutrient VALUES (1087, 10, 2, 30.82);
INSERT INTO public.foodnutrient VALUES (1088, 10, 4, 23.29);
INSERT INTO public.foodnutrient VALUES (1089, 10, 27, 21.45);
INSERT INTO public.foodnutrient VALUES (1090, 10, 5, 16.74);
INSERT INTO public.foodnutrient VALUES (1091, 10, 28, 5.67);
INSERT INTO public.foodnutrient VALUES (1092, 11, 28, 37.24);
INSERT INTO public.foodnutrient VALUES (1093, 11, 4, 9.73);
INSERT INTO public.foodnutrient VALUES (1094, 11, 14, 39.11);
INSERT INTO public.foodnutrient VALUES (1095, 11, 26, 34.40);
INSERT INTO public.foodnutrient VALUES (1096, 12, 4, 40.81);
INSERT INTO public.foodnutrient VALUES (1097, 12, 28, 42.62);
INSERT INTO public.foodnutrient VALUES (1098, 12, 27, 35.12);
INSERT INTO public.foodnutrient VALUES (1099, 12, 5, 2.48);
INSERT INTO public.foodnutrient VALUES (1100, 12, 26, 45.72);
INSERT INTO public.foodnutrient VALUES (1101, 12, 24, 47.01);
INSERT INTO public.foodnutrient VALUES (1102, 13, 26, 33.31);
INSERT INTO public.foodnutrient VALUES (1103, 13, 28, 1.78);
INSERT INTO public.foodnutrient VALUES (1104, 13, 15, 15.93);
INSERT INTO public.foodnutrient VALUES (1105, 13, 27, 1.89);
INSERT INTO public.foodnutrient VALUES (1106, 14, 26, 19.81);
INSERT INTO public.foodnutrient VALUES (1107, 14, 29, 27.10);
INSERT INTO public.foodnutrient VALUES (1108, 14, 3, 44.89);
INSERT INTO public.foodnutrient VALUES (1109, 14, 5, 47.29);
INSERT INTO public.foodnutrient VALUES (1110, 14, 28, 28.96);
INSERT INTO public.foodnutrient VALUES (1111, 14, 2, 32.33);
INSERT INTO public.foodnutrient VALUES (1112, 14, 27, 46.52);
INSERT INTO public.foodnutrient VALUES (1113, 15, 28, 17.57);
INSERT INTO public.foodnutrient VALUES (1114, 15, 5, 23.39);
INSERT INTO public.foodnutrient VALUES (1115, 15, 24, 36.59);
INSERT INTO public.foodnutrient VALUES (1116, 15, 15, 31.14);
INSERT INTO public.foodnutrient VALUES (1117, 15, 3, 45.34);
INSERT INTO public.foodnutrient VALUES (1118, 15, 26, 7.16);
INSERT INTO public.foodnutrient VALUES (1119, 16, 27, 36.09);
INSERT INTO public.foodnutrient VALUES (1120, 16, 3, 32.39);
INSERT INTO public.foodnutrient VALUES (1121, 16, 14, 16.04);
INSERT INTO public.foodnutrient VALUES (1122, 16, 28, 13.13);
INSERT INTO public.foodnutrient VALUES (1123, 16, 24, 9.40);
INSERT INTO public.foodnutrient VALUES (1124, 16, 4, 6.98);
INSERT INTO public.foodnutrient VALUES (1125, 17, 26, 6.67);
INSERT INTO public.foodnutrient VALUES (1126, 17, 3, 35.17);
INSERT INTO public.foodnutrient VALUES (1127, 90, 2, 3.99);
INSERT INTO public.foodnutrient VALUES (1128, 90, 24, 32.00);
INSERT INTO public.foodnutrient VALUES (1129, 90, 29, 0.96);
INSERT INTO public.foodnutrient VALUES (1130, 90, 14, 30.50);
INSERT INTO public.foodnutrient VALUES (1131, 90, 15, 8.20);
INSERT INTO public.foodnutrient VALUES (1132, 99, 2, 20.96);
INSERT INTO public.foodnutrient VALUES (1144, 3001, 26, 87.00);
INSERT INTO public.foodnutrient VALUES (1145, 3001, 2, 2.97);
INSERT INTO public.foodnutrient VALUES (1146, 3002, 14, 817.00);
INSERT INTO public.foodnutrient VALUES (1147, 3002, 24, 150.00);
INSERT INTO public.foodnutrient VALUES (1148, 3002, 15, 120.00);
INSERT INTO public.foodnutrient VALUES (1149, 3002, 26, 47.00);
INSERT INTO public.foodnutrient VALUES (1150, 3002, 29, 1.47);
INSERT INTO public.foodnutrient VALUES (1151, 3003, 23, 83.10);
INSERT INTO public.foodnutrient VALUES (1152, 3003, 29, 4.90);
INSERT INTO public.foodnutrient VALUES (1153, 3003, 2, 20.30);
INSERT INTO public.foodnutrient VALUES (1154, 3003, 24, 5.00);
INSERT INTO public.foodnutrient VALUES (1155, 3003, 30, 4.00);
INSERT INTO public.foodnutrient VALUES (1156, 3004, 27, 358.00);
INSERT INTO public.foodnutrient VALUES (1133, 99, 3, 55.50);
INSERT INTO public.foodnutrient VALUES (1134, 99, 24, 347.00);
INSERT INTO public.foodnutrient VALUES (1135, 99, 26, 279.00);
INSERT INTO public.foodnutrient VALUES (1136, 99, 29, 3.49);
INSERT INTO public.foodnutrient VALUES (1137, 100, 4, 38.50);
INSERT INTO public.foodnutrient VALUES (1138, 100, 2, 10.20);
INSERT INTO public.foodnutrient VALUES (1139, 100, 3, 18.70);
INSERT INTO public.foodnutrient VALUES (1157, 3004, 4, 22.80);
INSERT INTO public.foodnutrient VALUES (1158, 3004, 26, 27.00);
INSERT INTO public.foodnutrient VALUES (1159, 3004, 15, 8.70);
INSERT INTO public.foodnutrient VALUES (1160, 3005, 27, 200.00);
INSERT INTO public.foodnutrient VALUES (1161, 3005, 15, 50.00);
INSERT INTO public.foodnutrient VALUES (1162, 3005, 24, 11.00);
INSERT INTO public.foodnutrient VALUES (1163, 3005, 4, 10.40);
INSERT INTO public.foodnutrient VALUES (1164, 3006, 24, 183.00);
INSERT INTO public.foodnutrient VALUES (1165, 3006, 2, 9.00);
INSERT INTO public.foodnutrient VALUES (1166, 3006, 27, 234.00);
INSERT INTO public.foodnutrient VALUES (1167, 3006, 23, 0.75);
INSERT INTO public.foodnutrient VALUES (1168, 3007, 23, 3.20);
INSERT INTO public.foodnutrient VALUES (1169, 3007, 2, 20.00);
INSERT INTO public.foodnutrient VALUES (1170, 3007, 27, 363.00);
INSERT INTO public.foodnutrient VALUES (1171, 3007, 29, 0.80);
INSERT INTO public.foodnutrient VALUES (1172, 3007, 12, 526.00);
INSERT INTO public.foodnutrient VALUES (1173, 3008, 4, 28.70);
INSERT INTO public.foodnutrient VALUES (1174, 3008, 2, 2.70);
INSERT INTO public.foodnutrient VALUES (1175, 3008, 29, 0.20);
INSERT INTO public.foodnutrient VALUES (1176, 3008, 26, 12.00);
INSERT INTO public.foodnutrient VALUES (1177, 3009, 14, 101.60);
INSERT INTO public.foodnutrient VALUES (1178, 3009, 15, 89.20);
INSERT INTO public.foodnutrient VALUES (1179, 3009, 24, 47.00);
INSERT INTO public.foodnutrient VALUES (1180, 3009, 26, 21.00);
INSERT INTO public.foodnutrient VALUES (1181, 3009, 29, 0.73);
INSERT INTO public.foodnutrient VALUES (1182, 3010, 24, 125.00);
INSERT INTO public.foodnutrient VALUES (1183, 3010, 2, 3.40);
INSERT INTO public.foodnutrient VALUES (1184, 3010, 27, 150.00);
INSERT INTO public.foodnutrient VALUES (1185, 3010, 23, 0.45);
INSERT INTO public.foodnutrient VALUES (1186, 3011, 2, 8.50);
INSERT INTO public.foodnutrient VALUES (1187, 3011, 4, 15.20);
INSERT INTO public.foodnutrient VALUES (1188, 3011, 3, 3.20);
INSERT INTO public.foodnutrient VALUES (1189, 3011, 28, 450.00);
INSERT INTO public.foodnutrient VALUES (1190, 3011, 29, 1.50);
INSERT INTO public.foodnutrient VALUES (1191, 3012, 2, 12.30);
INSERT INTO public.foodnutrient VALUES (1192, 3012, 3, 8.50);
INSERT INTO public.foodnutrient VALUES (1193, 3012, 4, 18.50);
INSERT INTO public.foodnutrient VALUES (1194, 3012, 28, 520.00);
INSERT INTO public.foodnutrient VALUES (1195, 3012, 29, 1.80);
INSERT INTO public.foodnutrient VALUES (1196, 3013, 4, 32.50);
INSERT INTO public.foodnutrient VALUES (1236, 3021, 28, 650.00);
INSERT INTO public.foodnutrient VALUES (1237, 3021, 29, 2.20);
INSERT INTO public.foodnutrient VALUES (1238, 3022, 2, 8.20);
INSERT INTO public.foodnutrient VALUES (1239, 3022, 3, 12.50);
INSERT INTO public.foodnutrient VALUES (1240, 3022, 4, 22.80);
INSERT INTO public.foodnutrient VALUES (1241, 3022, 28, 480.00);
INSERT INTO public.foodnutrient VALUES (1242, 3022, 24, 38.00);
INSERT INTO public.foodnutrient VALUES (1243, 3023, 2, 10.50);
INSERT INTO public.foodnutrient VALUES (1244, 3023, 3, 15.80);
INSERT INTO public.foodnutrient VALUES (1245, 3023, 4, 18.50);
INSERT INTO public.foodnutrient VALUES (1246, 3023, 28, 520.00);
INSERT INTO public.foodnutrient VALUES (1247, 3023, 29, 1.50);
INSERT INTO public.foodnutrient VALUES (1248, 3024, 2, 11.20);
INSERT INTO public.foodnutrient VALUES (1249, 3024, 3, 7.50);
INSERT INTO public.foodnutrient VALUES (1250, 3024, 4, 25.50);
INSERT INTO public.foodnutrient VALUES (1251, 3024, 28, 580.00);
INSERT INTO public.foodnutrient VALUES (1252, 3024, 27, 320.00);
INSERT INTO public.foodnutrient VALUES (1253, 3025, 2, 9.80);
INSERT INTO public.foodnutrient VALUES (1254, 3025, 3, 6.20);
INSERT INTO public.foodnutrient VALUES (1255, 3025, 4, 28.50);
INSERT INTO public.foodnutrient VALUES (1256, 3025, 28, 550.00);
INSERT INTO public.foodnutrient VALUES (1257, 3025, 29, 1.80);
INSERT INTO public.foodnutrient VALUES (1258, 3026, 2, 10.50);
INSERT INTO public.foodnutrient VALUES (1259, 3026, 3, 5.50);
INSERT INTO public.foodnutrient VALUES (1260, 3026, 4, 17.20);
INSERT INTO public.foodnutrient VALUES (1261, 3026, 24, 85.00);
INSERT INTO public.foodnutrient VALUES (1262, 3026, 28, 620.00);
INSERT INTO public.foodnutrient VALUES (1263, 3027, 2, 8.50);
INSERT INTO public.foodnutrient VALUES (1264, 3027, 3, 4.80);
INSERT INTO public.foodnutrient VALUES (1265, 3027, 4, 20.50);
INSERT INTO public.foodnutrient VALUES (1266, 3027, 28, 480.00);
INSERT INTO public.foodnutrient VALUES (1267, 3027, 27, 280.00);
INSERT INTO public.foodnutrient VALUES (1268, 3028, 2, 6.50);
INSERT INTO public.foodnutrient VALUES (1269, 3028, 3, 3.20);
INSERT INTO public.foodnutrient VALUES (1270, 3028, 4, 24.50);
INSERT INTO public.foodnutrient VALUES (1271, 3028, 28, 380.00);
INSERT INTO public.foodnutrient VALUES (1272, 3028, 5, 1.50);
INSERT INTO public.foodnutrient VALUES (1273, 3029, 2, 5.80);
INSERT INTO public.foodnutrient VALUES (1274, 3029, 4, 32.50);
INSERT INTO public.foodnutrient VALUES (1275, 3029, 3, 2.50);
INSERT INTO public.foodnutrient VALUES (1276, 3029, 24, 45.00);
INSERT INTO public.foodnutrient VALUES (1277, 3029, 26, 38.00);
INSERT INTO public.foodnutrient VALUES (1278, 3030, 2, 7.50);
INSERT INTO public.foodnutrient VALUES (1279, 3030, 3, 8.50);
INSERT INTO public.foodnutrient VALUES (1280, 3030, 4, 28.50);
INSERT INTO public.foodnutrient VALUES (1281, 3030, 24, 95.00);
INSERT INTO public.foodnutrient VALUES (1282, 3030, 23, 0.65);
INSERT INTO public.foodnutrient VALUES (1283, 3031, 2, 18.50);
INSERT INTO public.foodnutrient VALUES (1284, 3031, 3, 12.50);
INSERT INTO public.foodnutrient VALUES (1285, 3031, 4, 8.50);
INSERT INTO public.foodnutrient VALUES (1286, 3031, 29, 3.20);
INSERT INTO public.foodnutrient VALUES (1287, 3031, 30, 4.80);
INSERT INTO public.foodnutrient VALUES (1288, 3032, 2, 16.80);
INSERT INTO public.foodnutrient VALUES (1289, 3032, 3, 9.50);
INSERT INTO public.foodnutrient VALUES (1290, 3032, 4, 6.50);
INSERT INTO public.foodnutrient VALUES (1291, 3032, 28, 680.00);
INSERT INTO public.foodnutrient VALUES (1292, 3032, 29, 1.50);
INSERT INTO public.foodnutrient VALUES (1293, 3033, 2, 7.50);
INSERT INTO public.foodnutrient VALUES (1294, 3033, 3, 3.50);
INSERT INTO public.foodnutrient VALUES (1295, 3033, 4, 5.50);
INSERT INTO public.foodnutrient VALUES (1317, 3037, 30, 1.80);
INSERT INTO public.foodnutrient VALUES (1318, 3038, 2, 15.80);
INSERT INTO public.foodnutrient VALUES (1319, 3038, 3, 12.50);
INSERT INTO public.foodnutrient VALUES (1320, 3038, 4, 8.50);
INSERT INTO public.foodnutrient VALUES (1321, 3038, 28, 580.00);
INSERT INTO public.foodnutrient VALUES (1322, 3038, 29, 1.50);
INSERT INTO public.foodnutrient VALUES (1323, 3039, 2, 10.50);
INSERT INTO public.foodnutrient VALUES (1324, 3039, 3, 6.50);
INSERT INTO public.foodnutrient VALUES (1325, 3039, 4, 9.50);
INSERT INTO public.foodnutrient VALUES (1326, 3039, 24, 180.00);
INSERT INTO public.foodnutrient VALUES (1327, 3039, 15, 28.00);
INSERT INTO public.foodnutrient VALUES (1328, 3040, 2, 12.50);
INSERT INTO public.foodnutrient VALUES (1329, 3040, 3, 8.50);
INSERT INTO public.foodnutrient VALUES (1330, 3040, 4, 6.50);
INSERT INTO public.foodnutrient VALUES (1331, 3040, 24, 65.00);
INSERT INTO public.foodnutrient VALUES (1303, 3035, 2, 15.20);
INSERT INTO public.foodnutrient VALUES (1304, 3035, 3, 11.50);
INSERT INTO public.foodnutrient VALUES (1305, 3035, 4, 12.50);
INSERT INTO public.foodnutrient VALUES (1306, 3035, 27, 380.00);
INSERT INTO public.foodnutrient VALUES (1307, 3035, 26, 42.00);
INSERT INTO public.foodnutrient VALUES (1308, 3036, 2, 14.50);
INSERT INTO public.foodnutrient VALUES (1309, 3036, 3, 3.80);
INSERT INTO public.foodnutrient VALUES (1310, 3036, 4, 8.50);
INSERT INTO public.foodnutrient VALUES (1311, 3036, 15, 45.00);
INSERT INTO public.foodnutrient VALUES (1312, 3036, 5, 3.50);
INSERT INTO public.foodnutrient VALUES (1313, 3037, 2, 16.50);
INSERT INTO public.foodnutrient VALUES (1314, 3037, 3, 5.50);
INSERT INTO public.foodnutrient VALUES (1315, 3037, 4, 12.50);
INSERT INTO public.foodnutrient VALUES (1316, 3037, 28, 520.00);
INSERT INTO public.foodnutrient VALUES (1332, 3040, 27, 350.00);


--
-- TOC entry 6412 (class 0 OID 21256)
-- Dependencies: 237
-- Data for Name: foodtag; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6413 (class 0 OID 21264)
-- Dependencies: 238
-- Data for Name: foodtagmapping; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6558 (class 0 OID 24449)
-- Dependencies: 394
-- Data for Name: friendrequest; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.friendrequest VALUES (1, 2, 1, 'accepted', '2025-11-23 22:04:38.429358', '2025-11-24 05:13:42.72614');
INSERT INTO public.friendrequest VALUES (2, 3, 1, 'rejected', '2025-11-24 05:28:25.996759', '2025-11-24 06:25:36.921093');
INSERT INTO public.friendrequest VALUES (3, 1, 3, 'accepted', '2025-11-24 06:26:33.35418', '2025-11-24 06:47:24.985891');
INSERT INTO public.friendrequest VALUES (4, 3, 2, 'accepted', '2025-11-26 16:55:52.514366', '2025-11-26 16:58:48.81072');
INSERT INTO public.friendrequest VALUES (5, 4, 1, 'pending', '2025-11-27 04:52:49.710415', '2025-11-27 04:52:49.710415');


--
-- TOC entry 6560 (class 0 OID 24479)
-- Dependencies: 396
-- Data for Name: friendship; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.friendship VALUES (1, 1, 2, '2025-11-24 05:13:42.72614');
INSERT INTO public.friendship VALUES (2, 1, 3, '2025-11-24 06:47:24.985891');
INSERT INTO public.friendship VALUES (3, 2, 3, '2025-11-26 16:58:48.81072');


--
-- TOC entry 6486 (class 0 OID 22226)
-- Dependencies: 315
-- Data for Name: healthcondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.healthcondition VALUES (1, 'Tiểu đường type 2', 'Type 2 Diabetes', 'Chuyển hóa', 'Cơ thể kháng insulin làm đường huyết tăng cao.', 'Thừa cân, ít vận động, ăn nhiều tinh bột tinh chế.', NULL, 'Dài hạn', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (2, 'Cao huyết áp', 'Hypertension', 'Tim mạch', 'Huyết áp tăng cao mạn tính.', 'Ăn mặn, ít kali, stress, di truyền.', NULL, 'Dài hạn', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (3, 'Mỡ máu cao', 'High Cholesterol', 'Tim mạch', 'LDL và Cholesterol cao dẫn đến xơ vữa mạch.', 'Ăn nhiều mỡ bão hòa, trans fat, ít vận động.', NULL, '3–6 tháng', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (4, 'Béo phì', 'Obesity', 'Chuyển hóa', 'Tích lũy mỡ thừa do thừa năng lượng.', 'Ăn nhiều tinh bột tinh chế, chất béo, ít hoạt động.', NULL, '3–12 tháng', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (5, 'Gout', 'Gout', 'Chuyển hóa', 'Acid uric cao gây viêm khớp.', 'Ăn nhiều purine: thịt đỏ, hải sản.', NULL, '1–3 tháng (duy trì lâu dài)', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (6, 'Gan nhiễm mỡ', 'Fatty Liver', 'Gan', 'Mỡ tích tụ trong gan.', 'Dư đường, chất béo bão hòa, béo phì.', NULL, '2–6 tháng', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (7, 'Viêm dạ dày', 'Gastritis', 'Tiêu hóa', 'Viêm niêm mạc dạ dày.', 'HP, stress, đồ chua và dầu mỡ.', NULL, '2–8 tuần', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (8, 'Thiếu máu', 'Anemia', 'Huyết học', 'Thiếu hồng cầu do thiếu sắt, B12 hoặc folate.', 'Ăn thiếu sắt, thiếu vitamin B12 hoặc B9.', NULL, '1–3 tháng', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (9, 'Suy dinh dưỡng', 'Malnutrition', 'Dinh dưỡng', 'Thiếu năng lượng và đạm.', 'Ăn không đủ protein và năng lượng.', NULL, '1–3 tháng', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (10, 'Dị ứng thực phẩm', 'Food Allergy', 'Miễn dịch', 'Phản ứng miễn dịch với protein thực phẩm.', 'Cơ địa dị ứng, di truyền.', NULL, 'Lâu dài', '2025-11-19 06:56:08.695007', '2025-11-19 06:56:08.695007', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (11, 'Đái tháo đường tuýp 2', 'Type 2 Diabetes Mellitus', 'E11', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (12, 'Tăng huyết áp (Cao huyết áp)', 'Essential Hypertension', 'I10', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (13, 'Huyết khối tĩnh mạch sâu (Cục máu đông)', 'Deep Vein Thrombosis (DVT)', 'I82', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (14, 'Thiếu máu do thiếu sắt', 'Iron Deficiency Anemia', 'D50', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (15, 'Loãng xương', 'Osteoporosis', 'M81', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (16, 'Gút (Gout)', 'Gout', 'M10', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (17, 'Bệnh thận mãn tính', 'Chronic Kidney Disease', 'N18', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (18, 'Trào ngược dạ dày thực quản', 'Gastroesophageal Reflux Disease (GERD)', 'K21', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (20, 'Bệnh tả không đặc hiệu', 'Cholera, unspecified', 'A009', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (21, 'Sốt thương hàn không đặc hiệu', 'Typhoid fever, unspecified', 'A0100', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (25, 'Viêm ruột Salmonella', 'Salmonella enteritis', 'A020', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (26, 'Nhiễm trùng huyết Salmonella', 'Salmonella sepsis', 'A021', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (35, 'Nhiễm E. coli gây bệnh đường ruột', 'Enteropathogenic Escherichia coli infection', 'A040', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (36, 'Viêm ruột Campylobacter', 'Campylobacter enteritis', 'A045', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (37, 'Viêm dạ dày ruột nhiễm trùng', 'Infectious gastroenteritis and colitis, unspecified', 'A09', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (38, 'Lao phổi', 'Tuberculosis of lung', 'A150', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (39, 'Viêm màng não do lao', 'Tuberculous meningitis', 'A170', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (19, 'Rối loạn lipid máu (Mỡ máu cao)', 'Hyperlipidemia', 'E78', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (22, 'Bệnh động mạch vành', 'Coronary Artery Disease', 'I25', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (23, 'Rung nhĩ', 'Atrial Fibrillation', 'I48', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (24, 'Suy tim', 'Heart Failure', 'I50', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (27, 'Hen phế quản', 'Asthma', 'J45', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (28, 'Bệnh phổi tắc nghẽn mãn tính', 'Chronic Obstructive Pulmonary Disease (COPD)', 'J44', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (29, 'Loét dạ dày tá tràng', 'Peptic Ulcer', 'K27', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (30, 'Gan nhiễm mỡ (Fatty Liver)', 'Fatty Liver Disease', 'K76', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (31, 'Viêm khớp dạng thấp', 'Rheumatoid Arthritis', 'M06', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (32, 'Suy giáp', 'Hypothyroidism', 'E03', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (33, 'Cường giáp', 'Hyperthyroidism', 'E05', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);
INSERT INTO public.healthcondition VALUES (34, 'Đau nửa đầu (Migraine)', 'Migraine', 'G43', NULL, NULL, NULL, NULL, '2025-12-01 00:29:28.788236', '2025-12-01 00:29:28.788236', NULL, NULL, NULL);


--
-- TOC entry 6415 (class 0 OID 21282)
-- Dependencies: 240
-- Data for Name: meal; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.meal VALUES (1, 1, 'breakfast', '2025-11-19', '2025-11-19 17:15:20.526323', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (2, 1, 'breakfast', '2025-11-19', '2025-11-19 17:22:51.742888', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (3, 1, 'breakfast', '2025-11-19', '2025-11-19 17:23:02.029974', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (4, 1, 'breakfast', '2025-11-19', '2025-11-19 18:28:37.682973', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (5, 1, 'breakfast', '2025-11-19', '2025-11-19 18:35:23.343518', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (6, 1, 'breakfast', '2025-11-19', '2025-11-19 18:35:28.798292', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (7, 1, 'breakfast', '2025-11-19', '2025-11-19 19:04:28.355553', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (8, 1, 'breakfast', '2025-11-20', '2025-11-19 20:40:13.511318', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (9, 1, 'lunch', '2025-11-20', '2025-11-19 22:47:25.727935', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (10, 1, 'breakfast', '2025-11-20', '2025-11-20 06:10:01.273567', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (11, 1, 'breakfast', '2025-11-20', '2025-11-20 06:19:06.56877', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (12, 1, 'breakfast', '2025-11-20', '2025-11-20 06:23:49.676052', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (13, 1, 'dinner', '2025-11-20', '2025-11-20 06:31:08.301478', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (14, 1, 'breakfast', '2025-11-21', '2025-11-20 17:38:24.726029', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (15, 1, 'breakfast', '2025-11-21', '2025-11-20 17:48:32.300224', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (16, 1, 'snack', '2025-11-21', '2025-11-20 17:53:14.213624', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (17, 1, 'breakfast', '2025-11-21', '2025-11-20 17:58:45.604753', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (18, 1, 'lunch', '2025-11-23', '2025-11-22 21:15:52.896061', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (24, 1, 'snack', '2025-11-23', '2025-11-23 01:26:13.380954', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (25, 1, 'breakfast', '2025-11-24', '2025-11-23 17:45:03.153128', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (26, 1, 'breakfast', '2025-11-24', '2025-11-23 18:14:23.196177', false, NULL, NULL, NULL);
INSERT INTO public.meal VALUES (27, 1, 'breakfast', '2025-11-24', '2025-11-23 18:14:35.826821', false, NULL, NULL, NULL);


--
-- TOC entry 6462 (class 0 OID 21890)
-- Dependencies: 287
-- Data for Name: meal_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.meal_entries VALUES (1, 1, '2025-11-21', 'dinner', 69, 300.00, 1500.00, 120.00, 90.00, 60.00, '2025-11-20 17:58:12.16041-08');
INSERT INTO public.meal_entries VALUES (2, 1, '2025-11-21', 'breakfast', 6, 100.00, 19.00, 3.10, 2.60, 0.20, '2025-11-20 17:59:45.088649-08');
INSERT INTO public.meal_entries VALUES (3, 1, '2025-11-21', 'breakfast', 7, 80.00, 20.00, 4.64, 1.04, 0.08, '2025-11-20 17:59:45.099982-08');
INSERT INTO public.meal_entries VALUES (4, 1, '2025-11-21', 'breakfast', 10, 70.00, 22.40, 5.11, 1.26, 0.14, '2025-11-20 17:59:45.102092-08');
INSERT INTO public.meal_entries VALUES (5, 1, '2025-11-21', 'breakfast', 22, 50.00, 17.50, 1.75, 2.50, 0.00, '2025-11-20 17:59:45.103949-08');
INSERT INTO public.meal_entries VALUES (6, 1, '2025-11-23', 'lunch', 69, 300.00, 1500.00, 120.00, 90.00, 60.00, '2025-11-22 22:20:56.760024-08');
INSERT INTO public.meal_entries VALUES (7, 1, '2025-11-23', 'snack', 69, 300.00, 1500.00, 120.00, 90.00, 60.00, '2025-11-23 00:45:36.192525-08');
INSERT INTO public.meal_entries VALUES (8, 1, '2025-11-23', 'snack', 69, 300.00, 1500.00, 120.00, 90.00, 60.00, '2025-11-23 01:04:38.379562-08');
INSERT INTO public.meal_entries VALUES (9, 1, '2025-11-23', 'snack', 8, 100.00, 23.00, 3.70, 2.10, 0.50, '2025-11-23 01:26:02.805836-08');
INSERT INTO public.meal_entries VALUES (10, 1, '2025-11-23', 'snack', 22, 200.00, 70.00, 7.00, 10.00, 0.00, '2025-11-23 01:26:02.838469-08');
INSERT INTO public.meal_entries VALUES (11, 1, '2025-11-24', 'breakfast', 69, 300.00, 1500.00, 120.00, 90.00, 60.00, '2025-11-23 17:43:52.211841-08');
INSERT INTO public.meal_entries VALUES (12, 1, '2025-11-24', 'breakfast', 69, 300.00, 1500.00, 120.00, 90.00, 60.00, '2025-11-23 18:13:53.445821-08');
INSERT INTO public.meal_entries VALUES (13, 1, '2025-11-24', 'breakfast', 87, 100.00, 1000.00, 1000.00, 1000.00, 1000.00, '2025-11-23 19:37:18.223167-08');
INSERT INTO public.meal_entries VALUES (14, 3, '2025-11-27', 'dinner', 87, 100.00, 1000.00, 1000.00, 1000.00, 1000.00, '2025-11-27 05:51:50.476636-08');
INSERT INTO public.meal_entries VALUES (15, 3, '2025-11-29', 'snack', 87, 100.00, 1000.00, 1000.00, 1000.00, 1000.00, '2025-11-29 01:34:58.874873-08');


--
-- TOC entry 6417 (class 0 OID 21298)
-- Dependencies: 242
-- Data for Name: mealitem; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6419 (class 0 OID 21318)
-- Dependencies: 244
-- Data for Name: mealnote; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6506 (class 0 OID 22467)
-- Dependencies: 335
-- Data for Name: mealtemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6508 (class 0 OID 22488)
-- Dependencies: 337
-- Data for Name: mealtemplateitem; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6492 (class 0 OID 22289)
-- Dependencies: 321
-- Data for Name: medicationlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.medicationlog VALUES (1, 2, 1, '2025-11-23', '12:00:00', '2025-11-22 21:15:30.821333', 'taken', '2025-11-22 21:15:30.821333', NULL, NULL);


--
-- TOC entry 6490 (class 0 OID 22268)
-- Dependencies: 319
-- Data for Name: medicationschedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.medicationschedule VALUES (1, 2, 1, '{07:00,12:00,19:00}', NULL, '2025-11-22 17:22:00.803486', '{"07:00": {"notes": "", "period": "morning"}, "12:00": {"notes": "", "period": "afternoon"}, "19:00": {"notes": "", "period": "evening"}}', NULL);
INSERT INTO public.medicationschedule VALUES (2, 3, 3, '{07:00}', NULL, '2025-11-24 06:27:45.058226', '{"07:00": {"notes": "", "period": "morning"}}', NULL);


--
-- TOC entry 6564 (class 0 OID 24530)
-- Dependencies: 400
-- Data for Name: messagereaction; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6432 (class 0 OID 21541)
-- Dependencies: 257
-- Data for Name: mineral; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.mineral VALUES (1, 'MIN_CA', 'Calcium (Ca)', 'Calcium for bones and teeth', 'mg', 1000.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (2, 'MIN_P', 'Phosphorus (P)', 'Phosphorus for bone and energy metabolism', 'mg', 700.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (3, 'MIN_MG', 'Magnesium (Mg)', 'Magnesium for muscle and nerve function', 'mg', 310.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (4, 'MIN_K', 'Potassium (K)', 'Potassium electrolyte', 'mg', 4700.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (5, 'MIN_NA', 'Sodium (Na)', 'Sodium electrolyte', 'mg', 1500.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (6, 'MIN_FE', 'Iron (Fe)', 'Iron for hemoglobin', 'mg', 18.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (7, 'MIN_ZN', 'Zinc (Zn)', 'Zinc for immune function', 'mg', 11.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (8, 'MIN_CU', 'Copper (Cu)', 'Copper cofactor', 'mg', 0.900, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (9, 'MIN_MN', 'Manganese (Mn)', 'Manganese cofactor', 'mg', 2.300, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (10, 'MIN_I', 'Iodine (I)', 'Iodine for thyroid', 'µg', 150.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (11, 'MIN_SE', 'Selenium (Se)', 'Selenium antioxidant', 'µg', 55.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (12, 'MIN_CR', 'Chromium (Cr)', 'Chromium for metabolism', 'µg', 35.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (13, 'MIN_MO', 'Molybdenum (Mo)', 'Molybdenum enzyme cofactor', 'µg', 45.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.mineral VALUES (14, 'MIN_F', 'Fluoride (F)', 'Fluoride for dental health', 'mg', 3.000, '2025-11-19 06:57:52.829613', NULL);


--
-- TOC entry 6540 (class 0 OID 23152)
-- Dependencies: 375
-- Data for Name: mineralnutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.mineralnutrient VALUES (31, 1, 24, 0.000, 1.000000, 'Direct mapping: CA -> MIN_CA', '2025-11-19 17:33:13.520883');
INSERT INTO public.mineralnutrient VALUES (32, 2, 25, 0.000, 1.000000, 'Direct mapping: P -> MIN_P', '2025-11-19 17:33:13.52465');
INSERT INTO public.mineralnutrient VALUES (33, 3, 26, 0.000, 1.000000, 'Direct mapping: MG -> MIN_MG', '2025-11-19 17:33:13.525838');
INSERT INTO public.mineralnutrient VALUES (34, 4, 27, 0.000, 1.000000, 'Direct mapping: K -> MIN_K', '2025-11-19 17:33:13.527468');
INSERT INTO public.mineralnutrient VALUES (35, 5, 28, 0.000, 1.000000, 'Direct mapping: NA -> MIN_NA', '2025-11-19 17:33:13.528719');
INSERT INTO public.mineralnutrient VALUES (36, 6, 29, 0.000, 1.000000, 'Direct mapping: FE -> MIN_FE', '2025-11-19 17:33:13.529723');
INSERT INTO public.mineralnutrient VALUES (37, 7, 30, 0.000, 1.000000, 'Direct mapping: ZN -> MIN_ZN', '2025-11-19 17:33:13.531096');
INSERT INTO public.mineralnutrient VALUES (38, 8, 31, 0.000, 1.000000, 'Direct mapping: CU -> MIN_CU', '2025-11-19 17:33:13.532452');
INSERT INTO public.mineralnutrient VALUES (39, 9, 32, 0.000, 1.000000, 'Direct mapping: MN -> MIN_MN', '2025-11-19 17:33:13.533671');
INSERT INTO public.mineralnutrient VALUES (40, 11, 34, 0.000, 1.000000, 'Direct mapping: SE -> MIN_SE', '2025-11-19 17:33:13.534674');
INSERT INTO public.mineralnutrient VALUES (41, 10, 33, 0.000, 1.000000, 'Direct mapping: I -> MIN_I', '2025-11-19 17:33:13.535539');
INSERT INTO public.mineralnutrient VALUES (42, 12, 35, 0.000, 1.000000, 'Direct mapping: CR -> MIN_CR', '2025-11-19 17:33:13.536369');
INSERT INTO public.mineralnutrient VALUES (43, 13, 36, 0.000, 1.000000, 'Direct mapping: MO -> MIN_MO', '2025-11-19 17:33:13.537167');
INSERT INTO public.mineralnutrient VALUES (44, 14, 37, 0.000, 1.000000, 'Direct mapping: F -> MIN_F', '2025-11-19 17:33:13.537977');


--
-- TOC entry 6434 (class 0 OID 21562)
-- Dependencies: 259
-- Data for Name: mineralrda; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.mineralrda VALUES (1, 1, NULL, 0, 0, 200.000, 'mg', 'AI for infants 0-6 months');
INSERT INTO public.mineralrda VALUES (2, 1, NULL, 1, 1, 260.000, 'mg', 'AI for infants 7-12 months');
INSERT INTO public.mineralrda VALUES (3, 1, NULL, 1, 3, 700.000, 'mg', 'RDA for children 1-3 years');
INSERT INTO public.mineralrda VALUES (4, 1, NULL, 4, 8, 1000.000, 'mg', 'RDA for children 4-8 years');
INSERT INTO public.mineralrda VALUES (5, 1, NULL, 9, 18, 1300.000, 'mg', 'RDA for adolescents (peak bone growth)');
INSERT INTO public.mineralrda VALUES (6, 1, NULL, 19, 50, 1000.000, 'mg', 'RDA for adults 19-50');
INSERT INTO public.mineralrda VALUES (7, 1, 'male', 51, 70, 1000.000, 'mg', 'RDA for males 51-70');
INSERT INTO public.mineralrda VALUES (8, 1, 'female', 51, 120, 1200.000, 'mg', 'RDA for females 51+ (postmenopausal)');
INSERT INTO public.mineralrda VALUES (9, 1, 'male', 71, 120, 1200.000, 'mg', 'RDA for males 71+');
INSERT INTO public.mineralrda VALUES (10, 6, NULL, 0, 0, 0.270, 'mg', 'AI for infants 0-6 months');
INSERT INTO public.mineralrda VALUES (11, 6, NULL, 1, 1, 11.000, 'mg', 'RDA for infants 7-12 months');
INSERT INTO public.mineralrda VALUES (12, 6, NULL, 1, 3, 7.000, 'mg', 'RDA for children 1-3 years');
INSERT INTO public.mineralrda VALUES (13, 6, NULL, 4, 8, 10.000, 'mg', 'RDA for children 4-8 years');
INSERT INTO public.mineralrda VALUES (14, 6, NULL, 9, 13, 8.000, 'mg', 'RDA for children 9-13 years');
INSERT INTO public.mineralrda VALUES (15, 6, 'male', 14, 18, 11.000, 'mg', 'RDA for males 14-18 years');
INSERT INTO public.mineralrda VALUES (16, 6, 'male', 19, 120, 8.000, 'mg', 'RDA for adult males');
INSERT INTO public.mineralrda VALUES (17, 6, 'female', 14, 18, 15.000, 'mg', 'RDA for females 14-18 years (menstruating)');
INSERT INTO public.mineralrda VALUES (18, 6, 'female', 19, 50, 18.000, 'mg', 'RDA for females 19-50 (menstruating)');
INSERT INTO public.mineralrda VALUES (19, 6, 'female', 51, 120, 8.000, 'mg', 'RDA for postmenopausal females');
INSERT INTO public.mineralrda VALUES (20, 3, 'male', 19, 30, 400.000, 'mg', 'RDA for males 19-30');
INSERT INTO public.mineralrda VALUES (21, 3, 'male', 31, 120, 420.000, 'mg', 'RDA for males 31+');
INSERT INTO public.mineralrda VALUES (22, 3, 'female', 19, 30, 310.000, 'mg', 'RDA for females 19-30');
INSERT INTO public.mineralrda VALUES (23, 3, 'female', 31, 120, 320.000, 'mg', 'RDA for females 31+');
INSERT INTO public.mineralrda VALUES (24, 7, 'male', 19, 120, 11.000, 'mg', 'RDA for adult males');
INSERT INTO public.mineralrda VALUES (25, 7, 'female', 19, 120, 8.000, 'mg', 'RDA for adult females');
INSERT INTO public.mineralrda VALUES (26, 4, 'male', 19, 120, 3400.000, 'mg', 'AI for adult males');
INSERT INTO public.mineralrda VALUES (27, 4, 'female', 19, 120, 2600.000, 'mg', 'AI for adult females');
INSERT INTO public.mineralrda VALUES (28, 5, NULL, 19, 50, 1500.000, 'mg', 'AI for adults 19-50');
INSERT INTO public.mineralrda VALUES (29, 5, NULL, 51, 70, 1300.000, 'mg', 'AI for adults 51-70');
INSERT INTO public.mineralrda VALUES (30, 5, NULL, 71, 120, 1200.000, 'mg', 'AI for adults 71+');
INSERT INTO public.mineralrda VALUES (31, 11, NULL, 19, 120, 55.000, 'µg', 'RDA for adults');
INSERT INTO public.mineralrda VALUES (32, 10, NULL, 19, 120, 150.000, 'µg', 'RDA for adults');
INSERT INTO public.mineralrda VALUES (33, 2, NULL, 19, 70, 700.000, 'mg', 'RDA for adults');
INSERT INTO public.mineralrda VALUES (34, 8, NULL, 19, 120, 900.000, 'µg', 'RDA for adults');
INSERT INTO public.mineralrda VALUES (35, 9, 'male', 19, 120, 2.300, 'mg', 'AI for adult males');
INSERT INTO public.mineralrda VALUES (36, 9, 'female', 19, 120, 1.800, 'mg', 'AI for adult females');
INSERT INTO public.mineralrda VALUES (73, 1, 'any', 19, 50, 1000.000, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (74, 2, 'any', 19, 50, 700.000, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (75, 3, 'any', 19, 50, 310.000, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (76, 4, 'any', 19, 50, 4700.000, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (77, 5, 'any', 19, 50, 1500.000, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (78, 6, 'any', 19, 50, 18.000, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (79, 7, 'any', 19, 50, 11.000, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (80, 8, 'any', 19, 50, 0.900, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (81, 9, 'any', 19, 50, 2.300, 'mg', NULL);
INSERT INTO public.mineralrda VALUES (82, 10, 'any', 19, 50, 150.000, 'µg', NULL);
INSERT INTO public.mineralrda VALUES (83, 11, 'any', 19, 50, 55.000, 'µg', NULL);
INSERT INTO public.mineralrda VALUES (84, 12, 'any', 19, 50, 35.000, 'µg', NULL);
INSERT INTO public.mineralrda VALUES (85, 13, 'any', 19, 50, 45.000, 'µg', NULL);
INSERT INTO public.mineralrda VALUES (86, 14, 'any', 19, 50, 3.000, 'mg', NULL);


--
-- TOC entry 6408 (class 0 OID 21220)
-- Dependencies: 233
-- Data for Name: nutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.nutrient VALUES (1, 'Energy (Calories)', 'ENERC_KCAL', 'kcal', '2025-11-19 06:57:43.015764', NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (2, 'Protein', 'PROCNT', 'g', '2025-11-19 06:57:43.015764', NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (4, 'Carbohydrate, by difference', 'CHOCDF', 'g', '2025-11-19 06:57:43.015764', NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (72, 'ALA (Alpha-Linolenic Acid)', 'ALA', 'g', '2025-11-19 07:14:21.419945', NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (75, 'EPA + DHA Combined', 'EPA_DHA', 'g', '2025-11-19 07:14:21.419945', NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (76, 'LA (Linoleic Acid)', 'LA', 'g', '2025-11-19 07:14:21.419945', NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (11, 'Vitamin A', 'VITA', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (12, 'Vitamin D', 'VITD', 'IU', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (13, 'Vitamin E', 'VITE', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (14, 'Vitamin K', 'VITK', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (15, 'Vitamin C', 'VITC', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (16, 'Vitamin B1 (Thiamine)', 'VITB1', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (17, 'Vitamin B2 (Riboflavin)', 'VITB2', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (18, 'Vitamin B3 (Niacin)', 'VITB3', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (19, 'Vitamin B5 (Pantothenic acid)', 'VITB5', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (20, 'Vitamin B6 (Pyridoxine)', 'VITB6', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (21, 'Vitamin B7 (Biotin)', 'VITB7', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (22, 'Vitamin B9 (Folate)', 'VITB9', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (23, 'Vitamin B12 (Cobalamin)', 'VITB12', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Vitamins', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (24, 'Calcium (Ca)', 'CA', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (25, 'Phosphorus (P)', 'P', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (26, 'Magnesium (Mg)', 'MG', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (27, 'Potassium (K)', 'K', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (28, 'Sodium (Na)', 'NA', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (29, 'Iron (Fe)', 'FE', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (30, 'Zinc (Zn)', 'ZN', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (31, 'Copper (Cu)', 'CU', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (32, 'Manganese (Mn)', 'MN', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (33, 'Iodine (I)', 'I', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (34, 'Selenium (Se)', 'SE', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (35, 'Chromium (Cr)', 'CR', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (36, 'Molybdenum (Mo)', 'MO', 'µg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (37, 'Fluoride (F)', 'F', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Minerals', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (5, 'Dietary Fiber (total)', 'FIBTG', 'g', '2025-11-19 06:57:43.015764', NULL, 'Dietary Fiber', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (6, 'Soluble Fiber', 'FIB_SOL', 'g', '2025-11-19 06:57:43.015764', NULL, 'Dietary Fiber', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (7, 'Insoluble Fiber', 'FIB_INSOL', 'g', '2025-11-19 06:57:43.015764', NULL, 'Dietary Fiber', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (8, 'Resistant Starch', 'FIB_RS', 'g', '2025-11-19 06:57:43.015764', NULL, 'Dietary Fiber', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (9, 'Beta-Glucan', 'FIB_BGLU', 'g', '2025-11-19 06:57:43.015764', NULL, 'Dietary Fiber', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (3, 'Total Fat', 'FAT', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (10, 'Cholesterol', 'CHOLESTEROL', 'mg', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (38, 'Monounsaturated Fat (MUFA)', 'FAMS', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (39, 'Polyunsaturated Fat (PUFA)', 'FAPU', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (40, 'Saturated Fat (SFA)', 'FASAT', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (41, 'Trans Fat (total)', 'FATRN', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (42, 'EPA (Eicosapentaenoic acid)', 'FAEPA', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (43, 'DHA (Docosahexaenoic acid)', 'FADHA', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (44, 'EPA + DHA (combined)', 'FAEPA_DHA', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (45, 'Linoleic acid (LA) 18:2 n-6', 'FA18_2N6C', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (46, 'Alpha-linolenic acid (ALA) 18:3 n-3', 'FA18_3N3', 'g', '2025-11-19 06:57:43.015764', NULL, 'Fat / Fatty acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (47, 'Histidine', 'AMINO_HIS', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (48, 'Isoleucine', 'AMINO_ILE', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (49, 'Leucine', 'AMINO_LEU', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (50, 'Lysine', 'AMINO_LYS', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (51, 'Methionine', 'AMINO_MET', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (52, 'Phenylalanine', 'AMINO_PHE', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (53, 'Threonine', 'AMINO_THR', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (54, 'Tryptophan', 'AMINO_TRP', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);
INSERT INTO public.nutrient VALUES (55, 'Valine', 'AMINO_VAL', 'g', '2025-11-19 06:57:43.015764', NULL, 'Amino acids', NULL, NULL, NULL);


--
-- TOC entry 6466 (class 0 OID 21945)
-- Dependencies: 291
-- Data for Name: nutrientcontraindication; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6451 (class 0 OID 21758)
-- Dependencies: 276
-- Data for Name: nutrientmapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.nutrientmapping VALUES (1, 5, 6, NULL, 1.000000, 'USDA FIBTG -> TOTAL_FIBER');
INSERT INTO public.nutrientmapping VALUES (2, 3, NULL, 7, 1.000000, 'FAT -> TOTAL_FAT');
INSERT INTO public.nutrientmapping VALUES (3, 38, NULL, 17, 1.000000, 'FAMS -> MUFA');
INSERT INTO public.nutrientmapping VALUES (4, 39, NULL, 15, 1.000000, 'FAPU -> PUFA');
INSERT INTO public.nutrientmapping VALUES (5, 42, NULL, 4, 1000.000000, 'FAEPA (g->mg) -> EPA_DHA');
INSERT INTO public.nutrientmapping VALUES (6, 43, NULL, 4, 1000.000000, 'FADHA (g->mg) -> EPA_DHA');
INSERT INTO public.nutrientmapping VALUES (7, 45, NULL, 15, 1.000000, 'FA18_2N6C -> PUFA (LA)');
INSERT INTO public.nutrientmapping VALUES (8, 46, NULL, 15, 1.000000, 'FA18_3N3 -> PUFA (ALA)');
INSERT INTO public.nutrientmapping VALUES (9, 6, 6, NULL, 1.000000, 'name contains fiber -> TOTAL_FIBER');
INSERT INTO public.nutrientmapping VALUES (10, 7, 6, NULL, 1.000000, 'name contains fiber -> TOTAL_FIBER');


--
-- TOC entry 6482 (class 0 OID 22141)
-- Dependencies: 309
-- Data for Name: nutritionanalysis; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6511 (class 0 OID 22581)
-- Dependencies: 342
-- Data for Name: passwordchangecode; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6534 (class 0 OID 23082)
-- Dependencies: 369
-- Data for Name: permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.permission VALUES (1, 'users.create', 'Tạo người dùng mới', 'users', 'create', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (2, 'users.read', 'Xem danh sách người dùng', 'users', 'read', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (3, 'users.update', 'Cập nhật thông tin người dùng', 'users', 'update', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (4, 'users.delete', 'Xóa người dùng', 'users', 'delete', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (5, 'users.manage', 'Quản lý toàn bộ người dùng', 'users', 'manage', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (6, 'foods.create', 'Thêm thực phẩm mới', 'foods', 'create', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (7, 'foods.read', 'Xem danh sách thực phẩm', 'foods', 'read', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (8, 'foods.update', 'Cập nhật thông tin thực phẩm', 'foods', 'update', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (9, 'foods.delete', 'Xóa thực phẩm', 'foods', 'delete', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (10, 'foods.manage', 'Quản lý toàn bộ thực phẩm', 'foods', 'manage', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (11, 'dishes.create', 'Tạo món ăn mới', 'dishes', 'create', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (12, 'dishes.read', 'Xem danh sách món ăn', 'dishes', 'read', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (13, 'dishes.update', 'Cập nhật thông tin món ăn', 'dishes', 'update', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (14, 'dishes.delete', 'Xóa món ăn', 'dishes', 'delete', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (15, 'dishes.manage', 'Quản lý toàn bộ món ăn', 'dishes', 'manage', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (16, 'dishes.approve', 'Phê duyệt món ăn từ user', 'dishes', 'approve', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (17, 'analytics.view', 'Xem báo cáo thống kê', 'analytics', 'read', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (18, 'analytics.export', 'Xuất báo cáo', 'analytics', 'export', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (19, 'logs.view', 'Xem nhật ký hoạt động', 'logs', 'read', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (20, 'logs.delete', 'Xóa nhật ký', 'logs', 'delete', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (21, 'roles.create', 'Tạo vai trò mới', 'roles', 'create', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (22, 'roles.update', 'Cập nhật vai trò', 'roles', 'update', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (23, 'roles.delete', 'Xóa vai trò', 'roles', 'delete', '2025-11-19 16:33:58.306697');
INSERT INTO public.permission VALUES (24, 'roles.assign', 'Gán vai trò cho admin', 'roles', 'assign', '2025-11-19 16:33:58.306697');


--
-- TOC entry 6500 (class 0 OID 22400)
-- Dependencies: 329
-- Data for Name: portionsize; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.portionsize VALUES (101, 3011, '1 large bowl', '1 tô to', 800.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (102, 3011, '1 medium bowl', '1 tô vừa', 700.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (103, 3012, '1 large plate', '1 dĩa to', 550.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (104, 3013, '1 medium plate', '1 dĩa vừa', 400.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (105, 3013, '1 small plate', '1 dĩa nhỏ', 300.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (106, 3014, '1 full sandwich', '1 ổ đầy đủ', 200.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (107, 3014, 'Half sandwich', 'Nửa ổ', 100.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (108, 3015, '3 rolls', '3 cuốn', 300.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (109, 3015, '2 rolls', '2 cuốn', 200.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (110, 3016, '1 large bowl soup', '1 tô canh to', 450.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (111, 3016, '1 medium bowl soup', '1 tô canh vừa', 350.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (112, 3017, '1 large plate', '1 dĩa to', 250.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (113, 3018, '1 piece fish', '1 miếng cá', 150.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (114, 3018, '1 small piece', '1 miếng nhỏ', 100.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (115, 3019, '2 pieces', '2 miếng', 200.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (116, 3020, '1 large plate', '1 dĩa to', 300.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (117, 3004, '2 bananas', '2 quả chuối', 240.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (118, 3007, '1 large fillet', '1 phi lê to', 200.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (119, 3009, '1 large cup', '1 chén to', 150.00, true, '2025-12-01 00:23:21.543354');
INSERT INTO public.portionsize VALUES (120, 3010, '1 large glass', '1 ly to', 300.00, true, '2025-12-01 00:23:21.543354');


--
-- TOC entry 6566 (class 0 OID 24555)
-- Dependencies: 402
-- Data for Name: privateconversation; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.privateconversation VALUES (1, 1, 2, '2025-11-24 05:13:47.156117', '2025-11-25 00:43:15.048766');
INSERT INTO public.privateconversation VALUES (2, 1, 3, '2025-11-24 06:49:29.098687', '2025-11-26 16:57:18.025524');
INSERT INTO public.privateconversation VALUES (3, 2, 3, '2025-12-02 01:36:43.697705', '2025-12-02 01:36:43.697705');


--
-- TOC entry 6568 (class 0 OID 24582)
-- Dependencies: 404
-- Data for Name: privatemessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.privatemessage VALUES (1, 1, 1, '123', NULL, true, '2025-11-25 00:36:59.726476', '2025-11-25 00:36:29.885888');
INSERT INTO public.privatemessage VALUES (2, 1, 2, '456', NULL, false, NULL, '2025-11-25 00:43:15.048766');
INSERT INTO public.privatemessage VALUES (3, 2, 3, '123', NULL, true, '2025-11-26 16:57:12.957054', '2025-11-26 16:55:50.004164');
INSERT INTO public.privatemessage VALUES (4, 2, 1, '456', NULL, false, NULL, '2025-11-26 16:57:18.025524');


--
-- TOC entry 6502 (class 0 OID 22418)
-- Dependencies: 331
-- Data for Name: recipe; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe VALUES (1, NULL, 'Phở Bò Hà Nội', 'Công thức nấu phở bò truyền thống Hà Nội', 4, 30, 180, 'Bước 1: Hầm xương bò 3-4 tiếng với hành, gừng nướng
Bước 2: Thêm gia vị: muối, đường, nước mắm, hạt nêm
Bước 3: Trụng bánh phở, cho vào tô
Bước 4: Thái thịt bò mỏng, xếp lên bánh phở
Bước 5: Chan nước dùng sôi, thêm hành, ngò rí, rau thơm
Bước 6: Ăn kèm chanh, ớt, tương ớt', NULL, true, '2025-12-01 00:23:21.519417', '2025-12-01 00:23:21.519417');
INSERT INTO public.recipe VALUES (2, NULL, 'Cơm Tấm Sườn Nướng', 'Cơm tấm sườn nướng sả ớt', 2, 20, 30, 'Bước 1: Ướp sườn heo với sả, tỏi, đường, nước mắm, dầu ăn 2 tiếng
Bước 2: Nướng sườn trên than hồng hoặc lò nướng
Bước 3: Nấu cơm tấm
Bước 4: Chiên trứng ốp la
Bước 5: Pha nước mắm chua ngọt
Bước 6: Bày cơm, sườn, trứng, dưa leo, cà chua', NULL, true, '2025-12-01 00:23:21.519417', '2025-12-01 00:23:21.519417');
INSERT INTO public.recipe VALUES (3, NULL, 'Canh Chua Cá', 'Canh chua cá lóc miền Nam', 4, 15, 25, 'Bước 1: Rửa sạch cá, cắt khúc vừa ăn
Bước 2: Nấu nước dùng với me, thơm, cà chua
Bước 3: Cho cá vào, nấu chín
Bước 4: Thêm đậu bắp, rau muống
Bước 5: Nêm nếm vừa ăn với muối, đường, nước mắm
Bước 6: Rắc hành, ngò, ớt', NULL, true, '2025-12-01 00:23:21.519417', '2025-12-01 00:23:21.519417');
INSERT INTO public.recipe VALUES (4, NULL, 'Gỏi Cuốn Tôm Thịt', 'Gỏi cuốn tươi mát', 10, 30, 15, 'Bước 1: Luộc tôm, thịt heo
Bước 2: Thái rau sống: xà lách, húng, rau thơm
Bước 3: Trụng bánh tráng qua nước ấm
Bước 4: Cuốn tôm, thịt, bún, rau vào bánh tráng
Bước 5: Pha nước chấm: nước mắm, đường, tỏi, ớt
Bước 6: Ăn ngay khi mới cuốn', NULL, true, '2025-12-01 00:23:21.519417', '2025-12-01 00:23:21.519417');
INSERT INTO public.recipe VALUES (5, NULL, 'Cháo Gà Dinh Dưỡng', 'Cháo gà cho người ốm', 2, 10, 40, 'Bước 1: Vo gạo, ngâm 30 phút
Bước 2: Luộc gà với gừng
Bước 3: Xé gà thành sợi
Bước 4: Nấu cháo với nước luộc gà
Bước 5: Nêm nếm vừa ăn
Bước 6: Cho gà xé vào, rắc hành, gừng', NULL, true, '2025-12-01 00:23:21.519417', '2025-12-01 00:23:21.519417');
INSERT INTO public.recipe VALUES (21, NULL, 'Bún Chả Hà Nội', 'Bún chả truyền thống Hà Nội', 4, 30, 25, 'Bước 1: Ướp thịt heo với nước mắm, đường, hành băm, ớt băm trong 2 tiếng
Bước 2: Vo viên chả, nướng chả và thịt trên bếp than hồng
Bước 3: Pha nước mắm chua ngọt với chanh, đường, tỏi, ớt
Bước 4: Trụng bún tươi
Bước 5: Trình bày bún, rau sống, chả và thịt nướng riêng
Bước 6: Chan nước mắm pha vào ăn kèm', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (22, NULL, 'Cà Ri Gà', 'Cà ri gà kiểu Việt Nam', 3, 25, 45, 'Bước 1: Sơ chế gà, thái miếng vừa ăn
Bước 2: Phi thơm hành tím, tỏi với bột cà ri
Bước 3: Cho gà vào xào săn, thêm khoai tây, cà rốt
Bước 4: Đổ nước dừa hoặc nước lọc, nêm nếm
Bước 5: Nấu nhỏ lửa 30-40 phút đến khi gà và rau mềm
Bước 6: Ăn kèm cơm hoặc bánh mì', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (23, NULL, 'Gỏi Gà', 'Gỏi gà bắp cải tím', 4, 35, 20, 'Bước 1: Luộc gà chín, xé sợi
Bước 2: Thái mỏng bắp cải tím, cà rốt, ngâm nước đá
Bước 3: Rang đậu phộng, giã nhỏ
Bước 4: Trộn rau với rau răm, hành tây, gà xé
Bước 5: Pha nước mắm chanh đường
Bước 6: Trộn đều, rắc đậu phộng và hành phi lên trên', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (24, NULL, 'Canh Chua Cá', 'Canh chua cá miền Nam', 4, 20, 25, 'Bước 1: Sơ chế cá, ướp muối tiêu gừng
Bước 2: Nấu nước dùng với me, thơm, cà chua
Bước 3: Nêm nếm chua ngọt vừa ăn
Bước 4: Cho cá vào nấu chín
Bước 5: Thêm rau muống, đậu bắp, hành
Bước 6: Tắt bếp, rắc ngò rí', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (25, NULL, 'Bánh Xèo', 'Bánh xèo giòn miền Nam', 6, 40, 30, 'Bước 1: Pha bột bánh xèo với bột gạo, bột nghệ, nước cốt dừa
Bước 2: Ướp tôm, thịt với gia vị
Bước 3: Chiên bánh trên chảo nóng với dầu nhiều
Bước 4: Cho nhân tôm, thịt, giá đỗ vào rồi gấp đôi
Bước 5: Chiên đến khi vàng giòn 2 mặt
Bước 6: Ăn kèm rau sống, nước mắm pha', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (26, NULL, 'Thịt Kho Tàu', 'Thịt kho trứng cút', 4, 20, 60, 'Bước 1: Luộc sơ thịt ba chỉ, thái miếng vuông
Bước 2: Luộc chín trứng cút, bóc vỏ
Bước 3: Làm nước màu caramel
Bước 4: Cho thịt vào kho với nước dừa, nước mắm, đường
Bước 5: Thêm trứng vào kho cùng
Bước 6: Nấu lửa nhỏ 45-60 phút đến khi thịt mềm, nước sệt', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (27, NULL, 'Chả Giò', 'Chả giò miền Nam giòn rụm', 20, 45, 25, 'Bước 1: Làm nhân với thịt heo xay, tôm, mộc nhĩ, miến, rau củ
Bước 2: Nêm nếm nhân vừa ăn
Bước 3: Cuốn nhân vào bánh tráng, cuốn chặt
Bước 4: Chiên ngập dầu lửa vừa đến vàng đều
Bước 5: Vớt ra để ráo dầu
Bước 6: Ăn kèm rau sống, bún, nước mắm pha', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (28, NULL, 'Bò Lúc Lắc', 'Bò lúc lắc sốt tiêu đen', 2, 20, 10, 'Bước 1: Thịt bò thái hạt lựu, ướp tiêu, tỏi, nước mắm, dầu
Bước 2: Chuẩn bị salad rau trộn
Bước 3: Xào bò nhanh tay trên lửa lớn
Bước 4: Nêm thêm tiêu đen, bơ
Bước 5: Lắc đều để thịt chín vừa, mềm
Bước 6: Ăn kèm salad, cơm hoặc bánh mì', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (29, NULL, 'Gà Kho Gừng', 'Gà kho gừng ấm bụng', 4, 25, 50, 'Bước 1: Gà thái miếng, ướp với gừng, tỏi, nước mắm
Bước 2: Phi thơm gừng tỏi
Bước 3: Cho gà vào kho với nước mắm, đường, ớt
Bước 4: Nấu lửa vừa 40-50 phút
Bước 5: Nêm nếm lại, thu nhỏ lửa cho nước sệt
Bước 6: Rắc hành lá, tiêu', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (30, NULL, 'Cháo Gà', 'Cháo gà dinh dưỡng dễ tiêu', 4, 15, 40, 'Bước 1: Vo gạo, ngâm 30 phút
Bước 2: Luộc gà với gừng, đổ bỏ nước đầu
Bước 3: Luộc lại gà đến chín, vớt ra xé sợi
Bước 4: Nấu cháo với nước luộc gà
Bước 5: Khi cháo nhừ, nêm nếm vừa ăn
Bước 6: Múc cháo ra tô, cho gà xé, rắc hành, ngò, gừng', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (31, NULL, 'Bún Bò Huế', 'Bún bò Huế cay nồng', 4, 30, 120, 'Bước 1: Ninh xương bò 2-3 tiếng
Bước 2: Luộc chả, giò heo
Bước 3: Rang sả với mắm tôm, ớt, thêm vào nước dùng
Bước 4: Nêm nếm cay mặn vừa ăn
Bước 5: Trụng bún bò
Bước 6: Cho bún vào tô, xếp chả giò, chan nước dùng, thêm rau', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (32, NULL, 'Bánh Cuốn', 'Bánh cuốn Thanh Trì', 6, 45, 30, 'Bước 1: Pha bột bánh cuốn mỏng
Bước 2: Làm nhân thịt xay, mộc nhĩ xào
Bước 3: Hấp bánh mỏng trên vải
Bước 4: Phết nhân lên bánh, cuộn lại
Bước 5: Xếp bánh ra đĩa
Bước 6: Ăn kèm chả, nước mắm, hành phi', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (33, NULL, 'Mì Quảng', 'Mì Quảng Đà Nẵng', 4, 35, 45, 'Bước 1: Nấu nước dùng từ xương, thêm nghệ
Bước 2: Ướp tôm, thịt nướng
Bước 3: Luộc mì vàng
Bước 4: Rang đậu phộng giã nhỏ
Bước 5: Trình bày mì, tôm thịt, rau sống, trứng
Bước 6: Chan nước dùng vừa đủ, rắc đậu phộng, hành', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (34, NULL, 'Bò Kho', 'Bò kho kiểu miền Nam', 4, 25, 90, 'Bước 1: Bò thái to, ướp với gia vị, sả
Bước 2: Làm nước màu
Bước 3: Kho bò với nước dừa, cà rốt
Bước 4: Nấu lửa nhỏ 60-90 phút
Bước 5: Nêm nếm, thêm sả ớt
Bước 6: Ăn kèm bánh mì hoặc bún', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (35, NULL, 'Canh Khổ Qua', 'Canh khổ qua nhồi thịt', 4, 30, 25, 'Bước 1: Khổ qua bỏ ruột, ngâm nước muối
Bước 2: Làm nhân thịt xay với miến
Bước 3: Nhồi nhân vào khổ qua
Bước 4: Nấu nước dùng từ xương
Bước 5: Cho khổ qua vào nấu chín
Bước 6: Nêm nếm, rắc hành', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (36, NULL, 'Gà Xào Sả Ớt', 'Gà xào sả ớt thơm cay', 3, 20, 15, 'Bước 1: Gà thái miếng, ướp sả ớt tỏi
Bước 2: Phi thơm sả ớt
Bước 3: Cho gà vào xào săn
Bước 4: Nêm nước mắm, đường
Bước 5: Xào đến khi gà chín vàng
Bước 6: Rắc hành lá, tắt bếp', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (37, NULL, 'Rau Muống Xào Tỏi', 'Rau muống xào tỏi giòn ngon', 2, 5, 5, 'Bước 1: Nhặt rau muống sạch, tách ngọn
Bước 2: Đập dập tỏi
Bước 3: Phi thơm tỏi
Bước 4: Cho rau vào xào nhanh tay lửa to
Bước 5: Nêm muối hoặc nước mắm
Bước 6: Đảo đều, tắt bếp khi rau còn xanh giòn', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (38, NULL, 'Đậu Hũ Sốt Cà Chua', 'Đậu hũ chiên sốt cà', 3, 15, 20, 'Bước 1: Đậu hũ cắt miếng, chiên vàng
Bước 2: Phi hành tỏi
Bước 3: Xào cà chua với gia vị
Bước 4: Nêm chua ngọt vừa ăn
Bước 5: Cho đậu hũ vào đảo đều
Bước 6: Rắc hành lá, tắt bếp', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (39, NULL, 'Canh Sườn Hầm', 'Canh sườn củ cải ngọt', 4, 20, 90, 'Bước 1: Sườn chặt khúc, chần sơ
Bước 2: Ninh sườn với nước 60 phút
Bước 3: Thêm củ cải, cà rốt thái to
Bước 4: Nấu thêm 30 phút
Bước 5: Nêm muối vừa ăn
Bước 6: Rắc hành, ngò', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');
INSERT INTO public.recipe VALUES (40, NULL, 'Xôi Xéo', 'Xôi xéo đậu xanh', 4, 15, 40, 'Bước 1: Ngâm gạo nếp 4 tiếng
Bước 2: Vo đậu xanh, hấp chín
Bước 3: Rang đậu xanh với muối
Bước 4: Hấp xôi với lá dứa
Bước 5: Trộn xôi với đậu xanh
Bước 6: Ăn kèm mỡ hành, thịt nạc dăm', NULL, true, '2025-12-01 00:23:21.55821', '2025-12-01 00:23:21.55821');


--
-- TOC entry 6504 (class 0 OID 22438)
-- Dependencies: 333
-- Data for Name: recipeingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipeingredient VALUES (17, 21, 3012, 400.00, 1, 'Bún tươi');
INSERT INTO public.recipeingredient VALUES (18, 21, 3019, 300.00, 2, 'Thịt heo nướng, chả');
INSERT INTO public.recipeingredient VALUES (19, 21, 3017, 200.00, 3, 'Rau sống');
INSERT INTO public.recipeingredient VALUES (20, 22, 3007, 400.00, 1, 'Gà');
INSERT INTO public.recipeingredient VALUES (21, 22, 3004, 200.00, 2, 'Khoai tây');
INSERT INTO public.recipeingredient VALUES (22, 22, 3017, 100.00, 3, 'Cà rốt, hành');
INSERT INTO public.recipeingredient VALUES (23, 23, 3007, 300.00, 1, 'Gà luộc xé');
INSERT INTO public.recipeingredient VALUES (24, 23, 3017, 400.00, 2, 'Bắp cải, cà rốt, rau thơm');
INSERT INTO public.recipeingredient VALUES (25, 24, 3018, 400.00, 1, 'Cá');
INSERT INTO public.recipeingredient VALUES (26, 24, 3016, 200.00, 2, 'Cà chua, thơm');
INSERT INTO public.recipeingredient VALUES (27, 24, 3017, 150.00, 3, 'Rau muống, đậu bắp');
INSERT INTO public.recipeingredient VALUES (28, 25, 3014, 300.00, 1, 'Bột bánh xèo');
INSERT INTO public.recipeingredient VALUES (29, 25, 3019, 200.00, 2, 'Thịt heo, tôm');
INSERT INTO public.recipeingredient VALUES (30, 25, 90, 150.00, 3, 'Giá đỗ');


--
-- TOC entry 6403 (class 0 OID 21175)
-- Dependencies: 228
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.role VALUES (1, 'super_admin');
INSERT INTO public.role VALUES (2, 'user_manager');
INSERT INTO public.role VALUES (3, 'content_manager');
INSERT INTO public.role VALUES (6, 'analytics_manager');
INSERT INTO public.role VALUES (7, 'support manager');


--
-- TOC entry 6536 (class 0 OID 23098)
-- Dependencies: 371
-- Data for Name: rolepermission; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rolepermission VALUES (1, 'super_admin', 1, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (2, 'super_admin', 2, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (3, 'super_admin', 3, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (4, 'super_admin', 4, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (5, 'super_admin', 5, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (6, 'super_admin', 6, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (7, 'super_admin', 7, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (8, 'super_admin', 8, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (9, 'super_admin', 9, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (10, 'super_admin', 10, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (11, 'super_admin', 11, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (12, 'super_admin', 12, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (13, 'super_admin', 13, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (14, 'super_admin', 14, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (15, 'super_admin', 15, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (16, 'super_admin', 16, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (17, 'super_admin', 17, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (18, 'super_admin', 18, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (19, 'super_admin', 19, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (20, 'super_admin', 20, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (21, 'super_admin', 21, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (22, 'super_admin', 22, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (23, 'super_admin', 23, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (24, 'super_admin', 24, '2025-11-19 16:35:17.458479');
INSERT INTO public.rolepermission VALUES (25, 'content_manager', 6, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (26, 'content_manager', 7, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (27, 'content_manager', 8, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (28, 'content_manager', 9, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (29, 'content_manager', 10, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (30, 'content_manager', 11, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (31, 'content_manager', 12, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (32, 'content_manager', 13, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (33, 'content_manager', 14, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (34, 'content_manager', 15, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (35, 'content_manager', 16, '2025-11-19 16:35:20.871476');
INSERT INTO public.rolepermission VALUES (39, 'user_manager', 1, '2025-11-19 16:35:40.061795');
INSERT INTO public.rolepermission VALUES (40, 'user_manager', 2, '2025-11-19 16:35:40.061795');
INSERT INTO public.rolepermission VALUES (41, 'user_manager', 3, '2025-11-19 16:35:40.061795');
INSERT INTO public.rolepermission VALUES (42, 'user_manager', 4, '2025-11-19 16:35:40.061795');
INSERT INTO public.rolepermission VALUES (43, 'user_manager', 5, '2025-11-19 16:35:40.061795');
INSERT INTO public.rolepermission VALUES (68, 'analytics_manager', 17, '2025-11-19 16:44:59.417767');
INSERT INTO public.rolepermission VALUES (69, 'analytics_manager', 18, '2025-11-19 16:44:59.417767');
INSERT INTO public.rolepermission VALUES (70, 'analytics_manager', 19, '2025-11-19 16:44:59.417767');


--
-- TOC entry 6423 (class 0 OID 21353)
-- Dependencies: 248
-- Data for Name: suggestion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6512 (class 0 OID 22602)
-- Dependencies: 343
-- Data for Name: user_account_status; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6514 (class 0 OID 22625)
-- Dependencies: 345
-- Data for Name: user_block_event; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6464 (class 0 OID 21912)
-- Dependencies: 289
-- Data for Name: user_meal_summaries; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_meal_summaries VALUES (1, 1, '2025-11-21', 'dinner', 1500.00, 120.00, 90.00, 60.00, '2025-11-20 17:58:12.16041-08');
INSERT INTO public.user_meal_summaries VALUES (2, 1, '2025-11-21', 'breakfast', 78.90, 14.60, 7.40, 0.42, '2025-11-20 17:59:45.103949-08');
INSERT INTO public.user_meal_summaries VALUES (6, 1, '2025-11-23', 'lunch', 1500.00, 120.00, 90.00, 60.00, '2025-11-22 22:20:56.760024-08');
INSERT INTO public.user_meal_summaries VALUES (7, 1, '2025-11-23', 'snack', 3093.00, 250.70, 192.10, 120.50, '2025-11-23 01:26:02.838469-08');
INSERT INTO public.user_meal_summaries VALUES (11, 1, '2025-11-24', 'breakfast', 4000.00, 1240.00, 1180.00, 1120.00, '2025-11-23 19:37:18.223167-08');
INSERT INTO public.user_meal_summaries VALUES (14, 3, '2025-11-27', 'dinner', 1000.00, 1000.00, 1000.00, 1000.00, '2025-11-27 05:51:50.476636-08');
INSERT INTO public.user_meal_summaries VALUES (15, 3, '2025-11-29', 'snack', 1000.00, 1000.00, 1000.00, 1000.00, '2025-11-29 01:34:58.874873-08');


--
-- TOC entry 6460 (class 0 OID 21866)
-- Dependencies: 285
-- Data for Name: user_meal_targets; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6516 (class 0 OID 22650)
-- Dependencies: 347
-- Data for Name: user_unblock_request; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6399 (class 0 OID 21144)
-- Dependencies: 224
-- Data for Name: useractivitylog; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.useractivitylog VALUES (1, 1, 'bmr_tdee_recomputed', '2025-11-19 07:19:57.587871');
INSERT INTO public.useractivitylog VALUES (2, 1, 'daily_targets_recomputed', '2025-11-19 07:19:59.88821');
INSERT INTO public.useractivitylog VALUES (3, 1, 'meal_entry_created', '2025-11-23 19:37:18.223167');
INSERT INTO public.useractivitylog VALUES (4, 2, 'body_measurement_recorded', '2025-11-23 20:44:04.627771');
INSERT INTO public.useractivitylog VALUES (5, 2, 'bmr_tdee_recomputed', '2025-11-23 20:44:04.64067');
INSERT INTO public.useractivitylog VALUES (6, 2, 'daily_targets_recomputed', '2025-11-23 20:44:07.120791');
INSERT INTO public.useractivitylog VALUES (7, 3, 'body_measurement_recorded', '2025-11-24 05:24:39.709436');
INSERT INTO public.useractivitylog VALUES (8, 3, 'bmr_tdee_recomputed', '2025-11-24 05:24:39.721753');
INSERT INTO public.useractivitylog VALUES (9, 3, 'daily_targets_recomputed', '2025-11-24 05:24:49.524601');
INSERT INTO public.useractivitylog VALUES (10, 3, 'health_condition_added', '2025-11-24 06:27:45.049044');
INSERT INTO public.useractivitylog VALUES (11, 1, 'body_measurement_recorded', '2025-11-24 22:52:03.733412');
INSERT INTO public.useractivitylog VALUES (12, 1, 'bmr_tdee_recomputed', '2025-11-24 22:52:03.758064');
INSERT INTO public.useractivitylog VALUES (13, 1, 'body_measurement_recorded', '2025-11-24 22:52:15.989212');
INSERT INTO public.useractivitylog VALUES (14, 1, 'bmr_tdee_recomputed', '2025-11-24 22:52:15.997088');
INSERT INTO public.useractivitylog VALUES (15, 1, 'daily_targets_recomputed', '2025-11-24 23:03:34.235157');
INSERT INTO public.useractivitylog VALUES (16, 3, 'drink_created', '2025-11-25 19:59:13.684712');
INSERT INTO public.useractivitylog VALUES (17, 3, 'dish_created', '2025-11-25 20:26:45.476684');
INSERT INTO public.useractivitylog VALUES (18, 3, 'drink_created', '2025-11-25 20:35:20.136881');
INSERT INTO public.useractivitylog VALUES (19, 3, 'dish_created', '2025-11-26 16:48:14.437252');
INSERT INTO public.useractivitylog VALUES (20, 3, 'drink_created', '2025-11-26 16:48:48.458853');
INSERT INTO public.useractivitylog VALUES (21, 3, 'meal_entry_created', '2025-11-27 05:51:50.476636');
INSERT INTO public.useractivitylog VALUES (22, 3, 'body_measurement_recorded', '2025-11-29 01:32:36.375268');
INSERT INTO public.useractivitylog VALUES (23, 3, 'bmr_tdee_recomputed', '2025-11-29 01:32:36.407365');
INSERT INTO public.useractivitylog VALUES (24, 3, 'daily_targets_recomputed', '2025-11-29 01:32:55.383183');
INSERT INTO public.useractivitylog VALUES (25, 3, 'meal_entry_created', '2025-11-29 01:34:58.874873');


--
-- TOC entry 6458 (class 0 OID 21843)
-- Dependencies: 283
-- Data for Name: useraminointake; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6456 (class 0 OID 21822)
-- Dependencies: 281
-- Data for Name: useraminorequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.useraminorequirement VALUES (4, 1, 19, 1.02, 1162.800, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (4, 2, 25, 1.02, 1530.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (4, 3, 14, 1.02, 856.800, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (4, 4, 30, 1.02, 1836.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (4, 5, 15, 1.02, 918.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (4, 6, 26, 1.02, 1591.200, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (4, 7, 4, 1.02, 244.800, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (4, 8, 15, 1.02, 918.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (4, 9, 42, 1.02, 2570.400, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.useraminorequirement VALUES (2, 1, 19, 1.036, 826.728, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (2, 2, 25, 1.036, 1087.800, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (2, 3, 14, 1.036, 609.168, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (2, 4, 30, 1.036, 1305.360, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (2, 5, 15, 1.036, 652.680, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (2, 6, 26, 1.036, 1131.312, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (2, 7, 4, 1.036, 174.048, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (2, 8, 15, 1.036, 652.680, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (2, 9, 42, 1.036, 1827.504, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.useraminorequirement VALUES (3, 1, 19, 1.106, 1260.840, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (3, 2, 25, 1.106, 1659.000, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (3, 3, 14, 1.106, 929.040, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (3, 4, 30, 1.106, 1990.800, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (3, 5, 15, 1.106, 995.400, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (3, 6, 26, 1.106, 1725.360, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (3, 7, 4, 1.106, 265.440, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (3, 8, 15, 1.106, 995.400, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (3, 9, 42, 1.106, 2787.120, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.useraminorequirement VALUES (1, 1, 19, 1.056, 1203.840, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.useraminorequirement VALUES (1, 2, 25, 1.056, 1584.000, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.useraminorequirement VALUES (1, 3, 14, 1.056, 887.040, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.useraminorequirement VALUES (1, 4, 30, 1.056, 1900.800, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.useraminorequirement VALUES (1, 5, 15, 1.056, 950.400, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.useraminorequirement VALUES (1, 6, 26, 1.056, 1647.360, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.useraminorequirement VALUES (1, 7, 4, 1.056, 253.440, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.useraminorequirement VALUES (1, 8, 15, 1.056, 950.400, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.useraminorequirement VALUES (1, 9, 42, 1.056, 2661.120, 'mg', '2025-11-24 22:52:15.990562');


--
-- TOC entry 6449 (class 0 OID 21738)
-- Dependencies: 274
-- Data for Name: userfattyacidintake; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.userfattyacidintake VALUES (1, 1, '2025-11-23', 7, 3.2000);
INSERT INTO public.userfattyacidintake VALUES (2, 1, '2025-11-24', 7, 1129.6000);
INSERT INTO public.userfattyacidintake VALUES (3, 1, '2025-11-24', 17, 1048.0000);
INSERT INTO public.userfattyacidintake VALUES (5, 1, '2025-11-24', 4, 2012000.0000);
INSERT INTO public.userfattyacidintake VALUES (4, 1, '2025-11-24', 15, 3036.0000);
INSERT INTO public.userfattyacidintake VALUES (26, 3, '2025-11-27', 7, 1000.0000);
INSERT INTO public.userfattyacidintake VALUES (27, 3, '2025-11-27', 17, 1000.0000);
INSERT INTO public.userfattyacidintake VALUES (29, 3, '2025-11-27', 4, 2000000.0000);
INSERT INTO public.userfattyacidintake VALUES (28, 3, '2025-11-27', 15, 3000.0000);
INSERT INTO public.userfattyacidintake VALUES (33, 3, '2025-11-29', 7, 1000.0000);
INSERT INTO public.userfattyacidintake VALUES (34, 3, '2025-11-29', 17, 1000.0000);
INSERT INTO public.userfattyacidintake VALUES (36, 3, '2025-11-29', 4, 2000000.0000);
INSERT INTO public.userfattyacidintake VALUES (35, 3, '2025-11-29', 15, 3000.0000);


--
-- TOC entry 6445 (class 0 OID 21697)
-- Dependencies: 270
-- Data for Name: userfattyacidrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.userfattyacidrequirement VALUES (3, 16, 1.050000, 1.0530, 3.102, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 17, 13.125000, 1.0530, 38.775, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 18, 10.500000, 1.0530, 31.020, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (2, 1, NULL, NULL, NULL, NULL, '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 2, NULL, NULL, NULL, NULL, '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 3, NULL, NULL, NULL, NULL, '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 4, 250.000000, 1.0180, 255, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 5, 5.0000, 1.0180, 9.055, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 6, 300.000000, 1.0180, 305, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 7, 30.0000, 1.0180, 54.327, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 15, 7.5000, 1.0180, 13.582, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 16, 1.0000, 1.0180, 1.811, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 17, 12.5000, 1.0180, 22.636, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (2, 18, 10.0000, 1.0180, 18.109, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfattyacidrequirement VALUES (1, 1, NULL, NULL, NULL, NULL, '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 2, NULL, NULL, NULL, NULL, '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 3, NULL, NULL, NULL, NULL, '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 4, 250.000000, 1.0380, 363, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 5, 5.500000, 1.0380, 13.892, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 6, 300.000000, 1.0380, 311, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 7, 33.000000, 1.0380, 83.351, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 15, 8.250000, 1.0380, 20.838, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 16, 1.100000, 1.0380, 2.778, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 17, 13.750000, 1.0380, 34.730, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (1, 18, 11.000000, 1.0380, 27.784, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfattyacidrequirement VALUES (4, 1, NULL, NULL, NULL, NULL, '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 2, NULL, NULL, NULL, NULL, '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 3, NULL, NULL, NULL, NULL, '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 4, 250.000000, 1.02, 357, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 5, 5.500000, 1.02, 12.467, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 6, 300.000000, 1.02, 306, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 7, 33.000000, 1.02, 74.800, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 15, 8.250000, 1.02, 18.700, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 16, 1.100000, 1.02, 2.493, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 17, 13.750000, 1.02, 31.167, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (4, 18, 11.000000, 1.02, 24.933, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfattyacidrequirement VALUES (3, 1, NULL, NULL, NULL, NULL, '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 2, NULL, NULL, NULL, NULL, '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 3, NULL, NULL, NULL, NULL, '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 4, 250.000000, 1.0530, 263, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 5, 5.250000, 1.0530, 15.510, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 6, 300.000000, 1.0530, 316, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 7, 31.500000, 1.0530, 93.059, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfattyacidrequirement VALUES (3, 15, 7.875000, 1.0530, 23.265, 'g', '2025-11-29 01:32:36.387799');


--
-- TOC entry 6447 (class 0 OID 21718)
-- Dependencies: 272
-- Data for Name: userfiberintake; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.userfiberintake VALUES (1, 1, '2025-11-23', 6, 2.7000);
INSERT INTO public.userfiberintake VALUES (2, 1, '2025-11-24', 6, 3104.1000);
INSERT INTO public.userfiberintake VALUES (14, 3, '2025-11-27', 6, 3000.0000);
INSERT INTO public.userfiberintake VALUES (17, 3, '2025-11-29', 6, 3000.0000);


--
-- TOC entry 6444 (class 0 OID 21677)
-- Dependencies: 269
-- Data for Name: userfiberrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.userfiberrequirement VALUES (2, 1, 10.000000, 1.0180, 10.180, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfiberrequirement VALUES (2, 2, 3.000000, 1.0180, 3.054, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfiberrequirement VALUES (2, 5, 15.000000, 1.0180, 15.270, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfiberrequirement VALUES (2, 6, 25.000000, 1.0180, 25.450, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfiberrequirement VALUES (2, 7, 7.000000, 1.0180, 7.126, 'g', '2025-11-23 20:44:04.63164');
INSERT INTO public.userfiberrequirement VALUES (1, 1, 10.000000, 1.0380, 10.380, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfiberrequirement VALUES (1, 2, 3.000000, 1.0380, 3.114, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfiberrequirement VALUES (1, 5, 15.000000, 1.0380, 15.570, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfiberrequirement VALUES (1, 6, 25.000000, 1.0380, 25.950, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfiberrequirement VALUES (1, 7, 7.000000, 1.0380, 7.266, 'g', '2025-11-24 22:52:15.990562');
INSERT INTO public.userfiberrequirement VALUES (4, 1, 10.000000, 1.02, 10.200, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfiberrequirement VALUES (4, 2, 3.000000, 1.02, 3.060, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfiberrequirement VALUES (4, 5, 15.000000, 1.02, 15.300, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfiberrequirement VALUES (4, 6, 25.000000, 1.02, 25.500, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfiberrequirement VALUES (4, 7, 7.000000, 1.02, 7.140, 'g', '2025-11-27 04:52:23.478157');
INSERT INTO public.userfiberrequirement VALUES (3, 1, 10.000000, 1.0530, 10.530, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfiberrequirement VALUES (3, 2, 3.000000, 1.0530, 3.159, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfiberrequirement VALUES (3, 5, 15.000000, 1.0530, 15.795, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfiberrequirement VALUES (3, 6, 25.000000, 1.0530, 26.325, 'g', '2025-11-29 01:32:36.387799');
INSERT INTO public.userfiberrequirement VALUES (3, 7, 7.000000, 1.0530, 7.371, 'g', '2025-11-29 01:32:36.387799');


--
-- TOC entry 6425 (class 0 OID 21393)
-- Dependencies: 250
-- Data for Name: usergoal; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6488 (class 0 OID 22242)
-- Dependencies: 317
-- Data for Name: userhealthcondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.userhealthcondition VALUES (2, 1, 5, '2025-11-22', '2025-11-23', '2025-11-30', 7, 'active', NULL, '2025-11-22 17:22:00.781798');
INSERT INTO public.userhealthcondition VALUES (3, 3, 4, '2025-11-24', '2025-11-24', '2025-12-01', 7, 'active', NULL, '2025-11-24 06:27:45.049044');
INSERT INTO public.userhealthcondition VALUES (1, 1, 4, '2025-11-19', '2025-11-27', '2025-11-29', 2, 'recovered', NULL, '2025-11-19 17:23:17.583225');


--
-- TOC entry 6570 (class 0 OID 29003)
-- Dependencies: 407
-- Data for Name: usermedication; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6435 (class 0 OID 21579)
-- Dependencies: 260
-- Data for Name: usermineralrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usermineralrequirement VALUES (1, 1, 1000.000, 1.0470, 1047.000, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 2, 700.000, 1.0470, 732.900, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 3, 400.000, 1.0470, 418.800, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 4, 3400.000, 1.0470, 3559.800, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 5, 1500.000, 1.0470, 1570.500, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 6, 8.000, 1.0470, 8.376, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 7, 11.000, 1.0470, 11.517, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 8, 900.000, 1.0470, 942.300, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 9, 2.300, 1.0470, 2.408, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 10, 150.000, 1.0470, 157.050, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 11, 55.000, 1.0470, 57.585, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 12, 35.000, 1.0470, 36.645, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 13, 45.000, 1.0470, 47.115, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (1, 14, 3.000, 1.0470, 3.141, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.usermineralrequirement VALUES (4, 1, 1000.000, 1.02, 1020.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 2, 700.000, 1.02, 714.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 3, 400.000, 1.02, 408.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 4, 3400.000, 1.02, 3468.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 5, 1500.000, 1.02, 1530.000, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 6, 8.000, 1.02, 8.160, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 7, 11.000, 1.02, 11.220, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 8, 900.000, 1.02, 918.000, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 9, 2.300, 1.02, 2.346, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (2, 1, 1000.000, 1.0270, 1027.000, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 2, 700.000, 1.0270, 718.900, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 3, 310.000, 1.0270, 318.370, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 4, 2600.000, 1.0270, 2670.200, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 5, 1500.000, 1.0270, 1540.500, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 6, 18.000, 1.0270, 18.486, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 7, 8.000, 1.0270, 8.216, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 8, 900.000, 1.0270, 924.300, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 9, 1.800, 1.0270, 1.849, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 10, 150.000, 1.0270, 154.050, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 11, 55.000, 1.0270, 56.485, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 12, 35.000, 1.0270, 35.945, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 13, 45.000, 1.0270, 46.215, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (2, 14, 3.000, 1.0270, 3.081, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.usermineralrequirement VALUES (4, 10, 150.000, 1.02, 153.000, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 11, 55.000, 1.02, 56.100, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 12, 35.000, 1.02, 35.700, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 13, 45.000, 1.02, 45.900, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (4, 14, 3.000, 1.02, 3.060, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.usermineralrequirement VALUES (3, 1, 1000.000, 1.0795, 1079.500, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 2, 700.000, 1.0795, 755.650, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 3, 310.000, 1.0795, 334.645, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 4, 2600.000, 1.0795, 2806.700, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 5, 1500.000, 1.0795, 1619.250, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 6, 18.000, 1.0795, 19.431, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 7, 8.000, 1.0795, 8.636, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 8, 900.000, 1.0795, 971.550, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 9, 1.800, 1.0795, 1.943, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 10, 150.000, 1.0795, 161.925, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 11, 55.000, 1.0795, 59.373, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 12, 35.000, 1.0795, 37.783, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 13, 45.000, 1.0795, 48.578, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.usermineralrequirement VALUES (3, 14, 3.000, 1.0795, 3.239, 'mg', '2025-11-29 01:32:36.387799');


--
-- TOC entry 6542 (class 0 OID 23753)
-- Dependencies: 377
-- Data for Name: usernutrientmanuallog; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usernutrientmanuallog VALUES (2, 1, '2025-11-20', 2, 'macro', 'PROCNT', 'Protein', 'g', 25.0000, 'scan', NULL, '{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}', '2025-11-20 04:47:31.387243-08', '2025-11-20 04:47:31.387243-08');
INSERT INTO public.usernutrientmanuallog VALUES (4, 1, '2025-11-20', 3, 'macro', 'FAT', 'Total Fat', 'g', 10.0000, 'scan', NULL, '{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}', '2025-11-20 04:47:31.390469-08', '2025-11-20 04:47:31.390469-08');
INSERT INTO public.usernutrientmanuallog VALUES (5, 1, '2025-11-20', 5, 'macro', 'FIBTG', 'Dietary Fiber (total)', 'g', 2.0000, 'scan', NULL, '{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}', '2025-11-20 04:47:31.392796-08', '2025-11-20 04:47:31.392796-08');
INSERT INTO public.usernutrientmanuallog VALUES (6, 1, '2025-11-20', 6, 'mineral', 'MIN_FE', 'Iron (Fe)', 'mg', 3.0000, 'scan', NULL, '{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}', '2025-11-20 04:47:31.395516-08', '2025-11-20 04:47:31.395516-08');
INSERT INTO public.usernutrientmanuallog VALUES (1, 1, '2025-11-20', 1, 'macro', 'ENERC_KCAL', 'Energy (Calories)', 'kcal', 400.0000, 'scan', NULL, '{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}', '2025-11-20 04:47:31.382769-08', '2025-11-20 04:47:31.396853-08');
INSERT INTO public.usernutrientmanuallog VALUES (3, 1, '2025-11-20', 4, 'macro', 'CHOCDF', 'Carbohydrate, by difference', 'g', 340.0000, 'scan', NULL, '{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}', '2025-11-20 04:47:31.388612-08', '2025-11-20 04:47:31.398213-08');
INSERT INTO public.usernutrientmanuallog VALUES (9, 1, '2025-11-20', 8, 'vitamin', 'VITB3', 'Vitamin B3 (Niacin)', 'mg', 5.0000, 'scan', NULL, '{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}', '2025-11-20 04:47:31.399401-08', '2025-11-20 04:47:31.399401-08');
INSERT INTO public.usernutrientmanuallog VALUES (10, 1, '2025-11-20', 13, 'vitamin', 'VITB12', 'Vitamin B12 (Cobalamin)', 'µg', 1.5000, 'scan', NULL, '{"source": "scan", "food_name": "Phá» bÃ²", "confidence": null}', '2025-11-20 04:47:31.401022-08', '2025-11-20 04:47:31.401022-08');


--
-- TOC entry 6470 (class 0 OID 21994)
-- Dependencies: 296
-- Data for Name: usernutrientnotification; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6468 (class 0 OID 21972)
-- Dependencies: 294
-- Data for Name: usernutrienttracking; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usernutrienttracking VALUES (1, 1, '2025-11-19', 'vitamin', 11, 31.950, NULL, 'µg', '2025-11-19 19:04:28.389863-08');
INSERT INTO public.usernutrienttracking VALUES (2, 1, '2025-11-19', 'vitamin', 9, 5.325, NULL, 'mg', '2025-11-19 19:04:28.404138-08');
INSERT INTO public.usernutrienttracking VALUES (3, 1, '2025-11-19', 'vitamin', 8, 17.040, NULL, 'mg', '2025-11-19 19:04:28.404704-08');
INSERT INTO public.usernutrienttracking VALUES (4, 1, '2025-11-19', 'vitamin', 3, 15.975, NULL, 'mg', '2025-11-19 19:04:28.405345-08');
INSERT INTO public.usernutrienttracking VALUES (5, 1, '2025-11-19', 'vitamin', 10, 1.385, NULL, 'mg', '2025-11-19 19:04:28.40585-08');
INSERT INTO public.usernutrienttracking VALUES (6, 1, '2025-11-19', 'vitamin', 13, 2.556, NULL, 'µg', '2025-11-19 19:04:28.40639-08');
INSERT INTO public.usernutrienttracking VALUES (7, 1, '2025-11-19', 'vitamin', 5, 95.850, NULL, 'mg', '2025-11-19 19:04:28.406916-08');
INSERT INTO public.usernutrienttracking VALUES (8, 1, '2025-11-19', 'vitamin', 2, 639.000, NULL, 'IU', '2025-11-19 19:04:28.407355-08');
INSERT INTO public.usernutrienttracking VALUES (9, 1, '2025-11-19', 'vitamin', 12, 426.000, NULL, 'µg', '2025-11-19 19:04:28.407742-08');
INSERT INTO public.usernutrienttracking VALUES (10, 1, '2025-11-19', 'vitamin', 4, 127.800, NULL, 'µg', '2025-11-19 19:04:28.40815-08');
INSERT INTO public.usernutrienttracking VALUES (11, 1, '2025-11-19', 'vitamin', 7, 1.385, NULL, 'mg', '2025-11-19 19:04:28.408533-08');
INSERT INTO public.usernutrienttracking VALUES (12, 1, '2025-11-19', 'vitamin', 6, 1.278, NULL, 'mg', '2025-11-19 19:04:28.408976-08');
INSERT INTO public.usernutrienttracking VALUES (13, 1, '2025-11-19', 'vitamin', 1, 958.500, NULL, 'µg', '2025-11-19 19:04:28.409344-08');
INSERT INTO public.usernutrienttracking VALUES (14, 1, '2025-11-19', 'mineral', 1, 1047.000, NULL, 'mg', '2025-11-19 19:04:28.409739-08');
INSERT INTO public.usernutrienttracking VALUES (15, 1, '2025-11-19', 'mineral', 9, 2.408, NULL, 'mg', '2025-11-19 19:04:28.410187-08');
INSERT INTO public.usernutrienttracking VALUES (16, 1, '2025-11-19', 'mineral', 10, 157.050, NULL, 'µg', '2025-11-19 19:04:28.410637-08');
INSERT INTO public.usernutrienttracking VALUES (17, 1, '2025-11-19', 'mineral', 11, 57.585, NULL, 'µg', '2025-11-19 19:04:28.411186-08');
INSERT INTO public.usernutrienttracking VALUES (18, 1, '2025-11-19', 'mineral', 3, 418.800, NULL, 'mg', '2025-11-19 19:04:28.411689-08');
INSERT INTO public.usernutrienttracking VALUES (19, 1, '2025-11-19', 'mineral', 6, 8.376, NULL, 'mg', '2025-11-19 19:04:28.412233-08');
INSERT INTO public.usernutrienttracking VALUES (20, 1, '2025-11-19', 'mineral', 12, 36.645, NULL, 'µg', '2025-11-19 19:04:28.412692-08');
INSERT INTO public.usernutrienttracking VALUES (21, 1, '2025-11-19', 'mineral', 13, 47.115, NULL, 'µg', '2025-11-19 19:04:28.413236-08');
INSERT INTO public.usernutrienttracking VALUES (22, 1, '2025-11-19', 'mineral', 8, 942.300, NULL, 'mg', '2025-11-19 19:04:28.413719-08');
INSERT INTO public.usernutrienttracking VALUES (23, 1, '2025-11-19', 'mineral', 5, 1570.500, NULL, 'mg', '2025-11-19 19:04:28.41418-08');
INSERT INTO public.usernutrienttracking VALUES (24, 1, '2025-11-19', 'mineral', 14, 3.141, NULL, 'mg', '2025-11-19 19:04:28.414721-08');
INSERT INTO public.usernutrienttracking VALUES (25, 1, '2025-11-19', 'mineral', 7, 11.517, NULL, 'mg', '2025-11-19 19:04:28.415238-08');
INSERT INTO public.usernutrienttracking VALUES (26, 1, '2025-11-19', 'mineral', 2, 732.900, NULL, 'mg', '2025-11-19 19:04:28.415611-08');
INSERT INTO public.usernutrienttracking VALUES (27, 1, '2025-11-19', 'mineral', 4, 3559.800, NULL, 'mg', '2025-11-19 19:04:28.41608-08');
INSERT INTO public.usernutrienttracking VALUES (135, 1, '2025-11-20', 'mineral', 4, 3559.800, 180.000, 'mg', '2025-11-20 06:31:08.346912-08');
INSERT INTO public.usernutrienttracking VALUES (136, 1, '2025-11-20', 'fiber', 1, 0.000, 0.000, 'g', '2025-11-20 06:31:08.347202-08');
INSERT INTO public.usernutrienttracking VALUES (137, 1, '2025-11-20', 'fiber', 2, 0.000, 0.000, 'g', '2025-11-20 06:31:08.347486-08');
INSERT INTO public.usernutrienttracking VALUES (138, 1, '2025-11-20', 'fatty_acid', 7, 0.000, 0.000, 'g', '2025-11-20 06:31:08.347738-08');
INSERT INTO public.usernutrienttracking VALUES (139, 1, '2025-11-20', 'fatty_acid', 5, 0.000, 60.000, 'g', '2025-11-20 06:31:08.347962-08');
INSERT INTO public.usernutrienttracking VALUES (140, 1, '2025-11-20', 'fatty_acid', 3, 0.000, 0.000, 'g', '2025-11-20 06:31:08.348176-08');
INSERT INTO public.usernutrienttracking VALUES (141, 1, '2025-11-20', 'fatty_acid', 4, 0.000, 60.000, 'g', '2025-11-20 06:31:08.34843-08');
INSERT INTO public.usernutrienttracking VALUES (142, 1, '2025-11-20', 'fatty_acid', 6, 0.000, 600.000, 'mg', '2025-11-20 06:31:08.348755-08');
INSERT INTO public.usernutrienttracking VALUES (143, 1, '2025-11-20', 'fatty_acid', 1, 0.000, 60.000, 'g', '2025-11-20 06:31:08.349098-08');
INSERT INTO public.usernutrienttracking VALUES (144, 1, '2025-11-20', 'fatty_acid', 2, 0.000, 0.000, 'g', '2025-11-20 06:31:08.349487-08');
INSERT INTO public.usernutrienttracking VALUES (327, 1, '2025-11-21', 'vitamin', 7, 1.385, 90.000, 'mg', '2025-11-20 17:58:45.635008-08');
INSERT INTO public.usernutrienttracking VALUES (328, 1, '2025-11-21', 'vitamin', 11, 31.950, 900.000, 'µg', '2025-11-20 17:58:45.635498-08');
INSERT INTO public.usernutrienttracking VALUES (109, 1, '2025-11-20', 'vitamin', 9, 5.325, 120.000, 'mg', '2025-11-20 06:31:08.329629-08');
INSERT INTO public.usernutrienttracking VALUES (110, 1, '2025-11-20', 'vitamin', 2, 639.000, 12000.000, 'IU', '2025-11-20 06:31:08.336148-08');
INSERT INTO public.usernutrienttracking VALUES (111, 1, '2025-11-20', 'vitamin', 7, 1.385, 120.000, 'mg', '2025-11-20 06:31:08.336753-08');
INSERT INTO public.usernutrienttracking VALUES (112, 1, '2025-11-20', 'vitamin', 11, 31.950, 1200.000, 'µg', '2025-11-20 06:31:08.337327-08');
INSERT INTO public.usernutrienttracking VALUES (113, 1, '2025-11-20', 'vitamin', 4, 127.800, 1200.000, 'µg', '2025-11-20 06:31:08.337767-08');
INSERT INTO public.usernutrienttracking VALUES (114, 1, '2025-11-20', 'vitamin', 3, 15.975, 120.000, 'mg', '2025-11-20 06:31:08.338223-08');
INSERT INTO public.usernutrienttracking VALUES (115, 1, '2025-11-20', 'vitamin', 1, 958.500, 1200.000, 'µg', '2025-11-20 06:31:08.33873-08');
INSERT INTO public.usernutrienttracking VALUES (116, 1, '2025-11-20', 'vitamin', 8, 17.040, 120.000, 'mg', '2025-11-20 06:31:08.339192-08');
INSERT INTO public.usernutrienttracking VALUES (117, 1, '2025-11-20', 'vitamin', 10, 1.385, 120.000, 'mg', '2025-11-20 06:31:08.339719-08');
INSERT INTO public.usernutrienttracking VALUES (118, 1, '2025-11-20', 'vitamin', 13, 2.556, 1200.000, 'µg', '2025-11-20 06:31:08.340194-08');
INSERT INTO public.usernutrienttracking VALUES (119, 1, '2025-11-20', 'vitamin', 5, 95.850, 217.900, 'mg', '2025-11-20 06:31:08.340623-08');
INSERT INTO public.usernutrienttracking VALUES (120, 1, '2025-11-20', 'vitamin', 12, 426.000, 1200.000, 'µg', '2025-11-20 06:31:08.341476-08');
INSERT INTO public.usernutrienttracking VALUES (121, 1, '2025-11-20', 'vitamin', 6, 1.278, 120.000, 'mg', '2025-11-20 06:31:08.341912-08');
INSERT INTO public.usernutrienttracking VALUES (122, 1, '2025-11-20', 'mineral', 13, 47.115, 600.000, 'µg', '2025-11-20 06:31:08.342252-08');
INSERT INTO public.usernutrienttracking VALUES (123, 1, '2025-11-20', 'mineral', 5, 1570.500, 3568.600, 'mg', '2025-11-20 06:31:08.342812-08');
INSERT INTO public.usernutrienttracking VALUES (124, 1, '2025-11-20', 'mineral', 1, 1047.000, 346.900, 'mg', '2025-11-20 06:31:08.343257-08');
INSERT INTO public.usernutrienttracking VALUES (125, 1, '2025-11-20', 'mineral', 9, 2.408, 180.000, 'mg', '2025-11-20 06:31:08.343581-08');
INSERT INTO public.usernutrienttracking VALUES (126, 1, '2025-11-20', 'mineral', 6, 8.376, 184.200, 'mg', '2025-11-20 06:31:08.343925-08');
INSERT INTO public.usernutrienttracking VALUES (127, 1, '2025-11-20', 'mineral', 3, 418.800, 180.000, 'mg', '2025-11-20 06:31:08.344308-08');
INSERT INTO public.usernutrienttracking VALUES (128, 1, '2025-11-20', 'mineral', 12, 36.645, 600.000, 'µg', '2025-11-20 06:31:08.344727-08');
INSERT INTO public.usernutrienttracking VALUES (329, 1, '2025-11-21', 'vitamin', 4, 127.800, 900.000, 'µg', '2025-11-20 17:58:45.63597-08');
INSERT INTO public.usernutrienttracking VALUES (330, 1, '2025-11-21', 'vitamin', 3, 15.975, 90.000, 'mg', '2025-11-20 17:58:45.636484-08');
INSERT INTO public.usernutrienttracking VALUES (331, 1, '2025-11-21', 'vitamin', 1, 958.500, 900.000, 'µg', '2025-11-20 17:58:45.636848-08');
INSERT INTO public.usernutrienttracking VALUES (332, 1, '2025-11-21', 'vitamin', 8, 17.040, 90.000, 'mg', '2025-11-20 17:58:45.637232-08');
INSERT INTO public.usernutrienttracking VALUES (333, 1, '2025-11-21', 'vitamin', 10, 1.385, 90.000, 'mg', '2025-11-20 17:58:45.637595-08');
INSERT INTO public.usernutrienttracking VALUES (334, 1, '2025-11-21', 'vitamin', 13, 2.556, 900.000, 'µg', '2025-11-20 17:58:45.637984-08');
INSERT INTO public.usernutrienttracking VALUES (335, 1, '2025-11-21', 'vitamin', 5, 95.850, 90.000, 'mg', '2025-11-20 17:58:45.638834-08');
INSERT INTO public.usernutrienttracking VALUES (336, 1, '2025-11-21', 'vitamin', 12, 426.000, 900.000, 'µg', '2025-11-20 17:58:45.639417-08');
INSERT INTO public.usernutrienttracking VALUES (129, 1, '2025-11-20', 'mineral', 10, 157.050, 600.000, 'µg', '2025-11-20 06:31:08.345073-08');
INSERT INTO public.usernutrienttracking VALUES (130, 1, '2025-11-20', 'mineral', 8, 942.300, 180.000, 'mg', '2025-11-20 06:31:08.345492-08');
INSERT INTO public.usernutrienttracking VALUES (131, 1, '2025-11-20', 'mineral', 7, 11.517, 180.000, 'mg', '2025-11-20 06:31:08.345783-08');
INSERT INTO public.usernutrienttracking VALUES (132, 1, '2025-11-20', 'mineral', 11, 57.585, 600.000, 'µg', '2025-11-20 06:31:08.346127-08');
INSERT INTO public.usernutrienttracking VALUES (133, 1, '2025-11-20', 'mineral', 2, 732.900, 180.000, 'mg', '2025-11-20 06:31:08.346405-08');
INSERT INTO public.usernutrienttracking VALUES (134, 1, '2025-11-20', 'mineral', 14, 3.141, 180.000, 'mg', '2025-11-20 06:31:08.34665-08');
INSERT INTO public.usernutrienttracking VALUES (337, 1, '2025-11-21', 'vitamin', 6, 1.278, 90.000, 'mg', '2025-11-20 17:58:45.639914-08');
INSERT INTO public.usernutrienttracking VALUES (338, 1, '2025-11-21', 'mineral', 13, 47.115, 450.000, 'µg', '2025-11-20 17:58:45.640419-08');
INSERT INTO public.usernutrienttracking VALUES (339, 1, '2025-11-21', 'mineral', 5, 1570.500, 135.000, 'mg', '2025-11-20 17:58:45.641189-08');
INSERT INTO public.usernutrienttracking VALUES (340, 1, '2025-11-21', 'mineral', 1, 1047.000, 135.000, 'mg', '2025-11-20 17:58:45.641793-08');
INSERT INTO public.usernutrienttracking VALUES (341, 1, '2025-11-21', 'mineral', 9, 2.408, 135.000, 'mg', '2025-11-20 17:58:45.642299-08');
INSERT INTO public.usernutrienttracking VALUES (342, 1, '2025-11-21', 'mineral', 6, 8.376, 135.000, 'mg', '2025-11-20 17:58:45.642735-08');
INSERT INTO public.usernutrienttracking VALUES (343, 1, '2025-11-21', 'mineral', 3, 418.800, 135.000, 'mg', '2025-11-20 17:58:45.643138-08');
INSERT INTO public.usernutrienttracking VALUES (344, 1, '2025-11-21', 'mineral', 12, 36.645, 450.000, 'µg', '2025-11-20 17:58:45.643509-08');
INSERT INTO public.usernutrienttracking VALUES (345, 1, '2025-11-21', 'mineral', 10, 157.050, 450.000, 'µg', '2025-11-20 17:58:45.643952-08');
INSERT INTO public.usernutrienttracking VALUES (346, 1, '2025-11-21', 'mineral', 8, 942.300, 135.000, 'mg', '2025-11-20 17:58:45.644456-08');
INSERT INTO public.usernutrienttracking VALUES (347, 1, '2025-11-21', 'mineral', 7, 11.517, 135.000, 'mg', '2025-11-20 17:58:45.64517-08');
INSERT INTO public.usernutrienttracking VALUES (348, 1, '2025-11-21', 'mineral', 11, 57.585, 450.000, 'µg', '2025-11-20 17:58:45.645711-08');
INSERT INTO public.usernutrienttracking VALUES (349, 1, '2025-11-21', 'mineral', 2, 732.900, 135.000, 'mg', '2025-11-20 17:58:45.64622-08');
INSERT INTO public.usernutrienttracking VALUES (350, 1, '2025-11-21', 'mineral', 14, 3.141, 135.000, 'mg', '2025-11-20 17:58:45.647009-08');
INSERT INTO public.usernutrienttracking VALUES (351, 1, '2025-11-21', 'mineral', 4, 3559.800, 135.000, 'mg', '2025-11-20 17:58:45.64744-08');
INSERT INTO public.usernutrienttracking VALUES (352, 1, '2025-11-21', 'fiber', 1, 0.000, 0.000, 'g', '2025-11-20 17:58:45.647943-08');
INSERT INTO public.usernutrienttracking VALUES (325, 1, '2025-11-21', 'vitamin', 9, 5.325, 90.000, 'mg', '2025-11-20 17:58:45.633088-08');
INSERT INTO public.usernutrienttracking VALUES (326, 1, '2025-11-21', 'vitamin', 2, 639.000, 9000.000, 'IU', '2025-11-20 17:58:45.634365-08');
INSERT INTO public.usernutrienttracking VALUES (515, 1, '2025-11-23', 'fatty_acid', 6, 311.000, 450.000, 'mg', '2025-11-23 01:26:13.458707-08');
INSERT INTO public.usernutrienttracking VALUES (516, 1, '2025-11-23', 'fatty_acid', 17, 34.730, 72.000, 'g', '2025-11-23 01:26:13.459503-08');
INSERT INTO public.usernutrienttracking VALUES (517, 1, '2025-11-23', 'fatty_acid', 16, 2.778, 9.000, 'g', '2025-11-23 01:26:13.460315-08');
INSERT INTO public.usernutrienttracking VALUES (518, 1, '2025-11-23', 'fatty_acid', 15, 20.838, 36.000, 'g', '2025-11-23 01:26:13.460729-08');
INSERT INTO public.usernutrienttracking VALUES (519, 1, '2025-11-23', 'fatty_acid', 7, 83.351, 183.700, 'g', '2025-11-23 01:26:13.461065-08');
INSERT INTO public.usernutrienttracking VALUES (520, 1, '2025-11-23', 'fatty_acid', 2, 0.000, 9.000, 'g', '2025-11-23 01:26:13.461354-08');
INSERT INTO public.usernutrienttracking VALUES (482, 1, '2025-11-23', 'mineral', 13, 47.115, 450.000, 'µg', '2025-11-23 01:26:13.446048-08');
INSERT INTO public.usernutrienttracking VALUES (483, 1, '2025-11-23', 'mineral', 5, 1570.500, 13191.000, 'mg', '2025-11-23 01:26:13.446622-08');
INSERT INTO public.usernutrienttracking VALUES (484, 1, '2025-11-23', 'mineral', 1, 1047.000, 932.000, 'mg', '2025-11-23 01:26:13.44711-08');
INSERT INTO public.usernutrienttracking VALUES (353, 1, '2025-11-21', 'fiber', 2, 0.000, 0.000, 'g', '2025-11-20 17:58:45.648304-08');
INSERT INTO public.usernutrienttracking VALUES (354, 1, '2025-11-21', 'fatty_acid', 7, 0.000, 0.000, 'g', '2025-11-20 17:58:45.64914-08');
INSERT INTO public.usernutrienttracking VALUES (355, 1, '2025-11-21', 'fatty_acid', 5, 0.000, 45.000, 'g', '2025-11-20 17:58:45.649816-08');
INSERT INTO public.usernutrienttracking VALUES (356, 1, '2025-11-21', 'fatty_acid', 3, 0.000, 0.000, 'g', '2025-11-20 17:58:45.650287-08');
INSERT INTO public.usernutrienttracking VALUES (357, 1, '2025-11-21', 'fatty_acid', 4, 0.000, 45.000, 'g', '2025-11-20 17:58:45.650714-08');
INSERT INTO public.usernutrienttracking VALUES (358, 1, '2025-11-21', 'fatty_acid', 6, 0.000, 450.000, 'mg', '2025-11-20 17:58:45.651199-08');
INSERT INTO public.usernutrienttracking VALUES (359, 1, '2025-11-21', 'fatty_acid', 1, 0.000, 45.000, 'g', '2025-11-20 17:58:45.651582-08');
INSERT INTO public.usernutrienttracking VALUES (360, 1, '2025-11-21', 'fatty_acid', 2, 0.000, 0.000, 'g', '2025-11-20 17:58:45.652053-08');
INSERT INTO public.usernutrienttracking VALUES (485, 1, '2025-11-23', 'mineral', 9, 2.408, 135.000, 'mg', '2025-11-23 01:26:13.447615-08');
INSERT INTO public.usernutrienttracking VALUES (486, 1, '2025-11-23', 'mineral', 6, 8.376, 142.200, 'mg', '2025-11-23 01:26:13.448059-08');
INSERT INTO public.usernutrienttracking VALUES (487, 1, '2025-11-23', 'mineral', 3, 418.800, 135.000, 'mg', '2025-11-23 01:26:13.448495-08');
INSERT INTO public.usernutrienttracking VALUES (488, 1, '2025-11-23', 'mineral', 12, 36.645, 450.000, 'µg', '2025-11-23 01:26:13.448921-08');
INSERT INTO public.usernutrienttracking VALUES (489, 1, '2025-11-23', 'mineral', 10, 157.050, 450.000, 'µg', '2025-11-23 01:26:13.449272-08');
INSERT INTO public.usernutrienttracking VALUES (490, 1, '2025-11-23', 'mineral', 8, 942.300, 135.000, 'mg', '2025-11-23 01:26:13.449629-08');
INSERT INTO public.usernutrienttracking VALUES (491, 1, '2025-11-23', 'mineral', 7, 11.517, 135.000, 'mg', '2025-11-23 01:26:13.45002-08');
INSERT INTO public.usernutrienttracking VALUES (492, 1, '2025-11-23', 'mineral', 11, 57.585, 450.000, 'µg', '2025-11-23 01:26:13.450404-08');
INSERT INTO public.usernutrienttracking VALUES (493, 1, '2025-11-23', 'mineral', 2, 732.900, 135.000, 'mg', '2025-11-23 01:26:13.450843-08');
INSERT INTO public.usernutrienttracking VALUES (494, 1, '2025-11-23', 'mineral', 14, 3.141, 135.000, 'mg', '2025-11-23 01:26:13.451189-08');
INSERT INTO public.usernutrienttracking VALUES (944, 1, '2025-11-24', 'vitamin', 8, 17.040, 1060.000, 'mg', '2025-11-23 19:37:18.24795-08');
INSERT INTO public.usernutrienttracking VALUES (945, 1, '2025-11-24', 'vitamin', 10, 1.385, 1060.000, 'mg', '2025-11-23 19:37:18.248306-08');
INSERT INTO public.usernutrienttracking VALUES (495, 1, '2025-11-23', 'mineral', 4, 3559.800, 135.000, 'mg', '2025-11-23 01:26:13.451518-08');
INSERT INTO public.usernutrienttracking VALUES (496, 1, '2025-11-23', 'amino_acid', 5, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.451808-08');
INSERT INTO public.usernutrienttracking VALUES (497, 1, '2025-11-23', 'amino_acid', 3, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.452092-08');
INSERT INTO public.usernutrienttracking VALUES (498, 1, '2025-11-23', 'amino_acid', 6, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.452378-08');
INSERT INTO public.usernutrienttracking VALUES (499, 1, '2025-11-23', 'amino_acid', 9, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.452664-08');
INSERT INTO public.usernutrienttracking VALUES (500, 1, '2025-11-23', 'amino_acid', 7, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.452955-08');
INSERT INTO public.usernutrienttracking VALUES (501, 1, '2025-11-23', 'amino_acid', 1, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.453224-08');
INSERT INTO public.usernutrienttracking VALUES (502, 1, '2025-11-23', 'amino_acid', 8, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.453489-08');
INSERT INTO public.usernutrienttracking VALUES (503, 1, '2025-11-23', 'amino_acid', 4, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.453765-08');
INSERT INTO public.usernutrienttracking VALUES (504, 1, '2025-11-23', 'amino_acid', 2, 0.000, 0.000, 'mg', '2025-11-23 01:26:13.454063-08');
INSERT INTO public.usernutrienttracking VALUES (505, 1, '2025-11-23', 'fiber', 2, 3.114, 27.000, 'g', '2025-11-23 01:26:13.454388-08');
INSERT INTO public.usernutrienttracking VALUES (506, 1, '2025-11-23', 'fiber', 1, 10.380, 27.000, 'g', '2025-11-23 01:26:13.454674-08');
INSERT INTO public.usernutrienttracking VALUES (507, 1, '2025-11-23', 'fiber', 5, 15.570, 27.000, 'g', '2025-11-23 01:26:13.455033-08');
INSERT INTO public.usernutrienttracking VALUES (508, 1, '2025-11-23', 'fiber', 6, 25.950, 96.000, 'g', '2025-11-23 01:26:13.455602-08');
INSERT INTO public.usernutrienttracking VALUES (509, 1, '2025-11-23', 'fiber', 7, 7.266, 27.000, 'g', '2025-11-23 01:26:13.456007-08');
INSERT INTO public.usernutrienttracking VALUES (510, 1, '2025-11-23', 'fatty_acid', 3, 0.000, 9.000, 'g', '2025-11-23 01:26:13.456506-08');
INSERT INTO public.usernutrienttracking VALUES (511, 1, '2025-11-23', 'fatty_acid', 4, 363.000, 9.000, 'g', '2025-11-23 01:26:13.456857-08');
INSERT INTO public.usernutrienttracking VALUES (946, 1, '2025-11-24', 'vitamin', 13, 2.556, 1600.000, 'µg', '2025-11-23 19:37:18.248807-08');
INSERT INTO public.usernutrienttracking VALUES (947, 1, '2025-11-24', 'vitamin', 5, 95.850, 1060.000, 'mg', '2025-11-23 19:37:18.249342-08');
INSERT INTO public.usernutrienttracking VALUES (948, 1, '2025-11-24', 'vitamin', 12, 426.000, 1600.000, 'µg', '2025-11-23 19:37:18.249849-08');
INSERT INTO public.usernutrienttracking VALUES (949, 1, '2025-11-24', 'vitamin', 6, 1.278, 1060.000, 'mg', '2025-11-23 19:37:18.250289-08');
INSERT INTO public.usernutrienttracking VALUES (469, 1, '2025-11-23', 'vitamin', 9, 5.325, 90.000, 'mg', '2025-11-23 01:26:13.440027-08');
INSERT INTO public.usernutrienttracking VALUES (470, 1, '2025-11-23', 'vitamin', 2, 639.000, 9000.000, 'IU', '2025-11-23 01:26:13.440721-08');
INSERT INTO public.usernutrienttracking VALUES (471, 1, '2025-11-23', 'vitamin', 7, 1.385, 90.000, 'mg', '2025-11-23 01:26:13.441135-08');
INSERT INTO public.usernutrienttracking VALUES (472, 1, '2025-11-23', 'vitamin', 11, 31.950, 900.000, 'µg', '2025-11-23 01:26:13.44153-08');
INSERT INTO public.usernutrienttracking VALUES (473, 1, '2025-11-23', 'vitamin', 4, 127.800, 900.000, 'µg', '2025-11-23 01:26:13.441946-08');
INSERT INTO public.usernutrienttracking VALUES (474, 1, '2025-11-23', 'vitamin', 3, 15.975, 90.000, 'mg', '2025-11-23 01:26:13.442358-08');
INSERT INTO public.usernutrienttracking VALUES (475, 1, '2025-11-23', 'vitamin', 1, 958.500, 900.000, 'µg', '2025-11-23 01:26:13.442768-08');
INSERT INTO public.usernutrienttracking VALUES (476, 1, '2025-11-23', 'vitamin', 8, 17.040, 90.000, 'mg', '2025-11-23 01:26:13.443184-08');
INSERT INTO public.usernutrienttracking VALUES (477, 1, '2025-11-23', 'vitamin', 10, 1.385, 90.000, 'mg', '2025-11-23 01:26:13.443698-08');
INSERT INTO public.usernutrienttracking VALUES (478, 1, '2025-11-23', 'vitamin', 13, 2.556, 900.000, 'µg', '2025-11-23 01:26:13.44427-08');
INSERT INTO public.usernutrienttracking VALUES (479, 1, '2025-11-23', 'vitamin', 5, 95.850, 117.000, 'mg', '2025-11-23 01:26:13.444755-08');
INSERT INTO public.usernutrienttracking VALUES (480, 1, '2025-11-23', 'vitamin', 12, 426.000, 900.000, 'µg', '2025-11-23 01:26:13.445175-08');
INSERT INTO public.usernutrienttracking VALUES (481, 1, '2025-11-23', 'vitamin', 6, 1.278, 90.000, 'mg', '2025-11-23 01:26:13.44558-08');
INSERT INTO public.usernutrienttracking VALUES (512, 1, '2025-11-23', 'fatty_acid', 5, 13.892, 9.000, 'g', '2025-11-23 01:26:13.457204-08');
INSERT INTO public.usernutrienttracking VALUES (513, 1, '2025-11-23', 'fatty_acid', 1, 0.000, 9.000, 'g', '2025-11-23 01:26:13.457618-08');
INSERT INTO public.usernutrienttracking VALUES (514, 1, '2025-11-23', 'fatty_acid', 18, 27.784, 45.000, 'g', '2025-11-23 01:26:13.458233-08');
INSERT INTO public.usernutrienttracking VALUES (950, 1, '2025-11-24', 'mineral', 13, 47.115, 1300.000, 'µg', '2025-11-23 19:37:18.250633-08');
INSERT INTO public.usernutrienttracking VALUES (951, 1, '2025-11-24', 'mineral', 5, 1570.500, 1090.000, 'mg', '2025-11-23 19:37:18.251047-08');
INSERT INTO public.usernutrienttracking VALUES (952, 1, '2025-11-24', 'mineral', 1, 1047.000, 1090.000, 'mg', '2025-11-23 19:37:18.251654-08');
INSERT INTO public.usernutrienttracking VALUES (953, 1, '2025-11-24', 'mineral', 9, 2.408, 1090.000, 'mg', '2025-11-23 19:37:18.252099-08');
INSERT INTO public.usernutrienttracking VALUES (954, 1, '2025-11-24', 'mineral', 6, 8.376, 1090.000, 'mg', '2025-11-23 19:37:18.252523-08');
INSERT INTO public.usernutrienttracking VALUES (955, 1, '2025-11-24', 'mineral', 3, 418.800, 1090.000, 'mg', '2025-11-23 19:37:18.252872-08');
INSERT INTO public.usernutrienttracking VALUES (956, 1, '2025-11-24', 'mineral', 12, 36.645, 1300.000, 'µg', '2025-11-23 19:37:18.25319-08');
INSERT INTO public.usernutrienttracking VALUES (957, 1, '2025-11-24', 'mineral', 10, 157.050, 1300.000, 'µg', '2025-11-23 19:37:18.253573-08');
INSERT INTO public.usernutrienttracking VALUES (958, 1, '2025-11-24', 'mineral', 8, 942.300, 1090.000, 'mg', '2025-11-23 19:37:18.254121-08');
INSERT INTO public.usernutrienttracking VALUES (959, 1, '2025-11-24', 'mineral', 7, 11.517, 1090.000, 'mg', '2025-11-23 19:37:18.254632-08');
INSERT INTO public.usernutrienttracking VALUES (960, 1, '2025-11-24', 'mineral', 11, 57.585, 1300.000, 'µg', '2025-11-23 19:37:18.255132-08');
INSERT INTO public.usernutrienttracking VALUES (961, 1, '2025-11-24', 'mineral', 2, 732.900, 1090.000, 'mg', '2025-11-23 19:37:18.255495-08');
INSERT INTO public.usernutrienttracking VALUES (962, 1, '2025-11-24', 'mineral', 14, 3.141, 1090.000, 'mg', '2025-11-23 19:37:18.255846-08');
INSERT INTO public.usernutrienttracking VALUES (963, 1, '2025-11-24', 'mineral', 4, 3559.800, 1090.000, 'mg', '2025-11-23 19:37:18.256285-08');
INSERT INTO public.usernutrienttracking VALUES (964, 1, '2025-11-24', 'amino_acid', 5, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.256767-08');
INSERT INTO public.usernutrienttracking VALUES (965, 1, '2025-11-24', 'amino_acid', 3, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.257154-08');
INSERT INTO public.usernutrienttracking VALUES (966, 1, '2025-11-24', 'amino_acid', 6, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.257543-08');
INSERT INTO public.usernutrienttracking VALUES (967, 1, '2025-11-24', 'amino_acid', 9, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.257841-08');
INSERT INTO public.usernutrienttracking VALUES (968, 1, '2025-11-24', 'amino_acid', 7, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.258097-08');
INSERT INTO public.usernutrienttracking VALUES (969, 1, '2025-11-24', 'amino_acid', 1, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.258356-08');
INSERT INTO public.usernutrienttracking VALUES (970, 1, '2025-11-24', 'amino_acid', 8, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.25869-08');
INSERT INTO public.usernutrienttracking VALUES (971, 1, '2025-11-24', 'amino_acid', 4, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.258971-08');
INSERT INTO public.usernutrienttracking VALUES (972, 1, '2025-11-24', 'amino_acid', 2, 0.000, 1015.000, 'mg', '2025-11-23 19:37:18.25923-08');
INSERT INTO public.usernutrienttracking VALUES (937, 1, '2025-11-24', 'vitamin', 9, 5.325, 1060.000, 'mg', '2025-11-23 19:37:18.243928-08');
INSERT INTO public.usernutrienttracking VALUES (938, 1, '2025-11-24', 'vitamin', 2, 639.000, 7000.000, 'IU', '2025-11-23 19:37:18.244892-08');
INSERT INTO public.usernutrienttracking VALUES (939, 1, '2025-11-24', 'vitamin', 7, 1.385, 1060.000, 'mg', '2025-11-23 19:37:18.245378-08');
INSERT INTO public.usernutrienttracking VALUES (940, 1, '2025-11-24', 'vitamin', 11, 31.950, 1600.000, 'µg', '2025-11-23 19:37:18.246092-08');
INSERT INTO public.usernutrienttracking VALUES (941, 1, '2025-11-24', 'vitamin', 4, 127.800, 1600.000, 'µg', '2025-11-23 19:37:18.246699-08');
INSERT INTO public.usernutrienttracking VALUES (942, 1, '2025-11-24', 'vitamin', 3, 15.975, 1060.000, 'mg', '2025-11-23 19:37:18.247171-08');
INSERT INTO public.usernutrienttracking VALUES (943, 1, '2025-11-24', 'vitamin', 1, 958.500, 1600.000, 'µg', '2025-11-23 19:37:18.247572-08');
INSERT INTO public.usernutrienttracking VALUES (973, 1, '2025-11-24', 'fiber', 1, 10.380, 0.000, 'g', '2025-11-23 19:37:18.259596-08');
INSERT INTO public.usernutrienttracking VALUES (974, 1, '2025-11-24', 'fiber', 2, 3.114, 0.000, 'g', '2025-11-23 19:37:18.25991-08');
INSERT INTO public.usernutrienttracking VALUES (975, 1, '2025-11-24', 'fiber', 5, 15.570, 0.000, 'g', '2025-11-23 19:37:18.260195-08');
INSERT INTO public.usernutrienttracking VALUES (976, 1, '2025-11-24', 'fiber', 6, 25.950, 3104.100, 'g', '2025-11-23 19:37:18.260444-08');
INSERT INTO public.usernutrienttracking VALUES (977, 1, '2025-11-24', 'fiber', 7, 7.266, 0.000, 'g', '2025-11-23 19:37:18.260679-08');
INSERT INTO public.usernutrienttracking VALUES (978, 1, '2025-11-24', 'fatty_acid', 1, 0.000, 0.000, 'g', '2025-11-23 19:37:18.260916-08');
INSERT INTO public.usernutrienttracking VALUES (979, 1, '2025-11-24', 'fatty_acid', 2, 0.000, 0.000, 'g', '2025-11-23 19:37:18.261178-08');
INSERT INTO public.usernutrienttracking VALUES (980, 1, '2025-11-24', 'fatty_acid', 3, 0.000, 0.000, 'g', '2025-11-23 19:37:18.261418-08');
INSERT INTO public.usernutrienttracking VALUES (981, 1, '2025-11-24', 'fatty_acid', 4, 363.000, 2012000.000, 'g', '2025-11-23 19:37:18.261649-08');
INSERT INTO public.usernutrienttracking VALUES (982, 1, '2025-11-24', 'fatty_acid', 5, 13.892, 0.000, 'g', '2025-11-23 19:37:18.261882-08');
INSERT INTO public.usernutrienttracking VALUES (983, 1, '2025-11-24', 'fatty_acid', 6, 311.000, 0.000, 'mg', '2025-11-23 19:37:18.262165-08');
INSERT INTO public.usernutrienttracking VALUES (984, 1, '2025-11-24', 'fatty_acid', 7, 83.351, 1129.600, 'g', '2025-11-23 19:37:18.262834-08');
INSERT INTO public.usernutrienttracking VALUES (985, 1, '2025-11-24', 'fatty_acid', 15, 20.838, 3036.000, 'g', '2025-11-23 19:37:18.263209-08');
INSERT INTO public.usernutrienttracking VALUES (986, 1, '2025-11-24', 'fatty_acid', 16, 2.778, 0.000, 'g', '2025-11-23 19:37:18.263648-08');
INSERT INTO public.usernutrienttracking VALUES (987, 1, '2025-11-24', 'fatty_acid', 17, 34.730, 1048.000, 'g', '2025-11-23 19:37:18.264081-08');
INSERT INTO public.usernutrienttracking VALUES (988, 1, '2025-11-24', 'fatty_acid', 18, 27.784, 0.000, 'g', '2025-11-23 19:37:18.264467-08');
INSERT INTO public.usernutrienttracking VALUES (1405, 3, '2025-11-27', 'vitamin', 3, 17.288, 1000.000, 'mg', '2025-11-27 05:51:50.515458-08');
INSERT INTO public.usernutrienttracking VALUES (1406, 3, '2025-11-27', 'vitamin', 11, 34.575, 1000.000, 'µg', '2025-11-27 05:51:50.519026-08');
INSERT INTO public.usernutrienttracking VALUES (1407, 3, '2025-11-27', 'vitamin', 4, 138.300, 1000.000, 'µg', '2025-11-27 05:51:50.519613-08');
INSERT INTO public.usernutrienttracking VALUES (1408, 3, '2025-11-27', 'vitamin', 6, 1.383, 1000.000, 'mg', '2025-11-27 05:51:50.520221-08');
INSERT INTO public.usernutrienttracking VALUES (1409, 3, '2025-11-27', 'vitamin', 8, 18.440, 1000.000, 'mg', '2025-11-27 05:51:50.520746-08');
INSERT INTO public.usernutrienttracking VALUES (1410, 3, '2025-11-27', 'vitamin', 10, 1.498, 1000.000, 'mg', '2025-11-27 05:51:50.521297-08');
INSERT INTO public.usernutrienttracking VALUES (1411, 3, '2025-11-27', 'vitamin', 13, 2.766, 1000.000, 'µg', '2025-11-27 05:51:50.521827-08');
INSERT INTO public.usernutrienttracking VALUES (1412, 3, '2025-11-27', 'vitamin', 2, 691.500, 1000.000, 'IU', '2025-11-27 05:51:50.522428-08');
INSERT INTO public.usernutrienttracking VALUES (1413, 3, '2025-11-27', 'vitamin', 7, 1.498, 1000.000, 'mg', '2025-11-27 05:51:50.5232-08');
INSERT INTO public.usernutrienttracking VALUES (1414, 3, '2025-11-27', 'vitamin', 5, 103.725, 1000.000, 'mg', '2025-11-27 05:51:50.523836-08');
INSERT INTO public.usernutrienttracking VALUES (1415, 3, '2025-11-27', 'vitamin', 1, 1037.250, 1000.000, 'µg', '2025-11-27 05:51:50.524374-08');
INSERT INTO public.usernutrienttracking VALUES (1416, 3, '2025-11-27', 'vitamin', 9, 5.763, 1000.000, 'mg', '2025-11-27 05:51:50.52501-08');
INSERT INTO public.usernutrienttracking VALUES (1417, 3, '2025-11-27', 'vitamin', 12, 461.000, 1000.000, 'µg', '2025-11-27 05:51:50.525891-08');
INSERT INTO public.usernutrienttracking VALUES (1418, 3, '2025-11-27', 'mineral', 5, 1649.250, 1000.000, 'mg', '2025-11-27 05:51:50.526438-08');
INSERT INTO public.usernutrienttracking VALUES (1419, 3, '2025-11-27', 'mineral', 9, 2.529, 1000.000, 'mg', '2025-11-27 05:51:50.526915-08');
INSERT INTO public.usernutrienttracking VALUES (1420, 3, '2025-11-27', 'mineral', 6, 8.796, 1000.000, 'mg', '2025-11-27 05:51:50.527385-08');
INSERT INTO public.usernutrienttracking VALUES (1421, 3, '2025-11-27', 'mineral', 14, 3.299, 1000.000, 'mg', '2025-11-27 05:51:50.527866-08');
INSERT INTO public.usernutrienttracking VALUES (1422, 3, '2025-11-27', 'mineral', 2, 769.650, 1000.000, 'mg', '2025-11-27 05:51:50.528343-08');
INSERT INTO public.usernutrienttracking VALUES (1423, 3, '2025-11-27', 'mineral', 1, 1099.500, 1000.000, 'mg', '2025-11-27 05:51:50.528782-08');
INSERT INTO public.usernutrienttracking VALUES (1424, 3, '2025-11-27', 'mineral', 13, 49.478, 1000.000, 'µg', '2025-11-27 05:51:50.529156-08');
INSERT INTO public.usernutrienttracking VALUES (1425, 3, '2025-11-27', 'mineral', 10, 164.925, 1000.000, 'µg', '2025-11-27 05:51:50.529519-08');
INSERT INTO public.usernutrienttracking VALUES (1426, 3, '2025-11-27', 'mineral', 4, 3738.300, 1000.000, 'mg', '2025-11-27 05:51:50.529907-08');
INSERT INTO public.usernutrienttracking VALUES (1427, 3, '2025-11-27', 'mineral', 7, 12.095, 1000.000, 'mg', '2025-11-27 05:51:50.530266-08');
INSERT INTO public.usernutrienttracking VALUES (1428, 3, '2025-11-27', 'mineral', 11, 60.473, 1000.000, 'µg', '2025-11-27 05:51:50.530618-08');
INSERT INTO public.usernutrienttracking VALUES (1429, 3, '2025-11-27', 'mineral', 3, 439.800, 1000.000, 'mg', '2025-11-27 05:51:50.533334-08');
INSERT INTO public.usernutrienttracking VALUES (1430, 3, '2025-11-27', 'mineral', 8, 989.550, 1000.000, 'mg', '2025-11-27 05:51:50.533938-08');
INSERT INTO public.usernutrienttracking VALUES (1431, 3, '2025-11-27', 'mineral', 12, 38.483, 1000.000, 'µg', '2025-11-27 05:51:50.534461-08');
INSERT INTO public.usernutrienttracking VALUES (1432, 3, '2025-11-27', 'amino_acid', 6, 1756.560, 1000.000, 'mg', '2025-11-27 05:51:50.53497-08');
INSERT INTO public.usernutrienttracking VALUES (1433, 3, '2025-11-27', 'amino_acid', 8, 1013.400, 1000.000, 'mg', '2025-11-27 05:51:50.535431-08');
INSERT INTO public.usernutrienttracking VALUES (1434, 3, '2025-11-27', 'amino_acid', 7, 270.240, 1000.000, 'mg', '2025-11-27 05:51:50.535951-08');
INSERT INTO public.usernutrienttracking VALUES (1435, 3, '2025-11-27', 'amino_acid', 2, 1689.000, 1000.000, 'mg', '2025-11-27 05:51:50.536394-08');
INSERT INTO public.usernutrienttracking VALUES (1436, 3, '2025-11-27', 'amino_acid', 4, 2026.800, 1000.000, 'mg', '2025-11-27 05:51:50.5369-08');
INSERT INTO public.usernutrienttracking VALUES (1437, 3, '2025-11-27', 'amino_acid', 1, 1283.640, 1000.000, 'mg', '2025-11-27 05:51:50.53746-08');
INSERT INTO public.usernutrienttracking VALUES (1438, 3, '2025-11-27', 'amino_acid', 3, 945.840, 1000.000, 'mg', '2025-11-27 05:51:50.538111-08');
INSERT INTO public.usernutrienttracking VALUES (1439, 3, '2025-11-27', 'amino_acid', 9, 2837.520, 1000.000, 'mg', '2025-11-27 05:51:50.538665-08');
INSERT INTO public.usernutrienttracking VALUES (1440, 3, '2025-11-27', 'amino_acid', 5, 1013.400, 1000.000, 'mg', '2025-11-27 05:51:50.539146-08');
INSERT INTO public.usernutrienttracking VALUES (1441, 3, '2025-11-27', 'fiber', 1, 10.730, 0.000, 'g', '2025-11-27 05:51:50.539671-08');
INSERT INTO public.usernutrienttracking VALUES (1442, 3, '2025-11-27', 'fiber', 2, 3.219, 0.000, 'g', '2025-11-27 05:51:50.540191-08');
INSERT INTO public.usernutrienttracking VALUES (1443, 3, '2025-11-27', 'fiber', 5, 16.095, 0.000, 'g', '2025-11-27 05:51:50.540747-08');
INSERT INTO public.usernutrienttracking VALUES (1444, 3, '2025-11-27', 'fiber', 6, 26.825, 3000.000, 'g', '2025-11-27 05:51:50.541884-08');
INSERT INTO public.usernutrienttracking VALUES (1445, 3, '2025-11-27', 'fiber', 7, 7.511, 0.000, 'g', '2025-11-27 05:51:50.543493-08');
INSERT INTO public.usernutrienttracking VALUES (1446, 3, '2025-11-27', 'fatty_acid', 1, 0.000, 0.000, 'g', '2025-11-27 05:51:50.544183-08');
INSERT INTO public.usernutrienttracking VALUES (1447, 3, '2025-11-27', 'fatty_acid', 2, 0.000, 0.000, 'g', '2025-11-27 05:51:50.544667-08');
INSERT INTO public.usernutrienttracking VALUES (1448, 3, '2025-11-27', 'fatty_acid', 3, 0.000, 0.000, 'g', '2025-11-27 05:51:50.545051-08');
INSERT INTO public.usernutrienttracking VALUES (1449, 3, '2025-11-27', 'fatty_acid', 4, 376.000, 2000000.000, 'g', '2025-11-27 05:51:50.545407-08');
INSERT INTO public.usernutrienttracking VALUES (1450, 3, '2025-11-27', 'fatty_acid', 5, 19.244, 0.000, 'g', '2025-11-27 05:51:50.546051-08');
INSERT INTO public.usernutrienttracking VALUES (1451, 3, '2025-11-27', 'fatty_acid', 6, 322.000, 0.000, 'mg', '2025-11-27 05:51:50.54668-08');
INSERT INTO public.usernutrienttracking VALUES (1452, 3, '2025-11-27', 'fatty_acid', 7, 115.463, 1000.000, 'g', '2025-11-27 05:51:50.547571-08');
INSERT INTO public.usernutrienttracking VALUES (1453, 3, '2025-11-27', 'fatty_acid', 15, 28.866, 3000.000, 'g', '2025-11-27 05:51:50.549786-08');
INSERT INTO public.usernutrienttracking VALUES (1454, 3, '2025-11-27', 'fatty_acid', 16, 3.849, 0.000, 'g', '2025-11-27 05:51:50.550576-08');
INSERT INTO public.usernutrienttracking VALUES (1455, 3, '2025-11-27', 'fatty_acid', 17, 48.110, 1000.000, 'g', '2025-11-27 05:51:50.551164-08');
INSERT INTO public.usernutrienttracking VALUES (1456, 3, '2025-11-27', 'fatty_acid', 18, 38.488, 0.000, 'g', '2025-11-27 05:51:50.551721-08');
INSERT INTO public.usernutrienttracking VALUES (1457, 3, '2025-11-29', 'vitamin', 7, 1.246, 1000.000, 'mg', '2025-11-29 01:34:58.961691-08');
INSERT INTO public.usernutrienttracking VALUES (1458, 3, '2025-11-29', 'vitamin', 6, 1.246, 1000.000, 'mg', '2025-11-29 01:34:58.968099-08');
INSERT INTO public.usernutrienttracking VALUES (1459, 3, '2025-11-29', 'vitamin', 9, 5.663, 1000.000, 'mg', '2025-11-29 01:34:58.970682-08');
INSERT INTO public.usernutrienttracking VALUES (1460, 3, '2025-11-29', 'vitamin', 3, 16.988, 1000.000, 'mg', '2025-11-29 01:34:58.971636-08');
INSERT INTO public.usernutrienttracking VALUES (1461, 3, '2025-11-29', 'vitamin', 4, 101.925, 1000.000, 'µg', '2025-11-29 01:34:58.972335-08');
INSERT INTO public.usernutrienttracking VALUES (1462, 3, '2025-11-29', 'vitamin', 5, 84.938, 1000.000, 'mg', '2025-11-29 01:34:58.972899-08');
INSERT INTO public.usernutrienttracking VALUES (1463, 3, '2025-11-29', 'vitamin', 1, 792.750, 1000.000, 'µg', '2025-11-29 01:34:58.973473-08');
INSERT INTO public.usernutrienttracking VALUES (1464, 3, '2025-11-29', 'vitamin', 13, 2.718, 1000.000, 'µg', '2025-11-29 01:34:58.974256-08');
INSERT INTO public.usernutrienttracking VALUES (1465, 3, '2025-11-29', 'vitamin', 11, 33.975, 1000.000, 'µg', '2025-11-29 01:34:58.975319-08');
INSERT INTO public.usernutrienttracking VALUES (1466, 3, '2025-11-29', 'vitamin', 2, 679.500, 1000.000, 'IU', '2025-11-29 01:34:58.976808-08');
INSERT INTO public.usernutrienttracking VALUES (1467, 3, '2025-11-29', 'vitamin', 12, 453.000, 1000.000, 'µg', '2025-11-29 01:34:58.978493-08');
INSERT INTO public.usernutrienttracking VALUES (1468, 3, '2025-11-29', 'vitamin', 8, 15.855, 1000.000, 'mg', '2025-11-29 01:34:58.979407-08');
INSERT INTO public.usernutrienttracking VALUES (1469, 3, '2025-11-29', 'vitamin', 10, 1.472, 1000.000, 'mg', '2025-11-29 01:34:58.980392-08');
INSERT INTO public.usernutrienttracking VALUES (1470, 3, '2025-11-29', 'mineral', 2, 755.650, 1000.000, 'mg', '2025-11-29 01:34:58.98185-08');
INSERT INTO public.usernutrienttracking VALUES (1471, 3, '2025-11-29', 'mineral', 3, 334.645, 1000.000, 'mg', '2025-11-29 01:34:58.98417-08');
INSERT INTO public.usernutrienttracking VALUES (1472, 3, '2025-11-29', 'mineral', 9, 1.943, 1000.000, 'mg', '2025-11-29 01:34:58.987862-08');
INSERT INTO public.usernutrienttracking VALUES (1473, 3, '2025-11-29', 'mineral', 14, 3.239, 1000.000, 'mg', '2025-11-29 01:34:58.989897-08');
INSERT INTO public.usernutrienttracking VALUES (1474, 3, '2025-11-29', 'mineral', 7, 8.636, 1000.000, 'mg', '2025-11-29 01:34:58.99068-08');
INSERT INTO public.usernutrienttracking VALUES (1475, 3, '2025-11-29', 'mineral', 6, 19.431, 1000.000, 'mg', '2025-11-29 01:34:58.991296-08');
INSERT INTO public.usernutrienttracking VALUES (1476, 3, '2025-11-29', 'mineral', 8, 971.550, 1000.000, 'mg', '2025-11-29 01:34:58.992048-08');
INSERT INTO public.usernutrienttracking VALUES (1477, 3, '2025-11-29', 'mineral', 4, 2806.700, 1000.000, 'mg', '2025-11-29 01:34:58.992733-08');
INSERT INTO public.usernutrienttracking VALUES (1478, 3, '2025-11-29', 'mineral', 10, 161.925, 1000.000, 'µg', '2025-11-29 01:34:58.99382-08');
INSERT INTO public.usernutrienttracking VALUES (1479, 3, '2025-11-29', 'mineral', 1, 1079.500, 1000.000, 'mg', '2025-11-29 01:34:58.994489-08');
INSERT INTO public.usernutrienttracking VALUES (1480, 3, '2025-11-29', 'mineral', 5, 1619.250, 1000.000, 'mg', '2025-11-29 01:34:58.995071-08');
INSERT INTO public.usernutrienttracking VALUES (1481, 3, '2025-11-29', 'mineral', 11, 59.373, 1000.000, 'µg', '2025-11-29 01:34:58.995711-08');
INSERT INTO public.usernutrienttracking VALUES (1482, 3, '2025-11-29', 'mineral', 12, 37.783, 1000.000, 'µg', '2025-11-29 01:34:58.996363-08');
INSERT INTO public.usernutrienttracking VALUES (1483, 3, '2025-11-29', 'mineral', 13, 48.578, 1000.000, 'µg', '2025-11-29 01:34:58.997309-08');
INSERT INTO public.usernutrienttracking VALUES (1484, 3, '2025-11-29', 'amino_acid', 5, 995.400, 1000.000, 'mg', '2025-11-29 01:34:58.999456-08');
INSERT INTO public.usernutrienttracking VALUES (1485, 3, '2025-11-29', 'amino_acid', 3, 929.040, 1000.000, 'mg', '2025-11-29 01:34:59.000059-08');
INSERT INTO public.usernutrienttracking VALUES (1486, 3, '2025-11-29', 'amino_acid', 2, 1659.000, 1000.000, 'mg', '2025-11-29 01:34:59.000522-08');
INSERT INTO public.usernutrienttracking VALUES (1487, 3, '2025-11-29', 'amino_acid', 6, 1725.360, 1000.000, 'mg', '2025-11-29 01:34:59.001102-08');
INSERT INTO public.usernutrienttracking VALUES (1488, 3, '2025-11-29', 'amino_acid', 8, 995.400, 1000.000, 'mg', '2025-11-29 01:34:59.001589-08');
INSERT INTO public.usernutrienttracking VALUES (1489, 3, '2025-11-29', 'amino_acid', 1, 1260.840, 1000.000, 'mg', '2025-11-29 01:34:59.002076-08');
INSERT INTO public.usernutrienttracking VALUES (1490, 3, '2025-11-29', 'amino_acid', 9, 2787.120, 1000.000, 'mg', '2025-11-29 01:34:59.002494-08');
INSERT INTO public.usernutrienttracking VALUES (1491, 3, '2025-11-29', 'amino_acid', 7, 265.440, 1000.000, 'mg', '2025-11-29 01:34:59.0029-08');
INSERT INTO public.usernutrienttracking VALUES (1492, 3, '2025-11-29', 'amino_acid', 4, 1990.800, 1000.000, 'mg', '2025-11-29 01:34:59.003289-08');
INSERT INTO public.usernutrienttracking VALUES (1493, 3, '2025-11-29', 'fiber', 1, 10.530, 0.000, 'g', '2025-11-29 01:34:59.003656-08');
INSERT INTO public.usernutrienttracking VALUES (1494, 3, '2025-11-29', 'fiber', 2, 3.159, 0.000, 'g', '2025-11-29 01:34:59.004038-08');
INSERT INTO public.usernutrienttracking VALUES (1495, 3, '2025-11-29', 'fiber', 5, 15.795, 0.000, 'g', '2025-11-29 01:34:59.004443-08');
INSERT INTO public.usernutrienttracking VALUES (1496, 3, '2025-11-29', 'fiber', 6, 26.325, 3000.000, 'g', '2025-11-29 01:34:59.00493-08');
INSERT INTO public.usernutrienttracking VALUES (1497, 3, '2025-11-29', 'fiber', 7, 7.371, 0.000, 'g', '2025-11-29 01:34:59.005425-08');
INSERT INTO public.usernutrienttracking VALUES (1498, 3, '2025-11-29', 'fatty_acid', 1, 0.000, 0.000, 'g', '2025-11-29 01:34:59.005819-08');
INSERT INTO public.usernutrienttracking VALUES (1499, 3, '2025-11-29', 'fatty_acid', 2, 0.000, 0.000, 'g', '2025-11-29 01:34:59.006229-08');
INSERT INTO public.usernutrienttracking VALUES (1500, 3, '2025-11-29', 'fatty_acid', 3, 0.000, 0.000, 'g', '2025-11-29 01:34:59.006591-08');
INSERT INTO public.usernutrienttracking VALUES (1501, 3, '2025-11-29', 'fatty_acid', 4, 263.000, 2000000.000, 'g', '2025-11-29 01:34:59.006955-08');
INSERT INTO public.usernutrienttracking VALUES (1502, 3, '2025-11-29', 'fatty_acid', 5, 15.510, 0.000, 'g', '2025-11-29 01:34:59.007309-08');
INSERT INTO public.usernutrienttracking VALUES (1503, 3, '2025-11-29', 'fatty_acid', 6, 316.000, 0.000, 'mg', '2025-11-29 01:34:59.00766-08');
INSERT INTO public.usernutrienttracking VALUES (1504, 3, '2025-11-29', 'fatty_acid', 7, 93.059, 1000.000, 'g', '2025-11-29 01:34:59.008019-08');
INSERT INTO public.usernutrienttracking VALUES (1505, 3, '2025-11-29', 'fatty_acid', 15, 23.265, 3000.000, 'g', '2025-11-29 01:34:59.008425-08');
INSERT INTO public.usernutrienttracking VALUES (1506, 3, '2025-11-29', 'fatty_acid', 16, 3.102, 0.000, 'g', '2025-11-29 01:34:59.008958-08');
INSERT INTO public.usernutrienttracking VALUES (1507, 3, '2025-11-29', 'fatty_acid', 17, 38.775, 1000.000, 'g', '2025-11-29 01:34:59.009478-08');
INSERT INTO public.usernutrienttracking VALUES (1508, 3, '2025-11-29', 'fatty_acid', 18, 31.020, 0.000, 'g', '2025-11-29 01:34:59.009893-08');


--
-- TOC entry 6396 (class 0 OID 21107)
-- Dependencies: 221
-- Data for Name: userprofile; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.userprofile VALUES (2, 'vận động nhẹ', 'chay', 'Sữa bò', 'Duy trì', NULL, 42.00, 1.38, 1164.00, 1601.00, 1601.00, 100.00, 44.00, 200.00, 1638.80);
INSERT INTO public.userprofile VALUES (1, 'vận động nhẹ', 'clean', 'Sữa bò', 'Duy trì', NULL, 60.00, 1.38, 1593.00, 2190.00, 2190.00, 137.00, 61.00, 274.00, 2244.00);
INSERT INTO public.userprofile VALUES (4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.userprofile VALUES (3, 'rất năng động', 'clean', 'Sữa bò', 'Duy trì', NULL, 60.00, 1.73, 1464.00, 2525.00, 2525.00, 158.00, 70.00, 316.00, 2684.00);


--
-- TOC entry 6509 (class 0 OID 22559)
-- Dependencies: 340
-- Data for Name: usersecurity; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usersecurity VALUES (2, false, NULL, 5, 0, '2025-11-23 20:43:44.66746-08');
INSERT INTO public.usersecurity VALUES (4, false, NULL, 5, 0, '2025-11-27 04:52:30.283885-08');
INSERT INTO public.usersecurity VALUES (1, false, NULL, 5, 0, '2025-11-19 07:19:23.784325-08');
INSERT INTO public.usersecurity VALUES (3, false, NULL, 5, 0, '2025-11-24 05:24:16.617351-08');


--
-- TOC entry 6397 (class 0 OID 21120)
-- Dependencies: 222
-- Data for Name: usersetting; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usersetting VALUES (2, 'light', 'vi', 'medium', 'metric', false, 'auto', NULL, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, true, 'medium', 25.00, 35.00, 10.00, 30.00, false, '07:00:00', '11:00:00', '13:00:00', '18:00:00');
INSERT INTO public.usersetting VALUES (1, 'light', 'vi', 'medium', 'metric', false, 'auto', NULL, false, false, 'Cà Mau', '2025-11-21 08:53:34.988', '{"dt": 1763689835, "id": 1586443, "cod": 200, "sys": {"sunset": 1763721335, "country": "VN", "sunrise": 1763679313}, "base": "stations", "main": {"temp": 24.68, "humidity": 81, "pressure": 1013, "temp_max": 24.68, "temp_min": 24.68, "sea_level": 1013, "feels_like": 25.32, "grnd_level": 1013}, "name": "Ca Mau", "wind": {"deg": 28, "gust": 8.01, "speed": 4}, "coord": {"lat": 9.1792, "lon": 105.1458}, "clouds": {"all": 100}, "weather": [{"id": 804, "icon": "04d", "main": "Clouds", "description": "mây đen u ám"}], "timezone": 25200, "visibility": 10000}', NULL, NULL, NULL, NULL, NULL, 0, false, 'medium', 25.00, 35.00, 10.00, 30.00, false, '07:00:00', '11:00:00', '13:00:00', '18:00:00');
INSERT INTO public.usersetting VALUES (4, 'light', 'vi', 'medium', 'metric', false, 'auto', NULL, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, true, 'medium', 25.00, 35.00, 10.00, 30.00, false, '07:00:00', '11:00:00', '13:00:00', '18:00:00');
INSERT INTO public.usersetting VALUES (3, 'light', 'vi', 'medium', 'metric', false, 'auto', NULL, false, false, 'Cà Mau', '2025-11-29 16:37:16.806', '{"dt": 1764408921, "id": 1586443, "cod": 200, "sys": {"sunset": 1764412614, "country": "VN", "sunrise": 1764370727}, "base": "stations", "main": {"temp": 26.26, "humidity": 67, "pressure": 1008, "temp_max": 26.26, "temp_min": 26.26, "sea_level": 1008, "feels_like": 26.26, "grnd_level": 1008}, "name": "Ca Mau", "wind": {"deg": 307, "gust": 5.99, "speed": 3.27}, "coord": {"lat": 9.1792, "lon": 105.1458}, "clouds": {"all": 85}, "weather": [{"id": 804, "icon": "04d", "main": "Clouds", "description": "mây đen u ám"}], "timezone": 25200, "visibility": 10000}', NULL, NULL, NULL, NULL, NULL, 0, false, 'low', 25.00, 35.00, 10.00, 30.00, false, '07:00:00', '11:00:00', '13:00:00', '18:00:00');


--
-- TOC entry 6428 (class 0 OID 21499)
-- Dependencies: 253
-- Data for Name: uservitaminrequirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.uservitaminrequirement VALUES (4, 1, 900.000, 1.02, 918.000, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 2, 600.000, 1.02, 612.000, 'IU', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 3, 15.000, 1.02, 15.300, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 4, 120.000, 1.02, 122.400, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 5, 90.000, 1.02, 91.800, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 6, 1.200, 1.02, 1.224, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 7, 1.300, 1.02, 1.326, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 8, 16.000, 1.02, 16.320, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 9, 5.000, 1.02, 5.100, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 10, 1.300, 1.02, 1.326, 'mg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 11, 30.000, 1.02, 30.600, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 12, 400.000, 1.02, 408.000, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (4, 13, 2.400, 1.02, 2.448, 'µg', '2025-11-27 04:52:23.478157');
INSERT INTO public.uservitaminrequirement VALUES (2, 1, 700.000, 1.0450, 731.500, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 2, 600.000, 1.0450, 627.000, 'IU', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 3, 15.000, 1.0450, 15.675, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 4, 90.000, 1.0450, 94.050, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 5, 75.000, 1.0450, 78.375, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 6, 1.100, 1.0450, 1.150, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 7, 1.100, 1.0450, 1.150, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 8, 14.000, 1.0450, 14.630, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 9, 5.000, 1.0450, 5.225, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 10, 1.300, 1.0450, 1.359, 'mg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 11, 30.000, 1.0450, 31.350, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 12, 400.000, 1.0450, 418.000, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (2, 13, 2.400, 1.0450, 2.508, 'µg', '2025-11-23 20:44:04.63164');
INSERT INTO public.uservitaminrequirement VALUES (3, 1, 700.000, 1.1325, 792.750, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 2, 600.000, 1.1325, 679.500, 'IU', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 3, 15.000, 1.1325, 16.988, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 4, 90.000, 1.1325, 101.925, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 5, 75.000, 1.1325, 84.938, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 6, 1.100, 1.1325, 1.246, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 7, 1.100, 1.1325, 1.246, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 8, 14.000, 1.1325, 15.855, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 9, 5.000, 1.1325, 5.663, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 10, 1.300, 1.1325, 1.472, 'mg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 11, 30.000, 1.1325, 33.975, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 12, 400.000, 1.1325, 453.000, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (3, 13, 2.400, 1.1325, 2.718, 'µg', '2025-11-29 01:32:36.387799');
INSERT INTO public.uservitaminrequirement VALUES (1, 1, 900.000, 1.0650, 958.500, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 2, 600.000, 1.0650, 639.000, 'IU', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 3, 15.000, 1.0650, 15.975, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 4, 120.000, 1.0650, 127.800, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 5, 90.000, 1.0650, 95.850, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 6, 1.200, 1.0650, 1.278, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 7, 1.300, 1.0650, 1.385, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 8, 16.000, 1.0650, 17.040, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 9, 5.000, 1.0650, 5.325, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 10, 1.300, 1.0650, 1.385, 'mg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 11, 30.000, 1.0650, 31.950, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 12, 400.000, 1.0650, 426.000, 'µg', '2025-11-24 22:52:15.990562');
INSERT INTO public.uservitaminrequirement VALUES (1, 13, 2.400, 1.0650, 2.556, 'µg', '2025-11-24 22:52:15.990562');


--
-- TOC entry 6427 (class 0 OID 21475)
-- Dependencies: 252
-- Data for Name: vitamin; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.vitamin VALUES (1, 'VITA', 'Vitamin A', 'Retinol and provitamin A compounds', 'µg', 700.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (2, 'VITD', 'Vitamin D', 'Supports calcium metabolism and bone health', 'IU', 600.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (3, 'VITE', 'Vitamin E', 'Antioxidant (tocopherols)', 'mg', 15.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (4, 'VITK', 'Vitamin K', 'Needed for blood clotting (K1/K2)', 'µg', 120.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (5, 'VITC', 'Vitamin C', 'Ascorbic acid, antioxidant', 'mg', 75.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (6, 'VITB1', 'Vitamin B1 (Thiamine)', 'Supports energy metabolism', 'mg', 1.200, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (7, 'VITB2', 'Vitamin B2 (Riboflavin)', 'Important for energy production', 'mg', 1.300, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (8, 'VITB3', 'Vitamin B3 (Niacin)', 'Supports metabolism and skin health', 'mg', 16.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (9, 'VITB5', 'Vitamin B5 (Pantothenic acid)', 'Component of coenzyme A', 'mg', 5.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (10, 'VITB6', 'Vitamin B6 (Pyridoxine)', 'Supports metabolism and brain health', 'mg', 1.300, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (11, 'VITB7', 'Vitamin B7 (Biotin)', 'Plays a role in macronutrient metabolism', 'µg', 30.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (12, 'VITB9', 'Vitamin B9 (Folate)', 'Key for cell division and DNA synthesis', 'µg', 400.000, '2025-11-19 06:57:52.829613', NULL);
INSERT INTO public.vitamin VALUES (13, 'VITB12', 'Vitamin B12 (Cobalamin)', 'Important for nerve function and blood formation', 'µg', 2.400, '2025-11-19 06:57:52.829613', NULL);


--
-- TOC entry 6538 (class 0 OID 23123)
-- Dependencies: 373
-- Data for Name: vitaminnutrient; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.vitaminnutrient VALUES (1, 2, 12, 0.000, 1.000000, 'USDA VITD -> Vitamin D', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (2, 3, 13, 0.000, 1.000000, 'USDA VITE -> Vitamin E', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (3, 4, 14, 0.000, 1.000000, 'USDA VITK -> Vitamin K', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (4, 5, 15, 0.000, 1.000000, 'USDA VITC -> Vitamin C', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (5, 6, 16, 0.000, 1.000000, 'USDA VITB1 -> Vitamin B1', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (6, 7, 17, 0.000, 1.000000, 'USDA VITB2 -> Vitamin B2', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (7, 8, 18, 0.000, 1.000000, 'USDA VITB3 -> Vitamin B3', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (8, 9, 19, 0.000, 1.000000, 'USDA VITB5 -> Vitamin B5', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (9, 10, 20, 0.000, 1.000000, 'USDA VITB6 -> Vitamin B6', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (10, 11, 21, 0.000, 1.000000, 'USDA VITB7 -> Vitamin B7', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (11, 13, 23, 0.000, 1.000000, 'USDA VITB12 -> Vitamin B12', '2025-11-19 17:30:55.588284');
INSERT INTO public.vitaminnutrient VALUES (12, 1, 11, 0.000, 1.000000, 'Auto-mapped: VITA -> VITA', '2025-11-19 17:31:39.643042');
INSERT INTO public.vitaminnutrient VALUES (37, 12, 22, 0.000, 1.000000, 'Auto-mapped: VITB9 -> VITB9', '2025-11-19 17:31:39.666002');


--
-- TOC entry 6430 (class 0 OID 21526)
-- Dependencies: 255
-- Data for Name: vitaminrda; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.vitaminrda VALUES (1, 1, NULL, 0, 0, 400.000, 'µg', 'Adequate Intake (AI) for infants 0-6 months');
INSERT INTO public.vitaminrda VALUES (2, 1, NULL, 1, 1, 500.000, 'µg', 'AI for infants 7-12 months');
INSERT INTO public.vitaminrda VALUES (3, 1, NULL, 1, 3, 300.000, 'µg', 'RDA for children 1-3 years');
INSERT INTO public.vitaminrda VALUES (4, 1, NULL, 4, 8, 400.000, 'µg', 'RDA for children 4-8 years');
INSERT INTO public.vitaminrda VALUES (5, 1, 'male', 9, 13, 600.000, 'µg', 'RDA for males 9-13 years');
INSERT INTO public.vitaminrda VALUES (6, 1, 'male', 14, 18, 900.000, 'µg', 'RDA for males 14-18 years');
INSERT INTO public.vitaminrda VALUES (7, 1, 'male', 19, 50, 900.000, 'µg', 'RDA for adult males');
INSERT INTO public.vitaminrda VALUES (8, 1, 'male', 51, 120, 900.000, 'µg', 'RDA for males 51+ years');
INSERT INTO public.vitaminrda VALUES (9, 1, 'female', 9, 13, 600.000, 'µg', 'RDA for females 9-13 years');
INSERT INTO public.vitaminrda VALUES (10, 1, 'female', 14, 18, 700.000, 'µg', 'RDA for females 14-18 years');
INSERT INTO public.vitaminrda VALUES (11, 1, 'female', 19, 50, 700.000, 'µg', 'RDA for adult females');
INSERT INTO public.vitaminrda VALUES (12, 1, 'female', 51, 120, 700.000, 'µg', 'RDA for females 51+ years');
INSERT INTO public.vitaminrda VALUES (13, 2, NULL, 0, 1, 400.000, 'IU', 'AI for infants');
INSERT INTO public.vitaminrda VALUES (14, 2, NULL, 1, 18, 600.000, 'IU', 'RDA for children and adolescents');
INSERT INTO public.vitaminrda VALUES (15, 2, NULL, 19, 70, 600.000, 'IU', 'RDA for adults');
INSERT INTO public.vitaminrda VALUES (16, 2, NULL, 71, 120, 800.000, 'IU', 'RDA for elderly');
INSERT INTO public.vitaminrda VALUES (17, 3, NULL, 0, 0, 4.000, 'mg', 'AI for infants 0-6 months');
INSERT INTO public.vitaminrda VALUES (18, 3, NULL, 1, 1, 5.000, 'mg', 'AI for infants 7-12 months');
INSERT INTO public.vitaminrda VALUES (19, 3, NULL, 1, 3, 6.000, 'mg', 'RDA for children 1-3 years');
INSERT INTO public.vitaminrda VALUES (20, 3, NULL, 4, 8, 7.000, 'mg', 'RDA for children 4-8 years');
INSERT INTO public.vitaminrda VALUES (21, 3, NULL, 9, 18, 11.000, 'mg', 'RDA for adolescents');
INSERT INTO public.vitaminrda VALUES (22, 3, NULL, 19, 120, 15.000, 'mg', 'RDA for adults');
INSERT INTO public.vitaminrda VALUES (23, 4, NULL, 0, 0, 2.000, 'µg', 'AI for infants 0-6 months');
INSERT INTO public.vitaminrda VALUES (24, 4, NULL, 1, 1, 2.500, 'µg', 'AI for infants 7-12 months');
INSERT INTO public.vitaminrda VALUES (25, 4, NULL, 1, 3, 30.000, 'µg', 'AI for children 1-3 years');
INSERT INTO public.vitaminrda VALUES (26, 4, NULL, 4, 8, 55.000, 'µg', 'AI for children 4-8 years');
INSERT INTO public.vitaminrda VALUES (27, 4, 'male', 9, 13, 60.000, 'µg', 'AI for males 9-13 years');
INSERT INTO public.vitaminrda VALUES (28, 4, 'male', 14, 18, 75.000, 'µg', 'AI for males 14-18 years');
INSERT INTO public.vitaminrda VALUES (29, 4, 'male', 19, 120, 120.000, 'µg', 'AI for adult males');
INSERT INTO public.vitaminrda VALUES (30, 4, 'female', 9, 13, 60.000, 'µg', 'AI for females 9-13 years');
INSERT INTO public.vitaminrda VALUES (31, 4, 'female', 14, 18, 75.000, 'µg', 'AI for females 14-18 years');
INSERT INTO public.vitaminrda VALUES (32, 4, 'female', 19, 120, 90.000, 'µg', 'AI for adult females');
INSERT INTO public.vitaminrda VALUES (33, 5, NULL, 0, 0, 40.000, 'mg', 'AI for infants 0-6 months');
INSERT INTO public.vitaminrda VALUES (34, 5, NULL, 1, 1, 50.000, 'mg', 'AI for infants 7-12 months');
INSERT INTO public.vitaminrda VALUES (35, 5, NULL, 1, 3, 15.000, 'mg', 'RDA for children 1-3 years');
INSERT INTO public.vitaminrda VALUES (36, 5, NULL, 4, 8, 25.000, 'mg', 'RDA for children 4-8 years');
INSERT INTO public.vitaminrda VALUES (37, 5, NULL, 9, 13, 45.000, 'mg', 'RDA for children 9-13 years');
INSERT INTO public.vitaminrda VALUES (38, 5, 'male', 14, 18, 75.000, 'mg', 'RDA for males 14-18 years');
INSERT INTO public.vitaminrda VALUES (39, 5, 'male', 19, 120, 90.000, 'mg', 'RDA for adult males');
INSERT INTO public.vitaminrda VALUES (40, 5, 'female', 14, 18, 65.000, 'mg', 'RDA for females 14-18 years');
INSERT INTO public.vitaminrda VALUES (41, 5, 'female', 19, 120, 75.000, 'mg', 'RDA for adult females');
INSERT INTO public.vitaminrda VALUES (42, 6, 'male', 19, 120, 1.200, 'mg', 'RDA for adult males');
INSERT INTO public.vitaminrda VALUES (43, 6, 'female', 19, 120, 1.100, 'mg', 'RDA for adult females');
INSERT INTO public.vitaminrda VALUES (44, 7, 'male', 19, 120, 1.300, 'mg', 'RDA for adult males');
INSERT INTO public.vitaminrda VALUES (45, 7, 'female', 19, 120, 1.100, 'mg', 'RDA for adult females');
INSERT INTO public.vitaminrda VALUES (46, 8, 'male', 19, 120, 16.000, 'mg', 'RDA for adult males');
INSERT INTO public.vitaminrda VALUES (47, 8, 'female', 19, 120, 14.000, 'mg', 'RDA for adult females');
INSERT INTO public.vitaminrda VALUES (48, 10, 'male', 19, 50, 1.300, 'mg', 'RDA for adult males 19-50');
INSERT INTO public.vitaminrda VALUES (49, 10, 'male', 51, 120, 1.700, 'mg', 'RDA for males 51+');
INSERT INTO public.vitaminrda VALUES (50, 10, 'female', 19, 50, 1.300, 'mg', 'RDA for adult females 19-50');
INSERT INTO public.vitaminrda VALUES (51, 10, 'female', 51, 120, 1.500, 'mg', 'RDA for females 51+');
INSERT INTO public.vitaminrda VALUES (52, 12, NULL, 19, 120, 400.000, 'µg', 'RDA for adults');
INSERT INTO public.vitaminrda VALUES (53, 13, NULL, 19, 120, 2.400, 'µg', 'RDA for adults');
INSERT INTO public.vitaminrda VALUES (107, 1, 'any', 19, 50, 700.000, 'µg', NULL);
INSERT INTO public.vitaminrda VALUES (108, 2, 'any', 19, 50, 600.000, 'IU', NULL);
INSERT INTO public.vitaminrda VALUES (109, 3, 'any', 19, 50, 15.000, 'mg', NULL);
INSERT INTO public.vitaminrda VALUES (110, 4, 'any', 19, 50, 120.000, 'µg', NULL);
INSERT INTO public.vitaminrda VALUES (111, 5, 'any', 19, 50, 75.000, 'mg', NULL);
INSERT INTO public.vitaminrda VALUES (112, 6, 'any', 19, 50, 1.200, 'mg', NULL);
INSERT INTO public.vitaminrda VALUES (113, 7, 'any', 19, 50, 1.300, 'mg', NULL);
INSERT INTO public.vitaminrda VALUES (114, 8, 'any', 19, 50, 16.000, 'mg', NULL);
INSERT INTO public.vitaminrda VALUES (115, 9, 'any', 19, 50, 5.000, 'mg', NULL);
INSERT INTO public.vitaminrda VALUES (116, 10, 'any', 19, 50, 1.300, 'mg', NULL);
INSERT INTO public.vitaminrda VALUES (117, 11, 'any', 19, 50, 30.000, 'µg', NULL);
INSERT INTO public.vitaminrda VALUES (118, 12, 'any', 19, 50, 400.000, 'µg', NULL);
INSERT INTO public.vitaminrda VALUES (119, 13, 'any', 19, 50, 2.400, 'µg', NULL);


--
-- TOC entry 6532 (class 0 OID 22922)
-- Dependencies: 367
-- Data for Name: waterlog; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 6708 (class 0 OID 0)
-- Dependencies: 219
-- Name: User_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."User_user_id_seq"', 4, true);


--
-- TOC entry 6709 (class 0 OID 0)
-- Dependencies: 225
-- Name: admin_admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_admin_id_seq', 2, true);


--
-- TOC entry 6710 (class 0 OID 0)
-- Dependencies: 365
-- Name: admin_verification_verification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_verification_verification_id_seq', 2, true);


--
-- TOC entry 6711 (class 0 OID 0)
-- Dependencies: 304
-- Name: adminconversation_admin_conversation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adminconversation_admin_conversation_id_seq', 4, true);


--
-- TOC entry 6712 (class 0 OID 0)
-- Dependencies: 306
-- Name: adminmessage_admin_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adminmessage_admin_message_id_seq', 7, true);


--
-- TOC entry 6713 (class 0 OID 0)
-- Dependencies: 277
-- Name: aminoacid_amino_acid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aminoacid_amino_acid_id_seq', 9, true);


--
-- TOC entry 6714 (class 0 OID 0)
-- Dependencies: 279
-- Name: aminorequirement_amino_requirement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aminorequirement_amino_requirement_id_seq', 54, true);


--
-- TOC entry 6715 (class 0 OID 0)
-- Dependencies: 298
-- Name: bodymeasurement_measurement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bodymeasurement_measurement_id_seq', 6, true);


--
-- TOC entry 6716 (class 0 OID 0)
-- Dependencies: 300
-- Name: chatbotconversation_conversation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chatbotconversation_conversation_id_seq', 4, true);


--
-- TOC entry 6717 (class 0 OID 0)
-- Dependencies: 302
-- Name: chatbotmessage_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chatbotmessage_message_id_seq', 6, true);


--
-- TOC entry 6718 (class 0 OID 0)
-- Dependencies: 397
-- Name: communitymessage_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.communitymessage_message_id_seq', 10, true);


--
-- TOC entry 6719 (class 0 OID 0)
-- Dependencies: 326
-- Name: conditioneffectlog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditioneffectlog_log_id_seq', 1, false);


--
-- TOC entry 6720 (class 0 OID 0)
-- Dependencies: 324
-- Name: conditionfoodrecommendation_recommendation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditionfoodrecommendation_recommendation_id_seq', 21, true);


--
-- TOC entry 6721 (class 0 OID 0)
-- Dependencies: 322
-- Name: conditionnutrienteffect_effect_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditionnutrienteffect_effect_id_seq', 90, true);


--
-- TOC entry 6722 (class 0 OID 0)
-- Dependencies: 245
-- Name: dailysummary_summary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dailysummary_summary_id_seq', 71, true);


--
-- TOC entry 6723 (class 0 OID 0)
-- Dependencies: 349
-- Name: dish_dish_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dish_dish_id_seq', 58, true);


--
-- TOC entry 6724 (class 0 OID 0)
-- Dependencies: 353
-- Name: dishimage_dish_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishimage_dish_image_id_seq', 1, false);


--
-- TOC entry 6725 (class 0 OID 0)
-- Dependencies: 351
-- Name: dishingredient_dish_ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishingredient_dish_ingredient_id_seq', 479, true);


--
-- TOC entry 6726 (class 0 OID 0)
-- Dependencies: 361
-- Name: dishnotification_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishnotification_notification_id_seq', 2, true);


--
-- TOC entry 6727 (class 0 OID 0)
-- Dependencies: 357
-- Name: dishnutrient_dish_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishnutrient_dish_nutrient_id_seq', 4196, true);


--
-- TOC entry 6728 (class 0 OID 0)
-- Dependencies: 355
-- Name: dishstatistics_stat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishstatistics_stat_id_seq', 1, false);


--
-- TOC entry 6729 (class 0 OID 0)
-- Dependencies: 378
-- Name: drink_drink_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drink_drink_id_seq', 57, true);


--
-- TOC entry 6730 (class 0 OID 0)
-- Dependencies: 380
-- Name: drinkingredient_drink_ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drinkingredient_drink_ingredient_id_seq', 138, true);


--
-- TOC entry 6731 (class 0 OID 0)
-- Dependencies: 382
-- Name: drinknutrient_drink_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drinknutrient_drink_nutrient_id_seq', 2396, true);


--
-- TOC entry 6732 (class 0 OID 0)
-- Dependencies: 384
-- Name: drinkstatistics_stat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drinkstatistics_stat_id_seq', 1, false);


--
-- TOC entry 6733 (class 0 OID 0)
-- Dependencies: 386
-- Name: drug_drug_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drug_drug_id_seq', 1, false);


--
-- TOC entry 6734 (class 0 OID 0)
-- Dependencies: 388
-- Name: drughealthcondition_drug_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drughealthcondition_drug_condition_id_seq', 204, true);


--
-- TOC entry 6735 (class 0 OID 0)
-- Dependencies: 390
-- Name: drugnutrientcontraindication_contra_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drugnutrientcontraindication_contra_id_seq', 178, true);


--
-- TOC entry 6736 (class 0 OID 0)
-- Dependencies: 263
-- Name: fattyacid_fatty_acid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fattyacid_fatty_acid_id_seq', 18, true);


--
-- TOC entry 6737 (class 0 OID 0)
-- Dependencies: 267
-- Name: fattyacidrequirement_fa_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fattyacidrequirement_fa_req_id_seq', 8, true);


--
-- TOC entry 6738 (class 0 OID 0)
-- Dependencies: 261
-- Name: fiber_fiber_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fiber_fiber_id_seq', 7, true);


--
-- TOC entry 6739 (class 0 OID 0)
-- Dependencies: 265
-- Name: fiberrequirement_fiber_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fiberrequirement_fiber_req_id_seq', 15, true);


--
-- TOC entry 6740 (class 0 OID 0)
-- Dependencies: 230
-- Name: food_food_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.food_food_id_seq', 87, true);


--
-- TOC entry 6741 (class 0 OID 0)
-- Dependencies: 312
-- Name: foodcategory_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.foodcategory_category_id_seq', 10, true);


--
-- TOC entry 6742 (class 0 OID 0)
-- Dependencies: 234
-- Name: foodnutrient_food_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.foodnutrient_food_nutrient_id_seq', 3474, true);


--
-- TOC entry 6743 (class 0 OID 0)
-- Dependencies: 236
-- Name: foodtag_tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.foodtag_tag_id_seq', 1, false);


--
-- TOC entry 6744 (class 0 OID 0)
-- Dependencies: 393
-- Name: friendrequest_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.friendrequest_request_id_seq', 5, true);


--
-- TOC entry 6745 (class 0 OID 0)
-- Dependencies: 395
-- Name: friendship_friendship_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.friendship_friendship_id_seq', 3, true);


--
-- TOC entry 6746 (class 0 OID 0)
-- Dependencies: 314
-- Name: healthcondition_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.healthcondition_condition_id_seq', 1, false);


--
-- TOC entry 6747 (class 0 OID 0)
-- Dependencies: 286
-- Name: meal_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meal_entries_id_seq', 15, true);


--
-- TOC entry 6748 (class 0 OID 0)
-- Dependencies: 239
-- Name: meal_meal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meal_meal_id_seq', 27, true);


--
-- TOC entry 6749 (class 0 OID 0)
-- Dependencies: 241
-- Name: mealitem_meal_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mealitem_meal_item_id_seq', 45, true);


--
-- TOC entry 6750 (class 0 OID 0)
-- Dependencies: 243
-- Name: mealnote_note_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mealnote_note_id_seq', 1, false);


--
-- TOC entry 6751 (class 0 OID 0)
-- Dependencies: 334
-- Name: mealtemplate_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mealtemplate_template_id_seq', 1, false);


--
-- TOC entry 6752 (class 0 OID 0)
-- Dependencies: 336
-- Name: mealtemplateitem_template_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mealtemplateitem_template_item_id_seq', 1, false);


--
-- TOC entry 6753 (class 0 OID 0)
-- Dependencies: 320
-- Name: medicationlog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicationlog_log_id_seq', 1, true);


--
-- TOC entry 6754 (class 0 OID 0)
-- Dependencies: 318
-- Name: medicationschedule_medication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicationschedule_medication_id_seq', 2, true);


--
-- TOC entry 6755 (class 0 OID 0)
-- Dependencies: 399
-- Name: messagereaction_reaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messagereaction_reaction_id_seq', 1, false);


--
-- TOC entry 6756 (class 0 OID 0)
-- Dependencies: 256
-- Name: mineral_mineral_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mineral_mineral_id_seq', 28, true);


--
-- TOC entry 6757 (class 0 OID 0)
-- Dependencies: 374
-- Name: mineralnutrient_mineral_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mineralnutrient_mineral_nutrient_id_seq', 44, true);


--
-- TOC entry 6758 (class 0 OID 0)
-- Dependencies: 258
-- Name: mineralrda_mineral_rda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mineralrda_mineral_rda_id_seq', 86, true);


--
-- TOC entry 6759 (class 0 OID 0)
-- Dependencies: 232
-- Name: nutrient_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutrient_nutrient_id_seq', 77, true);


--
-- TOC entry 6760 (class 0 OID 0)
-- Dependencies: 290
-- Name: nutrientcontraindication_contra_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutrientcontraindication_contra_id_seq', 1, false);


--
-- TOC entry 6761 (class 0 OID 0)
-- Dependencies: 275
-- Name: nutrientmapping_mapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutrientmapping_mapping_id_seq', 10, true);


--
-- TOC entry 6762 (class 0 OID 0)
-- Dependencies: 308
-- Name: nutritionanalysis_analysis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nutritionanalysis_analysis_id_seq', 1, false);


--
-- TOC entry 6763 (class 0 OID 0)
-- Dependencies: 341
-- Name: passwordchangecode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.passwordchangecode_id_seq', 1, false);


--
-- TOC entry 6764 (class 0 OID 0)
-- Dependencies: 368
-- Name: permission_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permission_permission_id_seq', 27, true);


--
-- TOC entry 6765 (class 0 OID 0)
-- Dependencies: 328
-- Name: portionsize_portion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.portionsize_portion_id_seq', 71, true);


--
-- TOC entry 6766 (class 0 OID 0)
-- Dependencies: 401
-- Name: privateconversation_conversation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.privateconversation_conversation_id_seq', 3, true);


--
-- TOC entry 6767 (class 0 OID 0)
-- Dependencies: 403
-- Name: privatemessage_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.privatemessage_message_id_seq', 4, true);


--
-- TOC entry 6768 (class 0 OID 0)
-- Dependencies: 330
-- Name: recipe_recipe_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipe_recipe_id_seq', 1, false);


--
-- TOC entry 6769 (class 0 OID 0)
-- Dependencies: 332
-- Name: recipeingredient_recipe_ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipeingredient_recipe_ingredient_id_seq', 30, true);


--
-- TOC entry 6770 (class 0 OID 0)
-- Dependencies: 227
-- Name: role_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_role_id_seq', 7, true);


--
-- TOC entry 6771 (class 0 OID 0)
-- Dependencies: 370
-- Name: rolepermission_role_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolepermission_role_permission_id_seq', 75, true);


--
-- TOC entry 6772 (class 0 OID 0)
-- Dependencies: 247
-- Name: suggestion_suggestion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suggestion_suggestion_id_seq', 1, false);


--
-- TOC entry 6773 (class 0 OID 0)
-- Dependencies: 344
-- Name: user_block_event_block_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_block_event_block_event_id_seq', 1, false);


--
-- TOC entry 6774 (class 0 OID 0)
-- Dependencies: 288
-- Name: user_meal_summaries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_meal_summaries_id_seq', 15, true);


--
-- TOC entry 6775 (class 0 OID 0)
-- Dependencies: 284
-- Name: user_meal_targets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_meal_targets_id_seq', 1, false);


--
-- TOC entry 6776 (class 0 OID 0)
-- Dependencies: 346
-- Name: user_unblock_request_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_unblock_request_request_id_seq', 1, false);


--
-- TOC entry 6777 (class 0 OID 0)
-- Dependencies: 223
-- Name: useractivitylog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.useractivitylog_log_id_seq', 25, true);


--
-- TOC entry 6778 (class 0 OID 0)
-- Dependencies: 282
-- Name: useraminointake_intake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.useraminointake_intake_id_seq', 1, false);


--
-- TOC entry 6779 (class 0 OID 0)
-- Dependencies: 273
-- Name: userfattyacidintake_intake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.userfattyacidintake_intake_id_seq', 39, true);


--
-- TOC entry 6780 (class 0 OID 0)
-- Dependencies: 271
-- Name: userfiberintake_intake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.userfiberintake_intake_id_seq', 19, true);


--
-- TOC entry 6781 (class 0 OID 0)
-- Dependencies: 249
-- Name: usergoal_goal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usergoal_goal_id_seq', 1, false);


--
-- TOC entry 6782 (class 0 OID 0)
-- Dependencies: 316
-- Name: userhealthcondition_user_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.userhealthcondition_user_condition_id_seq', 3, true);


--
-- TOC entry 6783 (class 0 OID 0)
-- Dependencies: 406
-- Name: usermedication_user_medication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usermedication_user_medication_id_seq', 1, false);


--
-- TOC entry 6784 (class 0 OID 0)
-- Dependencies: 376
-- Name: usernutrientmanuallog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usernutrientmanuallog_log_id_seq', 10, true);


--
-- TOC entry 6785 (class 0 OID 0)
-- Dependencies: 295
-- Name: usernutrientnotification_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usernutrientnotification_notification_id_seq', 1, false);


--
-- TOC entry 6786 (class 0 OID 0)
-- Dependencies: 293
-- Name: usernutrienttracking_tracking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usernutrienttracking_tracking_id_seq', 1508, true);


--
-- TOC entry 6787 (class 0 OID 0)
-- Dependencies: 251
-- Name: vitamin_vitamin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitamin_vitamin_id_seq', 26, true);


--
-- TOC entry 6788 (class 0 OID 0)
-- Dependencies: 372
-- Name: vitaminnutrient_vitamin_nutrient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitaminnutrient_vitamin_nutrient_id_seq', 71, true);


--
-- TOC entry 6789 (class 0 OID 0)
-- Dependencies: 254
-- Name: vitaminrda_vitamin_rda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitaminrda_vitamin_rda_id_seq', 119, true);


--
-- TOC entry 6790 (class 0 OID 0)
-- Dependencies: 364
-- Name: waterlog_water_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.waterlog_water_log_id_seq', 23, true);


--
-- TOC entry 5683 (class 2606 OID 21106)
-- Name: User User_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_email_key" UNIQUE (email);


--
-- TOC entry 5685 (class 2606 OID 21104)
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (user_id);


--
-- TOC entry 5694 (class 2606 OID 21171)
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (admin_id);


--
-- TOC entry 5696 (class 2606 OID 21173)
-- Name: admin admin_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_username_key UNIQUE (username);


--
-- TOC entry 5952 (class 2606 OID 22945)
-- Name: admin_verification admin_verification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_verification
    ADD CONSTRAINT admin_verification_pkey PRIMARY KEY (verification_id);


--
-- TOC entry 5827 (class 2606 OID 22107)
-- Name: adminconversation adminconversation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminconversation
    ADD CONSTRAINT adminconversation_pkey PRIMARY KEY (admin_conversation_id);


--
-- TOC entry 5832 (class 2606 OID 22131)
-- Name: adminmessage adminmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminmessage
    ADD CONSTRAINT adminmessage_pkey PRIMARY KEY (admin_message_id);


--
-- TOC entry 5702 (class 2606 OID 21191)
-- Name: adminrole adminrole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminrole
    ADD CONSTRAINT adminrole_pkey PRIMARY KEY (admin_id, role_id);


--
-- TOC entry 5784 (class 2606 OID 21800)
-- Name: aminoacid aminoacid_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aminoacid
    ADD CONSTRAINT aminoacid_code_key UNIQUE (code);


--
-- TOC entry 5786 (class 2606 OID 21798)
-- Name: aminoacid aminoacid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aminoacid
    ADD CONSTRAINT aminoacid_pkey PRIMARY KEY (amino_acid_id);


--
-- TOC entry 5788 (class 2606 OID 21816)
-- Name: aminorequirement aminorequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aminorequirement
    ADD CONSTRAINT aminorequirement_pkey PRIMARY KEY (amino_requirement_id);


--
-- TOC entry 5816 (class 2606 OID 22044)
-- Name: bodymeasurement bodymeasurement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bodymeasurement
    ADD CONSTRAINT bodymeasurement_pkey PRIMARY KEY (measurement_id);


--
-- TOC entry 5819 (class 2606 OID 22066)
-- Name: chatbotconversation chatbotconversation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbotconversation
    ADD CONSTRAINT chatbotconversation_pkey PRIMARY KEY (conversation_id);


--
-- TOC entry 5823 (class 2606 OID 22087)
-- Name: chatbotmessage chatbotmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbotmessage
    ADD CONSTRAINT chatbotmessage_pkey PRIMARY KEY (message_id);


--
-- TOC entry 6034 (class 2606 OID 24520)
-- Name: communitymessage communitymessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communitymessage
    ADD CONSTRAINT communitymessage_pkey PRIMARY KEY (message_id);


--
-- TOC entry 5879 (class 2606 OID 22368)
-- Name: conditioneffectlog conditioneffectlog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditioneffectlog
    ADD CONSTRAINT conditioneffectlog_pkey PRIMARY KEY (log_id);


--
-- TOC entry 5874 (class 2606 OID 22349)
-- Name: conditionfoodrecommendation conditionfoodrecommendation_condition_id_food_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionfoodrecommendation
    ADD CONSTRAINT conditionfoodrecommendation_condition_id_food_id_key UNIQUE (condition_id, food_id);


--
-- TOC entry 5876 (class 2606 OID 22347)
-- Name: conditionfoodrecommendation conditionfoodrecommendation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionfoodrecommendation
    ADD CONSTRAINT conditionfoodrecommendation_pkey PRIMARY KEY (recommendation_id);


--
-- TOC entry 5869 (class 2606 OID 22325)
-- Name: conditionnutrienteffect conditionnutrienteffect_condition_id_nutrient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionnutrienteffect
    ADD CONSTRAINT conditionnutrienteffect_condition_id_nutrient_id_key UNIQUE (condition_id, nutrient_id);


--
-- TOC entry 5871 (class 2606 OID 22323)
-- Name: conditionnutrienteffect conditionnutrienteffect_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionnutrienteffect
    ADD CONSTRAINT conditionnutrienteffect_pkey PRIMARY KEY (effect_id);


--
-- TOC entry 5733 (class 2606 OID 21346)
-- Name: dailysummary dailysummary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dailysummary
    ADD CONSTRAINT dailysummary_pkey PRIMARY KEY (summary_id);


--
-- TOC entry 5915 (class 2606 OID 22698)
-- Name: dish dish_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish
    ADD CONSTRAINT dish_pkey PRIMARY KEY (dish_id);


--
-- TOC entry 5931 (class 2606 OID 22760)
-- Name: dishimage dishimage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishimage
    ADD CONSTRAINT dishimage_pkey PRIMARY KEY (dish_image_id);


--
-- TOC entry 5924 (class 2606 OID 22731)
-- Name: dishingredient dishingredient_dish_id_food_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishingredient
    ADD CONSTRAINT dishingredient_dish_id_food_id_key UNIQUE (dish_id, food_id);


--
-- TOC entry 5926 (class 2606 OID 22729)
-- Name: dishingredient dishingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishingredient
    ADD CONSTRAINT dishingredient_pkey PRIMARY KEY (dish_ingredient_id);


--
-- TOC entry 5947 (class 2606 OID 22856)
-- Name: dishnotification dishnotification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnotification
    ADD CONSTRAINT dishnotification_pkey PRIMARY KEY (notification_id);


--
-- TOC entry 5941 (class 2606 OID 22809)
-- Name: dishnutrient dishnutrient_dish_id_nutrient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnutrient
    ADD CONSTRAINT dishnutrient_dish_id_nutrient_id_key UNIQUE (dish_id, nutrient_id);


--
-- TOC entry 5943 (class 2606 OID 22807)
-- Name: dishnutrient dishnutrient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnutrient
    ADD CONSTRAINT dishnutrient_pkey PRIMARY KEY (dish_nutrient_id);


--
-- TOC entry 5935 (class 2606 OID 22788)
-- Name: dishstatistics dishstatistics_dish_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishstatistics
    ADD CONSTRAINT dishstatistics_dish_id_key UNIQUE (dish_id);


--
-- TOC entry 5937 (class 2606 OID 22786)
-- Name: dishstatistics dishstatistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishstatistics
    ADD CONSTRAINT dishstatistics_pkey PRIMARY KEY (stat_id);


--
-- TOC entry 5981 (class 2606 OID 23814)
-- Name: drink drink_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drink
    ADD CONSTRAINT drink_pkey PRIMARY KEY (drink_id);


--
-- TOC entry 5983 (class 2606 OID 23816)
-- Name: drink drink_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drink
    ADD CONSTRAINT drink_slug_key UNIQUE (slug);


--
-- TOC entry 5988 (class 2606 OID 23847)
-- Name: drinkingredient drinkingredient_drink_id_food_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkingredient
    ADD CONSTRAINT drinkingredient_drink_id_food_id_key UNIQUE (drink_id, food_id);


--
-- TOC entry 5990 (class 2606 OID 23845)
-- Name: drinkingredient drinkingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkingredient
    ADD CONSTRAINT drinkingredient_pkey PRIMARY KEY (drink_ingredient_id);


--
-- TOC entry 5994 (class 2606 OID 23872)
-- Name: drinknutrient drinknutrient_drink_id_nutrient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinknutrient
    ADD CONSTRAINT drinknutrient_drink_id_nutrient_id_key UNIQUE (drink_id, nutrient_id);


--
-- TOC entry 5996 (class 2606 OID 23870)
-- Name: drinknutrient drinknutrient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinknutrient
    ADD CONSTRAINT drinknutrient_pkey PRIMARY KEY (drink_nutrient_id);


--
-- TOC entry 6000 (class 2606 OID 23898)
-- Name: drinkstatistics drinkstatistics_drink_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkstatistics
    ADD CONSTRAINT drinkstatistics_drink_id_key UNIQUE (drink_id);


--
-- TOC entry 6002 (class 2606 OID 23896)
-- Name: drinkstatistics drinkstatistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkstatistics
    ADD CONSTRAINT drinkstatistics_pkey PRIMARY KEY (stat_id);


--
-- TOC entry 6005 (class 2606 OID 23982)
-- Name: drug drug_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug
    ADD CONSTRAINT drug_pkey PRIMARY KEY (drug_id);


--
-- TOC entry 6009 (class 2606 OID 24005)
-- Name: drughealthcondition drughealthcondition_drug_id_condition_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drughealthcondition
    ADD CONSTRAINT drughealthcondition_drug_id_condition_id_key UNIQUE (drug_id, condition_id);


--
-- TOC entry 6011 (class 2606 OID 24003)
-- Name: drughealthcondition drughealthcondition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drughealthcondition
    ADD CONSTRAINT drughealthcondition_pkey PRIMARY KEY (drug_condition_id);


--
-- TOC entry 6015 (class 2606 OID 24035)
-- Name: drugnutrientcontraindication drugnutrientcontraindication_drug_id_nutrient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drugnutrientcontraindication
    ADD CONSTRAINT drugnutrientcontraindication_drug_id_nutrient_id_key UNIQUE (drug_id, nutrient_id);


--
-- TOC entry 6017 (class 2606 OID 24033)
-- Name: drugnutrientcontraindication drugnutrientcontraindication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drugnutrientcontraindication
    ADD CONSTRAINT drugnutrientcontraindication_pkey PRIMARY KEY (contra_id);


--
-- TOC entry 5760 (class 2606 OID 21640)
-- Name: fattyacid fattyacid_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fattyacid
    ADD CONSTRAINT fattyacid_code_key UNIQUE (code);


--
-- TOC entry 5762 (class 2606 OID 21638)
-- Name: fattyacid fattyacid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fattyacid
    ADD CONSTRAINT fattyacid_pkey PRIMARY KEY (fatty_acid_id);


--
-- TOC entry 5766 (class 2606 OID 21671)
-- Name: fattyacidrequirement fattyacidrequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fattyacidrequirement
    ADD CONSTRAINT fattyacidrequirement_pkey PRIMARY KEY (fa_req_id);


--
-- TOC entry 5756 (class 2606 OID 21622)
-- Name: fiber fiber_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fiber
    ADD CONSTRAINT fiber_code_key UNIQUE (code);


--
-- TOC entry 5758 (class 2606 OID 21620)
-- Name: fiber fiber_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fiber
    ADD CONSTRAINT fiber_pkey PRIMARY KEY (fiber_id);


--
-- TOC entry 5764 (class 2606 OID 21653)
-- Name: fiberrequirement fiberrequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fiberrequirement
    ADD CONSTRAINT fiberrequirement_pkey PRIMARY KEY (fiber_req_id);


--
-- TOC entry 5704 (class 2606 OID 21213)
-- Name: food food_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food
    ADD CONSTRAINT food_pkey PRIMARY KEY (food_id);


--
-- TOC entry 5842 (class 2606 OID 22204)
-- Name: foodcategory foodcategory_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodcategory
    ADD CONSTRAINT foodcategory_category_name_key UNIQUE (category_name);


--
-- TOC entry 5844 (class 2606 OID 22202)
-- Name: foodcategory foodcategory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodcategory
    ADD CONSTRAINT foodcategory_pkey PRIMARY KEY (category_id);


--
-- TOC entry 5712 (class 2606 OID 21244)
-- Name: foodnutrient foodnutrient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodnutrient
    ADD CONSTRAINT foodnutrient_pkey PRIMARY KEY (food_nutrient_id);


--
-- TOC entry 5718 (class 2606 OID 21263)
-- Name: foodtag foodtag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodtag
    ADD CONSTRAINT foodtag_pkey PRIMARY KEY (tag_id);


--
-- TOC entry 5720 (class 2606 OID 21270)
-- Name: foodtagmapping foodtagmapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodtagmapping
    ADD CONSTRAINT foodtagmapping_pkey PRIMARY KEY (food_id, tag_id);


--
-- TOC entry 6021 (class 2606 OID 24462)
-- Name: friendrequest friendrequest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendrequest
    ADD CONSTRAINT friendrequest_pkey PRIMARY KEY (request_id);


--
-- TOC entry 6023 (class 2606 OID 24464)
-- Name: friendrequest friendrequest_sender_id_receiver_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendrequest
    ADD CONSTRAINT friendrequest_sender_id_receiver_id_key UNIQUE (sender_id, receiver_id);


--
-- TOC entry 6028 (class 2606 OID 24489)
-- Name: friendship friendship_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendship
    ADD CONSTRAINT friendship_pkey PRIMARY KEY (friendship_id);


--
-- TOC entry 6030 (class 2606 OID 24491)
-- Name: friendship friendship_user1_id_user2_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendship
    ADD CONSTRAINT friendship_user1_id_user2_id_key UNIQUE (user1_id, user2_id);


--
-- TOC entry 5846 (class 2606 OID 22240)
-- Name: healthcondition healthcondition_name_vi_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.healthcondition
    ADD CONSTRAINT healthcondition_name_vi_key UNIQUE (name_vi);


--
-- TOC entry 5848 (class 2606 OID 22238)
-- Name: healthcondition healthcondition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.healthcondition
    ADD CONSTRAINT healthcondition_pkey PRIMARY KEY (condition_id);


--
-- TOC entry 5797 (class 2606 OID 21905)
-- Name: meal_entries meal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_entries
    ADD CONSTRAINT meal_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 5725 (class 2606 OID 21291)
-- Name: meal meal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal
    ADD CONSTRAINT meal_pkey PRIMARY KEY (meal_id);


--
-- TOC entry 5729 (class 2606 OID 21306)
-- Name: mealitem mealitem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealitem
    ADD CONSTRAINT mealitem_pkey PRIMARY KEY (meal_item_id);


--
-- TOC entry 5731 (class 2606 OID 21327)
-- Name: mealnote mealnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealnote
    ADD CONSTRAINT mealnote_pkey PRIMARY KEY (note_id);


--
-- TOC entry 5895 (class 2606 OID 22481)
-- Name: mealtemplate mealtemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealtemplate
    ADD CONSTRAINT mealtemplate_pkey PRIMARY KEY (template_id);


--
-- TOC entry 5898 (class 2606 OID 22496)
-- Name: mealtemplateitem mealtemplateitem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealtemplateitem
    ADD CONSTRAINT mealtemplateitem_pkey PRIMARY KEY (template_item_id);


--
-- TOC entry 5865 (class 2606 OID 22299)
-- Name: medicationlog medicationlog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationlog
    ADD CONSTRAINT medicationlog_pkey PRIMARY KEY (log_id);


--
-- TOC entry 5867 (class 2606 OID 22301)
-- Name: medicationlog medicationlog_user_condition_id_medication_date_medication__key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationlog
    ADD CONSTRAINT medicationlog_user_condition_id_medication_date_medication__key UNIQUE (user_condition_id, medication_date, medication_time);


--
-- TOC entry 5860 (class 2606 OID 22277)
-- Name: medicationschedule medicationschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationschedule
    ADD CONSTRAINT medicationschedule_pkey PRIMARY KEY (medication_id);


--
-- TOC entry 6041 (class 2606 OID 24546)
-- Name: messagereaction messagereaction_message_type_message_id_user_id_reaction_ty_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messagereaction
    ADD CONSTRAINT messagereaction_message_type_message_id_user_id_reaction_ty_key UNIQUE (message_type, message_id, user_id, reaction_type);


--
-- TOC entry 6043 (class 2606 OID 24544)
-- Name: messagereaction messagereaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messagereaction
    ADD CONSTRAINT messagereaction_pkey PRIMARY KEY (reaction_id);


--
-- TOC entry 5748 (class 2606 OID 21555)
-- Name: mineral mineral_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineral
    ADD CONSTRAINT mineral_code_key UNIQUE (code);


--
-- TOC entry 5750 (class 2606 OID 21553)
-- Name: mineral mineral_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineral
    ADD CONSTRAINT mineral_pkey PRIMARY KEY (mineral_id);


--
-- TOC entry 5973 (class 2606 OID 23167)
-- Name: mineralnutrient mineralnutrient_mineral_id_nutrient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineralnutrient
    ADD CONSTRAINT mineralnutrient_mineral_id_nutrient_id_key UNIQUE (mineral_id, nutrient_id);


--
-- TOC entry 5975 (class 2606 OID 23165)
-- Name: mineralnutrient mineralnutrient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineralnutrient
    ADD CONSTRAINT mineralnutrient_pkey PRIMARY KEY (mineral_nutrient_id);


--
-- TOC entry 5752 (class 2606 OID 21570)
-- Name: mineralrda mineralrda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineralrda
    ADD CONSTRAINT mineralrda_pkey PRIMARY KEY (mineral_rda_id);


--
-- TOC entry 5709 (class 2606 OID 21229)
-- Name: nutrient nutrient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrient
    ADD CONSTRAINT nutrient_pkey PRIMARY KEY (nutrient_id);


--
-- TOC entry 5803 (class 2606 OID 21957)
-- Name: nutrientcontraindication nutrientcontraindication_nutrient_id_condition_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientcontraindication
    ADD CONSTRAINT nutrientcontraindication_nutrient_id_condition_name_key UNIQUE (nutrient_id, condition_name);


--
-- TOC entry 5805 (class 2606 OID 21955)
-- Name: nutrientcontraindication nutrientcontraindication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientcontraindication
    ADD CONSTRAINT nutrientcontraindication_pkey PRIMARY KEY (contra_id);


--
-- TOC entry 5780 (class 2606 OID 21769)
-- Name: nutrientmapping nutrientmapping_nutrient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientmapping
    ADD CONSTRAINT nutrientmapping_nutrient_id_key UNIQUE (nutrient_id);


--
-- TOC entry 5782 (class 2606 OID 21767)
-- Name: nutrientmapping nutrientmapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientmapping
    ADD CONSTRAINT nutrientmapping_pkey PRIMARY KEY (mapping_id);


--
-- TOC entry 5840 (class 2606 OID 22152)
-- Name: nutritionanalysis nutritionanalysis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutritionanalysis
    ADD CONSTRAINT nutritionanalysis_pkey PRIMARY KEY (analysis_id);


--
-- TOC entry 5904 (class 2606 OID 22591)
-- Name: passwordchangecode passwordchangecode_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passwordchangecode
    ADD CONSTRAINT passwordchangecode_pkey PRIMARY KEY (id);


--
-- TOC entry 5957 (class 2606 OID 23096)
-- Name: permission permission_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_name_key UNIQUE (name);


--
-- TOC entry 5959 (class 2606 OID 23094)
-- Name: permission permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_pkey PRIMARY KEY (permission_id);


--
-- TOC entry 5882 (class 2606 OID 22410)
-- Name: portionsize portionsize_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portionsize
    ADD CONSTRAINT portionsize_pkey PRIMARY KEY (portion_id);


--
-- TOC entry 6047 (class 2606 OID 24566)
-- Name: privateconversation privateconversation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privateconversation
    ADD CONSTRAINT privateconversation_pkey PRIMARY KEY (conversation_id);


--
-- TOC entry 6049 (class 2606 OID 24568)
-- Name: privateconversation privateconversation_user1_id_user2_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privateconversation
    ADD CONSTRAINT privateconversation_user1_id_user2_id_key UNIQUE (user1_id, user2_id);


--
-- TOC entry 6055 (class 2606 OID 24594)
-- Name: privatemessage privatemessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privatemessage
    ADD CONSTRAINT privatemessage_pkey PRIMARY KEY (message_id);


--
-- TOC entry 5886 (class 2606 OID 22431)
-- Name: recipe recipe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe
    ADD CONSTRAINT recipe_pkey PRIMARY KEY (recipe_id);


--
-- TOC entry 5889 (class 2606 OID 22448)
-- Name: recipeingredient recipeingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipeingredient
    ADD CONSTRAINT recipeingredient_pkey PRIMARY KEY (recipe_ingredient_id);


--
-- TOC entry 5891 (class 2606 OID 22450)
-- Name: recipeingredient recipeingredient_recipe_id_food_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipeingredient
    ADD CONSTRAINT recipeingredient_recipe_id_food_id_key UNIQUE (recipe_id, food_id);


--
-- TOC entry 5698 (class 2606 OID 21182)
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- TOC entry 5700 (class 2606 OID 21184)
-- Name: role role_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_role_name_key UNIQUE (role_name);


--
-- TOC entry 5961 (class 2606 OID 23105)
-- Name: rolepermission rolepermission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolepermission
    ADD CONSTRAINT rolepermission_pkey PRIMARY KEY (role_permission_id);


--
-- TOC entry 5963 (class 2606 OID 23107)
-- Name: rolepermission rolepermission_role_name_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolepermission
    ADD CONSTRAINT rolepermission_role_name_permission_id_key UNIQUE (role_name, permission_id);


--
-- TOC entry 5736 (class 2606 OID 21362)
-- Name: suggestion suggestion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggestion
    ADD CONSTRAINT suggestion_pkey PRIMARY KEY (suggestion_id);


--
-- TOC entry 5716 (class 2606 OID 22188)
-- Name: foodnutrient unique_food_nutrient; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodnutrient
    ADD CONSTRAINT unique_food_nutrient UNIQUE (food_id, nutrient_id);


--
-- TOC entry 5906 (class 2606 OID 22613)
-- Name: user_account_status user_account_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account_status
    ADD CONSTRAINT user_account_status_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5909 (class 2606 OID 22637)
-- Name: user_block_event user_block_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_block_event
    ADD CONSTRAINT user_block_event_pkey PRIMARY KEY (block_event_id);


--
-- TOC entry 5799 (class 2606 OID 21927)
-- Name: user_meal_summaries user_meal_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_meal_summaries
    ADD CONSTRAINT user_meal_summaries_pkey PRIMARY KEY (id);


--
-- TOC entry 5801 (class 2606 OID 21929)
-- Name: user_meal_summaries user_meal_summaries_user_id_summary_date_meal_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_meal_summaries
    ADD CONSTRAINT user_meal_summaries_user_id_summary_date_meal_type_key UNIQUE (user_id, summary_date, meal_type);


--
-- TOC entry 5794 (class 2606 OID 21882)
-- Name: user_meal_targets user_meal_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_meal_targets
    ADD CONSTRAINT user_meal_targets_pkey PRIMARY KEY (id);


--
-- TOC entry 5913 (class 2606 OID 22663)
-- Name: user_unblock_request user_unblock_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_unblock_request
    ADD CONSTRAINT user_unblock_request_pkey PRIMARY KEY (request_id);


--
-- TOC entry 5692 (class 2606 OID 21153)
-- Name: useractivitylog useractivitylog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useractivitylog
    ADD CONSTRAINT useractivitylog_pkey PRIMARY KEY (log_id);


--
-- TOC entry 5792 (class 2606 OID 21854)
-- Name: useraminointake useraminointake_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraminointake
    ADD CONSTRAINT useraminointake_pkey PRIMARY KEY (intake_id);


--
-- TOC entry 5790 (class 2606 OID 21831)
-- Name: useraminorequirement useraminorequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraminorequirement
    ADD CONSTRAINT useraminorequirement_pkey PRIMARY KEY (user_id, amino_acid_id);


--
-- TOC entry 5776 (class 2606 OID 21746)
-- Name: userfattyacidintake userfattyacidintake_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfattyacidintake
    ADD CONSTRAINT userfattyacidintake_pkey PRIMARY KEY (intake_id);


--
-- TOC entry 5778 (class 2606 OID 24077)
-- Name: userfattyacidintake userfattyacidintake_user_date_fatty_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfattyacidintake
    ADD CONSTRAINT userfattyacidintake_user_date_fatty_unique UNIQUE (user_id, date, fatty_acid_id);


--
-- TOC entry 5770 (class 2606 OID 21706)
-- Name: userfattyacidrequirement userfattyacidrequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfattyacidrequirement
    ADD CONSTRAINT userfattyacidrequirement_pkey PRIMARY KEY (user_id, fatty_acid_id);


--
-- TOC entry 5772 (class 2606 OID 21726)
-- Name: userfiberintake userfiberintake_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfiberintake
    ADD CONSTRAINT userfiberintake_pkey PRIMARY KEY (intake_id);


--
-- TOC entry 5774 (class 2606 OID 24075)
-- Name: userfiberintake userfiberintake_user_date_fiber_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfiberintake
    ADD CONSTRAINT userfiberintake_user_date_fiber_unique UNIQUE (user_id, date, fiber_id);


--
-- TOC entry 5768 (class 2606 OID 21686)
-- Name: userfiberrequirement userfiberrequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfiberrequirement
    ADD CONSTRAINT userfiberrequirement_pkey PRIMARY KEY (user_id, fiber_id);


--
-- TOC entry 5738 (class 2606 OID 21401)
-- Name: usergoal usergoal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usergoal
    ADD CONSTRAINT usergoal_pkey PRIMARY KEY (goal_id);


--
-- TOC entry 5854 (class 2606 OID 22254)
-- Name: userhealthcondition userhealthcondition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userhealthcondition
    ADD CONSTRAINT userhealthcondition_pkey PRIMARY KEY (user_condition_id);


--
-- TOC entry 5856 (class 2606 OID 22256)
-- Name: userhealthcondition userhealthcondition_user_id_condition_id_treatment_start_da_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userhealthcondition
    ADD CONSTRAINT userhealthcondition_user_id_condition_id_treatment_start_da_key UNIQUE (user_id, condition_id, treatment_start_date);


--
-- TOC entry 6058 (class 2606 OID 29016)
-- Name: usermedication usermedication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermedication
    ADD CONSTRAINT usermedication_pkey PRIMARY KEY (user_medication_id);


--
-- TOC entry 5754 (class 2606 OID 21588)
-- Name: usermineralrequirement usermineralrequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermineralrequirement
    ADD CONSTRAINT usermineralrequirement_pkey PRIMARY KEY (user_id, mineral_id);


--
-- TOC entry 5978 (class 2606 OID 23771)
-- Name: usernutrientmanuallog usernutrientmanuallog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrientmanuallog
    ADD CONSTRAINT usernutrientmanuallog_pkey PRIMARY KEY (log_id);


--
-- TOC entry 5814 (class 2606 OID 22010)
-- Name: usernutrientnotification usernutrientnotification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrientnotification
    ADD CONSTRAINT usernutrientnotification_pkey PRIMARY KEY (notification_id);


--
-- TOC entry 5808 (class 2606 OID 21984)
-- Name: usernutrienttracking usernutrienttracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrienttracking
    ADD CONSTRAINT usernutrienttracking_pkey PRIMARY KEY (tracking_id);


--
-- TOC entry 5810 (class 2606 OID 21986)
-- Name: usernutrienttracking usernutrienttracking_user_id_date_nutrient_type_nutrient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrienttracking
    ADD CONSTRAINT usernutrienttracking_user_id_date_nutrient_type_nutrient_id_key UNIQUE (user_id, date, nutrient_type, nutrient_id);


--
-- TOC entry 5688 (class 2606 OID 21114)
-- Name: userprofile userprofile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userprofile
    ADD CONSTRAINT userprofile_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5900 (class 2606 OID 22574)
-- Name: usersecurity usersecurity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usersecurity
    ADD CONSTRAINT usersecurity_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5690 (class 2606 OID 21137)
-- Name: usersetting usersetting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usersetting
    ADD CONSTRAINT usersetting_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5744 (class 2606 OID 21508)
-- Name: uservitaminrequirement uservitaminrequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uservitaminrequirement
    ADD CONSTRAINT uservitaminrequirement_pkey PRIMARY KEY (user_id, vitamin_id);


--
-- TOC entry 5740 (class 2606 OID 21489)
-- Name: vitamin vitamin_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitamin
    ADD CONSTRAINT vitamin_code_key UNIQUE (code);


--
-- TOC entry 5742 (class 2606 OID 21487)
-- Name: vitamin vitamin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitamin
    ADD CONSTRAINT vitamin_pkey PRIMARY KEY (vitamin_id);


--
-- TOC entry 5967 (class 2606 OID 23136)
-- Name: vitaminnutrient vitaminnutrient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitaminnutrient
    ADD CONSTRAINT vitaminnutrient_pkey PRIMARY KEY (vitamin_nutrient_id);


--
-- TOC entry 5969 (class 2606 OID 23138)
-- Name: vitaminnutrient vitaminnutrient_vitamin_id_nutrient_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitaminnutrient
    ADD CONSTRAINT vitaminnutrient_vitamin_id_nutrient_id_key UNIQUE (vitamin_id, nutrient_id);


--
-- TOC entry 5746 (class 2606 OID 21534)
-- Name: vitaminrda vitaminrda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitaminrda
    ADD CONSTRAINT vitaminrda_pkey PRIMARY KEY (vitamin_rda_id);


--
-- TOC entry 5955 (class 2606 OID 22946)
-- Name: waterlog waterlog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waterlog
    ADD CONSTRAINT waterlog_pkey PRIMARY KEY (water_log_id);


--
-- TOC entry 5828 (class 1259 OID 22114)
-- Name: idx_admin_conversation_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admin_conversation_status ON public.adminconversation USING btree (status);


--
-- TOC entry 5829 (class 1259 OID 22115)
-- Name: idx_admin_conversation_updated; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admin_conversation_updated ON public.adminconversation USING btree (updated_at DESC);


--
-- TOC entry 5830 (class 1259 OID 22113)
-- Name: idx_admin_conversation_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admin_conversation_user ON public.adminconversation USING btree (user_id);


--
-- TOC entry 5833 (class 1259 OID 22137)
-- Name: idx_admin_message_conversation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admin_message_conversation ON public.adminmessage USING btree (admin_conversation_id);


--
-- TOC entry 5834 (class 1259 OID 22138)
-- Name: idx_admin_message_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admin_message_created ON public.adminmessage USING btree (created_at);


--
-- TOC entry 5835 (class 1259 OID 22139)
-- Name: idx_admin_message_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admin_message_read ON public.adminmessage USING btree (is_read);


--
-- TOC entry 5817 (class 1259 OID 22050)
-- Name: idx_body_measurement_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_body_measurement_user_date ON public.bodymeasurement USING btree (user_id, measurement_date DESC);


--
-- TOC entry 5820 (class 1259 OID 22073)
-- Name: idx_chatbot_conversation_updated; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chatbot_conversation_updated ON public.chatbotconversation USING btree (updated_at DESC);


--
-- TOC entry 5821 (class 1259 OID 22072)
-- Name: idx_chatbot_conversation_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chatbot_conversation_user ON public.chatbotconversation USING btree (user_id);


--
-- TOC entry 5824 (class 1259 OID 22093)
-- Name: idx_chatbot_message_conversation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chatbot_message_conversation ON public.chatbotmessage USING btree (conversation_id);


--
-- TOC entry 5825 (class 1259 OID 22094)
-- Name: idx_chatbot_message_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chatbot_message_created ON public.chatbotmessage USING btree (created_at);


--
-- TOC entry 6035 (class 1259 OID 24527)
-- Name: idx_community_message_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_community_message_created ON public.communitymessage USING btree (created_at DESC);


--
-- TOC entry 6036 (class 1259 OID 24528)
-- Name: idx_community_message_not_deleted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_community_message_not_deleted ON public.communitymessage USING btree (is_deleted) WHERE (is_deleted = false);


--
-- TOC entry 6037 (class 1259 OID 24526)
-- Name: idx_community_message_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_community_message_user ON public.communitymessage USING btree (user_id);


--
-- TOC entry 5877 (class 1259 OID 22389)
-- Name: idx_condition_food_recommendation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_condition_food_recommendation ON public.conditionfoodrecommendation USING btree (condition_id);


--
-- TOC entry 5872 (class 1259 OID 22388)
-- Name: idx_condition_nutrient_effect; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_condition_nutrient_effect ON public.conditionnutrienteffect USING btree (condition_id);


--
-- TOC entry 5734 (class 1259 OID 22953)
-- Name: idx_daily_summary_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_daily_summary_user_date ON public.dailysummary USING btree (user_id, date);


--
-- TOC entry 5916 (class 1259 OID 22710)
-- Name: idx_dish_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_category ON public.dish USING btree (category);


--
-- TOC entry 5917 (class 1259 OID 22712)
-- Name: idx_dish_creator_admin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_creator_admin ON public.dish USING btree (created_by_admin);


--
-- TOC entry 5918 (class 1259 OID 22711)
-- Name: idx_dish_creator_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_creator_user ON public.dish USING btree (created_by_user);


--
-- TOC entry 5932 (class 1259 OID 22766)
-- Name: idx_dish_image_dish; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_image_dish ON public.dishimage USING btree (dish_id);


--
-- TOC entry 5933 (class 1259 OID 22767)
-- Name: idx_dish_image_primary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_image_primary ON public.dishimage USING btree (dish_id, is_primary);


--
-- TOC entry 5927 (class 1259 OID 22742)
-- Name: idx_dish_ingredient_dish; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_ingredient_dish ON public.dishingredient USING btree (dish_id);


--
-- TOC entry 5928 (class 1259 OID 22743)
-- Name: idx_dish_ingredient_food; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_ingredient_food ON public.dishingredient USING btree (food_id);


--
-- TOC entry 5929 (class 1259 OID 22744)
-- Name: idx_dish_ingredient_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_ingredient_order ON public.dishingredient USING btree (dish_id, display_order);


--
-- TOC entry 5919 (class 1259 OID 22714)
-- Name: idx_dish_is_public; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_is_public ON public.dish USING btree (is_public);


--
-- TOC entry 5920 (class 1259 OID 22713)
-- Name: idx_dish_is_template; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_is_template ON public.dish USING btree (is_template);


--
-- TOC entry 5921 (class 1259 OID 22709)
-- Name: idx_dish_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_name ON public.dish USING btree (name);


--
-- TOC entry 5944 (class 1259 OID 22820)
-- Name: idx_dish_nutrient_dish; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_nutrient_dish ON public.dishnutrient USING btree (dish_id);


--
-- TOC entry 5945 (class 1259 OID 22821)
-- Name: idx_dish_nutrient_nutrient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_nutrient_nutrient ON public.dishnutrient USING btree (nutrient_id);


--
-- TOC entry 5938 (class 1259 OID 22794)
-- Name: idx_dish_stats_dish; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_stats_dish ON public.dishstatistics USING btree (dish_id);


--
-- TOC entry 5939 (class 1259 OID 22795)
-- Name: idx_dish_stats_popular; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_stats_popular ON public.dishstatistics USING btree (total_times_logged DESC);


--
-- TOC entry 5922 (class 1259 OID 22913)
-- Name: idx_dish_user_private; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dish_user_private ON public.dish USING btree (created_by_user, is_public) WHERE (created_by_user IS NOT NULL);


--
-- TOC entry 5948 (class 1259 OID 22868)
-- Name: idx_dishnotification_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dishnotification_created ON public.dishnotification USING btree (created_at DESC);


--
-- TOC entry 5949 (class 1259 OID 22869)
-- Name: idx_dishnotification_dish; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dishnotification_dish ON public.dishnotification USING btree (dish_id);


--
-- TOC entry 5950 (class 1259 OID 22867)
-- Name: idx_dishnotification_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dishnotification_user ON public.dishnotification USING btree (user_id, is_read);


--
-- TOC entry 5984 (class 1259 OID 23828)
-- Name: idx_drink_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drink_category ON public.drink USING btree (category);


--
-- TOC entry 5991 (class 1259 OID 23858)
-- Name: idx_drink_ingredient_drink; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drink_ingredient_drink ON public.drinkingredient USING btree (drink_id);


--
-- TOC entry 5992 (class 1259 OID 23859)
-- Name: idx_drink_ingredient_food; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drink_ingredient_food ON public.drinkingredient USING btree (food_id);


--
-- TOC entry 5997 (class 1259 OID 23883)
-- Name: idx_drink_nutrient_drink; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drink_nutrient_drink ON public.drinknutrient USING btree (drink_id);


--
-- TOC entry 5998 (class 1259 OID 23884)
-- Name: idx_drink_nutrient_nutrient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drink_nutrient_nutrient ON public.drinknutrient USING btree (nutrient_id);


--
-- TOC entry 5985 (class 1259 OID 23827)
-- Name: idx_drink_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drink_slug ON public.drink USING btree (slug);


--
-- TOC entry 6003 (class 1259 OID 23904)
-- Name: idx_drink_stats_drink; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drink_stats_drink ON public.drinkstatistics USING btree (drink_id);


--
-- TOC entry 5986 (class 1259 OID 23829)
-- Name: idx_drink_template; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drink_template ON public.drink USING btree (is_template);


--
-- TOC entry 6006 (class 1259 OID 23989)
-- Name: idx_drug_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drug_active ON public.drug USING btree (is_active);


--
-- TOC entry 6012 (class 1259 OID 24017)
-- Name: idx_drug_condition_condition; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drug_condition_condition ON public.drughealthcondition USING btree (condition_id);


--
-- TOC entry 6013 (class 1259 OID 24016)
-- Name: idx_drug_condition_drug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drug_condition_drug ON public.drughealthcondition USING btree (drug_id);


--
-- TOC entry 6018 (class 1259 OID 24046)
-- Name: idx_drug_contra_drug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drug_contra_drug ON public.drugnutrientcontraindication USING btree (drug_id);


--
-- TOC entry 6019 (class 1259 OID 24047)
-- Name: idx_drug_contra_nutrient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drug_contra_nutrient ON public.drugnutrientcontraindication USING btree (nutrient_id);


--
-- TOC entry 6007 (class 1259 OID 23988)
-- Name: idx_drug_name_vi; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drug_name_vi ON public.drug USING btree (name_vi);


--
-- TOC entry 5705 (class 1259 OID 22184)
-- Name: idx_food_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_food_active ON public.food USING btree (is_active);


--
-- TOC entry 5706 (class 1259 OID 22182)
-- Name: idx_food_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_food_category ON public.food USING btree (category);


--
-- TOC entry 5707 (class 1259 OID 22183)
-- Name: idx_food_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_food_name ON public.food USING btree (name);


--
-- TOC entry 5713 (class 1259 OID 22185)
-- Name: idx_foodnutrient_food; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_foodnutrient_food ON public.foodnutrient USING btree (food_id);


--
-- TOC entry 5714 (class 1259 OID 22186)
-- Name: idx_foodnutrient_nutrient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_foodnutrient_nutrient ON public.foodnutrient USING btree (nutrient_id);


--
-- TOC entry 6024 (class 1259 OID 24476)
-- Name: idx_friend_request_receiver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friend_request_receiver ON public.friendrequest USING btree (receiver_id);


--
-- TOC entry 6025 (class 1259 OID 24475)
-- Name: idx_friend_request_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friend_request_sender ON public.friendrequest USING btree (sender_id);


--
-- TOC entry 6026 (class 1259 OID 24477)
-- Name: idx_friend_request_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friend_request_status ON public.friendrequest USING btree (status);


--
-- TOC entry 6031 (class 1259 OID 24502)
-- Name: idx_friendship_user1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friendship_user1 ON public.friendship USING btree (user1_id);


--
-- TOC entry 6032 (class 1259 OID 24503)
-- Name: idx_friendship_user2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friendship_user2 ON public.friendship USING btree (user2_id);


--
-- TOC entry 5849 (class 1259 OID 29022)
-- Name: idx_healthcondition_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_healthcondition_name ON public.healthcondition USING btree (condition_name);


--
-- TOC entry 5976 (class 1259 OID 23778)
-- Name: idx_manual_nutrient_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_manual_nutrient_date ON public.usernutrientmanuallog USING btree (log_date);


--
-- TOC entry 5721 (class 1259 OID 22397)
-- Name: idx_meal_favorites; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meal_favorites ON public.meal USING btree (user_id, is_favorite);


--
-- TOC entry 5722 (class 1259 OID 22398)
-- Name: idx_meal_history; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meal_history ON public.meal USING btree (user_id, created_at DESC);


--
-- TOC entry 5723 (class 1259 OID 22511)
-- Name: idx_meal_photos; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meal_photos ON public.meal USING btree (user_id, created_at DESC) WHERE (photo_url IS NOT NULL);


--
-- TOC entry 5726 (class 1259 OID 22774)
-- Name: idx_mealitem_dish; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mealitem_dish ON public.mealitem USING btree (dish_id);


--
-- TOC entry 5727 (class 1259 OID 22396)
-- Name: idx_mealitem_quick_add; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mealitem_quick_add ON public.mealitem USING btree (food_id, quick_add_count DESC, last_eaten_at DESC);


--
-- TOC entry 5861 (class 1259 OID 24059)
-- Name: idx_medication_log_drug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medication_log_drug ON public.medicationlog USING btree (drug_id);


--
-- TOC entry 5862 (class 1259 OID 22387)
-- Name: idx_medication_log_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medication_log_user_date ON public.medicationlog USING btree (user_id, medication_date);


--
-- TOC entry 5857 (class 1259 OID 24053)
-- Name: idx_medication_schedule_drug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medication_schedule_drug ON public.medicationschedule USING btree (drug_id);


--
-- TOC entry 5858 (class 1259 OID 22386)
-- Name: idx_medication_schedule_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medication_schedule_user ON public.medicationschedule USING btree (user_id);


--
-- TOC entry 5863 (class 1259 OID 29025)
-- Name: idx_medicationlog_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicationlog_user_date ON public.medicationlog USING btree (user_medication_id, medication_date);


--
-- TOC entry 6038 (class 1259 OID 24552)
-- Name: idx_message_reaction_message; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_message_reaction_message ON public.messagereaction USING btree (message_type, message_id);


--
-- TOC entry 6039 (class 1259 OID 24553)
-- Name: idx_message_reaction_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_message_reaction_user ON public.messagereaction USING btree (user_id);


--
-- TOC entry 5970 (class 1259 OID 23178)
-- Name: idx_mineral_nutrient_mineral; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mineral_nutrient_mineral ON public.mineralnutrient USING btree (mineral_id);


--
-- TOC entry 5971 (class 1259 OID 23179)
-- Name: idx_mineral_nutrient_nutrient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mineral_nutrient_nutrient ON public.mineralnutrient USING btree (nutrient_id);


--
-- TOC entry 5836 (class 1259 OID 22160)
-- Name: idx_nutrition_analysis_approved; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_nutrition_analysis_approved ON public.nutritionanalysis USING btree (is_approved);


--
-- TOC entry 5837 (class 1259 OID 22159)
-- Name: idx_nutrition_analysis_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_nutrition_analysis_created ON public.nutritionanalysis USING btree (created_at);


--
-- TOC entry 5838 (class 1259 OID 22158)
-- Name: idx_nutrition_analysis_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_nutrition_analysis_user ON public.nutritionanalysis USING btree (user_id);


--
-- TOC entry 5880 (class 1259 OID 22416)
-- Name: idx_portion_food; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_portion_food ON public.portionsize USING btree (food_id, is_common);


--
-- TOC entry 6044 (class 1259 OID 24579)
-- Name: idx_private_conversation_user1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_conversation_user1 ON public.privateconversation USING btree (user1_id);


--
-- TOC entry 6045 (class 1259 OID 24580)
-- Name: idx_private_conversation_user2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_conversation_user2 ON public.privateconversation USING btree (user2_id);


--
-- TOC entry 6050 (class 1259 OID 24605)
-- Name: idx_private_message_conversation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_message_conversation ON public.privatemessage USING btree (conversation_id);


--
-- TOC entry 6051 (class 1259 OID 24607)
-- Name: idx_private_message_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_message_created ON public.privatemessage USING btree (created_at);


--
-- TOC entry 6052 (class 1259 OID 24608)
-- Name: idx_private_message_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_message_read ON public.privatemessage USING btree (is_read) WHERE (is_read = false);


--
-- TOC entry 6053 (class 1259 OID 24606)
-- Name: idx_private_message_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_private_message_sender ON public.privatemessage USING btree (sender_id);


--
-- TOC entry 5901 (class 1259 OID 22598)
-- Name: idx_pwcode_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pwcode_code ON public.passwordchangecode USING btree (code);


--
-- TOC entry 5902 (class 1259 OID 22597)
-- Name: idx_pwcode_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pwcode_user ON public.passwordchangecode USING btree (user_id);


--
-- TOC entry 5887 (class 1259 OID 22463)
-- Name: idx_recipe_ingredient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_ingredient ON public.recipeingredient USING btree (recipe_id, ingredient_order);


--
-- TOC entry 5883 (class 1259 OID 22462)
-- Name: idx_recipe_public; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_public ON public.recipe USING btree (is_public) WHERE (is_public = true);


--
-- TOC entry 5884 (class 1259 OID 22461)
-- Name: idx_recipe_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_user ON public.recipe USING btree (user_id, created_at DESC);


--
-- TOC entry 5892 (class 1259 OID 22508)
-- Name: idx_template_favorite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_template_favorite ON public.mealtemplate USING btree (user_id, is_favorite) WHERE (is_favorite = true);


--
-- TOC entry 5896 (class 1259 OID 22509)
-- Name: idx_template_item; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_template_item ON public.mealtemplateitem USING btree (template_id, item_order);


--
-- TOC entry 5893 (class 1259 OID 22507)
-- Name: idx_template_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_template_user ON public.mealtemplate USING btree (user_id, meal_type, usage_count DESC);


--
-- TOC entry 5910 (class 1259 OID 22675)
-- Name: idx_unblock_request_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unblock_request_status ON public.user_unblock_request USING btree (status);


--
-- TOC entry 5911 (class 1259 OID 22674)
-- Name: idx_unblock_request_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unblock_request_user ON public.user_unblock_request USING btree (user_id);


--
-- TOC entry 5686 (class 1259 OID 24447)
-- Name: idx_user_avatar; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_avatar ON public."User" USING btree (avatar_url) WHERE (avatar_url IS NOT NULL);


--
-- TOC entry 5907 (class 1259 OID 22648)
-- Name: idx_user_block_event_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_block_event_user ON public.user_block_event USING btree (user_id);


--
-- TOC entry 5850 (class 1259 OID 22385)
-- Name: idx_user_health_condition_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_health_condition_status ON public.userhealthcondition USING btree (status);


--
-- TOC entry 5851 (class 1259 OID 22384)
-- Name: idx_user_health_condition_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_health_condition_user ON public.userhealthcondition USING btree (user_id);


--
-- TOC entry 5811 (class 1259 OID 22017)
-- Name: idx_user_nutrient_notification_unread; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_nutrient_notification_unread ON public.usernutrientnotification USING btree (user_id, is_read) WHERE (is_read = false);


--
-- TOC entry 5812 (class 1259 OID 22016)
-- Name: idx_user_nutrient_notification_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_nutrient_notification_user ON public.usernutrientnotification USING btree (user_id, created_at DESC);


--
-- TOC entry 5806 (class 1259 OID 21992)
-- Name: idx_user_nutrient_tracking_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_nutrient_tracking_user_date ON public.usernutrienttracking USING btree (user_id, date);


--
-- TOC entry 5852 (class 1259 OID 29023)
-- Name: idx_userhealthcondition_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_userhealthcondition_user ON public.userhealthcondition USING btree (user_id);


--
-- TOC entry 6056 (class 1259 OID 29024)
-- Name: idx_usermedication_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usermedication_user ON public.usermedication USING btree (user_id);


--
-- TOC entry 5964 (class 1259 OID 23150)
-- Name: idx_vitamin_nutrient_nutrient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vitamin_nutrient_nutrient ON public.vitaminnutrient USING btree (nutrient_id);


--
-- TOC entry 5965 (class 1259 OID 23149)
-- Name: idx_vitamin_nutrient_vitamin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vitamin_nutrient_vitamin ON public.vitaminnutrient USING btree (vitamin_id);


--
-- TOC entry 5953 (class 1259 OID 23911)
-- Name: idx_waterlog_drink; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_waterlog_drink ON public.waterlog USING btree (drink_id);


--
-- TOC entry 5710 (class 1259 OID 22028)
-- Name: uniq_nutrient_name_ci; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uniq_nutrient_name_ci ON public.nutrient USING btree (lower((name)::text));


--
-- TOC entry 5979 (class 1259 OID 23777)
-- Name: ux_manual_nutrient_user_date_nutrient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_manual_nutrient_user_date_nutrient ON public.usernutrientmanuallog USING btree (user_id, log_date, nutrient_id);


--
-- TOC entry 5795 (class 1259 OID 21888)
-- Name: ux_user_meal_targets_user_date_meal; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_user_meal_targets_user_date_meal ON public.user_meal_targets USING btree (user_id, target_date, meal_type);


--
-- TOC entry 6221 (class 2620 OID 22465)
-- Name: recipe recipe_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER recipe_update_timestamp BEFORE UPDATE ON public.recipe FOR EACH ROW EXECUTE FUNCTION public.update_recipe_timestamp();


--
-- TOC entry 6222 (class 2620 OID 22510)
-- Name: mealtemplate template_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER template_update_timestamp BEFORE UPDATE ON public.mealtemplate FOR EACH ROW EXECUTE FUNCTION public.update_recipe_timestamp();


--
-- TOC entry 6210 (class 2620 OID 24084)
-- Name: meal_entries trg_adjust_daily_summary_meal_entries; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_adjust_daily_summary_meal_entries AFTER INSERT OR DELETE OR UPDATE ON public.meal_entries FOR EACH ROW EXECUTE FUNCTION public.adjust_daily_summary_on_meal_entry_change();


--
-- TOC entry 6204 (class 2620 OID 21469)
-- Name: mealitem trg_adjust_daily_summary_mealitem; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_adjust_daily_summary_mealitem AFTER INSERT OR DELETE OR UPDATE ON public.mealitem FOR EACH ROW EXECUTE FUNCTION public.adjust_daily_summary_on_mealitem_change();


--
-- TOC entry 6218 (class 2620 OID 22391)
-- Name: userhealthcondition trg_calculate_treatment_duration; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_calculate_treatment_duration BEFORE INSERT OR UPDATE ON public.userhealthcondition FOR EACH ROW EXECUTE FUNCTION public.calculate_treatment_duration();


--
-- TOC entry 6228 (class 2620 OID 24105)
-- Name: waterlog trg_check_water_reset; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_water_reset BEFORE INSERT ON public.waterlog FOR EACH ROW EXECUTE FUNCTION public.trg_check_water_reset_on_log();


--
-- TOC entry 6205 (class 2620 OID 23961)
-- Name: mealitem trg_compute_fiber_fattyintake; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_compute_fiber_fattyintake AFTER INSERT OR DELETE OR UPDATE ON public.mealitem FOR EACH ROW EXECUTE FUNCTION public.compute_and_upsert_fiber_fattyintake();


--
-- TOC entry 6211 (class 2620 OID 24079)
-- Name: meal_entries trg_compute_fiber_fattyintake_meal_entries; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_compute_fiber_fattyintake_meal_entries AFTER INSERT OR DELETE OR UPDATE ON public.meal_entries FOR EACH ROW EXECUTE FUNCTION public.compute_and_upsert_fiber_fattyintake_meal_entries();


--
-- TOC entry 6206 (class 2620 OID 22825)
-- Name: mealitem trg_compute_mealitem_nutrients; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_compute_mealitem_nutrients BEFORE INSERT OR UPDATE ON public.mealitem FOR EACH ROW EXECUTE FUNCTION public.compute_mealitem_nutrients();


--
-- TOC entry 6197 (class 2620 OID 21471)
-- Name: userprofile trg_compute_userprofile_daily_water; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_compute_userprofile_daily_water BEFORE INSERT OR UPDATE ON public.userprofile FOR EACH ROW EXECUTE FUNCTION public.compute_userprofile_daily_water_target();


--
-- TOC entry 6226 (class 2620 OID 22824)
-- Name: dishingredient trg_dish_ingredient_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_dish_ingredient_changed AFTER INSERT OR DELETE OR UPDATE ON public.dishingredient FOR EACH ROW EXECUTE FUNCTION public.trg_recalc_dish_nutrients();


--
-- TOC entry 6207 (class 2620 OID 22827)
-- Name: mealitem trg_dish_statistics; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_dish_statistics AFTER INSERT ON public.mealitem FOR EACH ROW EXECUTE FUNCTION public.update_dish_statistics();


--
-- TOC entry 6213 (class 2620 OID 24099)
-- Name: bodymeasurement trg_log_body_measurement; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_body_measurement AFTER INSERT ON public.bodymeasurement FOR EACH ROW EXECUTE FUNCTION public.trg_log_body_measurement();


--
-- TOC entry 6223 (class 2620 OID 24091)
-- Name: dish trg_log_dish_created; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_dish_created AFTER INSERT ON public.dish FOR EACH ROW WHEN ((new.created_by_user IS NOT NULL)) EXECUTE FUNCTION public.trg_log_dish_created();


--
-- TOC entry 6230 (class 2620 OID 24093)
-- Name: drink trg_log_drink_created; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_drink_created AFTER INSERT ON public.drink FOR EACH ROW WHEN ((new.created_by_user IS NOT NULL)) EXECUTE FUNCTION public.trg_log_drink_created();


--
-- TOC entry 6219 (class 2620 OID 24101)
-- Name: userhealthcondition trg_log_health_condition_added; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_health_condition_added AFTER INSERT ON public.userhealthcondition FOR EACH ROW EXECUTE FUNCTION public.trg_log_health_condition_added();


--
-- TOC entry 6208 (class 2620 OID 24087)
-- Name: mealitem trg_log_meal_created; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_meal_created AFTER INSERT ON public.mealitem FOR EACH ROW EXECUTE FUNCTION public.trg_log_meal_created();


--
-- TOC entry 6212 (class 2620 OID 24089)
-- Name: meal_entries trg_log_meal_entry_created; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_meal_entry_created AFTER INSERT ON public.meal_entries FOR EACH ROW EXECUTE FUNCTION public.trg_log_meal_entry_created();


--
-- TOC entry 6220 (class 2620 OID 24097)
-- Name: medicationlog trg_log_medication_taken; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_medication_taken AFTER INSERT ON public.medicationlog FOR EACH ROW EXECUTE FUNCTION public.trg_log_medication_taken();


--
-- TOC entry 6229 (class 2620 OID 24095)
-- Name: waterlog trg_log_water_logged; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_water_logged AFTER INSERT ON public.waterlog FOR EACH ROW EXECUTE FUNCTION public.trg_log_water_logged();


--
-- TOC entry 6224 (class 2620 OID 22874)
-- Name: dish trg_notify_dish_approved; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_notify_dish_approved AFTER UPDATE ON public.dish FOR EACH ROW WHEN ((new.created_by_user IS NOT NULL)) EXECUTE FUNCTION public.notify_dish_approved();


--
-- TOC entry 6225 (class 2620 OID 22873)
-- Name: dish trg_notify_dish_created; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_notify_dish_created AFTER INSERT ON public.dish FOR EACH ROW WHEN (((new.created_by_user IS NOT NULL) AND (new.is_template = false))) EXECUTE FUNCTION public.notify_dish_created();


--
-- TOC entry 6227 (class 2620 OID 22875)
-- Name: dishstatistics trg_notify_dish_popular; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_notify_dish_popular AFTER UPDATE ON public.dishstatistics FOR EACH ROW EXECUTE FUNCTION public.notify_dish_popular();


--
-- TOC entry 6231 (class 2620 OID 24622)
-- Name: drinkingredient trg_recalc_drink_nutrients; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_recalc_drink_nutrients AFTER INSERT OR DELETE OR UPDATE ON public.drinkingredient FOR EACH ROW EXECUTE FUNCTION public.trigger_recalculate_drink_nutrients();


--
-- TOC entry 6217 (class 2620 OID 22163)
-- Name: adminmessage trg_update_admin_conversation_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_admin_conversation_timestamp AFTER INSERT ON public.adminmessage FOR EACH ROW EXECUTE FUNCTION public.update_conversation_timestamp();


--
-- TOC entry 6216 (class 2620 OID 22162)
-- Name: chatbotmessage trg_update_chatbot_conversation_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_chatbot_conversation_timestamp AFTER INSERT ON public.chatbotmessage FOR EACH ROW EXECUTE FUNCTION public.update_conversation_timestamp();


--
-- TOC entry 6232 (class 2620 OID 24069)
-- Name: drug trg_update_drug_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_drug_updated_at BEFORE UPDATE ON public.drug FOR EACH ROW EXECUTE FUNCTION public.update_drug_updated_at();


--
-- TOC entry 6203 (class 2620 OID 22190)
-- Name: food trg_update_food_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_food_timestamp BEFORE UPDATE ON public.food FOR EACH ROW EXECUTE FUNCTION public.update_food_timestamp();


--
-- TOC entry 6233 (class 2620 OID 24506)
-- Name: friendrequest trg_update_friend_request_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_friend_request_timestamp BEFORE UPDATE ON public.friendrequest FOR EACH ROW EXECUTE FUNCTION public.update_friend_request_timestamp();


--
-- TOC entry 6209 (class 2620 OID 23962)
-- Name: mealitem trg_update_nutrient_tracking; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_nutrient_tracking AFTER INSERT OR DELETE OR UPDATE ON public.mealitem FOR EACH ROW EXECUTE FUNCTION public.update_nutrient_tracking();


--
-- TOC entry 6234 (class 2620 OID 24611)
-- Name: privatemessage trg_update_private_conversation_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_private_conversation_timestamp AFTER INSERT ON public.privatemessage FOR EACH ROW EXECUTE FUNCTION public.update_private_conversation_timestamp();


--
-- TOC entry 6191 (class 2620 OID 23791)
-- Name: User trg_user_amino_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_user_amino_refresh AFTER UPDATE OF weight_kg, gender, age ON public."User" FOR EACH ROW WHEN (((old.weight_kg IS DISTINCT FROM new.weight_kg) OR ((old.gender)::text IS DISTINCT FROM (new.gender)::text) OR (old.age IS DISTINCT FROM new.age))) EXECUTE FUNCTION public.trg_refresh_user_amino_from_user();


--
-- TOC entry 6192 (class 2620 OID 23959)
-- Name: User trg_user_fatty_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_user_fatty_refresh AFTER UPDATE OF weight_kg, gender ON public."User" FOR EACH ROW WHEN (((old.weight_kg IS DISTINCT FROM new.weight_kg) OR ((old.gender)::text IS DISTINCT FROM (new.gender)::text))) EXECUTE FUNCTION public.trg_refresh_user_fatty_from_user();


--
-- TOC entry 6193 (class 2620 OID 23958)
-- Name: User trg_user_fiber_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_user_fiber_refresh AFTER UPDATE OF weight_kg, gender ON public."User" FOR EACH ROW WHEN (((old.weight_kg IS DISTINCT FROM new.weight_kg) OR ((old.gender)::text IS DISTINCT FROM (new.gender)::text))) EXECUTE FUNCTION public.trg_refresh_user_fiber_from_user();


--
-- TOC entry 6194 (class 2620 OID 21603)
-- Name: User trg_user_mineral_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_user_mineral_refresh AFTER UPDATE OF weight_kg, gender ON public."User" FOR EACH ROW WHEN (((old.weight_kg IS DISTINCT FROM new.weight_kg) OR ((old.gender)::text IS DISTINCT FROM (new.gender)::text))) EXECUTE FUNCTION public.trg_refresh_user_minerals_from_user();


--
-- TOC entry 6195 (class 2620 OID 21523)
-- Name: User trg_user_vitamin_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_user_vitamin_refresh AFTER UPDATE OF weight_kg, gender ON public."User" FOR EACH ROW WHEN (((old.weight_kg IS DISTINCT FROM new.weight_kg) OR ((old.gender)::text IS DISTINCT FROM (new.gender)::text))) EXECUTE FUNCTION public.trg_refresh_user_vitamins_from_user();


--
-- TOC entry 6196 (class 2620 OID 21473)
-- Name: User trg_user_weight_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_user_weight_changed AFTER UPDATE OF weight_kg ON public."User" FOR EACH ROW WHEN ((old.weight_kg IS DISTINCT FROM new.weight_kg)) EXECUTE FUNCTION public.notify_user_weight_change();


--
-- TOC entry 6198 (class 2620 OID 23790)
-- Name: userprofile trg_userprofile_amino_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_userprofile_amino_refresh AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON public.userprofile FOR EACH ROW EXECUTE FUNCTION public.trg_refresh_user_amino_from_userprofile();


--
-- TOC entry 6199 (class 2620 OID 23957)
-- Name: userprofile trg_userprofile_fatty_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_userprofile_fatty_refresh AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON public.userprofile FOR EACH ROW EXECUTE FUNCTION public.trg_refresh_user_fatty_from_userprofile();


--
-- TOC entry 6200 (class 2620 OID 23956)
-- Name: userprofile trg_userprofile_fiber_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_userprofile_fiber_refresh AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON public.userprofile FOR EACH ROW EXECUTE FUNCTION public.trg_refresh_user_fiber_from_userprofile();


--
-- TOC entry 6201 (class 2620 OID 21602)
-- Name: userprofile trg_userprofile_mineral_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_userprofile_mineral_refresh AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON public.userprofile FOR EACH ROW EXECUTE FUNCTION public.trg_refresh_user_minerals_from_userprofile();


--
-- TOC entry 6202 (class 2620 OID 21522)
-- Name: userprofile trg_userprofile_vitamin_refresh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_userprofile_vitamin_refresh AFTER INSERT OR UPDATE OF activity_factor, tdee, goal_type ON public.userprofile FOR EACH ROW EXECUTE FUNCTION public.trg_refresh_user_vitamins_from_userprofile();


--
-- TOC entry 6214 (class 2620 OID 22052)
-- Name: bodymeasurement trigger_calculate_bmi; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_calculate_bmi BEFORE INSERT OR UPDATE ON public.bodymeasurement FOR EACH ROW EXECUTE FUNCTION public.calculate_bmi_and_score();


--
-- TOC entry 6215 (class 2620 OID 22054)
-- Name: bodymeasurement trigger_sync_to_user; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_sync_to_user AFTER INSERT ON public.bodymeasurement FOR EACH ROW EXECUTE FUNCTION public.sync_latest_measurement_to_user();


--
-- TOC entry 6116 (class 2606 OID 22108)
-- Name: adminconversation adminconversation_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminconversation
    ADD CONSTRAINT adminconversation_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6117 (class 2606 OID 22132)
-- Name: adminmessage adminmessage_admin_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminmessage
    ADD CONSTRAINT adminmessage_admin_conversation_id_fkey FOREIGN KEY (admin_conversation_id) REFERENCES public.adminconversation(admin_conversation_id) ON DELETE CASCADE;


--
-- TOC entry 6062 (class 2606 OID 21192)
-- Name: adminrole adminrole_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminrole
    ADD CONSTRAINT adminrole_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admin(admin_id) ON DELETE CASCADE;


--
-- TOC entry 6063 (class 2606 OID 21197)
-- Name: adminrole adminrole_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminrole
    ADD CONSTRAINT adminrole_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(role_id) ON DELETE CASCADE;


--
-- TOC entry 6102 (class 2606 OID 21817)
-- Name: aminorequirement aminorequirement_amino_acid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aminorequirement
    ADD CONSTRAINT aminorequirement_amino_acid_id_fkey FOREIGN KEY (amino_acid_id) REFERENCES public.aminoacid(amino_acid_id) ON DELETE CASCADE;


--
-- TOC entry 6113 (class 2606 OID 22045)
-- Name: bodymeasurement bodymeasurement_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bodymeasurement
    ADD CONSTRAINT bodymeasurement_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6114 (class 2606 OID 22067)
-- Name: chatbotconversation chatbotconversation_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbotconversation
    ADD CONSTRAINT chatbotconversation_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6115 (class 2606 OID 22088)
-- Name: chatbotmessage chatbotmessage_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbotmessage
    ADD CONSTRAINT chatbotmessage_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.chatbotconversation(conversation_id) ON DELETE CASCADE;


--
-- TOC entry 6184 (class 2606 OID 24521)
-- Name: communitymessage communitymessage_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communitymessage
    ADD CONSTRAINT communitymessage_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6131 (class 2606 OID 22374)
-- Name: conditioneffectlog conditioneffectlog_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditioneffectlog
    ADD CONSTRAINT conditioneffectlog_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.healthcondition(condition_id);


--
-- TOC entry 6132 (class 2606 OID 22379)
-- Name: conditioneffectlog conditioneffectlog_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditioneffectlog
    ADD CONSTRAINT conditioneffectlog_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id);


--
-- TOC entry 6133 (class 2606 OID 22369)
-- Name: conditioneffectlog conditioneffectlog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditioneffectlog
    ADD CONSTRAINT conditioneffectlog_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6129 (class 2606 OID 22350)
-- Name: conditionfoodrecommendation conditionfoodrecommendation_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionfoodrecommendation
    ADD CONSTRAINT conditionfoodrecommendation_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.healthcondition(condition_id) ON DELETE CASCADE;


--
-- TOC entry 6130 (class 2606 OID 22355)
-- Name: conditionfoodrecommendation conditionfoodrecommendation_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionfoodrecommendation
    ADD CONSTRAINT conditionfoodrecommendation_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE CASCADE;


--
-- TOC entry 6127 (class 2606 OID 22326)
-- Name: conditionnutrienteffect conditionnutrienteffect_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionnutrienteffect
    ADD CONSTRAINT conditionnutrienteffect_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.healthcondition(condition_id) ON DELETE CASCADE;


--
-- TOC entry 6128 (class 2606 OID 22331)
-- Name: conditionnutrienteffect conditionnutrienteffect_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditionnutrienteffect
    ADD CONSTRAINT conditionnutrienteffect_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6076 (class 2606 OID 21347)
-- Name: dailysummary dailysummary_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dailysummary
    ADD CONSTRAINT dailysummary_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6149 (class 2606 OID 22704)
-- Name: dish dish_created_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish
    ADD CONSTRAINT dish_created_by_admin_fkey FOREIGN KEY (created_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6150 (class 2606 OID 22699)
-- Name: dish dish_created_by_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish
    ADD CONSTRAINT dish_created_by_user_fkey FOREIGN KEY (created_by_user) REFERENCES public."User"(user_id) ON DELETE SET NULL;


--
-- TOC entry 6153 (class 2606 OID 22761)
-- Name: dishimage dishimage_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishimage
    ADD CONSTRAINT dishimage_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(dish_id) ON DELETE CASCADE;


--
-- TOC entry 6151 (class 2606 OID 22732)
-- Name: dishingredient dishingredient_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishingredient
    ADD CONSTRAINT dishingredient_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(dish_id) ON DELETE CASCADE;


--
-- TOC entry 6152 (class 2606 OID 22737)
-- Name: dishingredient dishingredient_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishingredient
    ADD CONSTRAINT dishingredient_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE RESTRICT;


--
-- TOC entry 6157 (class 2606 OID 22862)
-- Name: dishnotification dishnotification_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnotification
    ADD CONSTRAINT dishnotification_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(dish_id) ON DELETE CASCADE;


--
-- TOC entry 6158 (class 2606 OID 22857)
-- Name: dishnotification dishnotification_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnotification
    ADD CONSTRAINT dishnotification_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.userprofile(user_id) ON DELETE CASCADE;


--
-- TOC entry 6155 (class 2606 OID 22810)
-- Name: dishnutrient dishnutrient_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnutrient
    ADD CONSTRAINT dishnutrient_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(dish_id) ON DELETE CASCADE;


--
-- TOC entry 6156 (class 2606 OID 22815)
-- Name: dishnutrient dishnutrient_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishnutrient
    ADD CONSTRAINT dishnutrient_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6154 (class 2606 OID 22789)
-- Name: dishstatistics dishstatistics_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishstatistics
    ADD CONSTRAINT dishstatistics_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(dish_id) ON DELETE CASCADE;


--
-- TOC entry 6168 (class 2606 OID 23822)
-- Name: drink drink_created_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drink
    ADD CONSTRAINT drink_created_by_admin_fkey FOREIGN KEY (created_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6169 (class 2606 OID 23817)
-- Name: drink drink_created_by_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drink
    ADD CONSTRAINT drink_created_by_user_fkey FOREIGN KEY (created_by_user) REFERENCES public."User"(user_id) ON DELETE SET NULL;


--
-- TOC entry 6170 (class 2606 OID 23848)
-- Name: drinkingredient drinkingredient_drink_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkingredient
    ADD CONSTRAINT drinkingredient_drink_id_fkey FOREIGN KEY (drink_id) REFERENCES public.drink(drink_id) ON DELETE CASCADE;


--
-- TOC entry 6171 (class 2606 OID 23853)
-- Name: drinkingredient drinkingredient_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkingredient
    ADD CONSTRAINT drinkingredient_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE RESTRICT;


--
-- TOC entry 6172 (class 2606 OID 23873)
-- Name: drinknutrient drinknutrient_drink_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinknutrient
    ADD CONSTRAINT drinknutrient_drink_id_fkey FOREIGN KEY (drink_id) REFERENCES public.drink(drink_id) ON DELETE CASCADE;


--
-- TOC entry 6173 (class 2606 OID 23878)
-- Name: drinknutrient drinknutrient_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinknutrient
    ADD CONSTRAINT drinknutrient_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6174 (class 2606 OID 23899)
-- Name: drinkstatistics drinkstatistics_drink_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinkstatistics
    ADD CONSTRAINT drinkstatistics_drink_id_fkey FOREIGN KEY (drink_id) REFERENCES public.drink(drink_id) ON DELETE CASCADE;


--
-- TOC entry 6175 (class 2606 OID 23983)
-- Name: drug drug_created_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug
    ADD CONSTRAINT drug_created_by_admin_fkey FOREIGN KEY (created_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6176 (class 2606 OID 24011)
-- Name: drughealthcondition drughealthcondition_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drughealthcondition
    ADD CONSTRAINT drughealthcondition_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.healthcondition(condition_id) ON DELETE CASCADE;


--
-- TOC entry 6177 (class 2606 OID 24006)
-- Name: drughealthcondition drughealthcondition_drug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drughealthcondition
    ADD CONSTRAINT drughealthcondition_drug_id_fkey FOREIGN KEY (drug_id) REFERENCES public.drug(drug_id) ON DELETE CASCADE;


--
-- TOC entry 6178 (class 2606 OID 24036)
-- Name: drugnutrientcontraindication drugnutrientcontraindication_drug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drugnutrientcontraindication
    ADD CONSTRAINT drugnutrientcontraindication_drug_id_fkey FOREIGN KEY (drug_id) REFERENCES public.drug(drug_id) ON DELETE CASCADE;


--
-- TOC entry 6179 (class 2606 OID 24041)
-- Name: drugnutrientcontraindication drugnutrientcontraindication_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drugnutrientcontraindication
    ADD CONSTRAINT drugnutrientcontraindication_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6090 (class 2606 OID 21672)
-- Name: fattyacidrequirement fattyacidrequirement_fatty_acid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fattyacidrequirement
    ADD CONSTRAINT fattyacidrequirement_fatty_acid_id_fkey FOREIGN KEY (fatty_acid_id) REFERENCES public.fattyacid(fatty_acid_id) ON DELETE CASCADE;


--
-- TOC entry 6089 (class 2606 OID 21654)
-- Name: fiberrequirement fiberrequirement_fiber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fiberrequirement
    ADD CONSTRAINT fiberrequirement_fiber_id_fkey FOREIGN KEY (fiber_id) REFERENCES public.fiber(fiber_id) ON DELETE CASCADE;


--
-- TOC entry 6064 (class 2606 OID 21214)
-- Name: food food_created_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food
    ADD CONSTRAINT food_created_by_admin_fkey FOREIGN KEY (created_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6065 (class 2606 OID 22177)
-- Name: food food_created_by_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food
    ADD CONSTRAINT food_created_by_user_fkey FOREIGN KEY (created_by_user) REFERENCES public."User"(user_id) ON DELETE SET NULL;


--
-- TOC entry 6067 (class 2606 OID 21245)
-- Name: foodnutrient foodnutrient_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodnutrient
    ADD CONSTRAINT foodnutrient_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE CASCADE;


--
-- TOC entry 6068 (class 2606 OID 21250)
-- Name: foodnutrient foodnutrient_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodnutrient
    ADD CONSTRAINT foodnutrient_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6069 (class 2606 OID 21271)
-- Name: foodtagmapping foodtagmapping_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodtagmapping
    ADD CONSTRAINT foodtagmapping_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE CASCADE;


--
-- TOC entry 6070 (class 2606 OID 21276)
-- Name: foodtagmapping foodtagmapping_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foodtagmapping
    ADD CONSTRAINT foodtagmapping_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.foodtag(tag_id) ON DELETE CASCADE;


--
-- TOC entry 6180 (class 2606 OID 24470)
-- Name: friendrequest friendrequest_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendrequest
    ADD CONSTRAINT friendrequest_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6181 (class 2606 OID 24465)
-- Name: friendrequest friendrequest_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendrequest
    ADD CONSTRAINT friendrequest_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6182 (class 2606 OID 24492)
-- Name: friendship friendship_user1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendship
    ADD CONSTRAINT friendship_user1_id_fkey FOREIGN KEY (user1_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6183 (class 2606 OID 24497)
-- Name: friendship friendship_user2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendship
    ADD CONSTRAINT friendship_user2_id_fkey FOREIGN KEY (user2_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6108 (class 2606 OID 21906)
-- Name: meal_entries meal_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_entries
    ADD CONSTRAINT meal_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6071 (class 2606 OID 21292)
-- Name: meal meal_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal
    ADD CONSTRAINT meal_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6072 (class 2606 OID 22768)
-- Name: mealitem mealitem_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealitem
    ADD CONSTRAINT mealitem_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(dish_id) ON DELETE SET NULL;


--
-- TOC entry 6073 (class 2606 OID 21312)
-- Name: mealitem mealitem_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealitem
    ADD CONSTRAINT mealitem_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE CASCADE;


--
-- TOC entry 6074 (class 2606 OID 21307)
-- Name: mealitem mealitem_meal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealitem
    ADD CONSTRAINT mealitem_meal_id_fkey FOREIGN KEY (meal_id) REFERENCES public.meal(meal_id) ON DELETE CASCADE;


--
-- TOC entry 6075 (class 2606 OID 21328)
-- Name: mealnote mealnote_meal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealnote
    ADD CONSTRAINT mealnote_meal_id_fkey FOREIGN KEY (meal_id) REFERENCES public.meal(meal_id) ON DELETE CASCADE;


--
-- TOC entry 6138 (class 2606 OID 22482)
-- Name: mealtemplate mealtemplate_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealtemplate
    ADD CONSTRAINT mealtemplate_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6139 (class 2606 OID 22502)
-- Name: mealtemplateitem mealtemplateitem_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealtemplateitem
    ADD CONSTRAINT mealtemplateitem_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE CASCADE;


--
-- TOC entry 6140 (class 2606 OID 22497)
-- Name: mealtemplateitem mealtemplateitem_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mealtemplateitem
    ADD CONSTRAINT mealtemplateitem_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.mealtemplate(template_id) ON DELETE CASCADE;


--
-- TOC entry 6124 (class 2606 OID 24054)
-- Name: medicationlog medicationlog_drug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationlog
    ADD CONSTRAINT medicationlog_drug_id_fkey FOREIGN KEY (drug_id) REFERENCES public.drug(drug_id) ON DELETE SET NULL;


--
-- TOC entry 6125 (class 2606 OID 22302)
-- Name: medicationlog medicationlog_user_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationlog
    ADD CONSTRAINT medicationlog_user_condition_id_fkey FOREIGN KEY (user_condition_id) REFERENCES public.userhealthcondition(user_condition_id) ON DELETE CASCADE;


--
-- TOC entry 6126 (class 2606 OID 22307)
-- Name: medicationlog medicationlog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationlog
    ADD CONSTRAINT medicationlog_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6121 (class 2606 OID 24048)
-- Name: medicationschedule medicationschedule_drug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationschedule
    ADD CONSTRAINT medicationschedule_drug_id_fkey FOREIGN KEY (drug_id) REFERENCES public.drug(drug_id) ON DELETE SET NULL;


--
-- TOC entry 6122 (class 2606 OID 22278)
-- Name: medicationschedule medicationschedule_user_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationschedule
    ADD CONSTRAINT medicationschedule_user_condition_id_fkey FOREIGN KEY (user_condition_id) REFERENCES public.userhealthcondition(user_condition_id) ON DELETE CASCADE;


--
-- TOC entry 6123 (class 2606 OID 22283)
-- Name: medicationschedule medicationschedule_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicationschedule
    ADD CONSTRAINT medicationschedule_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6185 (class 2606 OID 24547)
-- Name: messagereaction messagereaction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messagereaction
    ADD CONSTRAINT messagereaction_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6085 (class 2606 OID 21556)
-- Name: mineral mineral_created_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineral
    ADD CONSTRAINT mineral_created_by_admin_fkey FOREIGN KEY (created_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6165 (class 2606 OID 23168)
-- Name: mineralnutrient mineralnutrient_mineral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineralnutrient
    ADD CONSTRAINT mineralnutrient_mineral_id_fkey FOREIGN KEY (mineral_id) REFERENCES public.mineral(mineral_id) ON DELETE CASCADE;


--
-- TOC entry 6166 (class 2606 OID 23173)
-- Name: mineralnutrient mineralnutrient_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineralnutrient
    ADD CONSTRAINT mineralnutrient_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6086 (class 2606 OID 21571)
-- Name: mineralrda mineralrda_mineral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mineralrda
    ADD CONSTRAINT mineralrda_mineral_id_fkey FOREIGN KEY (mineral_id) REFERENCES public.mineral(mineral_id) ON DELETE CASCADE;


--
-- TOC entry 6066 (class 2606 OID 21230)
-- Name: nutrient nutrient_created_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrient
    ADD CONSTRAINT nutrient_created_by_admin_fkey FOREIGN KEY (created_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6110 (class 2606 OID 21958)
-- Name: nutrientcontraindication nutrientcontraindication_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientcontraindication
    ADD CONSTRAINT nutrientcontraindication_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6099 (class 2606 OID 21780)
-- Name: nutrientmapping nutrientmapping_fatty_acid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientmapping
    ADD CONSTRAINT nutrientmapping_fatty_acid_id_fkey FOREIGN KEY (fatty_acid_id) REFERENCES public.fattyacid(fatty_acid_id) ON DELETE CASCADE;


--
-- TOC entry 6100 (class 2606 OID 21775)
-- Name: nutrientmapping nutrientmapping_fiber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientmapping
    ADD CONSTRAINT nutrientmapping_fiber_id_fkey FOREIGN KEY (fiber_id) REFERENCES public.fiber(fiber_id) ON DELETE CASCADE;


--
-- TOC entry 6101 (class 2606 OID 21770)
-- Name: nutrientmapping nutrientmapping_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutrientmapping
    ADD CONSTRAINT nutrientmapping_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6118 (class 2606 OID 22153)
-- Name: nutritionanalysis nutritionanalysis_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutritionanalysis
    ADD CONSTRAINT nutritionanalysis_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6142 (class 2606 OID 22592)
-- Name: passwordchangecode passwordchangecode_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passwordchangecode
    ADD CONSTRAINT passwordchangecode_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6134 (class 2606 OID 22411)
-- Name: portionsize portionsize_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portionsize
    ADD CONSTRAINT portionsize_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE CASCADE;


--
-- TOC entry 6186 (class 2606 OID 24569)
-- Name: privateconversation privateconversation_user1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privateconversation
    ADD CONSTRAINT privateconversation_user1_id_fkey FOREIGN KEY (user1_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6187 (class 2606 OID 24574)
-- Name: privateconversation privateconversation_user2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privateconversation
    ADD CONSTRAINT privateconversation_user2_id_fkey FOREIGN KEY (user2_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6188 (class 2606 OID 24595)
-- Name: privatemessage privatemessage_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privatemessage
    ADD CONSTRAINT privatemessage_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.privateconversation(conversation_id) ON DELETE CASCADE;


--
-- TOC entry 6189 (class 2606 OID 24600)
-- Name: privatemessage privatemessage_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.privatemessage
    ADD CONSTRAINT privatemessage_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6135 (class 2606 OID 22432)
-- Name: recipe recipe_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe
    ADD CONSTRAINT recipe_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6136 (class 2606 OID 22456)
-- Name: recipeingredient recipeingredient_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipeingredient
    ADD CONSTRAINT recipeingredient_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food(food_id) ON DELETE CASCADE;


--
-- TOC entry 6137 (class 2606 OID 22451)
-- Name: recipeingredient recipeingredient_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipeingredient
    ADD CONSTRAINT recipeingredient_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipe(recipe_id) ON DELETE CASCADE;


--
-- TOC entry 6161 (class 2606 OID 23113)
-- Name: rolepermission rolepermission_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolepermission
    ADD CONSTRAINT rolepermission_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permission(permission_id) ON DELETE CASCADE;


--
-- TOC entry 6162 (class 2606 OID 23108)
-- Name: rolepermission rolepermission_role_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolepermission
    ADD CONSTRAINT rolepermission_role_name_fkey FOREIGN KEY (role_name) REFERENCES public.role(role_name) ON DELETE CASCADE;


--
-- TOC entry 6077 (class 2606 OID 21368)
-- Name: suggestion suggestion_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggestion
    ADD CONSTRAINT suggestion_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id);


--
-- TOC entry 6078 (class 2606 OID 21373)
-- Name: suggestion suggestion_suggested_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggestion
    ADD CONSTRAINT suggestion_suggested_food_id_fkey FOREIGN KEY (suggested_food_id) REFERENCES public.food(food_id);


--
-- TOC entry 6079 (class 2606 OID 21363)
-- Name: suggestion suggestion_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggestion
    ADD CONSTRAINT suggestion_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6143 (class 2606 OID 22619)
-- Name: user_account_status user_account_status_blocked_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account_status
    ADD CONSTRAINT user_account_status_blocked_by_admin_fkey FOREIGN KEY (blocked_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6144 (class 2606 OID 22614)
-- Name: user_account_status user_account_status_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account_status
    ADD CONSTRAINT user_account_status_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6145 (class 2606 OID 22643)
-- Name: user_block_event user_block_event_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_block_event
    ADD CONSTRAINT user_block_event_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6146 (class 2606 OID 22638)
-- Name: user_block_event user_block_event_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_block_event
    ADD CONSTRAINT user_block_event_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6109 (class 2606 OID 21930)
-- Name: user_meal_summaries user_meal_summaries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_meal_summaries
    ADD CONSTRAINT user_meal_summaries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6107 (class 2606 OID 21883)
-- Name: user_meal_targets user_meal_targets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_meal_targets
    ADD CONSTRAINT user_meal_targets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6147 (class 2606 OID 22669)
-- Name: user_unblock_request user_unblock_request_decided_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_unblock_request
    ADD CONSTRAINT user_unblock_request_decided_by_admin_fkey FOREIGN KEY (decided_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6148 (class 2606 OID 22664)
-- Name: user_unblock_request user_unblock_request_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_unblock_request
    ADD CONSTRAINT user_unblock_request_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6061 (class 2606 OID 21154)
-- Name: useractivitylog useractivitylog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useractivitylog
    ADD CONSTRAINT useractivitylog_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6105 (class 2606 OID 21860)
-- Name: useraminointake useraminointake_amino_acid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraminointake
    ADD CONSTRAINT useraminointake_amino_acid_id_fkey FOREIGN KEY (amino_acid_id) REFERENCES public.aminoacid(amino_acid_id) ON DELETE CASCADE;


--
-- TOC entry 6106 (class 2606 OID 21855)
-- Name: useraminointake useraminointake_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraminointake
    ADD CONSTRAINT useraminointake_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6103 (class 2606 OID 21837)
-- Name: useraminorequirement useraminorequirement_amino_acid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraminorequirement
    ADD CONSTRAINT useraminorequirement_amino_acid_id_fkey FOREIGN KEY (amino_acid_id) REFERENCES public.aminoacid(amino_acid_id) ON DELETE CASCADE;


--
-- TOC entry 6104 (class 2606 OID 21832)
-- Name: useraminorequirement useraminorequirement_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraminorequirement
    ADD CONSTRAINT useraminorequirement_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6097 (class 2606 OID 21752)
-- Name: userfattyacidintake userfattyacidintake_fatty_acid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfattyacidintake
    ADD CONSTRAINT userfattyacidintake_fatty_acid_id_fkey FOREIGN KEY (fatty_acid_id) REFERENCES public.fattyacid(fatty_acid_id) ON DELETE CASCADE;


--
-- TOC entry 6098 (class 2606 OID 21747)
-- Name: userfattyacidintake userfattyacidintake_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfattyacidintake
    ADD CONSTRAINT userfattyacidintake_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6093 (class 2606 OID 21712)
-- Name: userfattyacidrequirement userfattyacidrequirement_fatty_acid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfattyacidrequirement
    ADD CONSTRAINT userfattyacidrequirement_fatty_acid_id_fkey FOREIGN KEY (fatty_acid_id) REFERENCES public.fattyacid(fatty_acid_id) ON DELETE CASCADE;


--
-- TOC entry 6094 (class 2606 OID 21707)
-- Name: userfattyacidrequirement userfattyacidrequirement_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfattyacidrequirement
    ADD CONSTRAINT userfattyacidrequirement_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6095 (class 2606 OID 21732)
-- Name: userfiberintake userfiberintake_fiber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfiberintake
    ADD CONSTRAINT userfiberintake_fiber_id_fkey FOREIGN KEY (fiber_id) REFERENCES public.fiber(fiber_id) ON DELETE CASCADE;


--
-- TOC entry 6096 (class 2606 OID 21727)
-- Name: userfiberintake userfiberintake_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfiberintake
    ADD CONSTRAINT userfiberintake_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6091 (class 2606 OID 21692)
-- Name: userfiberrequirement userfiberrequirement_fiber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfiberrequirement
    ADD CONSTRAINT userfiberrequirement_fiber_id_fkey FOREIGN KEY (fiber_id) REFERENCES public.fiber(fiber_id) ON DELETE CASCADE;


--
-- TOC entry 6092 (class 2606 OID 21687)
-- Name: userfiberrequirement userfiberrequirement_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfiberrequirement
    ADD CONSTRAINT userfiberrequirement_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6080 (class 2606 OID 21402)
-- Name: usergoal usergoal_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usergoal
    ADD CONSTRAINT usergoal_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6119 (class 2606 OID 22262)
-- Name: userhealthcondition userhealthcondition_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userhealthcondition
    ADD CONSTRAINT userhealthcondition_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.healthcondition(condition_id) ON DELETE CASCADE;


--
-- TOC entry 6120 (class 2606 OID 22257)
-- Name: userhealthcondition userhealthcondition_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userhealthcondition
    ADD CONSTRAINT userhealthcondition_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6190 (class 2606 OID 29017)
-- Name: usermedication usermedication_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermedication
    ADD CONSTRAINT usermedication_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6087 (class 2606 OID 21594)
-- Name: usermineralrequirement usermineralrequirement_mineral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermineralrequirement
    ADD CONSTRAINT usermineralrequirement_mineral_id_fkey FOREIGN KEY (mineral_id) REFERENCES public.mineral(mineral_id) ON DELETE CASCADE;


--
-- TOC entry 6088 (class 2606 OID 21589)
-- Name: usermineralrequirement usermineralrequirement_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermineralrequirement
    ADD CONSTRAINT usermineralrequirement_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6167 (class 2606 OID 23772)
-- Name: usernutrientmanuallog usernutrientmanuallog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrientmanuallog
    ADD CONSTRAINT usernutrientmanuallog_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6112 (class 2606 OID 22011)
-- Name: usernutrientnotification usernutrientnotification_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrientnotification
    ADD CONSTRAINT usernutrientnotification_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6111 (class 2606 OID 21987)
-- Name: usernutrienttracking usernutrienttracking_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usernutrienttracking
    ADD CONSTRAINT usernutrienttracking_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6059 (class 2606 OID 21115)
-- Name: userprofile userprofile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userprofile
    ADD CONSTRAINT userprofile_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6141 (class 2606 OID 22575)
-- Name: usersecurity usersecurity_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usersecurity
    ADD CONSTRAINT usersecurity_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6060 (class 2606 OID 21138)
-- Name: usersetting usersetting_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usersetting
    ADD CONSTRAINT usersetting_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6082 (class 2606 OID 21509)
-- Name: uservitaminrequirement uservitaminrequirement_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uservitaminrequirement
    ADD CONSTRAINT uservitaminrequirement_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


--
-- TOC entry 6083 (class 2606 OID 21514)
-- Name: uservitaminrequirement uservitaminrequirement_vitamin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uservitaminrequirement
    ADD CONSTRAINT uservitaminrequirement_vitamin_id_fkey FOREIGN KEY (vitamin_id) REFERENCES public.vitamin(vitamin_id) ON DELETE CASCADE;


--
-- TOC entry 6081 (class 2606 OID 21490)
-- Name: vitamin vitamin_created_by_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitamin
    ADD CONSTRAINT vitamin_created_by_admin_fkey FOREIGN KEY (created_by_admin) REFERENCES public.admin(admin_id) ON DELETE SET NULL;


--
-- TOC entry 6163 (class 2606 OID 23144)
-- Name: vitaminnutrient vitaminnutrient_nutrient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitaminnutrient
    ADD CONSTRAINT vitaminnutrient_nutrient_id_fkey FOREIGN KEY (nutrient_id) REFERENCES public.nutrient(nutrient_id) ON DELETE CASCADE;


--
-- TOC entry 6164 (class 2606 OID 23139)
-- Name: vitaminnutrient vitaminnutrient_vitamin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitaminnutrient
    ADD CONSTRAINT vitaminnutrient_vitamin_id_fkey FOREIGN KEY (vitamin_id) REFERENCES public.vitamin(vitamin_id) ON DELETE CASCADE;


--
-- TOC entry 6084 (class 2606 OID 21535)
-- Name: vitaminrda vitaminrda_vitamin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitaminrda
    ADD CONSTRAINT vitaminrda_vitamin_id_fkey FOREIGN KEY (vitamin_id) REFERENCES public.vitamin(vitamin_id) ON DELETE CASCADE;


--
-- TOC entry 6159 (class 2606 OID 23906)
-- Name: waterlog waterlog_drink_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waterlog
    ADD CONSTRAINT waterlog_drink_id_fkey FOREIGN KEY (drink_id) REFERENCES public.drink(drink_id) ON DELETE SET NULL;


--
-- TOC entry 6160 (class 2606 OID 22947)
-- Name: waterlog waterlog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waterlog
    ADD CONSTRAINT waterlog_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id) ON DELETE CASCADE;


-- Completed on 2025-12-02 20:14:24

--
-- PostgreSQL database dump complete
--

\unrestrict u32gY70U2ENUoeX217dG0bbJvNOrRPAzsYCeDUSYrkUKQdc5RRSKvzGKIsZe5cj

