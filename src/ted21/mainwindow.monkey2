
Namespace ted2

#Import "assets/about.html@/ted2"
#Import "assets/scripts.json@/ted2"

#Import "assets/newfiles/Simple_Console_App.monkey2@/ted2/newfiles"
#Import "assets/newfiles/Simple_Mojo_App.monkey2@/ted2/newfiles"
#Import "assets/newfiles/Letterboxed_Mojo_App.monkey2@/ted2/newfiles"

Global MainWindow:MainWindowInstance

'NOTE Modules/mojo/input/keycodes.monkey has the following added to Mofifiers:
'	Command=  LeftGui|RightGui



Class MainWindowInstance Extends Window

	Field _debugging:String
	
	'paths
	Field _tmp:String
	Field _mx2cc:String

	'actions
	Field _fileNew:Action
	Field _fileOpen:Action
	Field _fileReOpen:Action 'new
	Field _fileClose:Action
	Field _fileCloseAll:Action
	Field _fileSave:Action
	Field _fileSaveAs:Action
	Field _fileSaveAll:Action
	Field _fileNextFile:Action
	Field _filePrevFile:Action
	Field _fileOpenProject:Action
	Field _fileQuit:Action
	
	Field _editUndo:Action
	Field _editRedo:Action
	Field _editCut:Action
	Field _editCopy:Action
	Field _editPaste:Action
	Field _editSelectAll:Action
	Field _editFind:Action

	Field _editSearch:Action
	Field _quickHelp:Action

	
	Field _buildDebug:Action
	Field _buildRelease:Action
	Field _buildForceStop:Action
	Field _buildLockFile:Action
	Field _buildNextError:Action
	
	Field _helpOnlineHelp:Action
	Field _helpOfflineHelp:Action
	Field _helpAbout:Action
	
	Field _panelColor:Action
	
	Field _findNext:Action
	Field _findPrevious:Action
	Field _findReplace:Action
	Field _findReplaceAll:Action
	Field _findUseBigCursor:Action
	Field _findShowInvisibles:Action
	Field _showInvisibles:bool = true
	Field _showBigCursor:bool = true
	
	Field _escape:Action
	Field _cmdEscape:Action
	Field _showConsole:bool = true
	
	'menus
	Field _menuBar:MenuBar
	
	Field _newFiles:Menu
	Field _recentFiles:Menu
	Field _closeProject:Menu
	Field _scripts:Menu
	
	Field _fileMenu:Menu
	Field _editMenu:Menu
	Field _viewMenu:Menu
	Field _buildMenu:Menu
	Field _scriptMenu:Menu
	Field _panelMenu:Menu
	Field _helpMenu:Menu
	
	Field _recent:=New Stack<String>
	Field _projects:=New Stack<String>

	'dialogs	
	Field _findDialog:FindDialog
	Field _searchDialog:SearchDialog
	
	'browsers
	Field _browser:TabView
	Field _projectView:ProjectView
	Field _codeView:CodeView
	Field _debugView:DebugView
	Field _helpView:HelpView
	
	Field _console:Console
	
	Field _colorView:ColorView

	'documents
	Field _docTabber:TabViewX
	Field _currentDoc:Ted2Document
	Field _currentTextView:TextView
	Field _openDocs := New Stack<Ted2Document>
	Field _lockedDoc:Ted2Document
	
	'main docking view
	Field _docker:DockingView
	
	
	'status bar
	Field _statusbar:StatusBar
	
	
	
	Field _errors := New List<Mx2Error>
	
	
	Const FunctionKeys := New Key[](Key.F1, Key.F2, Key.F3, Key.F4, Key.F5, Key.F6, Key.F7, Key.F8, Key.F9, Key.F10)

	
	Method OnFileNew()
		OpenDocument( "" )
	End


	
	Method OnFileOpen()
		Local path:=RequestFile( "Open file...","",False )
		If Not path Return
	
		OpenDocument( path,True )
		SaveState()
	End


	
	Method OnFileReOpen()
		Local path := _currentDoc.Path
	
		CloseDocument( _currentDoc )
		OpenDocument( path )
	End



	Method OnFileClose()
		If Not _currentDoc Return
		
		If _currentDoc.Dirty
		
			Local buttons:=New String[]( "Save","Discard Changes","Cancel" )
		
			Select TextDialog.Run( "Close","File '"+_currentDoc.Path+"' has been modified.",buttons )
			Case 0
				If Not SaveDocument( _currentDoc ) Return
			Case 2
				Return
			End

		Endif
		
		CloseDocument( _currentDoc )
		
		SaveState()
	End


	
	Method OnFileCloseAll()
		Local close := New Stack<Ted2Document>
	
		For Local doc := Eachin _openDocs
		
			If doc.Dirty
			
				MakeCurrent( doc )

				Local buttons := New String[]( "Save","Discard Changes","Cancel" )
			
				Select TextDialog.Run( "Close All","File '"+doc.Path+"' has been modified.",buttons )
					Case 0
						If Not SaveDocument( doc ) Then Return
					Case 2
						Return
				End
			
			Endif
			
			close.Add( doc )

		Next
		
		For Local doc := Eachin close
			CloseDocument( doc )
		Next
		
		SaveState()
	End


	
	Method OnFileSave()
		If Not _currentDoc Return
			
		SaveDocument( _currentDoc )
	End


	
	Method OnFileSaveAs()
		If Not _currentDoc Return
			
		Local path:=RequestFile( "Save As","",True )
		If Not path Return
		
		RenameDocument( _currentDoc,path )
		SaveDocument( _currentDoc )
	End


	
	Method OnFileSaveAll()
		For Local doc:=Eachin _openDocs
			SaveDocument( doc )
		Next
	End


	
	Method OnFileNextFile()
		If _docTabber.Count<2 Return
		
		Local i:=_docTabber.CurrentIndex+1
		If i=_docTabber.Count i=0
		
		Local doc:=FindDocument( _docTabber.ViewAtIndex( i ) )
		If Not doc Return
		
		MakeCurrent( doc )
	End


	
	Method OnFilePrevFile()
		If _docTabber.Count<2 Return
		
		Local i:=_docTabber.CurrentIndex-1
		If i=-1 i=_docTabber.Count-1
		
		Local doc:=FindDocument( _docTabber.ViewAtIndex( i ) )
		If Not doc Return
		
		MakeCurrent( doc )
	End


	
	Method OnFileOpenProject()
		Local dir:=RequestDir( "Select Project Directory...","" )
		If Not dir Return
		
		If Not _projectView.OpenProject( dir ) Return
		
		_projects.Push( dir )
		UpdateCloseProjectMenu()
	End


	
	Method OnFileQuit()
		For Local doc:=Eachin _openDocs
		
			If doc.Dirty
			
				MakeCurrent( doc )

				Local buttons:=New String[]( "Save","Discard Changes","Cancel" )
			
				Select TextDialog.Run( "Quit","File '"+doc.Path+"' has been modified.",buttons )
				Case 0
					If Not SaveDocument( doc ) Return
				Case 2
					Return
				End
			
			Endif
		
		Next
		
		SaveState()
		
		_console.Terminate()
		
		App.Terminate()
	End


	
	Method OnEditUndo()
		Local textView:=Cast<TextView>( App.KeyView )
		
		If textView textView.Undo()
	End


	
	Method OnEditRedo()
		Local textView:=Cast<TextView>( App.KeyView )
		
		If textView textView.Redo()
	End


	
	Method OnEditCut()
		Local textView:=Cast<TextView>( App.KeyView )
		
		If textView textView.Cut()
	End



	Method OnEditCopy()
		Local textView:=Cast<TextView>( App.KeyView )
		
		If textView textView.Copy()
	End



	Method OnEditPaste()		
		Local textView:=Cast<TextView>( App.KeyView )
		
		If textView textView.Paste()
	End


	
	Method OnEditSelectAll()
		Local textView:=Cast<TextView>( App.KeyView )
		
		If textView textView.SelectAll()
	End


	
	Method OnEditFind()
		_findDialog.Open()
	End


	
	Method OnEditSearch()
		_searchDialog.Open()
	End



	Method OnQuickHelp()
