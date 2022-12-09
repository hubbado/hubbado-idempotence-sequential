module Idempotence
  module Sequential
    module Controls
      module Message
        def self.example(id: nil, some_attribute: nil, metadata: {})
          metadata = Controls::Metadata.data.merge(metadata)
          metadata = Messaging::Message::Metadata.build(metadata)

          Messaging::Controls::Message.example(
            id: id,
            some_attribute: some_attribute,
            metadata: metadata
          )
        end

        module WithoutCausation
          def self.example(id: nil, some_attribute: nil, metadata: {})
            metadata = Metadata::WithoutCausation.example(**metadata)

            Messaging::Controls::Message.example(
              id: id,
              some_attribute: some_attribute,
              metadata: metadata
            )
          end
        end
      end
    end
  end
end
