import starling.display.*;
import starling.events.*;
import flash.ui.*;
import flash.geom.*;

enum GAME_TYPE
{
	STOCK;
	TIME;
}

typedef GameConditions = {type : GAME_TYPE, goal : Float}
class Level extends Sprite
{
	private var sprites : Array<GameSprite>;
	private var meters : Array<PlayerMeter>;
	private var level : LevelMap;
	private var camera : Camera;
	private var gameTimer : flash.utils.Timer;

	private var showFPS : Bool;
	private var frameCount : UInt;
	private var timePassed : Float;
	private var conditions : GameConditions;

	private inline static var pregameText =
	"Game will begin in: ";

	private static var defaultCond : GameConditions = {type : TIME, goal : 30000};

	public function new(map : LevelMap, players : Array<GameSprite>, ?t : GameConditions)
	{
		super();

		sprites = players;
		level = map;
		conditions = t == null ? defaultCond : t;

		camera = new Camera(level.minX, level.minY, map.width, map.height);

		addEventListener(Event.ADDED_TO_STAGE, preGame);

		showFPS = false;
		frameCount = 0; timePassed = 0;
		meters = new Array();
	}

	private function preGame(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, preGame);
		addEventListener(Event.ENTER_FRAME, countdown);
		loadSprites();
		var countText = new GameText(100,100,pregameText + "3");
		countText.x = Startup.stageWidth(0.5) - countText.width/2;
		countText.y = Startup.stageHeight(0.5) - countText.height/2;
		countText.name = "Pregame";
		Game.game.addChild(countText);

	}

	private function countdown(e:EnterFrameEvent)
	{
		timePassed += e.passedTime;
		var t = cast(Game.game.getChildByName("Pregame"), GameText);
		t.text = pregameText + Std.string(Math.ceil(-timePassed+3));
		if(timePassed > 3) startgame();
		moveCamera();
	}

	private function startgame()
	{
		Game.game.removeChild(Game.game.getChildByName("Pregame"));
		removeEventListener(Event.ENTER_FRAME, countdown);

		addEventListener(Event.ENTER_FRAME, update);
		if(sprites.length > 1)
			addEventListener(PlayerDiedEvent.DEATH, updateScore);
		addEventListener(KeyboardEvent.KEY_UP, debugFunc);
		if(conditions.type == TIME)
		{
			gameTimer = new flash.utils.Timer(conditions.goal, 1);
			gameTimer.start();
			gameTimer.addEventListener(flash.events.TimerEvent.TIMER_COMPLETE, endGame);
		}
	}

	private function loadSprites()
	{
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

		if(plyNum > 0)
		{
			camera.move(avg, positions);

			//move and scale level
			x = Startup.stageWidth(0.5)-(camera.x*camera.scale);
			y = Startup.stageHeight(0.5)-(camera.y*camera.scale);
			scaleX = scaleY = camera.scale;
		}
	}

	private function updateScore(e : PlayerDiedEvent)
	{
		if(e.killer == e.victim || e.killer == null)
		{
			e.victim.updateScore(false);
			if(conditions.type == STOCK && Math.abs(e.victim.getScore()) == conditions.goal)
			{
				removeChild(e.victim);
				sprites.remove(e.victim);
				meters.remove(e.victim.fatalKill());
				if(playerCount() <= 1)
					endGame();
			}
		}
		else
		{
			switch(conditions.type)
			{
				case STOCK:
					e.victim.updateScore(false);
					if(Math.abs(e.victim.getScore()) == conditions.goal)
					{
						removeChild(e.victim);
						sprites.remove(e.victim);
						meters.remove(e.victim.fatalKill());
						if(playerCount() <= 1)
							endGame();
					}
				case TIME:
					e.victim.updateScore(false);
					e.killer.updateScore(true);
			}
		}
	}

	private function playerCount() : UInt
	{
		var rval = 0;
		for(sprite in sprites)
		{
			if(Std.is(sprite, Player)) ++rval;
		}
		return rval;
	}

	private function endGame(?e:Dynamic)
	{
		var p = findWinner();
		var g = new GameText(100,100,"Player #" + p.playerID + " wins!");
		g.alignPivot();
		g.x = Startup.stageWidth(0.5);
		g.y = Startup.stageHeight(0.5);
		Game.game.addChild(g);
		removeEventListener(PlayerDiedEvent.DEATH, updateScore);
		addEventListener(Event.ENTER_FRAME, gameOver);
		timePassed = 0;
	}

	private function gameOver(e : EnterFrameEvent)
	{
		timePassed += e.passedTime;
		if(timePassed > 3) Game.game.reset();
	}

	private function findWinner() : Player
	{
		var rval : Player = null;
		switch(conditions.type)
		{
			case STOCK:
				for(sprite in sprites)
				{
					if(Std.is(sprite, Player))
					{
						rval = cast(sprite, Player);
						break;
					}
				}
			case TIME:
				var highScore = -0xffffff;
				for(sprite in sprites)
				{
					try
					{
						var cur = cast(sprite, Player);
						if(highScore < cur.getScore())
						{
							highScore = cur.getScore();
							rval = cur;
						}
					}
					catch(d:Dynamic){continue;}
				}
		}
		return rval;
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

	public inline static var cameraMoveSpeed = 10;
	public inline static var cameraScaleSpeed = 0.005;

	public function new(mx : Float, my : Float, w : Float, h : Float)
	{
		scale = 1;
		lowBound = new Point(mx + Startup.stageWidth(0.5), my + Startup.stageHeight(0.5));
		highBound = new Point(w - lowBound.x, h - lowBound.y);
		x = lowBound.x; y = lowBound.y;
	}

	public function getRect() : Rectangle
	{
		var scales = new Point(Startup.stageWidth(1/scale),Startup.stageHeight(1/scale));
		var nx = x - Startup.stageWidth(0.5/scale);
		var ny = y - Startup.stageHeight(0.5/scale);
		return new Rectangle(nx, ny, scales.x, scales.y);
	}

	public function allOnScreen(points : Array<Point>) : Bool
	{
		var rect = getRect();
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
		if(x < center.x - cameraMoveSpeed*2) x += cameraMoveSpeed;
		else if(x > center.x + cameraMoveSpeed*2) x -= cameraMoveSpeed;
		else x = center.x;
		if(y < center.y - cameraMoveSpeed*2) y += cameraMoveSpeed;
		else if(y > center.y + cameraMoveSpeed*2) y -= cameraMoveSpeed;
		else y = center.y;

		//bound camera
		if(x < lowBound.x) x = lowBound.x;
		else if(x > highBound.x) x = highBound.x;
		if(y < lowBound.y) y = lowBound.y;
		else if(y > highBound.y) y = highBound.y;

		//find scale
		var cond = !allOnScreen(positions);
		if(cond)
		{
			do{scale -= cameraScaleSpeed;}while(!allOnScreen(positions));
		}
		else if(scale < 1)
		{
			scale += cameraScaleSpeed;
			if(!allOnScreen(positions)) scale -= cameraScaleSpeed;
		}
	}
}