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

### Consumer groups

The check assumes that the messages of a source category reach an entity in increasing global position. The sequence is recorded for each causation *category*, so a message with a lower position than the recorded one is taken as already processed.

One consumer for a category gives that order. A consumer group gives it only within each member's part of the category. Message DB assigns a stream to a group member by its cardinal ID, the part of the stream's ID before the first `+`.

So the check is not safe when all of these are true:

- An entity's stream takes messages from several source streams of one category
- Those source streams have different cardinal IDs
- The consumer of that category runs in a consumer group

For example, a consumer of the `invoice` category writes each supplier's invoices to `ledger-{supplier_id}`, and runs as a group of two:

- Member 0 handles `invoice-A` at global position 1000, and writes to `ledger-123`. The ledger records 1000 for the `invoice` category
- Member 1 is behind. It then handles `invoice-B` at global position 900, for the same ledger
- `message_processed?` returns true, because 900 is lower than 1000, and the handler ignores a message that was never processed

Nothing is raised. `DecreasingSequenceError` comes from `record_sequence`, which only runs when an event is projected, and here no event is written.

The check is safe in a consumer group when every source stream of an entity has the same cardinal ID as each other. A compound ID that starts with the entity's ID gives this, such as `ledgerEntry-{supplier_id}+{entry_id}` for `ledger-{supplier_id}`. The risk is a category whose stream IDs you do not choose, which is usually another component's.

If your handler fans in from such a category, some options are:

- Run the consumer of that category as one consumer, with no group
- Partition by the target, not the source: give each consumer a `condition` on the ID of the entity that the message is for, in place of `group_size` and `group_member`. Every message for one entity then goes through one consumer, in order. This needs Message DB's `message_store.sql_condition` setting
- Use the reservation pattern for that handler. It does not depend on order

Recording a sequence for each group member, in place of each category, is safe only while the group does not change. When the group size changes, streams move between members, and a member's sequence no longer describes the streams that it now reads.

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

```shell
bundle
```

Or install it yourself as:

```shell
gem install hubbado-idempotence-sequential
```

## Ignore Decreasing Sequences

By default the library will raise `DecreasingSequenceError`  when the causation position of the message passed to `record_sequence` is lower than the current sequence for the causation category.

However, if you know you have a malformed stream, where the causation sequences do not increase linearly, you can disable the execption raising and log a warning instead by adding this line to your entity:

```ruby
ignore_decreasing_sequences!
```

Use this feature with extreme cauation!

## Testing

Fixtures for TestBench are available at https://github.com/hubbado/hubbado-idempotence-sequential-fixtures

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hubbado/hubbado-idempotence-reservation.

## License

The `hubbado-idempotence` library is released under the [MIT License](https://opensource.org/licenses/MIT).
