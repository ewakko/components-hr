# keep track installed components and dependencies
class Components
  attr_reader :installed, :dependencies

  def initialize
    @installed = []
    @dependencies = {}
  end

  def stop
    exit!
  end

  def list
    if @installed.empty?
      "\n"
    else
      sorted_list = @installed.sort
      sorted_list.join("\n") + "\n"
    end
  end

  def install(arg)
    message = install_dependency(arg)
    if @installed.include?(arg)
      "#{arg} already installed.\n"
    else
      @installed.push(arg)
      return "Installing #{arg}\n" if message.nil?
      return message.concat("Installing #{arg}\n")
    end
  end

  def install_dependency(arg)
    message = ''
    install_depends = has_dependency(arg)
    return message if install_depends.empty?
    install_depends.each do |d|
      message.concat(install(d))
    end
    message
  end

  def remove(arg)
    message = remove_dependency(arg)
    if @installed.include?(arg)
      dependency = has_dependents(arg)
      if !dependency.empty?
        "#{arg} is still needed.\n"
      else
        @installed.delete(arg)
        return message.concat("Removing #{arg}\n")
      end
    else
      "#{arg} is not installed.\n"
    end
  end

  def remove_dependency(arg)
    message = ''
    arg_arr = [arg]
    remove_depends = has_dependency(arg)
    return message if remove_depends.empty?
    remove_depends.each do |d|
        puts "My arg is #{arg_arr}, my dependents are #{has_dependents(d)}"
      if has_dependents(d) == arg_arr
        @installed.delete(arg)
        message.concat("Removing #{arg}\n")
      end
    end
    message
  end 

  def depends(arg)
    return @dependencies unless arg.length > 1
    key = arg[0]
    arg.shift
    arg.each do |d|
      return "#{key} depends on #{d}. Ignoring command.\n" unless has_dependency(d).empty?
    end
    new_dependency = { key => arg }
    @dependencies.merge!(new_dependency)
  end

  def supports(arg)
    return @dependencies unless arg.length > 1
    key = arg[-1]
    arg.pop
    new_dependency = { key => arg }
    @dependencies.merge!(new_dependency)
  end

  def has_dependency(arg)
    return [] unless @dependencies.key?(arg)
    @dependencies[arg]
  end

  def has_dependents(arg)
    list = []
    @dependencies.each do |k, v|
      list.push(k) if v.include?(arg)
    end
    list
  end
end

COMMANDS = %w(DEPENDS SUPPORTS INSTALL REMOVE LIST STOP).freeze

def do_command(obj, input)
  line = input.split(/\s+/)
  return "Unknown command #{input}\n" unless COMMANDS.include?(line[0])
  command = line[0].downcase
  if line.length == 1
    puts input
    puts obj.send(command.to_sym)
  elsif line.length == 2
    puts input
    puts obj.send(command.to_sym, line[1])
  elsif line.length > 2
    line.shift
    obj.send(command.to_sym, line)
    puts input
  end
end

components = Components.new
loop do
  input = gets.chomp
  do_command(components, input)
  break if input.chomp! == 'STOP'
end
