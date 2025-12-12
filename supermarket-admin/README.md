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
