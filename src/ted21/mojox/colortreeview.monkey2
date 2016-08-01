
Namespace mojox






Class ColorTreeView Extends View

	Field NodeClicked:Void( node:Node, event:MouseEvent )
'	Field NodeToggled:Void( node:Node, event:MouseEvent )

	Class Node
	
'		Method New( label:String, kind:Int, parent:Node = Null, index:Int = -1 )
		Method New( label:String, kind:Int, parent:Node, index:Int = -1)
      If Not(parent) Then
        index = -1
        If kind = NODEKIND_FOLDER then
          kind = NODEKIND_APP
        End if
      End If
        
			If parent parent.AddChild( Self, index )
			
			Label = label
			Kind = kind
			
'			If index > -1 Then
        Index = index
'      End if
		End



		Method New( label:String, red:float, green:float, blue:float, parent:Node, index:Int = -1)
      local kind:int = NODEKIND_COLOR
      
      If Not(parent) Then
        index = -1
        kind = NODEKIND_PALETTE
      End If
        
			If parent parent.AddChild( Self, index )
			
			Label = label
			Kind = kind
			Red = red
			Green = green
			Blue = blue
			
'			If index > -1 Then
        Index = index
'      End if
			
		End


		
		Property Label:String()
			Return _label
		Setter( label:String )
			_label = label
			
			Dirty()
		End



		Property Kind:String()
			Return _kind
		Setter( kind:String )
			_kind = kind
			
			Dirty()
		End



		Property Index:String()
			Return _index
		Setter( index:String )
			_index = index
			
			Dirty()
		End



		Property Red:Float()
			Return _red
		Setter( red:Float )
			_red = red
		End


		Property Green:Float()
			Return _green
		Setter( green:Float )
			_green = green
		End


		Property Blue:Float()
			Return _blue
		Setter( blue:Float )
			_blue = blue
		End


		Property Parent:Node()
			Return _parent
		End


		
		Property NumChildren:Int()
			Return _children.Length
		End


		
		Property Children:Node[]()
			Return _children.ToArray()
		End


	
		Property Expanded:Bool()
			Return _expanded
		Setter( expanded:Bool )
			_expanded=expanded
			
			Dirty()
		End


		
		Property Rect:Recti()
			Return _rect
		End


		
		Property Bounds:Recti()
			Return _bounds
		End


		
		Method AddChild( node:Node, index:Int=-1 )
			If node._parent Return
			
			'If index = -1
				index = _children.Length
			'Else
			'	Assert( index >= 0 And index <= _children.Length )
			'Endif
			
			node._parent = Self
			
			_children.Insert( index, node )
			
			node.Dirty()
		End


		
		Method RemoveChildren( index1:Int, index2:Int )
			Assert( index1>=0 And index2>=index1 And index1<=_children.Length And index2<=_children.Length )
		
			For Local i:=index1 Until index2
				_children[i]._parent=Null
			Next
			
			_children.Erase( index1,index2 )
			
			Dirty()
		End


		
		Method RemoveChild( node:Node )
			If node._parent<>Self Return
			
			_children.Remove( node )
			
			node._parent=Null
			
			Dirty()
		End


		
		Method RemoveChild( index:Int )
			RemoveChild( GetChild( index ) )
		End


		
		Method RemoveChildren( first:Int )
			RemoveChildren( first,_children.Length )
		End



		Method RemoveAllChildren()
			RemoveChildren( 0,_children.Length )
		End



		Method Remove()
			If _parent _parent.RemoveChild( Self )
		End


		
		Method GetChild:Node( index:Int )
			If index>=0 And index<_children.Length Return _children[index]
			
			Return Null
		End


		
		Private

		Field _parent:Node
		Field _children := New Stack<Node>
		Field _label:String
		Field _index:int

		field _red:Float
		field _green:Float
		field _blue:Float
		
		Field _expanded:Bool
		Field _kind:int
		Field _bounds:Recti
		Field _rect:Recti
		Field _dirty:Bool


		
		Method Dirty()
			_dirty = True
			Local node := _parent
			While node
				node._dirty = True
				node = node._parent
			Wend
		End
		
	End


	
	Method New()
		Layout = "fill"
		Style = Style.GetStyle( "mojo.ColorTreeView" )
		_rootNode = New Node( Null, NODEKIND_NONE, null )
	End



	Property RootNode:Node()
		Return _rootNode
	Setter( node:Node)
		_rootNode = node
	End


	
	Property RootNodeVisible:Bool()
		Return _rootNodeVisible
	Setter( rootNodeVisible:Bool )
		_rootNodeVisible = rootNodeVisible
	End


	
	Method FindNodeAtPoint:Node( point:Vec2i )
		Return FindNodeAtPoint( _rootNode, point )
	End


	
	Property Container:View() Override
		If Not _scroller
			_scroller = New ScrollView( Self )
		Endif
		Return _scroller
	End



	Property SelectedIndex:Int()
		Return _selectedIndex
	Setter( selectedIndex:int )
		_selectedIndex = selectedIndex
	End



	Property Label:String()
		Return _selectedLabel
	Setter( selectedLabel:String )
		_selectedLabel = selectedLabel
	End



	Property Red:Float()
		Return _selectedRed
	Setter( selectedRed:Float )
		_selectedRed = selectedRed
	End


	Property Green:Float()
		Return _selectedGreen
	Setter( selectedGreen:Float )
		_selectedGreen = selectedGreen
	End


	Property Blue:Float()
		Return _selectedBlue
	Setter( selectedBlue:Float )
		_selectedBlue = selectedBlue
	End



	Property IndexCount:Int()
		Return _indexCount
	Setter( indexCount:int )
		_indexCount = indexCount
	End
	
