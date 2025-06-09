# Projeto: mlserver-iris

## Objetivo

Configurar o MLServer para servir um modelo de Machine Learning (classificador da base Iris), utilizando Docker, de forma que o projeto possa ser clonado e executado com um único comando.

---

## Etapas do Projeto

### 1. Criar Estrutura do Projeto

A estrutura de diretórios e arquivos do projeto deve ser a seguinte:

```bash
mlserver-iris/
├── models/
│   └── iris/
│       ├── model.joblib
│       └── model-settings.json
├── requirements.txt
├── Dockerfile
└── README.md
```

### 2. Treinar e Salvar o Modelo

Crie um script Python (por exemplo, `train.py`) para treinar um classificador `RandomForestClassifier` com a base de dados Iris e salvar o modelo treinado usando `joblib`.

```python
# train.py
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from joblib import dump

# Carrega os dados
X, y = load_iris(return_X_y=True)

# Cria e treina o modelo
model = RandomForestClassifier()
model.fit(X, y)

# Salva o modelo no diretório de modelos
dump(model, "models/iris/model.joblib")
```

Execute o script para gerar o arquivo `model.joblib`.

### 3. Criar o Arquivo `model-settings.json`

Este arquivo de configuração informa ao MLServer qual implementação utilizar para carregar o modelo.

```json
{
  "name": "iris",
  "implementation": "mlserver_sklearn.SKLearnModel"
}
```

### 4. Criar o `requirements.txt`

Liste todas as dependências Python necessárias para o projeto.

```txt
mlserver
mlserver-sklearn
scikit-learn==1.7.0 
joblib
```
*(Nota: a versão do scikit-learn pode ser ajustada conforme necessário)*

### 5. Criar o `Dockerfile`

O Dockerfile define o ambiente para a nossa aplicação, instalando as dependências e definindo o comando para iniciar o servidor.

```Dockerfile
FROM python:3.10-slim

WORKDIR /app

# Copia e instala as dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia os modelos para o container
COPY models/ models/

# Expõe as portas e inicia o servidor
CMD ["mlserver", "start", "models"]
```

### 6. Construir a Imagem Docker

No terminal, na raiz do projeto, execute o comando a seguir para construir a imagem Docker.

```bash
docker build -t mlserver-iris .
```

### 7. Rodar o Container

Após a construção da imagem, inicie o container. Isso irá expor as portas para a API do MLServer.

```bash
docker run -p 8080:8080 -p 8081:8081 mlserver-iris
```

Você deverá ver uma saída no log confirmando que o modelo foi carregado com sucesso:
```
INFO - Loaded model 'iris' successfully.
```

### 8. Testar o Modelo

Com o container em execução, abra outro terminal para enviar uma requisição de inferência para o modelo usando `curl`.

```bash
curl -X POST http://localhost:8080/v2/models/iris/infer \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": [
      {
        "name": "input-0",
        "shape": [1, 4],
        "datatype": "FP32",
        "data": [5.1, 3.5, 1.4, 0.2]
      }
    ]
  }'
```

A resposta esperada será um JSON com a predição do modelo:

```json
{
  "model_name": "iris",
  "outputs": [
    {
      "name": "output-0",
      "shape": [1],
      "datatype": "INT64",
      "data": [0]
    }
  ]
}
```

### 9. Validar Endpoints no Navegador

Você pode verificar o status e a saúde do servidor acessando os seguintes endpoints no seu navegador:

-   **Verificar saúde:** [http://localhost:8080/v2/health/live](http://localhost:8080/v2/health/live)
-   **Listar modelos carregados:** [http://localhost:8080/v2/models](http://localhost:8080/v2/models)
-   **Verificar status do modelo iris:** [http://localhost:8080/v2/models/iris](http://localhost:8080/v2/models/iris)

---
