import flash.geom.Point;

enum PLAYER_ATTACK
{
	GROUND_PUNCH;
}
typedef Attack = {area : HitCircle, type : PLAYER_ATTACK}
typedef Anim = {x : Float, y : Float, rot : Float}
typedef AttackProperties = {knockback : Point, damage : Float}