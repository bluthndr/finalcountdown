import starling.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

class GameSprite extends Sprite implements Collidable
{
	private var vel : Point;
	private var lastPos : Point;
	private var speed : Float;
	private var weight : Float;
	private var onPlatform : Bool;
	private var platOn : Platform;

	private function new()
	{
		super();
		vel = new Point();
		platOn = null;
		lastPos = new Point();
		weight = 0.15;
		speed = 10;
		onPlatform = false;
	}

	public function getPosition() : Point
	{	return new Point(x,y);}

	public function getVelocity() : Point
	{	return vel.clone();}

	public function platformCollision(plat : Platform)
	{
		if(!onPlatform && vel.y > 0 && lastPos.y <= plat.y - height
		&& this.getRect().intersects(plat.getRect()))
		{
			y = plat.y - height;
			vel.y = 0;
			onPlatform = true;
			platOn = plat;
		}
	}

	public function wallCollision(wall : Wall)
	{
		if(this.getRect().intersects(wall.getRect()))
		{
			if(!onPlatform && vel.y > 0 && lastPos.y <= wall.y - height)
			{
				/*haxe.Log.clear();
				trace("Top Collision!", x, y , wall.x, wall.y);*/
				y = wall.y - height;
				vel.y = 0;
				onPlatform = true;
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

	public function gravity()
	{
		move();
		if(!onPlatform)
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
		++y;
		if(platOn == null)
			onPlatform = false;
		else
		{
			onPlatform = this.getRect().intersects(platOn.getRect());
			if(!onPlatform) platOn = null;
		}
		--y;
	}

	//must be overriden
	public function getRect () : Rectangle
	{	return new Rectangle();}

	private function move(){}
}