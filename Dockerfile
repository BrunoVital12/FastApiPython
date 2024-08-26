FROM python:3.12-alpine

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
