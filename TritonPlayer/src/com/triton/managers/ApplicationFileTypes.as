package com.triton.managers
{
/**
 * The ApplicationFileTypes class specifies constants
 * used by the ApplicationFileManager class
 */
public class ApplicationFileTypes
{
	/**
	 * Specifies the Settings xml file
	 * This is the file till version 1.1
	 */
	public static const SETTINGS_XML_FILE:String 		= "settings.xml";
	
	/**
	 * Specifies the default playlist file
	 * 
	 */
	public static const PLAYLIST_XML_FILE:String 		= "default.tpl";
	
	/**
	 * Specifies the settings object file
	 * Introduced in version 1.2
	 */
	public static const SETTINGS_OBJ_FILE:String 		= "triton.settings";

	/**
	 * Specifies the Playlist file extension.
	 */
	public static const PLAYLIST_FILE_EXTENSION:String 	= "tpl";
	
	/**
	 * Specifies the track file extension.
	 */
	public static const TRACK_FILE_EXTENSION:String 	= "mp3";
}
}