FROM aquasec/trivy:0.29.2

COPY pipe /

RUN apk --no-cache add bash

RUN chmod +x /pipe.sh

ENTRYPOINT ["/pipe.sh"]
