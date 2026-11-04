-- =====================================================================
--  JobMatch — Dados de exemplo para testar o sistema
--  Senha de TODOS os usuários: Senha123
--
--  Candidatos:   ana@jobmatch.dev, bruno@jobmatch.dev,
--                caio@jobmatch.dev (currículo 40%: não consegue se candidatar)
--  Recrutadores: rita@acme.dev (Acme Tecnologia), carlos@nuvem.dev (Nuvem Digital)
--  Admin:        admin@jobmatch.dev
-- =====================================================================

SET NAMES utf8mb4;

SET @senha = '$2a$10$OhTaDS.xkcgaq6Ce.jIGduJ9yBQLoayyrv0V8FGQNn8QBIVs2TUDK';

INSERT INTO habilidade (id, nome) VALUES
  (1, 'JavaScript'), (2, 'React'), (3, 'Node.js'), (4, 'SQL'), (5, 'MySQL'), (6, 'Python'),
  (7, 'Figma'), (8, 'UX Research'), (9, 'Excel'), (10, 'Power BI'), (11, 'Comunicação'),
  (12, 'Inglês'), (13, 'Git'), (14, 'TypeScript'), (15, 'Marketing Digital');

INSERT INTO usuario (id, email, senha_hash, perfil, email_confirmado) VALUES
  (1, 'rita@acme.dev',      @senha, 'RECRUTADOR', TRUE),
  (2, 'carlos@nuvem.dev',   @senha, 'RECRUTADOR', TRUE),
  (3, 'ana@jobmatch.dev',   @senha, 'CANDIDATO',  TRUE),
  (4, 'bruno@jobmatch.dev', @senha, 'CANDIDATO',  TRUE),
  (5, 'caio@jobmatch.dev',  @senha, 'CANDIDATO',  TRUE),
  (6, 'admin@jobmatch.dev', @senha, 'ADMIN',      TRUE);

INSERT INTO empresa (id, razao_social, nome_fantasia, cnpj, setor, descricao, cidade, uf) VALUES
  (1, 'Acme Tecnologia Ltda', 'Acme Tecnologia', '11222333000181', 'Tecnologia',
      'Desenvolvemos sistemas de gestão para pequenas empresas.', 'São Paulo', 'SP'),
  (2, 'Nuvem Serviços Digitais S.A.', 'Nuvem Digital', '44555666000102', 'Marketing e dados',
      'Agência de marketing orientada a dados.', 'Campinas', 'SP');

INSERT INTO recrutador (id, usuario_id, empresa_id, nome, cargo, admin_empresa) VALUES
  (1, 1, 1, 'Rita Moraes', 'Analista de RH', TRUE),
  (2, 2, 2, 'Carlos Lima', 'Gerente de pessoas', TRUE);

INSERT INTO candidato (id, usuario_id, nome, cpf, data_nascimento, telefone, cidade, uf) VALUES
  (1, 3, 'Ana Souza',   '52998224725', '2001-05-10', '11999990000', 'São Paulo',   'SP'),
  (2, 4, 'Bruno Alves', '15350946056', '2000-08-22', '11988880000', 'Santo André', 'SP'),
  (3, 5, 'Caio Mendes', '39053344705', '2002-01-15', '19977770000', 'Campinas',    'SP');

INSERT INTO curriculo (id, candidato_id, resumo, pretensao_salarial, percentual_preenchido) VALUES
  (1, 1, 'Estudante de ADS com projetos em React e Node.js.', 3500, 85),
  (2, 2, 'Em transição para a área de dados, com foco em SQL e Power BI.', 3000, 90),
  (3, 3, 'Designer em início de carreira.', 2500, 40);

INSERT INTO formacao (curriculo_id, instituicao, curso, nivel, inicio) VALUES
  (1, 'Fatec', 'Análise e Desenvolvimento de Sistemas', 'Tecnólogo', '2023-02-01'),
  (2, 'Fatec', 'Ciência de Dados', 'Tecnólogo', '2023-02-01'),
  (3, 'Senac', 'Design Gráfico', 'Técnico', '2024-02-01');

INSERT INTO experiencia (curriculo_id, empresa, cargo, descricao, inicio, atual) VALUES
  (1, 'Projeto acadêmico', 'Desenvolvedora', 'Sistema web em equipe.', '2024-03-01', TRUE),
  (2, 'Mercado Bom Preço', 'Assistente administrativo', 'Controle de estoque em planilhas.', '2022-06-01', TRUE);

INSERT INTO curriculo_habilidade (curriculo_id, habilidade_id, nivel) VALUES
  (1, 1, 'INTERMEDIARIO'), (1, 2, 'INTERMEDIARIO'), (1, 13, 'INTERMEDIARIO'), (1, 4, 'BASICO'), (1, 12, 'INTERMEDIARIO'),
  (2, 6, 'BASICO'), (2, 4, 'INTERMEDIARIO'), (2, 10, 'INTERMEDIARIO'), (2, 9, 'AVANCADO'),
  (3, 7, 'BASICO');