'		local tag := _currentTextView.TagUnderCursor()
'		_browser.CurrentView = _helpView
'		_helpView.Find( tag )
	End


	Method OnBuildDebug()
		Build( "debug" )
	End


	
	Method OnBuildRelease()
		Build( "release" )
	End


	
	Method OnBuildForceStop()
		_console.Terminate()
	End


	
	Method OnBuildLockFile()
		LockDoc( _currentDoc )
		
	End


	
	Method OnBuildNextError()
		While Not _errors.Empty And _errors.First.removed
			_errors.RemoveFirst()
		Wend
		
		If _errors.Empty Return
		
		_errors.AddLast( _errors.RemoveFirst() )
			
		GotoError( _errors.First )
	End


	
	Method OnHelpOnlineHelp()
		App.Idle+=Lambda()
			requesters.OpenUrl( "http://monkey2.monkey-x.com/modules-reference/" )
		End
	End


	
	Method OnHelpOfflineHelp()
		App.Idle+=Lambda()
			requesters.OpenUrl( "file://"+CurrentDir()+"docs/index.html" )
		End
	End


	
	Method OnHelpAbout()
		Local htmlView := New HtmlView
		htmlView.Go( "asset::ted2/about.html" )

		Local dialog := New Dialog( "About Monkey2" )
		dialog.ContentView = htmlView
		
		dialog.MinSize = New Vec2i( 640,600 )
		
		dialog.MaxSize = Rect.Size
		
		dialog.AddAction( "Okay!" ).Triggered = Lambda()
			dialog.Close()
		End
		
		dialog.Open()
	End



	Method OnPanelColor()
		_colorView.Visible = Not _colorView.Visible
	End
  
  
  
	Method OnFindNext()
		If Not _currentTextView Return
		
		Local text:=_findDialog.FindText
		If Not text Return
		
		Local tvtext:=_currentTextView.Text
		Local cursor:=Max( _currentTextView.Anchor,_currentTextView.Cursor )
		
		If Not _findDialog.CaseSensitive
			tvtext=tvtext.ToLower()
			text=text.ToLower()
		Endif
		
		Local i:=tvtext.Find( text,cursor )
		If i=-1
			i=tvtext.Find( text )
			If i=-1 Return
		Endif
		
		_currentTextView.SelectText( i,i+text.Length )
	End


	
	Method OnFindPrevious()
		If Not _currentTextView Return
		
		Local text:=_findDialog.FindText
		If Not text Return

		Local tvtext:=_currentTextView.Text
		Local cursor:=Min( _currentTextView.Anchor,_currentTextView.Cursor )
		
		If Not _findDialog.CaseSensitive
			tvtext=tvtext.ToLower()
			text=text.ToLower()
		Endif
		
		Local i:=tvtext.Find( text )
		If i=-1 Return
		
		If i>=cursor
			i=tvtext.FindLast( text )
		Else
			Repeat
				Local n:=tvtext.Find( text,i+text.Length )
				If n>=cursor Exit
				i=n
			Forever
		End
		
		_currentTextView.SelectText( i,i+text.Length )
	End


	
	Method OnFindReplace()
		If Not _currentTextView Return
		
		Local text:=_findDialog.FindText
		If Not text Return
		
		Local min:=Min( _currentTextView.Anchor,_currentTextView.Cursor )
		Local max:=Max( _currentTextView.Anchor,_currentTextView.Cursor )
		
		Local tvtext:=_currentTextView.Text.Slice( min,max )

		If Not _findDialog.CaseSensitive
			tvtext=tvtext.ToLower()
			text=text.ToLower()
		Endif
		
		If tvtext<>text Return
		
		_currentTextView.ReplaceText( _findDialog.ReplaceText )
		
		OnFindNext()
	End


	
	Method OnFindReplaceAll()
		If Not _currentTextView Return
		
		Local text := _findDialog.FindText
		If Not text Return
		
		Local rtext := _findDialog.ReplaceText
		
		Local tvtext := _currentTextView.Text

		If Not _findDialog.CaseSensitive
			tvtext = tvtext.ToLower()
			text = text.ToLower()
		Endif
		
		Local anchor := _currentTextView.Anchor
		Local cursor := _currentTextView.Cursor
		
		Local i := 0
		Local t := 0
		Repeat
		
			Local i := tvtext.Find( text,i )
			If i=-1 Exit
			
			_currentTextView.SelectText( i+t, i+text.Length+t )
			_currentTextView.ReplaceText( rtext )
			
			t += rtext.Length-text.Length
			i += text.Length
			
		Forever
		
		_currentTextView.SelectText( anchor,cursor )
	End



	method OnFindUseBigCursor()
		_showBigCursor = not _showBigCursor

		If _currentDoc then
			_currentTextView = Cast<TextView>( _currentDoc.View )
      
			If _currentTextView Then
				_currentTextView.BlockCursor = _showBigCursor
			end If
		end If
	end Method
	


	method OnFindShowInvisibles()
		_showInvisibles = not _showInvisibles

		If _currentDoc then
			_currentTextView = Cast<TextView>( _currentDoc.View )
      
			If _currentTextView Then
				_currentTextView.ShowInvisibles = _showInvisibles
			end If
		end If
	end method
	
	
	
	Method OnEscape()
		If _findDialog.Visible then
			_findDialog.Close()
			UpdateKeyView()
			Return
		Endif
	End


	
	Method OnCmdEscape()
		_console.Visible = Not _console.Visible
		_showConsole = Not _showConsole
	End



	Method InitPaths()
		_tmp="tmp/"
		
#If __HOSTOS__="macos"
		_mx2cc="bin/mx2cc_macos"
#Else If __HOSTOS__="windows"
		_mx2cc="bin/mx2cc_windows.exe"
#Else
		_mx2cc="bin/mx2cc_linux"
#Endif
		
		CreateDir( _tmp )
	End
	
	
	
	Method InitActions()
'DebugStop()
		Local _modifier:= Modifier.Control
    
#If __HOSTOS__="macos"
		_modifier = Modifier.Command
#Endif
	
		_fileNew=New Action( "New" )
		_fileNew.HotKey=Key.N
		_fileNew.HotKeyModifiers = _modifier
		_fileNew.Triggered=OnFileNew
		
		_fileOpen=New Action( "Open" )
		_fileOpen.HotKey=Key.O
		_fileOpen.HotKeyModifiers = _modifier
		_fileOpen.Triggered=OnFileOpen

		_fileReOpen=New Action( "ReOpen" )
		_fileReOpen.HotKey=Key.R
		_fileReOpen.HotKeyModifiers = _modifier
		_fileReOpen.Triggered=OnFileReOpen

		_fileClose=New Action( "Close" )
		_fileClose.HotKey=Key.F4
		_fileClose.HotKeyModifiers = _modifier
		_fileClose.Triggered=OnFileClose

		_fileCloseAll=New Action( "Close All" )
		_fileCloseAll.Triggered=OnFileCloseAll
		
		_fileSave=New Action( "Save" )
		_fileSave.HotKey=Key.S
		_fileSave.HotKeyModifiers = _modifier
		_fileSave.Triggered=OnFileSave
		
		_fileSaveAs=New Action( "Save As" )
		_fileSaveAs.Triggered=OnFileSaveAs
		
		_fileSaveAll=New Action( "Save All" )
		_fileSaveAll.Triggered=OnFileSaveAll
		
		_fileNextFile=New Action( "Next File" )
		_fileNextFile.Triggered=OnFileNextFile
		_fileNextFile.HotKey=Key.Tab
		_fileNextFile.HotKeyModifiers = _modifier
		
		_filePrevFile=New Action( "Previous File" )
		_filePrevFile.Triggered=OnFilePrevFile
		_filePrevFile.HotKey=Key.Tab
		_filePrevFile.HotKeyModifiers = _modifier
		
		_fileOpenProject=New Action( "Open project" )
		_fileOpenProject.Triggered=OnFileOpenProject
		
		_fileQuit=New Action( "Quit" )
		_fileQuit.Triggered=OnFileQuit
		
		_editUndo=New Action( "Undo" )
		_editUndo.HotKey=Key.Z
		_editUndo.HotKeyModifiers = _modifier
		_editUndo.Triggered=OnEditUndo
		
		_editRedo=New Action( "Redo" )
		_editRedo.HotKey=Key.Y
		_editRedo.HotKeyModifiers = _modifier
		_editRedo.Triggered=OnEditRedo
		
		_editCut=New Action( "Cut" )
