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
typedef AttackProperties = {knockback : Point, damage : Float,
									stun : Int, ivFrames : Int}

enum Animation
{
	STAND;
	JUMP;
	STICK;
	WALL_JUMP;
	FALL;
	WALK;
	STUN;
	GUARD;

	//punches
	HGP;
	LGP;

	//kicks
	HGK;
	LGK;

	//eyes
	LGE;
	HGE;
}