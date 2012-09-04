package com.triton.managers
{
import flash.events.IEventDispatcher;
	
import mx.styles.StyleManager;
	
/**
 * 
 */
public class ThemeManager
{
	//-------------------------------------------------------------------------
	//
	//	Constants
	//
	//-------------------------------------------------------------------------
	
	private static var themeLocations:Array;
	private static var currentTheme:String;
	
	//-------------------------------------------------------------------------
	//
	//	Methods
	//
	//-------------------------------------------------------------------------
	
	public function ThemeManager():void
	{
		
	}
	
	private static function initThemes():void
	{
		themeLocations = new Array();
		themeLocations[TritonThemes.ORANGE] = "/resources/themes/Orange.swf";
		themeLocations[TritonThemes.GREEN]  = "/resources/themes/Green.swf";
	}
	
	public static function getCurrentTheme():String
	{
		return currentTheme;
	}
	
	/**
	 * This method loads a theme for the application based on
	 * the parameter theme passed in.
	 */
	public static function loadApplicationTheme(theme:String):IEventDispatcher
	{
		// initialize the themes if not yet initialized
		if(themeLocations == null)
		{
			initThemes();
		}
		
		// Validate the value for theme
		currentTheme = theme ? theme : TritonThemes.DEFAULT;
		
		switch(currentTheme)
		{
			case TritonThemes.ORANGE:
			case TritonThemes.GREEN :
				return StyleManager.loadStyleDeclarations(
					themeLocations[currentTheme], true);
		}
		return null;
	}

}
}