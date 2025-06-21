json.extract! produto, :id, :nome, :preco, :categoria, :created_at, :updated_at
json.url produto_url(produto, format: :json)
