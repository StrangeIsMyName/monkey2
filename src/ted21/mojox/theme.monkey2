
Namespace mojox

#Import "assets/checkmark_icons.png@/mojox"
#Import "assets/treenode_expanded.png@/mojox"
#Import "assets/treenode_collapsed.png@/mojox"

#Import "assets/ui-icons.png@/mojox"
#Import "assets/ui-buttons.png@/mojox"
#Import "assets/ui-find.png@/mojox"



Const Theme := New ThemeInstance



Class ThemeInstance

	Property Name:String()
		Return _name
	End



	Property ClearColor:Color()
		Return _clearColor
	End


	
	Method Load()
		_name = "dark"
		_fontSize = 16
		_monoFontSize = 16
		
		Local obj := JsonObject.Load( "bin/ted2.config.json" )
		If obj
			If obj.Contains( "theme" )
				_name=obj["theme"].ToString()
			Endif
			If obj.Contains( "fontSize" )
				_fontSize=obj["fontSize"].ToNumber()
			Endif
			If obj.Contains( "monoFontSize" )
				_monoFontSize=obj["monoFontSize"].ToNumber()
			Endif
		Endif

		Select _name
			Case "light"
				_textColor = New Color( 0,0,0 )
				_disabledColor = New Color( .5,.5,.5 )
				_clearColor = New Color( .8,.8,.8 )
				_contentColor = New Color( .95,.95,.95 )
				_panelColor = New Color( .9,.9,.9 )
				_gutterColor = New Color( .8,.8,.8 )
				_borderColor = New Color( .7,.7,.7 )
				_lineColor = New Color( .95,.95,.95 )
				_knobColor = New Color( .7,.7,.7 )
				_hoverColor = New Color( .6,.6,.6 )
				_activeColor = New Color( .5,.5,.5 )
				
			Default
				_textColor = New Color( .9,.9,.9 )
				_disabledColor = New Color( .5,.5,.5 )
				_clearColor = New Color( .1,.1,.1 )
				_contentColor = New Color( .13,.13,.13 )
				_panelColor = New Color( .25,.25,.25 )
				_gutterColor = New Color( .1,.1,.1 )
				_borderColor = New Color( .1,.1,.1 )
				_lineColor = New Color( .2,.2,.2 )
				_knobColor = New Color( .4,.4,.4 )
				_hoverColor = New Color( .6,.6,.6 )
				_activeColor = New Color( .7,.7,.7 )
				
				_selectColor = New Color( 0,.5,1 )
				_selectColorT = New Color( 0,.5,1, .4 )
				_selectColorH = New Color( 0,.5,1, .7 )
				_selectColor2 = New Color( 0,.4,.9 )
				_backgroundColor = New Color( .15, .15, .15 )
				_toolColor = New Color( .25, .25, .25, 0.5 )
				_transparentColor = New Color( 0,.5,1, 0 )
		End
		
		_defaultFont = Font.Open( App.DefaultFontName, _fontSize )
		_defaultMonoFont = Font.Open( App.DefaultMonoFontName, _monoFontSize )

		Local style:Style
		Local state:Style
		
		style = Style.GetStyle( "" )
		style.DefaultColor = _textColor
		style.DefaultFont = _defaultFont



		'HelpSystem
		style = New Style( "mojo.HelpSystem" )
		style.DefaultColor = _panelColor
		style.BackgroundColor = _borderColor
		
		
		'Labeljl		
		style = New Style( "mojo.Labeljl" )
		style.DefaultColor = _textColor
		style.Padding = New Recti( 0,0,0,0 )

		'Buttonjl
		style=New Style( "mojo.Buttonjl",Style.GetStyle( "mojo.Labeljl" ) )
		
		Local icons := LoadIcons( "asset::mojox/checkmark_icons.png",16 )
		style.SetImage( "checkmark:unchecked",icons[0] )
		style.SetImage( "checkmark:checked",icons[1] )
		
		state=style.AddState( "selected" )
		state.BackgroundColor = _transparentColor

		state=style.AddState( "disabled" )
		state.DefaultColor = _disabledColor
		
		state=style.AddState( "hover" )
		state.BackgroundColor = _selectColorT
		
		state=style.AddState( "active" )
		state.BackgroundColor = _selectColorH

		state=style.AddState( "checked" )
		state.BackgroundColor = _selectColor2



		'StatusBar
		style=New Style( "mojo.StatusBar" )
		style.Border = New Recti( 0,0,0,0 )
		state.BackgroundColor=_selectColor2



		'TabViewjl
		style=New Style( "mojo.TabViewjl" )
		style.Border = New Recti( 0,0,0,0 )
		
		'TabButton
		style=New Style( "mojo.TabButtonjl",Style.GetStyle( "mojo.Buttonjl" ) )
		style.SetImage( "node:icons", Image.Load( "asset::mojox/ui-icons.png" ) )
		style.Border = New Recti( 0,0,0,0 )
		style.Padding = New Recti( 0,0,0,0 )
		
		state=style.AddState( "selected" )
		state.BackgroundColor = _selectColor

		state=style.AddState( "disabled" )
		state.DefaultColor = _disabledColor
		
		state=style.AddState( "hover" )
		state.BackgroundColor = _selectColorT
		
		state=style.AddState( "active" )
		state.BackgroundColor = _selectColorH

		state=style.AddState( "checked" )
		state.BackgroundColor = _selectColor2



		'Label		
		style=New Style( "mojo.Label" )
		style.DefaultColor=_textColor
		style.Padding=New Recti( -8,-4,8,4 )
