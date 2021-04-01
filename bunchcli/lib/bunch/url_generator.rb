# frozen_string_literal: true

require 'readline'
require 'cgi'

# String additions
class String
  def text?
    res = `file "#{self}"`
    res =~ /text/
  end
end

# misc utils
module Util
  def bundle_id(app)
    shortname = app.sub(/\.app$/, '')
    apps = `mdfind -onlyin /Applications -onlyin /Applications/Setapp -onlyin /Applications/Utilities -onlyin ~/Applications -onlyin /Developer/Applications 'kMDItemKind==Application'`

    foundapp = apps.split(/\n/).select! { |line| line.chomp =~ /#{shortname}\.app$/i }[0]

    if foundapp
      bid = `mdls -name kMDItemCFBundleIdentifier -r "#{foundapp}"`.chomp
    else
      # warn "Could not locate bundle id for #{shortname}, using provided app name"
      bid = app
    end
    bid
  end
end

# CLI Prompt utilities
module Prompt
  def choose_number(query = '->', max)
    stty_save = `stty -g`.chomp
    sel = nil
    begin
      while !sel =~ /^\d+$/ || sel.to_i <= 0 || sel.to_i > max
        sel = Readline.readline("#{query}", true)
        return nil if sel =~ /^\s*$/
      end
    rescue Interrupt
      system('stty', stty_save) # Restore
      exit
    end
    sel ? sel.to_i : nil
  end

  def get_line(query = '->')
    stty_save = `stty -g`.chomp
    begin
      line = Readline.readline("#{query}: ", true)
    rescue Interrupt
      system('stty', stty_save) # Restore
      exit
    end
    line.chomp
  end

  def get_text(query = 'Enter text, ^d to end')
    stty_save = `stty -g`.chomp
    lines = []
    puts query
    begin
      while (line = Readline.readline)
        lines << line
      end
    rescue Interrupt
      system('stty', stty_save) # Restore
      exit
    end
    lines.join("\n").chomp
  end

  def url_encode_text
    text = get_text
    puts
    CGI.escape(text)
  end
end

# Single menu item
class MenuItem
  attr_accessor :id, :title, :value

  def initialize(id, title, value)
    @id = id
    @title = title
    @value = value
  end
end

# Collection of menu items
class Menu
  include Prompt
  attr_accessor :items

  def initialize(items)
    @items = items
  end

  def choose(query = 'Select an item')
    throw 'No items initialized' if @items.nil?
    STDERR.puts
    STDERR.puts "┌#{("─" * 74)}┐"
    intpad = Math::log10(@items.length).to_i + 1
    @items.each_with_index do |item, idx|
      idxstr = "%#{intpad}d" % (idx + 1)
      line = "#{idxstr}: #{item.title}"
      pad = 74 - line.length
      STDERR.puts "│#{line}#{" " * pad}│"
    end
    STDERR.puts "└┤ #{query} ├#{"─" * (70 - query.length)}┘"
    sel = choose_number("> ", @items.length)
    sel ? @items[sel.to_i - 1] : nil
  end
end

class Snippet
  attr_accessor :fragments, :contents

  def initialize(file)
    if File.exist?(File.expand_path(file))
      @contents = IO.read(File.expand_path(file))
      @fragments = fragments
    else
      throw ('Tried to initialize snippet with invalid file')
    end
  end

  def fragments
    rx = /(?i-m)(?:[-#]+)\[([\s\S]*?)\][-# ]*\n([\s\S]*?)(?=\n(?:-+\[|#+\[|$))/
    matches = @contents.scan(rx)
    fragments = {}
    matches.each do |m|
      key = m[0]
      value = m[1]

      fragments[key] = value
    end
    fragments
  end

  def choose_fragment
    unless @fragments.empty?
      items = []
      @fragments.each { |k, v| items << MenuItem.new(k, k, v) }
      menu = Menu.new(items)
      return menu.choose('Select fragment')
    end
    nil
  end
end

# File search functions
class BunchFinder
  include Prompt
  attr_accessor :config_dir

  def initialize
    config_dir = `defaults read com.brettterpstra.bunch configDir`.strip
    config_dir = File.expand_path(config_dir)
    if File.directory?(config_dir)
      @config_dir = config_dir
    else
      throw 'Unable to retrieve Bunches Folder'
    end
  end

  def files_to_items(dir, pattern)
    Dir.chdir(dir)
    items = []
    Dir.glob(pattern) do |f|
      if f.text?
        filename = File.basename(f)
        items << MenuItem.new(filename, filename, filename)
      end
    end
    items
  end

  def choose_bunch
    items = files_to_items(@config_dir, '*.bunch')
    items.map! do |item|
      item.title = File.basename(item.title, '.bunch')
      item.value = File.basename(item.title, '.bunch')
      item
    end
    menu = Menu.new(items)
    menu.choose('Select a Bunch')
  end

  def choose_snippet
    items = files_to_items(@config_dir, '*')
    menu = Menu.new(items)
    menu.choose('Select a Snippet')
  end

  def expand_path(file)
    File.join(@config_dir, file)
  end

  def contents(snippet)
    IO.read(File.join(@config_dir, snippet))
  end

  def variables(content)
    matches = content.scan(/\$\{(\S+)(:.*?)?\}/)
    variables = []
    matches.each { |m| variables << m[0].sub(/:\S+$/, '') }
    variables.uniq
  end

  def fill_variables(text)
    vars = variables(text)
    output = []
    unless vars.empty?
      puts 'Enter values for variables'
      vars.each do |var|
        res = get_line(var)
        output << [var, CGI.escape(res)] unless res.empty?
      end
    end
    output
  end
end

class BunchURLGenerator
  include Prompt
  include Util

  def generate
    menu_items = [
      MenuItem.new('open', 'Open a Bunch', 'open'),
      MenuItem.new('close', 'Close a Bunch', 'close'),
      MenuItem.new('toggle', 'Toggle a Bunch', 'toggle'),
      MenuItem.new('snippet', 'Load a Snippet', 'snippet'),
      MenuItem.new('raw', 'Load raw text', 'raw')
    ]

    menu = Menu.new(menu_items)
    finder = BunchFinder.new

    selection = menu.choose
    Process.exit 0 unless selection
    url = "x-bunch://#{selection.value}"
    parameters = []
    case selection.id
    when /(open|close|toggle)/
      parameters << ['bunch', CGI.escape(finder.choose_bunch.value)]
    when /snippet/
      filename = finder.choose_snippet.value
      parameters << ['file', filename]
      filename = finder.expand_path(filename)
      snippet = Snippet.new(filename)
      fragment = snippet.choose_fragment
      if fragment
        parameters << ['fragment', CGI.escape(fragment.title)]
        contents = fragment.value
      else
        contents = snippet.contents
      end
      variables = finder.fill_variables(contents)
      parameters.concat(variables) if variables.length
    when /raw/
      parameters << ['text', menu.url_encode_text]
    else
      Process.exit 0
    end

    menu.items = [
      MenuItem.new('app', 'Application', 'find_bid'),
      MenuItem.new('url', 'URL', 'get_line(')
    ]

    selection = menu.choose('Add success action? (Enter to skip)')

    if selection
      case selection.id
      when /app/
        app = get_line('Application name')
        value = bundle_id(app)
      when /url/
        value = get_line('URL')
      end

      parameters << ['x-success', value] if value

      delay = get_line('Delay for success action')
      parameters << ['x-delay', delay.to_s] if delay =~ /^\d+$/
    end

    query_string = parameters.map { |param| "#{param[0]}=#{param[1]}" }.join('&')

    puts url + '?' + query_string
  end
end
