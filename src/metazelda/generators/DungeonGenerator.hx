package metazelda.generators;

import metazelda.Condition;
import metazelda.constraints.IDungeonConstraints;
import metazelda.Dungeon;
import metazelda.IDungeon;
import metazelda.Room;
import metazelda.Symbol;
import metazelda.util.Coords;
import metazelda.util.Direction;
import metazelda.util.Random;
import metazelda.util.Utils;

using metazelda.util.Utils;
using Lambda;

/**
 * The default and reference implementation of an {@link IDungeonGenerator}.
 */
class DungeonGenerator implements IDungeonGenerator
{
	public static inline var MAX_RETRIES:Int = 20;
	
	private var seed:Int;
	private var random:Random;
	private var dungeon:Dungeon;
	private var constraints:IDungeonConstraints;
	
	/**
	 * Creates a DungeonGenerator with a given random seed and places
	 * specific constraints on {@link IDungeon}s it generates.
	 * 
	 * @param seed          the random seed to use
	 * @param constraints   the constraints to place on generation
	 * @see net.bytten.metazelda.constraints.IDungeonConstraints
	 */
	public function new(seed:Int, constraints:IDungeonConstraints) 
	{
		//trace("Dungeon seed:" + seed);
		this.seed = seed;
		this.random = new Random(seed);
		Utils.assert(constraints != null);
		this.constraints = constraints;
	}
	
	/**
	 * Randomly chooses a {@link Room} within the given collection that has at
	 * least one adjacent empty space.
	 * 
	 * @param roomCollection    the collection of rooms to choose from
	 * @return  the room that was chosen, or null if there are no rooms with
	 *          adjacent empty spaces
	 */
	private function chooseRoomWithFreeEdge(roomCollection:Array<Room>):Room
	{
		var rooms:Array<Room> = roomCollection.copy();
		rooms.shuffle(random);
		for (i in 0...rooms.length)
		{
			var room:Room = rooms[i];
			for (d in Direction.values())
			{
				var coords:Coords = room.coords.nextInDirection(d);
				if (dungeon.get(coords) == null && constraints.validRoomCoords(coords)) {
					return room;
				}
			}
		}
		return null;
	}
	
	/**
	 * Randomly chooses a {@link Direction} in which the given {@link Room} has
	 * an adjacent empty space.
	 * 
	 * @param room  the room
	 * @return  the Direction of the empty space chosen adjacent to the Room or
	 *          null if there are no adjacent empty spaces
	 */
	public function chooseFreeEdge(room:Room):Direction
	{
		var d0:Int = random.nextInt(4);
		for (i in 0...4)
		{
			var d:Direction = Direction.fromCode((d0 + i) % Direction.NUM_DIRS);
			var coords:Coords = room.coords.nextInDirection(d);
			if (dungeon.get(coords) == null && constraints.validRoomCoords(coords)) {
				return d;
			}
		}
		Utils.assert(false, 'Room does not have a free edge: $room');
		return null;
	}
	
	/**
	 * Sets up the dungeon's entrance room.
	 * 
	 * @param levels    the keyLevel -> room-set mapping to update
	 * @see KeyLevelRoomMapping 
	 */
	private function initEntranceRoom(levels:KeyLevelRoomMapping):Void
	{
		var coords:Coords = null;
		var possibleEntries:Array<Coords> = Lambda.array(constraints.initialCoords());
		coords = possibleEntries[random.nextInt(possibleEntries.length)];
		Utils.assert(constraints.validRoomCoords(coords));
		
		var entry:Room = new Room(coords, null, new Symbol(Symbol.START), new Condition());
		dungeon.add(entry);
		
		levels.addRoom(0, entry);
	}
	
