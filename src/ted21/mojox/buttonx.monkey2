
Namespace mojox



Class Buttonx Extends Label



	Method New()
		Layout = "float"
		Style = Style.GetStyle( "mojo.Buttonx" )
		TextGravity = New Vec2f( .5,.5 )
	End
	

	
	Method New( text:String, width:Int, height:int )
		Self.New()

    _width = width - 4
    _height = height
    
		Text = text
	End



	Method New( action:Action, text:String, width:Int, height:int )
		Self.New()

    _width = width - 4
    _height = height
    
		Text = text

		Clicked = Lambda()
			action.Trigger()
		End
	End


	
	Property Selected:Bool()
		Return _selected
	Setter( selected:Bool )
		_selected = selected
		UpdateStyleState()
	End



	Property Hover:Bool()
		Return _hover
	Setter( hover:Bool )
		_hover = hover
		UpdateStyleState()
	End



	Property Live:Bool()
		Return _live
	Setter( live:Bool )
		_live = live
		UpdateStyleState()
	End



	Property ImageIcon:int()
		Return _imageIcon
	Setter( imageIcon:int )
		_imageIcon = imageIcon
	End

	
Protected

	Field _selected:Bool
	Field _live:Bool = true
	Field _active:Bool
	Field _hover:Bool
	
	Field _width:Int = 200
	Field _height:Int = 32
	
	field _imageIcon:int = -1
	Field _icons:Image
	
	Field _org:Vec2i
	
	Field _mouse:Vec2i
	Field _mousedown:Bool



	Method OnRender( canvas:Canvas ) Override
    Local selectedColor := New Color ( 0,.4,.9, 1 )
    Local selectedColor2 := New Color ( 0,.4,.9, 0.5 )
    
    If Text <> "" then
      canvas.Color = Color.White
      canvas.DrawText( Text, 10, 4 )
      canvas.DrawText( Text, 11, 4 )
    Endif


    If _imageIcon > -1 then
				canvas.Color = Color.White
				canvas.DrawImageIcon( _icons, 4,7,  _imageIcon, 80,  1.8,1.8)
    end If
    
    if _live = false then Return
    
    if Hover Then
      canvas.Color = selectedColor2
      canvas.DrawRect(0,0, Width, Height)
    end If
    
    If Selected then
      canvas.Color = selectedColor'Style.checked
      
      canvas.DrawRect(0,0, Width, 3)
      canvas.DrawRect(0,0, 3, Height)
      canvas.DrawRect(0,Height-3, Width, 3)
      canvas.DrawRect(Width-3,0, 3, Height)
     End if
  End 

	
	
	
	Method OnMeasure:Vec2i() Override
		Local size := New Vec2i
		
		size.x = _width
		size.y = _height

		Return size
	End


	
	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
      Case EventType.MouseDown
        _org=event.Location
        _active = True
        _mousedown = True
        
      Case EventType.MouseUp
        If _active And _hover
          _mousedown = False
          
          Clicked()
        Endif
        _active = False

      Case EventType.MouseEnter
        _hover = True

      Case EventType.MouseLeave
        _hover = False

      Case EventType.MouseMove
        _mouse = event.Location
        If _active Dragged( event.Location-_org )
		End
		
		UpdateStyleState()
	End


	
	method OnValidateStyle() Override
			_icons = Style.GetImage( "node:icons" )
	end Method
	
	

	Method UpdateStyleState()
		if _live = false Then
			StyleState = ""
			Return
		end If
		
		If _selected
			StyleState="selected"
		Else If _active And _hover
			StyleState="active"
		Else If _active Or _hover
			StyleState="hover"
		Else
			StyleState=""
		Endif
	End




End
