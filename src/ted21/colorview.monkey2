
Namespace ted2




Class ColorView Extends DockingView

 
  
  
  
  
  
  
	Class ColorButtons Extends DockingView
		Method New( caller:ColorView )
			_caller = caller
'      Clicked = Lambda()
 '       action.Trigger()
'      End

			_actionUse = New Action( "Use" )
			_actionUse.Triggered = Lambda()
				caller.UseButtonChanged()
'        print "use"
			End
			_colorUse = New Buttonx( _actionUse, "", 125, 40)

      
			_actionClose = New Action( "close" )
			_actionClose.Triggered = Lambda()
				caller.CloseButtonChanged()
'        print "close"
			End
			_colorClose = New Buttonx( _actionClose, "", 75, 40)
 
			Local findBar := New DockingView
    
			findBar.AddView( _colorUse, "left")
			findBar.AddView( _colorClose, "left")

			AddView( findBar, "top" )
		End Method


     
	Protected    


'    Method OnRender( canvas:Canvas ) Override
  '    Local currentColor := New Color( _red, _green, _blue )
  '    _colorMain.Text = _text
  '    Local red:= currentColor.R
  '    Local green:= currentColor.G
  '    Local blue:= currentColor.B
      
  '    Local ypos:Int = 1
      
 '     canvas.Color = Color.Blue
 '     canvas.DrawRect( 0,0, 10,10 )
  '    ypos = DrawColorBlock( canvas, ypos, 60, red, green, blue, 0, 4)
 '   End
    
	Private
		Field _caller:DockingView
		Field _colorUse:Buttonx
		Field _colorClose:Buttonx

		Field _actionUse:Action
		Field _actionClose:Action

	End
  
  
	Field UseColor:Void()
	Field CloseColor:Void()


	Method New()
		_actionMain = New Action( "main" )
		_actionMain.Triggered = Lambda()
			_selected = 4
			UpdateButtons()
		End
		_colorMain = New Buttonx( _actionMain, "", 200, 64)
		
		_action0 = New Action( "0" )
		_action0.Triggered = Lambda()
			_selected = 0
			UpdateButtons()
		End
		_color0 = New Buttonx( _action0, "", 200, 29)

		_action1 = New Action( "1" )
		_action1.Triggered = Lambda()
			_selected = 1
			UpdateButtons()
		End
		_color1 = New Buttonx( _action1, "", 200, 28)

		_action2 = New Action( "2" )
		_action2.Triggered = Lambda()
			_selected = 2
			UpdateButtons()
		End
		_color2 = New Buttonx( _action2, "", 200, 28)

		_action3 = New Action( "3" )
		_action3.Triggered = Lambda()
			_selected = 3
			UpdateButtons()
		End
		_color3 = New Buttonx( _action3, "", 200, 28)

		_action4 = New Action( "4" )
		_action4.Triggered = Lambda()
			_selected = 4
			UpdateButtons()
		End
		_color4 = New Buttonx( _action4, "", 200, 28)

		_action5 = New Action( "5" )
		_action5.Triggered = Lambda()
			_selected = 5
			UpdateButtons()
		End
		_color5 = New Buttonx( _action5, "", 200, 28)

		_action6 = New Action( "6" )
		_action6.Triggered = Lambda()
			_selected = 6
			UpdateButtons()
		End
		_color6 = New Buttonx( _action6, "", 200, 28)

		_action7 = New Action( "7" )
		_action7.Triggered = Lambda()
			_selected = 7
			UpdateButtons()
		End
		_color7 = New Buttonx( _action7, "", 200, 28)

		_action8 = New Action( "8" )
		_action8.Triggered = Lambda()
			_selected = 8
			UpdateButtons()
		End
		_color8 = New Buttonx( _action8, "", 200, 28)
		
		_actionButtons = New Action( "buttons" )
		_actionButtons.Triggered = Lambda()
			print "buttons"
'      _selected = 8
 '     UpdateButtons()
		End
		_buttons = New ColorButtons( Self )
		

		_colorTree = New ColorTree
		_colorTree.NodeClicked = Lambda( cnode:ColorTreeView.Node, event:MouseEvent )
'     print "here "+_colorTree.SelectedIndex
			If _colorTree.SelectedIndex < 0 then Return
			_text = _colorTree.Label
			_red = _colorTree.Red
			_green = _colorTree.Green
			_blue = _colorTree.Blue
			_redSelect = _colorTree.Red
			_greenSelect = _colorTree.Green
			_blueSelect = _colorTree.Blue
			
