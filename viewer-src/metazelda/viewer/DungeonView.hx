package metazelda.viewer;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import metazelda.Bounds;
import metazelda.Edge;
import metazelda.IDungeon;
import metazelda.Room;
import metazelda.util.Coords;
import metazelda.util.Direction;
import metazelda.viewer.util.Utils;

using Lambda;

class DungeonView extends Sprite
{
	public function new() 
	{
		super();
        addEventListener(Event.ADDED_TO_STAGE, onAdded);   
	}
	
	private function onAdded(event:Event):Void
	{
        removeEventListener(Event.ADDED_TO_STAGE, onAdded);
    }
	
	public function draw(dungeon:IDungeon)
	{
		var bounds:Bounds = dungeon.getExtentBounds();
		var width = Lib.current.stage.stageWidth;
		var height = Lib.current.stage.stageHeight;
		var scale:Float = Math.min(width / bounds.width(), height / bounds.height());
		this.x += -scale * bounds.left;
		this.y += -scale * bounds.top;
		
		for (room in dungeon.getRooms()) {
			drawEdges(dungeon, room, scale);
		}
		
		for (room in dungeon.getRooms()) {
			drawRoom(room, scale);
		}
	}
	
	// a is beginning, b is the arrow tip.
	function drawArrow(ax:Float, ay:Float, bx:Float, by:Float, color:Int=0xffc800)
	{
		var abx:Float, aby:Float, ab:Float, cx:Float, cy:Float;
		var dx:Float, dy:Float, ex:Float, ey:Float, fx:Float, fy:Float;
		var size:Float = 8, ratio:Float = 2, fullness1:Float = 2, fullness2:Float = 3;

		abx = bx - ax;
		aby = by - ay;
		ab = Math.sqrt(abx * abx + aby * aby);

		cx = bx - size * abx / ab;
		cy = by - size * aby / ab;
		dx = cx + (by - cy) / ratio;
		dy = cy + (cx - bx) / ratio;
		ex = cx - (by - cy) / ratio;
		ey = cy - (cx - bx) / ratio;
		fx = (fullness1 * cx + bx) / fullness2;
		fy = (fullness1 * cy + by) / fullness2;

		// draw lines and apply fill: a -> b -> d -> f -> e -> b
		graphics.beginFill(color);
		graphics.lineStyle(1, color);
		graphics.moveTo(ax, ay);
		graphics.lineTo(bx, by);
		graphics.lineTo(dx, dy);
		graphics.lineTo(fx, fy);
		graphics.lineTo(ex, ey);
		graphics.lineTo(bx, by);
		graphics.endFill();
	}
	
	function drawParentEdge(parent:Room, child:Room, d:Direction, scale:Float)
	{
		var x1:Float = parent.coords.x * scale + scale / 2;
		var y1:Float = parent.coords.y * scale + scale / 2;
		var x2:Float = child.coords.x * scale + scale / 2;
		var y2:Float = child.coords.y * scale + scale / 2;
		
		if      (d == Direction.N) { y1 -= scale/4; y2 += scale/4; }
		else if (d == Direction.E) { x1 += scale/4; x2 -= scale/4; }
		else if (d == Direction.S) { y1 += scale/4; y2 -= scale/4; }
		else if (d == Direction.W) { x1 -= scale/4; x2 += scale/4; }
		
		var dx = 0, dy = 0;
		if      (d == Direction.N) dx -= Std.int(scale / 10);
		else if (d == Direction.E) dy += Std.int(scale / 10);
		else if (d == Direction.S) dx += Std.int(scale / 10);
		else if (d == Direction.W) dy -= Std.int(scale / 10);
		
		x1 += dx; x2 += dx;
		y1 += dy; y2 += dy;
		
		drawArrow(x1, y1, x2, y2);
		
		metazelda.util.Utils.assert(parent.getChildren().has(child));
	}
	
