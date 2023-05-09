require_relative '../../../test_init'

context "Idempotence" do
  context "Sequential" do
    context "EntitySequences" do
      context '#record_sequence' do
        category = Controls::Category.example
        command_category = Controls::Category::Command.example

        event_stream_name   = Controls::StreamName.example(category)
        command_stream_name = Controls::StreamName.example(command_category)

        command_gp = 10
        event_issued_by_command_gp = command_gp + 1
        event_issued_by_event_gp = event_issued_by_command_gp + 1

        initial_command = Controls::Message::WithoutCausation
          .example(metadata: { stream_name: command_stream_name, global_position: command_gp })

        event_issued_by_command = Controls::Message.example(metadata: {
          stream_name: event_stream_name,
          global_position: event_issued_by_command_gp
        })
        event_issued_by_event = Controls::Message.example(metadata: {
          stream_name: event_stream_name,
          global_position: event_issued_by_event_gp
        })

        event_issued_by_command.metadata.follow(initial_command.metadata)
        event_issued_by_event.metadata.follow(event_issued_by_command.metadata)

        entity = Controls::Entity.example

        context 'just initiated instance' do
          test 'has no sequences yet' do
            assert entity.sequences == {}
          end
        end

        context 'initial_command - message has no sequences' do
          test 'raises no causation details error' do
            assert_raises EntitySequences::RecordSequence::NoCausationMessageDetailsError do
              entity.record_sequence(initial_command)
            end
          end
        end

        context 'event issued by command' do
          entity.record_sequence(event_issued_by_command)

          test 'records sequence for command category' do
            assert entity.sequences == { command_category => command_gp }
          end
        end

        context 'event issued by event' do
          entity.record_sequence(event_issued_by_event)

          test 'records sequence for command category' do
            assert entity.sequences == {
              command_category => command_gp,
              category => event_issued_by_command_gp
            }
          end
        end
      end
    end
  end
end
