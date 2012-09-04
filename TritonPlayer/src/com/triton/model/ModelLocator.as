package com.triton.model
{
import com.triton.custom.ScrollingText;
import com.triton.utils.SpeakerModes;

import flash.filesystem.File;

import mx.collections.ArrayCollection;

/**
 * The ModelLocator class
 */
[Bindable]
public class ModelLocator
{
	protected static var instance:ModelLocator;
	
	/**
	 * Constructor
	 */
	public function ModelLocator()
	{
		if(instance){
			throw new Error("Singleton already instantiated");
		}
	}
	
	/**
	 * This function returns the only instance of this class that is 
	 * used in this application.
	 */
	public static function getInstance():ModelLocator
	{
		if(instance == null)
			instance = new ModelLocator();
			
		return instance;
	}
	
	public const APPLICATION_TITLE:String 	= "TritonPlayer 1.3";
	public const BUILD_NUMBER:String 		= "1368"
	
	//-----------------------------
	// Shared Variables
	//-----------------------------
	
	public var isWindowTransparent:Boolean;
	public var loopOnEnd:Boolean 			= false;
	public var isPlayerMinimized:Boolean 	= false;
	public var isModalWindowVisible:Boolean = false;
	public var isCompactMode:Boolean 		= false;
	public var minimizeToTray:Boolean 		= true;
	
	public var scrollingTextInstance:ScrollingText = null
	
	public var visualizationIndex:Number;
	public var tempItemCount:int 	= 0;
	public var itemsReadCount:int 	= 0;
	public var tempColl:ArrayCollection = null;
	
	public var currentTheme:String;
	public var currentLocale:String;
	public var currentSpeakerState:String = SpeakerModes.SPEAKER_ON;
	public var lastLoadedPlaylistPath:String;
	public var lastBrowsedFolder:File;
}

}