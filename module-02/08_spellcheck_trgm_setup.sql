-- Habilita a extensão pg_trgm (trigramas)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- A extensão pg_trgm permite trabalhar com trigramas (sequências de 3 caracteres),
-- útil para medir similaridade entre strings (ex: para detectar erros ortográficos).

-- Exemplos de similaridade (similarity retorna um valor entre 0 e 1)
SELECT similarity('Something', 'something') AS sim;   -- 1 (igual, ignorando case)
SELECT similarity('Something', 'samething') AS sim;   -- ~0.54 (parecido)
SELECT similarity('Something', 'unrelated') AS sim;   -- 0 (sem relação)
SELECT similarity('Something', 'everything') AS sim;  -- ~0.23 (pouco parecido)
SELECT similarity('Something', 'omething') AS sim;    -- ~0.58 (parecido)

-- Criação de uma visão materializada com lexemas únicos de documentos,
-- usando ts_stat() para extrair os lexemas (palavras indexadas) da combinação de títulos,
-- conteúdos, autores e tags.
CREATE MATERIALIZED VIEW unique_lexeme AS
SELECT word FROM ts_stat(
$$
SELECT to_tsvector('simple', post.title) ||
       to_tsvector('simple', post.content) ||
       to_tsvector('simple', author.name) ||
       to_tsvector('simple', coalesce(string_agg(tag.name, ' '), ''))
FROM post
JOIN author ON author.id = post.author_id
JOIN posts_tags ON posts_tags.post_id = post.id
JOIN tag ON tag.id = posts_tags.tag_id
GROUP BY post.id, author.id
$$);

-- Criação de índice GIN com operador trigram para acelerar consultas de similaridade
CREATE INDEX idx_words_trgm ON unique_lexeme USING gin(word gin_trgm_ops);

-- Atualização da visão materializada quando necessário
-- (não precisa ser frequente, pois lexemas mudam pouco)
REFRESH MATERIALIZED VIEW unique_lexeme;

-- Consulta para encontrar o lexema mais similar ao termo pesquisado (ex: 'samething')
SELECT word
FROM unique_lexeme
WHERE similarity(word, 'samething') > 0.5
ORDER BY word <-> 'samething'
LIMIT 1;

-- Explicações:
-- similarity(a,b) retorna valor de 0 a 1 indicando o quão próximas as strings são
-- operador <-> retorna a "distância" entre strings (menor valor = mais próximas)

-- Estratégias para uso em busca:
-- 1. Não retornar resultados de erro ortográfico em todas as buscas para evitar poluição
-- 2. Retornar sugestões de correção caso a busca normal não traga resultados
-- 3. Incluir lexemas similares no tsquery para ampliar a busca (útil para dados informais, redes sociais)

-- Atenção:
-- Se o conjunto de lexemas for muito grande (ex: > 1 milhão), essa técnica pode gerar problemas
-- de performance e pode ser necessário um estudo mais aprofundado ou outras abordagens.