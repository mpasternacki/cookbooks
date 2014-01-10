Supervisord cookbook
====================

This cookbook installs
[Supervisord](http://supervisord.org/configuration.html) and provides
a resource to supervise programs.

Usage
-----

Include `recipe[supervisord]` in your run list, and
`supervisord_program` resource to configure individual programs. See
`See recipes/example.rb` for sample usage

Resources
---------

## `supervisord_program` 

### Actions

- `:supervise` (default):  add program to supervisord config
- `:start`, `:stop`, `:restart`: manage service

### Attribute parameters

- `:name` (name attribute)
- `:command` (required)
- all settings of a `[program:X]` section of supervisord config

Authors
-------

* Maciej Pasternacki
* Dan Crosta
