///////////////////////////////////////////////////////////////////////////////
// TritonPlayerAS.as
// Action Scripts for TritonPlayer main page
// Author 	: midhun harikumar
// Date 	: June 2010
// Version	: $ 1.8.0
///////////////////////////////////////////////////////////////////////////////

import com.triton.assets.LayoutAssets;
import com.triton.custom.CustomEventDispatcher;
import com.triton.events.PlaylistEvent;
import com.triton.events.TritonPlayerEvent;
import com.triton.managers.ApplicationFileManager;
import com.triton.managers.ApplicationFileTypes;
import com.triton.managers.PlaylistManager;
import com.triton.managers.SettingsManager;
import com.triton.managers.ThemeManager;
import com.triton.model.ModelLocator;
import com.triton.utils.FileOperations;
import com.triton.utils.FileReadWrite;
import com.triton.utils.MenuConstants;
import com.triton.utils.Utils;
import com.triton.vo.SettingsVO;

import flash.desktop.NativeApplication;
import flash.display.NativeWindowDisplayState;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;

import mx.collections.ArrayCollection;
import mx.core.Application;
import mx.events.StyleEvent;
import mx.managers.DragManager;
import mx.resources.ResourceManager;

//-----------------------------------------------------------------------------
//
// 	Constants
//
//-----------------------------------------------------------------------------
public static const COMPACT_STATE:String = "compactState";

//-----------------------------------------------------------------------------
//
// 	Variables
//
//-----------------------------------------------------------------------------
[Bindable]
private var assets:LayoutAssets;
[Bindable]
private var model:ModelLocator;
private var settingsVo:SettingsVO;
private var playlistManager:PlaylistManager;
private var eventDispatcher:CustomEventDispatcher;
private var styleLoader:IEventDispatcher;
private var _timestamp:int;

//-----------------------------------------------------------------------------
//
// 	Methods
//
//-----------------------------------------------------------------------------

/**
 * Override the initialized setter
 */
override public function set initialized(value:Boolean):void
{
	// This value will be set by the onStyleLoaded method
}

/**
 * This method is invoked on the preinitialze event and loads
 * the user settings from the disk, loads the stylesheet to be used
 * and initializes objects that will be used
 */
private function loadSettings():void
{
	_timestamp = getTimer();
	// Create instances
	assets 			= LayoutAssets.getInstance();
	model 			= ModelLocator.getInstance();
	playlistManager = PlaylistManager.getInstance();
	eventDispatcher = CustomEventDispatcher.getInstance();
	
	// Read the settings and load the style
	settingsVo = SettingsManager.readSettings();
	initializeStyles(settingsVo);
	
	//trace("readSettings : " + (getTimer() - _timestamp));
	// Setup triton event listeners
	eventDispatcher.addEventListener(
		TritonPlayerEvent.CLOSE_BUTTON_PRESSED, onApplicationClosed);
	eventDispatcher.addEventListener(
		TritonPlayerEvent.MINIMIZE_BUTTON_PRESSED,onApplicationMinimized);
	eventDispatcher.addEventListener(
		TritonPlayerEvent.RESTORE_BUTTON_PRESSED,onApplicationRestore);
	eventDispatcher.addEventListener(
		TritonPlayerEvent.COMPACT_MODE, onCompactMode);
	//trace("loadSettingsDone : " + (getTimer() - _timestamp));
}
/**
 * This method is invoked on applicationComplete
 */			
private function applicationCompleteHandler():void
{
	//trace("applicationComplete : " + (getTimer() - _timestamp));
	// Setup Listners
	Application.application.stage.addEventListener(KeyboardEvent.KEY_DOWN, onkeyDown);
	Application.application.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, 
		onNaiveWindowDisplayChange);
	stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
		nativeWindowMinimized);
	
	this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragIn);
	this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDrop);
	
	// Initialize the application with the settings
	initializeApp(settingsVo);
	
	// Show Tray Icon
	showTrayIcon();
	
	// Inform the views that the Settings have been loaded
	var settingsLoadedEvent:TritonPlayerEvent = 
		new TritonPlayerEvent(TritonPlayerEvent.SETTINGS_LOADED);
	settingsLoadedEvent.settingsVo = settingsVo;
	eventDispatcher.dispatchEvent(settingsLoadedEvent);

	var compactModeEvent:TritonPlayerEvent =
		new TritonPlayerEvent(TritonPlayerEvent.COMPACT_MODE)
	eventDispatcher.dispatchEvent(compactModeEvent);
	
	//trace("init end : " + (getTimer() - _timestamp));
}

