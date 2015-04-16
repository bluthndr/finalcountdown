import starling.display.*;
import starling.events.*;
import flash.ui.*;
import bitmasq.*;
import flash.geom.Point;
import GamePanel;

class Game extends Sprite
{
	private static inline var title = "Game";
	private static inline var credits =
	"Credits\n------------\nTemitope Alaga\nAdd other names later...";

	public static var game : Game;
	private var titleText : GameText;
	private var panel : GamePanel;

	public static inline var READY = "ReadyEvent";
	public static inline var CHANGE_CONTROLS = "ChangeControls";

	public function new()
	{
		super();
		game = this;
		panel = new GamePanel();
		addChild(panel);
		titleText = new GameText(title.length*50,100,title);
		titleText.x = Startup.stageWidth(0.5) - titleText.width/2;
		titleText.fontSize = 50; titleText.color = 0;
		addChild(titleText);
	}

	public function reset()
	{
		removeChildren();
		addChild(titleText);
		panel.reset();
		addChild(panel);
		touchable = true;
	}

	public function makeTestLevel()
	{
		removeChildren();
		touchable = false;

		//lists
		var lavas = new Array<Lava>();
		var plats = new Array<Platform>();
		var positions = new Array<Point>();
		var levelWidth = Startup.stageWidth(2);
		var levelHeight = Startup.stageHeight(1.1);

		var i : Float = 0; var top = true;
		while(i < levelWidth)
		{
			var plat = new Platform(100,50);
			plat.x = i;
			plat.y = levelHeight * (top ? 0.6 : 0.85);
			top = !top;
			plats.push(plat);
			if(i < levelWidth * 0.4)
				positions.push(new Point(i + 50, 10));
			i += (levelWidth * 0.1);
		}

		addChild(new Level(levelWidth,levelHeight,
		positions, panel.loadPlayers(), plats, null, null, false));
	}
}