describe EntryUpdater do
  describe '#run' do
    context 'when the service runs correctly' do
      subject { described_class.run(game: game) }

      it 'updates all of the relevant entries' do

      end
    end

    context 'when the service runs incorrectly' do
      context 'when it has bad parameters' do
        it 'returns an EntryUpdater error' do

        end
      end
    end
  end
end