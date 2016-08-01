
'extends
' mojo.input/keycodes
  'missing from Modifier enum
	Command=  LeftGui|RightGui

  'missing from Key enum
 	Equals = 61,


' mojo.graphics/canvas

	#rem monkeydoc Draws an image icon frame.
	Draws an image using the current [[Color]], [[BlendMode]] and [[Matrix]].

	@param tx X coordinate to draw image at.

	@param ty Y coordinate to draw image at.

	@param iconNumber number from 0 of the icon frame to draw (frames start from 0 and go left to right in equal pixel amounts).

	@param iconCount how many icon frames are packed into the image

	@param sx X axis scale factor for drawing.

	@param sy Y axis scale factor for drawing.
  #end
  Method DrawImageIcon( image:Image, tx:Float, ty:Float, iconNumber:Int, iconCount:Int )
    If iconCount < 0 Then Return
    
		Local vs:=image.Vertices
		Local wd:Float = (vs.max.x - vs.min.x) / iconCount
		vs.max.x = vs.min.x + wd

		Local tc:=image.TexCoords
		wd = (tc.max.x - tc.min.x) / iconCount
		tc.min.x = tc.min.x + (iconNumber * wd)
		tc.max.x = tc.min.x + wd
		
		AddDrawOp( image.Material,4,1 )
		AddVertex( vs.min.x+tx, vs.min.y+ty,  tc.min.x, tc.min.y )
		AddVertex( vs.max.x+tx, vs.min.y+ty,  tc.max.x, tc.min.y )
		AddVertex( vs.max.x+tx, vs.max.y+ty,  tc.max.x, tc.max.y )
		AddVertex( vs.min.x+tx, vs.max.y+ty,  tc.min.x, tc.max.y )
	End

  Method DrawImageIcon( image:Image, tx:Float, ty:Float, iconNumber:Int, iconCount:Int, sx:Float, sy:float )
		Local matrix := _matrix
		Translate( tx, ty )
		Rotate( 0 )
		Scale( sx, sy )
		DrawImageIcon( image, 0,0, iconNumber, iconCount )
		_matrix = matrix
	End

' std/graphics/color
	#rem monkeydoc Brown.
	#end
	Const Brown := New Color( .62,.31,0 )

	#rem monkeydoc Lime.
	#end
	Const Lime := New Color( .54,.74,.14 )

	#rem monkeydoc Mango.
	#end
	Const Mango := New Color( .94,.58,.03 )

	#rem monkeydoc Orange.
	#end
	Const Orange := New Color( .79,.32,0 )

	#rem monkeydoc Pink.
	#end
	Const Pink := New Color( .79,.44,.72 )

	#rem monkeydoc Purple.
	#end
	Const Purple := New Color( .41,.13,.48 )

	#rem monkeydoc LeafGreen.
	#end
	Const LeafGreen := New Color( .2,.6,.2 )

	#rem monkeydoc Yolk.
	#end
	Const Yolk := New Color( 1,.65,0 )

	#rem monkeydoc Peach.
	#end
	Const Peach := New Color( 1,.8,01 )

 	#rem monkeydoc Sand.
	#end
	Const Sand := New Color( .94,.87,.7 )
 
 	#rem monkeydoc WetSand.
	#end
	Const WetSand := New Color( .83,.76,.58 )
	
 	#rem monkeydoc NavyBlue.
	#end
	Const NavyBlue := New Color( .09,.15,.44 )
	
 	#rem monkeydoc Morello.
	#end
	Const Morello := New Color( .6,.34,.71 )
	
 	#rem monkeydoc Teal.
	#end
	Const Teal := New Color( .22,.43,.5 )

 	#rem monkeydoc SkyBlue.
	#end
	Const SkyBlue := New Color( .2,.59,.85 )

 	#rem monkeydoc LightGreen.
	#end
	Const LightGreen := New Color( .18,.8,.44 )

 	#rem monkeydoc Mint.
	#end
	Const Mint := New Color( .08,.62,.52 )

 	#rem monkeydoc Silver.
	#end
	Const Silver := New Color( .74,.76,.76 )

 	#rem monkeydoc Gold.
	#end
	Const Gold := New Color( .83,.66,.29 )

 	#rem monkeydoc Forest.
	#end
	Const Forest := New Color( .17,.31,.21 )

 	#rem monkeydoc TreeTrunk.
	#end
	Const TreeTrunk := New Color( .31,.23,.17 )

 	#rem monkeydoc Plum.
	#end
	Const Plum := New Color( .36,.2,.36 )

 	#rem monkeydoc Watermelon.
	#end
	Const Watermelon := New Color( .85,.32,.32 )

 	#rem monkeydoc Avocado.
	#end
	Const Avocado := New Color( .55,.69,.12 )

 	#rem monkeydoc BubbleGum.
	#end
	Const BubbleGum := New Color( .83,.36,.61 )

 	#rem monkeydoc Maroon.
	#end
	Const Maroon := New Color( .47,.18,.16 )

 	#rem monkeydoc Coffee.
	#end
	Const Coffee := New Color( .55,.44,.36 )

 	#rem monkeydoc Lavender.
	#end
	Const Lavender := New Color( .6,.67,.83 )

 	#rem monkeydoc PowderBlue.
	#end
	Const PowderBlue := New Color( .72,.78,.94 )

 	#rem monkeydoc GreyBlue.
	#end
	Const GreyBlue := New Color( .22,.29,.5 )

 	#rem monkeydoc Umber.
	#end
	Const Umber := New Color( .7,.53,.0 )

 	#rem monkeydoc Olive.
	#end
	Const Olive := New Color( .52,.6,.1 )

 	#rem monkeydoc Buff.
	#end
	Const Buff := New Color( .84,.77,.64 )
	
 	#rem monkeydoc Cobble.
	#end
	Const Cobble := New Color( .47,.38,.33 )
	
 	#rem monkeydoc Aqua.
	#end
	Const Aqua := New Color( .59,.67,.68 )

 	#rem monkeydoc LightKhaki.
	#end
	Const LightKhaki := New Color( .78,.78,.59 )

 	#rem monkeydoc DragonFruit.
	#end
	Const DragonFruit := New Color( .80,.38,0.5 )

 	#rem monkeydoc Ember.
	#end
	Const Ember := New Color( .74,.47,.34 )

 	#rem monkeydoc Corn.
	#end
	Const Corn := New Color( .91,.8,.32 )

 	#rem monkeydoc Honeysuckle.
	#end
	Const Honeysuckle := New Color( .95,.48,.59 )

 	#rem monkeydoc Phlox.
	#end
	Const Phlox := New Color( .52,.25,.51 )

 	#rem monkeydoc Khaki.
	#end
	Const Khaki := New Color( .56,.56,.39 )

 	#rem monkeydoc Nougat.
	#end
	Const Nougat := New Color( .83,.73,.62 )
