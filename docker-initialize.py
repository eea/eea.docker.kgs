#!/plone/instance/bin/python

from shutil import copy
import os

GRAYLOG_TEMPLATE = """
  <graylog>
    server %s
    facility %s
  </graylog>
"""

def zope_mode(mode):
    """ Start Zope in mode.
    """
    try:
        copy('/plone/instance/bin/%s' % mode.lower(),
             '/plone/instance/bin/instance')
    except Exception, err:
        print err
        print "Unknown mode %s. Fallback to bin/standalone" % mode
        copy('/plone/instance/bin/standalone','/plone/instance/bin/instance')
    else:
        print "Using bin/%s" % mode


def zope_log(mode, graylog):
    """ Zope logging
    """
    if not graylog:
        print "No GRAYLOG server provided. Centralized logging disabled."
        return

    if not os.path.exists('/plone/instance/parts/%s/etc/zope.conf' % mode):
        print "Unknown mode %s. Fallback to standalone" % mode
        mode = 'standalone'

    conf = ''
    with open('/plone/instance/parts/%s/etc/zope.conf' % mode, 'r') as zfile:
        conf = zfile.read()
        if 'eea.graylogger' in conf:
            print "eea.graylogger already configured."
            return

    facilty = os.environ.get('GRAYLOG_FACILITY', mode)
    print "Sending logs to graylog: '%s' as facilty: '%s'" % (graylog, facilty)

    template = GRAYLOG_TEMPLATE % (graylog, facilty)
    conf = "%import eea.graylogger\n" + conf.replace('</logfile>', "</logfile>%s" % template)

    with open('/plone/instance/parts/%s/etc/zope.conf' % mode, 'w') as zfile:
        zfile.write(conf)


def initialize():
    """ Configure
    """
    mode = os.environ.get('ZOPE_MODE', 'standalone')
    zope_mode(mode)

    print "===================================================================="

    graylog = os.environ.get('GRAYLOG', '')
    zope_log(mode, graylog)

    print "===================================================================="

if __name__ == "__main__":
    initialize()
