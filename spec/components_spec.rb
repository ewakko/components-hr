require 'components'

RSpec.describe Components, '#LIST' do
  context 'with no components installed' do
    it 'returns newline' do
      components = Components.new
      expect(components.list).to eq("\n")
    end
  end

  context 'with three components installed' do
    it 'show alpha sorted list of installed components in ascending order' do
      components = Components.new
      components.install('C')
      components.install('A')
      components.install('B')
      expect(components.list).to eq("A\nB\nC\n")
    end
  end

  context 'with two components installed and one deleted' do
    it 'show alpha sorted list of installed components in ascending order' do
      components = Components.new
      components.install('C')
      components.install('A')
      components.install('B')
      components.remove('B')
      expect(components.list).to eq("A\nC\n")
    end
  end  
end

RSpec.describe Components, '#INSTALL' do
  context 'with no components to install' do
    it 'returns newline' do
      components = Components.new
      expect(components.list).to eq("\n")
      expect(components.installed).to eq([])
    end
  end

  context 'with three different components' do
    it 'installs three different components' do
      components = Components.new
      expect(components.install('C')).to eq("Installing C\n")
      expect(components.installed).to eq(['C'])
      expect(components.install('A')).to eq("Installing A\n")
      expect(components.installed).to eq(%w(C A))
      expect(components.install('B')).to eq("Installing B\n")
      expect(components.installed).to eq(%w(C A B))
    end
  end

  context 'with two same components' do
    it 'gives message component is already installed' do
      components = Components.new
      expect(components.install('C')).to eq("Installing C\n")
      expect(components.installed).to eq(['C'])
      expect(components.install('C')).to eq("C already installed.\n")
      expect(components.installed).to eq(['C'])
    end
  end

  context 'with a dependency' do
    it 'installs component and one dependency' do
      components = Components.new
      components.depends(%w(A B))
      expect(components.install('A')).to eq("Installing B\nInstalling A\n")
      expect(components.installed).to eq(%w(B A))
    end
  end

  context 'with a dependency' do
    it 'installs component and two dependencies' do
      components = Components.new
      components.depends(%w(A B C))
      expect(components.install('A')).to eq("Installing B\nInstalling "\
        "C\nInstalling A\n")
      expect(components.installed).to eq(%w(B C A))
    end
  end

  context 'with supported component' do
    it 'installs component and one supporting component' do
      components = Components.new
      components.supports(%w(A B))
      expect(components.install('B')).to eq("Installing A\nInstalling B\n")
    end
  end

  context 'with supported components' do
    it 'installs component two supporting components' do
      components = Components.new
      components.supports(%w(A B C))
      expect(components.install('C')).to eq("Installing A\nInstalling "\
        "B\nInstalling C\n")
      expect(components.installed).to eq(%w(A B C))
    end
  end
end

RSpec.describe Components, '#REMOVE' do
  context 'with no components given' do
    it 'returns newline' do
      components = Components.new
      expect(components.list).to eq("\n")
      expect(components.installed).to eq([])
    end
  end

  context 'with three different components' do
    it 'removes three different components' do
      components = Components.new
      components.install('C')
      components.install('A')
      components.install('B')
      expect(components.remove('C')).to eq("Removing C\n")
      expect(components.installed).to eq(%w(A B))
      expect(components.remove('A')).to eq("Removing A\n")
      expect(components.installed).to eq(['B'])
      expect(components.remove('B')).to eq("Removing B\n")
      expect(components.installed).to eq([])
    end
  end

  context 'with a component that is not installed' do
    it 'gives message component is not installed' do
      components = Components.new
      expect(components.remove('C')).to eq("C is not installed.\n")
      expect(components.installed).to eq([])
    end
  end

  context 'with component that is a dependency' do
    it 'gives message component is still need and not removed' do
      components = Components.new
      components.install('C')
      components.install('A')
      components.install('B')
      expect(components.installed).to eq(%w(C A B))
      components.depends(%w(A B C))
      expect(components.dependencies).to eq('A' => %w(B C))
      expect(components.remove('C')).to eq("C is still needed.\n")
      expect(components.installed).to eq(%w(C A B))
    end
  end
end

