import starling.display.*;
import flash.geom.Rectangle;

class Platform extends Sprite implements Collidable
{
	private var rect : Rectangle;
	private var color : UInt;
	private static inline var TILE_SIZE = 64;

	public function new(w : Float = 100, h : Float = 100)
	{
		super();
		rect = new Rectangle(x,y,w,h);
		setImage(w,h);
		name = "Platform";
		blendMode = BlendMode.NONE;
	}

	private function setImage(w : Float, h : Float)
	{
		var i = 0.0;
		while(i < w)
		{
			var j = 0.0;
			while(j < h)
			{
				var im = new Image(Root.assets.getTexture(j == 0 ? "grass" : "grass2"));
				im.x = i; im.y = j;
				im.scaleX = im.scaleY = TILE_SIZE / im.width;
				addChild(im);
				j += TILE_SIZE;
			}
			i += TILE_SIZE;
		}
		flatten();
	}

	public function clone() : Platform
	{
		var rval = new Platform(rect.width, rect.height);
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