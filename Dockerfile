FROM atlashealth/ruby:2.2.0

RUN apt-get update \
  && apt-get install -y \
    curl \
    python-minimal \
    git-core \
    nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

RUN curl -L "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf - -C /usr/local

RUN curl -L "https://www.dropbox.com/download?dl=packages/dropbox.py" > /usr/local/bin/dropbox.py
RUN chmod a+x /usr/local/bin/dropbox.py

WORKDIR /app

ADD . /app

RUN bundle install

CMD /app/start.sh
