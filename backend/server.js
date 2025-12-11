// server.js - Backend Express para administração de supermercado
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Configuração do banco de dados
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'supermercado_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool;

// Inicializar pool de conexões
async function initDB() {
  try {
    pool = mysql.createPool(dbConfig);
    console.log('✓ Conectado ao banco de dados MySQL');
  } catch (error) {
    console.error('Erro ao conectar ao banco de dados:', error);
    process.exit(1);
  }
}

// ==================== ROTAS DE PRODUTOS ====================

// Listar todos os produtos
app.get('/api/produtos', async (req, res) => {
  try {
    const [produtos] = await pool.query(`
      SELECT 
        p.*,
        c.nome AS categoria_nome,
        f.nome AS fornecedor_nome
      FROM produtos p
      LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
      LEFT JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor
      WHERE p.ativo = TRUE
      ORDER BY p.nome
    `);
    res.json(produtos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Buscar produto por ID
app.get('/api/produtos/:id', async (req, res) => {
  try {
    const [produtos] = await pool.query(`
      SELECT 
        p.*,
        c.nome AS categoria_nome,
        f.nome AS fornecedor_nome
      FROM produtos p
      LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
      LEFT JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor
      WHERE p.id_produto = ? AND p.ativo = TRUE
    `, [req.params.id]);
    
    if (produtos.length === 0) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    res.json(produtos[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Criar novo produto
app.post('/api/produtos', async (req, res) => {
  try {
    const {
      codigo_barras, nome, descricao, id_categoria, id_fornecedor,
      preco_compra, preco_venda, estoque_atual, estoque_minimo,
      estoque_maximo, unidade_medida, data_validade
    } = req.body;

    const [result] = await pool.query(`
      INSERT INTO produtos (
        codigo_barras, nome, descricao, id_categoria, id_fornecedor,
        preco_compra, preco_venda, estoque_atual, estoque_minimo,
        estoque_maximo, unidade_medida, data_validade
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      codigo_barras, nome, descricao, id_categoria, id_fornecedor,
      preco_compra, preco_venda, estoque_atual, estoque_minimo,
      estoque_maximo, unidade_medida, data_validade
    ]);

    res.status(201).json({
      id: result.insertId,
      message: 'Produto criado com sucesso'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Atualizar produto
app.put('/api/produtos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    
    const fields = Object.keys(updates)
      .map(key => `${key} = ?`)
      .join(', ');
    const values = [...Object.values(updates), id];

    const [result] = await pool.query(`
      UPDATE produtos SET ${fields} WHERE id_produto = ?
    `, values);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }

    res.json({ message: 'Produto atualizado com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Deletar produto (soft delete)
app.delete('/api/produtos/:id', async (req, res) => {
  try {
    const [result] = await pool.query(
      'UPDATE produtos SET ativo = FALSE WHERE id_produto = ?',
      [req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }

    res.json({ message: 'Produto deletado com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Produtos com estoque baixo
app.get('/api/produtos/estoque/baixo', async (req, res) => {
  try {
    const [produtos] = await pool.query('SELECT * FROM visao_produtos_estoque_baixo');
    res.json(produtos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== ROTAS DE CATEGORIAS ====================

app.get('/api/categorias', async (req, res) => {
  try {
    const [categorias] = await pool.query(
      'SELECT * FROM categorias WHERE ativo = TRUE ORDER BY nome'
    );
    res.json(categorias);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/categorias', async (req, res) => {
  try {
    const { nome, descricao } = req.body;
    const [result] = await pool.query(
      'INSERT INTO categorias (nome, descricao) VALUES (?, ?)',
      [nome, descricao]
    );
    res.status(201).json({ id: result.insertId, message: 'Categoria criada' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== ROTAS DE FORNECEDORES ====================

app.get('/api/fornecedores', async (req, res) => {
  try {
    const [fornecedores] = await pool.query(
      'SELECT * FROM fornecedores WHERE ativo = TRUE ORDER BY nome'
    );
    res.json(fornecedores);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/fornecedores', async (req, res) => {
  try {
    const {
      nome, razao_social, cnpj, telefone, email,
      endereco, cidade, cep
    } = req.body;

    const [result] = await pool.query(`
      INSERT INTO fornecedores (
        nome, razao_social, cnpj, telefone, email, endereco, cidade, cep
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `, [nome, razao_social, cnpj, telefone, email, endereco, cidade, cep]);

    res.status(201).json({ id: result.insertId, message: 'Fornecedor criado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== ROTAS DE MOVIMENTOS ====================

// Registrar movimento de estoque
app.post('/api/movimentos', async (req, res) => {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    const {
      id_produto, id_deposito, tipo_movimento,
      quantidade, motivo, referencia, usuario
    } = req.body;

    // Buscar estoque atual
    const [produtos] = await connection.query(
      'SELECT estoque_atual FROM produtos WHERE id_produto = ?',
      [id_produto]
    );

    if (produtos.length === 0) {
      throw new Error('Produto não encontrado');
    }

    const estoque_anterior = produtos[0].estoque_atual;
    let estoque_novo = estoque_anterior;

    // Calcular novo estoque
    if (tipo_movimento === 'entrada') {
      estoque_novo += quantidade;
    } else if (tipo_movimento === 'saida') {
      estoque_novo -= quantidade;
      if (estoque_novo < 0) {
        throw new Error('Estoque insuficiente');
      }
    } else if (tipo_movimento === 'ajuste') {
      estoque_novo = quantidade;
    }

    // Registrar movimento
    await connection.query(`
      INSERT INTO movimentos_estoque (
        id_produto, id_deposito, tipo_movimento, quantidade,
        estoque_anterior, estoque_novo, motivo, referencia, usuario
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      id_produto, id_deposito, tipo_movimento, quantidade,
      estoque_anterior, estoque_novo, motivo, referencia, usuario
    ]);

    // Atualizar estoque do produto
    await connection.query(
      'UPDATE produtos SET estoque_atual = ? WHERE id_produto = ?',
      [estoque_novo, id_produto]
    );

    // Verificar alertas
    const [produto] = await connection.query(
      'SELECT estoque_minimo FROM produtos WHERE id_produto = ?',
      [id_produto]
    );

    if (estoque_novo <= produto[0].estoque_minimo) {
      await connection.query(`
        INSERT INTO alertas_estoque (id_produto, tipo_alerta, mensagem)
        VALUES (?, 'estoque_baixo', 'Estoque abaixo do mínimo')
      `, [id_produto]);
    }

    await connection.commit();
    res.json({ message: 'Movimento registrado com sucesso', estoque_novo });

  } catch (error) {
    await connection.rollback();
    res.status(500).json({ error: error.message });
  } finally {
    connection.release();
  }
});

// Listar movimentos
app.get('/api/movimentos', async (req, res) => {
  try {
    const [movimentos] = await pool.query(`
      SELECT 
        m.*,
        p.nome AS produto_nome,
        d.nome AS deposito_nome
      FROM movimentos_estoque m
      JOIN produtos p ON m.id_produto = p.id_produto
      JOIN depositos d ON m.id_deposito = d.id_deposito
      ORDER BY m.data_movimento DESC
      LIMIT 100
    `);
    res.json(movimentos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== ROTAS DE DEPÓSITOS ====================

app.get('/api/depositos', async (req, res) => {
  try {
    const [depositos] = await pool.query(
      'SELECT * FROM depositos WHERE ativo = TRUE'
    );
    res.json(depositos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== ROTAS DE ALERTAS ====================

app.get('/api/alertas', async (req, res) => {
  try {
    const [alertas] = await pool.query(`
      SELECT 
        a.*,
        p.nome AS produto_nome,
        p.codigo_barras
      FROM alertas_estoque a
      JOIN produtos p ON a.id_produto = p.id_produto
      WHERE a.resolvido = FALSE
      ORDER BY a.data_alerta DESC
    `);
    res.json(alertas);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Resolver alerta
app.put('/api/alertas/:id/resolver', async (req, res) => {
  try {
    await pool.query(`
      UPDATE alertas_estoque 
      SET resolvido = TRUE, data_resolucao = NOW()
      WHERE id_alerta = ?
    `, [req.params.id]);
    
    res.json({ message: 'Alerta resolvido' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== DASHBOARD ====================

app.get('/api/dashboard/stats', async (req, res) => {
  try {
    const [totalProdutos] = await pool.query(
      'SELECT COUNT(*) as total FROM produtos WHERE ativo = TRUE'
    );
    
    const [totalAlertas] = await pool.query(
      'SELECT COUNT(*) as total FROM alertas_estoque WHERE resolvido = FALSE'
    );
    
    const [valorEstoque] = await pool.query(
      'SELECT SUM(preco_venda * estoque_atual) as total FROM produtos WHERE ativo = TRUE'
    );
    
    const [totalFornecedores] = await pool.query(
      'SELECT COUNT(*) as total FROM fornecedores WHERE ativo = TRUE'
    );

    res.json({
      totalProdutos: totalProdutos[0].total,
      totalAlertas: totalAlertas[0].total,
      valorEstoque: valorEstoque[0].total || 0,
      totalFornecedores: totalFornecedores[0].total
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== INICIALIZAÇÃO ====================

app.get('/', (req, res) => {
  res.json({ 
    message: 'API de Administração de Supermercado',
    version: '1.0.0',
    endpoints: {
      produtos: '/api/produtos',
      categorias: '/api/categorias',
      fornecedores: '/api/fornecedores',
      movimentos: '/api/movimentos',
      depositos: '/api/depositos',
      alertas: '/api/alertas',
      dashboard: '/api/dashboard/stats'
    }
  });
});

// Iniciar servidor
initDB().then(() => {
  app.listen(PORT, () => {
    console.log(`✓ Servidor rodando na porta ${PORT}`);
    console.log(`✓ API disponível em http://localhost:${PORT}`);
  });
}).catch(error => {
  console.error('Erro ao iniciar servidor:', error);
  process.exit(1);
});

module.exports = app;