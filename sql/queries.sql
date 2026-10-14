-- Consultas SQL sobre la tabla `movies` (películas analizables 1990-2010).
-- Se ejecutan en SQLite desde el notebook (sección 8). Cada consulta lleva su pregunta de negocio.

-- Q1. ¿Qué géneros combinan mejor tasa de éxito y rentabilidad media? (mínimo 30 películas)
-- name: genero_exito
SELECT major_genre,
       COUNT(*)                                   AS peliculas,
       ROUND(AVG(is_hit) * 100, 1)                AS pct_exito,
       ROUND(AVG(roi), 2)                         AS roi_medio,
       ROUND(SUM(worldwide_gross) / 1e9, 2)       AS recaudacion_mm_usd
FROM movies
WHERE major_genre <> 'Unknown'
GROUP BY major_genre
HAVING COUNT(*) >= 30
ORDER BY pct_exito DESC;

-- Q2. Las 3 películas más rentables (beneficio absoluto) de cada género
-- name: top3_por_genero
WITH ranked AS (
    SELECT major_genre, title, year,
           ROUND(profit / 1e6, 1) AS beneficio_m_usd,
           ROW_NUMBER() OVER (PARTITION BY major_genre ORDER BY profit DESC) AS rk
    FROM movies
    WHERE major_genre IN ('Action', 'Comedy', 'Drama', 'Horror')
)
SELECT major_genre, rk, title, year, beneficio_m_usd
FROM ranked
WHERE rk <= 3
ORDER BY major_genre, rk;

-- Q3. Peso de cada distribuidora en la recaudación total y acumulado (concentración)
-- name: peso_distribuidoras
WITH por_dist AS (
    SELECT distributor, COUNT(*) AS peliculas, SUM(worldwide_gross) AS recaudacion
    FROM movies
    WHERE distributor <> 'Unknown'
    GROUP BY distributor
)
SELECT distributor, peliculas,
       ROUND(recaudacion / 1e9, 2)                                           AS recaudacion_mm_usd,
       ROUND(100.0 * recaudacion / SUM(recaudacion) OVER (), 1)              AS pct_total,
       ROUND(100.0 * SUM(recaudacion) OVER (ORDER BY recaudacion DESC)
                    / SUM(recaudacion) OVER (), 1)                            AS pct_acumulado
FROM por_dist
ORDER BY recaudacion DESC
LIMIT 8;

-- Q4. Evolución anual de la recaudación y variación respecto al año anterior
-- name: evolucion_anual
WITH anual AS (
    SELECT year, COUNT(*) AS peliculas, SUM(worldwide_gross) AS recaudacion
    FROM movies
    GROUP BY year
)
SELECT year, peliculas,
       ROUND(recaudacion / 1e9, 2) AS recaudacion_mm_usd,
       ROUND(100.0 * (recaudacion - LAG(recaudacion) OVER (ORDER BY year))
                   / LAG(recaudacion) OVER (ORDER BY year), 1) AS var_pct
FROM anual
ORDER BY year;
