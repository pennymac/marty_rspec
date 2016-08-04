# Marty RSpec

is a set of helper methods for integration/feature testing for the [Marty](https://github.com/arman000/marty) framework. In particular, it primarily maps javascript functions to provide Capybara-like behavior for Netzke/ExtJS components.

## Usage

On the macro-level, Marty RSpec functionality can be broken up into 6 pieces.

1. General Utility functions

    examples include log_in, press(button)

2. Wait functions

    because netzke/extjs requires execute_scripts all over the place, and because this causes intermittent timing failures

3. Netzke Component Utility functions

    first, call `c = netzke_find(name, component_type)`

    note that this doesn't actually 'find' the component a la Capybara. Instead, it prepares the javascript to be used for the particular component helper method. So, in order for any javascript to run, you would need to call (on a grid), for example, `c.row_count`

  1. component_type = 'gridpanel'

        this is the default

  2. component_type = 'combobox'

4. Custom Capybara selectors

    for using Capybara find on commonly used netzke/extjs DOM items

5. Custom RSpec Matchers

6. RSpec-by formatter

    this is actually an external gem that provides verbose RSpec formatter with benchmarking capabilities. You can wrap bits of longer feature tests in a block. RSpec will print the messages out with how many seconds each block took to complete.

    ```ruby
    # the beginning of your awesome test
    by 'your output message here' do
      # some test stuff here
    end

    and_by 'your next step' do
      # some other test stuff here
    end
    # the rest of your awesome test
    ```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'marty_rspec'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install marty_rspec

Add the following to your spec_helper.rb (you may want to scope to js tests only):

```ruby
require 'marty_rspec'

# ...

RSpec.configure do |config|
  config.include MartyRSpec::Util #, js:true
  # ...
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sleepn247/marty_rspec.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
