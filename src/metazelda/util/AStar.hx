package metazelda.util;

import de.polygonal.ds.ListSet;
import de.polygonal.ds.Prioritizable;
import de.polygonal.ds.PriorityQueue;

class AStar
{
	private var gScore:SimpleTreeMap<Coords, Float> = new SimpleTreeMap<Coords, Float>();
	private var fScore:SimpleTreeMap<Coords, Float> = new SimpleTreeMap<Coords, Float>();
	private var cameFrom:SimpleTreeMap<Coords, Coords> = new SimpleTreeMap<Coords, Coords>();
	private var closedSet:ListSet<Coords> = new ListSet<Coords>();
	private var openSet:PriorityQueue<PriorityCoords> = new PriorityQueue<PriorityCoords>(true, 110);
	private var map:IMap;
	private var from:Coords;
	private var to:Coords;
	
	public function new(map:IMap, from:Coords, to:Coords)
	{
		this.map = map;
		this.from = from;
		this.to = to;
		/*
		openSet.enqueue(new PriorityCoords(1, new Coords( -1, 5)));
		openSet.enqueue(new PriorityCoords(10, new Coords( -3, -3)));
		openSet.enqueue(new PriorityCoords(5, new Coords( 5, 7)));
		trace(openSet);
		*/
	}
	
	private function heuristicDistance(pos:Coords):Float
	{
		// Manhattan distance heuristic
		return Math.abs(to.x - pos.x) + Math.abs(to.y - pos.y);
	}
	
	private function updateFScore(pos:Coords):Void
	{
		fScore.set(pos, gScore.get(pos) + heuristicDistance(pos));
	}
	
	public function solve():Array<Coords>
	{
		/* See this page for the algorithm:
		 * http://en.wikipedia.org/wiki/A*_search_algorithm
		 */
		openSet.enqueue(makeCoords(from));
		gScore.set(from, 0.0);
		updateFScore(from);
		
		while (!openSet.isEmpty())
		{
			var current:Coords = openSet.dequeue().coords;
			
			if (current.equals(to)) {
				return reconstructPath();
			}
			
			closedSet.set(current);
			
			for (neighbor in map.get(current).neighbors())
			{
				// if closedSet contains neighbor
				if (Lambda.exists(closedSet, function (el) return el.equals(neighbor))) {
					continue;
				}
				
				var dist:Float = current.distance(neighbor);
				var g:Float = gScore.get(current) + dist;
				
				if (!opensetContains(neighbor) || g < gScore.get(neighbor)) {
					cameFrom.set(neighbor, current);
					gScore.set(neighbor, g);
					updateFScore(neighbor);
					openSet.enqueue(makeCoords(neighbor));
				}
			}
		}
		return null;
	}
	
	private function opensetContains(coords:Coords):Bool
	{
		for (el in openSet) {
			if (el.coords.equals(coords)) {
				return true;
			}
		}
		return false;
	}
	
	private inline function makeCoords(from:Coords):PriorityCoords
	{
		return new PriorityCoords(fScore.get(from), from);
	}
	
	private function reconstructPath():Array<Coords>
	{
		var result:Array<Coords> = new Array<Coords>();
		var current:Coords = to;
		while (!current.equals(from)) {
			result.push(current); // TODO: current.copy() ?
			current = cameFrom.get(current);
		}
		result.reverse();
		return result;
	}
	
	private function nextStep():Coords
	{
		var path:Array<Coords> = solve();
		if (path == null || path.length == 0) return null;
		return path[0];
	}
}

class PriorityCoords implements Prioritizable
{
	public var coords:Coords;
	
	public var priority:Float;
	public var position:Int;
	
	public function new(priority:Float, coords:Coords)
	{
		this.priority = priority;
		this.coords = coords;
	}
	
	public inline function toString():String
	{
		return coords.toString();
	}
}

interface IRoom {
	public function neighbors():List<Coords>;
}

interface IMap {
	public function get(xy:Coords):IRoom;
}