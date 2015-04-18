import starling.text.TextField;
import starling.display.Button;
import starling.events.*;
import starling.textures.Texture;

class GameText extends TextField
{
	//Name of bitmap font to be used for all text
	public inline static var bitmapFont = "Arial";

	public function new(w : UInt, h : UInt, s : String = "")
	{	super(w,h,s,bitmapFont,20,0xffffff);}
}

class GameButton extends Button
{
	public function new(w : UInt, h : UInt, s : String, fn : Void->Void)
	{
		super(Texture.empty(w,h), s);
		fontColor = 0xffffff;
		fontName = GameText.bitmapFont;
		fontSize = 20;
		addEventListener(Event.TRIGGERED, fn);
	}
}