import starling.display.Sprite;
import starling.utils.AssetManager;
import starling.text.*;
import bitmasq.*;

class Root extends Sprite
{
	public static var assets:AssetManager = new AssetManager();

	public function new()
	{	super();}

	public function start(startup:Startup)
	{
		assets.enqueue("assets/crack.png");
		assets.enqueue("assets/eye.png");
		assets.enqueue("assets/fist.png");
		assets.enqueue("assets/body.png");
		assets.enqueue("assets/shoe.png");
		assets.enqueue("assets/wall.png");
		assets.enqueue("assets/grass.png");
		assets.enqueue("assets/grass2.png");
		assets.enqueue("assets/lava.png");
		assets.enqueue("assets/FinalGame1.mp3");
		assets.enqueue("assets/FinalGame2.mp3");
		assets.enqueue("assets/FinalGame3.mp3");
		assets.enqueue("assets/FinalGame4.mp3");
		assets.enqueue("assets/lava.mp3");
		assets.enqueue("assets/EggWhite.png");
		assets.enqueue("assets/EggWhite.fnt");
		assets.loadQueue(function onProgress(ratio:Float)
		{
			if (ratio == 1)
			{
				var customFont = new BitmapFont(assets.getTexture("EggWhite"), assets.getXml("EggWhite"));
				TextField.registerBitmapFont(customFont);
				startup.init(function(){addChild(new Game());});
			}
		});
	}
}
