
Namespace mojox




Class MenuButton Extends Button




	Method New( text:String, imageIcon:int = -1  )
		Super.New( text )
		
		Layout = "fill"
		Style = Style.GetStyle( "mojo.MenuButton" )
		TextGravity = New Vec2f( 0,.5 )

		_imageIcon = imageIcon

'		MinSize=New Vec2i( 128,0 )
	End


	
	Method New( action:Action, imageIcon:int = -1 )
		Super.New( action )
		
		Layout = "fill"
		Style = Style.GetStyle( "mojo.MenuButton" )
		TextGravity = New Vec2f( 0,.5 )
		
		MinSize = New Vec2i( 160,0 )
		
		_imageIcon = imageIcon

		_action=action
	End


	
	Method OnMeasure:Vec2i() Override
		Local size:=Super.OnMeasure()
		
		If _action
			Local hotKey := _action.HotKeyLabel
			If hotKey size.x += Style.DefaultFont.TextWidth( "         "+hotKey+35 )
		Endif
		
		Return size
	End


	
	Method OnRender( canvas:Canvas ) Override
		Local ty := (Height - MeasuredSize.y) * TextGravity.y
		
		If not _action and _imageIcon = -1 then
			If Text
				Local tx := ((Width)-(MeasuredSize.x)) * TextGravity.x
				Local ty := (Height-MeasuredSize.y) * TextGravity.y
				
				if _subMenu then
					canvas.DrawText( Text, tx+25, ty )
				canvas.DrawImageIcon( _icons, Width-16, ty,  NODEKIND_SUBMENU, 80 )
				else	
					canvas.DrawText( Text, tx, ty )
				end if
			Endif
			
		else
		
			If Text
				Local tx := ((Width)-(MeasuredSize.x)) * TextGravity.x
				Local ty := (Height-MeasuredSize.y) * TextGravity.y
				canvas.DrawText( Text, tx+25, ty )
			Endif

			if _imageIcon > -1 then
				canvas.Color = Color.White
				canvas.DrawImageIcon( _icons, 0, ty,  _imageIcon, 80 )
			end if
			
			Local hotKey := _action.HotKeyLabel
			If hotKey
				Local w := Style.DefaultFont.TextWidth( hotKey )
				Local tx := (Width - w)
				canvas.DrawText( hotKey, tx, ty )
			Endif
		Endif
	End


	
	Method OnValidateStyle() Override
		_icons = Style.GetImage( "node:icons" )
	end Method
	
	
	Field _action:Action
	Field _icons:Image
	Field _imageIcon:int = -1
	field _subMenu:bool = false



End



Class Menu Extends DockingView

	Method New( label:String )
		_label = label
		Visible = False
		Style = mojo.app.Style.GetStyle( "mojo.Menu" )
		Layout = "float"
		Gravity = New Vec2f( 0,0 )
	End


	
	Property Label:String()
		Return _label
	End


	
	Method Clear()
		Super.ClearViews()
	End


	
	Method AddAction( action:Action, imageIndex:int = -1 )
		Local button := New MenuButton( action, imageIndex )
		button._imageIcon =  imageIndex
		button.Clicked += Lambda()
			_open[0].Close()
		End
		AddView( button, "top", 0 )
	End


	
	Method AddAction:Action( label:String, imageIndex:int = -1 )
		Local action := New Action( label )
		AddAction( action, imageIndex )
		Return action
	End


	
	Method AddSeparator()
		AddView( New Separator, "top", 0 )
	End


	
	Method AddSubMenu( menu:Menu )
		Local label := New MenuButton( menu.Label )
		label._subMenu = true

		label.Over = Lambda()
			if label.Hover Then
				'print "hover"
				If Not menu.Visible
					Local location := New Vec2i( label.Bounds.Right, label.Bounds.Top )
					menu.Open( location, label, Self )
				end if
			Else
				If menu.Visible
					'menu.Close()
					'Return
				Endif
				'print "off"
			end if
		end

		label.Clicked = Lambda()
			If menu.Visible
				menu.Close()
			Else
				Local location := New Vec2i( label.Bounds.Right, label.Bounds.Top )
				menu.Open( location, label, Self )
			Endif
		End
		
		AddView( label, "top", 0 )
	End


	
	Method Open( location:Vec2i, view:View, owner:View )
		Assert( Not Visible )
		
		While Not _open.Empty And _open.Top<>owner
			_open.Top.Close()
		Wend
		
		If _open.Empty
			_filter = App.MouseEventFilter
			App.MouseEventFilter = MouseEventFilter
		Endif
		
		Local window := view.FindWindow()
		location = view.TransformPointToView( location, window )
		
		window.AddChild( Self )
		Offset = location
		Visible = True
		
		_owner = owner
		_open.Push( Self )
	End


	
	Method Close()
		Assert( Visible )
		
		While Not _open.Empty
		
			Local menu := _open.Pop()
			menu.Parent.RemoveChild( menu )
			menu.Visible = False
			menu._owner = Null
			
			If menu = Self Exit
		Wend
		
		If Not _open.Empty Return
		
		App.MouseEventFilter = _filter
		_filter = Null
	End


	
Private


	
	Field _label:String
	Field _owner:View
	
	Global _open := New Stack<Menu>
	Global _filter:Void( MouseEvent )


	
	Function MouseEventFilter( event:MouseEvent )
		If event.Eaten Return
		
		Local view := event.View
		
		If view <> _open[0]._owner
			
			For Local menu := Eachin _open
				If view.IsChildOf( menu ) Return
			Next
		
			If view.IsChildOf( _open[0]._owner ) Return

		Endif
		
		If event.Type <> EventType.MouseDown
			event.Eat()
			Return
		Endif
		
		event.Eat()
		
		_open[0].Close()
	End
		
End



Class MenuBar Extends DockingView

	Method New()
		Style = Style.GetStyle( "mojo.MenuBar" )
		Layout = "fill"
	End


	
	Method AddMenu( menu:Menu, imageIcon:int = -1 )
		Local label := New MenuButton( menu.Label, imageIcon )
		
		label.Over = Lambda()
			if label.Hover Then
				'print "hover"
				If Not menu.Visible
					Local location := New Vec2i( label.Bounds.Left, label.Bounds.Bottom )
					menu.Open( location, label, Self )
				end if
			Else
				If menu.Visible
					'menu.Close()
					'Return
				Endif
				'print "off"
			end if
		end

		label.Clicked = Lambda()
			If Not menu.Visible
				Local location := New Vec2i( label.Bounds.Left, label.Bounds.Bottom )
				menu.Open( location, label, Self )
			Else
				menu.Close()
				Return
			Endif
		End
		
		AddView( label, "left", 0 )
	End
	
End
