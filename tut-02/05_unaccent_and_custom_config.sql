-- Trabalhando com caracteres acentuados no PostgreSQL
-- É comum que usuários digitando em teclados internacionais omitam acentos
-- A extensão 'unaccent' permite remover acentuação de forma sistemática

-- Ativando a extensão unaccent
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Teste simples com acentos
SELECT unaccent('èéêë');
-- Resultado: 'eeee'

-- Inserindo conteúdo com acentuação na tabela post
INSERT INTO post (id, title, content, author_id, language)
VALUES (4, 'il était une fois', 'il était une fois un hôtel ...', 2, 'french');

-- Tentando construir o documento removendo acentos diretamente via função unaccent
SELECT 
    to_tsvector(post.language, unaccent(post.title)) ||
    to_tsvector(post.language, unaccent(post.content)) ||
    to_tsvector('simple', unaccent(author.name)) ||
    to_tsvector('simple', unaccent(coalesce(string_agg(tag.name, ' '), '')))
FROM post
JOIN author ON author.id = post.author_id
JOIN posts_tags ON posts_tags.post_id = post.id
JOIN tag ON tag.id = posts_tags.tag_id
GROUP BY post.id, author.id;

-- OBS: Essa abordagem funciona, mas é menos eficiente
-- Alternativa mais elegante e performática: criar uma configuração de busca personalizada

-- Criando uma nova configuração de busca textual para o idioma francês com suporte a unaccent
CREATE TEXT SEARCH CONFIGURATION fr ( COPY = french );

-- Alterando o mapeamento para aplicar 'unaccent' antes do stemmer do idioma
ALTER TEXT SEARCH CONFIGURATION fr
    ALTER MAPPING FOR hword, hword_part, word
    WITH unaccent, french_stem;

-- Testando a nova configuração 'fr'
SELECT to_tsvector('fr', 'il était une fois');
-- Resultado: 'etait':2 'fois':4

-- Comparando com aplicação manual do unaccent
SELECT to_tsvector('french', unaccent('il était une fois'));
-- Resultado equivalente: 'etait':2 'fois':4

-- Exemplo de busca que ignora acentos (Hôtel vs hotels)
SELECT to_tsvector('fr', 'Hôtel') @@ to_tsquery('hotels') AS result;
-- Resultado: true (t)

-- Agora a configuração personalizada pode ser usada normalmente na construção dos documentos
-- Desde que post.language aponte para a configuração correta como 'fr', 'en', etc.
SELECT 
    to_tsvector(post.language, post.title) ||
    to_tsvector(post.language, post.content) ||
    to_tsvector('simple', author.name) ||
    to_tsvector('simple', coalesce(string_agg(tag.name, ' '), ''))
FROM post
JOIN author ON author.id = post.author_id
JOIN posts_tags ON posts_tags.post_id = post.id
JOIN tag ON tag.id = posts_tags.tag_id
GROUP BY post.id, author.id;