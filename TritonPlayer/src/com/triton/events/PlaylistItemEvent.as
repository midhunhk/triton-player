package com.triton.events
{
import com.sndbar.vo.TrackVO;

import flash.events.Event;

/**
 * The PlaylistItemS Event will be thrown when a PlayListItem
 * component is double clicked upon, or a remove event is thrown.
 */
public class PlaylistItemEvent extends Event
{
	//-------------------------------------------------------------------------
	//
	//	Constants
	//
	//-------------------------------------------------------------------------	
	public static const PLAYLIST_ITEM_REMOVED:String  = "playlistItemRemoved";
	public static const PLAYLIST_ITEM_SELECTED:String = "playlistItemSelected";
	
	//-------------------------------------------------------------------------
	//
	//	Variables
	//
	//-------------------------------------------------------------------------
	public var trackVo:TrackVO;
	
	//-------------------------------------------------------------------------
	//
	//  Constructor
	//
	//-------------------------------------------------------------------------
	public function PlaylistItemEvent(type:String, trackVo:TrackVO)
	{
		super(type, true);
		
		// Save the track index
		this.trackVo = trackVo;
	}
	
}

}