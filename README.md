# SeaShanty

SeaShanty is a tiny library that records HTTP interactions and replays responses for requests it has seen before.

The primary purpose is to speed up your test suite regardless of which test framework used by not relying on the network.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sea_shanty'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sea_shanty

## Usage

The following is a minimal example of how to use SeaShanty.

```ruby
require "rubygems"
require "sea_shanty"
require "minitest"
require "faraday"

SeaShanty.configure do |config|
  config.storage_dir = "fixtures/sea_shanty"
end
SeaShanty.intercept_from(:faraday)

class TestSeaShanty < Minitest::Test
  def test_fetch
    response = Faraday.get("https://example.com")
    assert_equal(200, response.status)
  end
end
```

The first time the test above is run, the request is sent as normal, because SeaShanty hasn't seen it before, and the request and response is stored, before the response is returned. On subsequent runs of the test, no requests will be sent over the network. Instead the response is loaded from the storage directory and returned.

**CAUTION!**

To prevent storing sensitive information like `Authorization` headers or credentials in the request body, use the `Configuration#request_body_filter` and `Configuration#request_headers_filter` described in the [Configuration](#configuration) section.

### Hooking into an HTTP library

The following call hooks into Faraday.

```ruby
SeaShanty.intercept_from :faraday
```

Any HTTP requests made before the call to `SeaShanty.intercept_from` will not be handled by SeaShanty.

### Configuration

* `storage_dir`
  * The storage directory for the requests and responses.
  * A string that can either be an absolute path or a path relative to `Dir.pwd`
* `bypass`
  * Tells if SeaShanty should be bypassed
  * A boolean. If it is true, SeaShanty will not look up or store responses, but just pass the request to the HTTP library
  * This can be overwritten by setting the environment variable `SEA_SHANTY_BYPASS`
* `readonly`
  * Tells if SeaShanty should allow the HTTP library to send the request over the network
  * A boolean. If it is true, no requests are sent over the network. Instead SeaShanty will raise a `SeaShanty::UnknownRequest` error, if the request has not been seen before
  * This can be overwritten by setting the environment variable `SEA_SHANTY_READONLY`
* `generic_responses`
  * Tells SeaShanty to return generic responses whenever the request url matches one of the keys
  * A hash where the keys are `Regexp`s and the values are strings with the path to a file with a stored response relative to the `storage_dir`
  * The request url is matched against the `Regexp`s, and the first match will make SeaShanty return the response stored in the file with the path in the hash value
* `request_body_filter`
  * Is applied to the request body before figuring out if the request has been seen before, and before the request and response is saved
  * A callable object with an arity of 1.
  * Is called with the raw request body
  * Must return the filtered body
* `request_headers_filter`
  * Is applied to the request headers before the request and response is saved
  * A callable object with an arity of 2
  * Is called once with each header name and value
  * Must return the filtered value


### Supported HTTP libraries

In the current version [Faraday](https://lostisland.github.io/faraday/) is the only library SeaShanty supports.

## Alternatives

* [VCR](https://github.com/vcr/vcr)
* [Ephemeral Response](https://github.com/sandro/ephemeral_response)
* [Net::HTTP Spy](https://github.com/martinbtt/net-http-spy)
* [NetRecorder](https://github.com/chrisyoung/netrecorder)
* [Puffing Billy](https://github.com/oesmith/puffing-billy)
* [REST-assured](https://github.com/artemave/REST-assured)
* [Stale Fish](https://github.com/jsmestad/stale_fish)
* [WebFixtures](https://github.com/trydionel/web_fixtures)

## TODO

- [ ] Add hooks for more HTTP libraries
- [ ] Add optional response body compression to reduce storage requirements
- [ ] Enable hooking into multiple HTTP libraries at the same time
- [ ] Make it possible to remove a hook at runtime
- [ ] Make it possible to overwrite stored requests and responses

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Releasing a new version

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

The SeaShanty versioning scheme follows [SemVer 2.0.0](https://semver.org/spec/v2.0.0.html).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rbgrouleff/sea_shanty. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rbgrouleff/sea_shanty/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SeaShanty project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rbgrouleff/sea_shanty/blob/main/CODE_OF_CONDUCT.md).
