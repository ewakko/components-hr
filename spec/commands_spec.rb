=begin
require 'components'

RSpec.describe '#do_command' do
  context 'send unknown command' do
    it 'returns error' do
      components = Components.new
      expect(do_command(components, 'not a command')).to eq('Unknown command '\
        "not a command\n")
    end
  end

  context 'send list command' do
    it 'runs list' do
      components = Components.new
      expect(do_command(components, "LIST")).to eq("\n")
    end
  end

  context 'send install command' do
    it 'runs install' do
      components = Components.new
      expect(do_command(components, "INSTALL A")).to eq("Installing A\n")
    end
  end

  context 'send remove command' do
    it 'runs list' do
      components = Components.new
      expect(do_command(components, "REMOVE A")).to eq("A is not' \
        'installed.\n")
    end
  end

  context 'send depends command' do
    it 'runs list' do
      components = Components.new
      expect(do_command(components, "DEPENDS A")).to eq({})
    end
  end

  context 'send support command' do
    it 'runs list' do
      components = Components.new
      expect(do_command(components, "SUPPORTS A")).to eq({})
    end
  end

  context 'send stop command' do
    it 'runs list' do
      components = Components.new
      expect(do_command(components, "STOP")).to eq("\n")
    end
  end
end
=end