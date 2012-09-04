package com.triton.events
{
import com.triton.vo.SettingsVO;

import flash.events.Event;

/**
 * The TritonPlayerEvent class defines the events used by the
 * TritonPlayer
 */
public class TritonPlayerEvent extends Event
{
	//-------------------------------------------------------------------------
	//
	//  Constants
	//
	//-------------------------------------------------------------------------	
	public static const COMPACT_MODE:String 		 = "compactMode";
	public static const KEY_PRESSED:String 			 = "keyPressed";
	public static const MENU_SELECTED:String 		 = "menuSelected";
	public static const SETTINGS_LOADED:String 		 = "settingsLoaded";
	
	public static const HIDE_MODAL_WINDOW:String 		= "hideModalWindow";
	public static const CLOSE_BUTTON_PRESSED:String 	= "closeButtonPressed";
	public static const RESTORE_BUTTON_PRESSED:String  	= "restoreButtonPressed";
	public static const MINIMIZE_BUTTON_PRESSED:String 	= "minimizeButtonPressed";
	
	//-------------------------------------------------------------------------
	//
	//  Variables
	//
	//-------------------------------------------------------------------------
	public var keyCode:uint;
	public var selectedMenu:String;
	public var settingsVo:SettingsVO;
	
	//-------------------------------------------------------------------------
	//
	//  Constructor
	//
	//-------------------------------------------------------------------------
	
	public function TritonPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
	
}
}