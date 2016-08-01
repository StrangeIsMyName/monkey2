
Namespace mojox

Class Button Extends Label

	Method New()
		Layout="float"
		Style=Style.GetStyle( "mojo.Button" )
		TextGravity=New Vec2f( .5,.5 )
	End


	
	Method New( icon:Image )
		Self.New()
		
		Icon=icon
	End


	
	Method New( text:String, icon:Image=Null )
		Self.New()

		Text=text
		Icon=icon
	End


	
	Method New( action:Action )
		Self.New()
		
		Text=action.Label
		Icon=action.Icon
		
		Clicked=Lambda()
			action.Trigger()
		End
		
		action.Modified=Lambda()
			Enabled=action.Enabled
			Text=action.Label
			Icon=action.Icon
		End
	End


	
	Property Checkable:Bool()
		Return _checkable
	Setter( checkable:Bool)
		_checkable=checkable
	End


	
	Property Hover:Bool()
		Return _hover
	End
	
	
	
	Property Checked:Bool()
		Return _checked
	Setter( checked:Bool )
		_checked=checked
	End


	
	Property Selected:Bool()
		Return _selected
	Setter( selected:Bool )
		_selected=selected
		
		UpdateStyleState()
	End

	
	
Protected
	
	Field _selected:Bool
	Field _checkable:Bool
	Field _checked:Bool
	Field _active:Bool
	Field _hover:Bool
	Field _org:Vec2i
	
	Field _mouse:Vec2i
	Field _mousedown:Bool



	Method OnValidateStyle() Override
		If _checkable And _checked
			CheckMark = RenderStyle.GetImage( "checkmark:checked" )
		Else If _checkable
			CheckMark = RenderStyle.GetImage( "checkmark:unchecked" )
		Else
			CheckMark = Null
		End
	End
	
	
	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
      Case EventType.MouseDown
        _org=event.Location
        _active = True
        _mousedown = true
      Case EventType.MouseUp
        If _active And _hover
          _mousedown = False
          
          If _checkable Then _checked = Not _checked
'          DebugStop()
          Clicked()
        Endif
        _active = False
      Case EventType.MouseEnter
        _hover = True
				Over()
      Case EventType.MouseLeave
        _hover = False
				Over()
      Case EventType.MouseMove
        _mouse = event.Location
        If _active Dragged( event.Location-_org )
		End
		
		UpdateStyleState()
	End


	
	Method UpdateStyleState()
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
