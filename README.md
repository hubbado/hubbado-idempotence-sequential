# Hubbado Idempotence Sequential

Idempotent handling of commands processing using causation message positions for the [Eventide](https://eventide-project.org/) framework

## Sequentail Idempotence handling


## A Word of Warning

This library should not be used without fully understanding how it works and why to use it. We firmly recommend that you are fully up to speed on idempotence, and the various ways of implementing it, before attempting to use this library.

Some useful resources for this are:

- [Idempotence: A Primer](https://blog.eventide-project.org/articles/idempotence-primer/) From the Eventide Blog
- [Video: Idempotence (or why our understanding of elevator buttons is incorrect](https://www.youtube.com/watch?v=mVkIC512ihM) From the Utah Microservices Meetup
- [Nobody Needs Reliable Messaging](https://www.infoq.com/articles/no-reliable-messaging/) From InfoQ. Do not be put off by this older article referencing Web Services, it's explanation of idempotence is very good and still relevant - design fundamentals do not date

We also highly recommend the Eventide training course [3-Day Evented Microservices, Autonomous Services, and Event Sourcing Workshop](https://eventide-project.org/#training-section)

### Why you might not want sequential idempotence

## Purpose of this library

This library allows you to implement idempotent message processing based on global position.

In your handler handler you check to see if the message has already been processed:

```ruby
class SomeHandler
  handle SomeMessage do |some_message|
    entity = store.fetch(entity_id)

    if entity.message_processed?(some_message)
      # Log something
      return
    end
  end
end
```

In your projection you need to add the following:

```ruby
class Projection
  include EntitySequences

  entity_name :entity

  apply SomeMessage do |some_message|
    entity.record_sequence(some_message)
  end
end
```

## Eventide Account Component Example

The Eventide [AccountComponent](https://github.com/eventide-examples/account-component) is an example used as training material on the excellent Eventide training course "3-Day Evented Microservices, Autonomous Services, and Event Sourcing Workshop" which you can read about here: https://eventide-project.org/#training-section

This documentation will not explain the Account Component, and we heavily recommend that you are able to understand all the working parts of that component before attempting to use this library.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hubbado-idempotence-sequential'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hubbado-idempotence-sequential

## Usage


## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hubbado/hubbado-idempotence-reservation.

## License

The `hubbado-idempotence` library is released under the [MIT License](https://opensource.org/licenses/MIT).
