FROM ubuntu:latest

RUN apt-get update -y 
RUN apt-get install -y python3 python3-pip

COPY . /app

ENV DB_ADDR=localhost
ENV DB_PORT=5001
ENV DB_USER=mongo
ENV DB_PW=mongo
ENV DB_NAME=bbthe90s
ENV COL_NAME=products

WORKDIR /app
RUN pip3 install flask pymongo

ENTRYPOINT ["python3"]
CMD ["product.py"]