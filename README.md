# Knowledge Engine: consultas sobre manhwas

O objetivo é construir uma base de conhecimento a partir de um dataset de manhwas e responder perguntas usando regras e consultas em Prolog.

O Python realiza a extração, o tratamento e a conversão dos dados (ETL). O Prolog realiza os filtros, as agregações, a ordenação e as comparações necessárias para responder às perguntas.

## Dataset

Foi utilizada uma única tabela, disponível no arquivo `manhwa_mal.csv`, com 2.943 registros. Os dados representam o conteúdo do arquivo coletado e não necessariamente a situação atual das obras.

**Fonte original do dataset:** https://www.kaggle.com/datasets/crxxom/manhwa-dataset

Foram selecionados sete campos, incluindo variáveis qualitativas e quantitativas:

| Campo | Descrição |
| --- | --- |
| `title` | Título da obra |
| `chapters` | Quantidade de capítulos |
| `status` | Situação da publicação |
| `genres` | Gêneros associados à obra |
| `popularity` | Posição no ranking de popularidade: números menores indicam maior popularidade |
| `score` | Nota da obra |
| `publish_time` | Período de publicação, mantido como texto |

## Arquivos do projeto

| Arquivo | Função |
| --- | --- |
| `manhwa_mal.csv` | Tabela de entrada |
| `gerar_base.py` | Script Python que lê o CSV e gera os fatos em Prolog |
| `base.pl` | Base de conhecimento gerada pelo script |
| `perguntas.pl` | Regra auxiliar e regras das três perguntas; carrega `base.pl` |
| `README.md` | Documentação do projeto |

## Construção da base de conhecimento

O script `gerar_base.py` lê o CSV com pandas e seleciona os sete campos. Cada linha é convertida em um fato `manhwa/7`, com a seguinte ordem de argumentos:

```prolog
manhwa(Titulo, Capitulos, Status, Generos, Popularidade, Score, Publicacao).
```

Tratamentos realizados:

- Remoção de `#` da popularidade: `#7` passa a ser o número `7`.
- Conversão dos gêneros separados por vírgulas em listas Prolog.
- Representação de capítulos e scores ausentes pelo átomo `desconhecido`.
- Escrita de textos entre aspas simples, com tratamento de apóstrofos e barras invertidas.
- Gravação do arquivo em UTF-8, com um ponto final ao término de cada fato.

Exemplo de fato gerado:

```prolog
manhwa('Solo Leveling', 201, 'Finished', ['Action', 'Adventure', 'Fantasy'], 7, 8.68, 'Mar  4, 2018 to May  31, 2023').
```

As consultas que realizam operações numéricas ignoram valores `desconhecido` usando `number/1`. Os registros são mantidos como aparecem no CSV, sem deduplicação por título.

## Perguntas e regras

### Regra auxiliar: romances completos

`romance_completo(Titulo, Score)` seleciona registros cujo status é `'Finished'`, cuja lista de gêneros contém `'Romance'` e cujo score é numérico. Essa regra é reutilizada nas perguntas 2 e 3.

### 1. Quais são os dez manhwas completos mais populares com score maior que 7, em ordem de popularidade?

```prolog
top_10_populares(Tabela).
```

A regra reúne os pares `Popularidade-Titulo` dos registros elegíveis com `findall/3`, ordena pela posição no ranking com `keysort/2` e seleciona os dez primeiros. Se houver menos de dez, retorna todos os elegíveis.

Os menores números de popularidade aparecem primeiro. A consulta combina filtragem, construção de lista, ordenação e seleção dos primeiros resultados.

### 2. Qual é a média de score dos manhwas completos de romance?

```prolog
media_romance_completo(Media).
```

A regra reúne os scores com `findall/3`, conta os registros com `length/2`, soma as notas com `sum_list/2` e calcula a média usando `is`. A condição `Quantidade > 0` evita divisão por zero; se não houver registros elegíveis, a consulta falha.

Resultado observado para o CSV utilizado:

```text
Media = 7.071906873614198
```

### 3. Quais manhwas completos de romance têm score acima da média desse mesmo grupo?

```prolog
romance_acima_da_media(Titulo, Score, Media).
```

A regra calcula a média da pergunta 2, busca os romances completos e seleciona aqueles com `Score > Media`. Ela combina regras auxiliares, agregação e comparação.

Exemplos de resultados: `Bastard`, com score 8,5, e `Who Made Me a Princess`, com score 8,44. Ambos superam a média de aproximadamente 7,0719.

## Como executar

### Pré-requisitos

- Python 3 e pandas.
- SWI-Prolog instalado e comando `swipl` disponível no terminal.


### 1. Instalar a dependência Python

No terminal, dentro da pasta do projeto:

```bash
python -m pip install pandas
```

### 2. Gerar a base de fatos

```bash
python gerar_base.py
```

Esse comando gera ou substitui `base.pl`. Para o CSV utilizado, a mensagem esperada é:

```text
Base criada com 2943 fatos.
```

### 3. Carregar as regras e a base

```bash
swipl -s perguntas.pl
```

O arquivo `perguntas.pl` carrega os fatos por meio da instrução:

```prolog
:- ensure_loaded('base.pl').
```

### 4. Executar as consultas

Quando aparecer o prompt `?-`, digite uma consulta por vez, incluindo o ponto final:

```prolog
top_10_populares(Tabela).
```

```prolog
media_romance_completo(Media).
```

```prolog
romance_acima_da_media(Titulo, Score, Media).
```

Na consulta da pergunta 3, pressione `;` para carregar mais um romance acima da média.


Para sair do interpretador:

```prolog
halt.
```