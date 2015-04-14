import flash.geom.Point;

enum PLAYER_ATTACK
{
	LG_PUNCH;
	LG_KICK;
	LG_EYE;
	HG_PUNCH;
	HG_KICK;
	HG_EYE;
}
typedef Attack = {area : HitCircle, type : PLAYER_ATTACK}
typedef Anim = {x : Float, y : Float, rot : Float}
typedef AttackProperties = {knockback : Point, damage : Float, stun : Int}