Private


	
	Field _rootNode:Node
	Field _rootNodeVisible := True
	Field _scroller:ScrollView
	
	field _selectedRed:Float
	field _selectedGreen:Float
	field _selectedBlue:Float
	field _selectedLabel:String
	Field _selectedIndex:Int = -1
	Field _indexCount:Int = 0

	Field _expandedIcon:Image
	Field _collapsedIcon:Image
	Field _icons:Image
	Field _nodeSize:Int


		
	Method FindNodeAtPoint:Node( node:Node, point:Vec2i )
		If node._rect.Contains( point ) Then Return node
	
		If node._expanded And node._bounds.Contains( point )
		
			For Local child := Eachin node._children
			
				Local cnode := FindNodeAtPoint( child, point )
				If cnode Return cnode

			Next

		Endif
		
		Return Null
	End


	
	Method MeasureNode( node:Node, origin:Vec2i, dirty:Bool )
		If Not node._dirty And Not dirty Then Return

		node._dirty = False
	
		Local size:Vec2i
		Local nodeSize := 0
		
		If _rootNodeVisible Or node<>_rootNode then
			size = New Vec2i( Style.DefaultFont.TextWidth( node.Label ) + _nodeSize + 30, _nodeSize )
			nodeSize = _nodeSize
		Endif
		
		Local rect := New Recti( origin, origin + size )
		
		node._rect = rect
		
		If node._expanded then
		
			origin.x += nodeSize
		
			For Local child := Eachin node._children
			
				origin.y = rect.Bottom
			
				MeasureNode( child, origin, True )
				
				rect |= child._bounds
			Next
		
		Endif
		
		node._bounds=rect
	End
	
	


	Method RenderNode( canvas:Canvas, node:Node )
		If Not node._bounds.Intersects( ClipRect ) Then return
	
		If _rootNodeVisible Or node <>_rootNode then
		
      Local icons := _icons
			Local xoffset:Int = 17
			Local icon := _collapsedIcon
			Local x := (_nodeSize-icon.Width)/2
			Local y := (_nodeSize-icon.Height)/2
			Local drawIcon:Int = node._kind
			
			If _selectedIndex > -1 And _selectedIndex = node._index then
        canvas.Color = New Color( 0.1,0.3,0.6, 1 )
        canvas.DrawRect( 0,node._rect.Y,  Width, icon.Height+4 )
			End if
      

			If node._children.Length then
				If node._expanded Then
          icon = _expandedIcon
          If node._kind = NODEKIND_FOLDER then
            drawIcon = drawIcon + 1
          End if
        End if

				
				canvas.Color = Color.White
				canvas.DrawImage( icon, node._rect.X+x, node._rect.Y+y )

			Endif
			
			if drawIcon = NODEKIND_COLOR Then
        canvas.Color = New Color( node._red, node._green, node._blue, 1 )
        canvas.DrawRect( node._rect.X+x+xoffset-5,node._rect.Y,  icon.Width+7, icon.Height+2 )
			else
        canvas.DrawImageIcon( icons, node._rect.X+x+xoffset, node._rect.Y+y-1,  drawIcon, 80 )
      end if

			
			canvas.Color = Style.DefaultColor
'			canvas.DrawText( node._index, node._rect.X+_nodeSize+25, node._rect.Y )
'			canvas.DrawText( node._label, node._rect.X+_nodeSize+50, node._rect.Y )
			canvas.DrawText( node._label, node._rect.X+_nodeSize+25, node._rect.Y )
		
		Endif
			
		If node._expanded then

			For Local child:=Eachin node._children
				RenderNode( canvas,child )
			Next

		Endif
	End


	
	Method OnValidateStyle() Override
		_collapsedIcon = Style.GetImage( "node:collapsed" )
		_expandedIcon = Style.GetImage( "node:expanded" )
		_icons = Style.GetImage( "node:icons" )
		
		_nodeSize=Style.DefaultFont.Height
		_nodeSize=Max( _nodeSize,Int( _expandedIcon.Height ) )
		_nodeSize=Max( _nodeSize,Int( _collapsedIcon.Height ) )
	End


	
	Method OnMeasure:Vec2i() Override
		If Not _rootNode Return New Vec2i( 0,0 )
		
		Local origin:Vec2i
		
		'If Not _rootNodeVisible origin=New Vec2i( -_nodeSize,-_nodeSize )
	
		MeasureNode( _rootNode, origin, false )
		
		Return _rootNode._bounds.Size
	End


	
	Method OnRender( canvas:Canvas ) Override
		If Not _rootNode Return
	
		RenderNode( canvas, _rootNode )

'		Print "TreeView ClipRect="+ClipRect.ToString()
	End


	
	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
      Case EventType.MouseDown
        SelectedIndex = -1
        Local node := FindNodeAtPoint( event.Location )

        If node
          Local p := event.Location - node._rect.Origin
          
          If p.x < _nodeSize And p.y < _nodeSize then
            node.Expanded = Not node._expanded
'            NodeToggled( node,event )
          Else
'            print node._red+" "+node._green+" "+node._blue
            Red = node._red
            Green = node._green
            Blue = node._blue
            Label = node._label
            SelectedIndex = node._index
            NodeClicked( node, event )
          Endif
          
        Endif
        
      Case EventType.MouseWheel
        Super.OnMouseEvent( event )
        Return

		End
	
	End


	
End

