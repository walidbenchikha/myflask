FROM debian:latest

MAINTAINER Walid Ben Chikha <walid.ben.chikha01@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt-get update && apt-get install -y \
	curl \
	git \
	build-essential \
	python \
	python-pip \
	python-dev \
	python-setuptools \
	nginx \
	supervisor

# Setup nginx
COPY nginx.conf /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/sites-enabled/default
COPY flask-nginx.conf /etc/nginx/sites-available/
RUN ln -sf /etc/nginx/sites-available/flask-nginx.conf /etc/nginx/sites-enabled/flask-nginx.conf
# Copy the uwsgi config file.
COPY uwsgi.ini /etc/
# Setup supervisor.
COPY flask-supervisor.conf /etc/supervisor/conf.d/flask-supervisor.conf
# Create log directories.
RUN mkdir -p /var/log/supervisor /var/log/nginx/app /var/log/uwsgi/app
# Copy application sources.
COPY myflask /var/www/app
# Change working directory.
WORKDIR /var/www/app
# Install app dependencies.
RUN pip install -r requirements/dev.txt
# Start uwsgi and nginx via supervisor daemon.
# here I used supervisor to easly manage (start/stop) nginx and uwsgi deamons
CMD ["/usr/bin/supervisord"]
