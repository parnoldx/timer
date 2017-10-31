# Timer

### The ultimate tea timer


![screenshot](data/screenshot.png)

## Usage
* Start a timer with natural language input like e.g. 5 minutes 15 seconds or 5m3s or just 5 for 5 minutes
* You can assign a title to your timer by double clicking
* Various color options to choose from
* Command line options available, see --help for more information

## Installation
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.parnold-x.timer)﻿


## Building
Dependencies:
* valac
* glib-2.0
* gee-0.8
* gtk+-3.0
* gstreamer-audio-1.0
* unity
 
then build with:
 
```
meson build --prefix=/usr
cd build
sudo ninja install
```
