import starling.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

class GameSprite extends Sprite implements Collidable
{
	private var vel : Point;
	private var lastPos : Point;
	private var speed : Float;
	private var weight : Float;
	private var platOn : Platform;
	private var charWidth : Float;
	private var charHeight : Float;
	private var curRect : Rectangle;
	private var lastRect : Rectangle;

	//speed is the magnitude of the velocity vector squared
	private static inline var LOW_BOUNCE_BOUND = 1024;//32 squared
	private static inline var HIGH_BOUNCE_BOUND = 6400;//80 sqaured
	/*If sprite hits a wall when:

	LOW_BOUNCE_BOUND <= magnitude <= GameSprite.HIGH_BOUNCE_BOUND,
	then the sprite will bounce of the wall.

	magnitude > GameSprite.HIGH_BOUNCE_BOUND, then the sprite will crash
	through the wall*/

	private function new()
	{
		super();
		vel = new Point();
		lastPos = new Point();
		weight = 0.15;
		speed = 10;
		platOn = null;
	}

	public function getPosition() : Point
	{	return new Point(x,y);}

	public function getVelocity() : Point
	{	return vel.clone();}

	public function platformCollision(plat : Platform) : Bool
	{
		if(!onPlatform() && vel.y > 0 && lastPos.y <= plat.y - charHeight
		&& this.getRect().intersects(plat.getRect()))
		{
			y = plat.y - charHeight;
			vel.y = 0;
			platOn = plat;
		}
		return onPlatform();
	}

	public function wallCollision(wall : Platform)
	{
		if(this.getRect().intersects(wall.getRect()))
		{
			if(!onPlatform() && vel.y > 0 && lastPos.y <= wall.y - charHeight)
			{
				/*haxe.Log.clear();
				trace("Top Collision!", x, y , wall.x, wall.y);*/
				y = wall.y - charHeight;
				vel.y = 0;
				platOn = wall;
			}
			else if(vel.x >= 0 && lastPos.x <= wall.x - charWidth)
			{
				/*haxe.Log.clear();
				trace("Left Collision!", x, y , wall.x, wall.y);*/
				if(GameSprite.LOW_BOUNCE_BOUND <= magnitude()) vel.x *= -1;
				else
				{
					vel.x = 0;
					x = wall.x - charWidth;
				}
			}
			else if(vel.x <= 0 && lastPos.x >= wall.x + wall.width)
			{
				/*haxe.Log.clear();
				trace("Right Collision!", x, y , wall.x, wall.y);*/
				if(GameSprite.LOW_BOUNCE_BOUND <= magnitude()) vel.x *= -1;
				else
				{
					x = wall.x + wall.width;
					vel.x = 0;
				}
			}
			else if(vel.y < 0 && lastPos.y >= wall.y + wall.height)
			{
				/*haxe.Log.clear();
				trace("Bottom Collision!", x, y , wall.x, wall.y);*/
				if(GameSprite.LOW_BOUNCE_BOUND <= magnitude()) vel.y *= -1;
				else
				{
					y = wall.y + wall.height;
					vel.y = 0;
				}
			}
		}
	}

	public function lavaCollision(lava : Lava)
	{	wallCollision(lava);}

	public function onPlatform() : Bool
	{	return platOn != null;}

	public inline function magnitude() : Float
	{	return vel.x*vel.x + vel.y*vel.y;}

	public function gravity()
	{
		if(platOn == null)
		{
			if(vel.y < -1)
			{	vel.y *= 1 - weight;}
			else if(vel.y > 0)
			{
				if(vel.y < 15)
					vel.y *= 1 + (weight/2);
			}
			else
			{	vel.y = 10 * weight;}
		}
		move();
		if(onPlatform())
		{
			var rect = getRect().clone();
			rect.y += 10* weight;
			if(!rect.intersects(platOn.getRect()))
				platOn = null;
		}
	}

	private function move()
	{
		lastPos.x = x; lastPos.y = y;
		lastRect.x = curRect.x; lastRect.y = curRect.y;

		x += vel.x; y += vel.y;
		curRect.x = x; curRect.y = y;
	}

	public function getRect() : Rectangle
	{	return curRect.union(lastRect);}

	public function getLocalRect() : Rectangle
	{
		return new Rectangle(x, y, width, height);
	}
}