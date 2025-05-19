-- Adiciona suporte multilíngue para full-text search no PostgreSQL
-- O PostgreSQL suporta várias configurações de idioma para stemming e análise textual

-- Exemplo 1: Análise com idioma inglês — retorna 'run' como stem de 'running'
SELECT to_tsvector('english', 'We are running');
-- Resultado: 'run':3

-- Exemplo 2: Análise com idioma francês — não realiza stemming, mantém palavras como estão
SELECT to_tsvector('french', 'We are running');
-- Resultado: 'are':2 'running':3 'we':1

-- Adicionando uma nova coluna de idioma à tabela post
ALTER TABLE post ADD COLUMN language TEXT NOT NULL DEFAULT 'english';

-- Agora reconstruímos o documento levando em conta a configuração de idioma contida em cada post
-- Utilizamos ::regconfig para que o PostgreSQL interprete corretamente o valor da coluna como configuração de idioma

SELECT 
    to_tsvector(post.language::regconfig, post.title) || 
    to_tsvector(post.language::regconfig, post.content) || 
    to_tsvector('simple', author.name) || 
    to_tsvector('simple', coalesce(string_agg(tag.name, ' '), '')) AS document
FROM post
JOIN author ON author.id = post.author_id
JOIN posts_tags ON posts_tags.post_id = post.id
JOIN tag ON tag.id = posts_tags.tag_id
GROUP BY post.id, author.id;

-- Comentário:
-- A função to_tsvector(text, text) requer que o primeiro argumento seja do tipo regconfig (registro de configuração)
-- Sem o cast explícito (::regconfig), a execução resultará em erro:
-- ERROR:  function to_tsvector(text, text) does not exist

-- O dicionário 'simple' pode ser utilizado para campos como nomes próprios
-- Ele não ignora stop words e não faz stemming (ideal para nomes de pessoas)

-- Exemplo: usando dicionário 'simple' para analisar uma frase
SELECT to_tsvector('simple', 'We are running');
-- Resultado: 'are':2 'running':3 'we':1