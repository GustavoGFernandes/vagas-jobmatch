-- =====================================================================
--  JobMatch — Modelo físico do banco de dados (MySQL 8)
--  17 tabelas · chaves, restrições e índices
--
--  No Docker, este arquivo roda sozinho na primeira vez que o MySQL sobe.
--  No XAMPP/MySQL local: selecione o banco (ex.: app_db) e importe este
--  arquivo e depois o 02-dados-exemplo.sql.
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS visualizacao_vaga, notificacao, favorito, historico_candidatura, candidatura,
  etapa_vaga, vaga_habilidade, vaga, curriculo_habilidade, habilidade, experiencia, formacao,
  curriculo, recrutador, empresa, candidato, usuario;

SET FOREIGN_KEY_CHECKS = 1;


-- ---------------------------------------------------------------------
--  Contas e empresas
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email             VARCHAR(150) NOT NULL,
    senha_hash        VARCHAR(255) NOT NULL,
    perfil            ENUM('CANDIDATO', 'RECRUTADOR', 'ADMIN') NOT NULL,
    ativo             BOOLEAN      NOT NULL DEFAULT TRUE,
    email_confirmado  BOOLEAN      NOT NULL DEFAULT FALSE,
    criado_em         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_usuario_email UNIQUE (email)                                -- RN01
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci
  COMMENT = 'Conta de acesso; o perfil define se é candidato, recrutador ou administrador';

