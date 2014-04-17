package metazelda;

import haxe.ds.Vector;
import metazelda.util.Coords;
import metazelda.util.Direction;

/**
 * Represents an individual space within the dungeon.
 * <p>
 * A Room contains:
 * <ul>
 * <li>an item ({@link Symbol}) that the player may (at his or her choice)
 *      collect by passing through this Room;
 * <li>an intensity, which is a measure of the relative difficulty of the room
 *      and ranges from 0.0 to 1.0;
 * <li>{@link Edge}s for each door to an adjacent Room.
 * </ul>
 */
class Room
{
	public var precond:Condition;
	public var coords:Coords;
	
	private var item:Symbol;
	private var edges:Vector<Edge>;
	private var intensity:Float;
	private var parent:Room;
	private var children:Array<Room>;
	
	/**
	 * Creates a Room at the given coordinates, with the given parent,
	 * containing a specific item, and having a certain pre-{@link Condition}.
	 * <p>
	 * The parent of a room is the parent node of this Room in the initial
	 * tree of the dungeon during
	 * {@link net.bytten.metazelda.generators.DungeonGenerator#generate()}, and
	 * before
	 * {@link net.bytten.metazelda.generators.DungeonGenerator#graphify()}.
	 * 
	 * @param coords    the coordinates of the new room
	 * @param parent    the parent room or null if it is the root / entry room
	 * @param item      the symbol to place in the room or null if no item
	 * @param precond   the precondition of the room
	 * @see Condition
	 */
	public function new(coords:Coords, parent:Room, item:Symbol, precond:Condition) 
	{
		this.coords = coords;
		this.item = item;
		this.edges = new Vector<Edge>(Direction.NUM_DIRS);
		this.precond = precond;
		this.intensity = 0.0;
		this.parent = parent;
		this.children = new Array<Room>();
		// all edges initially null
	}
	
	/**
	 * @return the intensity of the Room
	 * @see Room
	 */
	public function getIntensity():Float
	{
		return intensity;
	}
	
	/**
	 * @param intensity the value to set the Room's intensity to
	 * @see Room
	 */
	public function setIntensity(intensity:Float):Void
	{
		this.intensity = intensity;
	}
	
	/**
	 * @return  the item contained in the Room, or null if there is none
	 */
	public function getItem():Symbol
	{
		return item;
	}
	
	/**
	 * @param item  the item to place in the Room
	 */
	public function setItem(item:Symbol):Void
	{
		this.item = item;
	}
	
	/**
	 * Gets the array of {@link Edge} slots this Room has. There is one slot
	 * for each compass {@link Direction}. Non-null slots in this array
	 * represent links between this Room and adjacent Rooms.
	 * 
	 * @return the array of Edges
	 */
	public function getEdges():Vector<Edge>
	{
		return edges;
	}
	
	/**
	 * Gets the Edge object for a link in a given direction.
	 * 
	 * @param d the compass {@link Direction} of the Edge for the link from this
	 *          Room to an adjacent Room
	 * @return  the {@link Edge} for the link in the given direction, or null if
	 *          there is no link from this Room in the given direction
	 */
	public function getEdge(d:Direction):Edge
	{
		return edges[d.code];
	}
	
	/**
	 * Gets the number of Rooms this Room is linked to.
	 * 
	 * @return  the number of links
	 */
	public function linkCount():Int
	{
		var result:Int = 0;
		for (d in 0...Direction.NUM_DIRS) {
			if (edges[d] != null) {
				result++;
			}
		}
		return result;
	}
	
	/**
	 * @return whether this room is the entry to the dungeon.
	 */
	public function isStart():Bool
	{
		return item != null && item.isStart();
	}
	
	/**
	 * @return whether this room is the goal room of the dungeon.
	 */
	public function isGoal():Bool
	{
		return item != null && item.isGoal();
	}
	
	/**
	 * @return whether this room contains the dungeon's boss.
	 */
	public function isBoss():Bool
	{
		return item != null && item.isBoss();
	}
	
	/**
	 * @return whether this room contains the dungeon's switch object.
	 */
	public function isSwitch():Bool
	{
		return item != null && item.isSwitch();
	}
	
	/**
	 * @return the precondition for this Room
	 * @see Condition
	 */
	public function getPrecond():Condition
	{
		return precond;
	}
	
	/**
	 * @param precond   the precondition to set this Room's to
	 * @see Condition
	 */
	public function setPrecond(precond:Condition):Void
	{
		this.precond = precond;
	}
	
	/**
	 * @return the parent of this Room
	 * @see Room#Room
	 */
	public function getParent():Room
	{
		return parent;
	}
	
	/**
	 * @param parent the Room to set this Room's parent to
	 * @see Room#Room
	 */
	public function setParent(parent:Room):Void
	{
		this.parent = parent;
	}
	
	/**
	 * @return the collection of Rooms this Room is a parent of
	 * @see Room#Room
	 */
	public function getChildren():Array<Room>
	{
		return children;
	}
	
	/**
	 * Registers this Room as a parent of another.
	 * Does not modify the child room's parent property.
	 * 
	 * @param child the room to parent
	 */
	public function addChild(child:Room):Void
	{
		children.push(child);
	}
	
	public inline function toString():String
	{
		return 'Room($coords)';
	}
}