'		_editCut.HotKey=Key.X
'		_editCut.HotKeyModifiers=Modifier.Control
		_editCut.Triggered=OnEditCut
		
		_editCopy=New Action( "Copy" )
'		_editCopy.HotKey=Key.C
'		_editCopy.HotKeyModifiers=Modifier.Control
		_editCopy.Triggered=OnEditCopy
		
		_editPaste=New Action( "Paste" )
'		_editPaste.HotKey=Key.V
'		_editPaste.HotKeyModifiers=Modifier.Control
		_editPaste.Triggered=OnEditPaste
		
		_editSelectAll=New Action( "Select All" )
'		_editSelectAll.HotKey=Key.A
'		_editSelectAll.HotKeyModifiers=Modifier.Control
		_editSelectAll.Triggered=OnEditSelectAll
		
		_editFind=New Action( "Find" )
		_editFind.HotKey=Key.F
		_editFind.HotKeyModifiers = _modifier
		_editFind.Triggered=OnEditFind
		
		_findNext=New Action( "Find Next" )
		_findNext.HotKey=Key.F3
		_findNext.Triggered=OnFindNext
		
		_findPrevious=New Action( "Find Previous" )
		_findPrevious.HotKey=Key.F3
		_findPrevious.HotKeyModifiers=Modifier.Shift
		_findPrevious.Triggered=OnFindPrevious
		
		_findReplace=New Action( "Replace" )
		_findReplace.Triggered=OnFindReplace
		
		_findReplaceAll=New Action( "Replace All" )
		_findReplaceAll.Triggered=OnFindReplaceAll

		_findShowInvisibles=New Action( "Show tabs and Returns" )
		_findShowInvisibles.HotKey=Key.T
		_findShowInvisibles.HotKeyModifiers = _modifier
		_findShowInvisibles.Triggered=OnFindShowInvisibles

		_findUseBigCursor=New Action( "Use Big Cursor" )
		_findUseBigCursor.HotKey=Key.B
		_findUseBigCursor.HotKeyModifiers = _modifier
		_findUseBigCursor.Triggered=OnFindUseBigCursor



		_editSearch=New Action( "Search" )
		_editSearch.HotKey=Key.F
		_editSearch.HotKeyModifiers = _modifier | Modifier.Shift
		_editSearch.Triggered = OnEditSearch

		
		_buildDebug=New Action( "Debug" )
		_buildDebug.HotKey=Key.F5
		_buildDebug.Triggered=OnBuildDebug
		
		_buildRelease=New Action( "Release" )
		_buildRelease.HotKey=Key.F6
		_buildRelease.Triggered=OnBuildRelease
		
		_buildForceStop=New Action( "Force Stop" )
		_buildForceStop.HotKey=Key.Escape
		_buildForceStop.HotKeyModifiers=Modifier.Shift
		_buildForceStop.Triggered=OnBuildForceStop

		_buildLockFile=New Action( "Lock Build File" )
		_buildLockFile.HotKey=Key.L
		_buildLockFile.HotKeyModifiers = _modifier
		_buildLockFile.Triggered=OnBuildLockFile
		
		_buildNextError=New Action( "Next Error" )
		_buildNextError.HotKey=Key.F4
		_buildNextError.Triggered=OnBuildNextError
		
		_quickHelp=New Action( "Quick Help" )
		_quickHelp.HotKey=Key.F1
		_quickHelp.Triggered = OnQuickHelp

		_helpOnlineHelp=New Action( "Online Help" )
		_helpOnlineHelp.Triggered=OnHelpOnlineHelp

		_helpOfflineHelp=New Action( "Offline Help" )
		_helpOfflineHelp.Triggered=OnHelpOfflineHelp
		
		_helpAbout=New Action( "About Monkey2" )
		_helpAbout.Triggered=OnHelpAbout

		_panelColor=New Action( "Color Panel" )
		_panelColor.HotKey=Key.P
		_panelColor.HotKeyModifiers = _modifier
		_panelColor.Triggered=OnPanelColor
		
		_escape = New Action( "" )
		_escape.HotKey = Key.Escape
		_escape.Triggered = OnEscape

		_cmdEscape = New Action( "Console" )
		_cmdEscape.HotKey = Key.Escape
		_cmdEscape.HotKeyModifiers = _modifier
		_cmdEscape.Triggered = OnCmdEscape
	End
	
	
	
	Method InitMenus()
		_newFiles = New Menu( "New" )
		Local p := AssetsDir()+"ted2/newfiles/"
		For Local f := Eachin LoadDir( p )
			print f
			Local src := stringio.LoadString( p + f )
			local document:string = f.Replace( "_", " ")
			local icon:int = GetIconFromExt( ExtractExt( document ) )

			_newFiles.AddAction( StripExt( document ), icon ).Triggered = Lambda()
				Local doc := Cast<Mx2Document>( OpenDocument( "" ) )
				If doc
					doc.TextDocument.Text = src
					doc.Save()
				Endif
			End
		Next
		
		_scriptMenu = New Menu( "Scripts" )
		Local obj := JsonObject.Load( "asset::ted2/scripts.json" )
		Local hotkey := 0
		If obj
			For Local obj2 := Eachin obj["scripts"].ToArray()
				Local name := obj2.ToObject()["name"].ToString()
				Local script := obj2.ToObject()["script"].ToString()

				Local action := _scriptMenu.AddAction( name, NODEKIND_SCRIPT )
				If hotkey<FunctionKeys.Length
					action.HotKey = FunctionKeys[hotkey]
					action.HotKeyModifiers = Modifier.Shift
				endif
				hotkey+=1

				action.Triggered = Lambda()
					RunScript( script )
				End
			Next
		Endif

		_scripts = New Menu( "Scripts" )
		'Local obj:=JsonObject.Load( "asset::ted2/scripts.json" )
		If obj
			For Local obj2 := Eachin obj["scripts"].ToArray()
				Local name := obj2.ToObject()["name"].ToString()
				Local script := obj2.ToObject()["script"].ToString()
				Local action := _scripts.AddAction( name, NODEKIND_SCRIPT )
				action.Triggered = Lambda()
					RunScript( script )
				End
			Next
		Endif
		
		_recentFiles = New Menu( "Recent Files" )
		
		_closeProject = New Menu( "Close Project" )
		
		_fileMenu = New Menu( "File" )
		_fileMenu.AddAction( _fileNew, NODEKIND_NEW )
		_fileMenu.AddSubMenu( _newFiles )
		_fileMenu.AddAction( _fileOpen, NODEKIND_OPEN )
		_fileMenu.AddAction( _fileReOpen )
		_fileMenu.AddSubMenu( _recentFiles )
		_fileMenu.AddSeparator()
#If __HOSTOS__ = "macos"
		_fileMenu.AddAction( _fileClose, NODEKIND_OSXCLOSE )
