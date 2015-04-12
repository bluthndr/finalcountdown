import starling.text.TextField;

class GameText extends TextField
{
	//Name of bitmap font to be used for all text
	public inline static var bitmapFont = "Arial";

	public function new(w : UInt, h : UInt, s : String)
	{	super(w,h,s,bitmapFont,20,0xffffff);}
}