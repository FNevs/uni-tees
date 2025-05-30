# Tutorial com Flask e PostgreSQL

Esse tutorial mostra como fazer funcionar um crud simples usando a arquitetura MVC com Singleton.
Detalhes não são explicados pois não caberia aqui, mas o código está comentado.

As pastas estão organizadas de acordo com a responsabilidade de cada módulo.

- Na pasta controller há somente arquivos relacionados com os controladores. Já que temos apenas o pesquisador como entidade nesse tutorial, temos somente controladores relacionados com ele.
- Dentro da pasta controller também tem a pasta dao (Data Access Object), que tem somente código relacionado com a interação com o banco de dados.
- Na pasta model temos a classe da entidade Pesquisador

---

> [!IMPORTANT]
>
> Antes de começar verifique se você tem a versão do Python acima da 3.12 e o Docker instalado. Você pode instalar no ambiente virtual, se preferir. Este tutorial não cobre a instalação do Python e suas dependências, pois os comandos podem ser diferentes dependendo da instalação.

### Passo 1

Rode o comando **git clone <endereco_do_repositorio>** na pasta desejada

### Passo 2

Crie um ambiente virtual python para não misturar as dependências desse tutorial com as bibliotecas instaladas globalmente no computador.

`python -m venv <nome_do_venv>`

ou

`python3 -m venv <nome_do_venv>`

Vai depender da sua instalação do python.

### Passo 3

Depois de criar o ambiente virtual, rode o seguinte comando no terminal:

##### No Linux

`source nome_do_ambiente/bin/activate`

##### No Windows

`nome_do_ambiente\Scripts\activate`

Após isso, entre na pasta do tutorial e rode `pip install -r requirements.txt` com o ambiente virtual ativado para instalar as dependências.

### Passo 4

Na raiz da aplicação, digite `docker-compose up` para subir o banco de dados pelo docker.
Depois rode o arquivo `povoar_bd.py` na pasta **banco** para colocar os dados dos pesquisadores para teste no banco.

### Passo 5

Rode o arquivo `app.py` e faça as requisições GET, POST, PUT e DELETE para **/pesquisadores** para testar.
A aplicação estará rodando na porta 8000. Digite `http://localhost:8000` no navegador.

Use o comando para rodar a aplicação:

`uvicorn app:app --reload`

O primeiro **app** em "app:app --reload" se refere ao nome do arquivo principal. Portanto, se seu arquivo estivesse como 'main', você usaria "main:app --reload".

---

> [!TIP]
>
> Caso queira refazer tudo de novo, há um arquivo `apagar_db.py` na pasta **banco**. Basta rodar ele com o banco de dados funcionando, mas com o `app.py` parado.
