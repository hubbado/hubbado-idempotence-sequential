module Idempotence
  module Sequential
    module EntitySequences
      def self.included(cls)
        cls.class_exec do
          include RecordSequence
          include MessageProcessed

          include Schema::DataStructure

          attribute :sequences, Hash, default: {}
        end
      end

      module RecordSequence
        class NoCausationMessageDetailsError < RuntimeError; end

        def record_sequence(message)
          causation_message_stream_name = message.metadata.causation_message_stream_name
          raise NoCausationMessageDetailsError unless causation_message_stream_name

          causation_category = Messaging::StreamName.get_category(causation_message_stream_name)
          causation_sequence = message.metadata.causation_message_global_position

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
    end
  end
end
