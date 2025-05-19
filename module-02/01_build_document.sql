-- Constrói um "documento de texto" combinando título, conteúdo, autor e tags
SELECT 
    -- Concatena o título, conteúdo e nome do autor em uma única string
    post.title || ' ' || post.content || ' ' || author.name || ' ' ||

    -- Agrupa todas as tags associadas a um post em uma string separada por espaços
    -- Exemplo: 'scifi politics'
    -- Se não houver tags, retorna string vazia ('') em vez de NULL
    COALESCE(string_agg(tag.name, ' '), '') AS document

FROM post

    -- Junta com a tabela de autores
    JOIN author ON author.id = post.author_id

    -- Junta com a tabela de associação entre post e tag
    JOIN posts_tags ON posts_tags.post_id = post.id

    -- Junta com a tabela de tags
    JOIN tag ON tag.id = posts_tags.tag_id

-- Agrupa os resultados por post e autor, pois usamos agregação com string_agg
GROUP BY post.id, author.id;