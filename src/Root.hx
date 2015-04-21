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
		assets.enqueue("assets/crack.png");
		assets.enqueue("assets/eye.png");
		assets.enqueue("assets/fist.png");
		assets.enqueue("assets/body.png");
		assets.enqueue("assets/shoe.png");
		assets.enqueue("assets/FinalGame.mp3");
		assets.enqueue("assets/FinalGame2.mp3");
		assets.enqueue("assets/lavaparticle.pex");
		assets.enqueue("assets/lavatexture.png");
		assets.enqueue("assets/lava.mp3");
		assets.loadQueue(function onProgress(ratio:Float)
		{
			if (ratio == 1)
			{
				startup.init(function(){addChild(new Game());});
			}
		});
	}
}
