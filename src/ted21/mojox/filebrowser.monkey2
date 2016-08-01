
Namespace mojox



Class FileBrowser Extends TreeView

	Field FileClicked:Void( path:String, event:MouseEvent )



	Method New( rootPath:String="." )
		Style=Style.GetStyle( "mojo.FileBrowser" )
	
		_rootNode = New Node( Null )
		
		RootPath = rootPath

		NodeClicked = OnNodeClicked
		NodeToggled = OnNodeToggled
		
		RootNode = _rootNode
		
		Update()
	End


	
	Property RootPath:String()
		Return _rootPath
	Setter( path:String )
		_rootPath=path
		
		_rootNode._path = path
		_rootNode.Label = _rootPath
	End


	
	Method Update()
		UpdateNode( _rootNode, _rootPath, True )
	End



	Private


	
	Class Node Extends TreeView.Node
		Method New( parent:Node )
      Super.New( "", NODEKIND_PROJECT, parent, -1 )
		End
		
		Private


		
		Field _path:String
	End


	
	Field _rootNode:Node
	Field _rootPath:String
	
'	Field _count:Int = 0


	
	Method OnNodeClicked( tnode:TreeView.Node, event:MouseEvent )
		Local node := Cast<Node>( tnode )
		If Not node Then Return
		
		FileClicked( node._path, event )
	End


	
	Method OnNodeToggled( tnode:TreeView.Node, event:MouseEvent )
		Local node := Cast<Node>( tnode )
		If Not node Then Return
	
    IndexCount = 0
    
		If node.Expanded
			UpdateNode( node, node._path, True )
		Else
			For Local child := Eachin node.Children
				child.RemoveAllChildren()
			Next
		Endif
	
		Update()
	End



	Method UpdateNode( node:Node, path:String, recurse:Bool )
		Local dir := filesystem.LoadDir( path )
		
		Local dirs := New Stack<String>
		Local files := New Stack<String>
		
		For Local f := Eachin dir
			Local fpath := path+"/"+f
			Select GetFileType( fpath )
			Case FileType.Directory
				dirs.Push( f )
			Default
				files.Push( f )
			End
		Next
		
		dirs.Sort()
		files.Sort()
		
		Local i := 0
		Local children := node.Children
		
		While i < dir.Length
		
			Local f := ""
			If i < dirs.Length Then
        f = dirs[i]
      Else
        f = files[i-dirs.Length]
      End if  
			
			Local child:Node
			
			If i<children.Length then
				child = Cast<Node>( children[i] )
			Else
				child = New Node( node )
			Endif
			
			Local fpath := path+"/"+f
      Local ext := ExtractExt(fpath).ToLower()
			
			child.Label = f
			child._path = fpath
			
			If i < dirs.Length then
				If child.Expanded Or recurse then
					UpdateNode( child, fpath, child.Expanded )

          If ext = ".app" Then
            child.Kind = NODEKIND_APP
          else
            child.Kind = NODEKIND_FOLDER
          End if

          child.Index = IndexCount
          IndexCount += 1
				Endif
			Else
        child.Kind = NODEKIND_FILE
        
        'print count+" "+fpath
        child.Index = IndexCount
        IndexCount += 1
        
        Select ext
          Case ".txt", ".md"
            child.Kind = NODEKIND_TEXT
          Case ".cpp", "cxx", ".c"
            child.Kind = NODEKIND_CPP
          Case ".h", ".hpp", ".hxx"
            child.Kind = NODEKIND_H
          Case ".m", ".mm"
            child.Kind = NODEKIND_M
          Case ".htm", ".html"
            child.Kind = NODEKIND_HTML
          Case ".bat", ".sh"
            child.Kind = NODEKIND_SCRIPT
          Case ".js"
            child.Kind = NODEKIND_JAVASCRIPT
          Case ".css", ".json", ".xml"
            child.Kind = NODEKIND_WEBSCRIPT
          Case ".ttf"
            child.Kind = NODEKIND_FONT
          Case ".app", ".exe"
            child.Kind = NODEKIND_APP
          Case ".wav", ".wave"
            child.Kind = NODEKIND_AUDIO
          Case ".png", ".jpg", "bmp"
            child.Kind = NODEKIND_IMAGE
          Case ".monkey2", ".mx2"
            child.Kind = NODEKIND_MONKEY2
        End select
 '       print "file "+f
				child.RemoveAllChildren()
			Endif
			
			i += 1
		Wend
		
		node.RemoveChildren( i )
	End


	
End