	/**
	 * Fill the dungeon's space with rooms and doors (some locked).
	 * Keys are not inserted at this point.
	 * 
	 * @param levels    the keyLevel -> room-set mapping to update
	 * @throws RetryException if it fails
	 * @see KeyLevelRoomMapping
	 */
	private function placeRooms(levels:KeyLevelRoomMapping):Void
	{
		var roomsPerLock:Int;
		if (constraints.getMaxKeys() > 0) {
			roomsPerLock = Std.int(constraints.getMaxSpaces() / constraints.getMaxKeys());
		} else {
			roomsPerLock = constraints.getMaxSpaces();
		}
		
		// keyLevel: the number of keys required to get to the new room
		var keyLevel:Int = 0;
		var latestKey:Symbol = null;
		// condition that must hold true for the player to reach the new room
		// (the set of keys they must have).
		var cond:Condition = new Condition();
		
		var roomCount = dungeon.roomCount(); // fix for cpp target
		// Loop to place rooms and link them
		while (roomCount < constraints.getMaxSpaces())
		{
			var doLock:Bool = false;
			
			// Decide whether we need to place a new lock
			// (Don't place the last lock, since that's reserved for the boss)
			if (levels.getRooms(keyLevel).length >= roomsPerLock &&
			        keyLevel < constraints.getMaxKeys() - 1)
			{
				latestKey = new Symbol(keyLevel++);
				cond = cond.andSymbol(latestKey);
				doLock = true;
			}
			
			// Find an existing room with a free edge:
			var parentRoom:Room = null;
			if (!doLock && random.nextInt(10) > 0) {
				parentRoom = chooseRoomWithFreeEdge(levels.getRooms(keyLevel));
			}
			if (parentRoom == null) {
				parentRoom = chooseRoomWithFreeEdge(dungeon.getRooms());
				doLock = true;
			}
			
			// Decide which direction to put the new room in relative to the parent
			var d:Direction = chooseFreeEdge(parentRoom);
			var coords:Coords = parentRoom.coords.nextInDirection(d);
			var room:Room = new Room(coords, parentRoom, null, cond);
			
			// Add the room to the dungeon
			Utils.assert(dungeon.get(room.coords) == null);
			dungeon.add(room);
			parentRoom.addChild(room);
			dungeon.link(parentRoom, room, doLock ? latestKey : null);
			
			levels.addRoom(keyLevel, room);
			
			roomCount = dungeon.roomCount(); // fix for cpp target
		}
	}
	
	/**
	 * Places the BOSS and GOAL rooms within the dungeon, in existing rooms.
	 * These rooms are moved into the next keyLevel.
	 * 
	 * @param levels    the keyLevel -> room-set mapping to update
	 * @throws RetryException if it fails
	 * @see KeyLevelRoomMapping
	 */
	private function placeBossGoalRooms(levels:KeyLevelRoomMapping):Void
	{
		var possibleGoalRooms:Array<Room> = new Array<Room>();
		
		for (room in dungeon.getRooms())
		{
			if (room.getChildren().length > 0 || room.getItem() != null) {
				continue;
			}
			var parent:Room = room.getParent();
			if (parent == null || parent.getChildren().length != 1 ||
			        room.getItem() != null ||
			        !parent.getPrecond().impliesCondition(room.getPrecond())) {
				continue;
			}
			possibleGoalRooms.push(room);
		}
		
		if (possibleGoalRooms.length == 0) {
			throw new RetryException();
		}
		
		var goalRoom:Room = possibleGoalRooms[random.nextInt(possibleGoalRooms.length)];
		var bossRoom:Room = goalRoom.getParent();
		
		goalRoom.setItem(new Symbol(Symbol.GOAL));
		bossRoom.setItem(new Symbol(Symbol.BOSS));
		
		var oldKeyLevel:Int = bossRoom.getPrecond().getKeyLevel();
		var newKeyLevel:Int = Std.int(Math.min(levels.keyCount(), constraints.getMaxKeys()));
		var oklRooms:Array<Room> = levels.getRooms(oldKeyLevel);
		oklRooms.remove(goalRoom);
		oklRooms.remove(bossRoom);
		
		levels.addRoom(newKeyLevel, goalRoom);
		levels.addRoom(newKeyLevel, bossRoom);
		
		var bossKey:Symbol = new Symbol(newKeyLevel - 1);
		var precond:Condition = bossRoom.getPrecond().andSymbol(bossKey);
		bossRoom.setPrecond(precond);
		goalRoom.setPrecond(precond);
		
		if (newKeyLevel == 0) {
			dungeon.link(bossRoom.getParent(), bossRoom);
		} else {
			dungeon.link(bossRoom.getParent(), bossRoom, bossKey);
		}
		dungeon.link(bossRoom, goalRoom);
	}
	
	/**
	 * Removes the given {@link Room} and all its descendants from the given
	 * list.
	 * 
	 * @param rooms the list of Rooms to remove nodes from
	 * @param room  the Room whose descendants to remove from the list
	 */
	private function removeDescendantsFromList(rooms:Array<Room>, room:Room):Void
	{
		rooms.remove(room);
		for (child in room.getChildren()) {
			removeDescendantsFromList(rooms, child);
		}
	}
	
