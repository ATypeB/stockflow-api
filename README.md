# StockFlow API

[![StockFlow CI/CD](https://github.com/ATypeB/stockflow-api/actions/workflows/ci.yml/badge.svg)](https://github.com/ATypeB/stockflow-api/actions/workflows/ci.yml)

API REST para gerenciamento de produtos e controle básico de estoque, desenvolvida como projeto prático da disciplina **DevOps na Prática**. O foco do projeto é aplicar práticas de DevOps: versionamento, testes automatizados, integração e entrega contínuas, containers e Infraestrutura como Código.

## Tecnologias

- Node.js 22, TypeScript e Express 5
- Vitest e Supertest (testes automatizados)
- GitHub Actions (CI/CD)
- Docker e Docker Compose (containerização)
- GitHub Container Registry, GHCR (registro de imagens)
- Terraform (infraestrutura na AWS: VPC, EC2, DynamoDB)
- AWS Systems Manager (deploy na EC2, sem SSH)

## Status do projeto

**Fase 1: Configuração e Automação Inicial** (concluída)

- API REST com CRUD de produtos
- Pipeline de CI com GitHub Actions
- Scripts Terraform validados no pipeline

**Fase 2: Entrega Contínua, Containers e Deploy** (concluída, branch `fase-2`)

- Containerização com Docker (multi-stage, usuário não-root e health check)
- Orquestração local com Docker Compose
- Pipeline de CD: build e push da imagem no GHCR e deploy automático na EC2
- Infraestrutura aplicada de verdade na AWS Academy com Terraform

**Limitações conhecidas**

- Armazenamento **em memória**: os dados são perdidos quando a aplicação reinicia. A tabela DynamoDB já é provisionada pelo Terraform, mas ainda não é usada pela API.
- Instância única, sem balanceador de carga e sem HTTPS.
- Sem monitoramento ou alarmes (CloudWatch é uma melhoria futura).
- O deploy troca o container, o que causa uma breve indisponibilidade durante a atualização.
- As credenciais e o IP público do AWS Academy são temporários.

## Modelo de produto

| Campo         | Tipo   | Regra                           |
|---------------|--------|---------------------------------|
| `id`          | string | gerado automaticamente (UUID)   |
| `name`        | string | obrigatório, não pode ser vazio |
| `description` | string | obrigatório (pode ser vazio)    |
| `quantity`    | number | inteiro maior ou igual a 0      |
| `price`       | number | maior ou igual a 0              |

## Endpoints

| Método | Rota            | Descrição                    | Respostas     |
|--------|-----------------|------------------------------|---------------|
| GET    | `/`             | Verifica se a API está no ar | 200           |
| GET    | `/products`     | Lista todos os produtos      | 200           |
| GET    | `/products/:id` | Consulta um produto pelo ID  | 200, 404      |
| POST   | `/products`     | Cadastra um produto          | 201, 400      |
| PUT    | `/products/:id` | Atualiza um produto          | 200, 400, 404 |
| DELETE | `/products/:id` | Exclui um produto            | 204, 404      |

Dados inválidos retornam `400` com `{ "message": "Dados do produto inválidos." }`. Produtos inexistentes retornam `404` com `{ "message": "Produto não encontrado." }`.

Exemplo de cadastro:

```json
POST /products
{
  "name": "Notebook",
  "description": "Notebook para testes",
  "quantity": 5,
  "price": 3500
}
```

## Como executar

### Com Node.js

Pré-requisito: Node.js 22.

```bash
npm ci            # instala as dependências
npm run dev       # modo desenvolvimento (recarrega ao salvar)
npm run build     # compila o TypeScript para dist/
npm start         # executa a versão compilada
npm test          # executa os testes automatizados
```

Por padrão a API fica disponível em `http://localhost:3000`.

### Com Docker

Pré-requisito: Docker Desktop (ou Docker Engine) com Compose.

```bash
docker compose up --build -d   # constrói a imagem e sobe a API
docker compose ps              # mostra o estado (healthy)
docker compose down            # desliga e remove o container
```

Sem Compose, apenas com Docker:

```bash
docker build -t stockflow-api .
docker run --rm -p 3000:3000 stockflow-api
```

A porta 3000 precisa estar livre na máquina.

## Containers

- `Dockerfile`: build multi-stage em `node:22-alpine`. O estágio de build compila o TypeScript; a imagem final recebe só `dist/` e as dependências de produção, roda como usuário `node` (não-root) e define um `HEALTHCHECK`.
- `.dockerignore`: mantém `node_modules`, `infra` e arquivos locais fora do contexto de build.
- `docker-compose.yml`: orquestração local da API (build, porta, reinício automático e health check).

## Pipeline CI/CD

O workflow `.github/workflows/ci.yml` (**StockFlow CI/CD**) roda em `push` nas branches `main` e `fase-2`, em Pull Requests para a `main` e também manualmente (`workflow_dispatch`). Ele tem três jobs encadeados, e cada um só começa se o anterior passar:

1. **Build and Tests:** instala as dependências (`npm ci`), compila, executa os testes e valida o Terraform (`fmt -check`, `init -backend=false` e `validate`).
2. **Build and Push Docker Image:** constrói a imagem com Buildx e publica no GHCR (`ghcr.io/atypeb/stockflow-api`) com as tags `latest` e o SHA do commit.
3. **Deploy to EC2:** executa `scripts/deploy-remote.sh`, que envia o deploy para a instância EC2 pelo AWS Systems Manager.

Os jobs 2 e 3 não rodam em Pull Requests. O job de deploy usa `concurrency: deploy-ec2` para evitar dois deploys ao mesmo tempo.

### Segredos necessários

Em GitHub, **Settings > Secrets and variables > Actions > Repository secrets**:

| Segredo                 | Uso                                        |
|-------------------------|--------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | credencial temporária do AWS Academy       |
| `AWS_SECRET_ACCESS_KEY` | credencial temporária do AWS Academy       |
| `AWS_SESSION_TOKEN`     | credencial temporária do AWS Academy       |
| `EC2_INSTANCE_ID`       | ID da instância (`terraform output`)       |

As credenciais do AWS Academy expiram com a sessão do laboratório e precisam ser atualizadas a cada nova sessão. Nunca as versione no repositório.

## Scripts de deploy

- `scripts/deploy-remote.sh` (roda no pipeline ou na máquina do desenvolvedor): monta o comando, envia o `deploy.sh` para a EC2 com `aws ssm send-command` (documento `AWS-RunShellScript`), aguarda a conclusão e só termina com sucesso se o status do comando for `Success`. Não precisa de SSH nem de porta 22 aberta.
- `scripts/deploy.sh` (roda dentro da EC2): baixa a imagem informada em `IMAGE` (`docker pull`), remove o container anterior, inicia o novo com `--restart unless-stopped` e verifica a saúde da API em até 15 tentativas. Se a API não responder, imprime os últimos logs do container e falha, o que deixa o job vermelho no GitHub Actions.

Para fazer um deploy manual a partir de uma máquina com credenciais AWS válidas:

```bash
export INSTANCE_ID=<id da instância>
export IMAGE=ghcr.io/atypeb/stockflow-api:<sha do commit>
bash scripts/deploy-remote.sh
```

Rollback: reexecute o deploy com o SHA de uma versão anterior.

## Infraestrutura (Terraform)

Os arquivos ficam em `infra/` e descrevem:

- **VPC:** rede, subnet pública (zona `us-east-1a`), internet gateway, tabela de rotas e Security Group (porta 3000 liberada apenas para o IP informado em `allowed_cidr`)
- **EC2:** instância `t3.micro` com Amazon Linux 2023, Docker instalado via `user_data` e IMDSv2 obrigatório. Usa o instance profile `LabInstanceProfile`, já existente no AWS Academy.
- **DynamoDB:** tabela de produtos (cobrança sob demanda)

Para provisionar:

```bash
# copie infra/terraform.tfvars.example para infra/terraform.tfvars
# e preencha allowed_cidr com o seu IP no formato 203.0.113.10/32
terraform -chdir=infra init
terraform -chdir=infra plan
terraform -chdir=infra apply
terraform -chdir=infra output     # mostra o ID da instância, o IP e a URL da API
```

Para remover tudo ao final: `terraform -chdir=infra destroy`.

Os arquivos `terraform.tfvars` e `*.tfstate` não são versionados.

## Segurança

- Deploy sem SSH (Systems Manager), sem chave privada para proteger.
- Credenciais somente em GitHub Secrets e em `~/.aws/credentials`, nunca no repositório.
- Container executa como usuário não-root.
- IMDSv2 obrigatório na EC2.
- Security Group restrito ao IP do desenvolvedor.

## Estrutura do repositório

```
.github/workflows/ci.yml   pipeline de CI/CD
Dockerfile                 imagem da API (multi-stage)
docker-compose.yml         orquestração local
.dockerignore              arquivos fora do contexto de build
scripts/
  deploy-remote.sh         envia o deploy à EC2 via Systems Manager
  deploy.sh                executado na EC2 (pull, troca do container, health check)
infra/                     scripts Terraform
src/
  app.ts                   configuração do Express
  server.ts                inicialização do servidor
  routes/                  rotas da API
  services/                regras de negócio e armazenamento
tests/                     testes automatizados das rotas
```