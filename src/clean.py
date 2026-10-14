"""Limpieza del dataset de películas (vega-datasets).

Uso:  python src/clean.py
Entrada:  data/raw/movies.json
Salida:   data/processed/movies_clean.csv
"""
from pathlib import Path
import numpy as np
import pandas as pd

RAW = Path("data/raw/movies.json")
OUT = Path("data/processed/movies_clean.csv")

# Última fecha plausible del dataset (los datos se recopilaron hacia 2010-2011).
# Cualquier año posterior es un error de formato: años de 2 dígitos interpretados como 20xx.
MAX_VALID_YEAR = 2011


def load_and_clean() -> pd.DataFrame:
    df = pd.read_json(RAW)

    # 1. Nombres de columna en snake_case
    df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]

    # 2. Fechas: texto "Jun 12 1998" -> datetime, y corrección de años imposibles (>2011)
    d = pd.to_datetime(df["release_date"], format="%b %d %Y")
    bad = d.dt.year > MAX_VALID_YEAR
    d = d.where(~bad, d - pd.DateOffset(years=100))
    df["release_date"] = d
    df["year"] = d.dt.year
    df["decade"] = (df["year"] // 10 * 10).astype(int)
    df["fixed_future_date"] = bad

    # 3. Un gross de 0 significa "sin dato / no estrenada", no una película que no recaudó nada
    for col in ["us_gross", "worldwide_gross"]:
        df[col] = df[col].replace(0, np.nan)

    # 4. Categorías vacías -> "Unknown" en lugar de dejar nulos
    for col in ["major_genre", "mpaa_rating", "distributor", "source", "creative_type"]:
        df[col] = df[col].fillna("Unknown")

    # 5. Métricas de negocio
    df["profit"] = df["worldwide_gross"] - df["production_budget"]
    df["roi"] = df["profit"] / df["production_budget"]          # 1.0 = recaudó el doble de lo que costó
    df["is_hit"] = np.where(df["roi"].notna(), df["roi"] > 0, np.nan)

    # 6. Conjunto analizable: presupuesto >= 1 M$ (por debajo el ROI es ruido) y recaudación conocida
    df["analysable"] = (df["production_budget"] >= 1_000_000) & df["worldwide_gross"].notna()
    return df.sort_values("release_date").reset_index(drop=True)


if __name__ == "__main__":
    df = load_and_clean()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUT, index=False)
    print(f"{len(df)} películas | {df['analysable'].sum()} analizables | "
          f"{df['fixed_future_date'].sum()} fechas corregidas -> {OUT}")