-- Vagas (datas relativas a hoje para a lista parecer recente)
INSERT INTO vaga (id, empresa_id, recrutador_id, titulo, descricao, area, nivel, modalidade, tipo_contrato,
                  cidade, uf, salario_min, salario_max, status, publicada_em, encerrada_em) VALUES
  (1, 1, 1, 'Desenvolvedor(a) Front-end Júnior',
   'Você vai criar telas em React para nosso sistema de gestão, junto com o time de design.\n\nRequisitos: conhecimento em JavaScript e React, noções de Git.\nDesejável: inglês para leitura.\n\nBenefícios: vale-refeição, plano de saúde e auxílio home office.',
   'Tecnologia', 'Júnior', 'HIBRIDO', 'CLT', 'São Paulo', 'SP', 3200, 4200, 'ABERTA', NOW() - INTERVAL 2 DAY, NULL),
  (2, 1, 1, 'Desenvolvedor(a) Back-end Node.js',
   'Construção de APIs REST em Node.js com banco MySQL.\n\nRequisitos: Node.js, SQL e Git.',
   'Tecnologia', 'Pleno', 'REMOTO', 'PJ', NULL, NULL, 6000, 8000, 'ABERTA', NOW() - INTERVAL 5 DAY, NULL),
  (3, 1, 1, 'Estágio em Suporte Técnico', 'Atendimento a clientes e registro de chamados.',
   'Tecnologia', 'Estágio', 'PRESENCIAL', 'ESTAGIO', 'São Paulo', 'SP', 1500, 1500, 'ABERTA', NOW() - INTERVAL 9 DAY, NULL),
  (4, 1, 1, 'Designer UX/UI', 'Rascunho da vaga.',
   'Design', 'Pleno', 'HIBRIDO', 'CLT', 'São Paulo', 'SP', NULL, NULL, 'RASCUNHO', NULL, NULL),
  (5, 1, 1, 'Analista de Testes', 'Testes manuais e automatizados.',
   'Tecnologia', 'Júnior', 'REMOTO', 'CLT', NULL, NULL, NULL, NULL, 'PAUSADA', NOW() - INTERVAL 20 DAY, NULL),
  (6, 2, 2, 'Analista de Dados Júnior',
   'Montagem de relatórios e dashboards para clientes.\n\nRequisitos: SQL e Excel avançado. Desejável Power BI ou Python.',
   'Dados', 'Júnior', 'HIBRIDO', 'CLT', 'Campinas', 'SP', 3500, 4500, 'ABERTA', NOW() - INTERVAL 1 DAY, NULL),
  (7, 2, 2, 'Assistente de Marketing Digital', 'Gestão de redes sociais e campanhas pagas.',
   'Marketing', 'Júnior', 'PRESENCIAL', 'CLT', 'Campinas', 'SP', 2200, 2800, 'ABERTA', NOW() - INTERVAL 3 DAY, NULL),
  (8, 2, 2, 'Designer Gráfico Freelancer', 'Peças para campanhas de clientes.',
   'Design', 'Pleno', 'REMOTO', 'FREELANCER', NULL, NULL, NULL, NULL, 'ABERTA', NOW() - INTERVAL 7 DAY, NULL),
  (9, 2, 2, 'Estágio em Dados', 'Vaga já preenchida.',
   'Dados', 'Estágio', 'REMOTO', 'ESTAGIO', NULL, NULL, NULL, NULL, 'ENCERRADA', NOW() - INTERVAL 40 DAY, NOW() - INTERVAL 5 DAY);

INSERT INTO etapa_vaga (id, vaga_id, nome, ordem) VALUES
  (1, 1, 'Triagem de currículo', 1), (2, 1, 'Teste técnico', 2), (3, 1, 'Entrevista', 3), (4, 1, 'Proposta', 4),
  (5, 2, 'Triagem de currículo', 1), (6, 2, 'Teste técnico', 2), (7, 2, 'Entrevista', 3), (8, 2, 'Proposta', 4),
  (9, 3, 'Triagem de currículo', 1), (10, 3, 'Entrevista', 2),
  (11, 4, 'Triagem de currículo', 1), (12, 4, 'Portfólio', 2), (13, 4, 'Entrevista', 3),
  (14, 5, 'Triagem de currículo', 1), (15, 5, 'Entrevista', 2),
  (16, 6, 'Triagem de currículo', 1), (17, 6, 'Teste técnico', 2), (18, 6, 'Entrevista', 3), (19, 6, 'Proposta', 4),
  (20, 7, 'Triagem de currículo', 1), (21, 7, 'Entrevista', 2),
  (22, 8, 'Triagem de currículo', 1), (23, 8, 'Portfólio', 2),
  (24, 9, 'Triagem de currículo', 1), (25, 9, 'Entrevista', 2);

INSERT INTO vaga_habilidade (vaga_id, habilidade_id) VALUES
  (1, 1), (1, 2), (1, 13), (1, 12),
  (2, 3), (2, 4), (2, 5), (2, 13),
  (3, 11), (3, 9),
  (4, 7), (4, 8),
  (5, 13),
  (6, 4), (6, 9), (6, 10), (6, 6),
  (7, 15), (7, 11),
  (8, 7),
  (9, 9);

