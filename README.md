![screenshot](http://i.imgur.com/6lPGlV6.png)

# haxe-metazelda

Haxe port of Metazelda : https://github.com/tcoxon/metazelda  
Implementation of an algorithm for procedurally-generating dungeons with Zelda-like item-based puzzles.


## Overview
haxe-metazelda is the Haxe port of [metazelda](https://github.com/tcoxon/metazelda). It's organized into 2 separated modules : 
 1. the metazelda algorithm
 2. the viewer

The metazelda algorithm can easily be imported in your own project, and only needs polygonal-ds.

#### Dependencies for the viewer
```
openfl (tested with 1.3.0)
```

#### Dependencies for the metazelda algorithm
```
polygonal-ds (tested with 1.4.1)
```

## Try it
 * [flash version](https://dl.dropboxusercontent.com/u/100579483/haxe-metazelda/flash/haxemetazelda.swf)
 * [html5 version](https://dl.dropboxusercontent.com/u/100579483/haxe-metazelda/html5/index.html)

It has successfully been compiled to flash, html5,  windows & neko. It should work on any desktop OS and the mobile target hasn't been tested yet (give it a try and tell me if you can).

### Screenshots

![haxe-metazelda screenshot 1](http://i.imgur.com/Q6DRIQk.png)  

-----

**[Gallery on Imgur](http://imgur.com/a/N4VPm)**

## How to use it
Check out the **[wiki](https://github.com/julsam/haxe-metazelda/wiki)**.

## Todo
 1. improve UI. Maybe use haxeui ?
 2. improve wiki
   1. more doc
   2. snippets
 3. make an example demo project to show how to use it.
 
## Licence
 
 BSD Licence (see [LICENCE](https://github.com/julsam/haxe-metazelda/blob/master/LICENCE) file)
