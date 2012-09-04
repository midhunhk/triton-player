package com.triton.events
{
import flash.events.Event;

/**
 * The events that are thrown by the PlaylistManager Class
 */
public class PlaylistEvent extends Event
{
	//-------------------------------------------------------------------------
	//
	//	Constants
	//
	//-------------------------------------------------------------------------
	
	public static var PLAYLIST_PLAY_CHANGE:String 	= "playlistPlayChange";
	public static var PLAYLIST_MUTE_CHANGE:String 	= "playlistMuteChange";
	public static var PLAYLIST_PAUSED:String 		= "playlistPaused";
	public static var PLAYLIST_CHANGE:String 		= "playlistChange";
	public static var PLAYLIST_STOP:String 			= "playlistStop";
	public static var PLAYLIST_RESET:String 		= "playlistReset";
	public static var PLAYLIST_SHUFFLED:String 		= "playlistShuffled";
	public static var FILE_LOADED:String 			= "fileLoaded"; 
	
	//-------------------------------------------------------------------------
	//
	//  Constructor
	//
	//-------------------------------------------------------------------------
	public function PlaylistEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
	
}

}