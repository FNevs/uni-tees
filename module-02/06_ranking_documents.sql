-- Classificação de documentos com PostgreSQL Full-Text Search
-- O PostgreSQL permite calcular a relevância de documentos com base em diferentes partes do texto

-- A função setweight() permite definir a importância relativa de partes do documento
-- A função ts_rank() retorna um valor que representa a relevância de um documento para uma consulta

-- Exemplo completo com pesos para diferentes campos
SELECT pid, p_title
FROM (
    SELECT post.id AS pid,
           post.title AS p_title,
           setweight(to_tsvector(post.language::regconfig, post.title), 'A') || -- Título: peso alto
           setweight(to_tsvector(post.language::regconfig, post.content), 'B') || -- Conteúdo: peso médio
           setweight(to_tsvector('simple', author.name), 'C') || -- Autor: peso baixo
           setweight(to_tsvector('simple', coalesce(string_agg(tag.name, ' '), '')), 'B') AS document -- Tags: peso médio
    FROM post
    JOIN author ON author.id = post.author_id
    JOIN posts_tags ON posts_tags.post_id = post.id
    JOIN tag ON tag.id = posts_tags.tag_id
    GROUP BY post.id, author.id
) p_search
WHERE p_search.document @@ to_tsquery('english', 'Endangered & Species')
ORDER BY ts_rank(p_search.document, to_tsquery('english', 'Endangered & Species')) DESC;

-- Atribuição de pesos:
-- 'A' > 'B' > 'C' > 'D'
-- Título (A) tem maior influência na relevância
-- Tags (B) e conteúdo (B) vêm em seguida
-- Autor (C) tem o menor peso

-- Exemplos didáticos para entender ts_rank():

-- Dois termos aparecem no texto → rank mais alto
SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example & document')) AS relevancy;
-- Resultado: 0.0985009

-- Apenas um termo corresponde → rank mais baixo
SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example')) AS relevancy;
-- Resultado: 0.0607927

-- Um termo relevante e outro ausente → rank reduzido
SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example | unknown')) AS relevancy;
-- Resultado: 0.0303964

-- Ambos os termos ausentes → rank mínimo (quase zero)
SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example & unknown')) AS relevancy;
-- Resultado: 1e-20

-- Dica: o operador `|` (OR) gera menos relevância que o `&` (AND) quando ambos os termos são encontrados

-- Exemplo de personalização: promover documentos mais recentes
-- Exemplo fictício assumindo campo post.updated_at
SELECT post.id, post.title,
       ts_rank(document, query) / (EXTRACT(EPOCH FROM NOW() - post.updated_at) / 3600 + 1) AS final_score
FROM (
    SELECT post.*, 
           to_tsquery('english', 'example') AS query,
           setweight(to_tsvector(language::regconfig, title), 'A') ||
           setweight(to_tsvector(language::regconfig, content), 'B') AS document
    FROM post
) p
WHERE document @@ query
ORDER BY final_score DESC;

-- Essa técnica usa o tempo de modificação para promover conteúdo mais recente
-- O valor da relevância é dividido pela "idade" do documento em horas (+1 para evitar divisão por zero)
-- Isso significa que documentos mais novos terão uma pontuação mais alta