
Namespace mojox



Class TabButtonX Extends Button

	Method New( text:String, view:View )
		Super.New( text )
    Style = Style.GetStyle( "mojo.TabButtonjl" )
		TextGravity = New Vec2f( 0,.5 )
		_view = view
	End


	
	Property View:View()
		Return _view
	End


  Property DrawIcon:String()
    Return _drawIcon
  Setter( drawIcon:String )
    _drawIcon = drawIcon
  End


	
'#rem
	Method OnRender( canvas:Canvas ) Override
		Local x := 0
		Local w := 0
		
'    Local drawIcon:Int = 0
    Local icons := _icons

		If Icon
			Local y := (MeasuredSize.y - Icon.Height)/2'
			canvas.DrawImage( Icon,0,y )
			w += Icon.Width
			x = Icon.Width
		Endif
		
		If CheckMark
			Local y := (MeasuredSize.y - CheckMark.Height)/2
			canvas.DrawImage( CheckMark, Width - CheckMark.Width, y )
			w += CheckMark.Width
		Endif

    If icons And _drawIcon > 0 Then
      canvas.Color = Color.White
      canvas.DrawImageIcon( icons, 3,5,  _drawIcon, 80 )
      x += 12
		End if
		
		If Text
			Local tx := ((Width-w) - (MeasuredSize.x-w)) * TextGravity.x
			Local ty := (Height - MeasuredSize.y) * TextGravity.y
			canvas.DrawText( Text, tx+x+10, ty+5 )
		Endif


		Local ypos := RenderStyle.DefaultFont.Height + 8
		Local width := RenderStyle.DefaultFont.TextWidth( Text ) + 40
		
		_mousex = 0

    If _hover And _mouse.x > width-15 Then
      If _mousedown Then
        canvas.Color = New Color( 1,0,0, 1 )
        _mousex = _mouse.x
      else
        canvas.Color = New Color( 0.7,0,0, 1 )
      End if
      canvas.DrawRect ( width-18,4,  15,MeasuredSize.y-9 )
      canvas.Color = New Color( 1,1,1, 1 )
    else  
      canvas.Color = New Color( 1,1,1, 0.5 )
    End If
    
		canvas.DrawText( "X", width-15, 5 )

		canvas.Color = New Color( 1,1,1, 0.05 )
    canvas.DrawRect ( 1,0, width-2,ypos )

		canvas.Color = New Color( 0,0,0, 0.3 )
    canvas.DrawLine ( 0,ypos, 0, 0)
    canvas.DrawLine ( width,ypos, width, 0)


		width = width + 1
		
    canvas.DrawLine ( 0,0, width, 0)
		
		canvas.Color = New Color( 0,.5,1 )
		canvas.DrawRect(0,ypos, width, 2)

	End


	
	Method OnMeasure:Vec2i() Override
		Local size := New Vec2i
		
		If Text
			size.x = RenderStyle.DefaultFont.TextWidth( Text ) + 40
			size.y = RenderStyle.DefaultFont.Height + 10
		Endif

		If Icon
			size.x += Icon.Width
			size.y = Max( size.y,Int( Icon.Height ) )
		Endif
		
		If CheckMark
			size.x += CheckMark.Width
			size.y = Max( size.y,Int( CheckMark.Height ) )
		Endif
		
		Return size
	End
'#end



	Method OnValidateStyle() Override
'    print "validate"
'		_collapsedIcon = Style.GetImage( "node:collapsed" )
'		_expandedIcon = Style.GetImage( "node:expanded" )
		_icons = Style.GetImage( "node:icons" )
		
'		_nodeSize=Style.DefaultFont.Height
'		_nodeSize=Max( _nodeSize,Int( _expandedIcon.Height ) )
'		_nodeSize=Max( _nodeSize,Int( _collapsedIcon.Height ) )
	End
	
	
		
Private
	
	Field _view:View
  Field _mousex:Int
  
  Field _drawIcon:Int = 0
  
	Field _icons:Image
End



