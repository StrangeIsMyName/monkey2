
Namespace mojox


Const NODEKIND_COLOR:Int = -1

Const NODEKIND_NONE:Int = 0

Const NODEKIND_FOLDER:Int = 1
Const NODEKIND_FOLDEROPEN:Int = 2
Const NODEKIND_FILE:Int = 3
Const NODEKIND_TEXT:Int = 4
Const NODEKIND_DEBUG:Int = 5
Const NODEKIND_APP:Int = 6
Const NODEKIND_SEARCH:Int = 7
Const NODEKIND_FIND:Int = 7
Const NODEKIND_CLASS:Int = 8
Const NODEKIND_MODULE:Int = 9
Const NODEKIND_STRUCT:Int = 10
Const NODEKIND_ENUM:Int = 11
Const NODEKIND_CONST:Int = 12
Const NODEKIND_GLOBAL:Int = 13
Const NODEKIND_FIELD:Int = 14
Const NODEKIND_CONSTRUCTOR:Int = 15
Const NODEKIND_PROPERTY:Int = 16
Const NODEKIND_METHOD:Int = 17
Const NODEKIND_EVENT:Int = 18
Const NODEKIND_FUNCTION:Int = 19
Const NODEKIND_PROJECT:Int = 20
Const NODEKIND_CPP:Int = 21
Const NODEKIND_H:Int = 22
Const NODEKIND_M:Int = 23
Const NODEKIND_HTML:Int = 24
Const NODEKIND_SCRIPT:Int = 25
Const NODEKIND_WEBSCRIPT:Int = 26
Const NODEKIND_DEBUGPARENT:Int = 27
Const NODEKIND_DEBUGFUNCTION:Int = 28
Const NODEKIND_DEBUGVAR:Int = 29
Const NODEKIND_DEBUGCOMPOSITE:Int = 30
Const NODEKIND_MONKEY2:Int = 31
Const NODEKIND_JAVASCRIPT:Int = 32
Const NODEKIND_IMAGE:Int = 33
Const NODEKIND_AUDIO:Int = 34
Const NODEKIND_FONT:Int = 35
Const NODEKIND_PALETTE:Int = 36
Const NODEKIND_SWATCH:Int = 37
Const NODEKIND_DEBUGOFF:Int = 38
Const NODEKIND_DEBUGON:Int = 39
Const NODEKIND_TAB:Int = 40
Const NODEKIND_OPERATOR:Int = 41
Const NODEKIND_SPACE:Int = 42
Const NODEKIND_RETURN:Int = 43
Const NODEKIND_LAMBDA:Int = 44
Const NODEKIND_OPEN:Int = 45
Const NODEKIND_SAVE:Int = 46
Const NODEKIND_SAVEAS:Int = 47
Const NODEKIND_NEW:Int = 48
Const NODEKIND_PREV:Int = 49
Const NODEKIND_NEXT:Int = 50
Const NODEKIND_UNDO:Int = 51
Const NODEKIND_REDO:Int = 52
Const NODEKIND_RUN:Int = 53
Const NODEKIND_RUNDEBUG:Int = 54
Const NODEKIND_VLINE:Int = 55
Const NODEKIND_SUBMENU:Int = 56
Const NODEKIND_OSXCLOSE:Int = 57
Const NODEKIND_WINDOWSCLOSE:Int = 58
Const NODEKIND_PANEL:Int = 59
Const NODEKIND_CONSOLE:Int = 60
Const NODEKIND_COLORPANEL:Int = 61
Const NODEKIND_CLASSEXTRA:Int = 62




Class TreeView Extends View

	Field NodeClicked:Void( node:Node, event:MouseEvent )
	Field NodeToggled:Void( node:Node, event:MouseEvent )

#-



	Class Node
	
'		Method New( label:String, kind:Int, parent:Node = Null, index:Int = -1 )
		Method New( label:String, kind:Int, parent:Node, index:Int = -1)
			If Not(parent) Then
				index = -1
				If kind = NODEKIND_FOLDER then
					kind = NODEKIND_APP
			  End if
			End If
       
			If parent Then
				parent.AddChild( Self, index )
			end if
			
			Label = label
			Kind = kind
			
			If index > -1 Then
				Index = index
			End if
		End



		Method New( label:String, kind:Int, parent:Node, index:Int, line:int)
			If Not(parent) Then
				index = -1
				If kind = NODEKIND_FOLDER then
					kind = NODEKIND_APP
			  End if
			End If
       
			If parent Then
				parent.AddChild( Self, index )
			end if
			
			Label = label
			Kind = kind
			Line = line
			
			If index > -1 Then
				Index = index
			End if
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



		Property Line:String()
			Return _line
		Setter( line:String )
			_line = line
			
			Dirty()
		End



		Property Index:String()
			Return _index
		Setter( index:String )
			_index = index
			
			Dirty()
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
			
			If index = -1
				index = _children.Length
			Else
				Assert( index >= 0 And index <= _children.Length )
			Endif
			
			node._parent = Self
			
			_children.Insert( index, node )
			
			node.Dirty()
		End



		
    Method AddChild( label:String, kind:Int, index:Int, line:int)

			_children.Insert( index, self )

      Label = label
      Kind = kind
      Line = line
      If index > -1 Then
        Index = index
      End if

    end method



		Method RemoveChildren( index1:Int, index2:Int )
			Assert( index1 >= 0 And index2 >= index1 And index1 <= _children.Length And index2 <= _children.Length )
		
			For Local i := index1 Until index2
				_children[i]._parent = Null
			Next
			
			_children.Erase( index1, index2 )
			
			Dirty()
		End


		
		Method RemoveChild( node:Node )
			If node._parent <> Self Return
			
			_children.Remove( node )
			
			node._parent=Null
			
			Dirty()
		End


		
		Method RemoveChild( index:Int )
			RemoveChild( GetChild( index ) )
		End


		
		Method RemoveChildren( first:Int )
			RemoveChildren( first, _children.Length )
		End



		Method RemoveAllChildren()
			RemoveChildren( 0, _children.Length )
		End



		Method Remove()
			If _parent _parent.RemoveChild( Self )
		End


		
		Method GetChild:Node( index:Int )
			If index >= 0 And index < _children.Length Return _children[index]
			
			Return Null
		End


		
		Private

		Field _parent:Node
		Field _children := New Stack<Node>
		
		Field _label:String
		Field _index:int
		Field _expanded:Bool
		Field _kind:int
		Field _line:int
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
		Style = Style.GetStyle( "mojo.TreeView" )
		_rootNode = New Node( Null, NODEKIND_NONE, null )
	End
	
	
	
	method RemoveAllChildren()
		_rootNode.RemoveAllChildren()
	end method



	method RemoveChildrenFromLine( line:int )
