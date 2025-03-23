CREATE VIEW ProteinCalView AS
WITH FullData AS (
  SELECT 
    f.fdc_id,
    f.data_type,
    f.description,
    f.food_category_id,
    bf.branded_food_category,
    bf.brand_name,
    bf.short_description,
    bf.ingredients,
    COALESCE(prot.amount, 0) AS protein_g,
    COALESCE(fat.amount, 0) AS fat_g,
    -- Use sugars+starhes if carbohydrates are less than grams sugar and grams starches combined
    CASE 
      WHEN COALESCE(carb.amount, 0) < COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
      THEN COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
      ELSE COALESCE(carb.amount, 0)
    END AS carbohydrate_g,
    -- Calculate calories from macros using effective carbohydrate value.
    COALESCE(cals.amount,0) 
    AS joined_cals,
    
    CASE -- Determine final calories: if joined calories are less than the calculated calories, use calc_cals; otherwise use joined_cals.
      WHEN COALESCE(cals.amount,0) <= (COALESCE(prot.amount,0)*4.0+COALESCE(fat.amount,0)*9.0+ (CASE --Check that carbs are not less than sugars and starches
                                                                                                    WHEN COALESCE(carb.amount, 0) < COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                                    THEN COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                                    ELSE COALESCE(carb.amount, 0)
                                                                                                END)*4.0) 
      THEN (COALESCE(prot.amount,0)*4.0 + COALESCE(fat.amount,0)*9.0 + (CASE --Check that carbs are not less than sugars and starches
                                                                            WHEN COALESCE(carb.amount, 0) < COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                            THEN COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                            ELSE COALESCE(carb.amount, 0)
                                                                          END)*4.0)
      ELSE COALESCE(cals.amount,0)
    END 
    AS used_cals,
    -- Calculate calc_cals
    (COALESCE(prot.amount,0)*4.0 + COALESCE(fat.amount,0)*9.0 + (CASE --Check that carbs are not less than sugars and starches
                                                                    WHEN COALESCE(carb.amount, 0) < COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                    THEN COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                    ELSE COALESCE(carb.amount, 0)
                                                                 END)*4.0) 
    AS calc_cals,
    -- Calculate percentage of calories from protein using final calories.
    CASE 
      WHEN (CASE -- Again, Determine final calories: if joined calories are less than the calculated calories, use calc_cals; otherwise use joined_cals when calculating percentages
              WHEN COALESCE(cals.amount,0) <= (COALESCE(prot.amount,0)*4.0+COALESCE(fat.amount,0)*9.0+ (CASE --Check that carbs are not less than sugars and starches
                                                                                                            WHEN COALESCE(carb.amount, 0) < COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                                            THEN COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                                            ELSE COALESCE(carb.amount, 0)
                                                                                                        END)*4.0) 
              THEN (COALESCE(prot.amount,0)*4.0 + COALESCE(fat.amount,0)*9.0 + (CASE --Check that carbs are not less than sugars and starches
                                                                                  WHEN COALESCE(carb.amount, 0) < COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                  THEN COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                  ELSE COALESCE(carb.amount, 0)
                                                                                END)*4.0)
              ELSE COALESCE(cals.amount,0)
            END
          ) = 0 
      THEN 0
      ELSE ROUND((COALESCE(prot.amount,0)*4.0) / (CASE -- Again, Determine final calories: if joined calories are less than the calculated calories, use calc_cals; otherwise use joined_cals when calculating percentages
                                                      WHEN COALESCE(cals.amount,0) <= (COALESCE(prot.amount,0)*4.0+COALESCE(fat.amount,0)*9.0+ (CASE --Check that carbs are not less than sugars and starches
                                                                                                                                                        WHEN COALESCE(carb.amount, 0) < COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                                                                                        THEN COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                                                                                        ELSE COALESCE(carb.amount, 0)
                                                                                                                                                    END)*4.0) 
                                                      THEN (COALESCE(prot.amount,0)*4.0 + COALESCE(fat.amount,0)*9.0 + (CASE 
                                                                                                                          WHEN COALESCE(carb.amount, 0) < COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                                                          THEN COALESCE(sug.amount, 0)+COALESCE(star.amount, 0)
                                                                                                                          ELSE COALESCE(carb.amount, 0)
                                                                                                                        END)*4.0)
                                                      ELSE COALESCE(cals.amount,0)
                                                  END) * 100, 2)
    END 
    AS pct_protein_calories
  FROM food f
  LEFT JOIN branded_food bf ON bf.fdc_id = f.fdc_id
  LEFT JOIN food_nutrient prot ON f.fdc_id = prot.fdc_id AND prot.nutrient_id = 1003
  LEFT JOIN food_nutrient fat  ON f.fdc_id = fat.fdc_id  AND fat.nutrient_id = 1004
  LEFT JOIN food_nutrient carb ON f.fdc_id = carb.fdc_id AND carb.nutrient_id = 1005
  LEFT JOIN food_nutrient sug  ON f.fdc_id = sug.fdc_id AND sug.nutrient_id = 2000
  LEFT JOIN food_nutrient star  ON f.fdc_id = star.fdc_id AND star.nutrient_id = 1009
  LEFT JOIN food_nutrient cals ON f.fdc_id = cals.fdc_id AND cals.nutrient_id = 1008
)
SELECT 
  description,  
  food_category_id,
  MAX(pct_protein_calories) AS pct_protein_calories,
  protein_g,
  fat_g,
  carbohydrate_g,
  MAX(calc_cals) AS calc_cals,
  MAX(joined_cals) AS joined_cals,
  MAX(used_cals) AS used_cals,
  MAX(brand_name) AS brand_name,
  MAX(short_description) AS short_description,
  MAX(ingredients) AS ingredients,
  MAX(branded_food_category) AS branded_food_category,
  MAX(fdc_id) AS fdc_id,
  MAX(data_type) AS data_type
FROM FullData
WHERE protein_g > 1 AND calc_cals > 4 AND pct_protein_calories <> 100 AND brand_name IS NOT NULL
GROUP BY 
  description,
  food_category_id,
  protein_g,
  fat_g,
  carbohydrate_g
ORDER BY pct_protein_calories DESC, food_category_id ASC, description ASC, brand_name ASC;
