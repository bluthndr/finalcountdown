import starling.display.*;
import starling.events.*;
import flash.ui.*;
import flash.geom.*;

class Level extends Sprite
{
	private var sprites : Array<GameSprite>;
	private var meters : Array<PlayerMeter>;
	private var level : LevelMap;
	private var camera : Camera;

	private var showFPS : Bool;
	private var frameCount : UInt;
	private var timePassed : Float;

	public function new(map : LevelMap, players : Array<GameSprite>)
	{
		super();

		camera = new Camera(map.width, map.height);

		sprites = players;
		level = map;

		addEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(KeyboardEvent.KEY_UP, debugFunc);

		showFPS = false;
		frameCount = 0; timePassed = 0;
		meters = new Array();
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(Event.ENTER_FRAME, update);

		//add all children to level
		addChild(level);
		for(i in 0...sprites.length)
		{
			sprites[i].x = level.spawnPoints[i].x;
			sprites[i].y = level.spawnPoints[i].y;
			camera.x += sprites[i].x;
			camera.y += sprites[i].y;
			addChild(sprites[i]);
		}
		moveCamera();
		//for(i in 0...numChildren) trace(getChildAt(i));
	}

	private function update(e:EnterFrameEvent)
	{
		if(showFPS)
		{
			timePassed += e.passedTime;
			++frameCount;
			if(timePassed >= 1)
			{
				haxe.Log.clear();
				trace("FPS: " + frameCount);
				frameCount = 0; timePassed = 0;
			}
		}
		//movement and collision detection
		for(sprite in sprites)
		{
			sprite.gravity();
			if(!sprite.visible) continue;
			if(!sprite.onPlatform())
			{
				for(platform in level.platforms)
				{
					if(sprite.platformCollision(platform))
						break;
				}
			}
			for(wall in level.walls)
			{	sprite.wallCollision(wall.getRect(),wall);}
			for(l in level.lava)
			{	sprite.lavaCollision(l);}
			try
			{
				var p1 = cast(sprite, Player);
				for(sp2 in sprites)
				{
					if(sp2 != p1)
					{
						try
						{
							var p2 = cast(sp2, Player);
							if(p1.playerCollision(p2)) break;
						}
						catch(d:Dynamic) continue;
					}
				}
			}
			catch(d:Dynamic)continue;
		}

		//camera movement
		moveCamera();

		//make sure meters aren't in the way of players
		for(meter in meters)
		{
			var changed = false;
			var point = globalToLocal(new Point(meter.x,meter.y));
			var mRect = new Rectangle(point.x, point.y, meter.width, meter.height);
			for(sprite in sprites)
			{
				if(Std.is(sprite, Player) && sprite.getLocalRect().intersects(mRect))
				{
					meter.alpha = 0.5;
					changed = true;
					break;
				}
			}
			if(!changed) meter.alpha = 1.0;
		}
	}

	private function moveCamera()
	{
		//find center between all players
		var avg = new Point();
		var plyNum = 0;
		var positions = new Array<Point>();
		for(sprite in sprites)
		{
			try
			{
				var ply = cast(sprite, Player);
				if(ply.alive())
				{
					avg.x += sprite.x;
					avg.y += sprite.y;
					positions.push(new Point(sprite.x-Player.WIDTH,sprite.y-Player.HEIGHT));
					positions.push(new Point(sprite.x+Player.WIDTH*2,sprite.y+Player.HEIGHT*2));
					++plyNum;
				}
			}
			catch(d:Dynamic) continue;
		}
		avg.x /= plyNum;
		avg.y /= plyNum;

		camera.move(avg, positions);

		//move and scale level
		x = Startup.stageWidth(0.5)-(camera.x*camera.scale);
		y = Startup.stageHeight(0.5)-(camera.y*camera.scale);
		scaleX = scaleY = camera.scale;
	}

