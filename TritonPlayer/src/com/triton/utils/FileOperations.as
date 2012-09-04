package com.triton.utils
{
import com.sndbar.events.ID3Event;
import com.sndbar.utils.ID3DataReader;
import com.sndbar.vo.TrackVO;
import com.triton.custom.CustomEventDispatcher;
import com.triton.events.PlaylistEvent;
import com.triton.managers.ApplicationFileTypes;
import com.triton.managers.PlaylistManager;
import com.triton.model.ModelLocator;

import flash.events.Event;
import flash.events.FileListEvent;
import flash.events.IEventDispatcher;
import flash.filesystem.File;
import flash.net.FileFilter;

import mx.collections.ArrayCollection;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

public class FileOperations
{
	//-------------------------------------------------------------------------
	//
	//	Variables
	//
	//-------------------------------------------------------------------------
	
	private var model:ModelLocator;
	private var fileFilter:FileFilter;
	private var playlistFileFilter:FileFilter;
	private var playlistManager:PlaylistManager;	
	private var dir:File = File.documentsDirectory;
	private var file:File = File.documentsDirectory;
	private var eventDispatcher:CustomEventDispatcher;
	private var resourceManager:IResourceManager = ResourceManager.getInstance();

	//-------------------------------------------------------------------------
	//
	//	Constructor
	//
	//-------------------------------------------------------------------------
	
	public function FileOperations()
	{
		model = ModelLocator.getInstance();
		playlistManager	= PlaylistManager.getInstance();
		eventDispatcher = CustomEventDispatcher.getInstance();
		var textTrackFiles:String = 
			resourceManager.getString("resources", "lbl_trackFiles");
		var textPlaylistFiles:String = 
			resourceManager.getString("resources", "lbl_playlistFiles");
		fileFilter = new FileFilter(textTrackFiles + " (*.mp3)","*.mp3");
		playlistFileFilter = 
			new FileFilter(textPlaylistFiles + " (*.tpl)","*.tpl");
	}
	
	//---------------------------------
	// File Operation
	//---------------------------------
	
	public function fileSave():void 
	{
		var textSelectFile:String = 
			resourceManager.getString("resources", "lbl_selectFile");
		file.browseForSave(textSelectFile);
		file.addEventListener(Event.SELECT, onFileSaveSelect);
	}	
	
	public function fileOpen():void 
	{
		var textTrackFiles:String = 
			resourceManager.getString("resources", "lbl_trackFiles");
		var textSelectFiles:String = 
			resourceManager.getString("resources", "lbl_selectFiles");
		fileFilter.description = textTrackFiles;
		file.browseForOpenMultiple(textSelectFiles,[fileFilter]);
		file.addEventListener(FileListEvent.SELECT_MULTIPLE, onMultipleSelect);
	}
	
	public function selectFile():void
	{
		var textPlaylistFiles:String = 
			resourceManager.getString("resources", "lbl_playlistFiles");
		var textSelectPlaylist:String = 
			resourceManager.getString("resources", "lbl_selectPlaylist");
		playlistFileFilter.description = textPlaylistFiles;
		file.browseForOpen(textSelectPlaylist,[playlistFileFilter]);
		file.addEventListener(Event.SELECT, onSelect);
	}
	
	public function dirOpen():void 
	{
		if(null != model.lastBrowsedFolder)
			dir = model.lastBrowsedFolder;
		var textSelectDir:String = 
			resourceManager.getString("resources", "lbl_selectDirectory");
		dir.browseForDirectory(textSelectDir);
		dir.addEventListener(Event.SELECT, onSelectDir);
	}
	
	//---------------------------------
	// File Operation event Handlers
	//---------------------------------
	
	/**
	 * This method will be invoked when saving a playlist
	 */
	private function onFileSaveSelect(event:Event):void
	{
		file.removeEventListener(Event.SELECT, onFileSaveSelect);
		
		// Appemd the playlist extension to the selected file
		var selectedFileName:String = (event.target as File).nativePath.toLowerCase();
		var playlistFileExt:String = "." + ApplicationFileTypes.PLAYLIST_FILE_EXTENSION;
		if(selectedFileName.indexOf(playlistFileExt) == -1)
		{
			selectedFileName += playlistFileExt;
		}
		
		var fileSelected:File = new File(selectedFileName);		
		trace(selectedFileName);
		var currentPlaylist:XML = Utils.getPlaylistAsXML(
			playlistManager.getPlaylistColl());
		FileReadWrite.writeToFile(fileSelected, 
			currentPlaylist.toXMLString(), true);
	}
	
	/**
	 * This method will be invoked for selecting a playlist file
	 */
	private function onSelect(event:Event):void
	{	
		file.removeEventListener(Event.SELECT, onSelect);
		
		var xmlData:XML = FileReadWrite.readXMLFile(file);
		var readPlaylist:ArrayCollection = Utils.getPlaylistFromXML(xmlData);
		if(readPlaylist.length > 0)
		{
			// update the collection in playlist manager
			model.lastLoadedPlaylistPath = file.nativePath;
			playlistManager.resetPausePosition();
			playlistManager.clearPlaylist();
			playlistManager.addPlaylistCollection(readPlaylist);
		}
		else{
			// Playlist Empty or invalid Playlist file
		}
	}
	
	/**
	 * Invoked when multiple files are selected
	 */
	private function onMultipleSelect(event:FileListEvent):void
	{
		file.removeEventListener(FileListEvent.SELECT_MULTIPLE, onMultipleSelect);
		for (var i:uint = 0; i < event.files.length; i++)
		{
			var dataReader:ID3DataReader = new ID3DataReader(event.files[i]);
			dataReader.addEventListener(ID3Event.DATA_READY, onDataReady);
			dataReader.addEventListener(ID3Event.ID3_ERROR, onId3Error);
		} 
	}
	
	/**
	 * Method to add a file to the playlist
	 */
	public function addFileToList(file:File):void
	{
		var dataReader:ID3DataReader = new ID3DataReader(file);
		dataReader.addEventListener(ID3Event.DATA_READY, onDataReady);
		dataReader.addEventListener(ID3Event.ID3_ERROR, onId3Error);
	}
	
	/**
	 * This function will set up listners for ID3DataReader events for each
	 * mp3 file in the selected directory
	 * 
	 * @event:The Event thrown when a directory is selected
	 */
	private function onSelectDir(event:Event):void 
	{
		dir.removeEventListener(Event.SELECT, onSelectDir);
		
	    var directory:File = event.target as File;
	    var files:Array = directory.getDirectoryListing();
	    var validTrackFileCount:int = 0;
	    
	    // Remember the folder selected
	    model.lastBrowsedFolder = directory;
	    
	    // Set up the values in model
	    model.tempColl = new ArrayCollection();
	    
	    for(var i:uint = 0; i < files.length; i++)
	    {
	    	var aFile:File = files[i] as File;
	    	if(aFile.isDirectory == false && supportedFileType(aFile.extension))
	    	{
	    		// Increment the count
	    		validTrackFileCount++;
	    		
	    		// Add a placeholder TrackVO to know the order of the files
	    		var tempVo:TrackVO = new TrackVO();
	    		tempVo.trackUrl = aFile.nativePath;
	    		model.tempColl.addItem(tempVo);
	    		
	    		// Set up ID3Tag Reader for each file
	    		var someVar:ID3DataReader = new ID3DataReader(aFile);
				someVar.addEventListener(ID3Event.DATA_READY, addDirectoryHandler);
				someVar.addEventListener(ID3Event.ID3_ERROR, onId3Error);
				
				// Show the progress bar initially
				eventDispatcher.dispatchEvent( 
						new PlaylistEvent(PlaylistEvent.FILE_LOADED));
	     	}
	    }
	    model.tempItemCount = validTrackFileCount;
	}
	
	/**
	 * Handler function invoked when an Id3ErrorEvent occurs on the
	 * ID3Reader object.
	 */
	private function onId3Error(event:ID3Event):void
	{
		removeID3Listeners(IEventDispatcher(event.target));
	}
	
	private function onDataReady(event:ID3Event):void
	{
		removeID3Listeners(IEventDispatcher(event.target));
		playlistManager.addItemToPlaylist(event.trackVO);
	}
	
	/**
	 * This function is the handler for the ID3DataReadyEvent for files 
	 * selected from a directory.
	 */
	private function addDirectoryHandler(event:ID3Event):void
	{
		var target:IEventDispatcher = IEventDispatcher(event.target);
		if(target)
		{
			target.removeEventListener(ID3Event.DATA_READY, 
				addDirectoryHandler);
		}
		
		if(model.tempColl && model.tempItemCount > 0)
		{
			var limit:uint = model.tempColl.length;
			for(var i:uint = 0; i < limit; i++)
			{				
				var trackVo:TrackVO = event.trackVO;
				var itemInCollection:TrackVO = model.tempColl[i] as TrackVO;
				
				// Update the TrackVo in the tempColl, in order to maintain the
				// order in which they were selected. This is needed because
				// the ID3DataReader completes on each file based on its data
				// and will not necessarily follow the order of selection.
				if( itemInCollection.trackUrl == trackVo.trackUrl )
				{
					model.tempColl[i] = trackVo;
					model.itemsReadCount++;
					
					// Dispatch an event to notify the progress
					eventDispatcher.dispatchEvent( 
						new PlaylistEvent(PlaylistEvent.FILE_LOADED));
					break;
				}
			}
			
			// When all files TrackVo s have been updated, add them to
			// the playlist manager
			if(model.tempItemCount == model.itemsReadCount){
				playlistManager.addPlaylistCollection(model.tempColl);
				
				// Reset the variables used in the model
				model.tempColl = null;
				model.tempItemCount = 0;
				model.itemsReadCount = 0;
			}			
		}
		else{
			onDataReady(event);
		}
	}
	
	/**
	 * This method returns true if the passed in file extension
	 * is supported by the TritonPlayer.
	 */
	private function supportedFileType(extension:String):Boolean
	{
		switch(extension.toLowerCase())
		{
			case ApplicationFileTypes.TRACK_FILE_EXTENSION :
				return true; 
		}
		return false;
	}
	
	private function removeID3Listeners(target:IEventDispatcher):void
	{
		if(target)
		{
			target.removeEventListener(ID3Event.ID3_ERROR, onId3Error);
			target.removeEventListener(ID3Event.DATA_READY, onDataReady);
			target = null;
		}
	}
}

}