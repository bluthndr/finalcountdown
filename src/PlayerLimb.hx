import starling.display.Image;
import starling.events.*;
import flash.geom.Rectangle;

class PlayerLimb extends GameSprite
{
	private var image : Image;
	private var lifetime : Int;

	private inline static var speedMod = 7.5;
	public function new(lt : String, angle : Float, ?flip : Bool)
	{
		super();

		image = new Image(Root.assets.getTexture(lt));
		if(image == null) throw "Wrong texture!";
		addChild(image);

		if(lt == "crack") rotation = flip ? Math.PI : 0;
		vel.x = Math.cos(angle) * speedMod;
		vel.y = -Math.sin(angle) * speedMod;
		weight = 0.3;
		lifetime = 300;

		addEventListener(Event.ADDED, function(e:Event)
		{
			removeEventListeners(Event.ADDED);
			image.alignPivot();
			charWidth = image.width/4;
			charHeight = image.height/4;
			curRect = new Rectangle(x,y,image.width,image.height);
			lastRect = curRect.clone();
			//trace(curRect, lastRect);
		});
	}

	public function setColor(c : UInt)
	{	image.color = c;}

	public function setScale(fx : Float, fy : Float)
	{
		image.scaleX = PlayerImage.set(fx);
		image.scaleY = PlayerImage.set(fy);
	}

	override public function platformCollision(plat : Platform) : Bool
	{
		if(vel.y > 0 && lastPos.y <= plat.y - charHeight
		&& this.getRect().intersects(plat.getRect()))
		{
			y = plat.y - charHeight;
			vel.y *= -0.5;
		}
		return onPlatform();
	}

	override public function wallCollision(wall : Rectangle, ?sp : Platform)
	{
		if(this.getRect().intersects(wall))
		{
			if(vel.y > 0 && lastPos.y <= wall.y - charHeight)
			{
				y = wall.y - charHeight;
				vel.y *= -0.5;
			}
			else if(vel.x >= 0 && lastPos.x <= wall.x - charWidth)
			{
				vel.x *= -1;
				x = wall.x - charWidth;
			}
			else if(vel.x <= 0 && lastPos.x >= wall.x + wall.width)
			{
				vel.x *= -1;
				x = wall.x + wall.width;
			}
			else if(vel.y < 0 && lastPos.y >= wall.y + wall.height)
			{
				vel.y *= -1;
				y = wall.y + wall.height;
			}
		}
	}

	override public function lavaCollision(lava : Lava)
	{
		if(this.getRect().intersects(lava.getRect()))
			despawn();
	}

	override private function move()
	{
		if(--lifetime <= 0) despawn();
		image.rotation += PlayerImage.deg2rad(magnitude()*0.005);
		vel.x *= 0.95;
		super.move();
	}

	private function despawn()
	{	cast(parent, Level).remove(this);}
}