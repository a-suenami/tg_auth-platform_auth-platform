# ==============================================================================
# docker - dynamodb - Dockerfile
# ==============================================================================
FROM amazon/dynamodb-local

RUN mkdir -p /home/dynamodblocal/data && \
  chown dynamodblocal /home/dynamodblocal/data -R && \
  chmod 775 -R /home/dynamodblocal/data

ENTRYPOINT ["java"]
CMD ["-jar", "DynamoDBLocal.jar", "-dbPath", "/home/dynamodblocal/data"]