CREATE TABLE candidato (
    id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id       BIGINT UNSIGNED NOT NULL,
    nome             VARCHAR(120) NOT NULL,
    cpf              CHAR(11)     NOT NULL,                                   -- só dígitos
    data_nascimento  DATE         NOT NULL,
    telefone         VARCHAR(20),
    cidade           VARCHAR(80),
    uf               CHAR(2),
    foto_url         VARCHAR(500),
    criado_em        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_candidato_usuario UNIQUE (usuario_id),                      -- 1:1 com usuario
    CONSTRAINT uq_candidato_cpf     UNIQUE (cpf),                             -- RN01
    CONSTRAINT ck_candidato_cpf     CHECK (cpf REGEXP '^[0-9]{11}$'),
    CONSTRAINT ck_candidato_uf      CHECK (uf IS NULL OR uf REGEXP '^[A-Z]{2}$'),
    CONSTRAINT fk_candidato_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE empresa (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    nome_fantasia   VARCHAR(120) NOT NULL,
    cnpj            CHAR(14)     NOT NULL,                                    -- só dígitos
    setor           VARCHAR(80),
    descricao       TEXT,
    site            VARCHAR(255),
    logo_url        VARCHAR(500),
    cidade          VARCHAR(80),
    uf              CHAR(2),
    criado_em       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_empresa_cnpj UNIQUE (cnpj),                                 -- RN01
    CONSTRAINT ck_empresa_cnpj CHECK (cnpj REGEXP '^[0-9]{14}$'),
    CONSTRAINT ck_empresa_uf   CHECK (uf IS NULL OR uf REGEXP '^[A-Z]{2}$')
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE recrutador (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id      BIGINT UNSIGNED NOT NULL,
    empresa_id      BIGINT UNSIGNED NOT NULL,
    nome            VARCHAR(120) NOT NULL,
    cargo           VARCHAR(80),
    admin_empresa   BOOLEAN      NOT NULL DEFAULT FALSE,                      -- RN04
    criado_em       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_recrutador_usuario UNIQUE (usuario_id),                     -- 1:1 com usuario
    CONSTRAINT fk_recrutador_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id) ON DELETE CASCADE,
    CONSTRAINT fk_recrutador_empresa FOREIGN KEY (empresa_id) REFERENCES empresa (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------
--  Currículo
-- ---------------------------------------------------------------------
CREATE TABLE curriculo (
    id                     BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    candidato_id           BIGINT UNSIGNED NOT NULL,
    resumo                 TEXT,
    pretensao_salarial     DECIMAL(10,2),
    arquivo_pdf_url        VARCHAR(500),
    percentual_preenchido  TINYINT UNSIGNED NOT NULL DEFAULT 0,
    criado_em              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_curriculo_candidato  UNIQUE (candidato_id),                 -- RN06: um currículo por candidato
    CONSTRAINT ck_curriculo_percentual CHECK (percentual_preenchido BETWEEN 0 AND 100),
    CONSTRAINT ck_curriculo_pretensao  CHECK (pretensao_salarial IS NULL OR pretensao_salarial >= 0),
    CONSTRAINT fk_curriculo_candidato  FOREIGN KEY (candidato_id) REFERENCES candidato (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE formacao (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    curriculo_id   BIGINT UNSIGNED NOT NULL,
    instituicao    VARCHAR(150) NOT NULL,
    curso          VARCHAR(150) NOT NULL,
    nivel          VARCHAR(40)  NOT NULL,                                     -- ex.: Técnico, Graduação
    inicio         DATE         NOT NULL,
    fim            DATE,                                                      -- nulo = em andamento
    criado_em      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT ck_formacao_datas     CHECK (fim IS NULL OR fim >= inicio),
    CONSTRAINT fk_formacao_curriculo FOREIGN KEY (curriculo_id) REFERENCES curriculo (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE experiencia (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    curriculo_id   BIGINT UNSIGNED NOT NULL,
    empresa        VARCHAR(150) NOT NULL,
    cargo          VARCHAR(120) NOT NULL,
    descricao      TEXT,
    inicio         DATE         NOT NULL,
    fim            DATE,
    atual          BOOLEAN      NOT NULL DEFAULT FALSE,
    criado_em      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT ck_experiencia_datas CHECK (fim IS NULL OR fim >= inicio),
    CONSTRAINT ck_experiencia_atual CHECK (NOT (atual AND fim IS NOT NULL)),
    CONSTRAINT fk_experiencia_curriculo FOREIGN KEY (curriculo_id) REFERENCES curriculo (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE habilidade (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(80) NOT NULL,
    criado_em      TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_habilidade_nome UNIQUE (nome)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- N:N currículo x habilidade
CREATE TABLE curriculo_habilidade (
    curriculo_id   BIGINT UNSIGNED NOT NULL,
    habilidade_id  BIGINT UNSIGNED NOT NULL,
    nivel          ENUM('BASICO', 'INTERMEDIARIO', 'AVANCADO') NOT NULL DEFAULT 'BASICO',
    criado_em      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (curriculo_id, habilidade_id),
    INDEX ix_ch_habilidade (habilidade_id),
    CONSTRAINT fk_ch_curriculo  FOREIGN KEY (curriculo_id)  REFERENCES curriculo (id)  ON DELETE CASCADE,
    CONSTRAINT fk_ch_habilidade FOREIGN KEY (habilidade_id) REFERENCES habilidade (id) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------
--  Vagas e processo seletivo
-- ---------------------------------------------------------------------
CREATE TABLE vaga (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empresa_id      BIGINT UNSIGNED NOT NULL,
    recrutador_id   BIGINT UNSIGNED NOT NULL,
    titulo          VARCHAR(150) NOT NULL,
    descricao       TEXT         NOT NULL,
    area            VARCHAR(80)  NOT NULL,
    nivel           VARCHAR(40)  NOT NULL,                                    -- ex.: Estágio, Júnior, Pleno
    modalidade      ENUM('PRESENCIAL', 'HIBRIDO', 'REMOTO') NOT NULL,
    tipo_contrato   ENUM('CLT', 'PJ', 'ESTAGIO', 'TEMPORARIO', 'FREELANCER') NOT NULL,
    cidade          VARCHAR(80),                                              -- nulo quando remota
    uf              CHAR(2),
    salario_min     DECIMAL(10,2),
    salario_max     DECIMAL(10,2),
    status          ENUM('RASCUNHO', 'ABERTA', 'PAUSADA', 'ENCERRADA') NOT NULL DEFAULT 'RASCUNHO',
    publicada_em    TIMESTAMP    NULL,
    encerrada_em    TIMESTAMP    NULL,
    criado_em       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX ix_vaga_filtros (status, cidade, modalidade),                       -- pesquisa e filtros (RF07, RF08)
    INDEX ix_vaga_empresa (empresa_id),
    CONSTRAINT ck_vaga_salario CHECK (                                        -- RN09
        salario_min IS NULL OR salario_max IS NULL OR salario_min <= salario_max),
    CONSTRAINT ck_vaga_salario_positivo CHECK (
        (salario_min IS NULL OR salario_min >= 0) AND (salario_max IS NULL OR salario_max >= 0)),
    CONSTRAINT ck_vaga_local CHECK (modalidade = 'REMOTO' OR cidade IS NOT NULL),   -- RN07
    CONSTRAINT ck_vaga_uf    CHECK (uf IS NULL OR uf REGEXP '^[A-Z]{2}$'),
    CONSTRAINT fk_vaga_empresa    FOREIGN KEY (empresa_id)    REFERENCES empresa (id)    ON DELETE CASCADE,
    CONSTRAINT fk_vaga_recrutador FOREIGN KEY (recrutador_id) REFERENCES recrutador (id) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- N:N vaga x habilidade
CREATE TABLE vaga_habilidade (
    vaga_id        BIGINT UNSIGNED NOT NULL,
    habilidade_id  BIGINT UNSIGNED NOT NULL,
    criado_em      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (vaga_id, habilidade_id),
    INDEX ix_vh_habilidade (habilidade_id),
    CONSTRAINT fk_vh_vaga       FOREIGN KEY (vaga_id)       REFERENCES vaga (id)       ON DELETE CASCADE,
    CONSTRAINT fk_vh_habilidade FOREIGN KEY (habilidade_id) REFERENCES habilidade (id) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE etapa_vaga (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    vaga_id        BIGINT UNSIGNED NOT NULL,
    nome           VARCHAR(80)  NOT NULL,
    ordem          SMALLINT UNSIGNED NOT NULL,
    descricao      TEXT,
    criado_em      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_etapa_ordem UNIQUE (vaga_id, ordem),                        -- sem duas etapas na mesma posição
    CONSTRAINT ck_etapa_ordem CHECK (ordem >= 1),
    CONSTRAINT fk_etapa_vaga  FOREIGN KEY (vaga_id) REFERENCES vaga (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- Entidade associativa candidato x vaga
CREATE TABLE candidatura (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    candidato_id        BIGINT UNSIGNED NOT NULL,
    vaga_id             BIGINT UNSIGNED NOT NULL,
    etapa_atual_id      BIGINT UNSIGNED NOT NULL,
    status              ENUM('EM_ANDAMENTO', 'APROVADO_ETAPA', 'CONTRATADO', 'REPROVADO', 'DESISTIU')
                        NOT NULL DEFAULT 'EM_ANDAMENTO',                      -- RN11
    carta_apresentacao  TEXT,
    curriculo_snapshot  JSON         NOT NULL,                                -- RN06: cópia do currículo no envio
    criado_em           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_candidatura_candidato_vaga UNIQUE (candidato_id, vaga_id),  -- RN10
    INDEX ix_candidatura_vaga_status (vaga_id, status),                       -- quadro do processo e relatórios
    INDEX ix_candidatura_etapa (etapa_atual_id),
    CONSTRAINT fk_candidatura_candidato FOREIGN KEY (candidato_id)   REFERENCES candidato (id)  ON DELETE CASCADE,
    CONSTRAINT fk_candidatura_vaga      FOREIGN KEY (vaga_id)        REFERENCES vaga (id)       ON DELETE CASCADE,
    CONSTRAINT fk_candidatura_etapa     FOREIGN KEY (etapa_atual_id) REFERENCES etapa_vaga (id) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE historico_candidatura (
    id                 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    candidatura_id     BIGINT UNSIGNED NOT NULL,
    etapa_id           BIGINT UNSIGNED NOT NULL,
    autor_usuario_id   BIGINT UNSIGNED,                                       -- nulo se o autor apagou a conta
    status             ENUM('EM_ANDAMENTO', 'APROVADO_ETAPA', 'CONTRATADO', 'REPROVADO', 'DESISTIU') NOT NULL,
    feedback           TEXT,
    motivo_reprovacao  VARCHAR(120),
    criado_em          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX ix_historico_candidatura (candidatura_id, criado_em),               -- linha do tempo (RF10)
    CONSTRAINT ck_historico_motivo CHECK (                                    -- RN13: reprovação exige motivo
        status <> 'REPROVADO' OR motivo_reprovacao IS NOT NULL),
    CONSTRAINT fk_historico_candidatura FOREIGN KEY (candidatura_id)   REFERENCES candidatura (id) ON DELETE CASCADE,
    CONSTRAINT fk_historico_etapa       FOREIGN KEY (etapa_id)         REFERENCES etapa_vaga (id)  ON DELETE RESTRICT,
    CONSTRAINT fk_historico_autor       FOREIGN KEY (autor_usuario_id) REFERENCES usuario (id)     ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------
--  Apoio: favoritos, notificações e histórico de visualização
-- ---------------------------------------------------------------------
-- referencia_id aponta para vaga.id ou candidato.id, conforme o tipo.
-- Por apontar para duas tabelas, não tem FK no banco; o backend valida.
CREATE TABLE favorito (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id     BIGINT UNSIGNED NOT NULL,
    tipo           ENUM('VAGA', 'CANDIDATO') NOT NULL,
    referencia_id  BIGINT UNSIGNED NOT NULL,
    criado_em      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_favorito UNIQUE (usuario_id, tipo, referencia_id),
    CONSTRAINT fk_favorito_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE notificacao (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id     BIGINT UNSIGNED NOT NULL,
    titulo         VARCHAR(150) NOT NULL,
    mensagem       TEXT         NOT NULL,
    lida           BOOLEAN      NOT NULL DEFAULT FALSE,
    link           VARCHAR(500),
    criado_em      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX ix_notificacao_usuario (usuario_id, lida),
    CONSTRAINT fk_notificacao_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE visualizacao_vaga (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id      BIGINT UNSIGNED NOT NULL,
    vaga_id         BIGINT UNSIGNED NOT NULL,
    visualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX ix_visualizacao_usuario (usuario_id, visualizado_em),
    CONSTRAINT fk_visualizacao_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id) ON DELETE CASCADE,
    CONSTRAINT fk_visualizacao_vaga    FOREIGN KEY (vaga_id)    REFERENCES vaga (id)    ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
