package com.triton.managers
{
import com.triton.utils.FileReadWrite;
import com.triton.utils.Utils;
import com.triton.vo.SettingsVO;

import flash.desktop.NativeApplication;
import flash.filesystem.File;
	
/**
 * The SettingsManager provides static methods to read settings for the 
 * application and also to write them back to disk.
 */
public class SettingsManager
{
	//-------------------------------------------------------------------------
	//
	//	Constants
	//
	//-------------------------------------------------------------------------
	
	public static const DEFAULT_LOCALE:String = "en_US";
	
	//-------------------------------------------------------------------------
	//
	//	Methods
	//
	//-------------------------------------------------------------------------
	
	public static function readSettings():SettingsVO
	{
		var tempVo:SettingsVO;
		var settingsVo:SettingsVO = getDefaultSettingsVo();
		var settingsFile:File = ApplicationFileManager.getApplicationFile(
			ApplicationFileTypes.SETTINGS_XML_FILE);
		
		if(settingsFile.exists == false)
		{
			// Read from 1.2 Binary Settings file
			settingsFile = ApplicationFileManager.getApplicationFile(
				ApplicationFileTypes.SETTINGS_OBJ_FILE);
			if(settingsFile.exists)
			{
				tempVo = SettingsVO( FileReadWrite.readObject(settingsFile));
				if(tempVo != null)
					settingsVo = tempVo;
			}
		}
		else
		{
			// read from 1.1 XML Settings file
			var settingsXml:XML = FileReadWrite.readXMLFile(settingsFile);
			// parse the xml to get settingsVo
			tempVo = Utils.getSettingsFromXML(settingsXml);
			if(tempVo != null)
				settingsVo = tempVo;
			// delete the old file
			settingsFile.deleteFileAsync();
		}
		return settingsVo;
	}
	
	/**
	 * This method updates the settings vo if an updated vo is 
	 * passed in and saves the settings on to the disk.
	 */
	public static function saveSettings(settingsVo:SettingsVO = null):void
	{
		var settingsFile:File = ApplicationFileManager.getApplicationFile(
			ApplicationFileTypes.SETTINGS_OBJ_FILE);
		FileReadWrite.writeObject(settingsFile, settingsVo);
	}
	
	/**
	 * This function will create a settingsVo object with
	 * the default settings for the vo.
	 */
	protected static function getDefaultSettingsVo():SettingsVO
	{
		var defaultSettings:SettingsVO 			= new SettingsVO();
		defaultSettings.width 					= 390;
		defaultSettings.height 					= 520;					
		defaultSettings.x 						= 650;
		defaultSettings.y 						= 260;
		defaultSettings.volume 					= 0.8;
		defaultSettings.locale 					= DEFAULT_LOCALE;
		defaultSettings.minimizeToTray 			= false;
		defaultSettings.transparentWindow 		= true;
		defaultSettings.visualizationIndex 		= 0;
		defaultSettings.lastBrowsedDirectoryPath = "";
		
		return defaultSettings;
	}
	
}
}