# Change Log

2020-08-08
- Moved the listing command to Python3.
- Created a release package to go with repo.

2019-05-31.0

Huge overhaul of the workflow. This workflow no longer runs off the url scheme and now runs off the CLI that Brett and a few others have created.

This change will allow for greater flexibility and speed with the application.

I've also changed the refresh call to now be contained in a single javascript for automation script instead of many steps. This was just for a cleaner look.

CHANGED b - Top Level Bunch Selector Now displays the active bunches
Changed: b <bunch filename> - Runs the Selected Bunch
REMOVED: b display <bunch filename> - Displays the contents of the Bunch in Large Text
CHANGED b edit <bunch filename> - Now `bedit
CHANGED b refresh -now bsettings:refresh (also now done with javascript for automation)