	private function debugFunc(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.F1:
				haxe.Log.clear();
				//trace(this);
			case Keyboard.F2:
				for(i in 0...sprites.length)
				{
					try
					{cast(sprites[i],Player).reset(level.spawnPoints[i]);}
					catch(d:Dynamic){continue;}
				}
			case Keyboard.F3:
				for(player in sprites)
				{
					try{cast(player,Player).toggleBound();}
					catch(d:Dynamic){continue;}
				}
			case Keyboard.F4:
				for(player in sprites)
				{
					try{cast(player,Player).kill();}
					catch(d:Dynamic){continue;}
				}
			case Keyboard.F5:
				showFPS = !showFPS;
			case Keyboard.ESCAPE:
				haxe.Log.clear();
				cast(parent, Game).reset();
		}
	}

	public function getSpawnPoint(p : Player) : Point
	{
		for(i in 0...sprites.length)
		{
			if(sprites[i] == p)
				return level.spawnPoints[i];
		}
		throw "Player isn't in the level...";
	}

	public function addMeter(meter : PlayerMeter)
	{	meters.push(meter);}

	public function addLimbs(limbs : Array<PlayerLimb>)
	{
		for(limb in limbs)
		{
			sprites.push(limb);
			addChild(limb);
		}
		//trace("Add limbs");
	}

	public function remove(sp : GameSprite)
	{
		//trace("Remove limb");
		sprites.remove(sp);
		removeChild(sp);
	}

	public function toString() : String
	{
		var s = "";
		s += Std.string(level);
		for(sprite in sprites) s += Std.string(sprite) + "\n";
		return s;
	}
}

class Camera
{
	public var x : Float;
	public var y : Float;
	public var scale : Float;
	public var lowBound : Point;
	public var highBound : Point;
	public inline static var cameraSpeed = 10;

	public function new(w : Float, h : Float)
	{
		scale = 1;
		lowBound = new Point(Startup.stageWidth(0.5),Startup.stageHeight(0.5));
		highBound = new Point(w - lowBound.x, h - lowBound.y);
		x = lowBound.x; y = lowBound.y;
	}

	public function getRect(?sc : Float) : Rectangle
	{
		if(sc != null)
		{
			var scales = new Point(Startup.stageWidth(1/sc),Startup.stageHeight(1/sc));
			var nx = x - Startup.stageWidth(0.5/sc);
			var ny = y - Startup.stageHeight(0.5/sc);
			return new Rectangle(nx, ny, scales.x, scales.y);
		}
		else
		{
			var scales = new Point(Startup.stageWidth(1/scale),Startup.stageHeight(1/scale));
			var nx = x - Startup.stageWidth(0.5/scale);
			var ny = y - Startup.stageHeight(0.5/scale);
			return new Rectangle(nx, ny, scales.x, scales.y);
		}
	}

	public function allOnScreen(points : Array<Point>, ?sc : Float) : Bool
	{
		var rect = getRect(sc == null ? scale : sc);
		for(p in points)
		{
			if(!rect.containsPoint(p))
				return false;
		}
		return true;
	}

	public function move(center : Point, positions : Array<Point>)
	{
		//move camera
		if(x < center.x - cameraSpeed*2) x += cameraSpeed;
		else if(x > center.x + cameraSpeed*2) x -= cameraSpeed;
		if(y < center.y - cameraSpeed*2) y += cameraSpeed;
		else if(y > center.y + cameraSpeed*2) y -= cameraSpeed;

		//bound camera
		if(x < lowBound.x) x = lowBound.x;
		else if(x > highBound.x) x = highBound.x;
		if(y < lowBound.y) y = lowBound.y;
		else if(y > highBound.y) y = highBound.y;

		//find scale
		var newScale : Float = 1;
		while(!allOnScreen(positions, newScale) && newScale > 0.01) newScale -= 0.01;
		if(scale < newScale - 0.05) scale += 0.01;
		else if(scale > newScale + 0.05) scale -= 0.01;
		else scale = newScale;
	}
}