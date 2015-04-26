import starling.display.*;
import starling.events.*;
import flash.ui.*;
import bitmasq.*;
import flash.geom.Point;
import GamePanel;
import GameText;
import flash.media.*;

class Game extends Sprite
{
	private static inline var title = "Egg Beaters";

	public static var game : Game;
	private var titleText : GameText;
	private var panel : GamePanel;
	private var musButtons : MusicButtons;

	public static inline var READY = "ReadyEvent";
	public static inline var CHANGE_CONTROLS = "ChangeControls";

	public function new()
	{
		super();
		game = this;

		titleText = new GameText(title.length*75,100,title);
		titleText.x = Startup.stageWidth(0.5) - titleText.width/2;
		titleText.fontSize = 75;
		titleText.removeBorder();
		addChild(titleText);

		musButtons = new MusicButtons();
		addChild(musButtons);

		panel = new GamePanel();
		addChild(panel);
	}

	public function reset()
	{
		removeChildren();
		addChild(titleText);

		musButtons.play(1);
		addChild(musButtons);

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

	public function play(s : Int)
	{	musButtons.play(s);}

	public function dec()
	{	musButtons.decVol();}

	public function inc()
	{	musButtons.incVol();}
}

class MusicButtons extends Sprite
{
	private var title : GameText;
	private var decButton : GameButton;
	private var incButton : GameButton;

	private var sound : Sound;
	private var channel : SoundChannel;
	private var volume : Float;
	private var isPlaying : Bool;

	public function new()
	{
		super();

		sound = Root.assets.getSound("FinalGame1");
		volume = 0.5;
		isPlaying = false;
		play();

		title = new GameText(150,25);
		title.fontSize = 20;
		updateText();
		addChild(title);
		decButton = new GameButton(75,25,"Decrease",decVol);
		decButton.y = 25;
		addChild(decButton);
		incButton = new GameButton(75,25,"Increase",incVol);
		incButton.x = 75; incButton.y = decButton.y;
		addChild(incButton);
	}

	public function play(?s : Int)
	{
		if(s == null)
		{
			if(!isPlaying)
			{
				channel = sound.play();
				channel.soundTransform = new SoundTransform(volume);
				isPlaying = true;
				if(!channel.hasEventListener(flash.events.Event.SOUND_COMPLETE))
				{
					channel.addEventListener(flash.events.Event.SOUND_COMPLETE,
					function(e:flash.events.Event)
					{
						isPlaying = false;
						play();
					});
				}
			}
		}
		else
		{
			channel.stop();
			isPlaying = false;
			sound = Root.assets.getSound("FinalGame"+Std.string(s));
			play();
		}
	}

	public function decVol()
	{
		volume -= 0.1;
		if(volume < 0.0) volume = 0.0;
		channel.soundTransform = new SoundTransform(volume);
		updateText();
	}

	public function incVol()
	{
		volume += 0.1;
		if(volume > 1.0) volume = 1.0;
		channel.soundTransform = new SoundTransform(volume);
		updateText();
	}

	private inline function updateText()
	{	title.text = "Music Volume: " + Std.string(Math.floor(volume*100));}
}