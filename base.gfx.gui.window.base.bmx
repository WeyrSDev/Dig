Rem
	===========================================================
	GUI Window
	===========================================================
End Rem
SuperStrict
Import "base.gfx.gui.panel.bmx"


Type TGUIWindowBase Extends TGUIPanel
	Field guiCaptionTextBox:TGUITextBox
	Field guiCaptionArea:TRectangle
	Global defaultCaptionColor:TColor = null

	Method Create:TGUIWindowBase(pos:TPoint, dimension:TPoint, limitState:String = "")
		Super.CreateBase(pos, dimension, limitState)

		'create background, setup text etc.
		InitContent(dimension.GetX(), dimension.GetY())

		GUIManager.Add(Self)
		Return Self
	End Method


	Method InitContent(width:Int, height:Int)
		If Not guiBackground
			SetBackground( new TGUIBackgroundBox.Create(null, null) )
		Else
			guiBackground.rect.position.SetXY(0,0)
			guiBackground.resize(width, height)
		EndIf
		'set another panel background
		guiBackground.spriteBaseName = "gfx_gui_window"

		SetCaption("Window")
		guiCaptionTextBox.SetFont( GetBitmapFont("Default", 16, BOLDFONT) )

		guiBackground.SetZIndex(0) 'absolute background of all children
		guiCaptionTextBox.SetZIndex(1)
	End Method


	'overwrite default to reapply caption/value to reposition them
	Method onStatusAppearanceChange:int()
		if guiCaptionTextBox
			Local rect:TRectangle = Null
			'if an area was defined - use this instead of an automatic area
			If guiCaptionArea
				rect = guiCaptionArea
			Else
				'automatic calculation: vertical center the caption between
				'                       0 and the start of content
				'                       but to make it visible in all cases
				'                       use "max(...)".
				Local padding:TRectangle = guiBackground.GetSprite().GetNinePatchContentBorder()
				rect = new TRectangle.Init(padding.GetLeft(), 0, GetContentScreenWidth(), Max(25, padding.GetTop()))
			EndIf

			'reposition in all cases
			guiCaptionTextBox.rect.position.SetXY(rect.GetX(), rect.GetY())
			guiCaptionTextBox.resize(rect.GetW(), rect.GetH())
		endif

	End Method


	Method SetCaptionArea(area:TRectangle)
		guiCaptionArea = area.copy()
	End Method


	'override for different alignment
	Method SetValue(value:String="")
		Super.SetValue(value)
		If guiTextBox Then guiTextBox.SetValueAlignment("LEFT", "TOP")
	End Method


	Method SetCaption:Int(caption:String="")
		If caption=""
			If guiCaptionTextBox
				guiCaptionTextBox.remove()
				guiCaptionTextBox = Null
			EndIf
		Else
			If Not guiCaptionTextBox
				'create the caption container
				guiCaptionTextBox = New TGUITextBox.Create(new TPoint, new Tpoint, caption, "")

				If defaultCaptionColor
					guiCaptionTextBox.SetValueColor(defaultCaptionColor)
				Else
					guiCaptionTextBox.SetValueColor(TColor.clWhite)
				EndIf
				guiCaptionTextBox.SetValueAlignment("CENTER", "CENTER")
				guiCaptionTextBox.SetAutoAdjustHeight(False)
				guiCaptionTextBox.SetZIndex(1)
				'set to ignore parental padding (so it starts at 0,0)
				guiCaptionTextBox.SetOption(GUI_OBJECT_IGNORE_PARENTPADDING, True)

				'we handle it
				addChild(guiCaptionTextBox)
			EndIf

			'assign new caption
			guiCaptionTextBox.value = caption

			'manually call reposition function
			onStatusAppearanceChange()
		EndIf
	End Method


	Method SetCaptionAndValue:Int(caption:String="", value:String="")
		SetCaption(caption)
		SetValue(value)

		Local oldTextboxHeight:Float = guiTextBox.rect.GetH()
		Local newTextboxHeight:Float = guiTextBox.getHeight()

		'resize window
		Self.resize(0, rect.getH() + newTextboxHeight - oldTextboxHeight)
		Return True
	End Method
End Type