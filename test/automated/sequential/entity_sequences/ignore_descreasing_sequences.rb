require_relative '../../../test_init'

context "Idempotence" do
  context "Sequential" do
    context "EntitySequences" do
      context 'ignore decreasing sequences' do
        category = Controls::Category.example
        command_category = Controls::Category::Command.example

        event_stream_name   = Controls::StreamName.example(category)
        command_stream_name = Controls::StreamName.example(command_category)

        command_gp = 10
        event_issued_by_command_gp = command_gp + 1
        event_one_issued_by_event_gp = event_issued_by_command_gp + 1
        event_two_issued_by_event_gp = event_one_issued_by_event_gp + 1

        initial_command = Controls::Message::WithoutCausation
          .example(metadata: { stream_name: command_stream_name, global_position: command_gp })

        event_issued_by_command = Controls::Message.example(metadata: {
          stream_name: event_stream_name,
          global_position: event_issued_by_command_gp
        })
        event_one_issued_by_event = Controls::Message.example(metadata: {
          stream_name: event_stream_name,
          global_position: event_one_issued_by_event_gp
        })
        event_two_issued_by_event = Controls::Message.example(metadata: {
          stream_name: event_stream_name,
          global_position: event_two_issued_by_event_gp
        })

        event_issued_by_command.metadata.follow(initial_command.metadata)
        event_one_issued_by_event.metadata.follow(event_issued_by_command.metadata)
        event_two_issued_by_event.metadata.follow(event_one_issued_by_event.metadata)

        entity = Controls::Entity::IgnoreDecreasingSequences.example

        entity.record_sequence(event_issued_by_command)
        entity.record_sequence(event_one_issued_by_event)
        entity.record_sequence(event_two_issued_by_event)

        context 'attempt to record sequence of earlier event' do
          test 'raises decreasing sequence error' do
            refute_raises EntitySequences::RecordSequence::DecreasingSequenceError do
              entity.record_sequence(event_one_issued_by_event)
            end
          end

          test 'does not update sequence' do
            assert entity.sequences == {
              command_category => command_gp,
              category => event_one_issued_by_event_gp
            }
          end
        end
      end
    end
  end
end

