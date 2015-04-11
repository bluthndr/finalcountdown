import starling.display.Sprite;
import starling.events.*;
import flash.ui.*;

class Level extends Sprite
{
	private var players : Array<Player>;
	private var platforms : Array<Platform>;
	private var walls : Array<Wall>;

	public function new(ply : Array<Player>, plat : Array<Platform>, wall : Array<Wall>)
	{
		super();

		players = ply;
		platforms = plat;
		walls = wall;

		addEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(KeyboardEvent.KEY_UP, debugFunc);
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(Event.ENTER_FRAME, collisionTest);

		//add all children to level
		for(wall in walls)
			addChild(wall);
		for(plat in platforms)
			addChild(plat);
		for(ply in players)
			addChild(ply);
	}

	private function collisionTest(e:Event)
	{
		for(player in players)
		{
			player.gravity();
			for(platform in platforms)
			{	player.platformCollision(platform);}
			for(wall in walls)
			{	player.wallCollision(wall);}
		}
	}

	private function debugFunc(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.F1:
				haxe.Log.clear();
				for(player in players)
				{
					trace("Position: " + player.getPosition(),
					"Velocity: " + player.getVelocity());
				}
			case Keyboard.F2:
				for(player in players)
					player.reset();
			case Keyboard.ESCAPE:
				cast(parent, Game).reset();
		}
	}
}