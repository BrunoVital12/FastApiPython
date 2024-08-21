# Hello World com FastAPI

Este é um projeto básico de "Hello World" usando o FastAPI em Python. O gerenciamento de dependências é feito com Poetry e o ambiente é configurado com pipx.

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

5. **Execute o Projeto**: Ative o ambiente virtual:
    ```
    poetry shell
    ```

    Inicie a aplicação
      ```
    fastapi dev x/app.py

    ```

7. **Acesse a Aplicação**: Abra o navegador e acesse:
    ```
    http://127.0.0.1:8000
    ```
    Você verá uma resposta JSON com `{"Hello": "World"}`.
   


