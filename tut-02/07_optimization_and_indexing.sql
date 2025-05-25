-- Otimização e Indexação no PostgreSQL com Full-Text Search

-- Criando um índice GIN diretamente sobre uma função de tsvector()
CREATE INDEX idx_fts_post ON post
USING gin(
    setweight(to_tsvector(language, title), 'A') ||
    setweight(to_tsvector(language, content), 'B')
);

-- 🧠 GIN vs GiST:
-- GIN (Generalized Inverted Index)
-- - Mais rápido para consultas
-- - Mais pesado na construção
-- - Ideal para dados mais estáticos

-- GiST (Generalized Search Tree)
-- - Suporta atualização mais rápida
-- - Pode gerar falsos positivos (precisa de verificação extra)
-- - Melhor para dados dinâmicos com menor vocabulário (~100.000 lexemas)

-- 📌 Recomendação geral:
-- Use GIN para dados estáticos ou leitura intensiva
-- Use GiST para dados dinâmicos com alta taxa de atualização

-- 🧱 Problema: Documento distribuído entre várias tabelas
-- 💡 Solução: Desnormalizar dados com *views materializadas* ou *triggers*

-- Criando uma VIEW MATERIALIZADA para busca
CREATE MATERIALIZED VIEW search_index AS
SELECT post.id,
       post.title,
       setweight(to_tsvector(post.language::regconfig, post.title), 'A') ||
       setweight(to_tsvector(post.language::regconfig, post.content), 'B') ||
       setweight(to_tsvector('simple', author.name), 'C') ||
       setweight(to_tsvector('simple', coalesce(string_agg(tag.name, ' '))), 'A') AS document
FROM post
JOIN author ON author.id = post.author_id
JOIN posts_tags ON posts_tags.post_id = post.id
JOIN tag ON tag.id = posts_tags.tag_id
GROUP BY post.id, author.id;

-- Atualização periódica da view materializada
-- Reindexação simples com:
-- REFRESH MATERIALIZED VIEW search_index;

-- Índice na view materializada
CREATE INDEX idx_fts_search ON search_index USING gin(document);

-- Consulta otimizada usando a view e o índice GIN
SELECT id AS post_id, title
FROM search_index
WHERE document @@ to_tsquery('english', 'Endangered & Species')
ORDER BY ts_rank(document, to_tsquery('english', 'Endangered & Species')) DESC;

-- 🔄 Alternativa para atualizações em tempo real:
-- Criar TRIGGERS com tsvector_update_trigger() ou tsvector_update_trigger_column()
-- Exemplo básico:
-- ALTER TABLE post ADD COLUMN document tsvector;
-- CREATE TRIGGER tsv_update BEFORE INSERT OR UPDATE
-- ON post FOR EACH ROW EXECUTE FUNCTION
-- tsvector_update_trigger(document, 'pg_catalog.english', title, content);

-- ✔️ Conclusão:
-- A estrutura ideal de indexação depende de vários fatores:
-- - Volume de dados
-- - Frequência de atualização
-- - Número de tabelas envolvidas
-- - Suporte a múltiplos idiomas
-- - Nível aceitável de atraso (real-time vs batch)