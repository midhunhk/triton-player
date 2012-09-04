package com.triton.assets
{
public class LayoutAssets
{
	
	protected static var instance:LayoutAssets;
	
	public function LayoutAssets()
	{
		if(instance){
			throw new Error("Singleton already instantiated");
		}
	}
	
	public static function getInstance():LayoutAssets
	{
		if(instance == null)
			instance = new LayoutAssets();
			
		return instance;
	}
	
	/**
	 * Image path
	 */
	 public const applicationIcon_16:String = "resources/images/icons/trident_16.png";
	 
	 public const playButton:String 	= "resources/images/controls/play_btn_18.png";
	 public const nextButton:String 	= "resources/images/controls/next_btn.png";
	 public const prevButton:String 	= "resources/images/controls/prev_btn.png";
	 public const stopButton:String 	= "resources/images/controls/stop_btn_18.png";
	 public const pauseButton:String 	= "resources/images/controls/pause_btn_18.png";
	 public const repeatButton:String 	= "resources/images/controls/repeat_btn.png";
	 public const shuffleButton:String 	= "resources/images/controls/shuffle_btn.png";
	 public const twitterButton:String 	= "resources/images/controls/twitter.png";
	 public const settingsButton:String = "resources/images/controls/settings.png";
	 public const speakerOnButton:String = "resources/images/controls/speaker_on.png";
	 public const speakerOffButton:String = "resources/images/controls/speaker_off.png";
	 public const compactModeButton:String = "resources/images/controls/compact_mode.png";
	 
	 public const playStatusIcon:String 	= "resources/images/icons/statusIcon_play.png";
	 public const pauseStatusIcon:String 	= "resources/images/icons/statusIcon_pause.png";
	 public const stopStatusIcon:String 	= "resources/images/icons/statusIcon_stop.png";
	 public const shuffleStatusIcon:String 	= "resources/images/icons/statusIcon_shuffle.png";
	 public const muteOnStatusIcon:String 	= "resources/images/icons/statusIcon_mute_on.png";
	 public const muteOffStatusIcon:String 	= "resources/images/icons/statusIcon_mute_off.png";
	 
	 public const addFileIcon:String 	= "resources/images/icons/file_add.png";
	 public const addDirIcon:String 	= "resources/images/icons/folder_add.png";
	 public const clearListIcon:String 	= "resources/images/icons/clear_list.png";
	 public const loadListIcon:String 	= "resources/images/icons/load_list.png"; 
	 public const saveListIcon:String 	= "resources/images/icons/save_list.png";
	 
	 public const tritonLogoText:String = "resources/images/layout/trident_logo_text.png"; 
	
	/**
	 * Assets embedded as classes
	 */
	 
	[Embed(source="../../../resources/images/layout/close_icon.png")]
    [Bindable] public  var closePlayerButton : Class;
    
    [Embed(source="../../../resources/images/layout/minimise_icon.png")]
    [Bindable] public  var minimizePlayerButton : Class;
}
}