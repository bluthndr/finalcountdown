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

	//speed is the magnitude of the velocity vector squared
	private static inline var LOW_BOUNCE_BOUND = 900;//30 squared
	private static inline var HIGH_BOUNCE_BOUND = 3600;//60 sqaure
	/*If sprite hits a wall when:

	LOW_BOUNCE_BOUND <= speed <= HIGH_BOUNCE_BOUND,
	then the sprite will bounce of the wall.

	speed > HIGH_BOUNCE_BOUND, then the sprite will crash
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
		if(!onPlatform() && vel.y > 0 && lastPos.y <= plat.y - height
		&& this.getRect().intersects(plat.getRect()))
		{
			y = plat.y - height;
			vel.y = 0;
			platOn = plat;
		}
		return onPlatform();
	}

	public function wallCollision(wall : Wall)
	{
		if(this.getRect().intersects(wall.getRect()))
		{
			if(!onPlatform() && vel.y > 0 && lastPos.y <= wall.y - height)
			{
				/*haxe.Log.clear();
				trace("Top Collision!", x, y , wall.x, wall.y);*/
				y = wall.y - height;
				vel.y = 0;
				platOn = wall;
			}
			else if(vel.x >= 0 && lastPos.x <= wall.x - width)
			{
				/*haxe.Log.clear();
				trace("Left Collision!", x, y , wall.x, wall.y);*/
				x = wall.x - width;
				vel.x = 0;
			}
			else if(vel.x <= 0 && lastPos.x >= wall.x + wall.width)
			{
				/*haxe.Log.clear();
				trace("Right Collision!", x, y , wall.x, wall.y);*/
				x = wall.x + wall.width;
				vel.x = 0;
			}
			else if(vel.y < 0 && lastPos.y >= wall.y + wall.height)
			{
				/*haxe.Log.clear();
				trace("Bottom Collision!", x, y , wall.x, wall.y);*/
				y = wall.y + wall.height;
				vel.y = 0;
			}
		}
	}

	public function onPlatform() : Bool
	{	return platOn != null;}

	public function magnitude()
	{	return Math.pow(vel.x,2) + Math.pow(vel.y,x);}

	public function gravity()
	{
		if(platOn == null)
		{
			if(vel.y < -5)
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

	//these functions must be overriden
	public function getRect () : Rectangle
	{	return new Rectangle();}

	private function move(){}
}