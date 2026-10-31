% Perguntas escolhidas:
% quais os 10 manhwas completos mais populares com score maior que 7, em ordem de popularidade?
% qual a média de score dos manhwas completos de romance?
% quais manhwas completos de romance estão acima da média de score?

:- ensure_loaded('base.pl').

romance_completo(Titulo, Score) :-
    manhwa(Titulo, _, 'Finished', Generos, _, Score, _),
    member('Romance', Generos),
    number(Score).


% Pergunta 1: dez completos mais populares com score maior que 7.
% Consulta: top_10_populares(Tabela).

top_10_populares(Tabela) :-
    findall(
        Popularidade-Titulo,
        (
            manhwa(Titulo, _, 'Finished', _, Popularidade, Score, _),
            number(Popularidade),
            number(Score),
            Score > 7
        ),
        Candidatos
    ),
    keysort(Candidatos, Ordenados),
    length(Ordenados, Quantidade),
    Limite is min(10, Quantidade),
    length(Tabela, Limite),
    append(Tabela, _, Ordenados).


       
% Pergunta 2: media dos scores dos romances completos.
% Consulta: media_romance_completo(Media).

media_romance_completo(Media) :-
    findall(
        Score,
        romance_completo(_, Score),
        Scores
    ),
    length(Scores, Quantidade),
    Quantidade > 0,
    sum_list(Scores, Soma),
    Media is Soma / Quantidade.



  
% Pergunta 3: romances completos com score acima da media do grupo.
% Consulta: romance_acima_da_media(Titulo, Score, Media).

romance_acima_da_media(Titulo, Score, Media) :-
    media_romance_completo(Media),
    romance_completo(Titulo, Score),
    Score > Media.
