FROM aquasec/trivy:0.20.2

COPY pipe /

RUN apk --no-cache add bash

RUN chmod +x /pipe.sh

ENTRYPOINT ["/pipe.sh"]