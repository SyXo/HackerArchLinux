import os


class Touchpad :
	def __init__( self ) :
		self.id = ""
		self.props = ""
		self.toggleId = ""
		self.toggleState = ""
		self.tapToggleId = ""
		self.tapToggleState = ""

		self.Username = os.popen( "cat /etc/passwd |grep 1000| awk -F \":\" ' {print $1} ' " ).readline( ).strip( '\n' )

		touchpad = os.popen( "xinput list | awk '/Touchpad/ {print }' " ).readline( )
		touchpad = touchpad.split( )

		for part in touchpad :
			if part.startswith( "id=" ) :
				self.id = part.split( "=" )[ 1 ]

		self._getTouchpadProps( )
		self._getTouchpadToggle( )
		self._getTouchpadTapToggle( )
		self._enableTouchpadTapping( )

	def _getTouchpadProps( self ) :
		self.props = os.popen( "xinput list-props " + self.id ).readlines( )

	def _getTouchpadToggle( self ) :
		for prop in self.props :
			if prop.__contains__( "Device Enabled (" ) :
				indexS = prop.find( '(' ) + 1
				indexE = prop.find( ')' )
				self.toggleId = prop[ indexS : indexE ]
				self.toggleState = prop[ indexE + 2 : ].strip( )
				break

	def _getTouchpadTapToggle( self ) :
		for prop in self.props :
			if prop.__contains__( "Tapping Enabled (" ) :
				indexS = prop.find( '(' ) + 1
				indexE = prop.find( ')' )
				self.tapToggleId = prop[ indexS : indexE ]
				self.tapToggleState = prop[ indexE + 2 : ].strip( )
				break

	def _enableTouchpadTapping( self ) :
		if self.tapToggleState == "0" :
			self.tapToggleState = "1"
			os.system( "xinput set-prop " + self.id + " " + self.tapToggleId + " " + self.tapToggleState )

	def ExportTouchpad( self ) :
		with open( "/home/" + self.Username + "/.config/i3/touchpad-id" , "w+" ) as f :
			f.write( self.id + os.linesep )
			f.write( self.toggleId + os.linesep )
			f.write( self.toggleState + os.linesep )


if __name__ == '__main__' :
	myTouchpad = Touchpad( )
	myTouchpad.ExportTouchpad( )