	/**
	 * Adds extra conditions to the given {@link Room}'s preconditions and all
	 * of its descendants.
	 * 
	 * @param room  the Room to add extra preconditions to
	 * @param cond  the extra preconditions to add
	 */
	private function addPrecond(room:Room, cond:Condition):Void
	{
		room.setPrecond(room.getPrecond().andCondition(cond));
		for (child in room.getChildren()) {
			addPrecond(child, cond);
		}
	}
	
	/**
	 * Randomly locks descendant rooms of the given {@link Room} with
	 * {@link Edge}s that require the switch to be in the given state.
	 * <p>
	 * If the given state is EITHER, the required states will be random.
	 * 
	 * @param room          the room whose child to lock
	 * @param givenState    the state to require the switch to be in for the
	 *                      child rooms to be accessible
	 * @return              true if any locks were added, false if none were
	 *                      added (which can happen due to the way the random
	 *                      decisions are made)
	 * @see Condition.SwitchState
	 */
	private function switchLockChildRooms(room:Room, givenState:SwitchState):Bool
	{
		var anyLocks:Bool = false;
		var state:SwitchState = givenState != SwitchState.EITHER
		        ? givenState
		        : (random.nextInt(2) == 0
		            ? SwitchState.ON
		            : SwitchState.OFF);
		
		for (d in Direction.values())
		{
			if (room.getEdge(d) != null)
			{
				var nextRoom:Room = dungeon.get(room.coords.nextInDirection(d));
				if (room.getChildren().has(nextRoom))
				{
					if (room.getEdge(d).getSymbol() == null && random.nextInt(4) != 0)
					{
						dungeon.link(room, nextRoom, state.toSymbol());
						addPrecond(nextRoom, new Condition(state.toSymbol()));
						anyLocks = true;
					}
					else
					{
						var temp:Bool = switchLockChildRooms(nextRoom, state);
						if (temp == true) {
							anyLocks = temp;
						}
					}
					
					if (givenState == SwitchState.EITHER) {
						state = state.invert();
					}
				}
			}
		}
		return anyLocks;
	}
	
	/**
	 * Returns a path from the goal to the dungeon entrance, along the 'parent'
	 * relations.
	 * 
	 * @return  a list of linked {@link Room}s starting with the goal room and
	 *          ending with the start room.
	 */
	private function getSolutionPath():Array<Room>
	{
		var solution:Array<Room> = new Array<Room>();
		var room:Room = dungeon.findGoal();
		while (room != null)
		{
			solution.push(room);
			room = room.getParent();
		}
		return solution;
	}
	
	/**
	 * Makes some {@link Edge}s within the dungeon require the dungeon's switch
	 * to be in a particular state, and places the switch in a room in the
	 * dungeon.
	 * 
	 * @throws RetryException if it fails
	 */
	private function placeSwitches():Void
	{
		// Possible TODO: have multiple switches on separate circuits
		// At the moment, we only have one switch per dungeon.
		if (constraints.getMaxSwitches() <= 0) return;
		
		var solution:Array<Room> = getSolutionPath();
		
		for (attempt in 0...10)
		{
			var rooms:Array<Room> = dungeon.getRooms().copy();
			rooms.shuffle(random);
			solution.shuffle(random);
			
			// Pick a base room from the solution path so that the player
			// will have to encounter a switch-lock to solve the dungeon.
			var baseRoom:Room = null;
			for (room in solution) {
				if (room.getChildren().length > 1 && room.getParent() != null) {
					baseRoom = room;
					break;
				}
			}
			if (baseRoom == null) throw new RetryException();
			var baseRoomCond:Condition = baseRoom.getPrecond();
			
			removeDescendantsFromList(rooms, baseRoom);
			
			var switchRoom:Room = null;
			for (room in rooms) {
				if (room.getItem() == null &&
				        baseRoomCond.impliesCondition(room.getPrecond())) {
					switchRoom = room;
					break;
				}
			}
			if (switchRoom == null) continue;
			
			if (switchLockChildRooms(baseRoom, SwitchState.EITHER)) {
				switchRoom.setItem(new Symbol(Symbol.SWITCH));
				return;
			}
		}
		throw new RetryException();
	}
	
