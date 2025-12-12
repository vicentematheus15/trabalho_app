-- Tabela de Categorias
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Fornecedores
CREATE TABLE fornecedores (
    id_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    razao_social VARCHAR(200),
    cnpj VARCHAR(20),
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco TEXT,
    cidade VARCHAR(100),
    cep VARCHAR(10),
    ativo BOOLEAN DEFAULT TRUE,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Produtos
CREATE TABLE produtos (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    codigo_barras VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    id_categoria INT,
    id_fornecedor INT,
    preco_compra DECIMAL(10,2) NOT NULL,
    preco_venda DECIMAL(10,2) NOT NULL,
    estoque_atual INT DEFAULT 0,
    estoque_minimo INT DEFAULT 10,
    estoque_maximo INT DEFAULT 100,
    unidade_medida VARCHAR(20) DEFAULT 'unidade',
    data_validade DATE,
    imagem_url VARCHAR(255),
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor)
);

-- Tabela de Depósitos/Localizações
CREATE TABLE depositos (
    id_deposito INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    localizacao VARCHAR(200),
    capacidade_maxima INT,
    responsavel VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Estoque por Depósito
CREATE TABLE estoque_deposito (
    id_estoque INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL,
    id_deposito INT NOT NULL,
    quantidade INT DEFAULT 0,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    FOREIGN KEY (id_deposito) REFERENCES depositos(id_deposito),
    UNIQUE KEY (id_produto, id_deposito)
);

-- Tabela de Movimentos de Estoque
CREATE TABLE movimentos_estoque (
    id_movimento INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL,
    id_deposito INT NOT NULL,
    tipo_movimento ENUM('entrada', 'saida', 'ajuste', 'transferencia', 'devolucao') NOT NULL,
    quantidade INT NOT NULL,
    estoque_anterior INT NOT NULL,
    estoque_novo INT NOT NULL,
    motivo VARCHAR(255),
    referencia VARCHAR(100),
    usuario VARCHAR(100),
    data_movimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    FOREIGN KEY (id_deposito) REFERENCES depositos(id_deposito)
);

-- Tabela de Ordens de Compra
CREATE TABLE ordens_compra (
    id_ordem INT PRIMARY KEY AUTO_INCREMENT,
    id_fornecedor INT NOT NULL,
    numero_ordem VARCHAR(50) UNIQUE NOT NULL,
    data_ordem DATE NOT NULL,
    data_entrega_prevista DATE,
    data_entrega_real DATE,
    total DECIMAL(12,2) DEFAULT 0,
    status ENUM('pendente', 'aprovada', 'recebida', 'cancelada') DEFAULT 'pendente',
    observacoes TEXT,
    usuario_criou VARCHAR(100),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor)
);

-- Tabela de Detalhes das Ordens de Compra
CREATE TABLE detalhes_ordem_compra (
    id_detalhe INT PRIMARY KEY AUTO_INCREMENT,
    id_ordem INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    quantidade_recebida INT DEFAULT 0,
    FOREIGN KEY (id_ordem) REFERENCES ordens_compra(id_ordem) ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- Tabela de Alertas de Estoque
CREATE TABLE alertas_estoque (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL,
    tipo_alerta ENUM('estoque_baixo', 'estoque_critico', 'proximo_vencer', 'vencido', 'excesso_estoque') NOT NULL,
    mensagem TEXT,
    data_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolvido BOOLEAN DEFAULT FALSE,
    data_resolucao TIMESTAMP NULL,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- Índices para otimizar consultas
CREATE INDEX idx_produtos_categoria ON produtos(id_categoria);
CREATE INDEX idx_produtos_fornecedor ON produtos(id_fornecedor);
CREATE INDEX idx_produtos_codigo ON produtos(codigo_barras);
CREATE INDEX idx_movimentos_data ON movimentos_estoque(data_movimento);
CREATE INDEX idx_movimentos_produto ON movimentos_estoque(id_produto);
CREATE INDEX idx_ordens_data ON ordens_compra(data_ordem);
CREATE INDEX idx_alertas_resolvido ON alertas_estoque(resolvido);

-- Visão para produtos com estoque baixo
CREATE VIEW visao_produtos_estoque_baixo AS
SELECT 
    p.id_produto,
    p.codigo_barras,
    p.nome,
    c.nome AS categoria,
    p.estoque_atual,
    p.estoque_minimo,
    f.nome AS fornecedor
FROM produtos p
LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
LEFT JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor
WHERE p.estoque_atual <= p.estoque_minimo AND p.ativo = TRUE;

-- Visão para produtos próximos ao vencimento
CREATE VIEW visao_produtos_proximos_vencer AS
SELECT 
    p.id_produto,
    p.codigo_barras,
    p.nome,
    p.estoque_atual,
    p.data_validade,
    DATEDIFF(p.data_validade, CURDATE()) AS dias_restantes
FROM produtos p
WHERE p.data_validade IS NOT NULL 
    AND p.data_validade <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
    AND p.ativo = TRUE
ORDER BY p.data_validade;
