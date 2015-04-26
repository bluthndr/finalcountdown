import starling.display.*;
import starling.events.*;
import flash.geom.Point;
import LevelEditor;

class LevelMap extends Sprite
{
	public var platforms : Array<Platform>;
	public var walls : Array<Wall>;
	public var lava : Array<Lava>;
	public var spawnPoints : Array<Point>;
	public var minX : Float;
	public var minY : Float;
	public var bgColor : UInt;

	private function new(dataList : Array<Placeable>, c : UInt = 0x00bfff)
	{
		super();

		walls = new Array();
		platforms = new Array();
		lava = new Array();
		spawnPoints = [for(i in 0...8) new Point()];

		minX = minY = 0; bgColor = c;
		for(data in dataList)
		{
			if(data.x < minX) minX = data.x;
			if(data.y < minY) minY = data.y;
			switch(data.type)
			{
				case 0:
					var wall = new Wall(data.w,data.h);
					wall.x = data.x; wall.y = data.y;
					walls.push(wall);
				case 1:
					var platform = new Platform(data.w,data.h);
					platform.x = data.x; platform.y = data.y;
					platforms.push(platform);
				case 2:
					var lv = new Lava(data.w,data.h);
					lv.x = data.x; lv.y = data.y;
					lava.push(lv);
				default:
					spawnPoints[data.type-3].x = data.x;
					spawnPoints[data.type-3].y = data.y;
			}
		}
		for(wall in walls) addChild(wall);
		for(plat in platforms) addChild(plat);
		for(l in lava) addChild(l);
		addEventListener(Event.ADDED, addHandle);
	}

	private function addHandle(e:Event)
	{
		removeEventListener(Event.ADDED,addHandle);
		flatten();
	}

	public function toString() : String
	{
		var s = "";
		for(wall in walls) s += Std.string(wall) + "\n";
		for(platform in platforms) s += Std.string(platform) + "\n";
		return s;
	}
}

class TestLevel extends LevelMap
{
	public function new()
	{	super(getLevel());}

	private static function getLevel() : Array<Placeable>
	{
		var rval = new Array<Placeable>();
		var levelWidth = Startup.stageWidth(2);
		var levelHeight = Startup.stageHeight(1.1);

		var i : Float = 0; var top = true;
		while(i < levelWidth)
		{
			rval.push({x : i, y : levelHeight * (top ? 0.5 : 0.75), w : 100, h : 50, type : 1});
			top = !top;
			i += (levelWidth * 0.1);
		}

		var space = Startup.stageWidth(0.1);
		for(i in 0...8)
		{
			if(i < 4) rval.push({x : i*space, y : 10, w:0, h:0, type : i+3});
			else rval.push({x : levelWidth - Player.WIDTH - ((i-4)*space), y : 10, w:0, h:0, type : i+3});
		}


		//bottom walls
		rval.push({x : 0, y : levelHeight, w : Startup.stageWidth(0.8),
									h : Startup.stageHeight(0.1), type : 0});

		rval.push({x : Startup.stageWidth(1.2), y : levelHeight,
		w : Startup.stageWidth(0.8), h : Startup.stageHeight(0.1), type : 0});

		//side walls
		rval.push({x : Startup.stageWidth(-0.1), y : Startup.stageHeight(-0.1),
		w : Startup.stageWidth(0.1), h : levelHeight + Startup.stageHeight(0.2), type : 0});

		rval.push({x : levelWidth, y : Startup.stageHeight(-0.1),
		w : Startup.stageWidth(0.1), h : levelHeight + Startup.stageHeight(0.2), type : 0});

		//top wall
		rval.push({x : 0, y : Startup.stageHeight(-0.1), w : levelWidth, h : Startup.stageHeight(0.1), type : 0});

		//bottom lava
		rval.push({x : Startup.stageWidth(-0.1), y : levelHeight + Startup.stageHeight(0.1),
		w : levelWidth + Startup.stageWidth(0.2), h : Startup.stageHeight(0.25), type : 2});

		return rval;
	}
}