'			print "ok "+_red+" "+_green+" "+_blue
		end
		

		Local findBar := New DockingView
	
		findBar.AddView( _colorMain, "top")
		findBar.AddView( _color0, "top")
		findBar.AddView( _color1, "top")
		findBar.AddView( _color2, "top")
		findBar.AddView( _color3, "top")
		findBar.AddView( _color4, "top")
		findBar.AddView( _color5, "top")
		findBar.AddView( _color6, "top")
		findBar.AddView( _color7, "top")
		findBar.AddView( _color8, "top")
		
		findBar.AddView( _buttons, "top")

		findBar.AddView( _colorTree, "top")
		'findBar.ContentView = _findField

		AddView( findBar, "top" )
  
	End


  
	Method CloseButtonChanged()
		CloseColor()
		'    print "called close"
	End Method
	
	
	
	Method UseButtonChanged()
		UseColor()
		'    print "called use"
	End Method



	Method UpdateButtons()
		_colorMain.Selected = (_selected = 4)
	
		_color0.Selected = (_selected = 0)
		_color1.Selected = (_selected = 1)
		_color2.Selected = (_selected = 2)
		_color3.Selected = (_selected = 3)
		_color4.Selected = (_selected = 4)
		_color5.Selected = (_selected = 5)
		_color6.Selected = (_selected = 6)
		_color7.Selected = (_selected = 7)
		_color8.Selected = (_selected = 8)
	
	End Method

	Property RGB:String()
		local ret:String = _redSelect
		ret = ret.Left(4)
		ret = ret.Right(3)
		local str:string = _greenSelect
		str = str.Left(4)
		str = str.Right(3)
		ret = ret + ", "+str
		str = _blueSelect
		str = str.Left(4)
		str = str.Right(3)
		ret = ret + ", "+str
	
		return ret
	end 


Protected


	Property Red:Float()
		Return _redSelect
	End


	Property Green:Float()
		Return _greenSelect
	End


	Property Blue:Float()
		Return _blueSelect
	End



	Method DrawColorBlock:int( canvas:Canvas, ypos:Int, height:Int, red:Float, green:Float, blue:Float, difference:Float, nSelect:int)
		red = Clamp(red + difference, 0.0, 1.0)
		green = Clamp(green + difference, 0.0, 1.0)
		blue = Clamp(blue + difference, 0.0, 1.0)
    
		If nSelect = _selected Then
			_redSelect = red
			_greenSelect = green
			_blueSelect = blue
		End If
    
		Local bright:Float = (red + green + blue) * 0.333

		canvas.Color = New Color( red, green, blue )
		canvas.DrawRect( 4,ypos, Width-5,height )
		
		If bright > 0.45 Then
			canvas.Color = Color.Black
		Else
			canvas.Color = Color.White
		End If
		
		Local txt:string
		Local str:String = red
		str = str.Left(4)
		str = str.Right(3)
		txt = str + ", "
		str = green
		str = str.Left(4)
		str = str.Right(3)
		txt = txt + str + ", "
		str = blue
		str = str.Left(4)
		str = str.Right(3)
		txt = txt + str
		
		canvas.DrawText( txt, 10, ypos + height - 20 )

		if difference = 0 and height = 28 then
			canvas.DrawText( _text, Width - 35 - (_text.Length*6), ypos + height - 20 )
			canvas.DrawText( _text, Width - 36 - (_text.Length*6), ypos + height - 20 )
		end if
		
		Return ypos + height
	  End Method
  
  
  
	Method OnRender( canvas:Canvas ) Override
		Local currentColor := New Color( _red, _green, _blue )
		_colorMain.Text = _text
		Local red:= currentColor.R
		Local green:= currentColor.G
		Local blue:= currentColor.B
    
		Local ypos:Int = 1
    
		canvas.Color = currentColor
		ypos = DrawColorBlock( canvas, ypos, 60, red, green, blue, 0, 4)
		ypos += 4

		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, 0.6, 0)
		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, 0.45, 1)
		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, 0.3, 2)
		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, 0.15, 3)
		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, 0, 4)
		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, -0.15, 5)
		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, -0.3, 6)
		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, -0.45, 7)
		ypos = DrawColorBlock( canvas, ypos, 28, red, green, blue, -0.6, 8)
		
		canvas.Color = New Color( 0.15,0.15,0.15 )
		canvas.DrawRect( 4,ypos, Width - 5,40 )

		canvas.Color = New Color( _redSelect, _greenSelect, _blueSelect )
		canvas.DrawRect( 12,ypos+8, 24,24 )

		canvas.Color = Color.White
		canvas.DrawText( "Use Color", 50, ypos +12)
		canvas.DrawText( "Close", 146, ypos +12)
		
		ypos += 40
	  End 