	function drawEdges(dungeon:IDungeon, room:Room, scale:Float)
	{
		graphics.lineStyle(1);
		for (d in Direction.values())
		{
			var oppD:Direction = Direction.oppositeDirection(d);
			
			var coords:Coords = room.coords;
			var nextCoords:Coords = coords.nextInDirection(d);
			
			var nextRoom:Room = dungeon.get(nextCoords);
			if (nextRoom != null && nextRoom.getParent() == room) {
				drawParentEdge(room, nextRoom, d, scale);
			}
			
			var edge:Edge = room.getEdge(d);
			if (edge == null) continue;
			
			var x1:Float = coords.x * scale + scale / 2;
			var y1:Float = coords.y * scale + scale / 2;
			var x2:Float = nextCoords.x * scale + scale / 2;
			var y2:Float = nextCoords.y * scale + scale / 2;
			
			if      (d == Direction.N) { y1 -= scale/4; y2 += scale/4; }
			else if (d == Direction.E) { x1 += scale/4; x2 -= scale/4; }
			else if (d == Direction.S) { y1 += scale/4; y2 -= scale/4; }
			else if (d == Direction.W) { x1 -= scale/4; x2 += scale/4; }
			
			if (nextRoom != null && edge.equals(nextRoom.getEdge(oppD))) {
				// Bidirectional edge
				// avoid drawing twice:
				if (room.coords.compareTo(nextRoom.coords) > 0) continue;
				
				drawLine(x1, y1, x2, y2);
				
				var midx = (x1 + x2) / 2;
				var midy = (y1 + y2) / 2;
				if (edge.getSymbol() != null) {
					addText(midx, midy, edge.getSymbol().toString());
				}
			} else {
				// Unidirectional edge
				var dx = 0, dy = 0;
				if      (d == Direction.N) dx -= Std.int(scale / 20);
				else if (d == Direction.E) dy += Std.int(scale / 20);
				else if (d == Direction.S) dx += Std.int(scale / 20);
				else if (d == Direction.W) dy -= Std.int(scale / 20);
				
				x1 += dx; x2 += dx;
				y1 += dy; y2 += dy;
				drawArrow(x1, y1, x2, y2, 0xff0000);
				
				var midx = (x1 + x2) / 2;
				var midy = (y1 + y2) / 2;
				if (edge.getSymbol() != null) {
					addText(midx, midy, edge.getSymbol().toString());
				}
			}
		}
	}
	
	function drawRoom(room:Room, scale:Float)
	{
		var cx:Int = Std.int(room.coords.x * scale + scale / 2);
		var cy:Int = Std.int(room.coords.y * scale + scale / 2);
		
		var darkerColor = Utils.hsv2int((0.6 - room.getIntensity() * 0.6) * 360, 1.0, 0.4);
		graphics.lineStyle(1, darkerColor);
		graphics.beginFill(Utils.hsv2int((0.6 - room.getIntensity() * 0.6) * 360, 0.7, 1.0));
		graphics.drawCircle(cx, cy, scale / 4);
		
		if (room.isGoal()) {
			graphics.beginFill(Utils.hsv2int((0.6 - room.getIntensity() * 0.6) * 360, 0.7, 1.0));
			graphics.drawCircle(cx, cy, scale / 5);
		}
		graphics.endFill();
		
		if (room.getItem() != null) {
			addText(cx - 12, cy - 14, room.getItem().toString(), darkerColor);
		}
		addText(cx - 12, cy, Std.string(room.getIntensity()).substr(0, 4), darkerColor);
	}
	
	function drawLine(x1:Float, y1:Float, x2:Float, y2:Float, color:Int=0x555555)
	{
		graphics.lineStyle(1, color);
		graphics.moveTo(x1, y1);
		graphics.lineTo(x2, y2);
	}
	
	function addText(x:Float, y:Float, text:String, color:Int=0x555555)
	{
		var tf:TextField = new TextField();
		tf.text = text;
		tf.textColor = color;
		tf.x = x;
		tf.y = y;
		addChild(tf);
	}
	
	public function remove()
	{
		//graphics.clear();
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}
}
