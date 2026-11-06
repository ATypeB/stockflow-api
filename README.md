# StockFlow API

[![StockFlow CI](https://github.com/ATypeB/stockflow-api/actions/workflows/ci.yml/badge.svg)](https://github.com/ATypeB/stockflow-api/actions/workflows/ci.yml)

API REST para gerenciamento de produtos e controle básico de estoque, desenvolvida como projeto prático da disciplina **DevOps na Prática**. O foco do projeto é aplicar práticas de DevOps: versionamento, testes automatizados, integração contínua e Infraestrutura como Código.

## Tecnologias

- Node.js 22, TypeScript e Express 5
- Vitest e Supertest (testes automatizados)
- GitHub Actions (integração contínua)
- Terraform (infraestrutura na AWS: EC2, DynamoDB, IAM, VPC)

## Status do projeto

**Fase 1 – Configuração e Automação Inicial** (concluída)

- API REST com CRUD de produtos
- Pipeline de CI com GitHub Actions
- Scripts Terraform validados (o provisionamento real na AWS não foi executado)
- Armazenamento **em memória**: os dados são perdidos quando a aplicação reinicia

**Fase 2 – Entrega Contínua, Monitoramento e Segurança** (planejada)

- Containerização com Docker
- Entrega contínua (CD) com publicação da imagem no Amazon ECR e deploy na EC2
- Integração da API com o Amazon DynamoDB

## Modelo de produto

| Campo         | Tipo   | Regra                        |
|---------------|--------|------------------------------|
| `id`          | string | gerado automaticamente (UUID) |
| `name`        | string | obrigatório, não pode ser vazio |
| `description` | string | obrigatório (pode ser vazio) |
| `quantity`    | number | inteiro maior ou igual a 0   |
| `price`       | number | maior ou igual a 0           |

## Endpoints

| Método | Rota             | Descrição                    | Respostas          |
|--------|------------------|------------------------------|--------------------|
| GET    | `/`              | Verifica se a API está no ar | 200                |
| GET    | `/products`      | Lista todos os produtos      | 200                |
| GET    | `/products/:id`  | Consulta um produto pelo ID  | 200, 404           |
| POST   | `/products`      | Cadastra um produto          | 201, 400           |
| PUT    | `/products/:id`  | Atualiza um produto          | 200, 400, 404      |
| DELETE | `/products/:id`  | Exclui um produto            | 204, 404           |

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

Pré-requisito: Node.js 22.

```bash
npm ci            # instala as dependências
npm run dev       # modo desenvolvimento (recarrega ao salvar)
npm run build     # compila o TypeScript para dist/
npm start         # executa a versão compilada
npm test          # executa os testes automatizados
```

Por padrão a API fica disponível em `http://localhost:3000`.

## Integração contínua

O workflow `.github/workflows/ci.yml` (**StockFlow CI**) roda em todo `push` e em Pull Requests para a branch `main`. Ele:

1. Instala as dependências (`npm ci`)
2. Compila a aplicação (`npm run build`)
3. Executa os testes (`npm test`)
4. Verifica a formatação do Terraform (`terraform fmt -check -recursive`)
5. Inicializa e valida a infraestrutura (`terraform init -backend=false` e `terraform validate`)

O pipeline não usa credenciais da AWS, não cria recursos e não faz deploy. A entrega contínua será implementada na Fase 2.

## Infraestrutura (Terraform)

Os arquivos ficam em `infra/` e descrevem:

- **DynamoDB**: tabela de produtos (cobrança sob demanda)
- **EC2**: instância que hospedará a API
- **IAM**: role com acesso restrito à tabela de produtos, associada à EC2
- **VPC**: rede, subnet pública, internet gateway, rotas e security group (porta 3000, liberada apenas para o IP informado)

Para planejar a infraestrutura:

```bash
cd infra
# copie terraform.tfvars.example para terraform.tfvars e preencha
# ami_id (AMI do Amazon Linux 2023 na região) e allowed_cidr (seu IP no formato 203.0.113.10/32)
terraform init
terraform plan
```

O arquivo `terraform.tfvars` não é versionado.

## Estrutura do repositório

```
.github/workflows/ci.yml   pipeline de integração contínua
infra/                     scripts Terraform
src/
  app.ts                   configuração do Express
  server.ts                inicialização do servidor
  routes/                  rotas da API
  services/                regras de negócio e armazenamento
tests/                     testes automatizados das rotas
```