private function creationCompleteHandler():void
{
	//trace("creationComplete : " + (getTimer() - _timestamp));
	// Parse and load the default playlist that was saved.
	var playlistFile:File = ApplicationFileManager.getApplicationFile(
		ApplicationFileTypes.PLAYLIST_XML_FILE);
	if(playlistFile.exists)
	{
		parseAndLoadPlaylistXML(playlistFile);
	}
}


/**
 * This method is invoked when the user double clicks on a Triton
 * playlist file.
 */
public function onInvokeEvent(event:InvokeEvent):void
{
	try
	{
		var argArray:Array = event.arguments;
		if(argArray.length > 0){
			var playlistFile:File = new File(argArray[0]);
			if(playlistFile.exists)
				parseAndLoadPlaylistXML(playlistFile);
		}
	}
	catch(error:Error)
	{
		trace(error.message);
	}
}

private function iconLoadComplete(event:Event):void
{
	NativeApplication.nativeApplication.icon.bitmaps = 
		[event.target.content.bitmapData];
}

/** 
 * Invoked when the user clicks on the SysTray Icon.
 * Restores the application if it was in minimized state
 */
private function onSysTrayClick(event:MouseEvent):void
{
	if(model.isPlayerMinimized)
	{
		onApplicationRestore();
	}	
}

private function updateSysTrayTooltip(event:PlaylistEvent):void
{	
	if(event.type == PlaylistEvent.PLAYLIST_PLAY_CHANGE){
		var sysTrayToolTip:String = Utils.getSysTrayToolTip(
			playlistManager.getCurrentTrackVo());
		setSysTrayTooltip(sysTrayToolTip);
	}
	else if(event.type == PlaylistEvent.PLAYLIST_STOP){
		setSysTrayTooltip();
	}
}

private function setSysTrayTooltip(toolTipText:String="Triton Player"):void
{
	var sysTrayIcon:SystemTrayIcon = 
		(NativeApplication.nativeApplication.icon as SystemTrayIcon);
	sysTrayIcon.tooltip = toolTipText;
	
}			

/**
 * This method will parse and load the playlist passed as a file
 * @param playlistFile
 */
private function parseAndLoadPlaylistXML(playlistFile:File):void
{
	var playlistXML:XML = FileReadWrite.readXMLFile( playlistFile);				
	var playlistColl:ArrayCollection = Utils.getPlaylistFromXML(playlistXML);
	if(playlistColl && playlistColl.length)
	{
		playlistManager.clearPlaylist();
		playlistManager.addPlaylistCollection(playlistColl);
	}
}

/**
 * Application KeyDown Handler
 */
private function onkeyDown(event:KeyboardEvent):void
{
	if(event.keyCode == Keyboard.ESCAPE)
	{
   		if(model.isModalWindowVisible)
   		{
   			// Close the modal Window
   			eventDispatcher.dispatchEvent(new TritonPlayerEvent(
				TritonPlayerEvent.HIDE_MODAL_WINDOW));
   		}
   		else
   		{
   			// Minimize the app
   			eventDispatcher.dispatchEvent(new TritonPlayerEvent(
				TritonPlayerEvent.MINIMIZE_BUTTON_PRESSED));
   		}
   	}
   	else if(model.isModalWindowVisible == false)
   	{
   		// Dispatch an event with the keycode
   		var keyPressEvennt:TritonPlayerEvent = 
   			new TritonPlayerEvent(TritonPlayerEvent.KEY_PRESSED);
   		keyPressEvennt.keyCode = event.keyCode;
   		eventDispatcher.dispatchEvent(keyPressEvennt);
   	}
}

/**
 * Handler function called when the application's display state is changing
 */
