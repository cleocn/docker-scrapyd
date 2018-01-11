FROM ubuntu:16.04

MAINTAINER "liu jx" cleocn@qq.com

ADD sources.list /etc/apt/sources.list 

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
  wget \
  unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

RUN pip install --upgrade pip setuptools -i https://mirrors.aliyun.com/pypi/simple/ \
  && pip install --upgrade \
    git+https://github.com/cleocn/scrapyd.git@master \
    mysql-connector-python \
    numpy \
    selenium \
    -i https://mirrors.aliyun.com/pypi/simple/  

ADD http://npm.taobao.org/mirrors/chromedriver/2.34/chromedriver_linux64.zip /usr/local/bin/
WORKDIR /usr/local/bin/
RUN unzip chromedriver_linux64.zip \
  && rm -f chromedriver_linux64.zip

# Plan A 
# ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /home
# # ADD google-chrome-stable_current_amd64.deb /home
# RUN dpkg -i --force-depends /home/google-chrome-stable_current_amd64.deb || true \
#   && apt-get install -f -y \
#   && rm -f /home/google-chrome-stable_current_amd64.deb \
#   && apt-get clean \
#   && rm -rf /var/lib/apt/lists/

# Plan B
RUN  wget -q -O - http://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && mkdir -p ~/.pip/ \
  && sh -c 'echo "[global] \
index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf' \
  && apt-get update \
  && apt-get install -y --no-install-recommends google-chrome-stable \
    tzdata \
  && rm -f /etc/apt/sources.list.d/google.list \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/log/supervisor \
  && chgrp staff /var/log/supervisor \
  && chmod g+w /var/log/supervisor \
  && chgrp staff /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /etc/scrapyd/ /var/lib/scrapyd/{eggs,dbs,logs,items}

COPY scrapyd.conf /etc/scrapyd/scrapyd.conf

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG="zh_CN.UTF-8" 
RUN echo "export LC_ALL=zh_CN.UTF-8"  >>  /etc/profile

EXPOSE 6800

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
