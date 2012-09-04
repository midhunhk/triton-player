package com.triton.custom
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when a change in playlist manager occurs
 * 
 *  @eventType com.triton.events.PlaylistEvent.PLAYLIST_PLAY_CHANGE
 */
[Event(name="playlistPlayChange", type="com.triton.events.PlaylistEvent")]

/**
 *  Dispatched when a change in playlist manager occurs
 * 
 *  @eventType com.triton.events.PlaylistEvent.PLAYLIST_CHANGE
 */
[Event(name="playlistChange", type="com.triton.events.PlaylistEvent")]

/**
 *  Dispatched when a stop event occurs
 * 
 *  @eventType com.triton.events.PlaylistEvent.PLAYLIST_STOP
 */
[Event(name="playlistStop", type="com.triton.events.PlaylistEvent")]

/**
 *  Dispatched when playlist becomes empty
 * 
 *  @eventType com.triton.events.PlaylistEvent.PLAYLIST_RESET
 */
[Event(name="playlistReset", type="com.triton.events.PlaylistEvent")]

/**
 *  Dispatched when a file has been loaded into the playlist.
 *  This will be indicated to show the progress of loading files.
 * 
 *  @eventType com.triton.events.PlaylistEvent.FILE_LOADED
 */
[Event(name="fileLoaded", type="com.triton.events.PlaylistEvent")]

/**
 *  Dispatched when playing in shuffled mode
 * 
 *  @eventType com.triton.events.PlaylistEvent.PLAYLIST_SHUFFLED
 */
[Event(name="playlistShuffled", type="com.triton.events.PlaylistEvent")]

/**
 *  Dispatched when in pause mode
 * 
 *  @eventType com.triton.events.PlaylistEvent.PLAYLIST_PAUSED
 */
[Event(name="playlistPaused", type="com.triton.events.PlaylistEvent")]

/**
 *  Dispatched when in mute mode changes
 * 
 *  @eventType com.triton.events.PlaylistEvent.PLAYLIST_MUTE_CHANGE
 */
[Event(name="playlistMuteChange", type="com.triton.events.PlaylistEvent")]

/**
 *  Dispatched when user toggles between compact and normal mode
 * 
 *  @eventType com.triton.events.TritonPlayerEvent.COMPACT_MODE
 */
[Event(name="compactMode", type="com.triton.events.TritonPlayerEvent")]

/**
 * The CustomEventDispatcher class
 */
public class CustomEventDispatcher
{
	
	protected static var instance:CustomEventDispatcher;
	
	private var eventDispatcher:IEventDispatcher;
	
	public function CustomEventDispatcher(target:IEventDispatcher=null)
	{
		eventDispatcher = new EventDispatcher(target);
	}
	
	/**
	 * Instantiates the Singleton and returns the instance
	 */
	public static function getInstance():CustomEventDispatcher
	{
		if(instance == null)
			instance = new CustomEventDispatcher();
		return instance;
	}
	
	/**
	 * Dispatches the event
	 */
	public function dispatchEvent(event:Event):Boolean
	{
		return eventDispatcher.dispatchEvent(event);
	}
	
	/**
	 * Adds an event listner
	 */
	public function addEventListener(type:String, listener:Function, useCapture:Boolean  = false, priority:int = 0, 
		useWeakReference:Boolean  = false):void
	{
		eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	/**
	 * Removes an event listner
	 */
	public function removeEventListener(type:String, listener:Function, useCapture:Boolean  = false):void
	{
		eventDispatcher.removeEventListener(type, listener, useCapture);
	}

}

}