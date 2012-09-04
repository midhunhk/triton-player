package com.triton.custom
{
    import flash.display.Shape;
    import flash.events.Event;
    
    import mx.controls.Label;
    import mx.core.UIComponent;

    /**
     * Sets the size of the characters.
     * @default 10
     */
    [Style(name="fontSize",type="Number",inherit="yes")]
    
    /**
     * Sets the weight (bold or normal) for the text.
     * @default normal
     */
    [Style(name="fontWeight",type="String",inherit="yes")]
    
    /**
     * Sets the font family for the text.
     * @default system
     */
    [Style(name="fontFamily",type="String",inherit="yes")]
    
    /**
     * Sets the color for the text.
     * @default 0 (black)
     */
    [Style(name="color",type="Number",format="Color",inherit="yes")]

    /**
     * This component displays a string of moving text. The text may move left to right, right to left,
     * bottom to top, or top to bottom.
     * 
     * When the text reaches the edge in its direction of travel, a second copy of the text begins to
     * scroll along the same path.
     * 
     * The String to scroll is set using this component's <code>text</code> property. Constants can 
     * set the <code>direction</code> of the scroll as well as the <code>speed</code>.
     * 
     * <pre>
     * <ScrollingText text="Hello World" direction="rightToLeft" speed="5" width="100%" />
     * </pre>
     */
    public class ScrollingText extends UIComponent
    {
        /**
         * Scrolls the text from the right side to the left side. This is the default.
         */
        public static const RIGHT_TO_LEFT:String = "rightToLeft";
        
        /**
         * Scrolls the text from the left side to the right side.
         */
        public static const LEFT_TO_RIGHT:String = "leftToRight";
        
        /**
         * Scrolls the text from the bottom to the top of the control.
         */ 
        public static const BOTTOM_TO_TOP:String = "bottomToTop";
        
        /**
         * Scrolls the text from the top to the bottom of the control.
         */ 
        public static const TOP_TO_BOTTOM:String = "topToBottom";
        
        /**
         * @private
         */
        private var cache:Array;
        private var clipMask:Shape;
        private var currentIndex:int = 0;
        private var secondIndex:int = 1;
        private var messageText:String;
        private var messageSpeed:int = 5;
        private var textDirection:String = RIGHT_TO_LEFT;
        
        /**
         * Constructor
         */
        public function ScrollingText()
        {
            super();
        }
        
        
        /**
         * Creates the objects that make this component work. Two Labels are placed into a cache
         * where they are used to scroll the text. As one label disappears the other appears.
         * 
         * A mask is also created for the component to clip the text flowing out of the component's
         * boundaries as UIComponent provides no clipping of its own.
         */
        override protected function createChildren():void
        {
            super.createChildren();
            
            cache = [new Label(),new Label()];
            
            (cache[0] as Label).styleName = this;
            (cache[0] as Label).cacheAsBitmap = true;
            addChild(cache[0]);
            
            (cache[1] as Label).styleName = this;
            (cache[1] as Label).cacheAsBitmap = true;
            addChild(cache[1]);
            
            clipMask = new Shape();
            addChild(clipMask);
            mask = clipMask;
        }
        
        /**
         * The text message to display in the marquee.
         */
        public function get text() : String
        {
            return messageText;
        }
        public function set text( value:String ) : void
        {
            messageText = value;
            invalidateProperties();
        }
        
        /**
         * Determines how fast the text flows. Minimum is 1.
         * @default 5
         */
        public function get speed() : int
        {
            return messageSpeed;
        }
        public function set speed( value:int ) : void
        {
            if( value < 1 ) value = 1;
            messageSpeed = value;
        }
        
        [Inspectable(type="String",enumeration="leftToRight,rightToLeft,topToBottom,bottomToTop")]
        /**
         * Determines if the text scrolls horizontally (default) or vertically. Possible values are:
         * <ul>
         * <li>LEFT_TO_RIGHT</li>
         * <li>RIGHT_TO_LEFT</li>
         * <li>TOP_TO_BOTTOM</li>
         * <li>BOTTOM_TO_TOP</li>
         * 
         * @default LEFT_TO_RIGHT
         */
        public function get direction() : String
        {
            return textDirection;
        }
        public function set direction( value:String ) : void
        {
            textDirection = value;
            invalidateProperties();
        }
        
        [Bindable]
        /**
         * If true, the text is flowing; false if the text is not flowing.
         */
        public var running:Boolean = false;
        
        /**
         * This function begins the text scrolling.
         */
        public function start() : void
        {
            if( !running ) {
                addEventListener( Event.ENTER_FRAME, moveText );
            }
            running = true;
        }
        
        /**
         * This function stops the text scrolling.
         */
        public function stop() : void
        {
            if( running ) {
                removeEventListener( Event.ENTER_FRAME, moveText );
            }    
            running = false;
        }
        
        /**
         * This Flex framework function is called once all of the properties have been set (or if
         * invalidateProperties has been called). The Labels are given their text values and the
         * orientation is set, if necessary, to comply with the direction.
         */
        override protected function commitProperties() : void
        {
            if( text == null )  messageText = "";
            cache[0].text = text;
            cache[1].text = text;
            
            // calling validateNow will help with determining the actual size of the Labels in
            // the measure method.
            cache[0].validateNow();
            cache[1].validateNow();
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        /**
         * The job of measure() is to given reasonable values to measuredWidth and measuredHeight. The measure()
         * framework function is called only if an explicit size cannot be determined.
         */
        override protected function measure() : void
        {
            super.measure();
            
            measuredWidth = 0;
            measuredHeight= 0;
            
            // For each Label, set its actual size and then modified the measured width
            // and height.
            for(var i:int=0; i < cache.length; i++)
            {
                var l:Label = cache[i] as Label;
                l.setActualSize( l.getExplicitOrMeasuredWidth(), l.getExplicitOrMeasuredHeight() );
                
                measuredWidth = Math.max(measuredWidth,l.getExplicitOrMeasuredWidth());
                measuredHeight = Math.max(measuredHeight,l.getExplicitOrMeasuredHeight());
            }
        }
        
        /**
         * The updateDisplayList function is called whenever the display list has become invalid. Here,
         * the initial positions of the labels are determined and the clipping mask is made.
         */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth,unscaledHeight);
            
            var label0:Label = cache[0] as Label;
            var label1:Label = cache[1] as Label;
            
            var xpos:Number = (unscaledWidth - label0.width)/2;
            var ypos:Number = (unscaledHeight- label0.height)/2;
            
            switch( direction )
            {
                case RIGHT_TO_LEFT:
                    label0.move(unscaledWidth,ypos);
                    label1.move(Math.max(unscaledWidth,label0.width+10),ypos);
                    break;
                case LEFT_TO_RIGHT:
                    label0.move(0-label0.width,ypos);
                    label1.move(0-label1.width-10,ypos);
                    break;
                case BOTTOM_TO_TOP:
                    label0.move(xpos,unscaledHeight);
                    label1.move(xpos,unscaledHeight);
                    break;
                case TOP_TO_BOTTOM:
                    label0.move(xpos,0-label0.height);
                    label1.move(xpos,0-label1.height);
                    break;
            }
            
            clipMask.graphics.clear();
            clipMask.graphics.beginFill(0);
            clipMask.graphics.drawRect(0,0,unscaledWidth,unscaledHeight);
            clipMask.graphics.endFill();
        }
        
        /**
         * This function is the ENTER_FRAME event handler and it moves the text by measuredSpeed amounts.
         * 
         * The direction determines where the text is positioned and moved. When one label
         * reaches its destination (eg, RIGHT_TO_LEFT reaching the left edge), the second label begins its
         * journey. When that label reaches the destination, the first label starts, etc.
         */
        private function moveText( event:Event ) : void
        {
            // HORIZONTAL
        
            // RIGHT_TO_LEFT
            if( direction == RIGHT_TO_LEFT ) {
                cache[currentIndex].x -= messageSpeed;
                if( cache[currentIndex].x <= 0 ) {
                    cache[secondIndex].x -= messageSpeed;
                }
                if( cache[currentIndex].x+cache[currentIndex].width <= 0 ) {
                    cache[currentIndex].x = Math.max(cache[currentIndex].parent.width,cache[secondIndex].width+10);
                    currentIndex = 1 - currentIndex;
                    secondIndex  = 1 - secondIndex;
                }
            }
            // LEFT_TO_RIGHT 
            else if( direction == LEFT_TO_RIGHT ) {
                cache[currentIndex].x += messageSpeed;
                if( cache[currentIndex].x > 0 && cache[currentIndex].x+cache[currentIndex].width > cache[currentIndex].parent.width ) {
                    cache[secondIndex].x += messageSpeed;
                }
                if( cache[currentIndex].x > cache[currentIndex].parent.width ) {
                    cache[currentIndex].x = 0 - cache[currentIndex].width - 10;
                    currentIndex = 1 - currentIndex;
                    secondIndex  = 1 - secondIndex;
                }
            }
            
            // VERTICAL 
            
            // BOTTOM_TO_TOP
            else if( direction == BOTTOM_TO_TOP ) {
                cache[currentIndex].y -= messageSpeed;
                if( cache[currentIndex].y <= 0 ) {
                    cache[secondIndex].y -= messageSpeed;
                }
                if( cache[currentIndex].y+cache[currentIndex].height <= 0 ) {
                    cache[currentIndex].y = cache[currentIndex].parent.height;
                    currentIndex = 1 - currentIndex;
                    secondIndex  = 1 - secondIndex;
                }
            }
            // TOP_TO_BOTTOM 
            else if( direction == TOP_TO_BOTTOM ) {
                cache[currentIndex].y += messageSpeed;
                if( cache[currentIndex].y+cache[currentIndex].height > cache[currentIndex].parent.height ) {
                    cache[secondIndex].y += messageSpeed;
                }
                if( cache[currentIndex].y > cache[currentIndex].parent.height ) {
                    cache[currentIndex].y = 0 - cache[currentIndex].height;
                    currentIndex = 1 - currentIndex;
                    secondIndex  = 1 - secondIndex;
                }
            }
        }
    }
}