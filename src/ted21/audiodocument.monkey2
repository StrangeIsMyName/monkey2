
Namespace ted21


const _pureNotes := New float[] (
	16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87, 
	32.70, 34.65, 36.71, 38.89, 41.20, 43.65, 46.25, 49.00, 51.91, 55.00, 58.27, 61.74, 
	65.41, 69.30, 73.42, 77.78, 82.41, 87.31, 92.50, 98.00, 103.8, 110.0, 116.5, 123.5, 
	130.8, 138.6, 146.8, 155.6, 164.8, 174.6, 185.0, 196.0, 207.7, 220.0, 233.1, 246.9, 
	261.6, 277.2, 293.7, 311.1, 329.6, 349.2, 370.0, 392.0, 415.3, 440.0, 466.2, 493.9, 
	523.3, 554.4, 587.3, 622.3, 659.3, 698.5, 740.0, 784.0, 830.6, 880.0, 932.3, 987.8, 
	1047, 1109, 1175, 1245, 1319, 1397, 1480, 1568, 1661, 1760, 1865, 1976, 
	2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951, 
	4186, 4435, 4699, 4978, 5274, 5588, 5920, 6272, 6645, 7040, 7459, 7902 )

global _notes := New Float[9, 17]
		

Class AudioDocumentView Extends View

	Field _timer:Timer


	Method New( doc:AudioDocument )
		Local j:Int
		Local k:Int
				
		Local freq:Float
		Local count:Int = 0

		
		For k = 0 To 8
			For j = 0 To 11
				freq = _pureNotes[count]
				_notes[k, j] = freq/220
				If j < 5 _notes[k, j+12] = freq/110
''				PureNote[count] = freq/220
				count = count + 1
			Next
		Next	

		_doc = doc

		Layout = "fill"
		
		Style.BackgroundColor = new Color(.1, .1, .1)'App.Theme.GetColor( "content" )
		
		If Not _chan _chan = New Channel
		
		_timer = New Timer(10, OnUpdate)
	End


	
Protected


	
	Method OnLayout() Override
'		_toolBar.Frame=Rect
	End


	
	Method GetSample:Float( channel:Int, length:int, index:Int  )
		Select _doc.Data.Format
			Case AudioFormat.Mono8
				Return _doc.Data.Data[index]/128.0-1
			Case AudioFormat.Stereo8
				Return _doc.Data.Data[index*2+(channel&1)]/128.0-1
			Case AudioFormat.Mono16
				Return Cast<Short Ptr>( _doc.Data.Data )[index]/32767.0
			Case AudioFormat.Stereo16
				Return Cast<Short Ptr>( _doc.Data.Data )[index*2+(channel&1)]/32767.0
		End Select
		
		Return 0
	End


	Method DrawWaveform( canvas:Canvas, x:int, y:int, width:float, height:float)
		Local data := _doc.Data

		Local halfHeight:float = height * .5
		Local quarterHeight:float = height * .25
		Local quarterHeight2:float = height - quarterHeight
		Local last:float
		Local curr:float
		Local last2:float
		Local curr2:float
		Local sample:float
		Local xpos:int
		
		
'		Print halfHeight+" "+quarterHeight
		
		Local chan:int = 0
		Local stereo:bool = False
		Local bits:int = 8
		
		Select _doc.Data.Format
			Case AudioFormat.Stereo8
				stereo =  True
			Case AudioFormat.Mono16
				bits = 16
			Case AudioFormat.Stereo16
				bits = 16
				stereo =  True
		End Select
				
		canvas.Color = new Color( 0, .1, 0 )
		canvas.DrawRect( x, y, width, height )

		If stereo Then
			canvas.Color = Color.Black
			canvas.DrawLine( x, y+halfHeight, x+width, y+halfHeight )
			canvas.Color = Color.White
			canvas.DrawLine( x, y+quarterHeight, x+width, y+quarterHeight )
			canvas.DrawLine( x, y+quarterHeight2, x+width, y+quarterHeight2 )

			canvas.Color = new Color( .39, .69, 0 )
			last = y + quarterHeight
			last2 = y + quarterHeight2
			For xpos = 0 to width-x
