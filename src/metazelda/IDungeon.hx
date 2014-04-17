package metazelda;

import metazelda.util.Coords;

/**
 * Represents the special layout of a lock-and-key puzzle and contains all
 * {@link Symbol}s, {@link Room}s and {@link Edge}s within the puzzle.
 */
interface IDungeon
{
	/**
	 * @return  the rooms within the dungeon
	 */
	public function getRooms():Array<Room>;
	
	/**
	 * @return the number of rooms in the dungeon
	 */
	public function roomCount():Int;
	
	/**
	 * @param coords    the coordinates
	 * @return  the room at the given coordinates
	 */
	public function get(coords:Coords):Room;
	
	/**
	 * @param x the X coordinate
	 * @param y the Y coordinate
	 * @return  the room at the given coordinates
	 */
	public function getBy(x:Int, y:Int):Room;
	
	/**
	 * Adds a new room to the dungeon, overwriting any rooms already in it that
	 * have the same coordinates.
	 * 
	 * @param room  the room to add
	 */
	public function add(room:Room):Void;
	
	/**
	 * Adds a one-way conditional edge between the given rooms.
	 * A one-way edge may be used to travel from room1 to room2, but not room2
	 * to room1.
	 * 
	 * @param room1 the first room to link
	 * @param room2 the second room to link
	 * @param cond  the condition on the edge
	 */
	public function linkOneWay(room1:Room, room2:Room, cond:Symbol=null):Void;
	
	/**
	 * Adds a two-way conditional edge between the given rooms.
	 * A two-way edge may be used to travel from each room to the other.
	 * 
	 * @param room1 the first room to link
	 * @param room2 the second room to link
	 * @param cond  the condition on the edge
	 */
	public function link(room1:Room, room2:Room, cond:Symbol=null):Void;
	
	/**
	 * Tests whether two rooms are linked.
	 * Two rooms are linked if there are any edges (in any direction) between
	 * them.
	 * 
	 * @return  true if the rooms are linked, false otherwise
	 */
	public function roomsAreLinked(room1:Room, room2:Room):Bool;
	
	/**
	 * @return  the room containing the START symbol
	 */
	public function findStart():Room;
	
	/**
	 * @return  the room containing the BOSS symbol
	 */
	public function findBoss():Room;
	
	/**
	 * @return  the room containing the GOAL symbol
	 */
	public function findGoal():Room;
	
	/**
	 * @return  the room containing the SWITCH symbol
	 */
	public function findSwitch():Room;
	
	/**
	 * Gets the {@link Bounds} that encloses every room within the dungeon.
	 * <p>
	 * The Bounds object has the X coordinate of the West-most room, the Y
	 * coordinate of the North-most room, the 'right' coordinate of the
	 * East-most room, and the 'bottom' coordinate of the South-most room.
	 * 
	 * @return  the rectangle enclosing every room within the dungeon
	 */
	public function getExtentBounds():Bounds;
}
