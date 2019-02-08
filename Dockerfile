FROM ruby:2.4

RUN apt-get update -qq && \
	apt-get install -y \
	clamav \
	ffmpeg \
	imagemagick \
	less \
	libclamav-dev \
	libclamav7 \
	libcurl3 \
	libcurl3-gnutls \
	libcurl4-openssl-dev \
	libreoffice \
	nodejs \
	openjdk-8-jdk \
	postgresql-client \
	vim \
	zip \
	&& \
	freshclam

WORKDIR /usr/local/src
RUN wget -q https://projects.iq.harvard.edu/files/fits/files/fits-1.1.1.zip && \
	unzip fits-1.1.1.zip && \
	ln -s /usr/local/src/fits-1.1.1/fits.sh /usr/local/bin/fits

WORKDIR /APPROOT
COPY . .
RUN gem install bundler -N && \
	bundle install

COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 3000
