# whomst

Gets user and group info, by any means necessary

whomst will try obtaining info, in order of availability, from:

- the `getpwnam`and `getgrnam` functions from the [posix][] module
- the functions from the [userid][] module (if installed)
- the `getent(1)` binary
- the contents of `/etc/passwd` and `/etc/group`
- the results of doing a `setuid` or `setgid` with the given name (as used by
  [npm][uid-number])
- as a last-ditch effort, seeing if the uid matches the current user's info

[posix]: https://github.com/ohmu/node-posix
[userid]: https://github.com/jandre/node-userid
[uid-number]: https://github.com/npm/uid-number

As of v0.1.2, not all of these code paths have been tested (though they are all
believed to be implemented).

## API

`whomst.user` and`whomst.group` take a number or string and return a promise.
`whomst.sync.user` and `whomst.sync.group` do the same thing, but synchronously
instead of via promises.

These functions return objects compatible with the return values of the
corresponding functions from the `posix` package. See the documentation for
[posix.getpwnam][] and [posix.getgrnam][] for examples of returns from
whomst.user and whomst.group, respectively.

[posix.getpwnam]: https://github.com/ohmu/node-posix#posixgetpwnamuser
[posix.getgrnam]: https://github.com/ohmu/node-posix#posixgetgrnamgroup

Note that not all fields are guaranteed: if `whomst.group` has to fall back to
the `setgid` hack method for determining a group's gid, the return value may
only contain `name` and `gid` (or even only `gid`, if the name wasn't
provided). This means that *you may not be able to determine a group's name
from its gid*, if all the more-reliable mechanisms fail.

## Tips

Unlike some similar modules like `uid-number`, `whomst` does not cache any
results between calls (as these results could, in theory, change between two
separate invocations). If you wish to cache results between calls to this
function (say, if you're going to make thousands of calls to it in the space of
a very short time), you may wish to implement a memoization layer like
[fast-memoize][] around `whomst`.

[fast-memoize]: https://www.npmjs.com/package/fast-memoize
