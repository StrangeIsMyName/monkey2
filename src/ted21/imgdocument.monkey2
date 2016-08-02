
Namespace ted2


Class ImgView Extends DockingView



	Method New()
#rem
		_findField = New TextField
		_findField.TabHit = Lambda()
		
			If _findField.Document.Text <> _matchText Or Not _matches.Length Then Return
			
			_matchId = (_matchId+1) Mod _matches.Length
			Go( _matches[_matchId] )

		End
		
		_findField.Document.TextChanged = Lambda()
			UpdateMatches( _findField.Text )
			If _matches.Length Go( _matches[0] )
		End
		
		Local findBar := New DockingView
	
		findBar.AddView( New Label( "Find:" ), "left" )
		findBar.ContentView = _findField
		
		_helpTree = New HelpTree
		
		_helpTree.NodeClicked = Lambda( tnode:TreeView.Node, event:MouseEvent )
		
			Local node:=Cast<HelpTree.Node>( tnode )
			If Not node Return
			
			Go( node.Page )
		End
		
		_htmlView=New HtmlView

		_htmlView.AnchorClicked=Lambda( url:String )
		
			'dodgy work around for mx2 docs!
			If url.StartsWith( "javascript:void('" ) And url.EndsWith( "')" )
				Local page:=url.Slice( url.Find( "'" )+1,url.FindLast( "'" ) )
				Go( page )
				Return
			Endif

			_htmlView.Go( url )
		End
		
		AddView( findBar, "top" )
		
		AddView( _helpTree, "top", 128 )
		
		ContentView = New ScrollView( _htmlView )
#end
	End



Private

	Field _image:ImageView

End



Class ImageView Extends View

	Field ZoomChanged:Void()


	Method New( doc:ImgDocument )
		_doc = doc
		
		Layout = "fill"
		Style=Style.GetStyle( "mojo.ImageView" )
	End



	Property Zoom:String()
		Return _zoom
	Setter( zoom:String )
		_zoom = zoom
	End


	Property ImageWidth:int()
		return _doc.Image.Width
	End
	

	Property ImageHeight:int()
		return _doc.Image.Height
	End


	Property ImageZoom:int()
		return int(_zoom * 100)
	End

	
Protected


	
  Method OnValidateStyle() Override
		_buttons = Style.GetImage( "node:buttons" )
	End



	Method OnRender( canvas:Canvas ) Override
    Local FGColor := New Color ( .15,.15,.15, 1 )
    Local SelectedColor := New Color ( 0,.5,1, 1 )
    
		canvas.Color = New Color ( .13,.13,.13, 1 )
		canvas.DrawRect( 0,0, Width,Height )
		
		If Not _doc.Image Then Return
		
		'print _zoom+" "+_doc.Image.Width
		Local imageWidth:int = _zoom * _doc.Image.Width
		Local imageHeight:int = _zoom * _doc.Image.Height
		
		Local imageWidth2:float = imageWidth * 0.5
		Local imageHeight2:float = imageHeight * 0.5
		
		Local width2:Int = Width * 0.5
		Local height2:Int = Height * 0.5
		
		Local x1:Int = (_imageOffsetX*_zoom) + width2 - imageWidth2
		Local x2:Int = (_imageOffsetX*_zoom) + width2 + imageWidth2
		Local y1:Int = (_imageOffsetY*_zoom) + height2 - imageHeight2
		Local y2:Int = (_imageOffsetY*_zoom) + height2 + imageHeight2
		
		If x1 < 0 Then x1 = 0
		If x2 > Width Then x2 = Width
		If y1 < 0 Then y1 = 0
		If y2 > Height Then y2 = Height
		
		canvas.Color = New Color( .2,.2,.2 )
		canvas.DrawRect( x1,y1, x2-x1,y2-y1 )
		
		Local zoomStep:int = (_zoom) * 2
		If zoomStep < 8 Then zoomStep = 8

    Local wd:Int
    Local ht:Int
    canvas.Color = New Color( .4,.4,.4 )
		For Local x := x1 Until x2 Step zoomStep
      wd = zoomStep
      If x + zoomStep > x2 Then wd = x2 - x
      
			For Local y := y1 Until y2 Step zoomStep
        ht = zoomStep
        If y + zoomStep > y2 Then ht = y2 - y
        
        If ((x-x1)~(y-y1)) & zoomStep then
          canvas.DrawRect( x,y, wd,ht )
        End if
'				canvas.Color = (x~y) & zoomStep ? New Color( .4,.4,.4 ) Else New Color( .2,.2,.2 )
'				canvas.DrawRect( x,y, wd,ht )
			Next
		Next
		
		
    canvas.TextureFilteringEnabled = false

		canvas.Color = Color.Black
    canvas.DrawLine( x1,y1, x1,y2 )
    canvas.DrawLine( x2,y1, x2,y2 )
    canvas.DrawLine( x1,y1, x2,y1 )
    canvas.DrawLine( x1,y2, x2,y2 )

		canvas.Color = Color.White