Private
	Field _text:String = "Red"
	Field _red:Float = 1
	Field _green:Float = 0
	Field _blue:Float = 0
	Field _redSelect:Float = 1
	Field _greenSelect:Float = 0
	Field _blueSelect:Float = 0
	
	Field _selected:Int = -1
	
	Field _buttons:ColorButtons
	Field _actionButtons:Action
	
	Field _colorTree:ColorTree
	Field _actionList:Action

	Field _colorMain:Buttonx
	Field _color0:Buttonx
	Field _color1:Buttonx
	Field _color2:Buttonx
	Field _color3:Buttonx
	Field _color4:Buttonx
	Field _color5:Buttonx
	Field _color6:Buttonx
	Field _color7:Buttonx
	Field _color8:Buttonx

	  Field _actionMain:Action
	  Field _action0:Action
	  Field _action1:Action
	  Field _action2:Action
	  Field _action3:Action
	  Field _action4:Action
	  Field _action5:Action
	  Field _action6:Action
	  Field _action7:Action
	  Field _action8:Action
end






Class ColorTree Extends ColorTreeView



	Class Node Extends ColorTreeView.Node
    'looks like this is never called ?
		Method New( page:String, parent:ColorTreeView.Node, tree:HelpTree )
			Super.New( page, NODEKIND_NONE, parent )

			_page = page
		End



		Method New( label:string, red:float, green:float, blue:float, parent:ColorTreeView.Node, index:int )
			Super.New( "", NODEKIND_COLOR, parent )

			      Index = index
			      Label = label
			      'Red = red
			      'Green = green
      '
		end 
    
 
 
 		
		Property Page:String()
			Return _page
		End


		
	Private
		


		Field _page:String
	End


	
	Method New() 'beginning of the tree
		RootNodeVisible = False
		RootNode.Expanded = True

		New ColorTreeView.Node( "Black", 0,0,0, RootNode, 0 )
		New ColorTreeView.Node( "DarkGrey", .25,.25,.25, RootNode, 204 )
		New ColorTreeView.Node( "Grey", .5,.5,.5, RootNode, 1 )
		New ColorTreeView.Node( "LightGrey", .75,.75,.75, RootNode, 205 )
		New ColorTreeView.Node( "White", 1,1,1, RootNode, 2 )
		New ColorTreeView.Node( "Red", 1,0,0, RootNode, 3 )
		New ColorTreeView.Node( "Brown", .7,.4,.1, RootNode, 203 )
		New ColorTreeView.Node( "Orange", 1,.5,0, RootNode, 4 )
		New ColorTreeView.Node( "Yellow", 1,1,0, RootNode, 5 )
		New ColorTreeView.Node( "Lime", .7,1,0, RootNode, 6 )
		New ColorTreeView.Node( "Green", 0,1,0, RootNode, 7 )
		New ColorTreeView.Node( "Pine", 0,0.5,0, RootNode, 200 )
		New ColorTreeView.Node( "Aqua", 0,.9,.4, RootNode, 8 )
		New ColorTreeView.Node( "Cyan", 0,1,1, RootNode, 9 )
		New ColorTreeView.Node( "Sky", 0,.5,1, RootNode, 10 )
		New ColorTreeView.Node( "Blue", 0,0,1, RootNode, 11 )
		New ColorTreeView.Node( "Steel", .2,.2,.7, RootNode, 201 )
		New ColorTreeView.Node( "Violet", .7,0,1, RootNode, 12 )
		New ColorTreeView.Node( "Magenta", 1,0,1, RootNode, 13 )
		New ColorTreeView.Node( "Puce", 1,0,.4, RootNode, 14 )
		New ColorTreeView.Node( "Skin", .8,.5,.6, RootNode, 202 )
		
		_ui = New ColorTreeView.Node( "User Interface", NODEKIND_PALETTE, RootNode )
		New ColorTreeView.Node( "UICharcoal", .24,.23,.23, _ui, 15 )
		New ColorTreeView.Node( "UISilver", .74,.73,.73, _ui, 16 )
		New ColorTreeView.Node( "UITeal", .18,.65,.52, _ui, 17 )
		New ColorTreeView.Node( "UILightGreen", .32,.80,.31, _ui, 18 )
		New ColorTreeView.Node( "UIVibrantGreen", .09,.87,.07, _ui, 19 )
		New ColorTreeView.Node( "UIGreen", .2,.6,.19, _ui, 20 )
		New ColorTreeView.Node( "UILime", .54,.74,.14, _ui, 21 )
		New ColorTreeView.Node( "UIOrange", .86,.61,.13, _ui, 22 )
		New ColorTreeView.Node( "UIBurntOrange", .79,.31,0, _ui, 23 )
		New ColorTreeView.Node( "UIDarkOrange", .42,.16,.09, _ui, 24 )
		New ColorTreeView.Node( "UIBrown", .62,.31,.01, _ui, 25 )
		New ColorTreeView.Node( "UIMango", .94,.78,.1, _ui, 26 )
		New ColorTreeView.Node( "UIYellow", .89,.87,.01, _ui, 27 )
		New ColorTreeView.Node( "UIRed", .89,.07,.01, _ui, 28 )
		New ColorTreeView.Node( "UIMagenta", .99,.01,.59, _ui, 29 )
		New ColorTreeView.Node( "UIPink", .90,.44,.72, _ui, 30 )
		New ColorTreeView.Node( "UIPurple", .61,.36,.72, _ui, 31 )
		New ColorTreeView.Node( "UILavender", .51,.58,.93, _ui, 32 )
		New ColorTreeView.Node( "UICyan", .24,.63,.83, _ui, 33 )
		New ColorTreeView.Node( "UIBlue", .0,.4,.9, _ui, 34 )
		New ColorTreeView.Node( "UIFontBlue", .11,.57,.96, _ui, 35 )
		New ColorTreeView.Node( "UIPaleBlue", .57,.77,.86, _ui, 36 )
		
		_pico = New ColorTreeView.Node( "Pico", NODEKIND_PALETTE, RootNode, -1 )
		New ColorTreeView.Node( "PicoBlack", .1,.1,.1, _pico, 37 )
		New ColorTreeView.Node( "PicoBrown", .67,.32,.21, _pico, 38 )
		New ColorTreeView.Node( "PicoRed", .92,.1,.31, _pico, 39 )
		New ColorTreeView.Node( "PicoCyan", .31,.65,.86, _pico, 40 )
		New ColorTreeView.Node( "PicoBlue", .1,.16,.32, _pico, 41 )
		New ColorTreeView.Node( "PicoDirt", .37,.34,.30, _pico, 42 )
		New ColorTreeView.Node( "PicoOrange", .98,.63,.1, _pico, 43 )
		New ColorTreeView.Node( "PicoPurple", .51,.46,.61, _pico, 44 )
		New ColorTreeView.Node( "PicoMaroon", .49,.14,.32, _pico, 45 )
		New ColorTreeView.Node( "PicoSilver", .76,.76,.77, _pico, 46 )
		New ColorTreeView.Node( "PicoYellow", .96,.92,.18, _pico, 47 )
		New ColorTreeView.Node( "PicoPink", .94,.46,.65, _pico, 48 )
		New ColorTreeView.Node( "PicoGreen", 0,.52,.31, _pico, 49 )
		New ColorTreeView.Node( "PicoWhite", .99,.94,.91, _pico, 50 )
		New ColorTreeView.Node( "PicoLime", .36,.73,.3, _pico, 51 )
		New ColorTreeView.Node( "PicoSkin", .98,.8,.87, _pico, 52 )
		
		_xam = New ColorTreeView.Node( "xamaran", NODEKIND_PALETTE, RootNode, -1 )
		New ColorTreeView.Node( "XamCoral", .95,.26,.21, _xam, 53 )
		New ColorTreeView.Node( "XamPink", .91,.11,.38, _xam, 54 )
		New ColorTreeView.Node( "XamPurple", .61,.15,.69, _xam, 55 )
		New ColorTreeView.Node( "XamViolet", .40,.22,.71, _xam, 56 )
		New ColorTreeView.Node( "XamBlue", .24,.17,.70, _xam, 57 )
		New ColorTreeView.Node( "XamSky", .12,.58,.95, _xam, 58 )
		New ColorTreeView.Node( "XamWater", .01,.66,.95, _xam, 59 )
		New ColorTreeView.Node( "XamAqua", 0,.73,.83, _xam, 60 )
		New ColorTreeView.Node( "XamPine", 0,.58,.53, _xam, 61 )
		New ColorTreeView.Node( "XamGreen", .29,.68,.31, _xam, 62 )
		New ColorTreeView.Node( "XamMint", .54,.76,.29, _xam, 63 )
		New ColorTreeView.Node( "XamLime", .80,.86,.22, _xam, 64 )
		New ColorTreeView.Node( "XamYellow", 1,.92,.23, _xam, 65 )
		New ColorTreeView.Node( "XamPeach", 1,.75,.03, _xam, 66 )
		New ColorTreeView.Node( "XamOrange", 1,.59,.01, _xam, 67 )
		New ColorTreeView.Node( "XamEmber", 1,.38,.13, _xam, 68 )
		New ColorTreeView.Node( "XamBrown", .47,.33,.28, _xam, 69 )
		New ColorTreeView.Node( "XamSilver", .61,.61,.61, _xam, 70 )
		New ColorTreeView.Node( "XamSteel", .37,.49,.54, _xam, 71 )
		
		_vic = New ColorTreeView.Node( "Vic", NODEKIND_PALETTE, RootNode, -1 )
		New ColorTreeView.Node( "VicBlack", .1,.1,.1, _vic, 72 )
		New ColorTreeView.Node( "VicGrey", .61,.61,.61, _vic, 73 )
		New ColorTreeView.Node( "VicWhite", .98,.98,.98, _vic, 74 )
		New ColorTreeView.Node( "VicRed", .74,.14,.2, _vic, 75 )
		New ColorTreeView.Node( "VicLiver", .45,.16,.18, _vic, 76 )
		New ColorTreeView.Node( "VicBlush", .87,.43,.54, _vic, 77 )
		New ColorTreeView.Node( "VicPink", .79,.26,.65, _vic, 78 )
		New ColorTreeView.Node( "VicDirt", .28,.23,.16, _vic, 79 )
		New ColorTreeView.Node( "VicBrown", .64,.39,.13, _vic, 80 )
		New ColorTreeView.Node( "VicKhaki", .67,.61,.2, _vic, 81 )
		New ColorTreeView.Node( "VicOrange", .92,.53,.19, _vic, 82 )
		New ColorTreeView.Node( "VicFire", .92,.27,0, _vic, 83 )
		New ColorTreeView.Node( "VicLemon", 96,.88,.41, _vic, 84 )
		New ColorTreeView.Node( "VicPeach", .98,.70,.4, _vic, 85 )
		New ColorTreeView.Node( "VicPine", .06,.36,.2, _vic, 86 )
		New ColorTreeView.Node( "VicGreen", .26,.53,.1, _vic, 87 )
		New ColorTreeView.Node( "VicLime", .63,.80,.15, _vic, 88 )
		New ColorTreeView.Node( "VicOil", .18,.28,.3, _vic, 89 )
		New ColorTreeView.Node( "VicSea", .07,.5,.49, _vic, 90 )
		New ColorTreeView.Node( "VicAqua", .08,.76,.64, _vic, 91 )
		New ColorTreeView.Node( "VicRoyal", .13,.35,.96, _vic, 92 )
		New ColorTreeView.Node( "VicBlue", 0,.34,.52, _vic, 93 )
		New ColorTreeView.Node( "VicSky", .19,.63,.94, _vic, 94 )
		New ColorTreeView.Node( "VicSteel", .69,.86,.92, _vic, 95 )
		New ColorTreeView.Node( "VicPurple", .20,.16,.59, _vic, 96 )
		New ColorTreeView.Node( "VicViolet", .6,.39,.97, _vic, 97 )
		New ColorTreeView.Node( "VicCandy", .96,.55,.83, _vic, 98 )
		New ColorTreeView.Node( "VicSkin", .95,.72,.56, _vic, 99 )
		
		_extended = New ColorTreeView.Node( "Extended", NODEKIND_PALETTE, RootNode, -1 )
		New ColorTreeView.Node( "ExLightGrey", .75,.75,.75, _extended, 100 )
		New ColorTreeView.Node( "ExDarkGrey", .25,.25,.25, _extended, 101 )
		New ColorTreeView.Node( "ExBrown", .62,.31,0, _extended, 102 )
		New ColorTreeView.Node( "ExTreeTrunk", .31,.23,.17, _extended, 103 )
		New ColorTreeView.Node( "ExLime", .54,.74,.14, _extended, 104 )
		New ColorTreeView.Node( "ExMango", .94,.58,.03, _extended, 105 )
		New ColorTreeView.Node( "ExOrange", .79,.32,0, _extended, 106 )
		New ColorTreeView.Node( "ExPink", .79,.44,.72, _extended, 107 )
		New ColorTreeView.Node( "ExPurple", .41,.13,.48, _extended, 108 )
		New ColorTreeView.Node( "ExLeaf", .2,.6,.2, _extended, 109 )
		New ColorTreeView.Node( "ExYolk", 1,.65,0, _extended, 110 )
		New ColorTreeView.Node( "ExPeach", 1,.8,01, _extended, 111 )
		New ColorTreeView.Node( "ExSand", .94,.87,.7, _extended, 112 )
		New ColorTreeView.Node( "ExWetSand", .73,.66,.48, _extended, 113 )
		New ColorTreeView.Node( "ExNavy", .09,.15,.44, _extended, 114 )
		New ColorTreeView.Node( "ExMorello", .6,.34,.71, _extended, 115 )
		New ColorTreeView.Node( "ExTeal", .22,.43,.5, _extended, 116 )
		New ColorTreeView.Node( "ExSky", .2,.59,.85, _extended, 117 )
		New ColorTreeView.Node( "ExSlime", .18,.8,.44, _extended, 118 )
		New ColorTreeView.Node( "ExMint", .08,.62,.52, _extended, 119 )
		New ColorTreeView.Node( "ExSilver", .74,.76,.76, _extended, 120 )
		New ColorTreeView.Node( "ExGold", .83,.66,.29, _extended, 121 )
		New ColorTreeView.Node( "ExForest", .17,.31,.21, _extended, 122 )
		New ColorTreeView.Node( "ExPlum", .36,.2,.36, _extended, 123 )
		New ColorTreeView.Node( "ExWatermellon", .85,.32,.32, _extended, 124 )
		New ColorTreeView.Node( "ExAvocado", .55,.69,.12, _extended, 125 )
		New ColorTreeView.Node( "ExBubblegum", .83,.36,.61, _extended, 126 )
		New ColorTreeView.Node( "ExMaroon", .47,.18,.16, _extended, 127 )
		New ColorTreeView.Node( "ExCoffee", .55,.44,.36, _extended, 128 )
		New ColorTreeView.Node( "ExLavender", .6,.67,.83, _extended, 129 )
		New ColorTreeView.Node( "ExPowder", .72,.78,.94, _extended, 130 )
		New ColorTreeView.Node( "ExPigeon", .22,.29,.5, _extended, 131 )
		New ColorTreeView.Node( "ExUmber", .7,.53,.0, _extended, 132 )
		New ColorTreeView.Node( "ExBuff", .84,.77,.64, _extended, 133 )
		New ColorTreeView.Node( "ExCobble", .47,.38,.33, _extended, 134 )
		New ColorTreeView.Node( "ExAqua", .59,.67,.68, _extended, 135 )
		New ColorTreeView.Node( "ExSewer", .78,.78,.59, _extended, 136 )
		New ColorTreeView.Node( "ExDragon", .80,.38,0.5, _extended, 137 )
		New ColorTreeView.Node( "ExEmber", .74,.47,.34, _extended, 138 )
		New ColorTreeView.Node( "ExOlive", .52,.6,.1, _extended, 139 )
		New ColorTreeView.Node( "ExCorn", .91,.8,.32, _extended, 140 )
		New ColorTreeView.Node( "ExHoney", .95,.48,.59, _extended, 141 )
		New ColorTreeView.Node( "ExPhlox", .52,.25,.51, _extended, 142 )
		New ColorTreeView.Node( "ExKhaki", .56,.56,.39, _extended, 143 )
		New ColorTreeView.Node( "ExNougat", .83,.73,.62, _extended, 144 )


	End






Private


	Field _ui:ColorTreeView.Node
	Field _pico:ColorTreeView.Node
	Field _vic:ColorTreeView.Node
	Field _extended:ColorTreeView.Node
	Field _xam:ColorTreeView.Node

	
End class