RSpec.describe Components, '#DEPENDS' do
  context 'with no arguments' do
    it 'does not add a dependency' do
      components = Components.new
      expect(components.depends([])).to eq({})
      expect(components.dependencies).to eq({})
    end
  end

  context 'with one component' do
    it 'does not add a dependency' do
      components = Components.new
      expect(components.depends(['A'])).to eq({})
      expect(components.dependencies).to eq({})
    end
  end

  context 'with two different components' do
    it 'a dependency to a compontent is added' do
      components = Components.new
      expect(components.depends(%w(A B))).to eq('A' => ['B'])
      expect(components.dependencies).to eq('A' => ['B'])
    end
  end

  context 'with three different components' do
    it 'two dependencies to a component is added' do
      components = Components.new
      expect(components.depends(%w(A B C))).to eq('A' => %w(B C))
      expect(components.dependencies).to eq('A' => %w(B C))
    end
  end

  context 'attempt to add circular dependencies' do
    it 'gives message dependency is invalid' do
      components = Components.new
      components.depends(%w(A B C))
      expect(components.depends(%w(B A))).to eq("B depends on A. Ignoring "\
        "command.\n")
      expect(components.dependencies).to eq('A' => %w(B C))
    end
  end
end

RSpec.describe Components, '#SUPPORTS' do
  context 'with no arguments' do
    it 'does not add a dependency' do
      components = Components.new
      expect(components.supports([])).to eq({})
      expect(components.dependencies).to eq({})
    end
  end

  context 'with one component' do
    it 'does not add a dependency' do
      components = Components.new
      expect(components.supports(['A'])).to eq({})
      expect(components.dependencies).to eq({})
    end
  end

  context 'with two different components' do
    it 'a dependency to a component is added' do
      components = Components.new
      expect(components.supports(%w(A B))).to eq('B' => ['A'])
      expect(components.dependencies).to eq('B' => ['A'])
    end
  end

  context 'with three different components' do
    it 'two dependencies to a component is added' do
      components = Components.new
      expect(components.supports(%w(A B C))).to eq('C' => %w(A B))
      expect(components.dependencies).to eq('C' => %w(A B))
    end
  end
end

RSpec.describe Components, '#has_dependency' do
  context 'with no dependencies' do
    it 'returns empty array' do
      components = Components.new
      expect(components.has_dependency('A')).to eq([])
    end
  end

  context 'with one dependency' do
    it 'returns array of dependency' do
      components = Components.new
      components.depends(%w(A B))
      expect(components.has_dependency('A')).to eq(['B'])
    end
  end

  context 'with two dependency' do
    it 'returns array of dependencies' do
      components = Components.new
      components.depends(%w(A B C))
      expect(components.has_dependency('A')).to eq(%w(B C))
    end
  end
end

RSpec.describe Components, '#has_dependents' do
  context 'with no dependents' do
    it 'returns empty array' do
      components = Components.new
      expect(components.has_dependents('A')).to eq([])
    end
  end

  context 'with one dependent' do
    it 'returns dependent' do
      components = Components.new
      components.depends(%w(A B))
      expect(components.dependencies).to eq('A' => ['B'])
      expect(components.has_dependents('B')).to eq(['A'])
    end
  end

  context 'with two dependents' do
    it 'returns array of dependents' do
      components = Components.new
      components.depends(%w(A B C))
      components.depends(%w(D B E))
      expect(components.dependencies).to eq('A' => %w(B C), 'D' => %w(B E))
      expect(components.has_dependents('B')).to eq(%w(A D))
    end
  end
end

RSpec.describe Components, '#install_dependency' do
  context 'with no dependencies' do
    it 'returns empty string' do
      components = Components.new
      expect(components.install_dependency('A')).to eq('')
    end
  end

  context 'with one dependencies' do
    it 'returns install message' do
      components = Components.new
      components.depends(%w(A B))
      expect(components.install_dependency('A')).to eq("Installing B\n")
    end
  end

  context 'with two dependencies' do
    it 'returns install messages for both dependencies installed' do
      components = Components.new
      components.depends(%w(A B C))
      expect(components.install_dependency('A')).to eq("Installing B\nInstalling C\n")
    end
  end
end

RSpec.describe Components, '#remove_dependency' do
  context 'with no dependencies' do
    it 'returns empty string' do
      components = Components.new
      components.install('A')
      expect(components.remove_dependency('A')).to eq('')
    end
  end

  context 'with one dependencies' do
    it 'returns install message' do
      components = Components.new
      components.install('A')
      components.install('B')
      components.depends(%w(A B))
      expect(components.remove_dependency('A')).to eq("Removing B\n")
    end
  end

  context 'with two dependencies' do
    it 'returns install messages for both dependencies installed' do
      components = Components.new
      components.install('C')
      components.install('A')
      components.install('B')
      components.depends(%w(A B C))
      expect(components.remove_dependency('A')).to eq("Removing B\Removing C\n")
    end
  end
end
