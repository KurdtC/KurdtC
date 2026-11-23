-- Diário de campanha: qual foi a última pista que deixei para mim?
-- Execute em SQLite. Os dados fictícios existem apenas durante a consulta.
-- O identificador da campanha distingue duas jornadas, mesmo dentro do mesmo jogo.

WITH
campanhas(id, jogo, campanha) AS (
    VALUES
        (1, 'Farol de Vidro', 'A cartógrafa'),
        (2, 'Maré de Cobre', 'Primeira travessia')
),
sessoes(id, campanha_id, inicio, minutos, proximo_passo) AS (
    VALUES
        (1, 1, '2026-03-01 19:00', 45, 'Visitar o arquivo do porto.'),
        (2, 1, '2026-03-04 20:00', 35, 'Comparar o mapa antigo com a marca no cais.'),
        (3, 2, '2026-03-02 18:00', 50, 'Testar a chave de cobre na casa do faroleiro.')
),
historico AS (
    SELECT
        campanha_id,
        inicio,
        proximo_passo,
        SUM(minutos) OVER (PARTITION BY campanha_id) AS total_minutos,
        ROW_NUMBER() OVER (
            PARTITION BY campanha_id ORDER BY inicio DESC, id DESC
        ) AS ordem
    FROM sessoes
)
SELECT
    c.jogo,
    c.campanha,
    h.inicio AS ultima_sessao,
    COALESCE(h.total_minutos, 0) AS minutos_jogados,
    COALESCE(h.proximo_passo, 'Começar a campanha.') AS ao_voltar
FROM campanhas AS c
LEFT JOIN historico AS h ON h.campanha_id = c.id AND h.ordem = 1
ORDER BY c.jogo, c.campanha;