#else		
		_fileMenu.AddAction( _fileClose, NODEKIND_WINDOWSCLOSE )
#end		
		_fileMenu.AddAction( _fileCloseAll )
		_fileMenu.AddSeparator()
		_fileMenu.AddAction( _fileSave, NODEKIND_SAVE )
		_fileMenu.AddAction( _fileSaveAs, NODEKIND_SAVEAS )
		_fileMenu.AddAction( _fileSaveAll )
		_fileMenu.AddSeparator()
		_fileMenu.AddAction( _fileNextFile )
		_fileMenu.AddAction( _filePrevFile )
		_fileMenu.AddSeparator()
		_fileMenu.AddAction( _fileOpenProject )
		_fileMenu.AddSubMenu( _closeProject )
		_fileMenu.AddSeparator()
		_fileMenu.AddAction( _fileQuit )
		
		_editMenu = New Menu( "Edit" )
		_editMenu.AddAction( _editUndo, NODEKIND_UNDO )
		_editMenu.AddAction( _editRedo, NODEKIND_REDO )
		_editMenu.AddSeparator()
		_editMenu.AddAction( _editCut )
		_editMenu.AddAction( _editCopy )
		_editMenu.AddAction( _editPaste )
		_editMenu.AddSeparator()
		_editMenu.AddAction( _editSelectAll )
		_editMenu.AddSeparator()
		_editMenu.AddAction( _editFind, NODEKIND_FIND )
		_editMenu.AddAction( _findNext )
		_editMenu.AddAction( _findPrevious )
		_editMenu.AddAction( _findReplace )
		_editMenu.AddAction( _findReplaceAll )
		_editMenu.AddSeparator()
		_editMenu.AddAction( _findShowInvisibles )
		_editMenu.AddAction( _findUseBigCursor )
		
		_buildMenu=New Menu( "Build" )
		_buildMenu.AddAction( _buildDebug, NODEKIND_RUNDEBUG )
		_buildMenu.AddAction( _buildRelease, NODEKIND_RUN )
		_buildMenu.AddSeparator()
		_buildMenu.AddAction( _buildNextError )
		_buildMenu.AddSeparator()
		_buildMenu.AddAction( _buildLockFile, NODEKIND_LOCK )
		_buildMenu.AddSeparator()
		_buildMenu.AddSubMenu( _scripts )
		_buildMenu.AddSeparator()
		_buildMenu.AddAction( _buildForceStop )
		
		_helpMenu=New Menu( "Help" )
		_helpMenu.AddAction( _helpOnlineHelp, NODEKIND_HELPONLINE )
		_helpMenu.AddAction( _helpOfflineHelp, NODEKIND_HELPBOOKS )
		_helpMenu.AddSeparator()
		_helpMenu.AddAction( _helpAbout, NODEKIND_HELP )

		_panelMenu=New Menu( "Panels" )
		_panelMenu.AddAction( _panelColor, NODEKIND_COLORPANEL )
		_panelMenu.AddSeparator()
		_panelMenu.AddAction( _cmdEscape, NODEKIND_CONSOLE )
		
		_menuBar = New MenuBar
		_menuBar.AddMenu( _fileMenu )
		_menuBar.AddMenu( _editMenu )
		_menuBar.AddMenu( _buildMenu )
		_menuBar.AddMenu( _scriptMenu )
		_menuBar.AddMenu( _panelMenu )
		_menuBar.AddMenu( _helpMenu )


			local _fieldButton:Buttonx
		 _fieldButton = New Buttonx( "", 40, 40)
		 _fieldButton.Live = false
		 _fieldButton.ImageButton = 10'NODEKIND_VLINE
			_menuBar.AddView( _fieldButton,"left",30, false )

		local _actionField:Action
    _actionField = New Action( "method" )
    _actionField.Triggered = Lambda()
			OnFileNew()
		end
   _fieldButton = New Buttonx( _actionField, "", 40, 40)
   _fieldButton.ImageButton = 7'NODEKIND_NEW
		_menuBar.AddView( _fieldButton,"left",40, false )

    _actionField = New Action( "method" )
    _actionField.Triggered = Lambda()
			OnFileOpen()
		end
   _fieldButton = New Buttonx( _actionField, "", 40, 40)
   _fieldButton.ImageButton = 4'NODEKIND_OPEN
		_menuBar.AddView( _fieldButton,"left",40, false )

    _actionField = New Action( "method" )
    _actionField.Triggered = Lambda()
			OnFileSave()
		end
   _fieldButton = New Buttonx( _actionField, "", 40, 40)
   _fieldButton.ImageButton = 5'NODEKIND_SAVE
		_menuBar.AddView( _fieldButton,"left",40, false )

    _actionField = New Action( "method" )
    _actionField.Triggered = Lambda()
			OnFileSaveAs()
		end
   _fieldButton = New Buttonx( _actionField, "", 40, 40)
   _fieldButton.ImageButton = 6'NODEKIND_SAVEAS
		_menuBar.AddView( _fieldButton,"left",40, false )

		 _fieldButton = New Buttonx( "", 40, 40)
		 _fieldButton.Live = false
		 _fieldButton.ImageButton = 10'NODEKIND_VLINE
			_menuBar.AddView( _fieldButton,"left",30, false )

'    _actionField = New Action( "method" )
'    _actionField.Triggered = Lambda()
'			OnEditUndo()
'		end
'   _fieldButton = New Buttonx( _actionField, "", 40, 40)
'   _fieldButton.ImageIcon = NODEKIND_UNDO
'		_menuBar.AddView( _fieldButton,"left",40, false )

'    _actionField = New Action( "method" )
'    _actionField.Triggered = Lambda()
'			OnEditRedo()
'		end
'   _fieldButton = New Buttonx( _actionField, "", 40, 40)
'   _fieldButton.ImageIcon = NODEKIND_REDO
'		_menuBar.AddView( _fieldButton,"left",40, false )

