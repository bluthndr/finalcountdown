import flash.media.*;

class SFX
{
	public static var soundVol = 0.1;
	public inline static function play(s : String)
	{	Root.assets.playSound(s,0,0,new SoundTransform(soundVol));}
}