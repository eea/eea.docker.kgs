#!/bin/bash
set -e

buildDeps="
  git
  curl
  build-essential
  libblas-dev
  liblapack-dev
  gfortran
  libexpat1-dev
  libc6-dev
  libjpeg-dev
  libmemcached-dev
  libpq-dev
  libreadline-dev
  libldap2-dev
  libsasl2-dev
  libssl-dev
  libxml2-dev
  libxslt-dev
  libz-dev
  zlib1g-dev
"

runDeps="
  vim
  git
  curl
  subversion
  tex-gyre
  poppler-utils
  libpng12-0
  libjpeg62
  libxml2
  libxslt1.1
  libpq5
  libmemcached11
  libmagickcore-6.q16-2-extra
  lynx
  wv
  graphviz
  ImageMagick
  ghostscript
"

echo "========================================================================="
echo "Installing $buildDeps"
echo "========================================================================="

apt-get update
apt-get install -y --no-install-recommends $buildDeps

echo "========================================================================="
echo "Installing pip, zc.buildout and setuptools"
echo "========================================================================="

VERSION_CFG="/plone/instance/versions.cfg"

if [ -z "$PIP" ]; then
  PIP=$(cat $VERSION_CFG | grep "pip\s*=\s*" | sed 's/^.*\=\s*//g')
fi

if [ -z "$ZC_BUILDOUT" ]; then
  ZC_BUILDOUT=$(cat $VERSION_CFG | grep "zc\.buildout\s*=\s*" | sed 's/^.*\=\s*//g')
fi

if [ -z "$SETUPTOOLS" ]; then
  SETUPTOOLS=$(cat $VERSION_CFG | grep "setuptools\s*\=\s*" | sed 's/ *//g' | sed 's/=//g' | sed 's/[a-z]//g')
fi

echo "Running: pip install pip==$PIP zc.buildout==$ZC_BUILDOUT setuptools==$SETUPTOOLS"
pip install pip==$PIP zc.buildout==$ZC_BUILDOUT setuptools==$SETUPTOOLS


echo "========================================================================="
echo "Installing gosu"
echo "========================================================================="

curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"
curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc"
export GNUPGHOME="$(mktemp -d)"
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu
rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc
chmod +x /usr/local/bin/gosu
gosu nobody true


echo "========================================================================="
echo "Installing wkhtmltopdf..."
echo "========================================================================="

curl -o /tmp/wkhtmltopdf.tgz -SL https://svn.eionet.europa.eu/repositories/Zope/trunk/wk/wkhtmltopdf-0.12.2.4.tgz
tar -zxvf /tmp/wkhtmltopdf.tgz -C /tmp/
mv -v /tmp/wkhtmltopdf /usr/bin/

echo "========================================================================="
echo "Running buildout -c buildout.cfg"
echo "========================================================================="

buildout -c buildout.cfg

echo "========================================================================="
echo "Update KGS version"
echo "========================================================================="

/updates.sh

echo "========================================================================="
echo "Unininstalling $buildDeps"
echo "========================================================================="

apt-get purge -y --auto-remove $buildDeps


echo "========================================================================="
echo "Installing $runDeps"
echo "========================================================================="

apt-get install -y --no-install-recommends $runDeps


echo "========================================================================="
echo "Cleaning up cache..."
echo "========================================================================="

rm -vrf /var/lib/apt/lists/*
rm -vrf /plone/buildout-cache/downloads/*
rm -vrf /tmp/*

echo "========================================================================="
echo "mkrelease..."
echo "========================================================================="

ln -s /plone/instance/bin/mkrelease /usr/local/bin/mkrelease
ln -s /mkrelease-pypi /usr/local/bin/mkrelease-pypi

echo "========================================================================="
echo "Fixing permissions..."
echo "========================================================================="

mkdir -p /data/suggestions
mkdir -p /data/downloads/pdf
mkdir -p /data/downloads/tmp
mkdir -p /plone/instance/var/log/

touch /plone/instance/var/log/instance.log
touch /plone/instance/var/log/instance-Z2.log

touch /plone/instance/var/log/standalone.log
touch /plone/instance/var/log/standalone-Z2.log

touch /plone/instance/var/log/zeo_client.log
touch /plone/instance/var/log/zeo_client-Z2.log

touch /plone/instance/var/log/zeo_async.log
touch /plone/instance/var/log/zeo_async-Z2.log

touch /plone/instance/var/log/rel_async.log
touch /plone/instance/var/log/rel_async-Z2.log

touch /plone/instance/var/log/rel_client.log
touch /plone/instance/var/log/rel_client-Z2.log

chown -vR plone:plone /plone /data
