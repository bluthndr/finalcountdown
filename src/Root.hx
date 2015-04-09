import starling.display.Sprite;
import starling.utils.AssetManager;

class Root extends Sprite
{
	public static var assets:AssetManager = new AssetManager();

	public function new()
	{	super();}

	public function start(startup:Startup)
	{
		assets.loadQueue(function onProgress(ratio:Float)
		{
			if (ratio == 1)
			{
				startup.init(makeTestLevel);
			}
		});
	}

	private function makeTestLevel()
	{
		//make walls
		var walls = new Array<Wall>();
		var wall = new Wall(Startup.stageWidth(), Startup.stageHeight(0.1));
		wall.y = Startup.stageHeight() - wall.height;
		walls.push(wall);

		var wall2 = new Wall(Startup.stageWidth(0.1), Startup.stageHeight());
		wall2.x = -wall2.width;
		walls.push(wall2);

		var wall3 = wall2.clone();
		wall3.x = Startup.stageWidth();
		walls.push(wall3);

		var wall4 = new Wall(100, 200);
		wall4.x = Startup.stageWidth(0.5) - wall4.width/2; wall4.y = wall.y - 200;
		walls.push(wall4);

		//make platforms
		var plats = new Array<Platform>();
		var plat = new Platform(Startup.stageWidth(0.1), Startup.stageHeight(0.05));
		plat.y = wall.y - 100;
		plats.push(plat);

		var plat2 = plat.clone();
		plat2.x = Startup.stageWidth() - plat.width;
		plats.push(plat2);

		var plat3 = plat.clone();
		plat3.x += 150; plat3.y -= 100;
		plats.push(plat3);

		var plat4 = plat2.clone();
		plat4.x -= 150; plat4.y -= 100;
		plats.push(plat4);

		var wall5 = new Wall(Startup.stageWidth(0.1), Startup.stageHeight(0.1));
		wall5.x = plat.x; wall5.y = plat.y - 200;
		walls.push(wall5);

		var wall6 = wall5.clone();
		wall6.x = plat2.x;
		walls.push(wall6);

		var ply = new Player();
		ply.x = Startup.stageWidth(0.5) - ply.width/2;

		addChild(new Level([ply], plats, walls));
	}

}