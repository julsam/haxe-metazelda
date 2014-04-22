package metazelda.util;


class Utils
{
	public static inline var MAX_VALUE =
	#if neko
	0x3fffffff;
	#else
	0x7fffffff;
	#end
	
	public static function assert(cond:Bool, msg:String="", ?info:haxe.PosInfos):Void
	{
		if (cond != true)
		{
			throw 'Assertation failed: "$msg"\n${info.fileName}:${info.lineNumber}: Assertation failed in ${info.className}/${info.methodName}()';
		}
	}
	
	/**
	 * Randomly permute the specified array using the specified source of randomness.
	 * @param a     array to shuffle
	 * @param rnd   random number generator
	 * @return a    the shuffled array
	 */
	@:generic
	public static function shuffle<T>(array:Array<T>, rnd:Random):Array<T>
	{
		var size:Int = array.length;
		var int1 = 0;
		var int2 = 0;
		var tempObject:Null<T> = null;
		
		for (i in 0...size)
		{
			int1 = rnd.nextInt(size);
			int2 = rnd.nextInt(size);
			tempObject = array[int1];
			array[int1] = array[int2];
			array[int2] = tempObject;
		}
		return array;
	}
}
