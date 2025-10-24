# build stage
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --prefix=/install -r requirements.txt

# final
FROM python:3.11-slim
ENV PATH=/install/bin:$PATH
WORKDIR /app
COPY --from=builder /install /install
COPY . /app
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app", "--workers", "2"]
