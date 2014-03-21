package com.triton.managers
{
import com.sndbar.events.PlayerEvent;
import com.sndbar.events.TimerTickEvent;
import com.sndbar.player.AudioPlayer;
import com.sndbar.player.PlayerMode;
import com.sndbar.vo.TrackVO;
import com.triton.custom.CustomEventDispatcher;
import com.triton.events.PlaylistEvent;
import com.triton.events.PlaylistItemEvent;
import com.triton.model.ModelLocator;
import com.triton.utils.Utils;

import mx.collections.ArrayCollection;

/**
 * An instance of PlaylistManager manages the playlist and other state data
 *
 * This class manages the state of the playlist as well as being a Facade to
 * the AudioPlayer object that does the real work of playing an audio file
 */
public class PlaylistManager
{
	//-------------------------------------------------------------------------
	//
	//	Variables
	//
	//-------------------------------------------------------------------------
	
	/**
	 * @protected
	 * The singleton instance
	 */
	protected static var instance:PlaylistManager;
	
	/**
	 * @private
	 * Keeps track of the current playing track
	 */
	private var currentPlayingTrackIndex:int = 0;	
	
	/**
	 * @private 
	 * The array Collection that holds the playlist
	 */
	private var playlistColl:ArrayCollection;
	
	/**
	 * @private 
	 * The array Collection that holds the unsorted playlist
	 */
	private var tempPlaylistColl:ArrayCollection;
	
	/**
	 * @private 
	 * Whether the player is in shuffled mode
	 */
	private var isShuffledMode:Boolean;
	
	/**
	 * @private
	 * Whether the playlist is being shuffled or not
	 */
	private var isShuffling:Boolean;
	
	/**
	 * @private
	 */
	private var model:ModelLocator;
	
	/**
	 * @private
	 * The AudioPlayer instance
	 */
	private var audioPlayer:AudioPlayer;
	
	/**
	 * @private
	 */
	private var customEventDispatcher:CustomEventDispatcher;
	
	//-------------------------------------------------------------------------
	//
	//	Constructor
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function PlaylistManager(enforcer:SingletonEnforcer)
	{
		if(enforcer == null)
		{
			throw new Error("PlaylistManager already instantiated");
		}
		
		// Instantiate private members
		isShuffledMode 			= false;
		isShuffling				= false;
		audioPlayer 			= new AudioPlayer();
		model 					= ModelLocator.getInstance();
		customEventDispatcher 	= CustomEventDispatcher.getInstance();
		
		// Register Events
		customEventDispatcher.addEventListener(PlaylistItemEvent.PLAYLIST_ITEM_SELECTED, onPlaylistItemSelect);
		customEventDispatcher.addEventListener(PlaylistItemEvent.PLAYLIST_ITEM_REMOVED, onPlaylistItemRemove);
		
		audioPlayer.addEventListener(PlayerEvent.SOUND_COMPLETE, onSoundComplete);
		audioPlayer.addEventListener(TimerTickEvent.TIMER_TICK, onTimerComplete);
		audioPlayer.addEventListener(PlayerEvent.PLAYER_MODE_CHANGED, onPlayerModeChange);
	}
	
	/**
	 * This function returns the only instance of the 
	 * PlaylistManager available 
	 */
	public static function getInstance():PlaylistManager
	{
		if(instance == null)
			instance = new PlaylistManager(new SingletonEnforcer());
		return instance;
	}
	
	/**
	 * Handler function that is invoked when a playlist item is selected
	 */
	private function onPlaylistItemSelect(event:PlaylistItemEvent):void
	{
		playTrackFromVo(event.trackVo);
	}
	
	/**
	 * Handler function that is invoked when a playlist item is removed
	 */
	private function onPlaylistItemRemove(event:PlaylistItemEvent):void
	{
		removeItemFromPlaylist(event.trackVo);
	}
	
	/**
	 * Handler function invoked when the audioPlayer has completed playing 
	 * a track. Decides what to do next.
	 */
	private function onSoundComplete(event:PlayerEvent):void
	{
		if(currentPlayingTrackIndex < getPlaylistLength() -1 )
			playNextTrack();
		else if(model.loopOnEnd == true)
			playNextTrack();
		else
			stopPlay();
	}
	
	/**
	 * Handler function that is invoked when the audioPlayer has started
	 * playing a track.
	 */
	private function onPlayerModeChange(event:PlayerEvent):void
	{
		// Check the current player mode
		if(event.playerMode == PlayerMode.PLAYER_PLAY)
		{
			// Dispatch the PlayChange event
			var playlistEvent:PlaylistEvent = 
				new PlaylistEvent(PlaylistEvent.PLAYLIST_PLAY_CHANGE);
			customEventDispatcher.dispatchEvent(playlistEvent);
			if(model.scrollingTextInstance.running == false)
				model.scrollingTextInstance.start();
		}
	}
	
	/**
	 * Function to listen to Timer events thrown by the AudioPlayer
	 */
	private function onTimerComplete(event:TimerTickEvent):void
	{
		customEventDispatcher.dispatchEvent(event);
	}
	
	//-------------------------------------------------------------------------
	//
	//	Public methods for playing files
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Play a track based on the current track index
	 */
	public function playCurrentTrack():void
	{
		playTrackWithIndex(currentPlayingTrackIndex);
	}
	
	/**
	 * Play a track with a specified index
	 */
	public function playTrackWithIndex(index:int):void
	{
		if(playlistColl != null && playlistColl.length > 0)
		{			
			var currentTrack:TrackVO = getTrackVo(index);
			if(audioPlayer && currentTrack)
			{
				if(audioPlayer.currentPlayerMode == PlayerMode.PLAYER_PLAY)
					audioPlayer.stopPlayer();
				
				audioPlayer.playSoundWithFilePath(currentTrack.trackUrl);
				currentPlayingTrackIndex = index;
			}
		}
	}
	
	/**
	 * Toggle between a shuffled and normal playlist.
	 */
	public function playInShuffledMode():void
	{
		if(playlistColl != null && playlistColl.length > 0 && !isShuffling)
		{
			// Synchronize this block 
			isShuffling = true;
			var currentTrack:TrackVO = getCurrentTrackVo();
			if(isShuffledMode == true)
			{
				// Revert to normal mode
				playlistColl = new ArrayCollection(tempPlaylistColl.source);
				tempPlaylistColl = null;
				isShuffledMode = false;
			}
			else
			{
				// Backup the playlistColl 
				tempPlaylistColl = new ArrayCollection(playlistColl.toArray());
				// Create a tempColl which will be shuffled
				var tempColl:ArrayCollection = 
					new ArrayCollection(playlistColl.source);
				// Set the shuffledColl as playlistColl
				playlistColl = Utils.getShuffledCollection(tempColl);
				isShuffledMode = true;
			}
			
			if(audioPlayer.currentPlayerMode == PlayerMode.PLAYER_PLAY)
			{
				currentPlayingTrackIndex = getTrackIndex(currentTrack)
			}
			
			isShuffling = false;
			
			// Dispatch the event to the listeners
			customEventDispatcher.dispatchEvent( 
				new PlaylistEvent(PlaylistEvent.PLAYLIST_SHUFFLED));
		}
	}
	
	/**
	 * This method is used to play a track when the track's ValueObject is known
	 */
	public function playTrackFromVo(trackVo:TrackVO):void
	{
		// Find out the position of the trackvo in the playlist coll
		if(playlistColl != null)
		{
			for(var i:int = 0; i < playlistColl.length; i++)
			{
				if(playlistColl[i] == trackVo)
				{
					playTrackWithIndex(i);					
					break;					
				}
			}
		}
	}
	
	/**
	 * Play the current track from a position
	 */
	public function playTrackFromPosition(percPosition:Number, 
		continuePlaying:Boolean):void
	{
		// position value in milliseconds
		var position:int =  audioPlayer.trackLength * percPosition * 10;
		audioPlayer.pausePlayer();
		audioPlayer.setPausePosition(position);
		if(continuePlaying)
		{
			playCurrentTrack();
		}
	}
	
	/**
	 * Stop the player
	 */
	public function stopPlay():void
	{
		if(audioPlayer)
			audioPlayer.stopPlayer();
		model.scrollingTextInstance.stop();
		customEventDispatcher.dispatchEvent( 
			new PlaylistEvent(PlaylistEvent.PLAYLIST_STOP));
	}
	
	/**
	 * Pause the current track
	 */
	public function pausePlay():void
	{
		if(audioPlayer)
			audioPlayer.pausePlayer();
		customEventDispatcher.dispatchEvent( 
			new PlaylistEvent(PlaylistEvent.PLAYLIST_PAUSED));	
	}
	
	/**
	 * Plays the next track in the playlist
	 */
	public function playNextTrack():void
	{
		if(playlistColl != null)
		{
			var nextTrack:int = (currentPlayingTrackIndex + 1) % playlistColl.length;
			if(audioPlayer){
				audioPlayer.stopPlayer();
				audioPlayer.resetPausePosition();
			}
			playTrackWithIndex(nextTrack);
		}
	}
	
	/**
	 * Plays the previous track in the playlist
	 */
	public function playPreviousTrack():void
	{
		if(playlistColl != null)
		{
			var prevTrack:int = (currentPlayingTrackIndex - 1);
			if(prevTrack < 0)
				prevTrack = playlistColl.length -1;
			if(audioPlayer){
				audioPlayer.stopPlayer();
				audioPlayer.resetPausePosition();
			}
			playTrackWithIndex(prevTrack);
		}
	}
	
	//-------------------------------------------------------------------------
	//
	// Public Methods for exposing audioPlayer methods
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Returns the Current Player mode.
	 */
	public function getCurrentPlayerMode():String
	{
		return audioPlayer.currentPlayerMode;
	}
	
	/**
	 * Resets the audio players pause position
	 */
	public function resetPausePosition():void
	{
		audioPlayer.resetPausePosition();
	}
	
	/**
	 * This method can be called to set the pausePosition
	 */
	public function setPausePosition(value:Number):void
	{
		audioPlayer.setPausePosition(value);
	}
	
	/**
	 * This method will return the current position of the play head
	 * in seconds.
	 */
	public function getCurrentPosition():Number
	{
		return audioPlayer.getCurrentPosition();
	}
	
	/**
	 * This method can be used to set the volume parameter
	 */
	public function setCurrentVolume(value:Number):void
	{
		audioPlayer.setCurrentVolume(value);
	}
	
	/**
	 * Returns the current value for volume
	 */
	public function getCurrentVolume():Number
	{
		return audioPlayer.getCurrentVolume();
	}
	
	/*
	 * Returns the current track length
	 */
	public function getTrackLength():int
	{
		return audioPlayer.trackLength;
	}
	
	//-------------------------------------------------------------------------
	//
	// Public Methods for managing the playlist
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Append a trackVo to the playlist
	 */
	public function addItemToPlaylist(trackVo:TrackVO):void
	{
		if(playlistColl == null)
			playlistColl = new ArrayCollection();
		playlistColl.addItem(trackVo);
		
		// Add this track to the original arrayColl
		if(isShuffledMode)
			tempPlaylistColl.addItem(trackVo);
		customEventDispatcher.dispatchEvent( 
			new PlaylistEvent(PlaylistEvent.PLAYLIST_CHANGE));
	}
	
	/**
	 * This method will append a collection of trackVo's to the 
	 * current playlist collection
	 */
	public function addPlaylistCollection(coll:ArrayCollection):void
	{
		if(playlistColl == null)
			playlistColl = new ArrayCollection();
		
		for(var i:uint = 0; i <coll.length; i++)
			playlistColl.addItem( coll[i] as TrackVO );
			
		customEventDispatcher.dispatchEvent( 
			new PlaylistEvent(PlaylistEvent.PLAYLIST_CHANGE));
	}
	
	/**
	 * This method will clear the playlist 
	 */
	public function clearPlaylist():void
	{
		playlistColl = null;
		customEventDispatcher.dispatchEvent( 
			new PlaylistEvent(PlaylistEvent.PLAYLIST_RESET));
	}
	
	/**
	 * This method will remove a track from the playlist collection
	 */
	public function removeItemFromPlaylist(trackVo:TrackVO):void
	{
		if(playlistColl != null)
		{
			for(var i:uint = 0; i < playlistColl.length; i++)
			{
				if(playlistColl[i] == trackVo)
				{
					playlistColl.removeItemAt(i);
					customEventDispatcher.dispatchEvent( 
						new PlaylistEvent(PlaylistEvent.PLAYLIST_CHANGE));
					break;
				}
			}
		}
	}
	
	//-------------------------------------------------------------------------
	//
	// Public Methods for retrieving data
	//
	//-------------------------------------------------------------------------
	
	/**
	 * This method returns the current playing TrackVo
	 * Returns null if collection is empty
	 */
	public function getCurrentTrackVo():TrackVO
	{
		if(playlistColl!=null && playlistColl.length > 0)
			return playlistColl[currentPlayingTrackIndex];
		return null;
	}
	
	/**
	 * This method returns the track index of the current
	 * playing track
	 */
	public function getCurrentTrackIndex():int
	{
		return currentPlayingTrackIndex;
	}
	
	/**
	 * This method sets the current track index
	 */
	public function setCurrentTrackIndex(trackIndex:int):void
	{
		if(playlistColl && trackIndex >= 0 && trackIndex < playlistColl.length)
		{
			currentPlayingTrackIndex = trackIndex;
		}
	}
	
	/**
	 * This method returns the TrackVo in the needed position
	 */
	public function getTrackVo(index:int):TrackVO
	{
		if(index >= 0 && playlistColl != null && index < playlistColl.length)
			return playlistColl[index];
		return null;
	}
	
	/**
	 * This method returns a copy of the playlist collection.
	 * Returns null if playlistCollection is empty
	 */
	public function getPlaylistColl():ArrayCollection
	{
		if(playlistColl)
			return new ArrayCollection(playlistColl.source);
		return null;
	}
	
	/**
	 * This method returns the length of the playlist collection
	 * Safer than doing getPlaylistColl().length which may return null
	 */
	public function getPlaylistLength():int
	{
		if(playlistColl)
			return playlistColl.length;
		return 0;
	}
	
	/**
	 * This method returns the index of the trackVo in the playlist coll
	 */
	public function getTrackIndex(trackVo:TrackVO):int
	{
		if(playlistColl)
			return playlistColl.getItemIndex(trackVo);
		return -1;
	}
	
	/**
	 * This methid returns the value of whether shuffled 
	 * mode is on or not
	 */
	public function isShuffledPlay():Boolean
	{
		return isShuffledMode;
	}

}
	
}
class SingletonEnforcer
{}
