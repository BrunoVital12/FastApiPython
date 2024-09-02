# Hello World com FastAPI

Este é um projeto básico de "Hello World" usando o FastAPI em Python. O gerenciamento de dependências é feito com Poetry e o ambiente é configurado com pipx.
GitHub Actions configurado para passar pelos testes do Trivy e SonarCloud, passado dos testes o container é lançado no DockerHub. 

## Requisitos

Antes de começar, certifique-se de ter os seguintes softwares instalados:

- Python 3.12+
- pipx
- Docker
- Rancher Desktop (opcional, mas recomendado para trabalhar com Kubernetes)


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


5. **Baixar Rancher Desktop (Um aplicativo de código aberto que fornece todos os elementos essenciais para trabalhar com contêineres e Kubernetes no desktop.)**: Link para download: https://rancherdesktop.io

6. **Crie um arquivo Dockerfile**: Dentro da mesma pasta que o seu projeto, com o seguinte conteúdo:

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


7. **Construir e Executar o Container**: Para construir e rodar o container Docker:

    ```bash
    docker build -t my-fastapi-app .
    docker run -p 8000:8000 my-fastapi-app
    ```


8. **Acesse a Aplicação**: Uma vez que o container estiver rodando, você pode acessar a aplicação no navegador:

    ```
    http://localhost:8000
    ```

9. **Criar um novo folder dentro do seu projeto com o seguinte nome: ***".github\workflows"***.**: dentro dele criar um arquivo .yml com o seguinte conteúdo: 
```name: SonarCloud, Trivy Scan, Docker Build and Push 

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]
jobs:
  sonarcloud:
    name: SonarCloud
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # Needed to get PR information, if any
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
            args: > 
                -Dsonar.projectKey=BrunoVital12_FastApiPython 
                -Dsonar.organization=brunovital12 

  trivy-scan:
    runs-on: ubuntu-latest
    needs: sonarcloud  # Run this job after the SonarCloud job
    steps:
    - name: Check out the repository
      uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Login to DockerHub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build Docker image
      run: docker build -t my-fastapi-app .

    - name: Run Trivy vulnerability scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: my-fastapi-app
        format: 'table'
        exit-code: '1'
        ignore-unfixed: true

    - name: Save Docker image as artifact
      run: |
        docker save my-fastapi-app:latest | gzip > my-fastapi-app.tar.gz
        mkdir -p /tmp/artifacts
        mv my-fastapi-app.tar.gz /tmp/artifacts/

    - name: Upload Docker image artifact
      uses: actions/upload-artifact@v3
      with:
        name: docker-image
        path: /tmp/artifacts/my-fastapi-app.tar.gz

  build-and-push:
    runs-on: ubuntu-latest
    needs: trivy-scan
    if: success()
    steps:
    - name: Check out the repository
      uses: actions/checkout@v3

    - name: Download Docker image artifact
      uses: actions/download-artifact@v3
      with:
        name: docker-image

    - name: Load Docker image
      run: gunzip -c my-fastapi-app.tar.gz | docker load

    - name: List Docker images after load
      run: docker images

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Login to DockerHub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Tag Docker image
      run: |
        docker tag my-fastapi-app:latest ${{ secrets.DOCKER_USERNAME }}/my-fastapi-app:latest

    - name: Push Docker image to Docker Hub
      run: |
        docker push ${{ secrets.DOCKER_USERNAME }}/my-fastapi-app:latest
```

Esse código realizará uma verificação com o SonarCloud e o Trivy, caso passe nos testes, é subido o container no DockerHub (É necessário ter conta, e configurado os secrets no github.)

