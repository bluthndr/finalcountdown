import starling.display.*;
import flash.geom.Rectangle;

class Platform extends Sprite implements Collidable
{
	private var rect : Rectangle;
	private var color : UInt;
	public function new(w : Float = 100, h : Float = 100, c: UInt = 0x777777)
	{
		super();
		rect = new Rectangle(x,y,w,h);
		color = c;
		addChild(new Quad(w,h,c));
		name = "Platform";
	}

	public function clone() : Platform
	{
		var rval = new Platform(rect.width, rect.height, color);
		rval.x = x; rval.y = y;
		return rval;
	}

	public function getRect() : Rectangle
	{
		rect.x = x; rect.y = y;
		return rect;
	}

	public function toString() : String
	{
		return Std.string(new flash.geom.Point(x,y)) + " ("
		+ Std.string(rect.width) + "," + Std.string(rect.height) + ")";
	}
}