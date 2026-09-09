# Explicando o Docker Compose

Este documento explica a estrutura do arquivo `docker-compose.yml` deste projeto, o que pode ser editado e como os containers PostgreSQL e pgAdmin se relacionam.

## 1. O que e Docker Compose

Docker Compose permite definir e executar varios containers relacionados usando um arquivo YAML.

Neste projeto, o Compose define dois servicos:

- `db`: banco de dados PostgreSQL 18.
- `pgadmin`: interface web para administrar o PostgreSQL.

A especificacao atual do Compose nao exige um campo `version` no inicio do arquivo. Por isso, o arquivo comeca diretamente com `services`.

Referencia:

- [Compose file reference](https://docs.docker.com/reference/compose-file/)
- [Compose application model](https://docs.docker.com/compose/intro/compose-application-model/)

## 2. Estrutura basica

Cada item dentro de `services` representa um container:

```yaml
services:
  db:
    image: postgres:18
```

No arquivo deste projeto:

```yaml
services:
  db:
  pgadmin:
```

### `image`

Indica qual imagem Docker sera usada:

```yaml
image: postgres:18
image: dpage/pgadmin4
```

A imagem `postgres:18` usa PostgreSQL 18. A imagem `dpage/pgadmin4` usa a versao padrao disponibilizada pelo mantenedor.

Esse campo pode ser editado. E recomendado informar uma tag especifica para controlar a versao e evitar atualizacoes inesperadas. Alterar a versao principal do PostgreSQL pode exigir migracao do banco.

### `container_name`

Define um nome fixo para o container:

```yaml
container_name: db
container_name: pgadmin
```

Pode ser editado. Tambem pode ser removido para que o Docker Compose gere os nomes automaticamente. Remover esse campo facilita executar varias copias do projeto no mesmo computador.

Referencias:

- [Compose services](https://docs.docker.com/reference/compose-file/services/)
- [Docker image reference](https://docs.docker.com/reference/cli/docker/image/)

## 3. Variaveis de ambiente

Variaveis de ambiente configuram os containers no momento da inicializacao.

### PostgreSQL

```yaml
environment:
  POSTGRES_DB: northwind
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres
```

Essas variaveis definem:

- `POSTGRES_DB`: nome do banco criado inicialmente.
- `POSTGRES_USER`: usuario inicial do PostgreSQL.
- `POSTGRES_PASSWORD`: senha do usuario inicial.

Esses valores podem ser alterados. A senha simples do exemplo deve ser substituida em ambientes reais.

### pgAdmin

```yaml
environment:
  PGADMIN_DEFAULT_EMAIL: pgadmin4@pgadmin.org
  PGADMIN_DEFAULT_PASSWORD: postgres
  PGADMIN_LISTEN_PORT: 5050
  PGADMIN_CONFIG_SERVER_MODE: 'False'
```

- `PGADMIN_DEFAULT_EMAIL`: email usado para entrar no pgAdmin.
- `PGADMIN_DEFAULT_PASSWORD`: senha usada para entrar no pgAdmin.
- `PGADMIN_LISTEN_PORT`: porta em que o pgAdmin escuta dentro do container.
- `PGADMIN_CONFIG_SERVER_MODE`: configuracao do modo de servidor do pgAdmin.

Referencias:

- [PostgreSQL Docker Official Image](https://hub.docker.com/_/postgres)
- [PostgreSQL Docker documentation](https://github.com/docker-library/docs/tree/master/postgres)
- [pgAdmin container deployment](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html)

## 4. Volumes e arquivos

Volumes preservam dados ou disponibilizam arquivos dentro dos containers.

### Volumes nomeados

Sao gerenciados pelo Docker e permanecem depois que os containers sao removidos:

```yaml
postgresql_bin:/usr/lib/postgresql
postgresql_data:/var/lib/postgresql
pgadmin_root_prefs:/root/.pgadmin
pgadmin_working_dir:/var/lib/pgadmin
```

A declaracao dos volumes fica no final do arquivo:

```yaml
volumes:
  pgadmin_root_prefs:
    driver: local
```

O volume mais importante para os dados do banco e `postgresql_data`.

### Bind mounts

Conectam arquivos ou pastas do computador a caminhos dentro do container:

```yaml
./northwind.sql:/docker-entrypoint-initdb.d/northwind.sql
./files:/files
```

- `./northwind.sql` e o arquivo SQL no computador.
- `/docker-entrypoint-initdb.d/northwind.sql` e o caminho dentro do container PostgreSQL.
- `./files` e a pasta local do projeto.
- `/files` e o caminho dessa pasta dentro do container.

O PostgreSQL executa o SQL de inicializacao somente quando o diretorio de dados esta vazio. Se o volume `postgresql_data` ja possuir um banco, alterar `northwind.sql` nao executara o script novamente automaticamente.

Referencias:

- [Compose volumes](https://docs.docker.com/reference/compose-file/volumes/)
- [Docker volumes](https://docs.docker.com/engine/storage/volumes/)
- [Docker bind mounts](https://docs.docker.com/engine/storage/bind-mounts/)
- [PostgreSQL initialization scripts](https://github.com/docker-library/docs/tree/master/postgres#initialization-scripts)

## 5. Portas

A sintaxe e:

```text
porta_no_computador:porta_no_container
```

### PostgreSQL

```yaml
ports:
  - 55432:5432
```

Isso significa:

- `55432`: porta disponivel no computador.
- `5432`: porta usada pelo PostgreSQL dentro do container.

Do computador, a conexao usa `localhost:55432`.

De outro container na mesma rede, a conexao usa:

```text
host: db
porta: 5432
```

### pgAdmin

```yaml
ports:
  - 5050:5050
```

Acesse a interface no navegador:

```text
http://localhost:5050
```

Referencia:

- [Compose ports](https://docs.docker.com/reference/compose-file/services/#ports)
- [Docker port publishing](https://docs.docker.com/engine/network/port-publishing/)

## 6. Redes

Os dois servicos usam a mesma rede:

```yaml
networks:
  - db
```

A rede e declarada no final do arquivo:

```yaml
networks:
  db:
    driver: bridge
```

O driver `bridge` permite que os containers se comuniquem. Dentro da rede, o nome do servico funciona como nome de host.

Por isso, ao cadastrar o PostgreSQL no pgAdmin, use:

```text
Host name/address: db
Port: 5432
Username: postgres
Password: postgres
```

Nao use `localhost` como host dentro do pgAdmin. Nesse contexto, `localhost` aponta para o proprio container do pgAdmin.

Referencia:

- [Compose networks](https://docs.docker.com/reference/compose-file/networks/)
- [Docker networking](https://docs.docker.com/engine/network/)

## 7. Comandos principais

Execute os comandos a partir da pasta que contem o `docker-compose.yml`.

### Iniciar os containers

```bash
docker compose up -d
```

O parametro `-d` executa os containers em segundo plano.

### Ver o status

```bash
docker compose ps
```

### Ver os logs

```bash
docker compose logs -f
```

Para ver apenas os logs do banco:

```bash
docker compose logs -f db
```

### Abrir o psql dentro do container

```bash
docker compose exec db psql -U postgres -d northwind
```

### Parar e remover os containers

```bash
docker compose down
```

Esse comando remove os containers e preserva os volumes nomeados.

### Remover containers e volumes

```bash
docker compose down -v
```

Esse comando tambem remove os volumes nomeados. Os dados do banco serao apagados e o `northwind.sql` sera executado novamente na proxima inicializacao.

### Validar o arquivo

```bash
docker compose config
```

Esse comando verifica e exibe a configuracao final sem iniciar os containers.

Referencia:

- [Docker Compose command-line reference](https://docs.docker.com/reference/cli/docker/compose/)

## 8. O que e editavel

| Item | Pode editar? | Cuidados |
|---|---|---|
| Nome dos servicos | Sim | Outros servicos podem usar esses nomes como host.
| `image` | Sim | Verifique compatibilidade entre versoes.
| `container_name` | Sim | Nomes fixos podem impedir varias copias do projeto.
| Variaveis de ambiente | Sim | Use valores seguros fora de um ambiente local.
| Portas externas | Sim | Escolha portas livres no computador.
| Portas internas | Com cuidado | Devem corresponder ao servico dentro da imagem.
| Volumes | Sim | Alterar ou remover pode causar perda de dados.
| Caminhos locais | Sim | O arquivo ou pasta precisa existir no computador.
| Nome da rede | Sim | Todos os servicos que precisam conversar devem usa-la.
| `driver: bridge` | Com cuidado | E o padrao adequado para esta comunicacao local.

## 9. Observacao sobre PostgreSQL 18 e `postgresql_bin`

A documentacao da imagem oficial do PostgreSQL indica `/var/lib/postgresql` como o alvo de volume para PostgreSQL 18. Isso corresponde ao mount usado por `postgresql_data` neste projeto.

O volume `postgresql_bin` e montado em `/usr/lib/postgresql` nos dois containers. A documentacao do pgAdmin lista os utilitarios PostgreSQL em caminhos como `/usr/local/pgsql-18`. Portanto, esse volume compartilhado normalmente nao e necessario apenas para conectar o pgAdmin ao PostgreSQL.

Mantenha esse volume somente se houver uma finalidade especifica no projeto. Caso contrario, ele pode ser candidato a revisao futura.

Referencias:

- [PostgreSQL Docker image: PGDATA and PostgreSQL 18](https://hub.docker.com/_/postgres)
- [pgAdmin container: PostgreSQL utilities](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html#postgresql-utilities)
