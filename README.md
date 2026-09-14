# Contexto 

**Banco de Dados Northwind no Postgres com Docker.**

O banco de dados Northwind contém os dados de vendas de uma empresa chamada Northwind Traders, que importa e exporta alimentos especiais de todo o mundo.

O banco de dados Northwind é ERP com dados de clientes, pedidos, inventário, compras, fornecedores, remessas, funcionários e contabilidade.

O conjunto de dados Northwind inclui dados de amostra para o seguinte:

- Fornecedores: Fornecedores e vendedores da Northwind
- Clientes: Clientes que compram produtos da Northwind
- Funcionários: Detalhes dos funcionários da Northwind Traders
- Produtos: Informações do produto
- Transportadoras: Os detalhes dos transportadores que enviam os produtos dos comerciantes para os clientes finais
- Pedidos e Detalhes do Pedido: Transações de pedidos de vendas ocorrendo entre os clientes e a empresa

O banco de dados Northwind inclui 14 tabelas e os relacionamentos entre as tabelas são mostrados no seguinte diagrama de relacionamento de entidades.

<img src=ER.png />

## Configuração Inicial

### Manualmente

Utilize os arquivos .sql fornecido e execute no banco de dados.

### Com Docker Compose

Pré-requisito: Instale o Docker e Docker Compose

- Começar com Docker:
 https://www.docker.com/get-started

- Instalar Docker Compose:
 https://docs.docker.com/compose/install/

### Passos para configuração com Docker:

1. Iniciar o Docker Compose Execute o comando abaixo para subir os serviços:

 ````bash
> docker compose up
 ````

2. Conectar o PgAdmin Acesse o PgAdmin pelo URL: http://localhost:5050, com a senha postgres.

Configure um novo servidor no PgAdmin:

* **Aba General**:
    * Nome: db
* **Aba Connection**:
    * Nome do host: db
    * Nome de usuário: postgres
    * Senha: postgres Em seguida, selecione o banco de dados "northwind".
 
 3. Parar o Docker Compose Pare o servidor iniciado pelo comando docker-compose up usando Ctrl-C e remova os contêineres com:

 ````bash
 docker compose down
 ````

4. Arquivos e Persistência Suas modificações nos bancos de dados Postgres serão persistidas no volume Docker postgresql_data e podem ser recuperadas reiniciando o Docker Compose com docker-compose up. Para deletar os dados do banco, execute:

 ````bash
 docker compose down -v
  ````
