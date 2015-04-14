import starling.display.Sprite;
import flash.ui.*;
import starling.events.*;
import PlayerAttributes;

class Animator extends Sprite
{
	var image : PlayerImage;
	var cur : UInt;

	//either rotate or move
	var moving : Bool;

	public function new()
	{
		super();
		image = new PlayerImage();
		addChild(image);
		cur = 0;
		updateColor();
		moving = true;
		addEventListener(Event.ADDED, addHandle);
		showInstructions();
	}

	private function showInstructions()
	{
		haxe.Log.clear();
		trace("Press arrow keys to move red limb.");
		trace("Press page up and page down to zoom in and out.");
		trace("Press Q and W to change limb.");
		trace("Press F1 to toggle moving/rotation.");
		trace("Press F2 to cycle through animations.");
		trace("Press Enter to save animation.");
	}

	private inline function updateColor()
	{
		for(i in 0...7)
		{
			if(i == Std.int(cur%7)) image.get(i).color = 0xff0000;
			else image.get(i).color = 0xffffff;
		}
	}

	private function addHandle(e:Event)
	{
		removeEventListener(Event.ADDED, addHandle);

		image.scaleX = image.scaleY = 3;
		x = Startup.stageWidth(0.5) - width/2;
		y = Startup.stageHeight(0.5) - height/2;
		addEventListener(KeyboardEvent.KEY_DOWN,
		function(e:KeyboardEvent)
		{
			switch(e.keyCode)
			{
				case Keyboard.ENTER:
					image.save();
				case Keyboard.PAGE_UP:
					image.scaleX += 0.1;
					image.scaleY = image.scaleX;
				case Keyboard.PAGE_DOWN:
					image.scaleX -= 0.1;
					image.scaleY = image.scaleX;
				case Keyboard.Q:
					if(cur == 0) cur = 6;
					else --cur;
					updateColor();
				case Keyboard.W:
					++cur;
					updateColor();
				case Keyboard.F1:
					moving = !moving;
					trace(moving ? "Now Moving" : "Now Rotating");
				case Keyboard.F2:
					image.nextAnim();
				case Keyboard.F3:
					image.loopCur();
				case Keyboard.F5:
					image.toggleCircles();
				case Keyboard.F9:
					showInstructions();
				case Keyboard.ESCAPE:
					cast(parent, Game).reset();
				default:
					if(moving) move(e);
					else rotate(e);
			}
		});
	}

	private function move(e:KeyboardEvent)
	{
		var im = image.get(cur);
		switch(e.keyCode)
		{
			case Keyboard.UP:
				im.y -= 1;
			case Keyboard.DOWN:
				im.y += 1;
			case Keyboard.LEFT:
				im.x -= 1;
			case Keyboard.RIGHT:
				im.x += 1;
		}
	}

	private function rotate(e:KeyboardEvent)
	{
		var im = image.get(cur);
		switch(e.keyCode)
		{
			case Keyboard.LEFT:
				im.rotation -= PlayerImage.deg2rad(10);
			case Keyboard.RIGHT:
				im.rotation += PlayerImage.deg2rad(10);
		}
	}
}