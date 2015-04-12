class Lava extends Platform
{
	public function new(w : Float = 100, h : Float = 100)
	{
		super(w,h,0x550000);
		name = "Lava";
	}

	override public function clone() : Lava
	{
		var rval = new Lava(quad.width, quad.height);
		rval.x = x; rval.y = y;
		return rval;
	}
}