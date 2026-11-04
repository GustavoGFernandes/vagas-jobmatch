# JobMatch — Vagas

Páginas de vagas do JobMatch: lista com busca e filtros, detalhe com candidatura, vagas favoritas e, para a empresa, minhas vagas, cadastro/edição em 3 passos e o quadro do processo seletivo.

## Estrutura

```
.
├── backend/
│   ├── src/
│   │   ├── config/          db.js (conexão com o MySQL)
│   │   ├── controllers/     regras e consultas de cada assunto
│   │   ├── middlewares/     auth.js (login e perfis) e erros.js
│   │   ├── routes/          index.js + uma rota por assunto
│   │   ├── app.js
│   │   └── server.js
│   ├── .env.example
│   ├── Dockerfile
│   └── package.json
├── database/
│   ├── init/
│   │   ├── 01-schema.sql          17 tabelas (modelo físico)
│   │   └── 02-dados-exemplo.sql   empresas, vagas, candidatos e candidaturas de teste
│   └── Dockerfile
├── frontend/
│   ├── src/app/             páginas (App Router do Next.js)
│   │   ├── _components/     peças reutilizáveis (cabeçalho, card de vaga, modal, formulário...)
│   │   ├── _lib/            chamada à API, login e formatação
│   │   ├── vagas/           /vagas e /vagas/[id]
│   │   ├── favoritos/
│   │   ├── empresa/vagas/   minhas vagas, nova, [id]/editar, [id]/processo
│   │   ├── login/
│   │   ├── layout.js
│   │   └── globals.css
│   ├── .env.example
│   ├── Dockerfile
│   └── package.json
├── .env.example
└── docker-compose.yml
```

As pastas com `_` dentro de `src/app` (`_components`, `_lib`) não viram páginas. É a forma do Next.js de guardar código de apoio ao lado das rotas.

## Tecnologias

- **Frontend:** Next.js 16.2.10 em JavaScript, sem Tailwind nem Bootstrap (CSS próprio em `globals.css`)
- **Backend:** Node.js + Express em JavaScript, com `mysql2`, `jsonwebtoken` e `bcryptjs`
- **Banco:** MySQL 8

## Rodar localmente

1. Instale as dependências:
   ```bash
   cd backend && npm install
   cd ../frontend && npm install
   ```
2. Copie os arquivos de ambiente:
   - `.env.example` → `.env` (raiz)
   - `backend/.env.example` → `backend/.env`
   - `frontend/.env.example` → `frontend/.env.local`
3. Suba o MySQL:
   - com Docker: `docker compose up -d database` (já roda os arquivos de `database/init`)
   - ou com XAMPP/MySQL local: crie o banco `app_db` e importe `01-schema.sql` e depois `02-dados-exemplo.sql`
4. Backend: `cd backend && npm run dev`
5. Frontend: `cd frontend && npm run dev`

Endereços:
- Frontend: http://localhost:3000
- Backend: http://localhost:8080
- Teste da API e do banco: http://localhost:8080/api/health

Para zerar o banco no Docker: `docker compose down -v` e `docker compose up -d database`.

### Com Docker Compose (tudo junto)

```bash
cp .env.example .env
docker compose up --build
```

## Contas de teste

Todas com a senha **Senha123**. A tela de login tem botões que preenchem as duas primeiras.

| Perfil | E-mail | Observação |
| --- | --- | --- |
| Candidata | ana@jobmatch.dev | já está no teste técnico da vaga de Front-end |
| Recrutadora | rita@acme.dev | empresa Acme Tecnologia |
| Candidato | bruno@jobmatch.dev | em processo em duas vagas |
| Candidato | caio@jobmatch.dev | currículo 40%: não consegue se candidatar (RN05) |
| Recrutador | carlos@nuvem.dev | empresa Nuvem Digital |

## Páginas

| Endereço | Quem | O que tem |
| --- | --- | --- |
| `/vagas` | todos | busca, filtros (cidade, modalidade, contrato, nível, área, salário), ordenação e paginação. O candidato vê o match de cada vaga. |
| `/vagas/[id]` | todos | detalhe da vaga e etapas. O candidato favorita, se candidata com carta, acompanha a etapa e pode desistir. |
| `/favoritos` | candidato | vagas salvas |
| `/empresa/vagas` | recrutador | vagas da empresa: editar, publicar, pausar, reabrir, encerrar, duplicar e excluir rascunho |
| `/empresa/vagas/nova` | recrutador | cadastro em 3 passos: dados → requisitos e habilidades → etapas |
| `/empresa/vagas/[id]/editar` | recrutador | o mesmo formulário, preenchido |
| `/empresa/vagas/[id]/processo` | recrutador | quadro Kanban: arraste o candidato entre etapas ou clique para ver o currículo, aprovar, reprovar ou contratar |