'		style.Padding=New Recti( 0,0,0,0 )
		
		'Button
		style=New Style( "mojo.Button",Style.GetStyle( "mojo.Label" ) )
		
'		Local icons:=LoadIcons( "asset::mojox/checkmark_icons.png",16 )
		style.SetImage( "checkmark:unchecked",icons[0] )
		style.SetImage( "checkmark:checked",icons[1] )
		
		state=style.AddState( "disabled" )
		state.DefaultColor=_disabledColor
		
		state=style.AddState( "hover" )
		state.BackgroundColor=_hoverColor
		
		state=style.AddState( "active" )
		state.BackgroundColor=_activeColor


		'Buttonx
		style = New Style( "mojo.Buttonx", Style.GetStyle( "mojo.Label" ) )
		style.Padding = New Recti( -2,0,2,0 )
		style.Border = New Recti( -1,0,1,0 )

		style.SetImage( "node:icons", Image.Load( "asset::mojox/ui-icons.png" ) )
		style.SetImage( "node:buttons", Image.Load( "asset::mojox/ui-buttons.png" ) )

		Local icon2 := LoadIcons( "asset::mojox/ui-find.png",30 )
		style.SetImage( "find:find",icon2[0] )

		state=style.AddState( "selected" )
		state.BackgroundColor = _transparentColor

		state=style.AddState( "disabled" )
		state.DefaultColor = _disabledColor
		
		state=style.AddState( "hover" )
		state.BackgroundColor = _selectColorT
		
		state=style.AddState( "active" )
		state.BackgroundColor = _selectColorH

		state=style.AddState( "checked" )
		state.BackgroundColor = _selectColor2


		'NewButton
		style=New Style( "mojo.NewButton",Style.GetStyle( "mojo.Label" ) )
		
'		Local icons:=LoadIcons( "asset::mojox/checkmark_icons.png",16 )
		style.SetImage( "checkmark:unchecked",icons[0] )
		style.SetImage( "checkmark:checked",icons[1] )
		
		state=style.AddState( "selected" )
		state.BackgroundColor = _transparentColor

		state=style.AddState( "disabled" )
		state.DefaultColor = _disabledColor
		
		state=style.AddState( "hover" )
		state.BackgroundColor = _selectColorT
		
		state=style.AddState( "active" )
		state.BackgroundColor = _selectColorH

		state=style.AddState( "checked" )
		state.BackgroundColor = _selectColor2


		
		'Menu
		style = New Style( "mojo.Menu" )
		style.Padding = New Recti( -2,-2,2,2 )
		style.Border = New Recti( -1,-1,1,1 )
		style.BackgroundColor = _panelColor
		style.BorderColor = _borderColor
		
		'MenuButton
		style = New Style( "mojo.MenuButton", Style.GetStyle( "mojo.NewButton" ) )
		style.SetImage( "node:icons", Image.Load( "asset::mojox/ui-icons.png" ) )

		'MenuBar
		style = New Style( "mojo.MenuBar" )
		style.Padding = New Recti( -2,-2,2,2 )
		style.BackgroundColor = _panelColor

		
		'DockingView
		style = New Style( "mojo.DockingView" )
		
		'DockView
		style = New Style( "mojo.DockView" )
		
		'DragKnob
		style = New Style( "mojo.DragKnob" )
