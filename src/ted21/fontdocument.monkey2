
Namespace ted21


Class FontView Extends View

	field _font:Font
	
	Property Path:String()
		Return _path
	Setter( path:String )
		_path = path
	End
	
	Method New( doc:FontDocument )
		_doc = doc
		
		Layout = "fill"
		Style = Style.GetStyle( "mojo.ImageView" )
	End


Protected

	Method OnValidateStyle() Override
	End


	Method OnRender( canvas:Canvas ) Override
		canvas.Color = New Color ( .13,.13,.13, 1 )
		canvas.DrawRect( 0,0, Width, 40 )
		canvas.Color = New Color ( .1,.1,.1, 1 )
		canvas.DrawRect( 0,40, Width, Height-40 )
		
		If Not _font Then Return
		
		canvas.Font = Style.DefaultFont
	
		canvas.Color =  Color.White
		canvas.DrawText( "Font: " + StripDir( _path ), 10, 10 )

		canvas.Font = _font
		canvas.Color =  Color.LightGrey
		
		canvas.Scale( .2, .2)
		canvas.DrawText( "The Quick Brown Fox Jumps Over The Lazy Dog", 50, 200 )
		canvas.Scale( 1.5, 1.5)
		canvas.DrawText( "The Quick Brown Fox Jumps Over The Lazy Dog", 50, 200 )
		canvas.Scale( 1.5, 1.5)
		canvas.DrawText( "The Quick Brown Fox Jumps Over The Lazy Dog", 50, 180 )
		canvas.Scale( 1.5, 1.5)
		canvas.DrawText( "The Quick Brown Fox Jumps Over The Lazy Dog", 50, 160 )
		canvas.Scale( 1.5, 1.5)
		canvas.DrawText( "The Quick Brown Fox Jumps Over The Lazy Dog", 50, 140 )
		
		Local chr:int =  33
		Local x:int
		Local y:int = 230
		Repeat
			x =  50
			Repeat
				canvas.Color = New Color ( .07,.07,.07, 1 )
				canvas.DrawRect( x, y, 45, 45 )
				canvas.Color =  Color.LightGrey
				canvas.DrawText( String.FromChar(chr), x, y )
				chr += 1
				x += 50
			Until x > Width - 90
			y += 50
		Until y > Height - 90
	End
	
Private
	field _path:string
  	Field _doc:FontDocument
End



Class FontDocument Extends Ted2Document

	Method New( path:String )
		Super.New( path )
		
		_view = New FontView( Self )
		_view.Path = path
		_view._font = Font.Load( path, 50 )
	End

Protected

	Method OnLoad:Bool() Override
		Return True
	End


	
	Method OnSave:Bool() Override
		Return False
	End


	
	Method OnClose() Override
	End


	
	Method OnCreateView:FontView() Override
		Return _view
	End

Private

	Field _view:FontView
	
End
