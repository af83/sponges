# Changelog

## Version 0.6

 * Deprecation notice about Redis store removal
 * Ruby 2.0 compatibility: rework signal handler. 2.0 does not allow the use of
 a mutex in a trap. For now on, a pipe is use to comunicate signal to the
 handler. This has also enforce signal handler to be synchrone.
 * `restart` now daemonize process by default


### Version 0.7

 * Inclusion of Http supervision