'				Print xpos+" "+dataLength+" "+(xpos * widthLength)
				sample = GetSample( 0, data.Length, Float(xpos) / width * data.Length )
				curr =  quarterHeight + y + (quarterHeight * sample)
				sample = GetSample( 1, data.Length, Float(xpos) / width * data.Length )
				curr2 =  quarterHeight2 + y + (quarterHeight * sample)

				If xpos Then
					canvas.DrawLine( xpos-1+x, last, xpos+x, curr )
					canvas.DrawLine( xpos-1+x, last2, xpos+x, curr2 )
				End if
				last = curr
				last2 = curr2
			Next

			_sampleVolume = GetSample( 0, data.Length, _chan.Playhead )
			_sampleVolume2 = GetSample( 1, data.Length, _chan.Playhead )

			Local diff:float = width / data.Length
			
			'Print diff
			xpos = diff * _chan.Playhead
			canvas.Color = Color.White
			canvas.DrawLine( xpos+x, 0, xpos+x, height )
			canvas.Color = Color.Black
			canvas.DrawLine( xpos+x+1, 0, xpos+x+1, height )
		else
			canvas.Color = Color.White
			canvas.DrawLine( x, y+halfHeight, x+width, y+halfHeight )
			
			canvas.Color = new Color( .39, .69, 0 )
			last = halfHeight + y
			
			Local currSample:int
			For xpos = 1 to width-x-1
				currSample = Float(xpos) / width * data.Length
				sample = GetSample( chan, data.Length, currSample )
				curr =  halfHeight + y + (halfHeight * sample)

				canvas.DrawLine( xpos-1+x, last, xpos+x, curr )
				
				last = curr
			Next
			
			_sampleVolume = GetSample( chan, data.Length, _chan.Playhead )

			Local diff:float = width / data.Length
			
			'Print diff
			xpos = diff * _chan.Playhead
			canvas.Color = Color.White
			canvas.DrawLine( xpos+x, 0, xpos+x, height )
			canvas.Color = Color.Black
			canvas.DrawLine( xpos+x+1, 0, xpos+x+1, height )
			
		End if
	End method


	Method CheckVolumePan( mx:int, my:int, x:float, y:float, width:float, height:float)
		If my < 40 Then Return
		
		'pan
		If my < 80 Then
			Local midx:float = width * .5
			Local diff:float = 2 / width
			Local xpos:float = (mx - midx) * diff
			_pan = xpos
			_chan.Pan = _pan
			Return
		End If
		
		'volume
		If my < 90 Then Return
		
		my -= 90
		
		height -= 100
		If my > height Then Return
		
