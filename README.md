# sponges

[![Code
Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/AF83/sponges)
[![Gem
Version](https://fury-badge.herokuapp.com/rb/sponges.png)](http://badge.fury.io/rb/sponges)

When I build workers, I want them to be like an army of spongebobs, always
stressed and eager to work. `sponges` helps you build this army of sponges, to
control them, and, well, to kill them gracefully. Making them stressed and eager
to work is your job. :)

Basically, sponges is a ruby supervisor that forks processes and controls their
execution and termination. For example the following will start a supervision
daemon and 8 processes of  "a_worker".

```bash
ruby a_worker.rb start -d -s 8
```
If you kill the supervisor it will cleanly
terminate the child processes.

Internally, `sponges` strongly relies on Unix signals.

## Is it any good?

[Yes.](http://news.ycombinator.com/item?id=3067434)

## Installation

Ruby 1.9.2 (or superior).

Install it with rubygems:

    gem install sponges

With bundler, add it to your `Gemfile`:

``` ruby
gem "sponges"
```

## Usage
In a file called `example.rb`:

``` ruby
# The worker class is the one you want to daemonize.
#
require 'sponges'

class Worker
  def initialize
    # Trap the HUP signal, set a boolean to true.
    trap(:HUP) {
      Sponges.logger.info "HUP signal trapped, clean stop."
      @hup = true
    }
  end

  def run
    Sponges.logger.info Process.pid
    if @hup # is true, we need to shutdown this worker
      Sponges.logger.info "HUP signal trapped, shutdown..."
      exit 0 # everything's fine, we can exit
    else # this worker can continue its work
      sleep rand(20)
      run
    end
  end
end

Sponges.configure do |config|
  config.logger            = MyCustomLogger.new   # optionnal
  config.redis             = Redis.new            # optionnal
  config.size              = 3                    # optionnal, default to cpu's size
  config.daemonize         = true                 # optionnal, default to false
  config.port              = 5032                 # optionnal, default to 5032
  config.after_fork do
    puts "Execute code when a child process is created"
  end
  config.on_chld do
    puts "Execute code when a child process is killed"
end

# Register a pool named "worker_name".
#
Sponges.start "worker_name" do
  Worker.new({some: args}).run
end
```
See the help message :
``` bash
ruby example.rb
```

Start workers :
``` bash
ruby example.rb start
```

Start workers and daemonize them:
``` bash
ruby example.rb start -d
```

Start 8 instances of the worker and daemonize them:
``` bash
ruby example.rb start -d -s 8 # By default, size equals cpu core's size.
```

Retart gracefully 4 instances of the worker, with a timeout of 3 seconds and
daemonize them:
``` bash
ruby example.rb restart -g -s 4 -t 3
```

Stop workers with a `QUIT` signal :
``` bash
ruby example.rb stop
```

Stop workers with a `KILL` signal :
``` bash
ruby example.rb kill
```

Stop workers with a `HUP` signal :
``` bash
ruby example.rb stop -g -t 5
```
In this case, you will have to trap the `HUP` signal, and handle a clean stop
from each workers. The point is to wait for a task to be done before quitting. A
timeout can be specify with the `-t` option. When this timeout is hited, the
process is killed.

Increment worker's pool size :
``` bash
ruby example.rb increment # will add a worker to the pool.
```

Decrement worker's pool size :
``` bash
ruby example.rb decrement # will remove a worker to the pool.
```

Show a list of workers and their children.
``` bash
ruby example.rb list
```

## Http supervision

sponges provides an http interface to supervise pool's activity, and to expose
pids. Http supervision can be enable in configuration:


``` ruby
Sponges.configure do |config|
  config.port            = 3333
end
```

By default, sponges listens on port 5032, and responds in json. Here is an
example of response:

``` javascript
{
  "supervisor":{
    "pid":11537,
    "pctcpu":0.0,
    "pctmem":0.22,
    "created_at":"2013-03-05 15:21:04 +0100"
  },
  "children":[
    {
      "pid":11540,
      "pctcpu":0.0,
      "pctmem":0.21,
      "created_at":"2013-03-05 15:21:04 +0100"
    },
    {
      "pid":11543,
      "pctcpu":0.0,
      "pctmem":0.21,
      "created_at":"2013-03-05 15:21:04 +0100"
    },
    {
      "pid":11546,
      "pctcpu":0.0,
      "pctmem":0.21,
      "created_at":"2013-03-05 15:21:04 +0100"
    },
    {
      "pid":11549,
      "pctcpu":0.0,
      "pctmem":0.21,
      "created_at":"2013-03-05 15:21:04 +0100"
    }
  ]
}
```

## Stores

sponges can store pids in memory or in redis. Memory is the default store. The
`list` command is not available with the memory store.

To select the redis store, you need to add `nest` to your application's
Gemfile, and do the following.

``` ruby
gem "nest"
```

``` ruby
Sponges.configure do |config|
  config.store         = :redis
end
```

## Roadmap

### Version 1.0

 * Removal of Redis store

## [Changelog](CHANGELOG.md)

## Acknowledgements

sponges would not have been the same without [Jesse
Storimer](https://github.com/jstorimer) and his awesome book about
[Unix](http://workingwithunixprocesses.com/).

## Copyright

MIT. See LICENSE for further details.