## API

Base: `/api`. Rotas com login usam o cabeçalho `Authorization: Bearer <token>`.

| Método | Rota | Quem | O que faz |
| --- | --- | --- | --- |
| GET | `/api/health` | público | status da API e do MySQL |
| POST | `/api/auth/login` | público | login; devolve o token |
| GET | `/api/auth/me` | logado | dados do usuário |
| GET | `/api/vagas` | público | lista com filtros: `q`, `cidade`, `area`, `nivel`, `modalidade`, `contrato`, `salarioMin`, `ordem`, `page`, `size` |
| GET | `/api/vagas/filtros` | público | opções dos filtros |
| GET | `/api/vagas/:id` | público | detalhe |
| GET | `/api/vagas/minhas` | recrutador | vagas da empresa com contagem de candidatos |
| POST | `/api/vagas` | recrutador | criar (`publicar: true` já abre) |
| PUT | `/api/vagas/:id` | recrutador | editar |
| PATCH | `/api/vagas/:id/status` | recrutador | `ABERTA`, `PAUSADA` ou `ENCERRADA` |
| POST | `/api/vagas/:id/duplicar` | recrutador | copia como rascunho |
| DELETE | `/api/vagas/:id` | recrutador | exclui rascunho |
| GET | `/api/vagas/:id/candidaturas` | recrutador | quadro do processo |
| POST | `/api/vagas/:id/candidaturas` | candidato | candidatar-se |
| GET | `/api/candidaturas/motivos-reprovacao` | público | motivos de reprovação |
| GET | `/api/candidaturas/:id` | empresa ou candidato | currículo enviado e histórico |
| PATCH | `/api/candidaturas/:id/etapa` | recrutador | `{ acao: "avancar" \| "mover" \| "reprovar" \| "contratar" }` |
| DELETE | `/api/candidaturas/:id` | candidato | desistir |
| GET | `/api/favoritos/vagas` | candidato | vagas favoritas |
| POST | `/api/favoritos` | logado | `{ tipo: "VAGA", referenciaId }` |
| DELETE | `/api/favoritos/:tipo/:id` | logado | remove favorito |
| GET | `/api/habilidades?q=` | público | sugestões de habilidades |

Erros vêm sempre como `{ "erro": "codigo", "mensagem": "texto" }`: 400 dados inválidos, 401 sem login, 403 sem permissão, 404 não encontrado, 409 bloqueado por regra de negócio.

## Regras de negócio aplicadas

| Regra | Onde |
| --- | --- |
| RN05 currículo com 70% para se candidatar | `candidaturasController.candidatar` |
| RN06 cópia do currículo na candidatura | `candidaturasController.montarSnapshot` |
| RN07 campos obrigatórios e ao menos uma etapa | `vagasController.validarVaga` |
| RN08 Rascunho → Aberta → Pausada ↔ Aberta → Encerrada | `vagasController.TRANSICOES` |
| RN09 salário mínimo ≤ máximo | `validarVaga` e `CHECK` no banco |
| RN10 uma candidatura por vaga, só em vaga aberta | `candidatar` e `UNIQUE` no banco |
| RN11 começa na primeira etapa | `candidatar` |
| RN12 só a empresa dona move candidatos, com histórico | `candidaturasController.movimentar` |
| RN13 reprovação exige motivo | `movimentar` e `CHECK` no banco |
| RN14 status final não muda | `movimentar` |
| RN15 desistir antes do status final | `candidaturasController.desistir` |
| RN16 encerrar a vaga reprova quem estava em andamento | `vagasController.alterarStatus` |
| RN17 favoritar não notifica | `favoritosController` |

Outras decisões: as etapas só mudam enquanto a vaga não tem candidaturas; contratar só na última etapa; o match segue a fórmula da documentação sem o termo de nível de experiência (o currículo ainda não tem esse campo).
