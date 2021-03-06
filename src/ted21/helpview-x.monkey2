
Namespace ted2

'#Import "assets/find.png@/ted21"
'#Import "assets/debug_icons.png@/ted21"



Function EnumModules:String[]()
	Local mods:=New StringStack

	local path:="modules/"
	for local file:=eachin LoadDir(path)
		if GetFileType(path+file)=FileType.Directory
			If GetFileType(path+file+"/docs/__PAGES__")=FileType.Directory
				mods.Push(file)
			endif
		endif
	next
	
'	For Local line:=Eachin stringio.LoadString( "modules/modules.txt" ).Split( "~n" )
'	
'		Local i:=line.Find( "'" )
'		If i<>-1 line=line.Slice( 0,i )
'		
'		line=line.Trim()
'		If line mods.Push( line )
'		
'	Next
	
	Return mods.ToArray()
End






Class HelpView Extends DockingView

	Field PageClicked:Void( url:String )
	field _index:Int



	Method New()
		_findField = New TextField
		_findField.TabHit = Lambda()
			If _findField.Document.Text <> _matchText Or Not _matches.Length Then Return
			
			_matchId = (_matchId + 1) Mod _matches.Length
			Go( _matches[_matchId] )
		End
		
'		_findField.Document.TextChanged = Lambda()
'			UpdateMatches( _findField.Text )
'			If _matches.Length Go( _matches[0] )
'		End


		_actionFind = New Action( "Search" )
		_actionFind.Triggered = Lambda()
			print "Search"+_findField.Text
			UpdateMatches( _findField.Text )
			If _matches.Length Go( _matches[0] )
		End
		_findButton = New Buttonx( _actionFind, "", 40, 40)
		_findButton.ImageButton = 3'NODEKIND_FIND
		
		
		Local findBar := New DockingView
		findBar.AddView( New Label( "Search" ), "left" )
		findBar.AddView( _findButton, "right" )
		findBar.ContentView = _findField

		
		_helpTree = New HelpTree
		_helpTree.NodeClicked = Lambda( tnode:TreeView.Node, event:MouseEvent )
			Local node := Cast<HelpTree.Node>( tnode )
			If Not node Return
			
'			Go( node.Page )
		End

		
		_htmlView = New HtmlView
		_htmlView.AnchorClicked = Lambda( url:String )
		
			'dodgy work around for mx2 docs!
			If url.StartsWith( "javascript:void('" ) And url.EndsWith( "')" )
				Local page := url.Slice( url.Find( "'" )+1,url.FindLast( "'" ) )
				Go( page )
				Return
			Endif

			_htmlView.Go( url )
		End
		
		AddView( findBar, "top", 40, false )
		
		AddView( _helpTree, "top", 128 )
		ContentView = New ScrollView( _htmlView )
	End



	Method OnRender( canvas:Canvas ) Override
	end Method
  

	
	Method Find(findText:String)
		if _findField.Text=findText
			_index+=1
		else
			_findField.Text=findText
			_index=0
			UpdateMatches( _findField.Text )
		endif
		If _matches.Length 
			_index=_index mod _matches.Length
			Go( _matches[_index] )
		endif
	End method



	Property HelpTree:HelpTree()
		Return _helpTree
	End


	
	Property HtmlView:HtmlView()
		Return _htmlView
	End


	
	Method Go( page:String )
		Local url:="modules/"+page.Replace( ":","/docs/__PAGES__/" ).Replace( ".","-" )+".html"
		_htmlView.Go( RealPath( url ) )
	End


	
	Method UpdateMatches( text:String )
		_matchId=0
		_matchText=text
		_matches.Clear()

		For Local page:=Eachin _helpTree.Index
			If page.Contains( text ) _matches.Push( page )
		Next

		_matches.Sort()
		
		_helpTree.Matches.RemoveAllChildren()
		For Local page := Eachin _matches
			New HelpTree.Node( page, _helpTree.Matches, _helpTree )
		Next
	End


	
Private

	Field _findField:TextField
	Field _helpTree:HelpTree
	Field _htmlView:HtmlView
	Field _scroller:ScrollView

	Field _findButton:Buttonx
	Field _actionFind:Action

	
	Field _matchId:Int
	Field _matchText:String
	Field _matches:=New StringStack
End






Class HelpTree Extends TreeView

  Field _indexCount:int



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
				
				Default
					Kind = parent.Kind
			End Select

			If obj.Contains( "data" )
				Local data := obj["data"].ToObject()
				Local page := data["page"].ToString()
				tree._index.Add( page )
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


		
'		Property Page:String()
'			Return _page
'		End


		
	Private
		


'		Field _page:String
	End


	
	Method New() 'beginning of the tree
		RootNodeVisible = False
		RootNode.Expanded = True
		
		_matches = New TreeView.Node( "Matches", NODEKIND_SEARCH, RootNode, 0 )
		_modules = New TreeView.Node( "Modules", NODEKIND_MODULE, RootNode, 1 )
		
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


	
	Property Modules:TreeView.Node()
		Return _modules
	End


	
	Property Index:StringStack()
		Return _index
	End


	
Private


	
	Field _matches:TreeView.Node
	Field _modules:TreeView.Node
	
	Field _index := New StringStack
	
End
