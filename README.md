# sponges

When I build workers, I want them to be like an army of spongebobs, always
stressed and eager to work. `sponges` helps you build this army of sponges, to
control them, and, well, to kill them gracefully. Making them stressed and eager
to work is your job. :)

Internally, `sponges` strongly relies on Unix signals.

## Is it any good?

[Yes.](http://news.ycombinator.com/item?id=3067434)

## Production ready ?

Not yet, but soon.

## Installation

Ruby 1.9.3 and Redis are required.

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
  def run
    # Trap the HUP signal, set a boolean to true.
    trap(:HUP) {
      Sponges.logger.info "HUP signal trapped, clean stop."
      @hup = true
    }
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
  config.worker        = Worker.new
  config.worker_name   = "bob"
  config.worker_method = :run
  config.logger        = MyCustomLogger.new
end

Sponges.start
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
ruby example.rb start -d -s 8
```

Stop workers with a `QUIT` signal :
``` bash
ruby example.rb stop
```

Stop workers with a `HUP` signal :
``` bash
ruby example.rb stop -g
```
In this case, you will have to trap the `HUP` signal, and handle a clean stop
from each workers. The point is to wait for a task to be done before quitting.

Show a list of workers and their children.
``` bash
ruby example.rb list
```

## TODO

* Specing.
* Implement a restart command.
* make compatible with 1.9.2
* Increment / decrement workers pool size with `TTIN` and `TTOUT`.

## Copyright

MIT. See LICENSE for further details.
