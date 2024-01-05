FROM python:3.9-slim
WORKDIR /app
COPY accountservice.py .
RUN pip install Flask
EXPOSE 5001
CMD ["python", "accountservice.py"]
