package com.triton.managers
{
import flash.filesystem.File;
	
/**
 * The ApplicationFileManager class provides an abstraction for the
 * system files required by the application. 
 */
public class ApplicationFileManager
{
	/**
	 * This static method will return a reference to the
	 * ApplicationFile type requested.
	 */
	public static function getApplicationFile(type:String):File
	{
		var file:File = null;
		var isValidFile:Boolean = false;
		
		// Check the validity of the type passed
		switch(type)
		{
			case ApplicationFileTypes.PLAYLIST_XML_FILE :
			case ApplicationFileTypes.SETTINGS_OBJ_FILE :
			case ApplicationFileTypes.SETTINGS_XML_FILE :
				isValidFile = true;
				break;
		}
		
		// Map to applicationStorageDirectory if valid type
		if(isValidFile)
		{
			file = File.applicationStorageDirectory.resolvePath(type);
		}
		
		return file;
	}

}
}