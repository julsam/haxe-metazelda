package metazelda.util;

import de.polygonal.ds.Comparable;
import haxe.ds.BalancedTree;

class SimpleTreeMap<K:Comparable<K>, V> extends BalancedTree<K, V>
{
	override function compare(k1:K, k2:K) {
		return k1.compare(k2);
	}
	
	public function values():Array<V>
	{
		return Lambda.array(this);
	}
	
	public function size():Int
	{
		return Lambda.array(this).length;
	}
	
	public function containsValue(value:V):Bool
	{
		for (el in iterator()) {
			if (el == value) {
				return true;
			}
		}
		return false;
	}
}
