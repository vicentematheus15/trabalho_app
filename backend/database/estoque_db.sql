CREATE TABLE usuario(  
    id_usuario int NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key',
    email VARCHAR(100) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    nivel_acesso ENUM('admin', 'vendedor') NOT NULL
);
CREATE TABLE fornecedor(
    id_fornecedor int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nome_fornecedor VARCHAR(100) NOT NULL,
    cnpj CHAR(14),
    email VARCHAR(50) NOT NULL
);
CREATE TABLE produto(
    id_produto int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    categoria ENUM('Celular', 'Computador', 'Segurança', 'Outro') NOT NULL,
    preco NUMERIC(10, 2),
    id_fornecedor INT,
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor)
);
CREATE TABLE estoque(
    id_estoque int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nome_estoque VARCHAR(100) NOT NULL,
    localizacao VARCHAR(100) NOT NULL
);
CREATE TABLE produto_estoque(
    id_produto_estoque int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_estoque INT NOT NULL,
    id_produto INT NOT NULL,
    FOREIGN KEY (id_estoque) REFERENCES estoque(id_estoque),
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
    qtd_atual int NOT NULL,
    qtd_reservada int NOT NULL,
    data_ultima_atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE movimentacao_estoque(
    id_movimentacao int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    data_movimentacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo_movimentacao ENUM('Entrada', 'Saída') NOT NULL,
    descricao VARCHAR(100),
    quantidade INT NOT NULL,
    id_produto_estoque INT NOT NULL,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_produto_estoque) REFERENCES produto_estoque(id_produto_estoque),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);