'		style.Padding=New Recti( -3,-3,3,3 )
		style.Padding = New Recti( -5,-5,5,5 )
		style.BackgroundColor = _panelColor
		
'		state=style.AddState( "hover" )
'		state.BackgroundColor=_hoverColor
		
'		state=style.AddState( "active" )
'		state.BackgroundColor=_activeColor
		state=style.AddState( "selected" )
		state.BackgroundColor = _transparentColor

		state=style.AddState( "disabled" )
		state.DefaultColor = _disabledColor
		
		state=style.AddState( "hover" )
		state.BackgroundColor = _selectColorT
		
		state=style.AddState( "active" )
		state.BackgroundColor = _selectColorH

		state=style.AddState( "checked" )
		state.BackgroundColor = _selectColor2


		
		'ScrollView
		style=New Style( "mojo.ScrollView" )
		style.BackgroundColor = _backgroundColor
		
		
		'ScrollBar
		style=New Style( "mojo.ScrollBar" )
'		style.BackgroundColor=_gutterColor
		style.BackgroundColor = _backgroundColor
'		style.BackgroundColor=_borderColor
		
		'ScrollKnob
		style=New Style( "mojo.ScrollKnob" )
		style.Padding=New Recti( -8,-8,8,8 )
		style.Border=New Recti( -1,-1,1,1 )
		style.BackgroundColor=_knobColor
		
		state=style.AddState( "hover" )
		state.BackgroundColor=_hoverColor
		
		state=style.AddState( "active" )
		state.BackgroundColor=_activeColor


		'TabView
		style=New Style( "mojo.TabView" )
		
		'TabButton
		style = New Style( "mojo.TabButton",Style.GetStyle( "mojo.NewButton" ) )
		style.Border = New Recti( 0,-2,2,0 )
		
		state = style.AddState( "selected" )
'		state.BackgroundColor=_contentColor
		state.BackgroundColor = _selectColor
		
		state = style.AddState( "hover" )
		state.BackgroundColor = _hoverColor
		
		state = style.AddState( "active" )
'		state.BackgroundColor=_activeColor
'		state.BackgroundColor = _hoverColor


		'TitleBar
		style = New Style( "mojo.TitleBar" )
		style.SetImage( "node:buttons", Image.Load( "asset::mojox/ui-buttons.png" ) )
		style.BorderColor = _panelColor
'		style.BackgroundColor = _panelColor
		style.DefaultColor = _selectColor2
		
		
		'HtmlView
		style = New Style( "mojo.HtmlView" )

		'TreeView
		style = New Style( "mojo.TreeView" )
		style.SetImage( "node:expanded", Image.Load( "asset::mojox/treenode_expanded.png" ) )
		style.SetImage( "node:collapsed", Image.Load( "asset::mojox/treenode_collapsed.png" ) )
		style.SetImage( "node:icons", Image.Load( "asset::mojox/ui-icons.png" ) )
		style.BorderColor = _contentColor
		style.BackgroundColor = _borderColor
		style.DefaultColor = _textColor
'		style.Margin = New Recti( -2,-2,2,2 )

		'ColorTreeView
		style=New Style( "mojo.ColorTreeView" )
		style.SetImage( "node:expanded", Image.Load( "asset::mojox/treenode_expanded.png" ) )
		style.SetImage( "node:collapsed", Image.Load( "asset::mojox/treenode_collapsed.png" ) )
		style.SetImage( "node:icons", Image.Load( "asset::mojox/ui-icons.png" ) )
		style.BackgroundColor = _borderColor
		style.DefaultColor = _selectColor2
		style.BorderColor = _panelColor
'		style.Margin=New Recti( -2,-2,2,2 )
		style.Margin = New Recti( 0,0,2,2 )
		style.Padding = New Recti( -2,-2,0,0 )



		'mx2Document
		style=New Style( "mojo.mx2Document" )
		style.SetImage( "node:icons", Image.Load( "asset::mojox/ui-icons.png" ) )
		style.DefaultFont=_defaultMonoFont
		style.Padding=New Recti( -4,-4,4,4 )
'		style.BackgroundColor=_contentColor
		style.BackgroundColor=_borderColor
		style.DefaultColor = new Color( .8, .8, .5 )

		'TreeView
