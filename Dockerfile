FROM heroku/heroku:18-build

RUN mkdir -p /app
WORKDIR /app

COPY . .

RUN .heroku/run.sh

ENV PATH="/app/bin:$PATH"

ENV LD_LIBRARY_PATH="/app/lib:$LD_LIBRARY_PATH"

CMD ["/app/bin/proot", "-S", "/app/.root-fs", "-b", "/app:/app", "-w", "/app", "R", "--no-save"]
