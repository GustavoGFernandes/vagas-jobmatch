# Banco MySQL do JobMatch. Os arquivos de init/ rodam em ordem (01, 02...) na primeira vez que o container sobe.
FROM mysql:8.4
COPY init/ /docker-entrypoint-initdb.d/
