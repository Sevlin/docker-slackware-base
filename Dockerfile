FROM vbatts/slackware:current

LABEL maintainer="sev@nix.org.ua"

ENV SLACKPKGPLUS_VER=1.7.7

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

RUN slackpkg update gpg
RUN slackpkg update
RUN slackpkg install-template base
RUN update-ca-certificates --fresh

#
# INST: slackpkg+
#
RUN wget --quiet --output-document /tmp/slackpkg+-${SLACKPKGPLUS_VER}-noarch-1mt.txz \
        https://sourceforge.net/projects/slackpkgplus/files/slackpkg%2B-${SLACKPKGPLUS_VER}-noarch-1mt.txz
RUN upgradepkg --install-new /tmp/*.t?z
RUN rm -vf /tmp/*.t?z

COPY slackpkgplus.conf /etc/slackpkg/

#
# SYS: upgrade-all
#
RUN slackpkg update gpg
RUN slackpkg update
RUN slackpkg upgrade-all
RUN slackpkg new-config
RUN rm -rf /var/lib/slackpkg/* \
           /var/cache/packages/*
RUN echo 'https://mirrors.nix.org.ua/linux/slackware/slackware64-current/' > /etc/slackpkg/mirrors \
 && touch /var/lib/slackpkg/current

