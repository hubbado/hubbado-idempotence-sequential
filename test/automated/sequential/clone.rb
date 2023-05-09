require_relative '../../test_init'

context "Idempotence" do
  context "Sequential" do
    context "#clone" do
      command_gp = Controls::Metadata.global_position

      command_category = Controls::Category::Command.example
      command_stream_name = Controls::StreamName.example(command_category)

      command = Controls::Message.example(metadata: {
        stream_name: command_stream_name,
        global_position: command_gp
      })

      event = Controls::Message.example(metadata: { global_position: command_gp + 1 })
      event.metadata.follow(command.metadata)

      entity = Controls::Entity.example
      entity_clone = entity.clone

      context "before record_sequence" do
        test "sequences are empty for both entity and cloned entity" do
          assert entity.sequences.empty?
          assert entity_clone.sequences.empty?
        end
      end

      context 'Processing event' do
        entity.record_sequence(event)

        test "updates entity's sequences" do
          assert entity.sequences == { command_category => command_gp }
        end

        test "keeps unchanged cloned entity sequences" do
          assert entity_clone.sequences.empty?
        end
      end
    end
  end
end
