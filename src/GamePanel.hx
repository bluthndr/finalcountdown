import starling.display.*;
import bitmasq.*;
import starling.events.*;
import flash.geom.Point;
import flash.ui.*;
import bitmasq.*;
import GameText;

class GamePanel extends Sprite
{
	private var panels : Array<PlayerPanel>;

	public function new()
	{
		super();
		panels = new Array();
		for(i in 0...8)
		{
			var panel = new PlayerPanel(i);
			panel.x = Startup.stageWidth(i * 0.125) + Startup.stageWidth(0.0075);
			panel.y = Startup.stageHeight(0.25);
			panels.push(panel);
			addChild(panel);
		}
		reset();
		addEventListener(Event.REMOVED, removeInputListeners);
	}

	public function reset()
	{
		addInputListeners();
		for(panel in panels)
		{
			panel.cursor.x = panel.x + panel.width/2;
			panel.cursor.y = panel.y - 25;
			if(!contains(panel.cursor)) addChild(panel.cursor);
			panel.reset();
		}
	}

	private function addInputListeners()
	{
		if(!hasEventListener(KeyboardEvent.KEY_DOWN))
			addEventListener(KeyboardEvent.KEY_DOWN, keyInput);
		if(!hasEventListener(KeyboardEvent.KEY_UP))
			addEventListener(KeyboardEvent.KEY_UP, keyOutput);
		if(!hasEventListener(GamepadEvent.CHANGE))
			Gamepad.get().addEventListener(GamepadEvent.CHANGE, gameInput);
		if(!hasEventListener(Game.READY))
			addEventListener(Game.READY, checkReady);
		if(!hasEventListener(Game.CHANGE_CONTROLS))
			addEventListener(Game.CHANGE_CONTROLS, changeCtrls);
		if(!hasEventListener(ControlChanger.DONE))
			addEventListener(ControlChanger.DONE, endChangeCtrls);
	}

	private function removeInputListeners()
	{
		removeEventListener(KeyboardEvent.KEY_DOWN, keyInput);
		removeEventListener(KeyboardEvent.KEY_UP, keyOutput);
		Gamepad.get().removeEventListener(GamepadEvent.CHANGE, gameInput);
		removeEventListener(Game.READY, checkReady);
		removeEventListener(Game.CHANGE_CONTROLS, changeCtrls);
		removeEventListener(ControlChanger.DONE, reset);
	}

	private function keyInput(e:KeyboardEvent)
	{
		if(e.keyCode == Keyboard.F1)
		{
			Game.game.removeChildren();
			Game.game.addChild(new LevelEditor());
		}
		else
		{
			for(panel in panels)
				panel.checkKeyInput(e.keyCode);
		}
	}

	private function keyOutput(e:KeyboardEvent)
	{
		for(panel in panels) panel.checkKeyOutput(e.keyCode);
	}

	private function gameInput(e:GamepadEvent)
	{
		//trace("Gamepad event", e.value, e.deviceIndex);
		for(panel in panels) panel.checkPadInput(e);
	}

	private function checkReady()
	{
		var ready = true;
		for(p in panels)
		{
			p.updateText();
			if(p.isHuman() && !p.isReady())
				ready = false;
		}
		if(ready)
		{
			removeInputListeners();
			Game.game.gotoLevelSelect();
		}
	}

	public function loadPlayers() : Array<GameSprite>
	{
		var players = new Array<GameSprite>();
		var i = 0;
		for(panel in panels)
		{
			if(panel.isHuman())
			{
				var player = new Player(panel,i);
				players.push(player);
			}
			++i;
		}
		return players;
	}

	public inline function getTopCtrls() : Controller
	{	return panels[0].getCtrls();}

	private function changeCtrls(e:ControlChangerEvent)
	{
		removeInputListeners();
		var cc = new ControlChanger(e.id, panels[e.id].getCtrls());
		cc.x = Startup.stageWidth(0.5) - cc.width/2;
		cc.y = Startup.stageHeight(0.5) - cc.height/2;
		addChild(cc);
	}

	private function endChangeCtrls()
	{
		removeChildAt(numChildren-1);
		reset();
	}

	public function trigger(cursor : Cursor)
	{
		for(panel in panels)
		{
			if(cursor.bounds.intersects(panel.bounds))
			{
				panel.trigger(cursor);
				break;
			}
		}
	}
}