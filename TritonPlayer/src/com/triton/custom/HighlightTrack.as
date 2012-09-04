package com.triton.custom
{
import flash.display.Graphics;	
import mx.core.UIComponent;

public class HighlightTrack extends UIComponent
{
	
    override public function get height():Number
    {
        return 3;
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        this.graphics.clear();
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        var gr:Graphics = this.graphics;
        
        var trackColor:uint = getStyle("trackColor");
		if(!trackColor)
			trackColor = 0xE94C00;
        
        gr.beginFill(trackColor);
        gr.drawRect(0, 0, unscaledWidth, 3);
        gr.endFill();
    }
}
}