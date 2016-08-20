
Namespace nogox


Class CodeTreeView Extends View

	Field NodeClicked:Void( event:MouseEvent )

#-



	
	Method New()
		Layout = "fill"
		Style = Style.GetStyle( "mojo.TreeView" )
	End
	

	Method AddInitialNode( label:String, kind:Int, line:Int, indent:int )
		local hidden:bool = true
		select kind
			case NODEKIND_METHOD
				hidden = _nkMethod
			case NODEKIND_FUNCTION
				hidden = _nkFunction
			case NODEKIND_FIELD
				hidden = _nkField
			case NODEKIND_PROPERTY
				hidden = _nkProperty
			case NODEKIND_LAMBDA
				hidden = _nkLambda
		end select
		
		_nodeLabel[ _indexCount ] = label
		_nodeKind[ _indexCount ] = kind
		_nodeLine[ _indexCount ] = line
		_nodeIndent[ _indexCount ] = indent
		_nodeHidden[ _indexCount ] = false

		_indexCount += 1
	end method



	Method AddNode( label:String, kind:Int, line:Int, indent:int )
		local hidden:bool = true
		select kind
			case NODEKIND_METHOD
				hidden = _nkMethod
			case NODEKIND_FUNCTION
				hidden = _nkFunction
			case NODEKIND_FIELD
				hidden = _nkField
			case NODEKIND_PROPERTY
				hidden = _nkProperty
			case NODEKIND_LAMBDA
				hidden = _nkLambda
		end select

		_nodeLabel[ _indexCount ] = label
		_nodeKind[ _indexCount ] = kind
		_nodeLine[ _indexCount ] = line
		_nodeIndent[ _indexCount ] = indent
		_nodeHidden[ _indexCount ] = false

		_indexCount += 1
	end method

	
	method ModifyKind( kind:int, show:bool )
		select kind
			case NODEKIND_METHOD
				_nkMethod = show
			case NODEKIND_FUNCTION
				_nkFunction = show
			case NODEKIND_FIELD
				_nkField = show
			case NODEKIND_PROPERTY
				_nkProperty = show
			case NODEKIND_LAMBDA
				_nkLambda = show
		end Select
			
		if show Then
			UnhideKind( kind )
		Else
			HideKind( kind )
		end If
	end Method
	
	
			
	method HideKind( kind:int )
		Local idx:int = 0
		
		While idx <= _indexCount
			if _nodeKind[ idx ] = kind then _nodeHidden[ idx ] = True
			idx += 1
		Wend	
	end method



	method UnhideKind( kind:int )
		Local idx:int = 0
		
		While idx <= _indexCount
			if _nodeKind[ idx ] = kind then _nodeHidden[ idx ] = false
			idx += 1
		Wend	
	end method



	Property Container:View() Override
		If Not _scroller
			_scroller = New ScrollView( Self )
		Endif
		Return _scroller
	End



	Property SelectedLabel:String()
		Return _selectedLabel
	Setter( selectedLabel:String )
		_selectedLabel = selectedLabel
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

	Field _nodeLabel := New String[500]
	Field _nodeKind := new byte[500]
	Field _nodeLine := new int[500]
	Field _nodeIndent := new byte[500]
	Field _nodeHidden := new bool[500]
	Field _nodeRef := new int[500]
	Field _nodesShown:int = 0
	Field _listHeight:int = 0
	
	Field _scroller:ScrollView
	
	Field _selectedLine:Int = -1
	Field _selectedIndex:Int = -1
	Field _selectedLabel:String = ""
	
	Field _indexCount:Int = 0
	
	Field _expandedIcon:Image
	Field _collapsedIcon:Image
	Field _icons:Image
	Field _nodeSize:Int

	field _nkMethod:bool
	field _nkFunction:bool
	field _nkField:bool
	field _nkProperty:bool
	field _nkLambda:bool



	Method OnValidateStyle() Override
		_collapsedIcon = Style.GetImage( "node:collapsed" )
		_icons = Style.GetImage( "node:icons" )
		
		_nodeSize = Style.DefaultFont.Height
		_nodeSize = Max( _nodeSize, Int( _collapsedIcon.Height ) )
	End


	
	Method OnMeasure:Vec2i() Override
		local ns:float = _nodeSize*1.009
		Return New Vec2i( Width-20, _nodesShown * ns )
	End


	method RemoveAll()
		_indexCount = 0
	end method



	method RemoveAllFromLine( line:int )
