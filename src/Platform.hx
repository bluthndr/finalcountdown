import starling.display.*;
import flash.geom.Rectangle;

class Platform extends Sprite implements Collidable
{
	private var quad : Quad;
	public function new(w : Float = 100, h : Float = 100, c: UInt = 0x777777)
	{
		super();
		quad = new Quad(w,h,c);
		addChild(quad);
		name = "Platform";
	}

	public function clone() : Platform
	{
		var rval = new Platform(quad.width, quad.height, quad.color);
		rval.x = x; rval.y = y;
		return rval;
	}

	public function getRect() : Rectangle
	{	return new Rectangle(x,y, quad.width, quad.height);}
}