class Wall extends Platform
{
	public function new(w : Float = 100, h : Float = 100, c: UInt = 0)
	{
		super(w,h,c);
		name = "Wall";
	}

	override public function clone() : Wall
	{
		var rval = new Wall(rect.width, rect.height, color);
		rval.x = x; rval.y = y;
		return rval;
	}
}