-- Exemplos básicos de uso do operador @@ para consultar documentos do tipo tsvector

-- Exemplo 1: Retorna TRUE porque "dream" está presente no vetor
SELECT to_tsvector('If you can dream it, you can do it') @@ 'dream';

-- Exemplo 2: Retorna FALSE porque a palavra 'impossible' não é processada corretamente sem stemming
SELECT to_tsvector('It''s kind of fun to do the impossible') @@ 'impossible';

-- Comparando diferentes formas de gerar tsquery:
-- O cast direto não aplica stemming
-- to_tsquery aplica stemming, retornando 'imposs'
SELECT 'impossible'::tsquery, to_tsquery('impossible');

-- Com a palavra 'dream', ambas as formas são equivalentes
SELECT 'dream'::tsquery, to_tsquery('dream');

-- Agora utilizando a forma correta com to_tsquery
-- Retorna TRUE, pois 'impossible' é transformado em 'imposs'
SELECT to_tsvector('It''s kind of fun to do the impossible') @@ to_tsquery('impossible');

-- Exemplos com operadores booleanos:

-- Uso do operador de negação (!): 'fact' está presente, então a negação falha
SELECT to_tsvector('If the facts don''t fit the theory, change the facts') @@ to_tsquery('!fact');

-- Uso de AND (&) e NOT (!): precisa conter 'theory' mas não 'fact' → retorna FALSE
SELECT to_tsvector('If the facts don''t fit the theory, change the facts') @@ to_tsquery('theory & !fact');

-- Uso do operador OR (|): procura por 'fiction' ou 'theory' → retorna TRUE pois contém 'theory'
SELECT to_tsvector('If the facts don''t fit the theory, change the facts.') @@ to_tsquery('fiction | theory');

-- Uso de prefixo com coringa (*): 'theo:*' casa com 'theory'
SELECT to_tsvector('If the facts don''t fit the theory, change the facts.') @@ to_tsquery('theo:*');

-- Aplicando uma consulta no esquema com dados reais (post, author, tag)

-- Consulta FTS sobre título, conteúdo, autor e tags, buscando "Endangered" e "Species"
SELECT pid, p_title
FROM (
    SELECT 
        post.id AS pid,
        post.title AS p_title,
        -- Constrói o documento como tsvector combinando os campos relevantes
        to_tsvector(post.title) ||
        to_tsvector(post.content) ||
        to_tsvector(author.name) ||
        to_tsvector(COALESCE(string_agg(tag.name, ' '), '')) AS document
    FROM post
        JOIN author ON author.id = post.author_id
        JOIN posts_tags ON posts_tags.post_id = post.id
        JOIN tag ON tag.id = posts_tags.tag_id
    GROUP BY post.id, author.id
) p_search
-- Aplica consulta FTS para encontrar posts com os termos "Endangered" AND "Species"
WHERE p_search.document @@ to_tsquery('Endangered & Species');