Class TabViewX Extends View

	Field CurrentChanged:Void()




	Method New()
		Style=Style.GetStyle( "mojo.TabView" )
		Layout="fill"
	End



	Property GetTabMouseX:int( view:View )
		Return _tabs[IndexOfView( view )]._mousex
	End

	
	Property Count:Int()
		Return _tabs.Length
	End


	Property GetMouseX:Int()
    If _current Then Return _current._mousex
    Return 0
	End

	
	Property CurrentIndex:Int()
		If _current Return IndexOfView( _current.View )
		Return -1
	Setter( currentIndex:Int )
		MakeCurrent( _tabs[currentIndex] )
	End


	
	Property CurrentView:View()
		If _current Return _current.View
		Return Null
	Setter( currentView:View )
		For Local tab:=Eachin _tabs
			If tab.View<>currentView Continue
			MakeCurrent( tab )
			Return
		Next
	End


	
	Method ViewAtIndex:View( index:Int )
		Return _tabs[index].View
	End



	Method IndexOfView:Int( view:View )
		For Local i := 0 Until _tabs.Length
			If _tabs[i].View = view Return i
		Next
		Return -1
	End



	Method AddTab:Int( text:String, view:View, makeCurrent:Bool = False )
		Local index := _tabs.Length

		Local tab := New TabButtonX( text, view )
		tab.Clicked = Lambda()
			MakeCurrent( tab )
		End
		_tabs.Add( tab )

		AddChild( tab )

		If makeCurrent then MakeCurrent( tab )

		Return index
	End


	
	Method RemoveTab( view:View )
		RemoveTab( IndexOfView( view ) )
	End


	
	Method RemoveTab( index:Int )
		If _current=_tabs[index]
			_current.Selected=False
			RemoveChild( _current.View.Container )
			_current=Null
		Endif
		
		RemoveChild( _tabs[index] )
		
		_tabs.Erase( index )
	End


	
	Method SetTabLabel( view:View, label:String, icon:Int = 0 )
		SetTabLabel( IndexOfView( view ), label, icon )
	End

	Method SetTabLabel( index:Int, label:String, icon:Int = 0 )
		_tabs[index].Text = label
		_tabs[index].DrawIcon = icon
	End



	Method SetTabIcon( view:View, icon:Int )
		SetTabIcon( IndexOfView( view ), icon )
	End

	Method SetTabIcon( index:Int, icon:Int )
		_tabs[index].DrawIcon = icon
	End

	
Private
	
	Field _tabs := New Stack<TabButtonX>
	
	Field _current:TabButtonX
	Field _previous:TabButtonX
	
	Field _buttonsSize:Vec2i


	
	Method MakeCurrent( tab:TabButtonX )
'    print "tabx="+tab._mousex
   ' DebugStop()
'		If tab = _current Return
		
		If _current 
			_current.Selected = False
			RemoveChild( _current.View.Container )
		Endif

		_current = tab

		If _current
			_current.Selected = True
			AddChild( _current.View.Container )
		Endif
		
		CurrentChanged()
	End
	
	
	
	Method OnRender( canvas:Canvas ) Override
'#rem
    If Not(_current) Then Return
    
 		Local BGColor := New Color( 0.2, 0.2, 0.2 )
'		Local BlackColor := New Color( 0.06, 0.06, 0.06 )
		Local HilightColor := New Color( 0, 0.5, 1 )

		
		canvas.Color = BGColor
    canvas.DrawRect( 0, 1, _current.View.Container.Frame.Width, _current.View.Container.Frame.Height-1 )

    'print Height-1
		canvas.Color = HilightColor'BlackColor
'    canvas.DrawLine( 0, 25, _current.View.Container.Frame.Width, 25 )
    canvas.DrawRect( 0, 24, _current.View.Container.Frame.Width, 2 )
'#end    
	End
	
		
	Method OnMeasure:Vec2i() Override
		Local size := New Vec2i
		
		For Local tab := Eachin _tabs
			size.x += tab.LayoutSize.x
			size.y = Max( size.y, tab.LayoutSize.y )
		Next
		
		_buttonsSize = size
		
		If _current
			size.x = Max( size.x, _current.View.LayoutSize.x )
			size.y += _current.View.LayoutSize.y
		Endif
		
		Return size
	
	End
	
	
	
	Method OnLayout() Override
		Local x := 0
		
		For Local tab := Eachin _tabs
			tab.Frame = New Recti( x, 0, x+tab.LayoutSize.x, _buttonsSize.y )
			x += tab.LayoutSize.x
		Next
		
		If _current then _current.View.Container.Frame = New Recti( 0, _buttonsSize.y, Width, Height )
	End
	
End

