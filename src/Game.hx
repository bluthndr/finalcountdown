import starling.display.*;
import starling.events.*;
import flash.ui.*;
import bitmasq.*;
import flash.geom.*;
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
	private var sfxButtons : SoundButtons;

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

		sfxButtons = new SoundButtons();
		addChild(sfxButtons);

		panel = new GamePanel();
		addChild(panel);

		addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent)
		{if(e.keyCode == Keyboard.ESCAPE) reset();});
	}

	public function reset()
	{
		removeChildren();
		addChild(titleText);

		musButtons.play(1);
		addChild(musButtons);

		addChild(sfxButtons);

		panel.reset();
		addChild(panel);
		touchable = true;
		Player.curLevel = null;
	}

	public function gotoLevelSelect()
	{
		removeChildren();
		touchable = false;
		addChild(new LevelSelector());
	}

	public inline function getPlayers() : Array<Player>
	{	return panel.loadPlayers();}

	public inline function getTopCtrls() : Controller
	{	return panel.getTopCtrls();}

	public function play(s : Int)
	{	musButtons.play(s);}

	public function decM()
	{	musButtons.decVol();}

	public function incM()
	{	musButtons.incVol();}

	public function decS()
	{	sfxButtons.decVol();}

	public function incS()
	{	sfxButtons.incVol();}
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

	public static var incPos = new Rectangle(0,25,75,25);
	public static var decPos = new Rectangle(75,25,75,25);

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

class SoundButtons extends Sprite
{
	private var title : GameText;
	public static var incPos : Rectangle;
	public static var decPos : Rectangle;

	public function new()
	{
		super();

		title = new GameText(150,25);
		title.x = Startup.stageWidth() - title.width;
		title.fontSize = 20;
		updateText();
		addChild(title);

		var decButton = new GameButton(75,25,"Decrease",decVol);
		decButton.x = title.x; decButton.y = 25;
		addChild(decButton);

		var incButton = new GameButton(75,25,"Increase",incVol);
		incButton.x = decButton.x + 75; incButton.y = decButton.y;
		addChild(incButton);

		if(incPos == null)
			incPos = new Rectangle(incButton.x,incButton.y,75,25);
		if(decPos == null)
			decPos = new Rectangle(decButton.x,decButton.y,75,25);
	}

	public function incVol()
	{
		SFX.soundVol += 0.1;
		if(SFX.soundVol > 1) SFX.soundVol = 1;
		updateText();
	}

	public function decVol()
	{
		SFX.soundVol -= 0.1;
		if(SFX.soundVol < 0) SFX.soundVol = 0;
		updateText();
	}

	private inline function updateText()
	{	title.text = "Sound Volume: " + Std.string(Math.floor(SFX.soundVol*100));}
}