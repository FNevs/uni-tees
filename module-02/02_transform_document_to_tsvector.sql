-- Transforma o conteúdo textual em um vetor de busca (tsvector), adequado para FTS
SELECT 
    -- Converte o título em vetor de termos
    to_tsvector(post.title) ||

    -- Converte o conteúdo da publicação
    to_tsvector(post.content) ||

    -- Converte o nome do autor
    to_tsvector(author.name) ||

    -- Concatena e converte as tags associadas à publicação
    to_tsvector(COALESCE(string_agg(tag.name, ' '), '')) AS document

FROM post

    -- Junta com autor (cada post tem um autor)
    JOIN author ON author.id = post.author_id

    -- Junta com tabela de associação (corrigido abaixo)
    JOIN posts_tags ON posts_tags.post_id = post.id

    -- Junta com as tags
    JOIN tag ON tag.id = posts_tags.tag_id

-- Agrupa pelos campos que não são agregados
GROUP BY post.id, author.id;