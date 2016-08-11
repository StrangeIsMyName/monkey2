
Namespace ted2


Class HelpView Extends DockingView

	Field PageClicked:Void( url:String )
	field _index:Int



	Property HelpTree:HelpTree()
		Return _helpTree
	End


'	Property HtmlView:HtmlView()
'		Return _htmlView
'	End



	Method New()
		_findField = New TextField
'		_findField.TabHit = Lambda()
'			If _findField.Document.Text <> _matchText Or Not _matches.Length Then Return
'			
'			_matchId = (_matchId + 1) Mod _matches.Length
'			Go( _matches[_matchId] )
'		End
		_findField.Document.TextChanged = Lambda()
			'Print _findField.Text
			UpdateMatches( _findField.Text )
		End


		_findButton = New Buttonx( "", 30, 40)
		_findButton.Enabled =  false
		
		
		Local findBar := New DockingView
		findBar.AddView( New Label( " " ), "left" )
		findBar.AddView( _findButton, "right" )
		findBar.ContentView = _findField

		
		_helpTree = New HelpTree
		_helpTree.NodeClicked = Lambda( tnode:TreeView.Node, event:MouseEvent )
			Local node := Cast<HelpTree.Node>( tnode )
			If Not node Return
			
			PageClicked( node.Page )
'			Go( node.Page )
		End

		
'		_htmlView = New HtmlView
'		_htmlView.AnchorClicked = Lambda( url:String )
'			'dodgy work around for mx2 docs!
'			If url.StartsWith( "javascript:void('" ) And url.EndsWith( "')" )
'				Local page := url.Slice( url.Find( "'" )+1,url.FindLast( "'" ) )
'				Go( page )
'				Return
'			Endif
'
'			_htmlView.Go( url )
'		End
		
		_titleBar =  New TitleBar( "Search", 3 )
		AddView( _titleBar, "top", 40, false )
		AddView( findBar, "top", 40, false )
'		AddView( _helpTree, "top", 128 )
'		ContentView = New ScrollView( _htmlView )
		ContentView =  _helpTree
	End



	Method OnRender( canvas:Canvas ) Override
		canvas.Color = Style.BackgroundColor
		canvas.DrawRect( 0, 0, Width, Height )
		canvas.Color = New Color( 1, 1, 1, 0.1 )
		canvas.DrawRect( 0, 0, Width, Height )
	end Method
  

	
	Method Find(findText:String)
		'_index = 0
		if _findField.Text = findText
'			Print "exists"
			_index += 1
		Else
'			Print "looking for"
			_findField.Text = findText
'			_index = 0
			UpdateMatches( _findField.Text )
		Endif

		If _matches.Length then
			PageClicked( _matches[_index] )
		End If

'		If _matches.Length 
'			_index = _index mod _matches.Length
'			Print "FJJFJFF"
''			PageClicked()
''			Go( _matches[_index] )
'		endif
	End method



	
	Method UpdateMatches( text:String )
		_matchId = 0
		_matchText = text
		_matches.Clear()
		_helpTree.Matches.RemoveAllChildren()

		If _matchText.Length < 2 Then
			New HelpTree.Node( "No Results", _helpTree.Matches, _helpTree )
			Return
		End If

		Local index:int =  0
		Local added:int =  0
		text = text.ToLower()
		Local label:string
		
		For Local page := Eachin _helpTree.Labels
			page = page.ToLower()
			If page.Right( text.Length ) = text Then
				label = _helpTree.Labels[ index ] + " ( "+ExtractExt( StripExt( _helpTree.Index[ index ] ) ) +" )"
				
				local tmp := New HelpTree.Node( label, _helpTree.Matches, _helpTree )
				'Print _helpTree.Index[ index ].StripExt()
				tmp.Page = _helpTree.Index[ index ]
				tmp.Index = added
				tmp.Kind = NODEKIND_SEARCHGOOD
				added += 1
			End If
			index += 1
		Next

		index =  0
		Local txt:string =  "."+text+"."
		For Local page := Eachin _helpTree.Index
			page = page.ToLower()
			If page.Contains( txt ) Then
				_matches.Push( page )

				label = _helpTree.Labels[ index ]' + " ( "+ExtractExt( StripExt( _helpTree.Index[ index ] ) ) +" )"

				local tmp := New HelpTree.Node( label, _helpTree.Matches, _helpTree )
				tmp.Page = page
				tmp.Index = added
				tmp.Kind = NODEKIND_SEARCHOK
				added += 1
			End If
			index += 1
		Next

		index =  0
		For Local page := Eachin _helpTree.Index
			page = page.ToLower()
			If page.Contains( text ) Then
				Local ok:int =  True
				For Local check := Eachin _matches
					If check = page Then ok = False
				Next
				
				If ok Then
					_matches.Push( page )
					local tmp := New HelpTree.Node( _helpTree.Labels[ index ], _helpTree.Matches, _helpTree )
					tmp.Page = page
					tmp.Index = added
					tmp.Kind = NODEKIND_SEARCHBAD
					added += 1
				End if
			End If
			index += 1
		Next



		If added = 0 Then
			New HelpTree.Node( "No Results", _helpTree.Matches, _helpTree )
		End If

