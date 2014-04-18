package metazelda.viewer.util;

class Utils
{
	/**
	 * Generate a color from HSV / HSB components.
	 * 
	 * @param	hue         Hue : a number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	sat         Saturation : a number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	val         Value : a number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @return	The color as an integer
	 */
	public static function hsv2int(h:Float, s:Float, v:Float):Int
	{
		var d:Float = (h % 360) / 60;
		if (d < 0) d += 6;
		var hf:Int = Math.floor(d);
		var hi:Int = hf % 6;
		var f:Float = d - hf;
		
		var v:Float = v;
		var p:Float = v * (1 - s);
		var q:Float = v * (1 - f * s);
		var t:Float = v * (1 - (1 - f) * s);
		
		var rgb = null;
		switch(hi)
		{
			case 0: rgb = { r: v, g: t, b: p };
			case 1: rgb = { r: q, g: v, b: p };
			case 2: rgb = { r: p, g: v, b: t };
			case 3: rgb = { r: p, g: q, b: v };
			case 4: rgb = { r: t, g: p, b: v };
			case 5: rgb = { r: v, g: p, b: q };
		}
		return Std.int(rgb.r * 255) << 16 | Std.int(rgb.g * 255) << 8 | Std.int(rgb.b * 255); 
	}
}
