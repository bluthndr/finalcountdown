import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import starling.core.Starling;
import starling.animation.Transitions;
import bitmasq.*;

@:bitmap("assets/loading.png")
class LoadingPic1 extends flash.display.BitmapData { }

@:bitmap("assets/loading2.png")
class LoadingPic2 extends flash.display.BitmapData { }

@:bitmap("assets/loading3.png")
class LoadingPic3 extends flash.display.BitmapData { }

class Startup extends Sprite
{
	private var loadingBitmap:Bitmap;
	private static var deviceNum : UInt = 0;

	function new()
	{
		super();

		loadingBitmap = new Bitmap(switch(Std.random(3))
		{
			case 0: new LoadingPic2(0,0);
			case 1: new LoadingPic3(0,0);
			default: new LoadingPic1(0,0);
		});
		loadingBitmap.x = 0;
		loadingBitmap.y = 0;
		loadingBitmap.width = Lib.current.stage.stageWidth;
		loadingBitmap.height = Lib.current.stage.stageHeight;
		loadingBitmap.smoothing = true;
		addChild(loadingBitmap);//To display on scene

		Lib.current.stage.addEventListener(Event.RESIZE, function(e:Event)
		{
			Starling.current.viewPort = new Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
			if (loadingBitmap != null)
			{
				loadingBitmap.width = Lib.current.stage.stageWidth;
				loadingBitmap.height = Lib.current.stage.stageHeight;
			}
		});

		var mStarling = new Starling(Root, Lib.current.stage);
		mStarling.antiAliasing = 0;

		function onRootCreated(event:Dynamic, root:Root)
		{
			mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			root.start(this);
			mStarling.start();
		}

		mStarling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
	}

	static function main()
	{
		var stage = Lib.current.stage;
		Gamepad.init(stage);
		//Gamepad.traceFunction = haxe.Log.trace;
		Gamepad.get().addEventListener(GamepadEvent.DEVICE_ADDED,
		function(){++deviceNum;});
		Gamepad.get().addEventListener(GamepadEvent.DEVICE_REMOVED,
		function(){--deviceNum;});
		stage.addChild(new Startup());
	}

	public static inline function getDeviceNum() : UInt
	{	return deviceNum;}

	public function init(fn : Void->Void)
	{
		Starling.juggler.tween(loadingBitmap, 1.0,
		{
			transition:Transitions.EASE_IN, delay: 1.0, alpha: 0,
			onComplete : function()
			{
				removeChild(loadingBitmap);
				fn();
			}
		});
	}

	public inline static function stageWidth(percentage : Float = 1.0) : Float
	{	return Starling.current.stage.stageWidth * percentage;}

	public inline static function stageHeight(percentage : Float = 1.0) : Float
	{	return Starling.current.stage.stageHeight * percentage;}
}
