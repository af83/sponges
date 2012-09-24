# sponges

When I build some worker, I want them to be like an army of spongebob, always
stressed and eager to work. sponges helps you to build this army of sponge, to
control them, and, well, kill them gracefully.

## Installation

Ruby 1.9.3 is required.

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
    puts Process.pid
    sleep 1
    run
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

## TODO

* Specing
* Storing pids
* Bin

## Copyright

MIT. See LICENSE for further details.
