# ¿Qué hace que una película gane dinero?

Análisis exploratorio de 3.201 películas (presupuesto, recaudación, género, nota de IMDB y distribuidora) para responder una pregunta de negocio: **si un estudio tuviera que decidir en qué películas invertir, ¿qué patrones separan las que recuperan su presupuesto de las que no?**

Herramientas: Python (pandas, seaborn, matplotlib), SQL (SQLite, CTE y funciones de ventana), Jupyter y Power BI.

## Resultados principales (películas de 1990 a 2010, n = 2.516)

| Pregunta | Resultado |
| --- | --- |
| Visión general | El 64% de las películas recupera su presupuesto; ROI mediano 0,64 |
| Género | Adventure (81%) y Horror (79%) tienen la mayor tasa de éxito; Drama (56%) la menor |
| Presupuesto | El cuartil de presupuesto más alto tiene la mayor tasa de éxito (76%) y el ROI mediano más alto (1,02). El cuartil más bajo es una lotería: el 10% peor pierde casi todo (ROI −0,97), el 10% mejor llega a 7,7 |
| Calidad percibida | Con nota IMDB > 7,5: ROI mediano 2,29 y 83% de éxito. Con nota < 5,5: 0,24 y 56% (correlación de Spearman ≈ 0,25) |
| Concentración | El 10% de las películas aporta el 49% de la recaudación total |
| Distribuidoras | 20th Century Fox y Disney combinan volumen y ROI; Warner Bros. recauda más en total pero con ROI mediano menor (0,64) |

`ROI = (recaudación mundial − presupuesto) / presupuesto`. Una película es un éxito si su ROI es mayor que 0.

## Decisiones de análisis que conviene conocer

- **Fechas corregidas.** 22 clásicos aparecían estrenados en el futuro (por ejemplo *Gone with the Wind* en 2039): los años de 2 dígitos se habían interpretado como 20xx en lugar de 19xx. Se restan 100 años a esas fechas (`src/clean.py`).
- **Recaudación 0 = dato desconocido**, no "no recaudó nada".
- **Presupuesto mínimo de 1 M$** para el análisis: por debajo, el ROI es ruido.
- **Solo 1990–2010.** Antes de 1990 el dataset contiene casi solo clásicos que siguen recordándose (sesgo de supervivencia), con un ROI mediano artificialmente alto. Se explica y se muestra en el notebook (sección 3).

## Limitaciones

- La recaudación mundial no es beneficio: incluye la parte que se quedan los cines y no recoge marketing ni ingresos de DVD o streaming.
- Dólares sin ajustar por inflación; datos hasta ~2010 (sin streaming).
- Son asociaciones, no causalidad. Género y presupuesto están relacionados (por ejemplo, Adventure tiene un presupuesto mediano de 70 M$), así que sus efectos no se pueden separar del todo.

## Estructura

```
data/raw/movies.json           Datos originales (vega-datasets)
data/processed/                Datos limpios y exportaciones para Power BI
src/clean.py                   Limpieza reproducible
sql/queries.sql                Consultas SQL (agregaciones, CTE, ventanas)
notebooks/analisis_peliculas.ipynb   Análisis completo, ya ejecutado
reports/figures/               Gráficos exportados
powerbi/guia_powerbi.md        Cómo construir el dashboard y medidas DAX
```

## Cómo reproducirlo

```bash
pip install -r requirements.txt
python src/clean.py
jupyter notebook notebooks/analisis_peliculas.ipynb
```

## Fuente

Dataset `movies.json` del repositorio público [vega-datasets](https://github.com/vega/vega-datasets). Revisa las condiciones de uso de la fuente antes de reutilizar los datos fuera de un contexto educativo.