private function onNaiveWindowDisplayChange(event:NativeWindowDisplayStateEvent):void
{
	if(event.afterDisplayState == NativeWindowDisplayState.MINIMIZED
		&& model.minimizeToTray == true)
	{
		Application.application.showStatusBar = false;
		stage.nativeWindow.visible = false;
	}
	else if(event.afterDisplayState == NativeWindowDisplayState.NORMAL
		&& model.minimizeToTray == true)
	{
		Application.application.showStatusBar = true;
		stage.nativeWindow.visible = true;	
	}
}

/**
 * Habndle the default Minimize event
 */
private function nativeWindowMinimized(event:NativeWindowDisplayStateEvent):void
{
	if(event.afterDisplayState == NativeWindowDisplayState.MINIMIZED)
	{
		event.preventDefault();
		onApplicationMinimized();
	}
}

/**
 * Invoked when the application is closed
 */
private function onApplicationClosed(event:Event):void
{
	// Save the settings
	saveApplicationSettings();
	// Exit the application
	Application.application.exit();
}

/**
 * This method will save the applications settings to the disk.
 */
private function saveApplicationSettings(event:Event = null):void
{
	var trackPosition:Number = playlistManager.getCurrentPosition();
	if(playlistManager.isShuffledPlay() == true)
	{
		// Save the unshuffled playlist to disk
		playlistManager.stopPlay();
		playlistManager.playInShuffledMode();
		playlistManager.setCurrentTrackIndex(0);
		trackPosition = 0;
	}
	// Save current playlist - write to disk
	var playlistFile:File = ApplicationFileManager.getApplicationFile(
		ApplicationFileTypes.PLAYLIST_XML_FILE);
		
	var currentPlaylist:String = 
		Utils.getPlaylistAsXML(playlistManager.getPlaylistColl()).toXMLString();
	FileReadWrite.writeToFile(playlistFile, currentPlaylist, true);
	var lastBrowsedPath:String = 
		(null == model.lastBrowsedFolder) ? "" : model.lastBrowsedFolder.url;
	
	// Create Settings vo
	settingsVo 							= new SettingsVO();
	settingsVo.x		 				= outerWrapper.x;
	settingsVo.y 						= outerWrapper.y;
	settingsVo.width 					= outerWrapper.width;
	settingsVo.height 					= outerWrapper.height;
	settingsVo.lastBrowsedDirectoryPath = lastBrowsedPath;
	settingsVo.playlistScrollPos 		= 
		playlistView.playlist.verticalScrollPosition;
	
	// Get data from model
	settingsVo.loopOnEnd 				= model.loopOnEnd;
	settingsVo.isCompactMode 			= model.isCompactMode;
	settingsVo.minimizeToTray 			= model.minimizeToTray;
	settingsVo.visualizationIndex 		= model.visualizationIndex;
	settingsVo.transparentWindow 		= model.isWindowTransparent;
	settingsVo.locale 					= model.currentLocale;
	settingsVo.currentTheme				= model.currentTheme;
	
	// Get data from playlistManager
	settingsVo.volume 			= playlistManager.getCurrentVolume();	
	settingsVo.trackIndex 		= playlistManager.getCurrentTrackIndex();
	settingsVo.trackPosition 	= trackPosition;
	
	// Save the settings to disk
	SettingsManager.saveSettings(settingsVo);
}

/**
 * Invoked when the application is minimized.
 * If minimize to tray is enabled, hide the app from the status bar
 */
private function onApplicationMinimized(event:TritonPlayerEvent=null):void
{
	stage.nativeWindow.minimize();
	model.isPlayerMinimized = true;
}

/**
 * Invoked when the application is restored from a minimized state
 * If minimize to tray is enabled, show the app on the status bar
 */
private function onApplicationRestore(event:TritonPlayerEvent=null):void
{
	stage.nativeWindow.restore();
	stage.nativeWindow.orderToFront();
	Application.application.setFocus();
	model.isPlayerMinimized = false;
}

/**
 * Invoked when drag starts 
 */
private function onDragIn(event:NativeDragEvent):void
{
	DragManager.acceptDragDrop(this);
}

/**
 * Invoked when drag Drop occurs.
 * If an tpl playlist file is dropped, load the playlist
 * If an mp3 file is dropped, add it to the current playlist
 */