'		 _fieldButton = New Buttonx( "", 40, 40)
'		 _fieldButton.Live = false
'		 _fieldButton.ImageButton = 10'NODEKIND_VLINE
'			_menuBar.AddView( _fieldButton,"left",30, false )

    _actionField = New Action( "method" )
    _actionField.Triggered = Lambda()
			OnBuildRelease()
		end
   _fieldButton = New Buttonx( _actionField, "", 40, 40)
   _fieldButton.ImageButton = 8'NODEKIND_RUN
		_menuBar.AddView( _fieldButton,"left",40, false )

    _actionField = New Action( "method" )
    _actionField.Triggered = Lambda()
			OnBuildDebug()
		end
   _fieldButton = New Buttonx( _actionField, "", 40, 40)
   _fieldButton.ImageButton = 9'NODEKIND_RUNDEBUG
		_menuBar.AddView( _fieldButton,"left",40, false )

    _actionField = New Action( "method" )
    _actionField.Triggered = Lambda()
			OnBuildForceStop()
		end
   _fieldButton = New Buttonx( _actionField, "", 40, 40)
   _fieldButton.ImageButton = 17'NODEKIND_SAVEAS
		_menuBar.AddView( _fieldButton,"left",40, false )

		 _fieldButton = New Buttonx( "", 40, 40)
		 _fieldButton.Live = false
		 _fieldButton.ImageButton = 10'NODEKIND_VLINE
			_menuBar.AddView( _fieldButton,"left",30, false )


		local _findField := New TextField
		_menuBar.AddView( _findField,"left",180, false )
		_findField.EnterHit = Lambda()
			print "find "+_findField.Text
		end

		local _actionFind:Action
    _actionFind = New Action( "find" )
    _actionFind.Triggered = Lambda()
			print "find "+_findField.Text
		end
   _fieldButton = New Buttonx( _actionFind, "", 40, 40)
   _fieldButton.ImageButton = 3'NODEKIND_FIND
		_menuBar.AddView( _fieldButton,"left",40, false )

    _actionFind = New Action( "prefs" )
    _actionFind.Triggered = Lambda()
			print "prefs "
		end
   _fieldButton = New Buttonx( _actionFind, "", 40, 40)
   _fieldButton.ImageButton = 16'NODEKIND_FIND
		_menuBar.AddView( _fieldButton,"right",40, false )

	End


	
	Method InitViews()
		_findDialog = New FindDialog
		_searchDialog = New SearchDialog
		
		_projectView = New ProjectView	
		_codeView = new CodeView
		_codeView.MethodClicked = Lambda( )
			_currentTextView.Document.Code.ModifyKind( null, NODEKIND_METHOD, _codeView.MethodState )
		end	
		_codeView.FunctionClicked = Lambda( )
			_currentTextView.Document.Code.ModifyKind( null, NODEKIND_FUNCTION, _codeView.FunctionState )
		end	
		_codeView.FieldClicked = Lambda( )
			_currentTextView.Document.Code.ModifyKind( null, NODEKIND_FIELD, _codeView.FieldState )
		end	
		_codeView.PropertyClicked = Lambda( )
			_currentTextView.Document.Code.ModifyKind( null, NODEKIND_PROPERTY, _codeView.PropertyState )
		end	
		_codeView.LambdaClicked = Lambda( )
			_currentTextView.Document.Code.ModifyKind( null, NODEKIND_LAMBDA, _codeView.LambdaState )
		end	


    
		_debugView = New DebugView
		_helpView = New HelpView

		_browser = New TabView
		_browser.AddTab( "Project", _projectView )
		_browser.AddTab( "Code", _codeView )
		_browser.AddTab( "Debug", _debugView )
		_browser.AddTab( "Help", _helpView )
		_browser.CurrentView = _projectView
		_browser.CurrentChanged = Lambda()
		'print "browser changed"







		select _browser.CurrentView
			case _helpView
				print "helpview"
				_console.Visible = false
				_docTabber.Visible = false
				
					
			default
				_docTabber.Visible = true

				_currentTextView = Null
				If _currentDoc then
					_currentTextView = Cast<TextView>( _currentDoc.View )
					
					If _currentTextView Then
						if _showConsole then _console.Visible = true
					endif
				end if
'				if _browser.PreviousView = _helpView Then
'				end if
		end select
'			if _browser.CurrentView = _codeView Then
				'print "CODE VIEW"
				
				'_codeView._docker.ContentView
				
		
'			end if
		end 
		
		
		_colorView = New ColorView
		_colorView.UseColor = Lambda()
			Local textView := Cast<TextView>( App.KeyView )
			
			If not textView then Return
        
			textView.Insert( _colorView.RGB )
		End
		_colorView.CloseColor = Lambda()
			_colorView.Visible = false
		end
		
		
		_console = New Console
		_console.ReadOnly = True
		
		_docTabber = New TabViewX
		_docTabber.CurrentChanged = Lambda()
			'print "document changed"
			Local closeDoc:Bool = _docTabber.GetMouseX > 0
			'      print closeDoc

			MakeCurrent( FindDocument( _docTabber.CurrentView ) )

			If closeDoc Then OnFileClose()
		End

		_statusbar = New StatusBar

		
		_docker = New DockingView
		_docker.ContentView = _docTabber
		_docker.AddView( _menuBar,"top",40, false )
		_docker.AddView( _statusbar, "bottom", 30, false )
		
		_docker.AddView( _browser,"left",250 )
		_docker.AddView( _colorView,"right",200, false )
		_docker.AddView( _console,"bottom",200 )

	End


	
	Method New( title:String, rect:Recti, flags:WindowFlags )
		Super.New( title, rect, flags )
		
		MainWindow = Self
		
		ClearColor = Theme.ClearColor
		
		SwapInterval = 1
		
		InitPaths()
		InitActions()
		InitMenus()
		InitViews()

		AddChild( _docker )
		
		LoadState()
		
		DeleteTmps()
		
		UpdateRecentFilesMenu()
		
		UpdateCloseProjectMenu()
		
		If Not _projects.Length
			Local dir := CurrentDir()
			If _projectView.OpenProject( dir ) _projects.Push( dir )
		Endif

		App.Idle += AppIdle
		
		Update()
		
		If Not _docTabber.Count OnHelpAbout()
		
	End


	
	Method OnWindowEvent( event:WindowEvent ) Override
		Select event.Type
			Case EventType.WindowClose
				_fileQuit.Trigger()
			Default
				Super.OnWindowEvent( event )
		End
	End



	Method ToRecti:Recti( value:JsonValue )
		Local json:=value.ToArray()
		Return New Recti( json[0].ToNumber(),json[1].ToNumber(),json[2].ToNumber(),json[3].ToNumber() )
	End


	
	Method UpdateCloseProjectMenu()
		_closeProject.Clear()
		For Local dir:=Eachin _projects
			_closeProject.AddAction( dir ).Triggered=Lambda()
				_projectView.CloseProject( dir )
				_projects.Remove( dir )
				UpdateCloseProjectMenu()
			End
		Next
	End


	
	Method UpdateRecentFilesMenu()
		_recentFiles.Clear()
		For Local path:=Eachin _recent
			_recentFiles.AddAction( path, GetIconFromExt( ExtractExt( path ) ) ).Triggered = Lambda()
				OpenDocument( path )
			End
		Next
	End
	
	
	
	Method LoadState()
		Local obj:=JsonObject.Load( "bin/ted2.state.json" )
		If Not obj Return
		
		If obj.Contains( "codeMethod" )
			_codeView.MethodState = obj["codeMethod"].ToBool()
		Endif
		If obj.Contains( "codeFunction" )
			_codeView.FunctionState = obj["codeFunction"].ToBool()
		Endif
		If obj.Contains( "codeField" )
			_codeView.FieldState = obj["codeField"].ToBool()
		Endif
		If obj.Contains( "codeLambda" )
			_codeView.LambdaState = obj["codeLambda"].ToBool()
		Endif
		If obj.Contains( "codeProperty" )
			_codeView.PropertyState = obj["codeProperty"].ToBool()
		Endif

		If obj.Contains( "showInvisibles" )
			_showInvisibles = obj["showInvisibles"].ToBool()
		Endif
		If obj.Contains( "showBigCursor" )
			_showBigCursor = obj["showBigCursor"].ToBool()
		Endif

		If obj.Contains( "openDocuments" )
			For Local doc := Eachin obj["openDocuments"].ToArray()
				Local path := doc.ToString()
				If GetFileType( path ) <> FileType.File Continue
          
				OpenDocument( doc.ToString() )
			Next
		Endif
		
		If obj.Contains( "recentFiles" )
			_recent.Clear()
'			For Local path:=Eachin obj["recentFiles"].ToArray()
'				_recent.Push( path.ToString() )
'			Next
			For Local file := Eachin obj["recentFiles"].ToArray()
 				Local path := file.ToString()
 				If GetFileType( path ) <> FileType.File Continue
 				_recent.Push( path )
			Next
		End
		
		If obj.Contains( "openProjects" )
			_projects.Clear()
