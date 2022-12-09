require_relative '../../../test_init'

context "Idempotence" do
  context "Sequential" do
    context "EntitySequencies" do
      context "#message_processed?" do
        global_position = Controls::Metadata.global_position

        prev_event  = Controls::Message.example(metadata: { global_position: global_position })
        command     = Controls::Message.example(metadata: { global_position: global_position + 10 })
        event       = Controls::Message.example(metadata: { global_position: global_position + 11 })
        event.metadata.follow(command.metadata)

        next_cmd    = Controls::Message.example(metadata: { global_position: global_position + 20 })
        next_event  = Controls::Message.example(metadata: { global_position: global_position + 21 })
        next_event.metadata.follow(next_cmd.metadata)

        context "when message does not processed yet" do
          entity = Controls::Entity.example

          test "returns false" do
            refute entity.message_processed?(command)
          end
        end

        context 'Processing command' do
          entity = Controls::Entity.example
          entity.record_sequence(prev_event)

          test "command does not processed yet" do
            refute entity.message_processed?(command)
          end

          entity.record_sequence(event)

          test "command processed" do
            assert entity.message_processed?(command)
          end
        end

        context 'It processed even the next command' do
          entity = Controls::Entity.example
          entity.record_sequence(next_event)

          test "command processed" do
            assert entity.message_processed?(command)
          end
        end
      end
    end
  end
end
