Description
===========

This cookbook manages user accounts, attributes, and permissions in a
generic, data-driven way. It is a drop-in replacement for Opscode's or
37signals' `users` cookbook, but it is more flexible.

This cookbook is partially based on Opscode's `users` cookbook and
`users::sysadmins` recipe.

This cookbook also provides a library part that can be used to
centrally configure users of your system in a consistent, data-driven
way. You can use the library part even when still using old opscode's
or 37signals' cookbook to actually create shell accounts. See "usage"
section for details.

Requirements
============

No other cookbook is required.

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
* `users.force_default_group` -- name of group that will be primary
  group for all users. Default is that a group is created for each user.

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
* `removed` -- if set to true value, user's account is **removed** if
  it exists. Set this key to revoke access instead of just deleting
  the data bag item -- the recipe won't touch unknown accounts.

Arbitrary other keys may be used by other cookbooks.

The groups data bag
-------------------

Keys recognized:

* `id` -- group name
* `gid` (optional) -- force numeric group id
* `shell` -- whether to create a shell group (boolean, defaults to true).
* `user_attributes` -- dictionary of attributes that will be applied
  to group members. Adding other groups by
  `group["user_attributes"]["groups"]` won't work; if group
  inheritance is needed, some other way will be provided.

Arbitrary other keys may be used by other cookbooks.

The GenericUsers::User class
----------------------------

A library class is provided to encapsulate common logic and move it
out of cookbooks. This logic concerns mostly user attribute defaults
provided in groups' `user_attributes` dictionary. To get new `User`
instances, following methods are provided:

* `GenericUsers::User.new(item)` -- takes a data bag item from
  `:users` data bag for initialization
* `GenericUsers::User.get(id)` -- fetches a `:users` data bag item,
  returns `User` instance
* `GenericUsers::User.find(query)` -- searches for `:user` data bag
  items by Chef search query, returns array of `User` instances

Attributes of original data bag items are processed for convenience:

* `:groups` attribute is a list even if data bag item's attribute is a
  bare string
* `:username` attribute, if not provided, is initialized to be equal
  to `:id`

Dictionary access on User instance return user's direct attribute if
it exists. Otherwise, user's groups are iterated to find one, whose
`:user_attributes` dictionary defines such attribute. First found
value is used.

To use all defined values (directly from user item and from all groups
that define the value), `get_all` method is used. When called only
with parameter name, it return an array of arrays: each array in the
list is a list of attribute values. If provided with a block that
takes two parameters, this block is used together with `inject` method
to flatten the list; use `&:+` to concatenate the list and `&:|` to
get a list of unique values. An example to clarify:

    user.get_all(:foo) => [[1], [2, 3], [1, 2, 4]]
    user.get_all(:foo, &:+) => [1, 2, 3, 1, 2, 4]
    user.get_all(:foo, &:|) => [1, 2, 3, 4]

Convenience methods
-------------------

* `GenericUsers::get_group(group_id)` -- returns data bag item or
  "imaginary group" Mash (containing two attributes: `:id`, and
  `:imaginary => true`) if group is not found.

Tests and docs
==============

Libraary part has an RSpec test suite provided in the `spec.rb` file,
and yardoc generated documentation in `doc` subdirectory. Run `bundle`
to get all needed software, `rake test` to test the library part, and
`rake doc` to regenerate documentation.