'			For Local jdir:=Eachin obj["openProjects"].ToArray()
'				Local dir:=jdir.ToString()
'				If _projectView.OpenProject( dir ) _projects.Push( dir )
			For Local proj := Eachin obj["openProjects"].ToArray()
				Local dir := proj.ToString()
				If Not _projectView.OpenProject( dir ) Continue
				_projects.Push( dir )
			Next
		Endif
		
		If obj.Contains( "windowRect" )
			Frame=ToRecti( obj["windowRect"] )
		Endif
		
		If obj.Contains( "colorPanel" )
			_colorView.Visible = obj["colorPanel"].ToNumber()
		endif

		If obj.Contains( "consoleSize" )
			_docker.SetViewSize( _console,obj["consoleSize"].ToNumber() )
		Endif
		
		If obj.Contains( "browserSize" )
			_docker.SetViewSize( _browser,obj["browserSize"].ToNumber() )
		Endif

		If obj.Contains( "helpTreeSize" )
			_helpView.SetViewSize( _helpView.HelpTree,obj["helpTreeSize"].ToNumber() )
		Endif
		
		If obj.Contains( "lockedDocument" )
			Local doc:=OpenDocument( obj["lockedDocument"].ToString() )
			If doc LockDoc( doc )
		Endif
	End

	
	Method ToJson:JsonValue( rect:Recti )
		Return New JsonArray( New JsonValue[]( New JsonNumber( rect.min.x ),New JsonNumber( rect.min.y ),New JsonNumber( rect.max.x ),New JsonNumber( rect.max.y ) ) )
	End


	Method SaveState()
		Local obj := New JsonObject
		
		Local docs := New JsonArray
		For Local doc := Eachin _openDocs
			docs.Add( New JsonString( doc.Path ) )
		Next
		obj["openDocuments"] = docs
		
		Local recent := New JsonArray
		For Local path := Eachin _recent
			recent.Add( New JsonString( path ) )
		End
		obj["recentFiles"] = recent
		
		Local projects := New JsonArray
		For Local dir := Eachin _projects
			projects.Add( New JsonString( dir ) )
		Next
		obj["openProjects"] = projects
		
		obj["windowRect"] = ToJson( Frame )
		
		obj["colorPanel"] = New JsonNumber( _colorView.Visible )

		obj["showInvisibles"] = New JsonNumber( _showInvisibles )
		obj["showBigCursor"] = New JsonNumber( _showBigCursor )

		obj["consoleSize"] = New JsonNumber( _docker.GetViewSize( _console ) )
		
		obj["browserSize"] = New JsonNumber( _docker.GetViewSize( _browser ) )
		
		obj["codeMethod"] = New JsonBool( _codeView.MethodState )
		obj["codeFunction"] = New JsonBool( _codeView.FunctionState )
		obj["codeLambda"] = New JsonBool( _codeView.LambdaState )
		obj["codeField"] = New JsonBool( _codeView.FieldState )
		obj["codeProperty"] = New JsonBool( _codeView.PropertyState )
		
		obj["helpTreeSize"] = New JsonNumber( _helpView.GetViewSize( _helpView.HelpTree ) )
		
		If _lockedDoc obj["lockedDocument"]=New JsonString( _lockedDoc.Path )
		
		
		local k:Int
		local out:string = ""
		local str:string = ""
		local chr:string
		local tab:string = ""
		local length:int
		for k = 0 to obj.ToJson().Length
			chr = obj.ToJson().Mid(k,1)
			Select chr
				case "{", "["
					str = str + chr
					out = out + str + "~n"
					tab = tab + "~t"
					str = tab
				case "}", "]"
					out = out + str + "~n"
					length = tab.Length
					tab = tab.Left( length - 2 )
					str = tab + chr
				case ","
					str = str + chr
					out = out + str + "~n"
					str = tab
				default
					str = str + chr
			end
		next
		out = out + str + "~n"
   
		SaveString( out,"bin/ted2.state.json" )
	End



	
	Method Notify( text:String,title:String="Ted2" )
		Local buttons:=New String[]( "Okay" )
		TextDialog.Run( title,text,buttons )
	End


	
	Method Confirm:Bool( text:String,title:String="Ted2" )
		Local buttons:=New String[]( "Okay","Cancel" )
		Return TextDialog.Run( title,text,buttons )=0
	End


	
	Method DeleteTmps()
		For Local i:=1 Until 10
			Local path:=RealPath( _tmp+"untitled"+i+".monkey2" )
			If GetFileType( path )=FileType.File 
				If Not FindDocument( path ) DeleteFile( path )
			Endif
		Next
	End


	
	Method AllocTmpPath:String()
		For Local i:=1 Until 10
			Local path:=_tmp+"untitled"+i+".monkey2"
			If GetFileType( path )=FileType.None Return path
		Next
		Return ""
	End


	
	Method IsTmpPath:Bool( path:String )
		Return path.StartsWith( _tmp )
	End


	
	Method BuildDoc:Ted2Document()
		If _lockedDoc Return _lockedDoc
		Return _currentDoc
	End


	
	Method LockDoc( doc:Ted2Document )
		If _lockedDoc And _lockedDoc=doc
			_lockedDoc=Null
			UpdateTabLabel( doc )
			Return
		Endif

		If doc And Not Cast<TextView>( doc.View ) doc=Null
	
		Local old:=_lockedDoc
		_lockedDoc=doc
		
		If _lockedDoc=old Return
		
		UpdateTabLabel( old )
		UpdateTabLabel( _lockedDoc )
	End


	
	Method UpdateKeyView()
		If Not _currentDoc Return
		
		_currentDoc.View.MakeKeyView()
	End


	
	Method MakeCurrent( doc:Ted2Document )
		If doc = _currentDoc Then
			Return
		end if
		
		If doc And _docTabber.CurrentView <> doc.View then
			Local icon:Int = DocumentTabIcon( doc )
			_docTabber.SetTabIcon( doc.View, icon )
		
			_docTabber.CurrentView = doc.View
		Endif

 '   print doc.Path

		_currentDoc = doc
		_currentTextView = Null
		If doc then
			_currentTextView = Cast<TextView>( doc.View )
      
			If _currentTextView Then
      'print "here"
				_codeView.ContentView = _currentTextView.Document.Code
				
				_currentTextView.BlockCursor = _showBigCursor
				_currentTextView.ShowInvisibles = _showInvisibles

				_statusbar.SetCursor( _currentTextView.Document.CursorLine, _currentTextView.Document.CursorColumn, _currentTextView.Document.CursorChar )
				_currentTextView.Document.SelectedIndex = _currentTextView.Document.CursorCodeLine

				_currentTextView.Document.CursorMoved = Lambda()
					_statusbar.SetCursor( _currentTextView.Document.CursorLine, _currentTextView.Document.CursorColumn, _currentTextView.Document.CursorChar )
'					print _currentTextView.Document.CursorCodeLine
					
					_currentTextView.Document.SelectedIndex = _currentTextView.Document.CursorCodeLine
					
'					print "line="+_currentTextView.Document.CursorLine+" column="+_currentTextView.Document.CursorColumn
				end
	
				_currentTextView.Document.Code.ModifyKind( null, NODEKIND_METHOD, _codeView.MethodState )
				_currentTextView.Document.Code.ModifyKind( null, NODEKIND_FUNCTION, _codeView.FunctionState )
				_currentTextView.Document.Code.ModifyKind( null, NODEKIND_FIELD, _codeView.FieldState )
				_currentTextView.Document.Code.ModifyKind( null, NODEKIND_PROPERTY, _codeView.PropertyState )
				_currentTextView.Document.Code.ModifyKind( null, NODEKIND_LAMBDA, _codeView.LambdaState )
				if _showConsole then _console.Visible = true
			else	
				_console.Visible = false
				local imageView := Cast<ImageView>( doc.View )
				
				if imageView Then
					imageView.ZoomChanged = Lambda()
						_statusbar.SetImage( imageView.ImageWidth, imageView.ImageWidth, imageView.ImageZoom )
					end

					_statusbar.SetImage( imageView.ImageWidth, imageView.ImageWidth, imageView.ImageZoom )
				end if
			endif

		end if
		

		
		App.Idle += Lambda()
			If _currentDoc
				Title="Ted2 - " + _currentDoc.Path
			Else
				Title="Ted2"
			Endif
		End

		UpdateKeyView()
		
