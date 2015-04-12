import starling.display.Image;
import starling.events.*;
import flash.geom.Rectangle;

class PlayerLimb extends GameSprite
{
	private var image : Image;
	private var lifetime : Int;

	private inline static var speedMod = 5;
	public function new(lt : String, angle : Float)
	{
		super();

		image = new Image(Root.assets.getTexture(lt));
		if(image == null) throw "Wrong texture!";
		addChild(image);

		weight = 5;
		lifetime = 300;

		addEventListener(Event.ADDED, function(e:Event)
		{
			removeEventListeners(Event.ADDED);
			image.alignPivot();
			charWidth = image.width;
			charHeight = image.height;
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
		&& this.getRect().intersects(plat.getRect())){vel.y = -10;}
		return onPlatform();
	}

	override public function wallCollision(wall : Platform)
	{
		if(this.getRect().intersects(wall.getRect()))
		{
			if((vel.y > 0 && lastPos.y <= wall.y - charHeight) ||
			(vel.y < 0 && lastPos.y >= wall.y + wall.height)){vel.y = -10;}
			else if((vel.x >= 0 && lastPos.x <= wall.x - charWidth) ||
			(vel.x <= 0 && lastPos.x >= wall.x + wall.width)){vel.x = -10;}
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
		image.rotation += PlayerImage.deg2rad(magnitude()*0.5);
		vel.x *= 0.95;
		if(vel.y > 30) vel.y = 30;
		super.move();
	}

	private function despawn()
	{	cast(parent, Level).remove(this);}
}