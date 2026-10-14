# Dashboard en Power BI

Esta guía te lleva de los datos limpios a un dashboard de una página. **Las medidas DAX no se han probado en Power BI Desktop** (se escribieron fuera de él): revisa cada una al crearla y corrige cualquier error de sintaxis.

## 1. Importar los datos

1. Power BI Desktop → Obtener datos → Texto/CSV → `data/processed/movies_dashboard.csv` (2.516 películas, 1990–2010).
2. En Power Query, comprueba tipos: `year` número entero; `budget`, `gross`, `imdb` número decimal. Renombra la tabla a `peliculas`.

## 2. Columnas calculadas

```DAX
ROI = DIVIDE(peliculas[gross] - peliculas[budget], peliculas[budget])

Exito = IF(peliculas[ROI] > 0, 1, 0)

Tramo IMDB =
IF(
    ISBLANK(peliculas[imdb]), BLANK(),
    SWITCH(
        TRUE(),
        peliculas[imdb] <= 5.5, "1. < 5,5",
        peliculas[imdb] <= 6.5, "2. 5,5–6,5",
        peliculas[imdb] <= 7.5, "3. 6,5–7,5",
        "4. > 7,5"
    )
)

Tramo presupuesto =
VAR q1 = PERCENTILE.INC(peliculas[budget], 0.25)
VAR q2 = PERCENTILE.INC(peliculas[budget], 0.50)
VAR q3 = PERCENTILE.INC(peliculas[budget], 0.75)
RETURN
    SWITCH(
        TRUE(),
        peliculas[budget] <= q1, "Q1 (bajo)",
        peliculas[budget] <= q2, "Q2",
        peliculas[budget] <= q3, "Q3",
        "Q4 (alto)"
    )
```

> Si `Tramo presupuesto` da problemas de rendimiento, calcula los percentiles en Power Query o como medidas aparte.

## 3. Medidas

```DAX
Películas = COUNTROWS(peliculas)

Tasa de éxito = AVERAGE(peliculas[Exito])

ROI mediano = MEDIAN(peliculas[ROI])

Recaudación (mil M$) = DIVIDE(SUM(peliculas[gross]), 1000000000)

ROI P10 = PERCENTILE.INC(peliculas[ROI], 0.10)

ROI P90 = PERCENTILE.INC(peliculas[ROI], 0.90)

Peso del top 10% =
VAR n = COUNTROWS(ALL(peliculas))
VAR k = INT(n * 0.10)
VAR top = TOPN(k, ALL(peliculas), peliculas[gross], DESC)
RETURN
    DIVIDE(SUMX(top, peliculas[gross]), CALCULATE(SUM(peliculas[gross]), ALL(peliculas)))
```

## 4. Página del dashboard

| Visual | Campos |
| --- | --- |
| 4 tarjetas | Películas, Tasa de éxito, ROI mediano, Recaudación (mil M$) |
| Barras horizontales: éxito por género | Eje: `genre` (filtro: excluir "Unknown" y géneros con menos de 30 películas); Valor: Tasa de éxito |
| Rango por presupuesto | Eje: Tramo presupuesto; Valores: ROI P10, ROI mediano, ROI P90 (gráfico de líneas y marcadores sin línea, o de cajas) |
| Columnas: éxito por nota | Eje: Tramo IMDB; Valor: Tasa de éxito |
| Tabla de distribuidoras | `distributor`, Películas, Recaudación (mil M$), ROI mediano, Tasa de éxito (filtro: Películas ≥ 50, excluir "Unknown") |
| Segmentador | `year` (rango) |

Pon un título que diga la conclusión ("Las películas de presupuesto alto fallan menos") en lugar de uno descriptivo.

## 5. Para comprobar que está bien

Con el segmentador de año en 1990–2010 y sin otros filtros, deberías ver: 2.516 películas, tasa de éxito 63,9%, ROI mediano 0,64 y recaudación 243 mil M$. Si no coincide, algo falla en la importación o en los tipos.
