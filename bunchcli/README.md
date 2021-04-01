# Bunch

A CLI for [Bunch.app](https://brettterpstra.com/projects/bunch).

## Installation

    $ gem install bunch

## Usage

    $ bunch -h  
    CLI for Bunch.app
    -l, --list                       List available Bunches
    -s, --show BUNCH                 Show contents of Bunch
    -o, --open                       Open Bunch ignoring "Toggle Bunches" preference
    -c, --close                      Close Bunch ignoring "Toggle Bunches" preference
    -t, --toggle                     Toggle Bunch ignoring "Toggle Bunches" preference
        --snippet                    Load as snippet
        --fragment=FRAGMENT          Run a specific section
        --vars=VARS                  Variables to pass to a snippet, comma-separated
        --pref                       Set a preference. Run without argument to list available preferences.
    -u, --url                        Output URL instead of opening
    -i, --interactive                Interactively generate a Bunch url
        --show-config                Display configuration values
    -f, --force-refresh              Force refresh cached preferences
    -h, --help                       Display this screen
    -v, --version                    Display Bunch version

Usage: `bunch [options] BUNCH_NAME|PATH_TO_FILE`

Bunch names are case insensitive and will execute first match

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
