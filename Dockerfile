FROM ruby:2.5

RUN apt-get update -qq && \
	apt-get install -y \
	ffmpeg \
	imagemagick \
	less \
	libcurl3 \
	libcurl3-gnutls \
	libcurl4-openssl-dev \
	libreoffice \
	nodejs \
	openjdk-8-jdk \
	postgresql-client \
	vim

# TODO: Install FITS

RUN mkdir /APPROOT
WORKDIR /APPROOT
COPY . .
RUN gem install bundler -N && \
	bundle install --deployment

EXPOSE 3000
# CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000", "--prune-bundler"]