'		print _currentDoc.GetMouseX()
		
		Update()
	End


	
	Method FindDocument:Ted2Document( path:String )
		For Local doc:=Eachin _openDocs
			If doc.Path=path Return doc
		Next
		Return Null
	End	


	
	Method FindDocument:Ted2Document( view:View )
		For Local doc:=Eachin _openDocs
			If doc.View=view Return doc
		Next
		Return Null
	End	



	Method ReadError( path:String )
		Notify( "I/O Error reading file '"+path+"'" )
	End
	
	Method WriteError( path:String )
		Notify( "I/O Error writing file '"+path+"'" )
	End


	
	Method DocumentTabLabel:String( doc:Ted2Document )
		Local label := StripDir( doc.Path )
		Local ext := ExtractExt( doc.Path ).ToLower()
		If ext = ".monkey2" then label = StripExt( label )
		If IsTmpPath( doc.Path ) Then label = "<"+label+">"
		If doc = _lockedDoc Then label = "+"+label
		If doc.Dirty Then label += "*"
		Return label
	End
	
	
	
	Method GetIconFromExt:int( ext:string )
		ext = ext.ToLower()

		Local icon:Int = 0
		Select ext
			Case ".txt", ".md"
				icon = NODEKIND_TEXT
			Case ".cpp", "cxx", ".c"
				icon = NODEKIND_CPP
			Case ".h", ".hpp", ".hxx"
				icon = NODEKIND_H
			Case ".m", ".mm"
				icon = NODEKIND_M
			Case ".htm", ".html"
				icon = NODEKIND_HTML
			Case ".bat", ".sh"
				icon = NODEKIND_SCRIPT
			Case ".js"
				icon = NODEKIND_JAVASCRIPT
			Case ".css", ".json", ".xml"
				icon = NODEKIND_WEBSCRIPT
			Case ".ttf"
				icon = NODEKIND_FONT
			Case ".app", ".exe"
				icon = NODEKIND_APP
			Case ".wav", ".wave"
				icon = NODEKIND_AUDIO
			Case ".png", ".jpg", "bmp"
				icon = NODEKIND_IMAGE
			Case ".monkey2", ".mx2"
				icon = NODEKIND_MONKEY2
		End Select
		
		return icon
	end Method
	
	
	
	Method DocumentTabIcon:int( doc:Ted2Document )
		Local label := StripDir( doc.Path )
		return GetIconFromExt( ExtractExt( doc.Path ) )
#rem		
		Local ext := ExtractExt( doc.Path ).ToLower()
		
		Local icon:Int = 0
		Select ext
			Case ".txt", ".md"
				icon = NODEKIND_TEXT
			Case ".cpp", "cxx", ".c"
				icon = NODEKIND_CPP
			Case ".h", ".hpp", ".hxx"
				icon = NODEKIND_H
			Case ".m", ".mm"
				icon = NODEKIND_M
			Case ".htm", ".html"
				icon = NODEKIND_HTML
			Case ".bat", ".sh"
				icon = NODEKIND_SCRIPT
			Case ".js"
				icon = NODEKIND_JAVASCRIPT
			Case ".css", ".json", ".xml"
				icon = NODEKIND_WEBSCRIPT
			Case ".ttf"
				icon = NODEKIND_FONT
			Case ".app", ".exe"
				icon = NODEKIND_APP
			Case ".wav", ".wave"
				icon = NODEKIND_AUDIO
			Case ".png", ".jpg", "bmp"
				icon = NODEKIND_IMAGE
			Case ".monkey2", ".mx2"
				icon = NODEKIND_MONKEY2
		End Select
'rem		
	Select ext
      Case ".monkey2"
        icon = NODEKIND_MONKEY2
      Case ".png", ".jpg", ".bmp"', ".gif"
        icon = NODEKIND_IMAGE
      Case ".h", ".hpp", ".hxx"
      Case ".c", ".cpp", ".cxx"
      case ".m", ".mm"
      case ".s", ".asm"
      Case ".html", ".md", ".json", ".xml"
      Case ".css"
      case ".js"
      Case ".sh", ".bat"
      Case ".glsl"
      Case ".txt"
      Default
    End Select
#end    
'		Return icon
  End
  
  
  
	Method UpdateTabLabel( doc:Ted2Document )
		If doc Then
			Local icon:Int = DocumentTabIcon( doc )
			_docTabber.SetTabLabel( doc.View, DocumentTabLabel( doc ), icon )
		end if
	End


	
	Method OpenDocument:Ted2Document( path:String, addRecent:Bool = False, makeCurrent:Bool = True )
		Local doc:Ted2Document

		If path
			path = RealPath( path )
			
			Local ext := ExtractExt( path ).ToLower()
			
      '_statusbar.SetText( )
			Select ext
				Case ".monkey2"
				Case ".png", ".jpg", ".bmp"', ".gif"
				Case ".h", ".hpp", ".hxx", ".c", ".cpp", ".cxx", ".m", ".mm", ".s", ".asm"
				Case ".html", ".md", ".json", ".xml"
				Case ".css", ".js"
				Case ".sh", ".bat"
				Case ".glsl"
				Case ".txt"
				Default
      
					_statusbar.SetError( "This item does not support previewing" )
          
          'Notify( "Unrecognized file type extension for file '"+path+"'" )
					Return Null
			End
		
			doc = FindDocument( path )
			If doc Then
				_statusbar.SetText( "" )
				If makeCurrent Then MakeCurrent( doc )
				Return doc
			Endif
			
			Select ext
				Case ".monkey2", ".mx2"
					doc = New Mx2Document( path )
				Case ".png",".jpg"
					doc = New ImgDocument( path )
				Default
					doc = New TxtDocument( path )
			End
			
		Else
		

			path = AllocTmpPath()
			If Not path then
				_statusbar.SetError( "Can't create temporary file" )
				'Notify( "Can't create temporary file" )
				Return Null
			Endif
			SaveString( "", path )

			_statusbar.SetError( "This item does not support previewing" )
			
			doc = New Mx2Document( path )
		
		Endif
		
'		If Not doc.Load()
		If GetFileType( path ) <> FileType.File Or Not doc.Load()
			_statusbar.SetError( "Can't preview this document" )

			ReadError( path )
			Return Null
		End
		
		doc.DirtyChanged = Lambda()
			UpdateTabLabel( doc )
		End
		
		_docTabber.AddTab( DocumentTabLabel( doc ), doc.View )
		_openDocs.Add( doc )
		
		If addRecent
			_recent.Remove( path )
			_recent.Insert( 0,path )
			If _recent.Length > 20 Then _recent.Resize( 20 )
			UpdateRecentFilesMenu()
		Endif
		
		If makeCurrent Then MakeCurrent( doc )

		Return doc
	End
	
	
	
	Method RenameDocument( doc:Ted2Document,path:String )
		doc.Rename( path )

		UpdateTabLabel( doc )
	End


	
	Method SaveDocument:Bool( doc:Ted2Document )
		If IsTmpPath( doc.Path )

			Local path:=RequestFile( "Save As","",True )

			If Not path Return False
			
			RenameDocument( doc,path )
		Endif
		
		If doc.Save() Return True
		
		WriteError( doc.Path )
		
		Return False
	End


	
	Method CloseDocument( doc:Ted2Document )
		Local index:=_docTabber.IndexOfView( doc.View )
		
		_docTabber.RemoveTab( doc.View )

		_openDocs.Remove( doc )
		
'		doc.Close()
		App.Idle += Lambda()
			doc.Close()
			
			If IsTmpPath( doc.Path ) DeleteFile( doc.Path )
		End		
