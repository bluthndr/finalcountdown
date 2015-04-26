class Lava extends Platform
{
	public function new(w : Float = 100, h : Float = 100)
	{
		super(w,h);
		name = "Lava";
	}

	override public function clone() : Lava
	{
		var rval = new Lava(rect.width, rect.height);
		rval.x = x; rval.y = y;
		return rval;
	}

	override private function setImage(w : Float, h : Float)
	{
		var i = 0.0;
		while(i < w)
		{
			var j = 0.0;
			while(j < h)
			{
				var im = new starling.display.Image(Root.assets.getTexture("lava"));
				im.x = i; im.y = j;
				im.scaleX = im.scaleY = Platform.TILE_SIZE / im.width;
				addChild(im);
				j += Platform.TILE_SIZE;
			}
			i += Platform.TILE_SIZE;
		}
		flatten();
	}
}