'		style=New Style( "mojo.TreeView" )
'		style.SetImage( "node:expanded",Image.Load( "asset::mojox/treenode_expanded.png" ) )
'		style.SetImage( "node:collapsed",Image.Load( "asset::mojox/treenode_collapsed.png" ) )
'		style.BackgroundColor=_contentColor
'		style.DefaultColor=_textColor



		'imageView
		style=New Style( "mojo.ImageView" )
		style.SetImage( "node:buttons", Image.Load( "asset::mojox/ui-buttons.png" ) )
		
		
		
		'FileBrowser
		style=New Style( "mojo.FileBrowser",Style.GetStyle( "mojo.TreeView" ) )


		
		'TextView
		style=New Style( "mojo.TextView" )
		style.SetImage( "node:icons", Image.Load( "asset::mojox/ui-icons.png" ) )
		style.DefaultFont=_defaultMonoFont
		style.Padding=New Recti( -4,-4,4,4 )
'		style.BackgroundColor=_contentColor
		style.BackgroundColor=_borderColor
		style.DefaultColor = _textColor


		
		'Dialog
		style=New Style( "mojo.Dialog" )
		style.Border=New Recti( -1,-1,1,1 )
		style.BackgroundColor=_panelColor
		style.BorderColor=_borderColor
		
		'DialogTitle
		style=New Style( "mojo.DialogTitle",Style.GetStyle( "mojo.Label" ) )
		style.BackgroundColor=_knobColor
		
		style=New Style( "mojo.DialogContent" )
		style.Padding=New Recti( -8,-8,8,4 )
		
		style=New Style( "mojo.DialogActions" )
		style.Padding=New Recti( -8,-4,8,4 )


		
		'ToolBar
		style=New Style( "mojo.ToolBar",Style.GetStyle( "mojo.MenuBar" ) )
		style.Padding=New Recti( -2,-2,4,4 )
		style.BackgroundColor=_panelColor

		'toolbar button
'		style=New Style( "mojo.ToolButton",Style.GetStyle( "mojo.Buttonjl" ) )
'		style.Padding=New Recti( -2,-2,4,4 )
'		style.Border = New Recti( -4,0,20,20 )

		style=New Style( "mojo.ToolButton",Style.GetStyle( "mojo.Button" ) )
'		style.BackgroundColor=_toolColor

'		state=style.AddState( "disabled" )
'		state.DefaultColor=_toolColor

'		state=style.AddState( "hover" )
'		state.BackgroundColor=_hoverColor
		
'		state=style.AddState( "active" )
'		state.BackgroundColor=_activeColor



		
		'Separator
		style=New Style( "mojo.Separator" )
		style.Padding=New Recti( 0,0,1,1 )
		style.Border=New Recti( -8,-8,7,7 )
		style.BackgroundColor=_lineColor

		
		'TextField
		style=New Style( "mojo.TextField",Style.GetStyle( "mojo.TextView" ) )
'		style.Padding=New Recti( -2,-2,20,2 )
'		style.Padding=New Recti( -2,-2,2,2 )
'		style.Margin=New Recti( -2,-2,2,2 )
	End


	
	Method LoadIcons:Image[]( path:String, size:Int )
		'print "load icon="+path+" size="+size
    
		Local pixmap := Pixmap.Load( path )
		If Not pixmap Return Null
		
'		print "-ok"
		
		Local n := pixmap.Width/size
		
		Local icons := New Image[n]
		
		For Local i := 0 Until n
			icons[i] = New Image( pixmap.Window( i*size, 0, size, pixmap.Height ) )
		Next
		
		Return icons
	End



	Private


	
	Field _name:String
	Field _fontSize:Int
	Field _monoFontSize:Int
	
	Field _textColor:Color
	Field _defaultFont:Font
	Field _defaultMonoFont:Font
	
	Field _disabledColor:Color
	Field _clearColor:Color
	Field _contentColor:Color
	Field _panelColor:Color
	Field _gutterColor:Color
	Field _borderColor:Color
	Field _lineColor:Color
	Field _knobColor:Color
	Field _hoverColor:Color
	Field _activeColor:Color
	
	Field _transparentColor:Color
	Field _selectColor:Color
	Field _selectColorT:Color
	Field _selectColorH:Color
	Field _backgroundColor:Color
	Field _selectColor2:Color
	Field _toolColor:Color
	
End