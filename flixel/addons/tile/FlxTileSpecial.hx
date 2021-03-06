package flixel.addons.tile;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class FlxTileSpecial extends FlxBasic
{
	public static inline var ROTATE_0 = 0;
	public static inline var ROTATE_90 = 1;
	public static inline var ROTATE_270 = 2;
	
	/**
	 * The id of this tile in the tileset
	 */
	public var tileID:Int;
	
	public var flipX:Bool = false;
	public var flipY:Bool = false;
	
	public var rotate:Int;
	
	private var _tmp_flipH:Bool;
	private var _tmp_flipV:Bool;
	private var _tmp_rot:Int;
	
	#if FLX_RENDER_BLIT
	private var _normalFrame:BitmapData;
	private var _flippedFrame:BitmapData;
	private var _point:Point;
	
	public var tileRect:Rectangle;
	#end
	
	private var _matrix:Matrix;
	
	// Animation stuff
	private var _animation:FlxTileAnimation;
	private var _currFrame:Int = 0;
	private var _lastFrame:Int = -1;
	private var _currTileId:Int;
	private var _currAnimParam:AnimParams;
	private var _frameTimer:Float = 0.0;
	
	#if FLX_RENDER_BLIT
	private var _animRects:Array<Rectangle>;
	public var dirty:Bool = true;
	#end
	
	public function new(TilesetId:Int, FlipX:Bool, FlipY:Bool, Rotate:Int) 
	{
		super();
		tileID = TilesetId;
		_currTileId = tileID;
		flipX = FlipX;
		flipY = FlipY;
		rotate = Rotate;
		
		#if FLX_RENDER_BLIT
		_normalFrame = null;
		_flippedFrame = null;
		_point = new Point(0, 0);
		
		_animRects = null;
		tileRect = new Rectangle();
		#end
		
		_matrix = new Matrix();
		_animation = null;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		#if FLX_RENDER_BLIT
		_normalFrame = FlxDestroyUtil.dispose(_normalFrame);
		_flippedFrame = FlxDestroyUtil.dispose(_flippedFrame);
		
		_point = null;
		_animRects = null;
		tileRect = null;
		#end
		
		_animation = FlxDestroyUtil.destroy(_animation);
		_currAnimParam = null;
		_matrix = null;
	}
	
	override public function update():Void 
	{
		super.update();
		#if FLX_RENDER_BLIT
		dirty = false;
		#end
		// Modified from updateAnimation() in FlxSprite
		if (_animation != null && _animation.delay > 0) 
		{
			_frameTimer += FlxG.elapsed;
			if (_frameTimer > _animation.delay) 
			{
				_lastFrame = _currFrame;
			}
			while (_frameTimer > _animation.delay) 
			{
				_frameTimer = _frameTimer - _animation.delay;
				if (_currFrame >= _animation.frames.length - 1)
				{
					_currFrame = 0;
				}
				else
				{
					_currFrame++;
				}
			}
			_currTileId = _animation.frames[_currFrame];
			if (_animation.framesData != null) 
			{
				_currAnimParam = _animation.framesData[_currFrame];
			}
			
			#if FLX_RENDER_BLIT
			dirty = !(_currFrame == _lastFrame);
			#end
		}
	}
	
	public inline function isSpecial():Bool 
	{
		return isFlipped() || hasAnimation();
	}
	
	public inline function isFlipped():Bool 
	{
		return (flipX || flipY) || rotate != ROTATE_0;
	}
	
	public inline function hasAnimation():Bool 
	{
		return _animation != null;
	}
	
	#if FLX_RENDER_BLIT
	public function getBitmapData(width:Int, height:Int, rect:Rectangle, bitmap:BitmapData):BitmapData 
	{
		if (_normalFrame == null)
		{
			_normalFrame = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		}
		
		var generateFlipped:Bool = (_flippedFrame == null);
		if (generateFlipped)
		{
			_flippedFrame = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		}

		if (generateFlipped || dirty) 
		{
			tileRect.width = width;
			tileRect.height = height;
			
			_normalFrame.fillRect(tileRect, FlxColor.TRANSPARENT);
			_flippedFrame.fillRect(tileRect, FlxColor.TRANSPARENT);
			
			if (_animRects != null && _animRects[_currFrame] != null) 
			{
				rect = _animRects[_currFrame];
			}
			
			_normalFrame.copyPixels(bitmap, rect, _point, null, null, true);
			_flippedFrame.draw(_normalFrame, getMatrix(width, height));
			dirty = true;
		}
		
		return _flippedFrame;
	}
	
	/**
	 * Set the animation rectangles for flash
	 * @param	rects	An array with rectangles
	 */
	public function setAnimationRects(rects:Array<Rectangle>):Void 
	{
		_animRects = rects;
	}
	#end
	
	/**
	 * Add an animation to this special tile
	 * @param	tiles		An array with the tilesetID of each frame
	 * @param	frameRate	The speed of the animation in frames per second (Default: 30)
	 */
	public function addAnimation(tiles:Array<Int>, frameRate:Float = 30, ?framesData:Array<AnimParams>):Void 
	{
		_animation = new FlxTileAnimation("tileAnim", tiles, frameRate, true, framesData);
	}
	
	/**
	 * Returns the current tileID of this tile in the tileset
	 * @return The current tileID
	 */
	public function getCurrentTileId():Int 
	{
		return _currTileId;
	}
	
	/**
	 * Get the animation tiles id if any
	 * @return	An array of ids or null
	 */
	public function getAnimationTilesId():Array<Int> 
	{
		return (_animation != null) ? _animation.frames : null;
	}
	
	/**
	 * Calculates and return the matrix
	 * @param	width	the tile width
	 * @param	height	the tile height
	 * @return	The matrix calculated
	 */
	public function getMatrix(width:Int, height:Int):Matrix 
	{
		_tmp_flipH = flipX;
		_tmp_flipV = flipY;
		_tmp_rot = rotate;
		
		if (_currAnimParam != null)
		{
			_tmp_flipH = _currAnimParam.flipX;
			_tmp_flipV = _currAnimParam.flipY;
			_tmp_rot = _currAnimParam.rotate;
		}
		
		_matrix.identity();
		
		if (_tmp_rot != FlxTileSpecial.ROTATE_0) 
		{
			switch(_tmp_rot) 
			{
				case FlxTileSpecial.ROTATE_90:
					_matrix.rotate(90 * FlxAngle.TO_RAD);
					_matrix.translate(width, 0);

				case FlxTileSpecial.ROTATE_270:
					_matrix.rotate(270 * FlxAngle.TO_RAD);
					_matrix.translate(0, height);
			}
		}
		
		if (_tmp_flipH) 
		{
			_matrix.scale( -1, 1);
			_matrix.translate(width, 0);
		}
		if (_tmp_flipV) 
		{
			_matrix.scale(1, -1);
			_matrix.translate(0, height);
		}
		
		return _matrix;
	}
}


typedef AnimParams = {
	var flipX:Bool;
	var flipY:Bool;
	var rotate:Int;
}
