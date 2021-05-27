#!/bin/bash
set -e

buildDeps="$(cat "/build-deps.txt")"

runDeps="$(cat "/run-deps.txt")"

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

echo "Running: pip install pip==$PIP zc.buildout==$ZC_BUILDOUT setuptools==$SETUPTOOLS wheel==$WHEEL"
pip install pip==$PIP zc.buildout==$ZC_BUILDOUT setuptools==$SETUPTOOLS wheel==$WHEEL

echo "========================================================================="
echo "Installing wkhtmltopdf..."
echo "========================================================================="

cp /packages/wkhtmltopdf-0.12.4.tgz /tmp/wkhtmltopdf.tgz 
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
mkdir -p /data/log

touch /data/log/instance.log
touch /data/log/instance-Z2.log

touch /data/log/standalone.log
touch /data/log/standalone-Z2.log

touch /data/log/zeo_client.log
touch /data/log/zeo_client-Z2.log

touch /data/log/zeo_async.log
touch /data/log/zeo_async-Z2.log

touch /data/log/rel_async.log
touch /data/log/rel_async-Z2.log

touch /data/log/rel_client.log
touch /data/log/rel_client-Z2.log

# BBB - Backward compatibility
mkdir -p /plone/instance/var
rm -rf /plone/instance/var/log
ln -s /data/log /plone/instance/var/log
# BBB - end

chown -vR plone:plone /plone /data
