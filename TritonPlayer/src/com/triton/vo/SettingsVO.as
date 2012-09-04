package com.triton.vo
{
/**
 * SettingsVO
 */
[RemoteClass]
[Bindable]
public class SettingsVO
{
	/**
	 * @private
	 */
	private var _x:int;
	private var _y:int;
	private var _width:int;
	private var _height:int;
	private var _locale:String;
	private var _volume:Number;
	private var _loopOnEnd:Boolean;
	private var _isCompactMode:Boolean;
	private var _minimizeToTray:Boolean;
	private var _transparentWindow:Boolean;
	private var _visualizationIndex:Number;
	private var _lastBrowsedDirectoryPath:String;
	
	private var _trackIndex:int;
	private var _trackPosition:int;
	
	private var _currentTheme:String;
	private var _playlistScrollPos:uint;
	
	/**
	 * @public
	 * Setters and Getters
	 */
	 
	//-----------------------------
	// x
	//-----------------------------
	public function set x(value:int):void{
		_x = value;
	}		
	public function get x():int{
		return _x;
	}
	
	//-----------------------------
	// y
	//-----------------------------
	public function set y(value:int):void{
		_y = value;
	}		
	public function get y():int{
		return _y;
	}

	//-----------------------------
	// width
	//-----------------------------
	public function set width(value:int):void{
		_width = value;
	}		
	public function get width():int{
		return _width;
	}
	
	//-----------------------------
	// height
	//-----------------------------
	public function set height(value:int):void{
		_height = value;
	}		
	public function get height():int{
		return _height;
	}
	
	//-----------------------------
	// volume
	//-----------------------------
	public function set volume(value:Number):void{
		_volume = value;
	}		
	public function get volume():Number{
		return _volume;
	}
	
	//-----------------------------
	// locale
	//-----------------------------
	public function set locale(value:String):void{
		_locale = value;
	}		
	public function get locale():String{
		return _locale;
	}
	
	//-----------------------------
	// loopOnEnd
	//-----------------------------
	public function set loopOnEnd(value:Boolean):void{
		_loopOnEnd = value;
	}
	public function get loopOnEnd():Boolean{
		return _loopOnEnd;
	}
	
	//-----------------------------
	// isCompactMode
	//-----------------------------
	public function set isCompactMode(value:Boolean):void{
		_isCompactMode = value;
	}
	public function get isCompactMode():Boolean{
		return _isCompactMode;
	}
	
	//-----------------------------
	// minimizeToTray
	//-----------------------------
	public function set minimizeToTray(value:Boolean):void{
		_minimizeToTray = value;
	}
	public function get minimizeToTray():Boolean{
		return _minimizeToTray;
	}
	
	//-----------------------------
	// transparentWindow
	//-----------------------------
	public function set transparentWindow(value:Boolean):void{
		_transparentWindow = value;
	}
	public function get transparentWindow():Boolean{
		return _transparentWindow;
	}
	
	//-----------------------------
	// lastBrowsedDirectoryPath
	//-----------------------------
	public function set lastBrowsedDirectoryPath(value:String):void{
		_lastBrowsedDirectoryPath = value;
	}
	public function get lastBrowsedDirectoryPath():String{
		if(_lastBrowsedDirectoryPath == null)
			return "";
		return _lastBrowsedDirectoryPath;
	}
	
	//-----------------------------
	// visualizationIndex
	//-----------------------------
	public function set visualizationIndex(value:Number):void{
		_visualizationIndex = value;
	}
	public function get visualizationIndex():Number{
		return _visualizationIndex;
	}
	
	//-----------------------------
	// trackIndex
	//-----------------------------
	public function set trackIndex(value:Number):void{
		_trackIndex = value;
	}
	public function get trackIndex():Number{
		return _trackIndex;
	}
	
	//-----------------------------
	// trackPosition
	//-----------------------------
	public function set trackPosition(value:Number):void{
		_trackPosition = value;
	}
	public function get trackPosition():Number{
		return _trackPosition;
	}
	
	//---------------------------------
	// currentTheme
	//---------------------------------
	public function set currentTheme(value:String):void{
		_currentTheme = value;
	}
	public function get currentTheme():String{
		return _currentTheme;
	}
	
	//---------------------------------
	// playlistScrollPos
	//---------------------------------
	public function set playlistScrollPos(value:uint):void{
		_playlistScrollPos = value;
	}
	public function get playlistScrollPos():uint{
		return _playlistScrollPos;
	}
}
}