-- Cria a tabela de autores
CREATE TABLE author (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Cria a tabela de posts com relação ao autor
CREATE TABLE post (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    author_id INT NOT NULL REFERENCES author(id)
);

-- Cria a tabela de tags
CREATE TABLE tag (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Cria a tabela de associação entre posts e tags (relação N:N)
CREATE TABLE posts_tags (
    post_id INT NOT NULL REFERENCES post(id),
    tag_id INT NOT NULL REFERENCES tag(id)
);

-- Insere autores
INSERT INTO author (id, name)
VALUES 
    (1, 'Pete Graham'),
    (2, 'Rachid Belaid'),
    (3, 'Robert Berry');

-- Insere tags
INSERT INTO tag (id, name)
VALUES 
    (1, 'scifi'),
    (2, 'politics'),
    (3, 'science');

-- Insere posts com seus respectivos autores
INSERT INTO post (id, title, content, author_id)
VALUES 
    (1, 'Endangered species', 'Pandas are an endangered species', 1),
    (2, 'Freedom of Speech', 'Freedom of speech is a necessary right', 2),
    (3, 'Star Wars vs Star Trek', 'Few words from a big fan', 3);

-- Relaciona os posts com as tags
INSERT INTO posts_tags (post_id, tag_id)
VALUES 
    (1, 3),  -- Post 1 com a tag "science"
    (2, 2),  -- Post 2 com a tag "politics"
    (3, 1);  -- Post 3 com a tag "scifi"