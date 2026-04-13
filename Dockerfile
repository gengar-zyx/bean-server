FROM python:slim AS builder

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bison \
        build-essential \
        flex \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --root-user-action ignore --prefix="/install" \
    fava \
    fava-dashboards \
    beanprice \
    beancount-periodic \
    fava-portfolio-returns

FROM python:slim

COPY --from=builder /install /usr/local
COPY start-fava.sh /usr/local/bin/start-fava

RUN chmod +x /usr/local/bin/start-fava

ENV FAVA_HOST=0.0.0.0
EXPOSE 5000
CMD ["start-fava"]