'		_matches.Sort()

'		_helpTree.Matches.RemoveAllChildren()
'		For Local page := Eachin _matches
'			New HelpTree.Node( page, _helpTree.Matches, _helpTree )
'		Next
	End



Private

	field _titleBar:TitleBar

	Field _findField:TextField
	Field _helpTree:HelpTree
'	Field _htmlView:HtmlView
'	Field _scroller:ScrollView

	Field _findButton:Buttonx

	
	Field _matchId:Int
	Field _matchText:String
	Field _matches := New StringStack
End






Class HelpTree Extends TreeView

	Field _indexCount:int


	Function EnumModules:String[]()
		Local mods := New StringStack
	
		local path := "modules/"
		for local file := eachin LoadDir( path )
			if GetFileType( path + file ) = FileType.Directory
				If GetFileType( path + file + "/docs/__PAGES__") = FileType.Directory
					mods.Push( file )
				endif
			endif
		next
		
		Return mods.ToArray()
	End



	Class Node Extends TreeView.Node
    'looks like this is never called ?
		Method New( page:String, parent:TreeView.Node, tree:HelpTree )
			Super.New( page, NODEKIND_NONE, parent )

			Page = page
		End



		Method New( obj:JsonObject, parent:TreeView.Node, tree:HelpTree )
			Super.New( "", NODEKIND_NONE, parent )

			Index = tree._indexCount
			tree._indexCount += 1


			Label = obj["text"].ToString()
			Select Label
				Case "Modules"
					Kind = NODEKIND_MODULE
				Case "Enums"
					Kind = NODEKIND_ENUM
				Case "Classes"
					Kind = NODEKIND_CLASS
				Case "Globals"
					Kind = NODEKIND_GLOBAL
				Case "Constants"
					Kind = NODEKIND_CONST
				Case "Constructors", "Contructors"
					Kind = NODEKIND_CONSTRUCTOR
				Case "Methods"
					Kind = NODEKIND_METHOD
				Case "Functions"
					Kind = NODEKIND_FUNCTION
				Case "Structs"
					Kind = NODEKIND_STRUCT
				Case "Properties"
					Kind = NODEKIND_PROPERTY
				Case "Events"
					Kind = NODEKIND_EVENT
				Case "Fields"
					Kind = NODEKIND_FIELD
				
'				Default
'					Kind = parent.Kind
			End Select

			If obj.Contains( "data" )
				Local data := obj["data"].ToObject()
				Local page := data["page"].ToString()
				tree._index.Add( page )
				tree._labels.Add( Label )
				Page = page
			Endif
			
			If obj.Contains( "children" )
				Local count:Int = 0
				For Local child := Eachin obj["children"].ToArray()
					New Node( Cast<JsonObject>( child ), Self, tree )
					count = count + 1
				Next

				If count = 0 Then
					Kind = parent.Kind
				End if
'        print Label+" "+count
			Endif

		End


	Private


'		Field _page:String
	End


	
	Method New() 'beginning of the tree
		RootNodeVisible = False
		RootNode.Expanded = True
		
		_matches = RootNode
		
		_indexCount = 2
		
		For Local modname := Eachin EnumModules()
			Local index := "modules/"+modname+"/docs/__PAGES__/index.js"

			Local obj := JsonObject.Load( index )
			If Not obj
				Print "Error! file="+index
				Continue
			Endif
			
			New Node( obj, _modules, Self )
			_indexCount += 1
		Next

	End



	Property Matches:TreeView.Node()
		Return _matches
	End


	Property Index:StringStack()
		Return _index
	End

	Property Labels:StringStack()
		Return _labels
	End

Private

	Field _matches:TreeView.Node
	Field _modules:TreeView.Node
	
	Field _index := New StringStack
	Field _labels := New StringStack
	
End