	/**
	 * Randomly links up some adjacent rooms to make the dungeon graph less of
	 * a tree.
	 * 
	 * @throws RetryException if it fails
	 */
	private function graphify():Void
	{
		for (room in dungeon.getRooms())
		{
			if (room.isGoal() || room.isBoss()) continue;
			
			for (d in Direction.values())
			{
				if (room.getEdge(d) != null) continue;
				
				var nextRoom:Room = dungeon.get(room.coords.nextInDirection(d));
				if (nextRoom == null || nextRoom.isGoal() || nextRoom.isBoss()) {
					continue;
				}
				
				var forwardImplies:Bool = room.precond.impliesCondition(nextRoom.precond);
				var backwardImplies:Bool = nextRoom.precond.impliesCondition(room.precond);
				if (forwardImplies && backwardImplies) {
					// both rooms are at the same keyLevel.
					if (random.nextInt(5) != 0) continue;
					dungeon.link(room, nextRoom);
				} else {
					var difference:Symbol = room.precond.singleSymbolDifference(
					        nextRoom.precond);
					if (difference == null || (!difference.isSwitchState() &&
					        random.nextInt(5) != 0)) {
						continue;
					}
					dungeon.link(room, nextRoom, difference);
				}
			}
		}
	}
	
	/**
	 * Comparator objects for sorting {@link Room}s in a couple of different
	 * ways. These are used to determine in which rooms of a given keyLevel it
	 * is best to place the next key.
	 * 
	 * @see #placeKeys
	 */
	private static var EDGE_COUNT_COMPARATOR:Room->Room->Int = function (a:Room, b:Room) {
		return a.linkCount() - b.linkCount();
	};
	private static var INTENSITY_COMPARATOR:Room->Room->Int = function (a:Room, b:Room) {
		return a.getIntensity() > b.getIntensity() ? -1
		        : a.getIntensity() < b.getIntensity() ? 1 : 0;
	};
	
	/**
	 * Places keys within the dungeon in such a way that the dungeon is
	 * guaranteed to be solvable.
	 * 
	 * @param levels    the keyLevel -> room-set mapping to use
	 * @throws RetryException if it fails
	 * @see KeyLevelRoomMapping
	 */
	private function placeKeys(levels:KeyLevelRoomMapping):Void
	{
		// Now place the keys. For every key-level but the last one, place a
		// key for the next level in it, preferring rooms with fewest links
		// (dead end rooms).
		for (key in 0...(levels.keyCount() - 1))
		{
			var rooms:Array<Room> = levels.getRooms(key);
			
			rooms.shuffle(random);
			// Collections.sort is stable: it doesn't reorder "equal" elements,
			// which means the shuffling we just did is still useful.
			rooms.sort(INTENSITY_COMPARATOR);
			// Alternatively, use the EDGE_COUNT_COMPARATOR to put keys at
			// 'dead end' rooms.
			
			var placedKey = false;
			for (room in rooms) {
				if (room.getItem() == null) {
					room.setItem(new Symbol(key));
					placedKey = true;
					break;
				}
			}
			Utils.assert(placedKey == true);
		}
	}
	
	private static inline var INTENSITY_GROWTH_JITTER:Float = 0.1;
	private static inline var INTENSITY_EASE_OFF:Float = 0.2;
	
	/**
	 * Recursively applies the given intensity to the given {@link Room}, and
	 * higher intensities to each of its descendants that are within the same
	 * keyLevel.
	 * <p>
	 * Intensities set by this method may (will) be outside of the normal range
	 * from 0.0 to 1.0. See {@link #normalizeIntensity} to correct this.
	 * 
	 * @param room      the room to set the intensity of
	 * @param intensity the value to set intensity to (some randomn variance is
	 *                  added)
	 * @see Room
	 */
	private function applyIntensity(room:Room, intensity:Float):Float
	{
		intensity *= 1.0 - INTENSITY_GROWTH_JITTER / 2.0 +
		        INTENSITY_GROWTH_JITTER * random.randomFloat();
		
		room.setIntensity(intensity);
		
		var maxIntensity:Float = intensity;
		for (child in room.getChildren()) {
			if (room.getPrecond().impliesCondition(child.getPrecond())) {
				maxIntensity = Math.max(maxIntensity, applyIntensity(child,
				        intensity + 1.0));
			}
		}
		return maxIntensity;
	}
	
	/**
	 * Scales intensities within the dungeon down so that they all fit within
	 * the range 0 <= intensity < 1.0.
	 * 
	 * @see Room
	 */
	private function normalizeIntensity():Void
	{
		var maxIntensity:Float = 0.0;
		for (room in dungeon.getRooms()) {
			maxIntensity = Math.max(maxIntensity, room.getIntensity());
		}
		for (room in dungeon.getRooms()) {
			room.setIntensity(room.getIntensity() * 0.99 / maxIntensity);
		}
	}
	