-- Candidaturas: Ana no teste técnico do Front-end; Bruno na triagem do Front-end e na entrevista de Dados
INSERT INTO candidatura (id, candidato_id, vaga_id, etapa_atual_id, status, carta_apresentacao, curriculo_snapshot, criado_em) VALUES
  (1, 1, 1, 2, 'EM_ANDAMENTO', 'Gosto muito de criar interfaces e quero crescer na área.',
   JSON_OBJECT('nome', 'Ana Souza', 'email', 'ana@jobmatch.dev', 'telefone', '11999990000', 'cidade', 'São Paulo', 'uf', 'SP',
     'resumo', 'Estudante de ADS com projetos em React e Node.js.', 'pretensaoSalarial', 3500,
     'formacoes', JSON_ARRAY(JSON_OBJECT('instituicao', 'Fatec', 'curso', 'Análise e Desenvolvimento de Sistemas', 'nivel', 'Tecnólogo', 'inicio', '2023-02-01', 'fim', NULL)),
     'experiencias', JSON_ARRAY(JSON_OBJECT('empresa', 'Projeto acadêmico', 'cargo', 'Desenvolvedora', 'inicio', '2024-03-01', 'fim', NULL, 'atual', TRUE)),
     'habilidades', JSON_ARRAY(JSON_OBJECT('nome', 'Git'), JSON_OBJECT('nome', 'Inglês'), JSON_OBJECT('nome', 'JavaScript'), JSON_OBJECT('nome', 'React'), JSON_OBJECT('nome', 'SQL'))),
   NOW() - INTERVAL 2 DAY),
  (2, 2, 1, 1, 'EM_ANDAMENTO', NULL,
   JSON_OBJECT('nome', 'Bruno Alves', 'email', 'bruno@jobmatch.dev', 'telefone', '11988880000', 'cidade', 'Santo André', 'uf', 'SP',
     'resumo', 'Em transição para a área de dados, com foco em SQL e Power BI.', 'pretensaoSalarial', 3000,
     'formacoes', JSON_ARRAY(JSON_OBJECT('instituicao', 'Fatec', 'curso', 'Ciência de Dados', 'nivel', 'Tecnólogo', 'inicio', '2023-02-01', 'fim', NULL)),
     'experiencias', JSON_ARRAY(JSON_OBJECT('empresa', 'Mercado Bom Preço', 'cargo', 'Assistente administrativo', 'inicio', '2022-06-01', 'fim', NULL, 'atual', TRUE)),
     'habilidades', JSON_ARRAY(JSON_OBJECT('nome', 'Excel'), JSON_OBJECT('nome', 'Power BI'), JSON_OBJECT('nome', 'Python'), JSON_OBJECT('nome', 'SQL'))),
   NOW() - INTERVAL 1 DAY),
  (3, 2, 6, 18, 'EM_ANDAMENTO', 'Tenho experiência com planilhas e dashboards.',
   JSON_OBJECT('nome', 'Bruno Alves', 'email', 'bruno@jobmatch.dev', 'telefone', '11988880000', 'cidade', 'Santo André', 'uf', 'SP',
     'resumo', 'Em transição para a área de dados, com foco em SQL e Power BI.', 'pretensaoSalarial', 3000,
     'formacoes', JSON_ARRAY(), 'experiencias', JSON_ARRAY(),
     'habilidades', JSON_ARRAY(JSON_OBJECT('nome', 'Excel'), JSON_OBJECT('nome', 'Power BI'), JSON_OBJECT('nome', 'Python'), JSON_OBJECT('nome', 'SQL'))),
   NOW() - INTERVAL 1 DAY);

INSERT INTO historico_candidatura (candidatura_id, etapa_id, autor_usuario_id, status, feedback, criado_em) VALUES
  (1, 1, 3,    'EM_ANDAMENTO',   NULL, NOW() - INTERVAL 2 DAY),
  (1, 1, 1,    'APROVADO_ETAPA', 'Currículo alinhado com a vaga.', NOW() - INTERVAL 1 DAY),
  (1, 2, 1,    'EM_ANDAMENTO',   NULL, NOW() - INTERVAL 1 DAY),
  (2, 1, 4,    'EM_ANDAMENTO',   NULL, NOW() - INTERVAL 1 DAY),
  (3, 16, 4,   'EM_ANDAMENTO',   NULL, NOW() - INTERVAL 1 DAY),
  (3, 16, 2,   'APROVADO_ETAPA', NULL, NOW() - INTERVAL 1 DAY),
  (3, 17, 2,   'EM_ANDAMENTO',   NULL, NOW() - INTERVAL 1 DAY),
  (3, 17, 2,   'APROVADO_ETAPA', 'Ótimo resultado no teste.', NOW() - INTERVAL 1 DAY),
  (3, 18, 2,   'EM_ANDAMENTO',   NULL, NOW() - INTERVAL 1 DAY);