'		print "  REMOVE ALL FROM line="+line

		local found:int = -1
		Local idx:int = 0
		Local count:int = _indexCount
		
		While idx <= count and found = -1
			if _nodeLine[ idx ] >= line Then
				found = idx
			end if
			idx += 1
		Wend
		
		if found = -1 then
'			print "Line Not Found"
			Return
		end If
		
'		print "index="+found
		
		_indexCount = found
		if _indexCount < 0 then _indexCount = 0
	end


	
	Method DrawNode( canvas:Canvas, index:int,  ypos:int )
		Local nodeSize:int = _nodeSize
		Local icons := _icons
		Local xoffset:Int = 7
		Local icon := _collapsedIcon
		Local x := (_nodeSize - icon.Width) / 2
		Local y := (_nodeSize - icon.Height) / 2
		Local drawIcon:Int = _nodeKind[ index ]
			
		If _selectedIndex > -1 And _selectedIndex = index and index > -1 then
			canvas.Color = New Color( 0.1,0.3,0.6, 1 )
			canvas.DrawRect( 0,ypos,  Width, icon.Height+4 )
		End If

		local txt:string = ""
		select _nodeKind[ index ]
			case NODEKIND_CONST txt = "Const"
			case NODEKIND_GLOBAL txt = "Global"
			case NODEKIND_CLASS txt = "Class"
			case NODEKIND_METHOD txt = "Method"
			case NODEKIND_PROPERTY txt = "Property"
			case NODEKIND_FIELD txt = "Field"
			case NODEKIND_FUNCTION txt = "Function"
			case NODEKIND_STRUCT txt = "Struct"
			case NODEKIND_LAMBDA txt = "Lambda"
		end select

		local xt:int = _nodeSize + 35 + RenderStyle.DefaultFont.TextWidth( _nodeLabel[ index ] )
		canvas.Color = Color.DarkGrey
		if Width-60 > xt then
			canvas.DrawText( txt, Width-60, ypos )
		Else
			canvas.DrawText( txt, xt, ypos )
		end if

		canvas.Color = Color.White
		xt = _nodeIndent[ index ] * nodeSize
		canvas.DrawImageIcon( icons, x + xoffset + xt, ypos + y - 1,  drawIcon, 80 )

		canvas.DrawText( _nodeLabel[index], x + xoffset + xt + (nodeSize * 1.5), ypos )
	End method
	
	
	
	Method OnRender( canvas:Canvas ) Override
		Local idx:int = 0
		Local ypos:int = 0
		Local count:int = _indexCount
		_nodesShown = 0
		
		'we need two so the layout is updated correctly - this counts how many will be totally shown
		While idx <= count
			if not _nodeHidden[ idx ] Then
				_nodesShown += 1
				_nodeRef[ _nodesShown ] = idx
			End If
			idx += 1
		Wend
		
		'this does the actual drawing
		'Print ClipRect.Top+" "+ClipRect.Bottom
'		Print "index= "+_selectedIndex
		idx = 0
		While ypos < ClipRect.Bottom and idx <= count
			if not _nodeHidden[ idx ] Then
				if ypos >= ClipRect.Top then DrawNode( canvas, idx,  ypos )
				ypos += _nodeSize
			End If
			idx += 1
		Wend

'		canvas.DrawText( _indexCount, 0, 0 )
'		canvas.DrawText( _nodesShown, 0, _nodeSize )

		UpdateLayout()
	End


	
	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
			Case EventType.MouseDown
				SelectedIndex = -1
				Local ref:int = event.Location.Y / _nodeSize
				local pos:int = _nodeRef[ ref+1 ]
				
				SelectedIndex = pos
				SelectedLine = _nodeLine[ pos ]
				SelectedLabel = _nodeLabel[ pos ]
				_selectedIndex = pos
				Print "locationy:"+event.Location.Y+" nodesize:"+_nodeSize+" ref:"+ref+" pos:"+pos+" selectedindex:"+SelectedIndex+" label:"+SelectedLabel

				NodeClicked( event )
        
			Case EventType.MouseWheel
				Super.OnMouseEvent( event )
				Return

		End
	
	End


	
End

