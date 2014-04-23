package metazelda.viewer;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.text.TextField;
import metazelda.constraints.CountConstraints;
import metazelda.constraints.SpaceConstraints;
import metazelda.constraints.SpaceMap;
import metazelda.generators.DungeonGenerator;
import metazelda.generators.IDungeonGenerator;
import metazelda.generators.LinearDungeonGenerator;
import metazelda.util.Coords;
import metazelda.util.Random;
import openfl.Assets;

class Main extends Sprite 
{
	var inited:Bool;
	
	var dungeonGen:IDungeonGenerator;
	var dungeonView:DungeonView;
	var seedTextField:TextField;
	
	function regenerate()
	{
		var seed = Std.random(metazelda.util.Utils.MAX_VALUE - 1);
		
		var constraints:CountConstraints = null;
		//constraints = getSpaceConstraints("tail.png");
		if (constraints == null) {
			constraints = new CountConstraints(25, 4, 1);
		}
		
		// Normal Dungeon
		{
			//dungeonGen = new DungeonGenerator(seed, constraints);
		}
		
		
		// Linear Dungeon
		{
			constraints.setMaxSwitches(0);
			dungeonGen = new LinearDungeonGenerator(seed, constraints);
		}
		
		dungeonGen.generate();
		
		if (dungeonView != null) {
			removeChild(dungeonView);
			dungeonView = null;
		}
		
		dungeonView = new DungeonView();
		addChild(dungeonView);
		dungeonView.draw(dungeonGen.getDungeon());
		
		// reset the focus so we can use the key <r> to regenerate
		stage.focus = stage; 
		
		seedTextField.text = 'Dungeon seed: ${dungeonGen.getSeed()} | Press <R> to regenerate.';
	}
	
	function getSpaceConstraints(filename:String="turtle.png"):SpaceConstraints
	{
		var constraints:SpaceConstraints = null;
		try	{
			var spaceMap:SpaceMap = new SpaceMap();
			var img:BitmapData = Assets.getBitmapData('img/spacemaps/$filename');
			for (x in 0...img.width) {
				for (y in 0...img.height) {
					if (img.getPixel(x, y) & 0xFFFFFF != 0) {
						spaceMap.set(new Coords(x, y), true);
					}
				}
			}
			constraints = new SpaceConstraints(spaceMap);
			
		} catch (e:Dynamic) {
			trace("SpaceConstraints creation failed");
		}
		return constraints;
	}
	
	function resize(e) 
	{
		if (!inited) init();
		
		removeChild(dungeonView);
		dungeonView = new DungeonView();
		addChild(dungeonView);
		dungeonView.draw(dungeonGen.getDungeon());
	}

	function init() 
	{
		if (inited) return;
		inited = true;
		
		seedTextField = new TextField();
		seedTextField.width = 600;
		seedTextField.text = "";
		seedTextField.x = 5;
		seedTextField.y = 5;
		addChild(seedTextField);
		
		regenerate();
	}
	
	function onKeyDown(e:KeyboardEvent)
	{
		if (e.keyCode == 82) { // 'r' pressed
			regenerate();
		}
	}

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}

	public static function main() 
	{
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
