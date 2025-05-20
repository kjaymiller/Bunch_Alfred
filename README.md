> [!NOTE]
>
> I'm looking for someone to take over this project as I'm not longer maintaining it.
> I will continue to merge PRs as they make sense but feel free to ask about taking ownership or merging


This workflow takes advantage of [Brett Terpstra's Bunch Application][Bunch].

[Bunch] is a workspace loader that you can use to quickly open/close applications, urls, documents, and more to come.

This workflow utilizes Bunch's CLI script and it's x-callback functionality.

# Directions:

- bunch - Top Level Bunch Selector
- bunch <bunch_file> - Toggles the selected bunch

MODIFIERS (+ Return)

### Modifiers-Description

- CMD: Forces Open the Bunch
- Control: Forces Closed the Applications listed in the bunch.
- Shift: Opens the Bunch file to be edited
- bedit <bunch> - Opens the Bunch file to be edited
- `bsettings` - Opens the preferences page
- `bsettings:refresh` - Refreshes your Bunch List
- `bsettings:bunches_dir` - Reveals the contents of the current bunches directory
  - Modifier cmd - opens the prompt to change the bunches directory. (YOU WILL NEED TO REFRESH YOUR BUNCH LIST)
- `bsettings:help` - Opens this page!

# FAQ
### Do you work on Bunch?
No but I do test bunch and use it very much so when new features come out I do try to make sure that nothing has broken.
  
### Can I pass in variables from Alfred?
Not at the moment, but that is something that I would love to implement sadly this would rely on folks using a similar variable scheme or positional arguments being supported. I would recommend you do something like [Nested Bunches](https://bunchapp.co/docs/bunch-files/other-bunches/) or use [Interactive Dialogs](https://bunchapp.co/docs/bunch-files/interactivity/) to prompt for information.
  
### I installed the workflow and it's not seeing my Bunches
There could be a few problems
1. Using an outdated version of the workflow. [Install the Latest Version](https://github.com/kjaymiller/Bunch_Alfred/releases/latest)
2. You have both the stable and the Beta running. (This uses the x-callback-url and the Applescript to run so they may be getting wires crossed. Choose one and uninstall the other)
3. Your App Cache may be out of date in terms of the `configDir`. To fix, check out the [#Reset AppCache] Section


# Reset AppCache  
To reset the AppCache `configDir` value, delete the existing value.
1. Complete Quit Bunch
2. Open terminal, and enter `defaults delete ~/Library/Preferences/com.brettterpstra.Bunch.plist configDir`
3. ReLaunch Bunch

[Bunch]: https://bunchapp.co
