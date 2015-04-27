import flash.display.*;
import starling.display.Image;
import starling.textures.Texture;
import flash.geom.Point;

class HitCircle extends Image
{
	private static function getTexture() : Texture
	{
		var s = new Shape();
		s.graphics.beginFill(Std.random(0xffffff));
		s.graphics.drawCircle(128,128,128);
		s.graphics.endFill();

		var data = new BitmapData(256,256,true,0);
		data.draw(s);
		return Texture.fromBitmapData(data);
	}

	public function new(?im : Image)
	{
		super(getTexture());
		if(im != null)
		{
			x = im.x;
			y = im.y;
			scaleX = scaleY = im.scaleX;
			pivotX = pivotY = radius();
		}
		alpha = 0.5;
	}

	public function intersects(c : HitCircle) : Bool
	{
		var pos1 = getPosition();
		var pos2 = c.getPosition();
		var deltaX = pos1.x - pos2.x;
		var deltaY = pos1.y - pos2.y;
		var dist = deltaX*deltaX + deltaY*deltaY;
		var radial = radius() + c.radius();
		if(radial < 0) trace(radial);
		return dist <= radial*radial;
	}

	public function getPosition() : Point
	{	return localToGlobal(new Point(x,y));}

	public inline function radius() : Float
	{	return Math.abs(128 * scaleX);}
}