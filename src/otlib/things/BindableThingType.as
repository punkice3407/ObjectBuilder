/*
*  Copyright (c) 2014-2023 Object Builder <https://github.com/ottools/ObjectBuilder>
*
*  Permission is hereby granted, free of charge, to any person obtaining a copy
*  of this software and associated documentation files (the "Software"), to deal
*  in the Software without restriction, including without limitation the rights
*  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*  copies of the Software, and to permit persons to whom the Software is
*  furnished to do so, subject to the following conditions:
*
*  The above copyright notice and this permission notice shall be included in
*  all copies or substantial portions of the Software.
*
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
*  THE SOFTWARE.
*/

package otlib.things
{
    import flash.display.BitmapData;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    import flash.utils.describeType;

    import mx.events.PropertyChangeEvent;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;

    import nail.utils.isNullOrEmpty;

    import otlib.animation.FrameDuration;
    import otlib.animation.FrameGroup;
    import otlib.obd.OBDVersions;
    import otlib.sprites.SpriteData;
    import otlib.things.FrameGroupType;
    import ob.settings.ObjectBuilderSettings;

    [Event(name="propertyChange", type="mx.events.PropertyChangeEvent")]

    [ResourceBundle("strings")]

    public class BindableThingType extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        [Bindable]
        public var id:uint;

        [Bindable]
        public var category:String;

        [Bindable]
        public var isGround:Boolean;

        [Bindable]
        public var groundSpeed:uint;

        [Bindable]
        public var isGroundBorder:Boolean;

        [Bindable]
        public var isOnBottom:Boolean;

        [Bindable]
        public var isOnTop:Boolean;

        [Bindable]
        public var isContainer:Boolean;

        [Bindable]
        public var stackable:Boolean;

        [Bindable]
        public var forceUse:Boolean;

        [Bindable]
        public var multiUse:Boolean;

        [Bindable]
        public var hasCharges:Boolean;

        [Bindable]
        public var writable:Boolean;

        [Bindable]
        public var writableOnce:Boolean;

        [Bindable]
        public var maxTextLength:uint;

        [Bindable]
        public var isFluidContainer:Boolean;

        [Bindable]
        public var isFluid:Boolean;

        [Bindable]
        public var isUnpassable:Boolean;

        [Bindable]
        public var isUnmoveable:Boolean;

        [Bindable]
        public var blockMissile:Boolean;

        [Bindable]
        public var blockPathfind:Boolean;

        [Bindable]
        public var noMoveAnimation:Boolean;

        [Bindable]
        public var pickupable:Boolean;

        [Bindable]
        public var hangable:Boolean;

        [Bindable]
        public var isVertical:Boolean;

        [Bindable]
        public var isHorizontal:Boolean;

        [Bindable]
        public var rotatable:Boolean;

        [Bindable]
        public var hasOffset:Boolean;

        [Bindable]
        public var offsetX:int;

        [Bindable]
        public var offsetY:int;

        [Bindable]
        public var dontHide:Boolean;

        [Bindable]
        public var isTranslucent:Boolean;

        [Bindable]
        public var floorChange:Boolean;

        [Bindable]
        public var hasLight:Boolean;

        [Bindable]
        public var lightLevel:uint;

        [Bindable]
        public var lightColor:uint;

        [Bindable]
        public var hasElevation:Boolean;

        [Bindable]
        public var elevation:uint;

        [Bindable]
        public var isLyingObject:Boolean;

        [Bindable]
        public var animateAlways:Boolean;

        [Bindable]
        public var miniMap:Boolean;

        [Bindable]
        public var miniMapColor:uint;

        [Bindable]
        public var isLensHelp:Boolean;

        [Bindable]
        public var lensHelp:uint;

        [Bindable]
        public var isFullGround:Boolean;

        [Bindable]
        public var ignoreLook:Boolean;

        [Bindable]
        public var cloth:Boolean;

        [Bindable]
        public var clothSlot:uint;

        [Bindable]
        public var isMarketItem:Boolean;

        [Bindable]
        public var marketName:String;

        [Bindable]
        public var marketCategory:uint;

        [Bindable]
        public var marketTradeAs:uint;

        [Bindable]
        public var marketShowAs:uint;

        [Bindable]
        public var marketRestrictProfession:uint;

        [Bindable]
        public var marketRestrictLevel:uint;

        [Bindable]
        public var hasDefaultAction:Boolean;

        [Bindable]
        public var wrappable:Boolean;

        [Bindable]
        public var unwrappable:Boolean;

        [Bindable]
        public var topEffect:Boolean;

        [Bindable]
        public var defaultAction:uint;

        [Bindable]
        public var usable:Boolean;

        public var sprites:Dictionary;

		[Bindable]
		public var groups:uint;

		[Bindable]
		public var frameGroups:Array;

        [Bindable]
        public var settings:ObjectBuilderSettings;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function BindableThingType()
        {
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

		public function getFrameGroup(groupType:uint):FrameGroup
		{
			return frameGroups[groupType];
		}

		public function setFrameGroup(groupType:uint, frameGroup:FrameGroup):void
		{
			frameGroups[groupType] = frameGroup
		}

        public function setSprite(groupType:uint, index:uint, sprite:SpriteData):void
        {
			var frameGroup:FrameGroup = getFrameGroup(groupType);

            var oldValue:uint = frameGroup.spriteIndex[index];
			frameGroup.spriteIndex[index] = sprite.id;
			this.sprites[groupType][index] = sprite;

            var event:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
            event.property = "spriteIndex";
            event.oldValue = oldValue;
            event.newValue = sprite.id;
            dispatchEvent(event);
        }

        public function getSpriteBitmap(groupType:uint, index:uint):BitmapData
        {
            if (sprites[groupType] && index < sprites[groupType].length && sprites[groupType][index] != null)
                return sprites[groupType][index].getBitmap();

            return null;
        }

        public function reset():void
        {
            var description:XMLList = describeType(this)..accessor;
            for each (var property:XML in description) {

                var name:String = property.@name;
                var type:String = property.@type;

                if (type == "Boolean")
                    this[name] = false;
                else if (type == "uint" || type == "int")
                    this[name] = 0;
                else
                    this[name] = null;
            }
        }

        public function copyFrom(data:ThingData):Boolean
        {
            if (!data) return false;

            var thing:ThingType = data.thing;
            var description:XMLList = describeType(thing)..variable;

            for each (var property:XML in description) {
                var name:String = property.@name;
                if (this.hasOwnProperty(name))
                    this[name] = thing[name];
            }

			this.frameGroups = [];
			this.sprites = new Dictionary();
			for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
			{
				var frameGroup:FrameGroup = thing.getFrameGroup(groupType);
				if(!frameGroup)
                    continue;

                this.frameGroups[groupType] = frameGroup.clone();
                if (data.sprites[groupType])
                    this.sprites[groupType] = data.sprites[groupType].concat();

                groups = groupType + 1;
			}

            return true;
        }

        public function copyToThingData(data:ThingData, groups:uint):Boolean
        {
            if (!copyToThingType(data.thing, groups)) return false;

            if (this.sprites) {
                var sprites:Dictionary = new Dictionary();
                for (var groupType:uint = FrameGroupType.DEFAULT; groupType < groups; groupType++)
                {
                    if(!this.getFrameGroup(groupType))
                        continue;

                    var _sprites:Vector.<SpriteData> = this.sprites[groupType];
                    if(_sprites && _sprites.length > 0)
                    {
                        sprites[groupType] = new Vector.<SpriteData>(_sprites.length, true);

                        for (var i:uint = 0; i < _sprites.length; i++)
                            sprites[groupType][i] = _sprites[i] || SpriteData.createSpriteData();

                        data.sprites = sprites;
                    }
                }
            }
            return true;
        }

        public function copyToThingType(thing:ThingType, groups:uint = 2):Boolean
        {
            if (!thing)
                return false;

            var description:XMLList = describeType(thing)..variable;
            for each (var property:XML in description) {
                var name:String = property.@name;
                if (this.hasOwnProperty(name))
                    thing[name] = this[name];
            }

            thing.frameGroups = [];
			for (var groupType:uint = FrameGroupType.DEFAULT; groupType < groups; groupType++)
			{
				var frameGroup:FrameGroup = this.getFrameGroup(groupType);
				if(!frameGroup)
                    continue;

                thing.frameGroups[groupType] = frameGroup.clone();
			}

            return true;
        }

        public function updateSpriteCount(frameGroup:FrameGroup):void
        {
            var spriteCount:uint = frameGroup.getTotalSprites();
            frameGroup.spriteIndex.length = spriteCount;
            sprites[frameGroup.type].length = spriteCount;
            frameGroup.isAnimation = (frameGroup.frames > 1);

            if (frameGroup.isAnimation) {
                var duration:uint = settings.getDefaultDuration(this.category);
                var frameDurations:Vector.<FrameDuration> = new Vector.<FrameDuration>(frameGroup.frames, true);
                for (var i:uint = 0; i < frameGroup.frames; i++) {
                    if (frameGroup.frameDurations && i < frameGroup.frameDurations.length)
                        frameDurations[i] = frameGroup.frameDurations[i];
                    else
                        frameDurations[i] = new FrameDuration(duration, duration);
                }

                frameGroup.frameDurations = frameDurations;
            }

            dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
        }

        public function toThingData(version:uint):ThingData
        {
            var thing:ThingType = new ThingType();
            if (!copyToThingType(thing, groups) || !this.sprites)
                return null;

            var sprites:Dictionary = new Dictionary();
            for (var groupType:uint = FrameGroupType.DEFAULT; groupType <= FrameGroupType.WALKING; groupType++)
            {
				var group:FrameGroup = this.getFrameGroup(groupType);
				if(!group)
					continue;

                var _sprites:Vector.<SpriteData> = this.sprites[groupType];
                sprites[groupType] = new Vector.<SpriteData>(_sprites.length, true);

                for (var i:uint = 0; i < _sprites.length; i++)
					sprites[groupType][i] = _sprites[i] || SpriteData.createSpriteData();
            }

            return ThingData.create(OBDVersions.OBD_VERSION_3, version, thing, sprites);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static const PROPERTY_LABEL:Dictionary = new Dictionary();

        private static function startPropertyLabels():void
        {
            var resource:IResourceManager = ResourceManager.getInstance();
            PROPERTY_LABEL["frameGroups"] = resource.getString("strings", "frameGroups");
            PROPERTY_LABEL["width"] = resource.getString("strings", "width");
            PROPERTY_LABEL["height"] = resource.getString("strings", "height");
            PROPERTY_LABEL["exactSize"] = resource.getString("strings", "cropSize");
            PROPERTY_LABEL["layers"] = resource.getString("strings", "layers");
            PROPERTY_LABEL["patternX"] = resource.getString("strings", "patternX");
            PROPERTY_LABEL["patternY"] = resource.getString("strings", "patternY");
            PROPERTY_LABEL["patternZ"] = resource.getString("strings", "patternZ");
            PROPERTY_LABEL["frames"] = resource.getString("strings", "animations");
            PROPERTY_LABEL["isGround"] = resource.getString("strings", "isGround");
            PROPERTY_LABEL["groundSpeed"] = resource.getString("strings", "groundSpeed");
            PROPERTY_LABEL["isGroundBorder"] = resource.getString("strings", "isGroundBorder");
            PROPERTY_LABEL["isOnBottom"] = resource.getString("strings", "isOnBottom");
            PROPERTY_LABEL["isOnTop"] = resource.getString("strings", "isOnTop");
            PROPERTY_LABEL["isContainer"] = resource.getString("strings", "container");
            PROPERTY_LABEL["stackable"] = resource.getString("strings", "stackable");
            PROPERTY_LABEL["forceUse"] = resource.getString("strings", "forceUse");
            PROPERTY_LABEL["multiUse"] = resource.getString("strings", "multiUse");
            PROPERTY_LABEL["writable"] = resource.getString("strings", "writable");
            PROPERTY_LABEL["writableOnce"] = resource.getString("strings", "writableOnce");
            PROPERTY_LABEL["maxTextLength"] = resource.getString("strings", "maxLength");
            PROPERTY_LABEL["isFluidContainer"] = resource.getString("strings", "fluidContainer");
            PROPERTY_LABEL["isFluid"] = resource.getString("strings", "fluid");
            PROPERTY_LABEL["isUnpassable"] = resource.getString("strings", "unpassable");
            PROPERTY_LABEL["isUnmoveable"] = resource.getString("strings", "unmovable");
            PROPERTY_LABEL["blockMissile"] = resource.getString("strings", "blockMissile");
            PROPERTY_LABEL["blockPathfind"] = resource.getString("strings", "blockPathfinder");
            PROPERTY_LABEL["noMoveAnimation"] = resource.getString("strings", "noMoveAnimation");
            PROPERTY_LABEL["pickupable"] = resource.getString("strings", "pickupable");
            PROPERTY_LABEL["hangable"] = resource.getString("strings", "hangable");
            PROPERTY_LABEL["isVertical"] = resource.getString("strings", "verticalWall");
            PROPERTY_LABEL["isHorizontal"] = resource.getString("strings", "horizontalWall");
            PROPERTY_LABEL["rotatable"] = resource.getString("strings", "rotatable");
            PROPERTY_LABEL["hasOffset"] = resource.getString("strings", "hasOffset");
            PROPERTY_LABEL["offsetX"] = resource.getString("strings", "offsetX");
            PROPERTY_LABEL["offsetY"] = resource.getString("strings", "offsetY");
            PROPERTY_LABEL["dontHide"] = resource.getString("strings", "dontHide");
            PROPERTY_LABEL["isTranslucent"] = resource.getString("strings", "translucent");
            PROPERTY_LABEL["hasLight"] = resource.getString("strings", "hasLight");
            PROPERTY_LABEL["lightLevel"] = resource.getString("strings", "lightIntensity");
            PROPERTY_LABEL["lightColor"] = resource.getString("strings", "lightColor");
            PROPERTY_LABEL["hasElevation"] = resource.getString("strings", "hasElevation");
            PROPERTY_LABEL["elevation"] = resource.getString("strings", "elevation");
            PROPERTY_LABEL["isLyingObject"] = resource.getString("strings", "lyingObject");
            PROPERTY_LABEL["animateAlways"] = resource.getString("strings", "animateAlways");
            PROPERTY_LABEL["miniMap"] = resource.getString("strings", "automap");
            PROPERTY_LABEL["miniMapColor"] = resource.getString("strings", "automapColor");
            PROPERTY_LABEL["isLensHelp"] = resource.getString("strings", "lensHelp");
            PROPERTY_LABEL["lensHelp"] = resource.getString("strings", "lensHelpValue");
            PROPERTY_LABEL["isFullGround"] = resource.getString("strings", "fullGround");
            PROPERTY_LABEL["ignoreLook"] = resource.getString("strings", "ignoreLook");
            PROPERTY_LABEL["cloth"] = resource.getString("strings", "cloth");
            PROPERTY_LABEL["clothSlot"] = resource.getString("strings", "clothSlot");
            PROPERTY_LABEL["isMarketItem"] = resource.getString("strings", "market");
            PROPERTY_LABEL["marketName"] = resource.getString("strings", "name");
            PROPERTY_LABEL["marketCategory"] = resource.getString("strings", "category");
            PROPERTY_LABEL["marketTradeAs"] = resource.getString("strings", "tradeAs");
            PROPERTY_LABEL["marketShowAs"] = resource.getString("strings", "showAs");
            PROPERTY_LABEL["marketRestrictProfession"] = resource.getString("strings", "vocation");
            PROPERTY_LABEL["marketRestrictLevel"] = resource.getString("strings", "level");
            PROPERTY_LABEL["hasDefaultAction"] = resource.getString("strings", "hasAction");
            PROPERTY_LABEL["defaultAction"] = resource.getString("strings", "actionType");
            PROPERTY_LABEL["wrappable"] = resource.getString("strings", "wrappable");
            PROPERTY_LABEL["unwrappable"] = resource.getString("strings", "unwrappable");
            PROPERTY_LABEL["topEffect"] = resource.getString("strings", "topEffect");
            PROPERTY_LABEL["usable"] = resource.getString("strings", "usable");
            PROPERTY_LABEL["spriteIndex"] = resource.getString("strings", "spriteId");
            PROPERTY_LABEL["hasCharges"] = resource.getString("strings", "hasCharges");
            PROPERTY_LABEL["floorChange"] = resource.getString("strings", "floorChange");
            PROPERTY_LABEL["animationMode"] = resource.getString("strings", "animationMode");
            PROPERTY_LABEL["nextFrameStrategy"] = resource.getString("strings", "frameStrategy");
            PROPERTY_LABEL["minimumDuration"] = resource.getString("strings", "minimumDuration");
            PROPERTY_LABEL["maximumDuration"] = resource.getString("strings", "maximumDuration");
            PROPERTY_LABEL["startFrame"] = resource.getString("strings", "startFrame");
            PROPERTY_LABEL["loopCount"] = resource.getString("strings", "loopCount");
            PROPERTY_LABEL["isAnimation"] = resource.getString("strings", "isAnimation");
        }
        startPropertyLabels();

        public static function toLabel(property:String):String
        {
            if (!isNullOrEmpty(property) && PROPERTY_LABEL[property] !== undefined) {
                return PROPERTY_LABEL[property];
            }
            return "";
        }
    }
}
