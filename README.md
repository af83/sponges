# sponges

[![Code
Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/AF83/sponges)
[![Gem
Version](https://fury-badge.herokuapp.com/rb/sponges.png)](http://badge.fury.io/rb/sponges)

When I build workers, I want them to be much like an army of spongebobs: always
stressed and eager to work. `sponges` helps you with building this army of sponges,
controling them, and, well, eventually killing them gracefully. Hum, making them
stressed and eager to work would still be your job :)

Basically, sponges is a ruby supervisor that forks processes and controls their
execution and termination. For example, the following will start a supervision
daemon and 8 processes of "a_worker":

```bash
ruby a_worker.rb start -d -s 8
```
If you kill the supervisor, it will cleanly terminate its child processes.

Internally, `sponges` strongly relies on Unix signals.

## Installation

Requires Ruby 1.9.2 or newer.

Install it with rubygems:

    gem install sponges

You may use bundler. In this case, add it to your `Gemfile`:

``` ruby
gem "sponges"
```

and run `bundle install`.

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
  config.size              = 3                    # optionnal, default to cpu's size
  config.daemonize         = true                 # optionnal, default to false
  config.port              = 5032                 # optionnal, default to 5032
  config.env               = :production          # optionnal, default to nil
  # polling on supervisor, this is use to shutdown children in case supervisor
  # receive a `SIGKILL` signal.
  config.polling           = 60                   # optionnal, default to 60
  config.after_fork do
    puts "Execute code when a child process is created"
  end
  config.on_chld do
    puts "Execute code when a child process is killed"
  end
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
timeout can be specify with the `-t` option. When this timeout is hit, the
process is killed.

Increment worker's pool size :
``` bash
ruby example.rb increment # will add a worker from the pool.
```

Decrement worker's pool size :
``` bash
ruby example.rb decrement # will remove a worker from the pool.
```

## HTTP supervision

sponges provides an HTTP interface to supervise the pool's activity, and to expose
pids. HTTP supervision can be enabled in the configuration:


``` ruby
Sponges.configure do |config|
  config.port = 3333
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

## [Changelog](CHANGELOG.md)

## Acknowledgements

sponges would not have been the same without [Jesse
Storimer](https://github.com/jstorimer) and his awesome book about
[Unix](http://workingwithunixprocesses.com/).

## Copyright

MIT. See LICENSE for further details.
