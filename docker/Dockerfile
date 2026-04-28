FROM apache/kafka:4.2.0

ENV PATH=$PATH:/opt/kafka/bin

COPY --chmod=755 ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]