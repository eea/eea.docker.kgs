#!/plone/instance/bin/python

from shutil import copy
import os


def initialize():
    """ Configure
    """
    mode = os.environ.get('ZOPE_MODE', 'standalone')
    print "===================================================================="
    try:
        copy('/plone/instance/bin/%s' % mode.lower(),
             '/plone/instance/bin/instance')
    except Exception, err:
        print err
        print "Unknown mode %s. Fallback to bin/standalone" % mode
        copy('/plone/instance/bin/standalone','/plone/instance/bin/instance')
    else:
        print "Using bin/%s" % mode
    print "===================================================================="


if __name__ == "__main__":
    initialize()
