Description
===========

This cookbook manages user accounts, attributes, and permissions in a
generic, data-driven way. It is a drop-in replacement for Opscode's or
37signals' `users` cookbook, but it is more flexible.

This cookbook is partially based on Opscode's `users` cookbook and
`users::sysadmins` recipe.

Requirements
============

Attributes
==========

* `users.supergroup` -- group that is active on all machines, and has
  superuser rights. Default: `sysadmin`. Don't change the default to
  be compatible with Opscode's cookbooks
* `users.active_groups` -- names of groups to create shell accounts
  for on the machine.
  
  `users.supergroup`, if defined, will be added to this list.
  
  If this attribute is not defined, `active_groups` attribute will be
  tried for compatibility with 37signals' cookbook.
  
  Groups in this list will be created as shell groups and users will
  be added to them, unless `groups` data bag item for the group exists
  and has `shell` parameter set to `false`.

Usage
=====

Two data bags need to be created: `users` and `groups`. Second one can
be empty.

The users data bag
------------------

Keys recognized:

* `id` -- ID of data bag item, default username
* `username` -- username if different from `id`; it should be used for
  username policies requiring characters illegal in IDs (e.g. dots)
* `groups` -- list of groups user belongs to
* `comment` (optional) -- usually user's real name
* `shell` -- whether this is a shell account. Can be true (default),
  false, or a string value. If true or unset, use default shell
* `ssh_keys` or `ssh_key` (optional) -- a string or list of strings
  containing public SSH keys of the user
* `openid` (optional) -- OpenID URL of the user, added for supergroup
  members to Apache's mod\_auth\_openid config
* `gid` (optional) -- force user's primary group (name or numeric)
* `uid` (optional) -- force user's numeric id

Arbitrary other keys may be used by other cookbooks.

The groups data bag
-------------------

Keys recognized:

* `id` -- group name
* `gid` (optional) -- force numeric group id
* `shell` -- whether to create a shell group (boolean, defaults to true).

Arbitrary other keys may be used by other cookbooks.
