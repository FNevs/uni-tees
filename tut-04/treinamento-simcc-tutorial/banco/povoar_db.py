import conexao_singleton as cs  # Importa a conexão Singleton do banco de dados

banco = cs.Conexao().get_conexao()

# Script para criar as tabelas e extensões
script_sql_criacao = """
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    CREATE TABLE IF NOT EXISTS pesquisadores (
        pesquisadores_id UUID NOT NULL DEFAULT uuid_generate_v4(),
        lattes_id VARCHAR(16) NOT NULL,
        nome VARCHAR(200) NOT NULL,
        PRIMARY KEY (pesquisadores_id)
    );

    CREATE TABLE IF NOT EXISTS producoes (
        producoes_id UUID NOT NULL DEFAULT uuid_generate_v4(),
        pesquisadores_id UUID NOT NULL,
        issn VARCHAR(16) NOT NULL,
        nomeArtigo VARCHAR(200) NOT NULL,
        anoArtigo INTEGER NOT NULL,
        PRIMARY KEY (producoes_id),
        CONSTRAINT fkey FOREIGN KEY (pesquisadores_id) 
        REFERENCES pesquisadores (pesquisadores_id) ON DELETE CASCADE
       
    );
"""

try:
    with banco.cursor() as cursor:
        print("Criando tabelas...")
        cursor.execute(script_sql_criacao)
        banco.commit()  # Confirma a criação das tabelas
        print("Tabelas criadas com sucesso!")
except Exception as e:
    banco.rollback()  # Reverte a transação em caso de erro
    print(f"Erro ao criar tabelas: {e}")
    banco.close()
    exit(1)

# Script para inserir dados nas tabelas
script_sql_insercao = """
    INSERT INTO pesquisadores (pesquisadores_id, lattes_id, nome)
    VALUES
    ('bba81084-0a74-4c60-8e68-d9f8ff0a8431', 'L12345678901234', 'Ana Maria Silva'),
    ('21c93e65-8f45-4b74-b6a5-1d8897d6a5bb', 'L23456789012345', 'Carlos Eduardo Santos'),
    ('3a63e54c-8c0b-4746-a780-40fc9bb6fd8b', 'L34567890123456', 'Mariana Oliveira Souza'),
    ('ebfb75e3-c89b-4486-b73d-9ebf8a6215d2', 'L45678901234567', 'João Pedro Almeida'),
    ('a5bd8e89-6e6c-46f2-9b5b-0c6d9e2d8657', 'L56789012345678', 'Fernanda Lima Rocha');

    INSERT INTO producoes (producoes_id, pesquisadores_id, issn, nomeArtigo, anoArtigo) 
    VALUES
    ('7f5ef3a6-bcb6-4f07-b6b4-734a9068fb44', 'bba81084-0a74-4c60-8e68-d9f8ff0a8431', '1234-5678', 'Estudo sobre a Biodiversidade na Amazônia', 2022),
    ('8c6e3f54-c158-49b6-9e33-074e9f47db8f', 'bba81084-0a74-4c60-8e68-d9f8ff0a8431', '2345-6789', 'Impacto das Mudanças Climáticas', 2023),
    ('9a7bfc7c-e6d1-45b8-9e6f-0f899d0e9a71', '21c93e65-8f45-4b74-b6a5-1d8897d6a5bb', '3456-7890', 'Avanços na Inteligência Artificial', 2021),
    ('a3b1f7d6-7123-4d9a-93e6-46f5b8a5d2f7', '3a63e54c-8c0b-4746-a780-40fc9bb6fd8b', '4567-8901', 'Estudo Genético de Plantas Brasileiras', 2020),
    ('bd9f3e8a-dad2-4f5c-91c8-33f60e1c5f71', 'ebfb75e3-c89b-4486-b73d-9ebf8a6215d2', '5678-9012', 'Tecnologias Renováveis e Sustentáveis', 2022),
    ('c0f4c4b5-9f6f-44e6-a6c1-2e4d7a8b9a62', 'a5bd8e89-6e6c-46f2-9b5b-0c6d9e2d8657', '6789-0123', 'Nanotecnologia e Saúde', 2021);
"""

try:
    with banco.cursor() as cursor:
        print("Inserindo dados...")
        cursor.execute(script_sql_insercao)
        banco.commit()  # Confirma a inserção de dados
        print("Dados inseridos com sucesso!")
except Exception as e:
    banco.rollback()  # Reverte a transação em caso de erro
    print(f"Erro ao inserir dados: {e}")
finally:
    banco.close()
    print("Conexão com o banco de dados encerrada.")