private function onDrop(event:NativeDragEvent):void
{
	var fileList:Array = event.clipboard.getData(
		ClipboardFormats.FILE_LIST_FORMAT) as Array;
	var fileOperations:FileOperations = new FileOperations();
	
	for each(var file:File in fileList)
	{
		switch(file.extension.toLowerCase())
		{
			case ApplicationFileTypes.PLAYLIST_FILE_EXTENSION : 
					// Load the playlist
					parseAndLoadPlaylistXML(file);
					break;
			case ApplicationFileTypes.TRACK_FILE_EXTENSION :
					// Load the file into the current list
					fileOperations.addFileToList(file);
		}
	}
}

/**
 * Invoked when the compact mode toggles
 */
private function onCompactMode(event:TritonPlayerEvent):void
{
	trace("onCompactMode");
	if(model.isCompactMode == true)
	{
		this.currentState = COMPACT_STATE;
		Application.application.setFocus();
	}
	else
	{
		this.currentState = "";
	}
}

/**
 * Method to initialize the app with the stored settings.
 */
private function initializeApp(settingsVo:SettingsVO):void
{
	stage.nativeWindow.x = 0;
    stage.nativeWindow.y = 0;
    stage.nativeWindow.width  = Capabilities.screenResolutionX;
	stage.nativeWindow.height = Capabilities.screenResolutionY;
	
	playlistManager.setCurrentVolume( settingsVo.volume);
	
	setWindowTransparency();
}
private function onWrapperCreated():void
{
	outerWrapper.x = settingsVo.x;
	outerWrapper.y = settingsVo.y;
	outerWrapper.width = settingsVo.width;
	outerWrapper.height = settingsVo.height;
}

private function initializeStyles(settingsVo:SettingsVO):void
{
	// Load the currentTheme
	styleLoader = 
		ThemeManager.loadApplicationTheme(settingsVo.currentTheme);
	if(styleLoader)
	{
		styleLoader.addEventListener(StyleEvent.COMPLETE, onStyleLoaded);
		styleLoader.addEventListener(StyleEvent.ERROR, onStyleLoaded);
	}
	
	model.loopOnEnd = settingsVo.loopOnEnd;
	model.isCompactMode = settingsVo.isCompactMode;
	model.minimizeToTray = settingsVo.minimizeToTray;
	model.visualizationIndex = settingsVo.visualizationIndex;
	model.isWindowTransparent = settingsVo.transparentWindow;
	model.currentTheme = ThemeManager.getCurrentTheme();
		
	// Update the Locale
	ResourceManager.getInstance().localeChain = [settingsVo.locale];
	ResourceManager.getInstance().update();
	model.currentLocale = settingsVo.locale;
	
	var lastBrowsedPath:String = settingsVo.lastBrowsedDirectoryPath;
	if(lastBrowsedPath != "")
		model.lastBrowsedFolder = new File(lastBrowsedPath);
	else
		model.lastBrowsedFolder = File.documentsDirectory;
}
/**
 * Method invoked when the initial style has loaded.
 */
private function onStyleLoaded(event:StyleEvent):void
{
	styleLoader.removeEventListener(StyleEvent.COMPLETE, onStyleLoaded);
	styleLoader.removeEventListener(StyleEvent.ERROR, onStyleLoaded);
	
	super.initialized = true;
}

/**
 * This method will show an icon in the system tray if it is
 * supported in the current OS.
 */
private function showTrayIcon():void
{
	if(NativeApplication.supportsSystemTrayIcon)
	{
		var icon:Loader = new Loader();
		icon.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
		icon.load(new URLRequest(assets.applicationIcon_16));
		
		var systrayIcon:SystemTrayIcon = 
			NativeApplication.nativeApplication.icon as SystemTrayIcon;
		systrayIcon.menu = getSystemTrayMenu();
		systrayIcon.addEventListener(MouseEvent.CLICK, onSysTrayClick);
		setSysTrayTooltip();
		
		eventDispatcher.addEventListener(PlaylistEvent.PLAYLIST_PLAY_CHANGE, 
			updateSysTrayTooltip);
		eventDispatcher.addEventListener(PlaylistEvent.PLAYLIST_STOP, 
			updateSysTrayTooltip);
	}
}

/**
 * Method to set the window transparancy of the main canvas
 */
