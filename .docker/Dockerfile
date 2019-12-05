FROM gitlab-registry.oit.duke.edu/devops/containers/ruby:2.6

ARG APPROOT=/usr/src/app
ARG FITS_TMPDIR=/var/tmp/fits
ENV FITS_HEAP_SIZE=1g
ENV FITS_JAVA_OPTS="-Djava.io.tmpdir=${FITS_TMPDIR} -Xmx${FITS_HEAP_SIZE}"

RUN apt-get -y update \
	&& apt-get -y install \
	clamdscan \
        imagemagick \
	mediainfo \
	openjdk-11-jdk \
	unzip \
	wget \
	zip \
	&& apt-get -y clean

# Install FITS from builder image
COPY --from=gitlab-registry.oit.duke.edu/devops/containers/fits-container:1.5.0 /usr/src/fits /usr/src/fits

# Workaround for OpenSSL issue with EZID
ENV OPENSSL_CONF=/usr/local/etc/openssl.cnf
RUN sed 's/^CipherString = DEFAULT@SECLEVEL=2//' /etc/ssl/openssl.cnf > $OPENSSL_CONF \
	# Remove resource limits in ImageMagick
	&& sed -i -E 's/^(\s*<policy domain="resource" .*)$/<!-- \1 -->/g' /etc/ImageMagick-6/policy.xml \
	&& sed -i -E 's/^(<\/policymap>)/<policy domain="coder" rights="read|write" pattern="*" \/>\n\1/' \
	/etc/ImageMagick-6/policy.xml \
	# Tell clamscan to use TCP socket address
	&& echo 'TCPSocket 3310\nTCPAddr clamav' > /etc/clamav/clamd.conf \
	# Give appuser an IRB history
	&& echo 'IRB.conf[:SAVE_HISTORY] = 1000' > /home/appuser/.irbrc \
	# Symlink FITS script into PATH
	&& ln -s /usr/src/fits/fits.sh /usr/local/bin/fits.sh

WORKDIR $APPROOT
COPY . .
RUN bundle install \
	&& bundle exec rake assets:precompile \
	&& chown -R 1001:1001 log tmp public db/schema.rb \
	&& mkdir -p -m 0755 $FITS_TMPDIR \
	&& chown 1001:1001 $FITS_TMPDIR
VOLUME $FITS_TMPDIR

COPY .docker/include/docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

EXPOSE 3000
USER 1001
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000", "-P", "/tmp/server.pid"]
