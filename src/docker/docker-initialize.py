#!/plone/instance/bin/python
""" Docker initialize """

import os
from contextlib import closing
import urllib2
from shutil import copy


class Environment(object):
    """ Configure container via environment variables
    """
    def __init__(self, env=os.environ):
        self.env = env
        self.threads = self.env.get('ZOPE_THREADS', '')
        self.fast_listen = self.env.get('ZOPE_FAST_LISTEN', '')
        self.force_connection_close = self.env.get('ZOPE_FORCE_CONNECTION_CLOSE', '')

        self.postgres_host = self.env.get("RELSTORAGE_HOST", None)
        self.postgres_user = self.env.get("RELSTORAGE_USER", None)
        self.postgres_password = self.env.get("RELSTORAGE_PASS", None)

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
        self.cors_conf = '/plone/instance/parts/%s/etc/package-includes/999-cors-overrides.zcml' % (mode,)

        self.graylog = self.env.get('GRAYLOG', '')
        self.facility = self.env.get('GRAYLOG_FACILITY', self.mode)

        self.version = self.env.get('EEA_APP_VERSION',
                       self.env.get('EEA_KGS_VERSION', ''))
        self.name = self.env.get('SERVER_NAME', '')
        self.sentry = self.env.get('SENTRY_DSN', '')
        self._environment = self.env.get('ENVIRONMENT',
                            self.env.get('SENTRY_ENVIRONMENT', ''))

        self._conf = ''

    @property
    def environment(self):
        """ Try to get environment from rancher-metadata
        """
        if not self._environment:
            url = "http://rancher-metadata/latest/self/stack/environment_name"
            try:
                with closing(urllib2.urlopen(url)) as conn:
                    self._environment = conn.read()
            except Exception as err:
                self.log("Couldn't get environment from rancher-metadata: %s.", err)
                self._environment = "devel"
        return self._environment

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

    def setup_graylog(self):
        """ Send logs to graylog
        """
        if not self.graylog:
            return

        self.log("Sending logs to graylog: '%s' as facilty: '%s'", self.graylog, self.facility)
        if 'eea.graylogger' in self.conf:
            return

        template = GRAYLOG_TEMPLATE % (self.graylog, self.facility)
        self.conf = "%import eea.graylogger\n" + self.conf.replace('</logfile>', "</logfile>%s" % template)

    def setup_sentry(self):
        """ Send tracebacks to sentry
        """
        if not self.sentry:
            return

        self.log("Sending errors to sentry. Environment: %s", self.environment)

    def zope_log(self):
        """ Zope logging
        """
        if self.mode == "zeoserver":
            return

        self.setup_graylog()
        self.setup_sentry()

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

    def relstorage_host(self):
        """ RelStorage host
        """
        if not self.postgres_host:
            return

        self.conf = self.conf.replace("host='postgres'", "host='%s'" % self.postgres_host)

    def relstorage_user(self):
        """ RelStorage user
        """
        if not self.postgres_user:
            return

        self.conf = self.conf.replace("user='zope'", "user='%s'" % self.postgres_user)

    def relstorage_password(self):
        """ RelStorage password
        """
        if not self.postgres_password:
            return

        self.conf = self.conf.replace("password='zope'", "password='%s'" % self.postgres_password)

    def relstorage_keep_history(self):
        """ RelStorage keep-history
        """
        if self.keep_history:
            return

        self.conf = self.conf.replace('keep-history true', 'keep-history false')

    def finish(self):
        """ Finish Setup
        """
        conf = self.conf
        with open(self.zope_conf, 'w') as zfile:
            zfile.write(conf)

    def cors(self):
        """ Configure CORS Policies
        """
        if not [e for e in self.env if e.startswith("CORS_")]:
            return

        allow_origin = self.env.get("CORS_ALLOW_ORIGIN",
            "http://localhost:3000,http://127.0.0.1:3000")
        allow_methods = self.env.get("CORS_ALLOW_METHODS",
            "DELETE,GET,OPTIONS,PATCH,POST,PUT")
        allow_credentials = self.env.get("CORS_ALLOW_CREDENTIALS", "true")
        expose_headers = self.env.get("CORS_EXPOSE_HEADERS", "Content-Length")
        allow_headers = self.env.get("CORS_ALLOW_HEADERS", "Accept,Authorization,Content-Type,Lock-Token")
        max_age = self.env.get("CORS_MAX_AGE", "3600")
        cors_conf = CORS_TEMPLATE.format(
            allow_origin=allow_origin,
            allow_methods=allow_methods,
            allow_credentials=allow_credentials,
            expose_headers=expose_headers,
            allow_headers=allow_headers,
            max_age=max_age
        )
        with open(self.cors_conf, "w") as cfile:
            cfile.write(cors_conf)

    def setup(self):
        """ Configure
        """
        self.cors()
        self.zope_mode()
        self.zope_log()
        self.zope_threads()
        self.zope_fast_listen()
        self.zope_force_connection_close()
        self.relstorage_host()
        self.relstorage_user()
        self.relstorage_password()
        self.relstorage_keep_history()
        self.finish()

    __call__ = setup

CORS_TEMPLATE = """<configure
  xmlns="http://namespaces.zope.org/zope">
  <configure
    xmlns="http://namespaces.zope.org/zope"
    xmlns:plone="http://namespaces.plone.org/plone">
    <plone:CORSPolicy
      allow_origin="{allow_origin}"
      allow_methods="{allow_methods}"
      allow_credentials="{allow_credentials}"
      expose_headers="{expose_headers}"
      allow_headers="{allow_headers}"
      max_age="{max_age}"
     />
  </configure>
</configure>
"""

GRAYLOG_TEMPLATE = """
  <graylog>
    server %s
    facility %s
  </graylog>
"""

SENTRY_TEMPLATE = """
  <sentry>
    level ERROR
    site %s
    release %s
    environment %s
    processors eea.plonebuildout.profile.processors.SanitizeZopeProcessor
  </sentry>
"""

def initialize():
    """ Configure
    """
    environment = Environment()
    environment.setup()

if __name__ == "__main__":
    initialize()
