What is it?
===========

A puppet module that creates a riak ["development"](http://docs.basho.com/riak/latest/tutorials/fast-track/Building-a-Development-Environment/) cluster.
It takes care of putting binary files on disk and creating the cluster, but
does not create the initial binary tarball.  To create the binary tarball:

```
Download current [source](http://docs.basho.com/riak/latest/tutorials/installation/Installing-Riak-from-Source/)
tar -xzf riak-${version}.tar.gz
cd riak-${version}
make all
make devrel DEVNODES=1
cd dev
mv dev1 dev
tar -czf riak-dev-instance-${version}.tar.gz dev
```

The riak cluster is automatically backed up by [evenup/backups](https://github.com/evenup/evenup-backups)
and graphite statics through [sensu](http://sensuapp.org) are provided.  Both
will be made optional in a future release.

Usage:
------

<pre>
  class { 'riakdev':
    version           => '1.3.1',
    num_instances     => 3,
    pb_initial_port   => 8081,
    http_initial_port => 8091,
  }
</pre>


Known Issues:
-------------
Only tested on CentOS 6

TODO:
____
[ ] Make backups optional
[ ] Make sensu monitoring optional

License:
_______

Released under the Apache 2.0 licence


Contribute:
-----------
* Fork it
* Create a topic branch
* Improve/fix (with spec tests)
* Push new topic branch
* Submit a PR