'		Print my +" "
'		Print ((height - my) / (height*0.8))
		_volume = float(height - my) / float(height)
		_chan.Volume = _volume
		'Print _volume
		
	End method
	
	
	Method DrawVolume( canvas:Canvas, title:string, x:int, y:int, width:int, height:int)
		Local data := _doc.Data
		Local dataLength:int = data.Length

		canvas.Color = new Color( .2, .2, .2 )
		canvas.DrawRect( x, y+30, width, height-30 )

		canvas.Color = new Color( .3, .3, .3 )
		canvas.DrawRect( x, y, width, 30 )

		Local midx:int = x + (width * .5)
		
		Local stereo:bool = False
		
		Select _doc.Data.Format
			Case AudioFormat.Stereo8
				stereo =  True
			Case AudioFormat.Stereo16
				stereo =  True
		End Select
		
		'draw volume
		Local yTop:int = y + 80
		Local yHeight:int = height-90
		Local yBottom:int = yTop + yHeight
		Local yVol:float = ( Abs( _sampleVolume ) * _volume )

		canvas.Color = new Color( .1, .1, .1 )

		If stereo Then
			canvas.DrawRect( x+10, yBottom, 24, -height+90 )
			canvas.DrawRect( x+36, yBottom, 24, -height+90 )

			Local yVol2:float = ( Abs( _sampleVolume2 ) * _volume )
			If _sampleVolume > -1 Then
				canvas.Color = Color.UIBlue
				canvas.DrawRect( x+15, yBottom-2, 14, -( yHeight * yVol ) )
				if yVol > _maxVolume Then _maxVolume = yVol
			Else
				_sampleVolume = 0	
			End If
			If _maxVolume > 0.001 Then
				canvas.Color = Color.UIRed
				canvas.DrawRect( x+15, yBottom-( yHeight * _maxVolume )-2, 14, 2 )
			End If
			
			If _sampleVolume2 > -1 Then
				canvas.Color = Color.UIBlue
				canvas.DrawRect( x+41, yBottom-2, 15, -( yHeight * yVol2 ) )
				if yVol2 > _maxVolume2 Then _maxVolume2 = yVol2
			Else
				_sampleVolume2 = 0	
			End If
			If _maxVolume2 > 0.001 Then
				canvas.Color = Color.UIRed
				canvas.DrawRect( x+41, yBottom-( yHeight * _maxVolume2 )-2, 14, 2 )
			End If
		Else
			canvas.DrawRect( x+10, yBottom, 50, -height+90 )
			If _sampleVolume > -1 Then
				canvas.Color = Color.UIBlue
				canvas.DrawRect( x+15, yBottom-2, 40, -( yHeight * yVol ) )
				if yVol > _maxVolume Then _maxVolume = yVol
			Else
				_sampleVolume = 0	
			End If
			If _maxVolume > 0.001 Then
				canvas.Color = Color.UIRed
				canvas.DrawRect( x+15, yBottom-( yHeight * _maxVolume )-2, 40, 2 )
			End If
		End If
		

		'draw volume text
		canvas.Color = Color.LightGrey
		Local ht:float = (height - 11) - (81)
		Local yp:int
		Local xp:int = x + 60

		yp = y + height - 19 - (ht * 1)
		canvas.DrawText( "-100", xp+10, yp )
		yp = y + height - 19 - (ht * .75)
		canvas.DrawText( "- 75", xp+10, yp )
		yp = y + height - 19 - (ht * .5)
		canvas.DrawText( "- 50", xp+10, yp )
		yp = y + height - 19 - (ht * .25)
		canvas.DrawText( "- 25", xp+10, yp )
		yp = y + height - 19 - (ht * 0)
		canvas.DrawText( "-  0", xp+10, yp )

		'draw volume indicator
		yp = y + height - 11 - (ht * _volume)
		canvas.Color = Color.UIBlue
		canvas.DrawLine( xp, yp, xp-50, yp )
		canvas.LineWidth = 4
		canvas.DrawLine( xp, yp, xp+15, yp-10 )
		canvas.DrawLine( xp+15, yp-10, xp+45, yp-10 )
		canvas.DrawLine( xp+45, yp-10, xp+50, yp-5 )
		canvas.DrawLine( xp+50, yp-5, xp+50, yp+5 )
		canvas.DrawLine( xp+50, yp+5, xp+45, yp+10 )
		canvas.DrawLine( xp+45, yp+10, xp+15, yp+10 )
		canvas.DrawLine( xp+15, yp+10, xp, yp )

		'draw pan
		Local pn:float = _pan * (width-15) * .5
		canvas.Color = new Color( .1, .1, .1 )
		canvas.DrawRect( x+10, y+40, width-20, 30 )
		canvas.Color = Color.LightGrey
		canvas.DrawLine( midx, y+40, midx, y+70 )
		canvas.Color = Color.UIBlue
		canvas.DrawLine( midx + pn, y+40, midx + pn, y+70 )


		'the last thing is to draw the new text
		canvas.Color = Color.LightGrey
		canvas.Scale( 1.5, 1.2 ) '<- this sets the matrix
		canvas.DrawText( title, x+10, (y+5)*0.837 )
		
		canvas.ClearMatrix()
	End method
	

	method DrawKey( canvas:Canvas, color:int, text:string, x:float, y:float, width:float, height:float )
		Select color
			Case 0
				canvas.Color = Color.Black
			Case 1
				canvas.Color = new Color( .9, .9, .83 )
			Case 2
				canvas.Color = new Color( 1, 1, .44 )
		End Select
		
		canvas.DrawRect( x, y, width, height )

		Select color
			Case 0
				canvas.Color = Color.White
			Default
				canvas.Color = Color.Black
		End Select

		canvas.DrawText( text, x+10, y+5 )
		
	End method
	
	
	Method DrawKeys( canvas:Canvas, octave:int, note:int, x:float, y:float, width:float, height:float )
		Local ht:float = height / 8
		Local height1:float = ht * 3
		Local height2:float = ht * 6
		Local width1:float = height1 - 5
		Local halfWidth:float = width1 * 0.5
		
		Local xx:float = x + halfWidth
		Local yy:float = y
		
		DrawKey( canvas, 0, "s", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 0, "d", xx, yy, width1, width1 )
		xx += height1 + height1
		DrawKey( canvas, 0, "g", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 0, "h", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 0, "j", xx, yy, width1, width1 )
		xx += height1 + height1
		DrawKey( canvas, 0, "l", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 0, ";", xx, yy, width1, width1 )
		

		xx += height1 * 3
		yy += height1 + height1
		canvas.Color = Color.White
		canvas.DrawText( "Octave Up/Down", xx, yy )
		yy -= height1
		canvas.DrawText( (octave + 1), xx+height1, yy )
		yy -= height1
		DrawKey( canvas, 2, "[", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 2, "]", xx, yy, width1, width1 )

		xx = x
		yy += height1
		DrawKey( canvas, 1, "z", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, "x", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, "c", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, "v", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, "b", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, "n", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, "m", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, ",", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, ".", xx, yy, width1, width1 )
		xx += height1
		DrawKey( canvas, 1, "/", xx, yy, width1, width1 )

		yy += height1
		canvas.Color = Color.White
		canvas.DrawText( "Music Keyboard", x+(height1*3), yy )
	End method
	
	
	Method DrawPiano( canvas:Canvas, octave:int, octaveOffset:int, note:int, x:int, y:int, width:int, height:int )
		canvas.Color = new Color( .9, .9, .83 )
		canvas.DrawRect( x, y, width, height )

		Local oct:Float = Float(width / 8.0)
		Local k:Int
		Local keyheight:Int = Float((height-2) * 0.66666)
		
		Local nt:Float = Float(oct / 7.0)
		Local nt2:Float = nt / 2.0
		Local j:Int
		Local count:Int = 0
		
		Local noteDown:int = -1
		if note > -1 Then
			noteDown = note + (octave + octaveOffset) * 12
		End If
		
		
		'draw highlighted octave
		canvas.Color = new Color( .68, .62, .48 )
		canvas.DrawRect( x + (octave * oct), y, oct+1, height )

		'draw white keypress
		If noteDown > -1 Then
			Local offset:int = -1
			Select note
				Case 0 offset = 0
				Case 2 offset = 1
				Case 4 offset = 2
				Case 5 offset = 3
				Case 7 offset = 4
				Case 9 offset = 5
				Case 11 offset = 6
			End Select
			If offset > -1 and octave + octaveOffset < 8 Then
				canvas.Color = Color.UIBlue'new Color( 0, .55, 0 )
				canvas.DrawRect( x + ( (octave + octaveOffset) * oct) + (offset * nt), y, nt, height )
			End if
		End If
		
		count = 0
		For k = 0 To 7
			Local xx:Float = x + (oct * k) + nt
			Local x1:Float = xx - (nt / 4)
			For j = 0 To 6
				'draw key lines
				If j < 6 Or k < 7 Then
					canvas.Color = Color.DarkGrey
					canvas.DrawLine( xx, y, xx, y + height )
				End If	

				'draw black keys			
				If j = 2 Or j = 6
				Else
					count = count + 1
	
					'black key
					If count = noteDown Then
						canvas.Color = Color.UIBlue'new Color( 0, .55, 0 )
					Else
						canvas.Color = Color.Black
					End If
					canvas.DrawRect( x1, y, nt / 1.5, keyheight )
	
				End If
				
				xx = xx + nt
				x1 = x1 + nt
				count = count + 1
			Next
		Next
	End method
	
	
	
	Method OnUpdate()
		_maxVolume *= 0.8
		_maxVolume2 *= 0.8
