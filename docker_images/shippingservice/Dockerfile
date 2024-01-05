FROM python:3.9-slim
WORKDIR /app
COPY shippingservice.py .
RUN pip3 install Flask
EXPOSE 5003
CMD ["python3", "shippingservice.py"]
