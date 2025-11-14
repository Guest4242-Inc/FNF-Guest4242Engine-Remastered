package funkin.ui.title;

import flixel.FlxSprite;
import funkin.graphics.shaders.BlendModesShader;
import openfl.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;

class FlxSpriteOverlay extends FlxSprite
{
  var blendShader:BlendModesShader;
  var dipshitBitmap:BitmapData;
  var temp:FlxSprite;

  var watermark:FlxText;
  var watermarkTween:FlxTween;
  var watermarkTimer:Float = 0;
  var watermarkState:Int = 0; // 0: waiting, 1: fading in, 2: visible, 3: fading out, 4: done

  public function new(x:Float, y:Float)
  {
    super(x, y);
    temp = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    blendShader = new BlendModesShader();
    dipshitBitmap = new BitmapData(2180, 1720, true, 0xFFCC00CC);

    // set up the damn watermark telling you about a fun fact that you can press something to skip something unknown idk man im afraid of coding in haxe and my code is like spaghetti someone please helo me ;-;
    var text = "press enter to skip this part";
    var size = 24;
    watermark = new FlxText(0, 0, 0, text, size);
    watermark.setFormat("VCR OSD Mono", size, 0xFFFFFFFF, "right", FlxTextBorderStyle.OUTLINE, 0xFF000000);
    watermark.alpha = 0;
    watermark.scrollFactor.set(0, 0);
    // Position bottom right
    watermark.x = FlxG.width - watermark.width - 24;
    watermark.y = FlxG.height - watermark.height - 16;
    // Add to state if not already
    if (FlxG.state != null) FlxG.state.add(watermark);
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
    if (watermarkState == 0)
    {
      watermarkTimer += elapsed;
      if (watermarkTimer >= 1)
      {
        watermarkState = 1;
        watermarkTimer = 0;
        // Fade in
        watermarkTween = FlxTween.tween(watermark, {alpha: 0.4}, 0.5,
          {
            ease: FlxEase.quadOut,
            onComplete: function(_) {
              watermarkState = 2;
              watermarkTimer = 0;
            }
          });
      }
    }
    else if (watermarkState == 2)
    {
      watermarkTimer += elapsed;
      if (watermarkTimer >= 3)
      {
        watermarkState = 3;
        watermarkTimer = 0;
        // Fade out
        watermarkTween = FlxTween.tween(watermark, {alpha: 0}, 0.5,
          {
            ease: FlxEase.quadIn,
            onComplete: function(_) {
              watermarkState = 4;
            }
          });
      }
    }
  }

  override function drawComplex(camera:FlxCamera):Void
  {
    _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
    _matrix.translate(-origin.x, -origin.y);
    _matrix.scale(scale.x, scale.y);
    if (bakedRotationAngle <= 0)
    {
      updateTrig();
      if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
    }
    getScreenPosition(_point, camera).subtractPoint(offset);
    _point.add(origin.x, origin.y);
    _matrix.translate(_point.x, _point.y);
    if (isPixelPerfectRender(camera))
    {
      _matrix.tx = Math.floor(_matrix.tx);
      _matrix.ty = Math.floor(_matrix.ty);
    }

    var sprRect = getScreenBounds();

    // dipshitBitmap.draw(camera.canvas, camera.canvas.transform.matrix);
    // blendShader.setCamera(dipshitBitmap);

    // FlxG.bitmapLog.add(dipshitBitmap);

    camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
  }

  function copyToFlash(rect):openfl.geom.Rectangle
  {
    var flashRect = new openfl.geom.Rectangle();
    flashRect.x = rect.x;
    flashRect.y = rect.y;
    flashRect.width = rect.width;
    flashRect.height = rect.height;
    return flashRect;
  }

  override public function isSimpleRender(?camera:FlxCamera):Bool
  {
    if (FlxG.renderBlit)
    {
      return super.isSimpleRender(camera);
    }
    else
    {
      return false;
    }
  }
}
