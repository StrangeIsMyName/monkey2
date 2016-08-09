
Namespace ted2


Class HelpIndexView Extends DockingView

	Field PageClicked:Void( url:String )
	field _index:Int


	Property HelpIndexTree:HelpIndexTree()
		Return _helpIndexTree
	End


	Method New()
		_helpIndexTree = New HelpIndexTree
		_helpIndexTree.NodeClicked = Lambda( tnode:TreeView.Node, event:MouseEvent )
			Local node := Cast<HelpIndexTree.Node>( tnode )
			If Not node Return
			If node.Kind = NODEKIND_INDEX Then return

			PageClicked( node.Page )
		End

		_titleBar =  New TitleBar( "Index", 23 )
		AddView( _titleBar, "top", 40, false )
		AddView( _helpIndexTree, "top" )
		ContentView = null
	End method



	Method OnRender( canvas:Canvas ) Override
	end Method


Private

	field _titleBar:TitleBar
	
	Field _helpIndexTree:HelpIndexTree
	Field _scroller:ScrollView
End




Class HelpIndexTree Extends TreeView

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

		Method New( page:String, parent:TreeView.Node, tree:HelpIndexTree )
			Super.New( page, NODEKIND_INDEX, parent )

			Page = page
			If Page = "Misc" Then
				Index = 99999
			Else
				Index = page.Left(1)[0]*10000
			End if
		End


	
		Method New( obj:JsonObject, parent:TreeView.Node, tree:HelpIndexTree )
			Super.New( "", NODEKIND_PANEL, parent )

			Index = tree._indexCount
			tree._indexCount += 1
			
			Label = obj["text"].ToString()
'			Print Label
			If obj.Contains( "data" )
				Local data := obj["data"].ToObject()
				Local page := data["page"].ToString()
				
				Local indexText:string =  ExtractExt( page )
				indexText =  indexText.Right( indexText.Length - 1 )
				Local indexCount:int =  indexText.ToLower().Left(1)[0] - 96
				If indexCount < 0 Then indexCount =  0
'				Print "page= " + indexCount+" "+indexText + "   " + Kind + "   " + page
				
				tree._index.Add( page )
				Page = page
			Endif

		End



	End


	
	Method New() 'beginning of the tree
		RootNodeVisible = False
		RootNode.Expanded = True

		_modules = RootNode
		
		_indexCount = 1
		_indexMisc = New Node( "Misc", _modules, Self )
		_indexCount += 1
		_indexA = New Node( "A", _modules, Self )
		_indexCount += 1
		_indexB = New Node( "B", _modules, Self )
		_indexCount += 1
		_indexC = New Node( "C", _modules, Self )
		_indexCount += 1
		_indexD = New Node( "D", _modules, Self )
		_indexCount += 1
		_indexE = New Node( "E", _modules, Self )
		_indexCount += 1
		_indexF = New Node( "F", _modules, Self )
		_indexCount += 1
		_indexG = New Node( "G", _modules, Self )
		_indexCount += 1
		_indexH = New Node( "H", _modules, Self )
		_indexCount += 1
		_indexI = New Node( "I", _modules, Self )
		_indexCount += 1
		_indexJ = New Node( "J", _modules, Self )
		_indexCount += 1
		_indexK = New Node( "K", _modules, Self )
		_indexCount += 1
		_indexL = New Node( "L", _modules, Self )
		_indexCount += 1
		_indexM = New Node( "M", _modules, Self )
		_indexCount += 1
		_indexN = New Node( "N", _modules, Self )
		_indexCount += 1
		_indexO = New Node( "O", _modules, Self )
		_indexCount += 1
		_indexP = New Node( "P", _modules, Self )
		_indexCount += 1
		_indexQ = New Node( "Q", _modules, Self )
		_indexCount += 1
		_indexR = New Node( "R", _modules, Self )
		_indexCount += 1
		_indexS = New Node( "S", _modules, Self )
		_indexCount += 1
		_indexT = New Node( "T", _modules, Self )
		_indexCount += 1
		_indexU = New Node( "U", _modules, Self )
		_indexCount += 1
		_indexV = New Node( "V", _modules, Self )
		_indexCount += 1
		_indexW = New Node( "W", _modules, Self )
		_indexCount += 1
		_indexX = New Node( "X", _modules, Self )
		_indexCount += 1
		_indexY = New Node( "Y", _modules, Self )
		_indexCount += 1
		_indexZ = New Node( "Z", _modules, Self )
		_indexCount += 1
		
		For Local modname := Eachin EnumModules()
			Local index := "modules/"+modname+"/docs/__PAGES__/index.js"

			Local obj := JsonObject.Load( index )
			If Not obj
				Print "Error! file="+index
				Continue
			Endif
			
			Process( obj,  _modules,  Self )
			_indexCount += 1
		Next
		
		Sort( _indexMisc )
		Sort( _indexA )
		Sort( _indexB )
		Sort( _indexC )
		Sort( _indexD )
		Sort( _indexE )
		Sort( _indexF )
		Sort( _indexG )
		Sort( _indexH )
		Sort( _indexI )
		Sort( _indexJ )
		Sort( _indexK )
		Sort( _indexL )
		Sort( _indexM )
		Sort( _indexN )
		Sort( _indexO )
		Sort( _indexP )
		Sort( _indexQ )
		Sort( _indexR )
		Sort( _indexS )
		Sort( _indexT )
		Sort( _indexU )
		Sort( _indexV )
		Sort( _indexW )
		Sort( _indexX )
		Sort( _indexY )
		Sort( _indexZ )
	End



	method Sort( node:TreeView.Node )
		If Not node Then Return
		If Not node._children Then Return
		
		Local childA:TreeView.Node
		Local childB:TreeView.Node
		
		For childA = Eachin node._children
			For childB = Eachin node._children
				If childA.Label.ToLower() < childB.Label.ToLower() Then
					Local tmp:string = childA.Label
					Local pge:string = childA.Page
					childA.Label = childB.Label
					childB.Label = tmp
					childA.Page = childB.Page
					childB.Page = pge
				End If
			Next
		Next
		
	End method



	Method Process( obj:JsonObject, parent:TreeView.Node, tree:HelpIndexTree )
