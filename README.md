# sponges

When I build some worker, I want them to be like an army of spongebob, always
stressed and eager to work. sponges helps you to build this army of sponge, to
control them, and, well, kill them gracefully.

/!\ sponges is still under development.

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
    trap(:HUP) {
      Sponges.logger.info "HUP signal trapped, clean stop."
      @hup = true
    }
    Sponges.logger.info Process.pid
    if @hup
      Sponges.logger.info "HUP signal trapped, shutdown..."
      exit 0
    else
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

Start 8 instances of workers and daemonize them:
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
In this case, you gonna have to trap the `HUP` signal, and handle a clean stop
from each workers. The point is to wait from a task to be done before quitting.

Show a list of workers and their children.
``` bash
ruby example.rb list
```

## TODO

* Specing
* Bin

## Copyright

MIT. See LICENSE for further details.