public function setWindowTransparency():void
{
	if(model.isWindowTransparent)
	{
		outerCanvas.alpha = 0.3;
		playerInfoAndControls.alpha = 3;
		playlistContainer.alpha = 3;
		outerCanvas.styleName = "outerCanvasGradient";
	}
	else
	{
		outerCanvas.alpha = 1;
		playerInfoAndControls.alpha = 1;
		playlistContainer.alpha = 1;
		outerCanvas.styleName = "outerCanvasGradientAlt";
	}
}

/**
 * Initialises and returns the Tray Menu for the application
 */
private function getSystemTrayMenu():NativeMenu
{
	var iconMenu:NativeMenu  = new NativeMenu();
	
	// Create the MenuItems
	var menuItemNext:NativeMenuItem = 
		new NativeMenuItem(MenuConstants.MENU_ITEM_NEXT);
	menuItemNext.addEventListener(Event.SELECT, onPlayControlsClick);
					
	var menuItemPrev:NativeMenuItem = 
		new NativeMenuItem(MenuConstants.MENU_ITEM_PREV);
	menuItemPrev.addEventListener(Event.SELECT, onPlayControlsClick);				
	
	var menuItemPause:NativeMenuItem = 
		new NativeMenuItem(MenuConstants.MENU_ITEM_PAUSE);
	menuItemPause.addEventListener(Event.SELECT, onPlayControlsClick);				
	
	var menuItemStop:NativeMenuItem = 
		new NativeMenuItem(MenuConstants.MENU_ITEM_STOP);
	menuItemStop.addEventListener(Event.SELECT, onPlayControlsClick);				 
	
	var menuItemMinimize:NativeMenuItem = 
		new NativeMenuItem(MenuConstants.MENU_ITEM_MINIMIZE);
	menuItemMinimize.addEventListener(Event.SELECT, onMinimizeMenuClick);				
	
	var menuItemRestore:NativeMenuItem = 
		new NativeMenuItem(MenuConstants.MENU_ITEM_RESTORE);
	menuItemRestore.addEventListener(Event.SELECT, onRestoreMenuClick);				
	
	var menuItemExit:NativeMenuItem = 
		new NativeMenuItem(MenuConstants.MENU_ITEM_EXIT);
	menuItemExit.addEventListener(Event.SELECT, onExitMenuClick);
	
	var menuItemMute:NativeMenuItem = 
		new NativeMenuItem(MenuConstants.MENU_ITEM_MUTE);
	menuItemMute.addEventListener(Event.SELECT, onPlayControlsClick);
	
	// Add them to the menu
	iconMenu.addItem( menuItemNext);
	iconMenu.addItem( menuItemPrev);
	iconMenu.addItem( menuItemPause);
	iconMenu.addItem( menuItemStop);
	iconMenu.addItem( menuItemMute);
	iconMenu.addItem( new NativeMenuItem("",true));
	iconMenu.addItem( menuItemRestore);
	iconMenu.addItem( menuItemMinimize);
	iconMenu.addItem( new NativeMenuItem("",true));
	iconMenu.addItem( menuItemExit);
	
	return iconMenu;
}

private function onPlayControlsClick(event:Event):void
{
	var selectedItem:String = 
		(event.currentTarget as NativeMenuItem).label;
	var menuSelectEvent:TritonPlayerEvent = 
		new TritonPlayerEvent(TritonPlayerEvent.MENU_SELECTED);
	menuSelectEvent.selectedMenu = selectedItem;
	eventDispatcher.dispatchEvent( menuSelectEvent);
}

private function onRestoreMenuClick(event:Event):void
{
	eventDispatcher.dispatchEvent(new TritonPlayerEvent(
		TritonPlayerEvent.RESTORE_BUTTON_PRESSED));
}

private function onMinimizeMenuClick(event:Event):void
{
	eventDispatcher.dispatchEvent(new TritonPlayerEvent(
		TritonPlayerEvent.MINIMIZE_BUTTON_PRESSED));
}

private function onExitMenuClick(event:Event):void
{
	eventDispatcher.dispatchEvent(new TritonPlayerEvent(
		TritonPlayerEvent.CLOSE_BUTTON_PRESSED));
}