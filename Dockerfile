#FROM rasa/rasa:latest-full
FROM land007/ubuntu-unity-novnc:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        build-essential \
        ca-certificates \
        curl \
        git \
        libbz2-dev \
        libffi-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        #libssl1.0-dev \
        libssl1.0 \
        liblzma-dev \
        libssl-dev \
        llvm \
        make \
        netbase \
        pkg-config \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev \
        zlibc \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN pyenv install 3.7.9 && pyenv global 3.7.9 && pyenv rehash
RUN pip install poetry
RUN cd / && git clone https://github.com/land007/mcd-order-bot.git
RUN cd /mcd-order-bot && poetry install
RUN cd /mcd-order-bot && poetry run playwright install
#RUN pip install playwright && python -m playwright install
RUN sed -i 's/tokenizer_url:\ http:\/\/localhost:8001/tokenizer_url: http:\/\/172.17.0.1:8000/g' /mcd-order-bot/config.yml && cat /mcd-order-bot/config.yml
RUN sed -i 's/poetry\ run\ rasa\ x/poetry run rasa x --no-prompt/g' /mcd-order-bot/Makefile && cat /mcd-order-bot/Makefile
RUN sed -i 's/poetry\ run\ rasa\ run\ --enable-api/poetry run rasa run --enable-api --cors "*"/g' /mcd-order-bot/Makefile && cat /mcd-order-bot/Makefile
RUN sed -i 's/RASA_DUCKLING_HTTP_URL\ =\ http:\/\/localhost:8000/RASA_DUCKLING_HTTP_URL = http:\/\/172.17.0.1:8000/g' /mcd-order-bot/Makefile && cat /mcd-order-bot/Makefile
RUN sed -i 's/RECOGNIZERS_SERVICE_URL\ =\ http:\/\/localhost:7000\/recognize\/number/RECOGNIZERS_SERVICE_URL = http:\/\/172.17.0.1:7000\/recognize\/number/g' /mcd-order-bot/Makefile && cat /mcd-order-bot/Makefile
RUN cd /mcd-order-bot && make train
ENV RASA_HOME $HOME/rasa

EXPOSE 6080
EXPOSE 5002
EXPOSE 5005
EXPOSE 5055
EXPOSE 8002

#RUN mkdir -p ${RASA_HOME}/terms && echo "${USER} $(date)" > ${RASA_HOME}/terms/agree.txt
CMD cd /mcd-order-bot && make apiserver actionserver x rasaserver -j4

#docker build -t land007/mcd-order-bot:latest .
#docker rm -f mcd-order-bot && docker run --rm -it -p 6081:6080 -p 5002:5002 -p 5006:5005 -p 5056:5055 -p 8002:8002 -e PASSWORD=1 -e SUDO=yes --name mcd-order-bot land007/mcd-order-bot:latest 
#docker exec -it mcd-order-bot bash