'		Print "process " + obj["text"].ToString()

		Local Kind:int = 0

		If obj.Contains( "data" )
			Local data := obj["data"].ToObject()
			Local page := data["page"].ToString()
			
			Local indexText:string =  ExtractExt( page )
			indexText =  indexText.Right( indexText.Length - 1 )
			Local indexCount:int =  indexText.ToLower().Left(1)[0] - 96
			If indexCount < 0 Then indexCount =  0
			
			Select indexCount
				Case 1
					New Node( obj, _indexA, Self )
				Case 2
					New Node( obj, _indexB, Self )
				Case 3
					New Node( obj, _indexC, Self )
				Case 4
					New Node( obj, _indexD, Self )
				Case 5
					New Node( obj, _indexE, Self )
				Case 6
					New Node( obj, _indexF, Self )
				Case 7
					New Node( obj, _indexG, Self )
				Case 8
					New Node( obj, _indexH, Self )
				Case 9
					New Node( obj, _indexI, Self )
				Case 10
					New Node( obj, _indexJ, Self )
				Case 11
					New Node( obj, _indexK, Self )
				Case 12
					New Node( obj, _indexL, Self )
				Case 13
					New Node( obj, _indexM, Self )
				Case 14
					New Node( obj, _indexN, Self )
				Case 15
					New Node( obj, _indexO, Self )
				Case 16
					New Node( obj, _indexP, Self )
				Case 17
					New Node( obj, _indexQ, Self )
				Case 18
					New Node( obj, _indexR, Self )
				Case 19
					New Node( obj, _indexS, Self )
				Case 20
					New Node( obj, _indexT, Self )
				Case 21
					New Node( obj, _indexU, Self )
				Case 22
					New Node( obj, _indexV, Self )
				Case 23
					New Node( obj, _indexW, Self )
				Case 24
					New Node( obj, _indexX, Self )
				Case 25
					New Node( obj, _indexY, Self )
				Case 26
					New Node( obj, _indexZ, Self )
				Default
					New Node( obj, _indexMisc, Self )
			End Select
			
'			tree._index.Add( page )
'			_page = page
		Endif

		If obj.Contains( "children" )
			Local count:Int = 0
			For Local child := Eachin obj["children"].ToArray()
				Process( Cast<JsonObject>( child ), _modules, tree )
'					New Node( Cast<JsonObject>( child ), Self, tree )
				count = count + 1
			Next
         
'			If count = 0 Then
'				Kind = parent.Kind
'			End If
		Endif

	End
	
'	Property Modules:TreeView.Node()
'		Return _modules
'	End


	
	Property Index:StringStack()
		Return _index
	End


	
Private

	Field _modules:TreeView.Node
	
	Field _indexMisc:TreeView.Node
	Field _indexA:HelpIndexTree.Node
	Field _indexB:HelpIndexTree.Node
	Field _indexC:HelpIndexTree.Node
	Field _indexD:HelpIndexTree.Node
	Field _indexE:HelpIndexTree.Node
	Field _indexF:HelpIndexTree.Node
	Field _indexG:HelpIndexTree.Node
	Field _indexH:HelpIndexTree.Node
	Field _indexI:HelpIndexTree.Node
	Field _indexJ:HelpIndexTree.Node
	Field _indexK:HelpIndexTree.Node
	Field _indexL:HelpIndexTree.Node
	Field _indexM:HelpIndexTree.Node
	Field _indexN:HelpIndexTree.Node
	Field _indexO:HelpIndexTree.Node
	Field _indexP:HelpIndexTree.Node
	Field _indexQ:HelpIndexTree.Node
	Field _indexR:HelpIndexTree.Node
	Field _indexS:HelpIndexTree.Node
	Field _indexT:HelpIndexTree.Node
	Field _indexU:HelpIndexTree.Node
	Field _indexV:HelpIndexTree.Node
	Field _indexW:HelpIndexTree.Node
	Field _indexX:HelpIndexTree.Node
	Field _indexY:HelpIndexTree.Node
	Field _indexZ:HelpIndexTree.Node
	
	Field _index := New StringStack
	
End
