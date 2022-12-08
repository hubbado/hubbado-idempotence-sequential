module Idempotence
  module Sequential
    module Controls
      StreamName = Messaging::Controls::StreamName

      module StreamName
        def self.example(category = nil, id = nil)
          category ||= Category.example
          id ||= Entity.id

          stream_name(category, id)
        end
      end
    end
  end
end
