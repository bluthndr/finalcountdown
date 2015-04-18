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
		titleText.fontSize = 50;
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

	public function gotoLevelSelect()
	{
		removeChildren();
		touchable = false;
		addChild(new LevelSelector());
	}

	public inline function getPlayers() : Array<GameSprite>
	{	return panel.loadPlayers();}

	public inline function getTopCtrls() : Controller
	{	return panel.getTopCtrls();}
}