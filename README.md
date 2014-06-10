berkshelf-store
===============

A cookbook store compatible with berkshelf API

Status
------

work in progress...


Install
-------

    gem build berkshelf-store.gemspec
    gem install berkshelf-store-*.gem


Usage
-----

### Launch the deamon

    Usage: berkshelf-store.rb [options]
        -D, --datadir DIRECTORY          Data directory (default: ./datadir)
        -T, --tmpdir DIRECTORY           Tmp directory (default: ./tmpdir)
        -b, --bind IP                    bind IP (default: 127.0.0.1)
        -p, --port PORT                  port to listen on (default: 80)
        -l, --logger TYPE                file, syslog, stderr (default: syslog)
        -L, --logger-conf TYPE           file: filename, syslog: program.facility, stderr n/a (default: berkshelf-store.daemon)

Example:

    berkshelf-store -D /var/lib/berkshelf-store -T /var/tmp/berkshelf-store --bind 0.0.0.0 -l stderr

### upload some cookbooks

    curl -F cookbook=@/path/to/the/cookbook.tgz http://localhost/v1/cookbooks/cookbookname/cookbookversion

### use it with berkshelf

in the berkfile:

    source "http://localhost/v1"

    cookbook "cookbookname"

TODO:
----
- more Comments and tests
- cli (knife or beks plugin) for uploading
- Auth
- ACL (limit uploads by cookbook/users/groups)
- UI
- multi-tenancy ?



