package flixel.addons.weapon;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxVelocity;

/**
 * @link http://www.photonstorm.com
 * @link http://www.haxeflixel.com
 * @author Richard Davey / Photon Storm
 * @author Touch added by Impaler / Beeblerox
*/
class FlxBullet extends FlxSprite
{
	// Acceleration or Velocity?
	public var accelerates:Bool = false;
	public var xAcceleration:Int;
	public var yAcceleration:Int;
	
	public var rndFactorAngle:Int;
	public var rndFactorSpeed:Int;
	public var rndFactorLifeSpan:Int;
	public var lifespan:Float;
	
	private var _weapon:FlxWeapon;
	private var _animated:Bool = false;
	private var _bulletSpeed:Int = 0;
	
	public function new(Weapon:FlxWeapon, WeaponID:Int)
	{
		super(0, 0);
		
		_weapon = Weapon;
		ID = WeaponID;
		
		exists = false;
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * 
	 * @param	Name		What this animation should be called (e.g. "run").
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped		Whether or not the animation is looped or just plays once.
	 */
	public function addAnimation(Name:String, Frames:Array<Int>, FrameRate:Int = 0, Looped:Bool = true):Void
	{
		animation.add(Name, Frames, FrameRate, Looped);
		
		_animated = true;
	}
	
	public function fire(FromX:Float, FromY:Float, VelX:Float, VelY:Float):Void
	{
		x = FromX + FlxRandom.floatRanged( -_weapon.rndFactorPosition.x, _weapon.rndFactorPosition.x);
		y = FromY + FlxRandom.floatRanged( -_weapon.rndFactorPosition.y, _weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			acceleration.x = xAcceleration + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed);
			acceleration.y = yAcceleration + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed);
		}
		else
		{
			velocity.x = VelX + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed);
			velocity.y = VelY + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed);
		}
		
		postFire();
	}
	
	#if !FLX_NO_MOUSE
	public function fireAtMouse(FromX:Float, FromY:Float, Speed:Int, RotateBulletTowards = true):Void
	{
		x = FromX + FlxRandom.floatRanged( -_weapon.rndFactorPosition.x, _weapon.rndFactorPosition.x);
		y = FromY + FlxRandom.floatRanged( -_weapon.rndFactorPosition.y, _weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsMouse(this, Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed), Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsMouse(this, Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed));
		}
		
		if (RotateBulletTowards)
		{
			angle = FlxAngle.angleBetweenMouse(_weapon.parent, true);
		}
		
		postFire();
	}
	#end
	
	#if !FLX_NO_TOUCH
	public function fireAtTouch(FromX:Float, FromY:Float, Touch:FlxTouch, Speed:Int, RotateBulletTowards = true):Void
	{
		x = FromX + FlxRandom.floatRanged( -_weapon.rndFactorPosition.x, _weapon.rndFactorPosition.x);
		y = FromY + FlxRandom.floatRanged( -_weapon.rndFactorPosition.y, _weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsTouch(this, Touch, Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed), Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsTouch(this, Touch, Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed));
		}
		
		if (RotateBulletTowards)
		{
			angle = FlxAngle.angleBetweenTouch(_weapon.parent, Touch, true);
		}
		
		postFire();
	}
	#end
	
	public function fireAtPosition(FromX:Float, FromY:Float, ToX:Float, ToY:Float, Speed:Int):Void
	{
		x = FromX + FlxRandom.floatRanged( -_weapon.rndFactorPosition.x, _weapon.rndFactorPosition.x);
		y = FromY + FlxRandom.floatRanged( -_weapon.rndFactorPosition.y, _weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsPoint(this, FlxPoint.get(ToX, ToY), Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed), Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsPoint(this, FlxPoint.get(ToX, ToY), Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed));
		}
		
		postFire();
	}
	
	public function fireAtTarget(FromX:Float, FromY:Float, Target:FlxSprite, Speed:Int):Void
	{
		x = FromX + FlxRandom.floatRanged( -_weapon.rndFactorPosition.x, _weapon.rndFactorPosition.x);
		y = FromY + FlxRandom.floatRanged( -_weapon.rndFactorPosition.y, _weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsObject(this, Target, Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed), Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsObject(this, Target, Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed));
		}
		
		postFire();
	}
	
	public function fireFromAngle(FromX:Float, FromY:Float, FireAngle:Int, Speed:Int):Void
	{
		x = FromX + FlxRandom.floatRanged( -_weapon.rndFactorPosition.x, _weapon.rndFactorPosition.x);
		y = FromY + FlxRandom.floatRanged( -_weapon.rndFactorPosition.y, _weapon.rndFactorPosition.y);
		
		var newVelocity:FlxPoint = FlxVelocity.velocityFromAngle(FireAngle + FlxRandom.intRanged( -_weapon.rndFactorAngle, _weapon.rndFactorAngle), Speed + FlxRandom.intRanged( -_weapon.rndFactorSpeed, _weapon.rndFactorSpeed));
		
		if (accelerates)
		{
			acceleration.x = newVelocity.x;
			acceleration.y = newVelocity.y;
		}
		else
		{
			velocity.x = newVelocity.x;
			velocity.y = newVelocity.y;
		}
		
		postFire();
	}
	
	private function postFire():Void
	{
		if (_animated)
		{
			animation.play("fire");
		}
		
		if (_weapon.bulletElasticity > 0)
		{
			elasticity = _weapon.bulletElasticity;
		}
		
		exists = true;
		
		// Reset last x and y position in case we were recycled.
		last.x = x;
		last.y = y;
		
		if (_weapon.bulletLifeSpan > 0)
		{
			lifespan = _weapon.bulletLifeSpan + FlxRandom.floatRanged( -_weapon.rndFactorLifeSpan, _weapon.rndFactorLifeSpan);
		}
		
		if (_weapon.onFireCallback != null)
		{
			_weapon.onFireCallback();
		}
		
		#if !FLX_NO_SOUND_SYSTEM
		if (_weapon.onFireSound != null)
		{
			_weapon.onFireSound.play();
		}
		#end
	}
	
	override public function update():Void
	{
		if (lifespan > 0)
		{
			lifespan -= FlxG.elapsed;
			
			if (lifespan <= 0)
			{
				kill();
			}
		}
		
		if (!FlxMath.pointInFlxRect(Math.floor(x), Math.floor(y), _weapon.bounds))
		{
			kill();
		}
		
		super.update();
	}
}