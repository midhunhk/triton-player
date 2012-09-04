package com.triton.utils
{
import com.sndbar.vo.TrackVO;
import com.triton.vo.SettingsVO;

import mx.collections.ArrayCollection;

/**
 * Utility class with static methods
 */
public class Utils
{
	
	/**
	 * @private
	 */
	private static const scrollerTextLimit:int = 42;
	
	//---------------------------------------------------------------------
	//
	// Methods
	//
	//---------------------------------------------------------------------
	
	/**
	 * Method to return a formatted string corresponding to the number
	 * of seconds passed to it
	 * @param	timeInSeconds	Time in seconds to be formatted
	 */
	public static function formatTimeString(timeInSeconds:Number):String
	{
		var date:Date = new Date(null, null, 0, 0, 0, timeInSeconds, 0);
		
		var secs:int 	= date.getSeconds();
		var mins:int 	= date.getMinutes()
		var hours:int 	= date.getHours();			
		
		var hours_str:String = "";
		var mins_str:String = mins.toString();
		if(hours > 0){
			hours_str = hours + ":";
			if(mins < 10)
				mins_str = "0" + mins;
		}
		
		var secs_str:String = (secs < 10)? "0" + secs : secs.toString();
		var timeString:String = hours_str + mins_str + ":" + secs_str;
		return timeString;
	}
	
	/**
     * Method to get an array collection out of an Object
     * @param	item	Object that has to be made into an array collection
     */ 
    public static function getArrayCollection(item:Object):ArrayCollection
    {
		var arrayCollection:ArrayCollection;
		
		if(item == null){
			arrayCollection = null;
		}
		else if(item is ArrayCollection){
			arrayCollection =  item as ArrayCollection;
		}
		else{
			arrayCollection = new ArrayCollection();
			arrayCollection.addItem(item);
		}
		return arrayCollection;
	}
	
	/**
	 * Method to get an array collection of TrackVos from the xmlData passed
	 * @param xmlData The xml data
	 */
	public static function getPlaylistFromXML(xmlData:XML):ArrayCollection
	{
		var playlistColl:ArrayCollection = new ArrayCollection();
		
		if(xmlData != null && xmlData.track != null)
		{
			for each(var item:XML in xmlData.track)
			{
				var trackVo:TrackVO = new TrackVO();
				trackVo.title = item.title;
				trackVo.artist = item.artist;
				trackVo.album = item.album;
				trackVo.trackUrl = item.trackUrl;
				trackVo.duration = item.duration;
				playlistColl.addItem(trackVo);
			}
		}
		return playlistColl;
	}
	
	/**
	 * Method to get the playlist collection into XML format
	 * @param playlistColl The playlist collection
	 */
	public static function getPlaylistAsXML(playlistColl:ArrayCollection):XML
	{
		var xmlPlaylist:XML = <TritonPlaylist></TritonPlaylist>;
		if(playlistColl)
		{
			for(var i:int = 0; i < playlistColl.length; i++){
				var trackVo:TrackVO = playlistColl[i] as TrackVO;
				
				var xmlTrack:XML = <track></track>
				xmlTrack.title = getVal(trackVo.title);
				xmlTrack.artist = getVal(trackVo.artist);
				xmlTrack.album = getVal(trackVo.album);
				xmlTrack.trackUrl = trackVo.trackUrl;
				xmlTrack.duration = trackVo.duration;
				
				xmlPlaylist.track[i] = xmlTrack;
			}
		}
		return xmlPlaylist;
	}
	
	/**
	 * Utility method to check for null in the value passed 
	 */
	private static function getVal(data:String):String{
		if(data == null)
			return "";
		return data;
	}
	
	/**
	 * Method to get the SettingsVo from the xmlData passed
	 * @param xmlData The xml data 
	 */
	public static function getSettingsFromXML(xmlData:XML):SettingsVO
	{
		var settingsVo:SettingsVO = new SettingsVO();
		if(xmlData!=null)
		{
			settingsVo.x = xmlData.x;
			settingsVo.y = xmlData.y;
			settingsVo.width = xmlData.width;
			settingsVo.height = xmlData.height;
			settingsVo.volume = xmlData.volume;
			settingsVo.locale = xmlData.locale;
			settingsVo.visualizationIndex = xmlData.visualizationIndex;
			
			settingsVo.lastBrowsedDirectoryPath = xmlData.lastBrowsedDirectoryPath;
			
			var transpString:String = xmlData.isWindowTransparent;
			if(transpString.indexOf("true") >= 0)
				settingsVo.transparentWindow = true;
			else if(transpString.indexOf("false") >=0)
				settingsVo.transparentWindow = false;
			
			var compactString:String = xmlData.isCompactMode;
			if(compactString.indexOf("true") >= 0)
				settingsVo.isCompactMode = true;
			else if(transpString.indexOf("false") >=0)
				settingsVo.isCompactMode = false;
			
			var loopOnEndString:String = xmlData.loopOnEnd;
			if(loopOnEndString.indexOf("true") >= 0)
				settingsVo.loopOnEnd = true;
			else if(transpString.indexOf("false") >=0)
				settingsVo.loopOnEnd = false;
				
			var minimizeToTrayString:String = xmlData.minimizeToTray;
			if(minimizeToTrayString.indexOf("true") >= 0)
				settingsVo.minimizeToTray = true;
			else if(transpString.indexOf("false") >=0)
				settingsVo.minimizeToTray = false;
		}
		else
		{
			// Assign default values
			settingsVo.width = 390;
			settingsVo.height = 520;					
			settingsVo.x = 700;
			settingsVo.y = 260;
			settingsVo.volume = 1;
			settingsVo.minimizeToTray = true;
			settingsVo.transparentWindow = true;
			settingsVo.visualizationIndex = 0;
		}	
		return settingsVo;
	}
	
	/**
	 * This method returns in XML format the SettingsVo that is passed on
	 * @param settingsVo
	 */
	public static function getSettingsXML(settingsVo:SettingsVO):XML
	{		
		var xmlSettings:XML = <TritonPlayer></TritonPlayer>;
		xmlSettings.x = settingsVo.x;
		xmlSettings.y = settingsVo.y;
		xmlSettings.width = settingsVo.width;
		xmlSettings.height = settingsVo.height;
		xmlSettings.volume = settingsVo.volume;
		xmlSettings.locale = settingsVo.locale;
		xmlSettings.loopOnEnd = settingsVo.loopOnEnd;
		xmlSettings.isCompactMode = settingsVo.isCompactMode;
		xmlSettings.minimizeToTray = settingsVo.minimizeToTray;
		xmlSettings.visualizationIndex = settingsVo.visualizationIndex;
		xmlSettings.isWindowTransparent = settingsVo.transparentWindow;			
		xmlSettings.lastBrowsedDirectoryPath = settingsVo.lastBrowsedDirectoryPath;
		return xmlSettings;
	}
	
	/**
	 * Method that parses the passed in array collection and returns a
	 * collection of track objects
	 */
	public static function getPlaylistAsCollection(coll:ArrayCollection)
		:ArrayCollection
	{
		var returnColl:ArrayCollection = new ArrayCollection();
		var loopLimit:int = coll.length;
		
		for(var loop:int = 0; loop <loopLimit; loop++)
		{
			var trackVo:TrackVO = new TrackVO();
			trackVo.title = coll[loop].title;
			trackVo.artist = coll[loop].artist;
			trackVo.album = coll[loop].album;
			trackVo.trackUrl = coll[loop].trackUrl;
			trackVo.albumArtUrl = coll[loop].albumArtUrl;
			trackVo.duration = coll[loop].duration;
			returnColl.addItem(trackVo);
		}
		return returnColl;
	}
	
	/**
	 * Method that shuffles an array collection and returns
	 */
	public static function getShuffledCollection(baseColl:ArrayCollection)
		:ArrayCollection
	{
		var arr:Array = baseColl.source;
		var arr2:Array = [];

		while (arr.length > 0) {
		    arr2.push(arr.splice(Math.round(Math.random() * (arr.length - 1)), 1)[0]);
		}
		
		var coll:ArrayCollection = new ArrayCollection(arr2);
		return coll;
	}
	
	/**
	 * Method to compare to array collections and returns an array 
	 * collection with the difference objects
	 * Returns (Coll1 - Coll2)
	 */
	public static function compareArrayCollections(coll1:ArrayCollection, 
		coll2:ArrayCollection):ArrayCollection
	{			
		var returnColl:ArrayCollection = new ArrayCollection();			
		for(var loop:int = 0; loop < coll1.length; loop++)
		{
			if(coll2.contains(coll1[loop]) == false)
				returnColl.addItem(coll1[loop]);
		}	
		return returnColl;
	}
	
	/**
	 * This method returns the scroller text from the trackVo
	 */
	public static function getScrollerText(trackVo:TrackVO):String
	{
		var scrollerText:String = "***";
		var trackDetails:String = "";
		
		if(trackVo.artist)
			trackDetails = trackVo.artist + " - ";
		trackDetails += trackVo.title
		if(trackDetails.length > scrollerTextLimit)
			trackDetails = trackDetails.substr(0, scrollerTextLimit) + "...";
			
		scrollerText += trackDetails;
		scrollerText += " (" + 
			formatTimeString( trackVo.duration ) + ") ***";
		return scrollerText;
	}
	
	/**
	 * This method returns the tool tip that is displayed in the sys tray tooltip
	 */
	public static function getSysTrayToolTip(trackVo:TrackVO):String
	{
		var toolTip:String = "";
		if(trackVo.artist != null && trackVo.artist != "")
			toolTip = trackVo.artist + " - ";
		toolTip += trackVo.title;			
		return toolTip;
	}
	
	/**
	 * This method returns the index of an item in an array of objects
	 */
	public static function getItemIndexInArray(array:Array, itemName:String, 
		propName:String = "data"):int
	{
		for(var i:int = 0; i <array.length; i++)
		{
			var obj:Object = array[i];
			if(obj[propName] == itemName)
				return i;
		}
		return -1;
	} 
	
}
}