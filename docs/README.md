# MyMiniMap
[![Gitter](https://badges.gitter.im/MyMiniMap/Lobby.svg)](https://gitter.im/MyMiniMap/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is an addon for "Elder Scrolls Online" game to provide a minimap functionality. It started of as a replacement of at the time
outdated [**MiniMap by Fyrakin**](http://www.esoui.com/downloads/info605-MiniMapbyFyrakin.html), but now it's evolved into it's own addon.

## Disclaimer
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates.
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc.
 in the United States and/or other countries. All rights reserved.
 
LUA Script re-usage or code cloning of this Add-on for other projects is allowed and encouraged **with 
approved permission from the author**. 

## Table of Contents
1. [Features](#features)
2. [Changelog](#changelog)
	1. [v1.0.0](#v1.0.0-(initial-implementation))
3. [Contributing](#contributing)
	1. [Useful Resources](#useful-resources)
	2. [Development Tips & Suggestions](#development-tips-&-suggestions)
		1. [IDE Setup](#ide-setup)
		2. [Emmy Lua](#emmy-lua)
		3. [ESOUI Source Code](#esoui-source-code)
		4. [GitHub Issue Navigation](#github-issue-navigation)

## Features
* "North-facing Fixed" and "Rotating" modes.
* Smooth circular design.
* Map Pin display.
* Self-cleanup cycle for runtime bug fixing.
* Automatic hiding when entering menus.
* Ability to zoom in/out the map display.
* Ability to reposition the minimap control.
* Semi-lightweight CPU usage.

## Configuration
To access addon settings type `/mmm` in game chat.

To move the map simply drag it with mouse.

To zoom in/out, scroll mouse wheel on map while holding SHIFT.

## Changelog
### v1.0.0 (Initial Implementation)
* North-facing and Rotating modes.
* Smooth circular design.
* Map Pin display. Currently supported pin types:
    * Quest
    * Location
    * Waypoint
    * Fast Travel
    * POI
* Self-cleanup cycle for runtime bug fixing.
* Automatic hiding when entering menus.
* Ability to zoom in/out the map display.
* Ability to reposition the minimap control.
* Semi-lightweight CPU usage.

## Contributing
Contributors are welcome. If you'd like to take part in developing the addon, 
refer to the [Contributing Guidelines](CONTRIBUTING.md) for all the details.

### Useful Resources
* [ESOUI Wiki](http://wiki.esoui.com/Main_Page)
* [ESOUI Developer Forum](http://www.esoui.com/forums/forumdisplay.php?f=163)
* [ESOUI Gitter Chat](https://gitter.im/esoui/esoui)

### Development Tips & Suggestions
Bellow is a collection of tips and suggestions useful to know when working on any ESO addon.

#### IDE Setup
For best performance and clarity, [IntelliJ IDEA](https://www.jetbrains.com/idea/download/#section=windows) is the recommended IDE. Its community version is free and sufficient for
lua development.

#### Emmy Lua
To be able to work on lua projects, you'll first have to install the [Emmy Lua](https://plugins.jetbrains.com/plugin/9768-emmylua)
plugin to IntelliJ. Optionally, you
can also download the binaries of your prefered version of [Lua](http://luabinaries.sourceforge.net/download.html) language.
These can then be set/added as your lua language sources by going *File > Project Structure > SDKs*, clicking the green plus and selecting
the root folder of the extracted binary.

#### ESOUI Source Code
Once you have Emmy Lua plugin setup, it's very useful to check-out [ESOUI](https://github.com/esoui/esoui) project and add its esoui directory to the project's
libraries. This can be done by going *File > Project Structure > Libraries*, clicking on the green plus button, selecting
"Lua Zip Library" and navigating to the esoui folder. After this is done, IntelliJ will start providing you code validation, information
and suggestion from the globally available ESOUI libraries. You can also use code navigation (CTRL + B) to quickly access any code object
coming from those libraries.

#### GitHub Issue Navigation
GitHub's issues can also be integrated into IntelliJ. This can be done by following these steps:
* Go *File > Settings > Tools > Tasks > Servers* and add a GitHub server via the green plus button. Fill up the required server 
details and you're done. Optionally, I'd suggest going into the *Commit Message* tab and enabling commit messages. Set the message
as `[{id}] {summary}` and it'll provide you a meaningful base for your commit messages each time.

Having this done, you can also explore the settings available to you in the *File > Settings > Tools > Tasks* menu.
* **Changelist Name Format**: Automatically configures a changelist name for your tasks. 
    > Recommended: `[{id}] {summary}`
* **Feature Branch Name**: Automatically names your feature branches for the tasks. 
    > Recommended: `feature/MPE {id} {summary}`
    
Furthermore, by going *File > Settings > Version Control*, clicking the green plus button and adding the following entry,
IntelliJ can be setup to automatically detect GitHub issue references and provide you with direct hyperlinks to the issue page.
* **Issue ID**: `([A-Z,a-z]+)\-(\d+)`
* **Issue Link**: `https://github.com/k33ny/$1/issues/$2`