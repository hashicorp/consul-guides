FROM python:3
WORKDIR /tmp
ADD clientms.py .
ADD config.yml .
RUN pip install pyyaml redis Flask dnspython
ENV FLASK_APP /tmp/clientms.py
EXPOSE 5000
CMD [ "python", "-m", "flask", "run", "--host=0.0.0.0" ]
