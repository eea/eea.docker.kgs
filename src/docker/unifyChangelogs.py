#!/plone/instance/bin/zopepy
"""

Usage:

  $ ./unifyChnagelogs.py <URL_TO_PREVIOUS_VERSIONS.CFG>  <URL_TO_LATEST_VERSIONS.CFG> > changelog.md
  $ cat changelog.md

Example:

  $ ./unifyChangelogs.py https://raw.githubusercontent.com/eea/eea.docker.kgs/14.0/src/plone/versions.cfg https://raw.githubusercontent.com/eea/eea.docker.kgs/14.1/src/plone/versions.cfg > changelog.md
  $ cat changelog.md

"""

import contextlib
import urllib2
from distutils.version import StrictVersion
from docutils.core import publish_doctree
import sys

SOURCES = 'https://raw.githubusercontent.com/eea/eea.docker.kgs/master/src/plone/sources.cfg'
KGS_VERSION = 'https://raw.githubusercontent.com/eea/eea.docker.kgs/{version}/src/plone/versions.cfg'
OLD_VERSION = "https://raw.githubusercontent.com/eea/eea.plonebuildout.core/master/buildout-configs/kgs/{version}/versions.cfg"

def pullVersions(url):
    """ Compute versions
    """
    with contextlib.closing(urllib2.urlopen(url)) as versionsFile:
        for line in versionsFile:
            if line.startswith("#"):
                continue
            if line.startswith("["):
                continue
            if '=' not in line:
                continue

            package, version = line.split('=', 1)
            package = package.strip()
            version = version.strip()

            try:
                version = StrictVersion(version)
            except ValueError as err:
                continue

            yield package, version

def pullSources(url):
    """ Compute locations
    """
    with contextlib.closing(urllib2.urlopen(url)) as sourcesFile:
        for line in sourcesFile:
            if line.startswith("#"):
                continue
            if line.startswith("["):
                continue
            if '=' not in line:
                continue

            package, location = line.split("=", 1)
            package = package.strip()
            location = location.strip().split()[1].strip('.git')
            yield package, location

def main():
    if len(sys.argv) != 3:
        raise RuntimeError(__doc__)

    try:
        before = StrictVersion(sys.argv[1])
    except ValueError:
        before = sys.argv[1]
    else:
        if before < StrictVersion('14.0'):
            before = OLD_VERSION.format(version=before)
        else:
            before = KGS_VERSION.format(version=before)

    try:
        after = StrictVersion(sys.argv[2])
    except ValueError:
        after = sys.argv[2]
    else:
        if after < StrictVersion('14.0'):
            after = OLD_VERSION.format(version=after)
        else:
            after = KGS_VERSION.format(version=after)

    before = pullVersions(before)
    after = pullVersions(after)
    sources = pullSources(SOURCES)

    before = dict(before)
    sources = dict(sources)
    for package, version in after:
        previous = before.get(package, StrictVersion(0))
        if version <= previous:
            continue

        change = "\n## %s: %s ~ %s" % (package, previous, version)
        print(change)

        source = sources.get(package, None)
        if not source:
            continue

        response = None
        for structure in [
            "raw/develop/docs/HISTORY.txt",
            "raw/develop/HISTORY.txt",
            "raw/develop/CHANGES.txt"
            "raw/develop/docs/CHANGES.txt",
            "raw/master/docs/HISTORY.txt",
            "raw/master/HISTORY.txt",
            "raw/master/CHANGES.txt"
            "raw/master/docs/CHANGES.txt",
            "docs/HISTORY.txt",
            "docs/CHANGES.txt",
            "CHANGES.txt",
            "HISTORY.txt"]:

            try:
                response = urllib2.urlopen("%s/%s" % (source, structure))
            except urllib2.HTTPError:
                continue
            else:
                break

        if not response:
            continue

        logtext = response.read()
        tree = publish_doctree(logtext)

        def isValidVersionSection(x):
            if x.tagname == "section":
                try:
                    logVersion = StrictVersion(x['names'][0].split()[0])
                except ValueError:
                    pass
                else:
                    return logVersion > previous and logVersion <= version
            return False

        foundSections = tree.traverse(condition=isValidVersionSection)
        if foundSections:
            for s in foundSections:
                s.children[-1]
                childlist = s.children[-1]
                bullet = "- "
                for child in childlist.children:
                    text = child.astext()
                    text = text.replace("\n","\n" + " "*len(bullet))
                    print("* {text}".format(text=text))
        else:
            print("* https://pypi.python.org/pypi/{package}#changelog".format(package=package))

if __name__ == "__main__":
    main()