'		print "  REMOVE FROM "+line
		
		_removeNode = null
		RemoveLine( null, _rootNode, line)
		if _removeNode <> null Then
			_indexCount = _removeNode.Index
'			print " REMOVE FROM "+_removeNode.Line+" index="+ _removeNode.Index
			_rootNode.RemoveChildren( _removeNode.Index )
		end if

'		print "  SHOW"
'		ShowLine( _rootNode)
	end Method
	
	
	method RemoveLine( parent:Node, node:Node, line:int )
		local checkline:int = node.Line
		'print "START TRIM"
'		print checkline+" "+line
		if checkline >= line Then
			if _removeNode = null Then
				_removeNode = node
'				print "START"
			end if
'			print "remove  "+node.Label+" "+checkline+"  "+line
		end if
		
		if not node then Return
		
		For Local child := Eachin node._children
			if _removeNode = null then RemoveLine( parent, child, line )
		Next
	end method




	Method AddNodeToEnd( label:String, kind:Int, line:Int )
    new Node( label, kind, _rootNode, _indexCount, line )
	end method
	
	Method AddNode( label:String, kind:Int, line:Int )
'    print _indexCount
    
    new Node( label, kind, _rootNode, _indexCount, line )

    _indexCount += 1

	end method

	
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



	Property SelectedLine:Int()
		Return _selectedLine
	Setter( selectedLine:int )
		_selectedLine = selectedLine
	End



	Property IndexCount:Int()
		Return _indexCount
	Setter( indexCount:int )
		_indexCount = indexCount
	End
	
'Private


	
	Field _rootNode:Node
	Field _rootNodeVisible := True
	Field _scroller:ScrollView
	
	Field _selectedLine:Int = -1

	Field _selectedIndex:Int = -1
	Field _indexCount:Int = 0
	
	field _removeNode:Node

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
			Local x := (_nodeSize - icon.Width) / 2
			Local y := (_nodeSize - icon.Height) / 2
			Local drawIcon:Int = node._kind
			
			If _selectedIndex > -1 And _selectedIndex = node._index and node._index > -1 then
				canvas.Color = New Color( 0.1,0.3,0.6, 1 )
				canvas.DrawRect( 0,node._rect.Y,  Width, icon.Height+4 )
			End If
      

			If node._children.Length then
				If node._expanded Then
					icon = _expandedIcon
					If node._kind = NODEKIND_FOLDER then
						drawIcon = drawIcon + 1
					End if
				End if

				canvas.Color = Color.White
				canvas.DrawImage( icon, node._rect.X + x, node._rect.Y + y )
			Endif
			
			canvas.DrawImageIcon( icons, node._rect.X + x + xoffset, node._rect.Y + y - 1,  drawIcon, 80 )

			
			canvas.Color = Style.DefaultColor
'			canvas.DrawText( node._index, node._rect.X+_nodeSize+25, node._rect.Y )
'			canvas.DrawText( node._label, node._rect.X+_nodeSize+50, node._rect.Y )

			canvas.DrawText( node._label, node._rect.X + _nodeSize + 25, node._rect.Y )

'			canvas.DrawText( node._label+"  "+node._line, node._rect.X + _nodeSize + 25, node._rect.Y )
		
		Endif
			
		If node._expanded then

			For Local child := Eachin node._children
				RenderNode( canvas, child )
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

				If node Then
					Local p := event.Location - node._rect.Origin
          
					If p.x < _nodeSize And p.y < _nodeSize then
						node.Expanded = Not node._expanded
						NodeToggled( node, event )
'						print "toggled"
					Else
						NodeClicked( node, event )
						SelectedIndex = node._index
						SelectedLine = node._line
'						print "clicked"
					Endif
          
				Endif
        
			Case EventType.MouseWheel
				Super.OnMouseEvent( event )
				Return

		End
	
	End


	
End

