package com.triton.custom
{
import flash.display.Graphics;
import flash.geom.Matrix;

import mx.core.UIComponent;

public class SliderTrack extends UIComponent
{
    
    override public function get height():Number
    {
        return 4;
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        this.graphics.clear();
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        var gr:Graphics = this.graphics;
        var m:Matrix = new Matrix();
        m.createGradientBox(unscaledWidth, unscaledHeight,Math.PI/2);
        gr.beginGradientFill("linear",[0x3C3C3C, 0xcccccc],[1,1],[0,255],m);
        gr.drawRect(0, 0, unscaledWidth, 4);
        gr.endFill();
    }
    
}
}