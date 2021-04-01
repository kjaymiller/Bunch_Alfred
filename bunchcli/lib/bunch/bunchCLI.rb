class Bunch
  include Util
  attr_writer :url_method, :fragment, :variables, :show_url

  def initialize
    @bunch_dir = nil
    @url_method = nil
    @bunches = nil
    @fragment = nil
    @variables = nil
    @success = nil
    @show_url = false
    get_cache
  end

  def launch_if_needed
    pid = `ps ax | grep 'MacOS/Bunch'|grep -v grep`.strip
    if pid == ""
      `open -a Bunch`
      sleep 2
    end
  end

  def update_cache
    @bunch_dir = nil
    @url_method = nil
    @bunches = nil
    target = File.expand_path(CACHE_FILE)
    settings = {
      'bunchDir' => bunch_dir,
      'method' => url_method,
      'bunches' => bunches,
      'updated' => Time.now.strftime('%s').to_i
    }
    File.open(target,'w') do |f|
      f.puts YAML.dump(settings)
    end
    return settings
  end

  def get_cache
    target = File.expand_path(CACHE_FILE)
    if File.exists?(target)
      settings = YAML.load(IO.read(target))
      now = Time.now.strftime('%s').to_i
      if now - settings['updated'].to_i > CACHE_TIME
        settings = update_cache
      end
    else
      settings = update_cache
    end
    @bunch_dir = settings['bunchDir'] || bunch_dir
    @url_method = settings['method'] || url_method
    @bunches = settings['bunches'] || generate_bunch_list
  end

  def variable_query
    vars = @variables.split(/,/).map { |v| v.strip }
    query = []
    vars.each { |v|
      parts = v.split(/=/).map { |v| v.strip }
      k = parts[0]
      v = parts[1]
      query << "#{k}=#{CGI.escape(v)}"
    }
    query
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
      dir = `/usr/bin/defaults read #{ENV['HOME']}/Library/Preferences/com.brettterpstra.Bunch.plist configDir`.strip
      File.expand_path(dir)
    end
  end

  def url_method
    @url_method ||= `/usr/bin/defaults read #{ENV['HOME']}/Library/Preferences/com.brettterpstra.Bunch.plist toggleBunches`.strip == '1' ? 'toggle' : 'open'
  end

  def bunches
    @bunches ||= generate_bunch_list
  end

  def url(bunch)
    params = "&x-success=#{@success}" if @success
    if url_method == 'file'
      %(x-bunch://raw?file=#{bunch}#{params})
    elsif url_method == 'raw'
      %(x-bunch://raw?txt=#{bunch}#{params})
    elsif url_method == 'snippet'
      %(x-bunch://snippet?file=#{bunch}#{params})
    elsif url_method == 'setPref'
      %(x-bunch://setPref?#{bunch})
    else
      %(x-bunch://#{url_method}?bunch=#{bunch[:title]}#{params})
    end
  end

  def bunch_list
    list = []
    bunches.each { |bunch| list.push(bunch[:title]) }
    list
  end

  def list_bunches
    $stdout.puts bunch_list.join("\n")
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

  def list_preferences
    prefs =<<EOF
toggleBunches=[0,1]        Allow Bunches to be both opened and closed
configDir=[path]           Absolute path to Bunches folder
singleBunchMode=[0,1]      Close open Bunch when opening new one
preserveOpenBunches=[0,1]  Restore Open Bunches on Launch
debugLevel=[0-4]           Set the logging level for the Bunch Log
EOF
    puts prefs
  end


  def open(str)
    launch_if_needed
    # get front app
    front_app = %x{osascript -e 'tell application "System Events" to return name of first application process whose frontmost is true'}.strip
    bid = bundle_id(front_app)
    @success = bid if (bid)

    if @url_method == 'raw'
      warn 'Running raw string'
      if @show_url
        $stdout.puts url(str)
      else
        `open '#{url(str)}'`
      end
    elsif @url_method == 'snippet'
      _url = url(str)
      params = []
      params << "fragment=#{CGI.escape(@fragment)}" if @fragment
      params.concat(variable_query) if @variables
      _url += '&' + params.join('&')
      if @show_url
        $stdout.puts _url
      else
        warn "Opening snippet"
        `open '#{_url}'`
      end
    elsif @url_method == 'setPref'
      if str =~ /^(\w+)=([^= ]+)$/
        _url = url(str)
        if @show_url
          $stdout.puts _url
        else
          warn "Setting preference #{str}"
          `open '#{_url}'`
        end
      else
        warn "Invalid key=value pair"
        Process.exit 1
      end
    else
      bunch = find_bunch(str)
      unless bunch
        if File.exists?(str)
          @url_method = 'file'
          if @show_url
            $stdout.puts url(str)
          else
            warn "Opening file"
            `open '#{url(str)}'`
          end
        else
          warn 'No matching Bunch found'
          Process.exit 1
        end
      else
        if @show_url
          $stdout.puts url(str)
        else
          warn "#{human_action} #{bunch[:title]}"
          `open '#{url(bunch)}'`
        end
      end
    end
    # attempt to restore front app
    # %x{osascript -e 'delay 2' -e 'tell application "#{front_app}" to activate'}
  end

  def show(str)
    bunch = find_bunch(str)
    output = `cat "#{bunch[:path]}"`.strip
    puts output
  end

  def show_config(key=nil)
    case key
    when /(folder|dir)/
      puts bunch_dir
    when /toggle/
      puts url_method == 'toggle' ? 'true' : 'false'
    when /method/
      puts url_method
    else
      puts "Bunches Folder: #{bunch_dir}"
      puts "Default URL Method: #{url_method}"
      puts "Cached Bunches"
      bunches.each {|b|
        puts "    - #{b[:title]}"
      }
    end
  end
end
