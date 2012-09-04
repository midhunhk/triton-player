package com.triton.custom
{
import mx.controls.sliderClasses.SliderThumb;
import mx.core.mx_internal;
import flash.display.Graphics;

public class SliderButton extends SliderThumb
{
    use namespace mx_internal;
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
    	this.graphics.clear();
    	super.updateDisplayList(unscaledWidth, unscaledHeight);
    	
    	var thumbColor:uint = getStyle("thumbColor");
    	if(!thumbColor)
    		thumbColor = 0xE86618;
    	
        var gr:Graphics = this.graphics;
        gr.clear();
        gr.beginFill(thumbColor);
        gr.drawRect(0, 0, 6, 8);
        gr.endFill();
    }
    
    override protected function measure():void{
        super.measure();
        measuredWidth = 6;
        measuredHeight = 8;
    }
}
}