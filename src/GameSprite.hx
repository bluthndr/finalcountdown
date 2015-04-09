import starling.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

class GameSprite extends Sprite implements Collidable
{
	private var vel : Point;
	private var speed : Float;
	private var weight : Float;
	private var onPlatform : Bool;

	private function new()
	{
		super();
		vel = new Point();
		weight = 0.15;
		speed = 10;
		onPlatform = false;
	}

	public function getPosition() : Point
	{	return new Point(x,y);}

	public function getVelocity() : Point
	{	return vel.clone();}

	public function resetPlatformCollision()
	{	onPlatform = false;}

	public function platformCollision(plat : Platform)
	{
		if(!onPlatform && this.getRect().intersects(plat.getRect()))
		{
			if(vel.y > -5 && y < plat.y)
			{
				y = plat.y - height+1;
				vel.y = 0;
				onPlatform = true;
			}
		}
	}

	public function wallCollision(wall : Wall)
	{
		if(this.getRect().intersects(wall.getRect()))
		{
			if(!onPlatform && vel.y >= 0 && y < wall.y)
			{
				haxe.Log.clear();
				trace("Top Collision!", x, y , wall.x, wall.y);
				y = wall.y - height+1;
				vel.y = 0;
				onPlatform = true;
			}
			else if(vel.x >= 0 && x < wall.x && y < wall.y + wall.height * 0.99)
			{
				haxe.Log.clear();
				trace("Left Collision!", x, y , wall.x, wall.y);
				x = wall.x - width;
				vel.x = 0;
			}
			else if(vel.x <= 0 && x > wall.x + wall.width - width &&
			y < wall.y + wall.height * 0.99)
			{
				haxe.Log.clear();
				trace("Right Collision!", x, y , wall.x, wall.y);
				x = wall.x + wall.width;
				vel.x = 0;
			}
			else if(vel.y < 0 && x > wall.x - width && x < wall.x + wall.width &&
			y > wall.y + wall.height * 0.5)
			{
				haxe.Log.clear();
				trace("Bottom Collision!", x, y , wall.x, wall.y);
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
	}

	//must be overriden
	public function getRect () : Rectangle
	{	return new Rectangle();}

	private function move(){}
}