'		canvas.Translate( Width/2, Height/2 )
'		canvas.Scale( _zoom, _zoom )
		canvas.DrawImage( _doc.Image, (_imageOffsetX * _zoom) + width2, (_imageOffsetY * _zoom) + height2, 0,  _zoom, _zoom )


		canvas.Color = FGColor
		canvas.DrawRect( 0,0, 48,128 )
		
		canvas.Color = Color.Black
		canvas.DrawLine( 48,0, 48,128 )
		canvas.DrawLine( 48,128, 0,128 )

		canvas.Color = Color.Grey
    If _over = 0 Then
      canvas.Color = SelectedColor
      DrawFrame( canvas, 4,4, 40,40)
      canvas.Color = Color.White
    endif
		canvas.DrawImageIcon( _buttons, 8,8,   2, 24 )
		canvas.Color = Color.Grey
    If _over = 1 Then
      canvas.Color = SelectedColor
      DrawFrame( canvas, 4,44, 40,40)
      canvas.Color = Color.White
    endif
		canvas.DrawImageIcon( _buttons, 8,32+16,   0, 24 )
		canvas.Color = Color.Grey
    If _over = 2 Then
      canvas.Color = SelectedColor
      DrawFrame( canvas, 4,84, 40,40)
      canvas.Color = Color.White
    endif
		canvas.DrawImageIcon( _buttons, 8,64+24,   1, 24 )
		
	End
	
	
	
	Method DrawFrame( canvas:Canvas, x:Int, y:Int, width:Int, height:Int)
    Local x2:Int = x + width - 1
    Local y2:Int = y + height - 1
    
    canvas.DrawLine( x,y, x2,y )
    canvas.DrawLine( x,y, x,y2 )
    canvas.DrawLine( x2,y2, x2,y )
    canvas.DrawLine( x2,y2, x,y2 )
	End Method


	
	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
      Case EventType.MouseLeave
        _over = -1

      Case EventType.MouseMove
        If Mouse.ButtonReleased( MouseButton.Left ) Then
          _mouseDownX = -1
        End If
        
        _over = -1
        If event.Location.X < 48 Then
          if event.Location.Y < 44 Then
            _over = 0
          else
            if event.Location.Y < 84 Then
              _over = 1
            else
              if event.Location.Y < 128 Then
                _over = 2
              else
              End if  
            End if  
          End if  
        End if
        
        If _mouseDownX > -1 And Mouse.ButtonDown( MouseButton.Left ) Then
'          print "down"
          _imageOffsetX = (event.Location.X - _mouseDownX) / _zoom
          _imageOffsetY = (event.Location.Y - _mouseDownY) / _zoom
          
        End If
        
      Case EventType.MouseDown
        Select _over
          Case 1
            _zoom *= 2
						ZoomChanged()
          Case 2
            _zoom /= 2
						ZoomChanged()
          Case 0
            _zoom = 1
            _imageOffsetX = 0
            _imageOffsetY = 0
            _mouseDownX = -1
						ZoomChanged()
         default
            _mouseDownX = event.Location.X - _imageOffsetX
            _mouseDownY = event.Location.Y - _imageOffsetY
        End select
        If _zoom < 0.01 Then _zoom = 0.01
        
      Case EventType.MouseWheel
        If event.Wheel.Y < 0 then
          _zoom *= 2
        Else If event.Wheel.Y > 0
          _zoom /= 2
        Endif
        If _zoom < 0.01 Then _zoom = 0.01
				ZoomChanged()
		End
	End



	Method OnKeyEvent( event:KeyEvent ) Override
	
		Select event.Type
      Case EventType.KeyDown
  '      print Int(event.Key)
        Select event.Key
          Case Key.Key0
            _zoom = 1
            _imageOffsetX = 0
            _imageOffsetY = 0
            _mouseDownX = -1
            
          Case Key.Minus
            _zoom /= 2
            
          Case Key.Equals
            _zoom *= 2
        End

        If _zoom < 0.01 Then _zoom = 0.01
        ZoomChanged()
		End
		
		Super.OnKeyEvent( event)
	
	End

	
Private
  
  Field _mouseDownX:Int = -1
  Field _mouseDownY:Int = -1
  Field _imageOffsetX:Int = 0
  Field _imageOffsetY:Int = 0
  
	Field _zoom:Float = 1

	Field _buttons:Image
	Field _over:Int = -1
		
	Field _doc:ImgDocument
End



Class ImgDocument Extends Ted2Document



	Method New( path:String )
		Super.New( path )
		
		_view = New ImageView( Self )
	End


	
	Property Image:Image()
		Return _image
	End


	
	Protected


	
	Method OnLoad:Bool() Override
		'Print "Loading image:"+Path
	
		_image = Image.Load( Path )
		If Not _image Then
      return False
    End if
		
		'Print "OK!"
		
		_image.Handle = New Vec2f( .5,.5 )
		
		Return True
	End


	
	Method OnSave:Bool() Override
		Return False
	End


	
	Method OnClose() Override
		If _image _image.Discard()
	End


	
	Method OnCreateView:ImageView() Override
		Return _view
	End


	
	Private


	
	Field _image:Image
	Field _view:ImageView
	
End