	/**
	 * Computes the 'intensity' of each {@link Room}. Rooms generally get more
	 * intense the deeper they are into the dungeon.
	 * 
	 * @param levels    the keyLevel -> room-set mapping to update
	 * @throws RetryException if it fails
	 * @see KeyLevelRoomMapping
	 * @see Room
	 */
	private function computeIntensity(levels:KeyLevelRoomMapping):Void
	{
		var nextLevelBaseIntensity:Float = 0.0;
		for (level in 0...levels.keyCount())
		{
			var intensity:Float = nextLevelBaseIntensity * (1.0 - INTENSITY_EASE_OFF);
			
			for (room in levels.getRooms(level))
			{
				if (room.getParent() == null || 
				    !room.getParent().getPrecond().impliesCondition(room.getPrecond()))
				{
					nextLevelBaseIntensity = Math.max(
					    nextLevelBaseIntensity,
					    applyIntensity(room, intensity));
				}
			}
		}
		
		normalizeIntensity();
		
		dungeon.findBoss().setIntensity(1.0);
		dungeon.findGoal().setIntensity(0.0);
	}
	
	/**
	 * Checks with the
	 * {@link net.bytten.metazelda.constraints.IDungeonConstraints} that the
	 * dungeon is OK to use.
	 * 
	 * @throws RetryException if the IDungeonConstraints decided generation must
	 *                        be re-attempted
	 * @see net.bytten.metazelda.constraints.IDungeonConstraints
	 */
	private function checkAcceptable():Void
	{
		if (!constraints.isAcceptable(dungeon)) {
			throw new RetryException();
		}
	}
	
	public function generate():Void
	{
		var attempt = 0;
		while (true)
		{
			try
			{
				dungeon = new Dungeon();
				
				// Maps keyLevel -> Rooms that were created when lockCount had that value
				var levels:KeyLevelRoomMapping = new KeyLevelRoomMapping(constraints);
				
				// Create the entrance to the dungeon:
				initEntranceRoom(levels);
				
				// Fill the dungeon with rooms:
				placeRooms(levels);
				
				// Place the boss and goal rooms:
				placeBossGoalRooms(levels);
				
				// Place switches and the locks that require it:
				placeSwitches();
				
				// Make the dungeon less tree-like:
				graphify();
				
				computeIntensity(levels);
				
				// Place the keys within the dungeon:
				placeKeys(levels);
				
				checkAcceptable();
				
				return;
			}
			catch (e:RetryException)
			{
				if (++attempt > MAX_RETRIES) {
					throw "Dungeon generator failed";
				}
				#if debug
				trace("Retrying dungeon generation...");
				#end
			}
		}
	}
	
	public function getDungeon():IDungeon
	{
		return dungeon;
	}
	
	public function getSeed():Int
	{
		return seed;
	}
}

/**
 * Maps 'keyLevel' to the set of rooms within that keyLevel.
 * <p>
 * A 'keyLevel' is the count of the number of unique keys are needed for all
 * the locks we've placed. For example, all the rooms in keyLevel 0 are
 * accessible without collecting any keys, while to get to rooms in
 * keyLevel 3, the player must have collected at least 3 keys.
 */
private class KeyLevelRoomMapping
{
	private var map:Array<Array<Room>>;
	
	public function new(constraints:IDungeonConstraints)
	{
		map = new Array<Array<Room>>();
	}
	
	public function getRooms(keyLevel:Int):Array<Room>
	{
		while (keyLevel >= map.length) {
			map.push(null);
		}
		if (map[keyLevel] == null) {
			map[keyLevel] = new Array<Room>();
		}
		return map[keyLevel];
	}
	
	public function addRoom(keyLevel:Int, room:Room):Void
	{
		getRooms(keyLevel).push(room);
	}
	
	public function keyCount():Int
	{
		return map.length;
	}
}

/**
 * Thrown by several IDungeonGenerator methods that can fail.
 * Should be caught and handled in {@link #generate}.
 */
private class RetryException
{
	public var message(default, null):String;
	public var info(default, null):haxe.PosInfos;
	
	public function new(message:String="", ?info:haxe.PosInfos)
	{
		this.message = message;
		this.info = info;
	}
	
	public function toString():String
	{
		var str:String = 'RetryException: $message';
		if (info != null) {
			str += ' at ${info.className}/${info.methodName}():${info.lineNumber}';
		}
		return str;
	}
}
