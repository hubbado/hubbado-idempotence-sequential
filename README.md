# Hubbado Idempotence Sequential

Idempotent handling of commands processing using causation message positions for the [Eventide](https://eventide-project.org/) framework

## Sequential idempotence

The sequential idempotence pattern is used to ensure that a message is only processed once. It protects against recycles, that is, when a consumer restarts and sends an already processed message to a handler. It cannot protect against reissues — the same message sent more than once —. For that, you can use the reservation pattern.

To understand and employ sequential idempotence, one must understand a few concepts aside from the most fundamental Eventide concepts:

- Causation message: The message that "caused" a subsequent message. When using Message#follow, the causation message is the message given as an argument.
- Causation message global position: The global position (or sequence) of the causation message. This is included as metadata on a message automatically when it follows another message at message.metadata.causation_message_global_position.
- Causation message stream name: The stream name of the causation message. This is included as metadata on a message automatically when it follows another message at message.metadata.causation_message_stream_name.

When determining whether or not to process a message using sequential idempotence, it is a matter of determining whether or not that message has already been processed. A message has been processed if a message has been written to the entity stream that was caused by that message. In other words, if there exists a message on the entity stream with a causation message global position equal to the considered message's global position, that message has been processed. Because streams are processed in order, it can also be determined that a message has been processed if there exists a message with a causation message global position that is greater than the considered message's global position.

Said more succinctly: If a message's global position is less than or equal to the maximum causation message global position on a stream, that message has been processed and can be ignored.

## A Word of Warning

This library should not be used without fully understanding how it works and why to use it. We firmly recommend that you are fully up to speed on idempotence, and the various ways of implementing it, before attempting to use this library.

Some useful resources for this are:

- [Idempotence: A Primer](https://blog.eventide-project.org/articles/idempotence-primer/) From the Eventide Blog
- [Video: Idempotence (or why our understanding of elevator buttons is incorrect](https://www.youtube.com/watch?v=mVkIC512ihM) From the Utah Microservices Meetup
- [Nobody Needs Reliable Messaging](https://www.infoq.com/articles/no-reliable-messaging/) From InfoQ. Do not be put off by this older article referencing Web Services, it's explanation of idempotence is very good and still relevant - design fundamentals do not date

We also highly recommend the Eventide training course [3-Day Evented Microservices, Autonomous Services, and Event Sourcing Workshop](https://eventide-project.org/#training-section)

### Why you might not want sequential idempotence

- If you are waiting for several events to arrive, before writing a concluded event, then sequential idemtpotence might not be appropiate
- For example, SubprocessACompleted and SubprocessedBCompleted are both needed to write ProcessCompleted, but both events have already arrived
  - When you handle SubprocessACompleted, we can project the stream and write ProcessCompleted
  - When you handle SubprocessedBCompleted there is no sequential idempotence check we can make to see if we have already handled this event
  - Instead you need a check on the entity, `process_completed?`

## Purpose of this library

This library allows you to implement idempotent message processing based on global position.

Require the library:

```ruby
require 'idempotence/sequential'
```


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
  include Idempotence::Sequential::EntitySequences

  entity_name :entity

  apply SomeMessage do |some_message|
    entity.record_sequence(some_message)
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hubbado-idempotence-sequential'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hubbado-idempotence-sequential

## Testing

Fixtures for TestBench are available at https://github.com/hubbado/hubbado-idempotence-sequential-fixtures

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hubbado/hubbado-idempotence-reservation.

## License

The `hubbado-idempotence` library is released under the [MIT License](https://opensource.org/licenses/MIT).
