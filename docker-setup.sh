#!/bin/bash
set -e

buildDeps="
  git
  curl
  build-essential
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
  wv
  graphviz
  ImageMagick
"


echo "========================================================================="
echo "Cleaning up previous Plone installation..."
echo "========================================================================="

if [ -z "$ZOPE_HOME" ]; then
  ZOPE_HOME="/plone/instance"
fi

rm -vrf $ZOPE_HOME/* $ZOPE_HOME/.installed.cfg


echo "========================================================================="
echo "Installing zc.buildout and setuptools"
echo "========================================================================="

if [ -z "$ZC_BUILDOUT" ]; then
  ZC_BUILDOUT="2.2.1"
fi

if [ -z "$SETUPTOOLS" ]; then
  SETUPTOOLS="7.0"
fi

pip install zc.buildout==$ZC_BUILDOUT setuptools==$SETUPTOOLS


echo "========================================================================="
echo "Installing $buildDeps"
echo "========================================================================="

apt-get update
apt-get install -y --no-install-recommends $buildDeps

if [ -z "$KGS_VERSION" ]; then
  KGS_VERSION="latest_kgs"
fi


echo "========================================================================="
echo "Installing wkhtmltopdf..."
echo "========================================================================="

curl -o /tmp/wkhtmltopdf.tgz -SL https://svn.eionet.europa.eu/repositories/Zope/trunk/wk/wkhtmltopdf-0.12.2.4.tgz
tar -zxvf /tmp/wkhtmltopdf.tgz -C /tmp/
mv -v /tmp/wkhtmltopdf /usr/bin/


echo "========================================================================="
echo "Getting KGS=$KGS_VERSION"
echo "========================================================================="

git clone https://github.com/eea/eea.plonebuildout.core.git /tmp/eea.plonebuildout.core
cp -v /tmp/eea.plonebuildout.core/buildout-configs/kgs/$KGS_VERSION/*.cfg $ZOPE_HOME/
cp -v /tmp/eea.plonebuildout.core/updates.sh $ZOPE_HOME/
cp -v /tmp/eea.plonebuildout.core/buildout-configs/sources.cfg $ZOPE_HOME/
cp -v /tmp/eea.plonebuildout.core/buildout-configs/base-zope.cfg $ZOPE_HOME/
cp -v /tmp/*.cfg $ZOPE_HOME/


echo "========================================================================="
echo "Running buildout -c buildout.cfg"
echo "========================================================================="

buildout -c buildout.cfg

echo "========================================================================="
echo "Update KGS version"
echo "========================================================================="

./updates.sh

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
echo "Fixing permissions..."
echo "========================================================================="

mkdir -p /data/downloads/pdf /data/downloads/tmp
chown -vR plone:plone /plone /data
