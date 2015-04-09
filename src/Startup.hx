import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import starling.core.Starling;
import starling.animation.Transitions;

@:bitmap("assets/loading.png")
class LoadingBitmapData extends flash.display.BitmapData { }

class Startup extends Sprite
{
	private var loadingBitmap:Bitmap;

	function new()
	{
		super();

		loadingBitmap = new Bitmap(new LoadingBitmapData(0, 0));
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
		stage.addChild(new Startup());
	}

	public function init(fn : Void->Void)
	{
		Starling.juggler.tween(loadingBitmap, 1.0,
		{
			transition:Transitions.EASE_OUT, delay:0, alpha: 0,
			onComplete : function()
			{
				removeChild(loadingBitmap);
				fn();
			}
		});
	}

	public static function stageWidth(percentage : Float = 1.0) : Float
	{	return Starling.current.stage.stageWidth * percentage;}

		public static function stageHeight(percentage : Float = 1.0) : Float
	{	return Starling.current.stage.stageHeight * percentage;}
}