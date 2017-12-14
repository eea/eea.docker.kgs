#!/plone/instance/bin/python

import os
from shutil import copy


class Environment(object):
    """ Configure container via environment variables
    """
    def __init__(self, env=os.environ):
        self.env = env
        self.threads = self.env.get('ZOPE_THREADS', '')
        self.fast_listen = self.env.get('ZOPE_FAST_LISTEN', '')
        self.force_connection_close = self.env.get('ZOPE_FORCE_CONNECTION_CLOSE', '')

        self.keep_history = True
        if self.env.get('RELSTORAGE_KEEP_HISTORY', 'true').lower() in ('false', 'no', '0'):
            self.keep_history = False

        mode = self.env.get('ZOPE_MODE', 'standalone')
        conf = 'zope.conf'
        if mode == 'zeoserver':
            conf = 'zeo.conf'
        conf = '/plone/instance/parts/%s/etc/%s' % (mode, conf)
        if not os.path.exists(conf):
            mode = 'standalone'
            conf = '/plone/instance/parts/%s/etc/%s' % (mode, conf)

        self.mode = mode
        self.zope_conf = conf

        self.graylog = self.env.get('GRAYLOG', '')
        self.facility = self.env.get('GRAYLOG_FACILITY', self.mode)

        self._conf = ''

    @property
    def conf(self):
        """ Zope conf
        """
        if not self._conf:
            with open(self.zope_conf, 'r') as zfile:
                self._conf = zfile.read()
        return self._conf

    @conf.setter
    def conf(self, value):
        """ Zope conf
        """
        self._conf = value

    def log(self, msg='', *args):
        """ Log message to console
        """
        print msg % args

    def zope_mode(self):
        """ Zope mode
        """
        self.log("Using bin/%s", self.mode)
        copy('/plone/instance/bin/%s' % self.mode, '/plone/instance/bin/instance')

    def zope_log(self):
        """ Zope logging
        """
        if not self.graylog:
            return

        if self.mode == "zeoserver":
            return

        self.log("Sending logs to graylog: '%s' as facilty: '%s'", self.graylog, self.facility)

        if 'eea.graylogger' in self.conf:
            return

        template = GRAYLOG_TEMPLATE % (self.graylog, self.facility)
        self.conf = "%import eea.graylogger\n" + self.conf.replace('</logfile>', "</logfile>%s" % template)

    def zope_threads(self):
        """ Zope threads
        """
        if not self.threads:
            return

        self.conf = self.conf.replace('zserver-threads 2', 'zserver-threads %s' % self.threads)

    def zope_fast_listen(self):
        """ Zope fast-listen
        """
        if not self.fast_listen or self.fast_listen == 'off':
            return

        self.conf = self.conf.replace('fast-listen off', 'fast-listen %s' % self.fast_listen)

    def zope_force_connection_close(self):
        """ force-connection-close
        """
        if not self.force_connection_close or self.force_connection_close == 'on':
            return

        self.conf = self.conf.replace(
            'force-connection-close on', 'force-connection-close %s' % self.force_connection_close)

    def relstorage_keep_history(self):
        """ RelStorage keep-history
        """
        if self.keep_history:
            return

        self.conf = self.conf.replace('keep-history true', 'keep-history false')

    def finish(self):
        conf = self.conf
        with open(self.zope_conf, 'w') as zfile:
            zfile.write(conf)

    def setup(self):
        """ Configure
        """
        self.zope_mode()
        self.zope_log()
        self.zope_threads()
        self.zope_fast_listen()
        self.zope_force_connection_close()
        self.relstorage_keep_history()
        self.finish()

    __call__ = setup


GRAYLOG_TEMPLATE = """
  <graylog>
    server %s
    facility %s
  </graylog>
"""


def initialize():
    """ Configure
    """
    environment = Environment()
    environment.setup()

if __name__ == "__main__":
    initialize()
