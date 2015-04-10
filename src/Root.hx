import starling.display.Sprite;
import starling.utils.AssetManager;
import bitmasq.*;

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
				startup.init(function(){addChild(new Menu());});
			}
		});
	}
}