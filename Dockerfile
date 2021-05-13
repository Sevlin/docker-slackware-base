FROM vbatts/slackware:current

LABEL maintainer="sev@nix.org.ua"

ENV SLACKPKGPLUS_VER=1.7.6

ENV TERM=xterm

# pkgtools flags
ENV TERSE=0
# upgradepkg flag
#   Workaround to install new slackpkg,
#   even though older version is installed
ENV INSTALL_NEW=yes

COPY slackpkg.conf /etc/slackpkg/slackpkg.conf.custom
COPY base.template /etc/slackpkg/templates/
COPY sudoers /etc/sudoers.d/10-wheel

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#
# SYS: configuration and upgrades
#
RUN cat /etc/slackpkg/slackpkg.conf.custom > /etc/slackpkg/slackpkg.conf \
 && echo 'http://mirrors.nix.org.ua/linux/slackware/slackware64-current/' > /etc/slackpkg/mirrors \
 && touch /var/lib/slackpkg/current

RUN slackpkg update
RUN slackpkg update gpg
RUN slackpkg install aaa_glibc-solibs aaa_libraries
RUN slackpkg clean-system
RUN slackpkg upgrade slackpkg

RUN cat /etc/slackpkg/slackpkg.conf.custom > /etc/slackpkg/slackpkg.conf \
 && sed -i 's/v2.8/v15.0/g' /etc/slackpkg/slackpkg.conf \
 && echo 'http://mirrors.nix.org.ua/linux/slackware/slackware64-current/' > /etc/slackpkg/mirrors \
 && touch /var/lib/slackpkg/current

RUN slackpkg update
RUN slackpkg upgrade pkgtools
RUN slackpkg install-template base
RUN update-ca-certificates --fresh
RUN slackpkg new-config

#
# INST: slackpkg+
#
RUN wget --quiet --output-document /tmp/slackpkg+-${SLACKPKGPLUS_VER}-noarch-1mt.txz \
        https://sourceforge.net/projects/slackpkgplus/files/slackpkg%2B-${SLACKPKGPLUS_VER}-noarch-1mt.txz
RUN upgradepkg --install-new /tmp/*.t?z
RUN rm -vf /tmp/*.t?z

COPY slackpkgplus.conf /etc/slackpkg/

# SYS: restore slackpkg.conf
RUN cat /etc/slackpkg/slackpkg.conf.custom > /etc/slackpkg/slackpkg.conf \
 && sed -i 's/v2.8/v15.0/g' /etc/slackpkg/slackpkg.conf \
 && echo 'https://mirrors.nix.org.ua/linux/slackware/slackware64-current/' > /etc/slackpkg/mirrors \
 && touch /var/lib/slackpkg/current
RUN rm /etc/slackpkg/slackpkg.conf.custom

#
# SYS: upgrade-all
#
RUN slackpkg upgrade-all
RUN rm -rf /var/lib/slackpkg/* \
           /var/cache/packages/*
RUN touch /var/lib/slackpkg/current

