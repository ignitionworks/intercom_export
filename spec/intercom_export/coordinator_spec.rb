require 'spec_helper'
require 'intercom_export/coordinator'

require 'intercom'
require 'zendesk_api'

RSpec.describe IntercomExport::Coordinator do
  let(:source) { ['a thing'] }
  let(:splitter) { double('splitter') }
  let(:finder) { double('finder') }
  let(:differ) { double('differ') }
  let(:executor) { double('executor') }

  describe '#run' do
    let(:expected_parts) { [double('part1', id: 1), double('part2', id: 2)] }
    let(:expected_find_for_part2) { double('part2-found1') }
    let(:expected_commands_for_part1) { double('part1-diffs') }
    let(:expected_commands_for_part2) { double('part2-diffs') }

    before do
      allow(splitter).to receive(:split).with('a thing').and_return(expected_parts)

      allow(finder).to receive(:find).with(expected_parts[0]).and_return(nil)
      allow(finder).to receive(:find).with(expected_parts[1]).and_return(expected_find_for_part2)

      allow(differ).to receive(:diff).with(
        expected_parts[0], nil
      ).and_return(expected_commands_for_part1)

      allow(differ).to receive(:diff).with(
        expected_parts[1], expected_find_for_part2
      ).and_return(expected_commands_for_part2)
    end

    subject do
      IntercomExport::Coordinator.new(
        source: source, splitter: splitter, finder: finder, differ: differ, executor: executor
      )
    end

    it 'sends the commands to the correct executor' do
      expect(executor).to receive(:call).with(expected_commands_for_part1).ordered
      expect(executor).to receive(:call).with(expected_commands_for_part2).ordered

      subject.run
    end

    context 'with duplicate items' do
      let(:source) { ['a thing', 'a similar thing'] }

      before do
        allow(splitter).to receive(:split).with('a similar thing').and_return(expected_parts)
      end

      it 'does minimum number of commands' do
        expect(executor).to receive(:call).with(expected_commands_for_part1).ordered
        expect(executor).to receive(:call).with(expected_commands_for_part2).ordered

        subject.run
      end
    end
  end
end
