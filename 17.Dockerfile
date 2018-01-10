FROM ubuntu:17.10

MAINTAINER "liu jx" cleocn@qq.com

ADD 17.10.sources.list /etc/apt/sources.list 

RUN rm -rf /var/lib/apt/lists/ \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    supervisor \
    sudo \
	python-pip \
	python-dev \
	build-essential \
	git \
	libxml2-dev \
	libxslt1-dev \
	zlib1g-dev \
	libffi-dev \
	libssl-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

RUN pip install --upgrade pip setuptools -i https://mirrors.aliyun.com/pypi/simple/ \
  && pip install --upgrade \
    scrapyd \
    mysql-connector-python \
    numpy \
    selenium \
    -i https://mirrors.aliyun.com/pypi/simple/  \
  && mkdir -p /usr/share/icons/hicolor

ADD http://npm.taobao.org/mirrors/chromedriver/2.34/chromedriver_linux64.zip /usr/local/bin/

# ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /home
# ADD google-chrome-stable_current_amd64.deb /home
#|| true
# RUN dpkg -i --force-depends /home/google-chrome-stable_current_amd64.deb 
# RUN apt-get install -f \
#   && rm -f /home/google-chrome-stable_current_amd64.deb \
#   && apt-get clean \
#   && rm -rf /var/lib/apt/lists/
RUN  apt-get update \
  && apt-get -f install \
  # && apt-get install -y --no-install-recommends wget \
  # && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - \
  # && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  # && apt-get update \
  && apt-get install -y --no-install-recommends google-chrome-stable

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/log/supervisor \
  && chgrp staff /var/log/supervisor \
  && chmod g+w /var/log/supervisor \
  && chgrp staff /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /etc/scrapyd/ /var/lib/scrapyd/{eggs,dbs,logs,items}

COPY scrapyd.conf /etc/scrapyd/scrapyd.conf

EXPOSE 6800

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