'		Local pos:float = _chan.Playhead /_doc.Data.Length
'		_chan.Rate *= 0.95
		
'		Local diff:float = width / data.Length

'		xpos = diff * _chan.Playhead

'		Print _count+" "+_chan.Playhead
'		_count += 1
'		If Keyboard.KeyReleased(Key.Escape) Then instance.Terminate()
'		App.RequestRender()

	End Method


	Method OnRender( canvas:Canvas ) Override
		Local quarterHeight:float = Height * .35
		Local audioHeight:float = Height - quarterHeight
		DrawWaveform( canvas, 0, 0, Width, audioHeight )

		DrawPiano( canvas, _octave, _noteOctave, _note, 140, audioHeight+10, Width - 150, quarterHeight * .5 )
		DrawKeys( canvas, _octave, _note, 140, audioHeight+20+quarterHeight * .5, Width - 150, (quarterHeight * .5) - 30 )

		DrawVolume( canvas, "Master", 10, audioHeight+10, 120, quarterHeight-20 )
	End


	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
			Case EventType.MouseDown
					Local quarterHeight:float = Height * .35
					Local audioHeight:float = Height - quarterHeight
					Local mx:int = event.Location.X
					Local my:int = event.Location.Y

					If mx > 20 And mx < 120 And my > audioHeight+10 Then
						CheckVolumePan( mx-20, my-(audioHeight+10), 20, audioHeight+10, 100, quarterHeight-20 )
					End If
