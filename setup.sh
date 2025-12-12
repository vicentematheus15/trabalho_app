#!/bin/bash

# Script de instalação automática do Sistema de Supermercado
# Execute: bash setup.sh

echo "🚀 Iniciando instalação do Sistema de Administração de Supermercado..."
echo ""

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar Node.js
echo "📦 Verificando Node.js..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js não encontrado. Instale em: https://nodejs.org${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js $(node -v) encontrado${NC}"

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm não encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npm $(npm -v) encontrado${NC}"

# Verificar MySQL
echo ""
echo "🗄️  Verificando MySQL..."
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL não encontrado. Instale em: https://dev.mysql.com/downloads/mysql/${NC}"
    exit 1
fi
echo -e "${GREEN}✅ MySQL encontrado${NC}"

# Criar estrutura de pastas
echo ""
echo "📁 Criando estrutura de pastas..."
mkdir -p supermarket-admin/backend/database
mkdir -p supermarket-admin/frontend
cd supermarket-admin

echo -e "${GREEN}✅ Estrutura criada${NC}"

# Criar package.json
echo ""
echo "📝 Criando package.json..."
cat > backend/package.json << 'EOF'
{
  "name": "supermarket-admin-backend",
  "version": "1.0.0",
  "description": "API REST para administração de inventário de supermercado",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.5",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
EOF

echo -e "${GREEN}✅ package.json criado${NC}"

# Criar .env.example
echo ""
echo "🔐 Criando arquivo .env.example..."
cat > backend/.env.example << 'EOF'
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=sua_senha_aqui
DB_NAME=supermercado_db
PORT=3000
NODE_ENV=development
EOF

echo -e "${GREEN}✅ .env.example criado${NC}"

# Criar README
echo ""
echo "📖 Criando README.md..."
cat > README.md << 'EOF'
# Sistema de Administração de Supermercado

## 🚀 Início Rápido

1. Configure o arquivo `.env`:
   ```bash
   cd backend
   cp .env.example .env
   # Edite o arquivo .env com suas credenciais do MySQL
   ```

2. Instale as dependências:
   ```bash
   npm install
   ```

3. Configure o banco de dados:
   ```bash
   mysql -u root -p < database/supermarket_db.sql
   ```

4. Inicie o servidor:
   ```bash
   npm run dev
   ```

5. Acesse a API: http://localhost:3000

## 📚 Documentação Completa

Veja o guia completo no arquivo INSTALL.md

## 🔗 Endpoints

- GET /api/produtos - Listar produtos
- POST /api/produtos - Criar produto
- GET /api/categorias - Listar categorias
- GET /api/fornecedores - Listar fornecedores
- POST /api/movimentos - Registrar movimento
- GET /api/alertas - Ver alertas
- GET /api/dashboard/stats - Estatísticas

## 📞 Suporte

Para questões, abra uma issue no repositório.
EOF

echo -e "${GREEN}✅ README.md criado${NC}"

# Instalar dependências
echo ""
echo "📦 Instalando dependências do backend..."
cd backend
npm install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependências instaladas com sucesso${NC}"
else
    echo -e "${RED}❌ Erro ao instalar dependências${NC}"
    exit 1
fi

cd ..

# Instruções finais
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}📋 PRÓXIMOS PASSOS:${NC}"
echo ""
echo "1. Copie o arquivo SQL para a pasta database:"
echo "   cp /caminho/do/supermarket_db.sql backend/database/"
echo ""
echo "2. Copie o arquivo server.js para a pasta backend:"
echo "   cp /caminho/do/server.js backend/"
echo ""
echo "3. Configure o arquivo .env:"
echo "   cd backend"
echo "   cp .env.example .env"
echo "   nano .env  # Edite com suas credenciais"
echo ""
echo "4. Importe o banco de dados:"
echo "   mysql -u root -p < backend/database/supermarket_db.sql"
echo ""
echo "5. Inicie o servidor:"
echo "   cd backend"
echo "   npm run dev"
echo ""
echo "6. Acesse: http://localhost:3000"
echo ""
echo -e "${BLUE}📂 Estrutura criada em: $(pwd)${NC}"
echo ""
echo -e "${GREEN}Bom desenvolvimento! 🎉${NC}"