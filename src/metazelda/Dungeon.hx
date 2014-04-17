package metazelda;

import metazelda.Bounds;
import metazelda.Symbol;
import metazelda.util.Coords;
import metazelda.Room;
import metazelda.util.Direction;
import metazelda.util.SimpleTreeMap;
import metazelda.util.Utils;

/**
 * @see IDungeon
 */
class Dungeon implements IDungeon
{
	private var itemCount:Int;
	private var rooms:SimpleTreeMap<Coords, Room>;
	private var bounds:Bounds;
	
	public function new() 
	{
		rooms = new SimpleTreeMap<Coords, Room>();
		bounds = new Bounds(0, 0, 0, 0);
	}
	
	/* INTERFACE metazelda.IDungeon */
	
	public function getExtentBounds():Bounds
	{
		return bounds;
	}
	
	public function getRooms():Array<Room>
	{
		return rooms.values();
	}
	
	public function roomCount():Int
	{
		return rooms.size();
	}
	
	public function get(coords:Coords):Room
	{
		return rooms.get(coords);
	}
	
	public function getBy(x:Int, y:Int):Room
	{
		return get(new Coords(x, y));
	}
	
	public function add(room:Room):Void
	{
		rooms.set(room.coords, room);
		
		if (room.coords.x < bounds.left) {
			bounds = new Bounds(room.coords.x, bounds.top,
			        bounds.right, bounds.bottom);
		}
		if (room.coords.x > bounds.right) {
			bounds = new Bounds(bounds.left, bounds.top,
			        room.coords.x, bounds.bottom);
		}
		if (room.coords.y < bounds.top) {
			bounds = new Bounds(bounds.left, room.coords.y,
			        bounds.right, bounds.bottom);
		}
		if (room.coords.y > bounds.bottom) {
			bounds = new Bounds(bounds.left, bounds.top,
			        bounds.right, room.coords.y);
		}
		
	}
	
	public function linkOneWay(room1:Room, room2:Room, cond:Symbol=null):Void
	{
		Utils.assert(rooms.containsValue(room1) && rooms.containsValue(room2));
		Utils.assert(room1.coords.isAdjacent(room2.coords));
		var d:Direction = room1.coords.getDirectionTo(room2.coords);
		room1.getEdges()[d.code] = new Edge(cond);
	}
	
	public function link(room1:Room, room2:Room, cond:Symbol=null):Void
	{
		Utils.assert(rooms.containsValue(room1) && rooms.containsValue(room2));
		Utils.assert(room1.coords.isAdjacent(room2.coords));
		var d:Direction = room1.coords.getDirectionTo(room2.coords);
		room1.getEdges()[d.code] = new Edge(cond);
		room2.getEdges()[Direction.oppositeDirection(d).code] = new Edge(cond);
	}
	
	public function roomsAreLinked(room1:Room, room2:Room):Bool
	{
		var d:Direction = room1.coords.getDirectionTo(room2.coords);
		return room1.getEdge(d) != null ||
		    room2.getEdge(Direction.oppositeDirection(d)) != null;
	}
	
	public function findStart():Room
	{
		for (room in getRooms()) {
			if (room.isStart()) {
				return room;
			}
		}
		return null;
	}
	
	public function findBoss():Room
	{
		for (room in getRooms()) {
			if (room.isBoss()) {
				return room;
			}
		}
		return null;
	}
	
	public function findGoal():Room
	{
		for (room in getRooms()) {
			if (room.isGoal()) {
				return room;
			}
		}
		return null;
	}
	
	public function findSwitch():Room 
	{
		for (room in getRooms()) {
			if (room.isSwitch()) {
				return room;
			}
		}
		return null;
	}
}
