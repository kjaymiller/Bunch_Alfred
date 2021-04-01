![Bunch Logo](https://github.com/kjaymiller/Bunch_Alfred/blob/main/9EBA9B16-9A22-4846-87D0-B69CEB41B5D4.png?raw=true)

This workflow takes advantage of Brett Terpstra's [Bunch Application](https://brettterpstra.com/projects/bunch/). 

Bunch is a workspace loader that you can use to quickly open/close applications, urls, documents, and more to come. 

This workflow utilizes Bunch's [CLI script](https://brettterpstra.com/bunch-beta/docs/integration/cli/) and the [x-callback-url](https://brettterpstra.com/bunch-beta/docs/integration/url-handler/).


This Workflow is maintained by kjaymiller.
More at https://kjaymiller.com.


## Directions:

## First Use

> The default path it assumes your bunces are at is `~/bunches` (This is the path I set so if you have any issues where you cannot see your bunches change the variable to your desired path and run `bsettings:refresh`

1. trigger Alfred
2. type bunch (You should see "Work with Bunch" press **return** or **tab**
3. begin typing the name of the bunch you wish to run (You can also search through the bunches
4. _Return_ will open the bunch. _⌘+Return_ will close the bunch

## Troubleshooting

* `bsettings:refresh` - Refreshes your Bunch List and your Bunches Application with the value in Workflow Environment Variables under `configDir (Default ~/bunches)`

### That still didn't work

copy the value in configDir and run this command in terminal
`defaults write /Users/<YOUR_PROFILE>/Library/Preferences/com.brettterpstra.Bunch.plist configDir -string <configDir_VARIABLE>`
