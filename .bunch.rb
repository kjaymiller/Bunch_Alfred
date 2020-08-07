#!/usr/bin/env ruby
# frozen_string_literal: true

# A CLI for [Bunch.app](https://brettterpstra.com/projects/bunch/) by Brett Terpstra
# With tweaks from jlw (https://gist.github.com/jlw/28ab2591f8d14c7799a9e18580279f08#gistcomment-2924428)
require 'optparse'

class Bunch
  attr_writer :url_method

  def initialize
    @bunch_dir = nil
    @url_method = nil
    @bunches = nil
  end

  # items.push({title: 0})
  def generate_bunch_list
    items = []
    Dir.glob(File.join(bunch_dir, '*.bunch')).each do |f|
      items.push(
        path: f,
        title: File.basename(f, '.bunch')
      )
    end
    items
  end

  def bunch_dir
    @bunch_dir ||= begin
      dir = `/usr/bin/defaults read com.brettterpstra.Bunch configDir`.strip
      File.expand_path(dir)
    end
  end

  def url_method
    @url_method ||= `/usr/bin/defaults read com.brettterpstra.Bunch toggleBunches`.strip == '1' ? 'toggle' : 'open'
  end

  def bunches
    @bunches ||= generate_bunch_list
  end

  def url(bunch)
    %(x-bunch://#{url_method}?bunch=#{bunch[:title]})
  end

  def list_bunches
    bunches.each { |bunch| $stdout.puts bunch[:title] }
  end

  def find_bunch(str)
    found_bunch = false

    bunches.each do |bunch|
      if bunch[:title].downcase =~ /.*?#{str}.*?/i
        found_bunch = bunch
        break
      end
    end
    found_bunch
  end

  def human_action
    (url_method.gsub(/e$/, '') + 'ing').capitalize
  end

  def open(str)
    bunch = find_bunch(str)
    unless bunch
      warn 'No matching Bunch found'
      Process.exit 1
    end

    warn "#{human_action} #{bunch[:title]}"

    `open "#{url(bunch)}"`
  end

  def show(str)
    bunch = find_bunch(str)
    output = `cat "#{bunch[:path]}"`.strip
    puts output
  end
end

bunch = Bunch.new

optparse = OptionParser.new do |opts|
  opts.banner = 'CLI for Bunch.app'

  opts.on('-h', '--help', 'Display this screen') do |_opt|
    puts opts
    puts "\nUsage: #{File.basename(__FILE__)} [options] BUNCH_NAME"
    puts "\nBunch names are case insensitive and will execute first match"
    exit
  end

  opts.on('-l', '--list', 'List available Bunches') do |_opt|
    bunch.list_bunches
    Process.exit 0
  end

  opts.on('-o', '--open', 'Open Bunch ignoring "Toggle Bunches" preference') do |_opt|
    bunch.url_method = 'open'
  end

  opts.on('-c', '--close', 'Close Bunch ignoring "Toggle Bunches" preference') do |_opt|
    bunch.url_method = 'close'
  end

  opts.on('-t', '--toggle', 'Toggle Bunch ignoring "Toggle Bunches" preference') do |_opt|
    bunch.url_method = 'toggle'
  end

  opts.on('-s', '--show BUNCH', 'Show contents of Bunch') do |opt|
    bunch.show(opt)
    Process.exit 0
  end
end

optparse.parse!

ARGV.map { |arg| bunch.open(arg) }