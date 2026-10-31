from pathlib import Path
import pandas as pd

def texto_prolog(valor):
    texto = valor.replace("\\", "\\\\")
    texto = texto.replace("'", "''")
    texto = texto.replace("\n", " ").replace("\r", " ")
    return f"'{texto}'"

def numero_prolog(valor):
    valor = valor.strip().replace("#", "")
    if valor in ("", "Unknown"):
        return "desconhecido"

    return valor

def generos_prolog(valor):
    generos = valor.split(",")
    elementos = [texto_prolog(genero.strip()) for genero in generos]
    return "[" + ", ".join(elementos) + "]"

df = pd.read_csv(
    "manhwa_mal.csv",
    dtype=str,
    keep_default_na=False
)

linhas = ["% Ordem: titulo, capitulos, status, generos, popularidade, score, publicacao"]

for _, linha in df.iterrows():
    campos = [
        texto_prolog(linha["title"]),
        numero_prolog(linha["chapters"]),
        texto_prolog(linha["status"]),
        generos_prolog(linha["genres"]),
        numero_prolog(linha["popularity"]),
        numero_prolog(linha["score"]),
        texto_prolog(linha["publish_time"]),
    ]
    linhas.append("manhwa(" + ", ".join(campos) + ").")

Path("base.pl").write_text(
    "\n".join(linhas) + "\n",
    encoding="utf-8"
)

print(f"Base criada com {len(df)} fatos.")