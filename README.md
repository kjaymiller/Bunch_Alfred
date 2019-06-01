This workflow takes advantage of Brett Terpstra's [Bunch Application](https://brettterpstra.com/projects/bunch/). 

Bunch is a workspace loader that you can use to quickly open/close applications, urls, documents, and more to come. 

This workflow utilizes Bunch's [CLI script](https://gist.github.com/ttscoff/07820820270759b5ce98b06521877a54)


## Directions:

* `b - Top Level Bunch Selector`
* `b <bunch>` - Toggles the selected bunch

MODIFIERS (+ Return)
--------------------
 - CMD = Forces Open the Bunch
 - Control = Forces Closed the Applications listed in the bunch.
 - Shift = Opens the Bunch file to be edited
--------------------

* `bedit <bunch> - Opens the Bunch file to be edited
* `bsettings:refresh` - Refreshes your Bunch List 

Change Log
----------
2019-05-31.0
Huge overhaul of the workflow. This workflow no longer runs off the url scheme and now runs off the CLI that Brett and a few others have created. 

This change will allow for greater flexibility and speed with the application.

I've also changed the refresh call to now be contained in a single javascript for automation script instead of many steps. This was just for a cleaner look.

* CHANGED `b - Top Level Bunch Selector` Now displays the active bunches
* Changed: `b <bunch filename>` - Runs the Selected Bunch
* REMOVED: `b display <bunch filename>` - Displays the contents of the Bunch in Large Text
* CHANGED `b edit <bunch filename>` - Now `bedit <bunch name>
* CHANGED `b refresh` -now