'				if event.Location.X < 16 Then
'			Case EventType.MouseUp
'				_dragging = False
        
			Case EventType.MouseMove
				If Mouse.ButtonDown( MouseButton.Left ) Then
					Local quarterHeight:float = Height * .35
					Local audioHeight:float = Height - quarterHeight
					Local mx:int = event.Location.X
					Local my:int = event.Location.Y

					If mx > 20 And mx < 120 And my > audioHeight+10 Then
						CheckVolumePan( mx-20, my-(audioHeight+10), 20, audioHeight+10, 100, quarterHeight-20 )
					End If
				End If
        
'			Case EventType.MouseWheel
'				Super.OnMouseEvent( event )
'				Return
        
		End Select
		
	End


	Method OnKeyEvent( event:KeyEvent ) Override
		Select event.Type
			Case EventType.KeyUp
				If _note > -1 Then
					_note = -1
					_chan.Stop()
				End If
			Case EventType.KeyRepeat
			Case EventType.KeyDown
				_noteOctave = 0
				Select event.Key
					Case Key.Space
						If _chan.Playing Then
							_chan.Stop()
						Else
							_chan.Pan = _pan
							_chan.Volume = _volume
							_chan.Play( _doc.Sound )
						End If
					Case Key.LeftBracket
						If _octave > 0 Then _octave -= 1
					Case Key.RightBracket
						If _octave < 7 Then _octave += 1
					Case Key.Z
						_note = 0
						_chan.Rate = _notes[_octave, 0]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.S
						_note = 1
						_chan.Rate = _notes[_octave, 1]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.X
						_note = 2
						_chan.Rate = _notes[_octave, 2]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.D
						_note = 3
						_chan.Rate = _notes[_octave, 3]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.C
						_note = 4
						_chan.Rate = _notes[_octave, 4]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.V
						_note = 5
						_chan.Rate = _notes[_octave, 5]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.G
						_note = 6
						_chan.Rate = _notes[_octave, 6]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.B
						_note = 7
						_chan.Rate = _notes[_octave, 7]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.H
						_note = 8
						_chan.Rate = _notes[_octave, 8]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.N
						_note = 9
						_chan.Rate = _notes[_octave, 9]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.J
						_note = 10
						_chan.Rate = _notes[_octave, 10]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.M
						_note = 11
						_chan.Rate = _notes[_octave, 11]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.Comma
						If _octave = 8 Then return
						_note = 0
						_noteOctave = 1
						_chan.Rate = _notes[_octave+1, 0]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.L
						If _octave = 8 Then return
						_note = 1
						_noteOctave = 1
						_chan.Rate = _notes[_octave+1, 1]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.Period
						If _octave = 8 Then return
						_note = 2
						_noteOctave = 1
						_chan.Rate = _notes[_octave+1, 2]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.Semicolon
						If _octave = 8 Then return
						_note = 3
						_noteOctave = 1
						_chan.Rate = _notes[_octave+1, 3]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
					Case Key.Slash
						If _octave = 8 Then return
						_note = 4
						_noteOctave = 1
						_chan.Rate = _notes[_octave+1, 4]
						_chan.Volume = _volume
						_chan.Pan = _pan
						_chan.Play( _doc.Sound )
				End Select
		End Select

	End method

	
Private


	
	field _chan:Channel
	field _volume:float = .8
	field _pan:float = 0
	
	field _sampleVolume:float
	field _maxVolume:float
	field _sampleVolume2:float
	field _maxVolume2:float
	
	field _octave:int = 4
	field _note:int = -1
	field _noteOctave:int = 0
	

	Field _doc:AudioDocument
	
'	Field _count:long = 0	
End



Class AudioDocument Extends Ted2Document

	Method New( path:String )
		Super.New( path )
		
		_view = New AudioDocumentView( Self )
	End


	
	Property Data:AudioData()
		Return _data
	End

	
	Property Sound:Sound()
		If Not _sound _sound = New Sound( _data )
		
		Return _sound
	End

	
Protected

	
	Method OnLoad:Bool() Override
		_data = AudioData.Load( Path )
		If Not _data Return False
		
		Return True
	End


	
	Method OnSave:Bool() Override
		Return False
	End


	
	Method OnClose() Override
		If _sound then _sound.Discard()
		If _data then _data.Discard()
		
		_sound = Null
		_data = Null
	End


	
	Method OnCreateView:AudioDocumentView() Override
		Return _view
	End

	
Private

	Field _view:AudioDocumentView
	
	Field _data:AudioData
	
	Field _sound:Sound

End
