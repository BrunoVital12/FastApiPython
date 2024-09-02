# Hello World com FastAPI

Este é um projeto básico de "Hello World" usando o FastAPI em Python. O gerenciamento de dependências é feito com Poetry e o ambiente é configurado com pipx.
GitHub Actions configurado para passar pelos testes do Trivy e SonarCloud, passado dos testes o container é lançado no DockerHub. 

## Instalação e Execução

1. **Instale o pipx**: Se você ainda não tem o `pipx` instalado, use o seguinte comando:
    ```bash
    python -m pip install --user pipx
    python -m pipx ensurepath
    ```

2. **Instale o Poetry**: Use o `pipx` para instalar o Poetry:
    ```bash
    pipx install poetry
    ```

3. **Crie o Projeto**: Crie um novo projeto com o Poetry:
    ```bash
    poetry new hello-fastapi
    cd hello-fastapi
    ```


4. **Crie o Arquivo Principal**: Navegue até o diretório `hello_fastapi` e crie um arquivo `app.py` com o seguinte conteúdo:
    ```python
    from fastapi import FastAPI

    app = FastAPI()

    @app.get("/")
    def read_root():
        return {"Hello": "World"}
    ```

5. **Crie um arquivo Dockerfile**: Com o seguinte conteúdo dentro do Dockerfile:
![alt text](image.png)
```FROM python:3.12-alpine

WORKDIR /app

RUN apk add --no-cache build-base

COPY pyproject.toml poetry.lock /app/


RUN pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --no-root --only main \
    && apk del build-base  # Remover pacotes de build após a instalação


COPY projeto_compass /app/projeto_compass


EXPOSE 8000

CMD ["uvicorn", "projeto_compass.app:app", "--host", "0.0.0.0", "--port", "8000"]
```