'		If IsTmpPath( doc.Path ) DeleteFile( doc.Path )
		
		If doc=_lockedDoc _lockedDoc=Null
		
		If doc<>_currentDoc Return
		
		If Not _docTabber.Count 
			MakeCurrent( Null )
			Return
		Endif
		
		If index=_docTabber.Count index-=1
		
		MakeCurrent( FindDocument( _docTabber.ViewAtIndex( index ) ) )
	End


	
	Method GotoError( err:Mx2Error )
		Local doc:=Cast<Mx2Document>( OpenDocument( err.path ) )
		If Not doc Return
		
		Local tv:=Cast<TextView>( doc.View )
		If Not tv Return
		
		Local sol:=tv.Document.StartOfLine( err.line )
		tv.SelectText( sol,sol )
		
		Return
	End
	
	
	
	Method Build( config:String )
		If _console.Running then Return
		
		Local buildDoc := Cast<Mx2Document>( BuildDoc() )
		If Not buildDoc then Return
		
		For Local doc := Eachin _openDocs
			Local mx2Doc := Cast<Mx2Document>( doc )
			If mx2Doc then mx2Doc.Errors.Clear()
		Next
		
		For Local doc := Eachin _openDocs
			If doc.Save() then Continue
			WriteError( doc.Path )
			Return
		Next

		_console.Clear()
		
		Local cmd := _mx2cc+" makeapp -apptype=gui -build -config="+config+" ~q"+buildDoc.Path+"~q"
		
		If Not _console.Start( cmd ) then
			'print buildDoc.Path
			
			Notify( "1 Failed to start process: '"+cmd+"'" )
			Return
		Endif
		
		Local appFile:String
		
'		Local dialog := New TextDialog( "Ted2","Building "+buildDoc.Path+"..." )
		
'		dialog.AddAction( "Cancel" ).Triggered=_console.Terminate
		
'		dialog.Open()

		_errors.Clear()
		Local count:Int = 0
		
		
		Repeat
			Local stdout:=_console.ReadStdout()
			If Not stdout Exit
			
			'print "build "+stdout
			_statusbar.SetBuilding(count, stdout)
			count = count + 1
			
			If stdout.StartsWith( "Application built:" )
				appFile=stdout.Slice( stdout.Find( ":" )+1 ).Trim()
			Else
				Local i:=stdout.Find( "] : Error : " )
				If i<>-1
					Local j:=stdout.Find( " [" )
					If j<>-1
						Local path:=stdout.Slice( 0,j )
						Local line:=Int( stdout.Slice( j+2,i ) )-1
						Local msg:=stdout.Slice( i+12 )
						
						Local err:=New Mx2Error( path,line,msg )
						Local doc:=Cast<Mx2Document>( OpenDocument( path,False,False ) )
						
						If doc
							doc.Errors.Add( err )
							If _errors.Empty GotoError( err )
							_errors.Add( err )
						Endif
						
					Endif
				Endif
			Endif
			
			_console.Write( stdout )
		
		Forever
		
'		dialog.Close()
		_statusbar.SetNormal()
		
		If Not appFile Return
		
		cmd=appFile
		
		If Not _console.Start( cmd )
			Notify( "2 Failed to start process: '"+cmd+"'" )
			Return
		Endif
		
		_console.Clear()
		
		Local tab := _browser.CurrentView
			
		If config = "debug"
			_statusbar.SetDebug()
      
			_console.Write( "Debugging app:"+appFile+"~n" )
			_browser.CurrentView = _debugView
			_debugView.DebugBegin()
		Else
			_statusbar.SetRunning()
			_console.Write( "Running app:"+appFile+"~n" )
		Endif
		
		Repeat
			
			Local stdout := _console.ReadStdout()
			If Not stdout Exit
			
			If config = "debug" And stdout="{{!DEBUG!}}~n"
        '_statusbar.EndDebug()

				_debugView.DebugStop()
				Continue
			End
			
			_console.Write( stdout )
		
		Forever
		
		If config = "debug"
			_debugView.DebugEnd()
			_statusbar.EndDebug()
		Endif
		
		For Local doc:=Eachin _openDocs
			Local mx2Doc:=Cast<Mx2Document>( doc )
			If mx2Doc mx2Doc.DebugLine=-1
		Next
		
		_browser.CurrentView=tab
		
		_console.Write( "Done.~n" )

		_statusbar.SetNormal()
	End


	
	Method RunScript( script:String )
		If _console.Running then Return
		
		For Local doc := Eachin _openDocs
			If doc.Save() Continue
			WriteError( doc.Path )
			Return
		Next
		
		_console.Clear()

#If __HOSTOS__="windows"
		script+=".bat"
#Else
		script+=".sh"
#Endif
		Local cmd := script
		
		Local cd := CurrentDir()
		ChangeDir( "scripts" )
		
'		print "dir="+CurrentDir()+" script="+cmd
'		Local command:string =  CurrentDir()+cmd
'		Print command
'		Local r := _console.Start( command  )
		
		Local r := _console.Start( CurrentDir()+cmd )
		ChangeDir( cd )
		
		If Not r then
			Notify( "3 Failed to start process: '"+cmd+"'" )
			Return
		Endif
		
		Repeat
			Local stdout:=_console.ReadStdout()
			If Not stdout Exit

			_statusbar.SetBuilding(0, stdout)
			_console.Write( stdout )
		Forever
			
		_console.Write( "Done.~n" )
		_statusbar.SetNormal()
		_statusbar.SetText("")

	End


	
	Method RequestDir:String( title:String,dir:String )
		Local future:=New Future<String>
		
		App.Idle+=Lambda()
			future.Set( mojo.requesters.RequestDir( title,dir ) )
		End
		
		Return future.Get()
	End



	Method RequestFile:String( title:String,filters:String,save:Bool,path:String="" )
		Local future:=New Future<String>
		
		App.Idle+=Lambda()
			future.Set( mojo.requesters.RequestFile( title,filters,save,path ) )
		End
		
		Return future.Get()
	End



	Method UpdateActions()
		Local keyView := Cast<TextView>( App.KeyView )
	
		Local dirtyDocs:Bool
		For Local doc := Eachin _openDocs
			If doc.Dirty Then dirtyDocs = True
		Next
		
		'print "action"
		
		While Not _errors.Empty And _errors.First.removed
			_errors.RemoveFirst()
		Wend
	
		_fileClose.Enabled = _currentDoc <> Null
		_fileCloseAll.Enabled = _openDocs.Length<>0
		_fileSave.Enabled = _currentDoc <> Null And _currentDoc.Dirty
		_fileSaveAs.Enabled = _currentDoc <> Null
		_fileSaveAll.Enabled = dirtyDocs
		_fileNextFile.Enabled = _docTabber.Count>1
		_filePrevFile.Enabled = _docTabber.Count>1
		
		_editUndo.Enabled = keyView And keyView.CanUndo
		_editRedo.Enabled = keyView And keyView.CanRedo
		_editCut.Enabled = keyView And keyView.CanCut
		_editCopy.Enabled = keyView And keyView.CanCopy
		_editPaste.Enabled = keyView And keyView.CanPaste
		_editSelectAll.Enabled = keyView <> Null
		
		Local dbg:Int = _buildDebug.Enabled
		_buildDebug.Enabled = BuildDoc() <> Null And Not _console.Running
		_buildRelease.Enabled = BuildDoc() <> Null And Not _console.Running
		_buildLockFile.Enabled = _currentDoc <> Null
		_buildForceStop.Enabled = _console.Running
		_buildNextError.Enabled = Not _errors.Empty
		
'		If dbg And Not(_debugView._debugging) Then
 '     _statusbar.EndDebug()
	'	End if
		
		_scripts.Enabled = Not _console.Running
		_scriptMenu.Enabled = Not _console.Running
	End

	
	Method AppIdle()
		UpdateActions()
		
		App.RequestRender()
	
		App.Idle+=AppIdle
		
		GCCollect()	'thrash that GC!
	End
	
End
