module Idempotence
  module Sequential
    module EntitySequences
      def self.included(cls)
        cls.class_exec do
          prepend TransformWriteDupSequences

          extend IgnoreDecreasingSequences
          include RecordSequence
          include MessageProcessed
          include Log::Dependency

          attribute :sequences, Hash, default: -> { {} }
        end
      end

      module RecordSequence
        NoCausationMessageDetailsError = Class.new(RuntimeError)
        DecreasingSequenceError = Class.new(RuntimeError)

        def record_sequence(message)
          causation_message_stream_name = message.metadata.causation_message_stream_name
          raise NoCausationMessageDetailsError unless causation_message_stream_name

          causation_category = Messaging::StreamName.get_category(causation_message_stream_name)
          causation_sequence = message.metadata.causation_message_global_position

          if sequences[causation_category] &.> causation_sequence
            msg = "Causation sequence #{causation_sequence} in #{causation_message_stream_name} " \
                  "is less than the current sequence #{sequences[causation_category]}. " \
                  "Found when processing message #{message.metadata.global_position} in " \
                  "#{message.metadata.stream_name}."

            if self.class.ignore_decreasing_sequences?
              logger.warn(msg, tag: :sequential_idempotence)

              return
            else
              raise DecreasingSequenceError, msg
            end
          end

          sequences[causation_category] = causation_sequence
        end
      end

      module MessageProcessed
        def message_processed?(message)
          message_stream_name = message.metadata.stream_name
          message_category    = Messaging::StreamName.get_category(message_stream_name)

          category_sequence = sequences[message_category]
          return false unless category_sequence

          message_sequence = message.metadata.global_position
          message_sequence <= category_sequence
        end
      end

      module IgnoreDecreasingSequences
        def ignore_decreasing_sequences!
          @ignore_decreasing_sequences = true
        end

        def ignore_decreasing_sequences?
          !!@ignore_decreasing_sequences
        end
      end

      module TransformWriteDupSequences
        def transform_write(data)
          super(data)
          data[:sequences] = data[:sequences].dup
        end
      end
    end
  end
end
