module Idempotence
  module Sequential
    module Controls
      Metadata = Messaging::Controls::Metadata

      module Metadata
        module WithoutCausation
          def self.example(**params)
            data = self.data.merge(params)
            Messaging::Message::Metadata.build(data)
          end

          def self.data
            Metadata.data.except(*Messaging::Message::Metadata.workflow_attribute_names)
          end
        end
      end
    end
  end
end
