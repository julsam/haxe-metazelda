package metazelda.generators;

import de.polygonal.ds.ListSet;
import metazelda.constraints.IDungeonConstraints;
import metazelda.Dungeon;
import metazelda.Edge;
import metazelda.Room;
import metazelda.Symbol;
import metazelda.util.AStar;
import metazelda.util.AStar.IRoom;
import metazelda.util.Coords;
import metazelda.util.Direction;
import metazelda.util.Utils;

/**
 * Extends DungeonGenerator to choose the least nonlinear one immediately
 * available. This saves the player from having to do a lot of backtracking.
 * 
 * Ignores switches for now.
 */
class LinearDungeonGenerator extends DungeonGenerator
{
	public static inline var MAX_ATTEMPTS = 10;
	
	public function new(seed:Int, constraints:IDungeonConstraints) 
	{
		super(seed, constraints);
	}
	
	private function astar(start:Coords, goal:Coords, keyLevel:Int):Array<Coords>
	{
		var astar_:AStar = new AStar(new AStarMap(keyLevel, dungeon), start, goal);
		return astar_.solve();
	}
	
	/**
	 * Nonlinearity is measured as the number of rooms the player would have to
	 * pass through multiple times to get to the goal room (collecting keys and
	 * unlocking doors along the way).
	 * 
	 * Uses A* to find a path from the entry to the first key, from each key to
	 * the next key and from the last key to the goal.
	 * 
	 * @return  The number of rooms passed through multiple times
	 */
	public function measureNonlinearity():Int
	{
		var keyRooms:Array<Room> = new Array<Room>();
		for (i in 0...constraints.getMaxKeys()) {
			keyRooms.push(null);
		}
		for (room in dungeon.getRooms()) {
			if (room.getItem() == null) continue;
			var item:Symbol = room.getItem();
			if (item.getValue() >= 0 && item.getValue() < keyRooms.length) {
				keyRooms[item.getValue()] = room;
			}
		}
		
		var current:Room = dungeon.findStart();
		var goal:Room = dungeon.findGoal();
		Utils.assert(current != null && goal != null);
		var nextKey:Int = 0;
		var nonlinearity:Int = 0;
		
		var visitedRooms:ListSet<Coords> = new ListSet<Coords>();
		while (current != goal)
		{
			var intermediateGoal:Room;
			if (nextKey == constraints.getMaxKeys()) {
				intermediateGoal = goal;
			} else {
				intermediateGoal = keyRooms[nextKey];
			}
			
			var steps:Array<Coords> = astar(current.coords, intermediateGoal.coords, nextKey);
			for (c in steps) {
				if (Lambda.exists(visitedRooms, function (a) return a.equals(c))) {
					nonlinearity++;
				}
			}
			for (step in steps) {
				visitedRooms.set(step);
			}
			
			nextKey++;
			current = dungeon.get(steps[steps.length - 1]);
		}
		
		return nonlinearity;
	}
	
	override public function generate():Void
	{
		var attempts:Int = 0;
		var currentNonlinearity:Int = Utils.MAX_VALUE;
		var bestAttempt = 0;
		var currentBest:Dungeon = null;
		
		while (attempts++ < MAX_ATTEMPTS)
		{
			super.generate();
			
			var nonlinearity:Int = measureNonlinearity();
			#if debug
				trace('Dungeon $attempts nonlinearity: $nonlinearity');
			#end
			if (nonlinearity < currentNonlinearity) {
				currentNonlinearity = nonlinearity;
				bestAttempt = attempts;
				currentBest = dungeon;
			}
		}
		Utils.assert(currentBest != null);
		#if debug
			trace('Chose $bestAttempt nonlinearity: $currentNonlinearity');
		#end
		dungeon = currentBest;
	}
}

private class AStarRoom implements IRoom
{
	var keyLevel:Int;
	var room:Room;
	
	public function new(keyLevel:Int, room:Room)
	{
		this.keyLevel = keyLevel;
		this.room = room;
	}
	
	public function neighbors():List<Coords>
	{
		var result:List<Coords> = new List<Coords>();
		for (d in Direction.values()) {
			var e:Edge = room.getEdge(d);
			if (e != null && (!e.hasSymbol() || e.getSymbol().getValue() < keyLevel)) {
				result.add(room.coords.nextInDirection(d));
			}
		}
		return result;
	}
}

private class AStarMap implements metazelda.util.AStar.IMap
{
	var keyLevel:Int;
	var dungeon:Dungeon;
	
	public function new(keyLevel:Int, dungeon:Dungeon)
	{
		this.keyLevel = keyLevel;
		this.dungeon = dungeon;
	}
	
	public function get(xy:Coords):IRoom
	{
		return new AStarRoom(keyLevel, dungeon.get(xy));
	}
}
