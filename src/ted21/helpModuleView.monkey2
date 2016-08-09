
Namespace ted2


Class HelpModuleView Extends DockingView

	Field PageClicked:Void( url:String )
	field _index:Int


	Property HelpModuleTree:HelpModuleTree()
		Return _helpModuleTree
	End


	Method New()
		_helpModuleTree = New HelpModuleTree
		_helpModuleTree.NodeClicked = Lambda( tnode:TreeView.Node, event:MouseEvent )
			Local node := Cast<HelpModuleTree.Node>( tnode )
			If Not node Return

			PageClicked( node.Page )
		End

		_titleBar =  New TitleBar( "Modules", 22 )
		AddView( _titleBar, "top", 40, false )
		AddView( _helpModuleTree, "top" )
		ContentView = null
	End



	Method OnRender( canvas:Canvas ) Override
	end Method


Private

	field _titleBar:TitleBar
	
	Field _helpModuleTree:HelpModuleTree
	Field _scroller:ScrollView
End




Class TitleBar Extends View

	Property Text:String()
		Return _text
	Setter( text:String )
		_text = text
	End

	Method New( Text:string )
		Layout = "fill"
		Style = Style.GetStyle( "mojo.TitleBar" )
		_text = Text
	End


	Method New( Text:string, ImageButton:int )
		Layout = "fill"
		Style = Style.GetStyle( "mojo.TitleBar" )
		_text = Text
		_imageButton =  ImageButton
	End


	method OnValidateStyle() Override
		_buttons = Style.GetImage( "node:buttons" )
	end Method


	Method OnRender( canvas:Canvas ) Override
'		canvas.Color = New Color( .25, .25, .25 )

		canvas.Color = Style.DefaultColor
		canvas.DrawRect( 0, 0, Width, Height )
		canvas.Color = New Color( .1, .1, 0, 0.5 )
		canvas.DrawRect( 0, 0, Width, Height )

		canvas.Color = Style.BorderColor
		canvas.DrawTriangle( 0, 0, 10, 20, 0, 40 )
		
		If _imageButton > -1 Then
			canvas.Color = Color.White
			canvas.DrawImageIcon( _buttons, Width-35,5,  _imageButton, 24)
		End if
		
		canvas.Color = Color.LightGrey
		canvas.Scale( 2, 2)
		canvas.DrawText( _text, 10, 2 )
		canvas.DrawText( _text, 11, 2 )
	end Method

private
	field _text:string =  ""

	field _imageButton:int = -1
	Field _buttons:Image
End



Class HelpModuleTree Extends TreeView

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
		Method New( page:String, parent:TreeView.Node, tree:HelpModuleTree )
			Super.New( page, NODEKIND_MODULE, parent )

			Page = page
		End


	
		Method New( obj:JsonObject, parent:TreeView.Node, tree:HelpModuleTree )
			Super.New( "", NODEKIND_MODULE, parent )

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
					Kind = NODEKIND_MODULE
			End Select

			If obj.Contains( "data" )
				Local data := obj["data"].ToObject()
				Local page := data["page"].ToString()
				
				Local indexText:string =  ExtractExt( page )
'				Print "page= "+indexText.Right( indexText.Length - 1 ) + "   " + Kind + "   " + page
				
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

		_modules = RootNode'New TreeView.Node( "Modules", NODEKIND_MODULE, RootNode, 0 )
		
		_indexCount = 1
		
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


	
	Property Modules:TreeView.Node()
		Return _modules
	End


	
	Property Index:StringStack()
		Return _index
	End


	
Private

	Field _modules:TreeView.Node
	
	Field _index := New StringStack
	
End
