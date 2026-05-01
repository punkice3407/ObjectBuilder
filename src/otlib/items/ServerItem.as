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

package otlib.items
{
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    /**
     * Represents a server item from items.otb
     * Contains the mapping between Server ID and Client ID,
     * plus server-side flags and attributes.
     */
    public class ServerItem
    {
        // --------------------------------------------------------------------------
        // PROPERTIES
        // --------------------------------------------------------------------------

        /** Server ID - unique ID used by the server */
        public var id:uint;

        /** Client ID - reference to tibia.dat item */
        public var clientId:uint;

        /** Previous client ID (used during version updates) */
        public var previousClientId:uint;

        /** Item type (Ground, Container, Fluid, etc.) */
        public var type:uint;

        /** Stack order on tile */
        public var stackOrder:uint;

        /** Has explicit stack order set */
        public var hasStackOrder:Boolean;

        /** Item name (from OTB - internal name) */
        public var name:String;

        /** Sprite hash for sprite matching */
        public var spriteHash:ByteArray;

        /** Whether sprite was assigned during update */
        public var spriteAssigned:Boolean;

        /** Custom created item (not from dat) */
        public var isCustomCreated:Boolean;

        /** Dynamic XML attributes from items.xml */
        private var _xmlAttributes:Dictionary;

        // --------------------------------------
        // Flags (from OTB)
        // --------------------------------------

        public var unpassable:Boolean;
        public var blockMissiles:Boolean;
        public var blockPathfinder:Boolean;
        public var hasElevation:Boolean;
        public var forceUse:Boolean;
        public var multiUse:Boolean;
        public var pickupable:Boolean;
        public var movable:Boolean = true;
        public var stackable:Boolean;
        public var readable:Boolean;
        public var rotatable:Boolean;
        public var hangable:Boolean;
        public var hookSouth:Boolean;
        public var hookEast:Boolean;
        public var hasCharges:Boolean;
        public var ignoreLook:Boolean;
        public var allowDistanceRead:Boolean;
        public var isAnimation:Boolean;
        public var fullGround:Boolean;

        // --------------------------------------
        // Attributes
        // --------------------------------------

        public var groundSpeed:uint;
        public var lightLevel:uint;
        public var lightColor:uint;
        public var maxReadChars:uint;
        public var maxReadWriteChars:uint;
        public var minimapColor:uint;
        public var tradeAs:uint;

        // --------------------------------------------------------------------------
        // CONSTRUCTOR
        // --------------------------------------------------------------------------

        public function ServerItem()
        {
            type = ServerItemType.NONE;
            stackOrder = TileStackOrder.NONE;
            name = "";
        }

        // --------------------------------------------------------------------------
        // METHODS
        // --------------------------------------------------------------------------

        public function toString():String
        {
            if (name && name.length > 0)
                return id + " - " + name;
            return id.toString();
        }

        /** Item name from items.xml (displayed name) */
        public function get nameXml():String
        {
            return getXmlAttribute("name") as String;
        }
        public function set nameXml(value:String):void
        {
            setXmlAttribute("name", value);
        }

        /** Article (a, an, the) from items.xml */
        public function get article():String
        {
            return getXmlAttribute("article") as String;
        }
        public function set article(value:String):void
        {
            setXmlAttribute("article", value);
        }

        /** Plural form from items.xml */
        public function get plural():String
        {
            return getXmlAttribute("plural") as String;
        }
        public function set plural(value:String):void
        {
            setXmlAttribute("plural", value);
        }

        /**
         * Creates a copy of this server item
         */
        public function clone():ServerItem
        {
            var item:ServerItem = new ServerItem();
            item.id = id;
            item.clientId = clientId;
            item.previousClientId = previousClientId;
            item.type = type;
            item.stackOrder = stackOrder;
            item.hasStackOrder = hasStackOrder;
            item.name = name;
            item.spriteAssigned = spriteAssigned;
            item.isCustomCreated = isCustomCreated;

            if (spriteHash)
            {
                item.spriteHash = new ByteArray();
                item.spriteHash.writeBytes(spriteHash);
            }

            // Copy flags
            item.unpassable = unpassable;
            item.blockMissiles = blockMissiles;
            item.blockPathfinder = blockPathfinder;
            item.hasElevation = hasElevation;
            item.forceUse = forceUse;
            item.multiUse = multiUse;
            item.pickupable = pickupable;
            item.movable = movable;
            item.stackable = stackable;
            item.readable = readable;
            item.rotatable = rotatable;
            item.hangable = hangable;
            item.hookSouth = hookSouth;
            item.hookEast = hookEast;
            item.hasCharges = hasCharges;
            item.ignoreLook = ignoreLook;
            item.allowDistanceRead = allowDistanceRead;
            item.isAnimation = isAnimation;
            item.fullGround = fullGround;

            // Copy attributes
            item.groundSpeed = groundSpeed;
            item.lightLevel = lightLevel;
            item.lightColor = lightColor;
            item.maxReadChars = maxReadChars;
            item.maxReadWriteChars = maxReadWriteChars;
            item.minimapColor = minimapColor;
            item.tradeAs = tradeAs;

            // Deep-clone XML attributes (handles nested Dictionary/Array from Canary-style nested <attribute>)
            item.copyXmlAttributesFrom(this);

            return item;
        }

        /**
         * Gets flags as uint bitmask
         */
        public function getFlags():uint
        {
            var flags:uint = 0;

            if (unpassable)
                flags |= ServerItemFlag.UNPASSABLE;
            if (blockMissiles)
                flags |= ServerItemFlag.BLOCK_MISSILES;
            if (blockPathfinder)
                flags |= ServerItemFlag.BLOCK_PATHFINDER;
            if (hasElevation)
                flags |= ServerItemFlag.HAS_ELEVATION;
            if (forceUse)
                flags |= ServerItemFlag.FORCE_USE;
            if (multiUse)
                flags |= ServerItemFlag.MULTI_USE;
            if (pickupable)
                flags |= ServerItemFlag.PICKUPABLE;
            if (movable)
                flags |= ServerItemFlag.MOVABLE;
            if (stackable)
                flags |= ServerItemFlag.STACKABLE;
            if (hasStackOrder)
                flags |= ServerItemFlag.STACK_ORDER;
            if (readable)
                flags |= ServerItemFlag.READABLE;
            if (rotatable)
                flags |= ServerItemFlag.ROTATABLE;
            if (hangable)
                flags |= ServerItemFlag.HANGABLE;
            if (hookSouth)
                flags |= ServerItemFlag.HOOK_SOUTH;
            if (hookEast)
                flags |= ServerItemFlag.HOOK_EAST;
            if (hasCharges)
                flags |= ServerItemFlag.CLIENT_CHARGES;
            if (ignoreLook)
                flags |= ServerItemFlag.IGNORE_LOOK;
            if (allowDistanceRead)
                flags |= ServerItemFlag.ALLOW_DISTANCE_READ;
            if (isAnimation)
                flags |= ServerItemFlag.IS_ANIMATION;
            if (fullGround)
                flags |= ServerItemFlag.FULL_GROUND;

            return flags;
        }

        /**
         * Sets flags from uint bitmask
         */
        public function setFlags(flags:uint):void
        {
            unpassable = (flags & ServerItemFlag.UNPASSABLE) != 0;
            blockMissiles = (flags & ServerItemFlag.BLOCK_MISSILES) != 0;
            blockPathfinder = (flags & ServerItemFlag.BLOCK_PATHFINDER) != 0;
            hasElevation = (flags & ServerItemFlag.HAS_ELEVATION) != 0;
            forceUse = (flags & ServerItemFlag.FORCE_USE) != 0;
            multiUse = (flags & ServerItemFlag.MULTI_USE) != 0;
            pickupable = (flags & ServerItemFlag.PICKUPABLE) != 0;
            movable = (flags & ServerItemFlag.MOVABLE) != 0;
            stackable = (flags & ServerItemFlag.STACKABLE) != 0;
            hasStackOrder = (flags & ServerItemFlag.STACK_ORDER) != 0;
            readable = (flags & ServerItemFlag.READABLE) != 0;
            rotatable = (flags & ServerItemFlag.ROTATABLE) != 0;
            hangable = (flags & ServerItemFlag.HANGABLE) != 0;
            hookSouth = (flags & ServerItemFlag.HOOK_SOUTH) != 0;
            hookEast = (flags & ServerItemFlag.HOOK_EAST) != 0;
            hasCharges = (flags & ServerItemFlag.CLIENT_CHARGES) != 0;
            ignoreLook = (flags & ServerItemFlag.IGNORE_LOOK) != 0;
            allowDistanceRead = (flags & ServerItemFlag.ALLOW_DISTANCE_READ) != 0;
            isAnimation = (flags & ServerItemFlag.IS_ANIMATION) != 0;
            fullGround = (flags & ServerItemFlag.FULL_GROUND) != 0;
        }

        /**
         * Gets the item group based on type
         */
        public function getGroup():uint
        {
            switch (type)
            {
                case ServerItemType.GROUND:
                    return ServerItemGroup.GROUND;
                case ServerItemType.CONTAINER:
                    return ServerItemGroup.CONTAINER;
                case ServerItemType.FLUID:
                    return ServerItemGroup.FLUID;
                case ServerItemType.SPLASH:
                    return ServerItemGroup.SPLASH;
                case ServerItemType.DEPRECATED:
                    return ServerItemGroup.DEPRECATED;
                default:
                    return ServerItemGroup.NONE;
            }
        }

        // --------------------------------------
        // XML Attribute Methods
        // --------------------------------------

        /**
         * Sets an XML attribute value
         */
        public function setXmlAttribute(key:String, value:Object):void
        {
            if (!_xmlAttributes)
                _xmlAttributes = new Dictionary();

            _xmlAttributes[key] = value;
        }

        /**
         * Gets an XML attribute value
         */
        public function getXmlAttribute(key:String):Object
        {
            if (!_xmlAttributes)
                return null;

            return _xmlAttributes[key];
        }

        /**
         * Checks if an XML attribute exists
         */
        public function hasXmlAttribute(key:String):Boolean
        {
            if (!_xmlAttributes)
                return false;

            return _xmlAttributes[key] !== undefined;
        }

        /**
         * Gets all XML attributes as Dictionary
         */
        public function getXmlAttributes():Dictionary
        {
            return _xmlAttributes;
        }

        /**
         * Clears all XML attributes
         */
        public function clearAllXmlAttributes():void
        {
            _xmlAttributes = null;
        }

        /**
         * Sets all XML attributes from an Object, replacing any existing attributes.
         * This copies the Object's key-value pairs into the internal Dictionary.
         */
        public function setXmlAttributesFromObject(attrsObj:Object):void
        {
            if (!attrsObj)
            {
                _xmlAttributes = null;
                return;
            }

            _xmlAttributes = new Dictionary();
            for (var key:String in attrsObj)
            {
                _xmlAttributes[key] = attrsObj[key];
            }
        }

        /**
         * Deep-copies all XML attributes from another ServerItem, replacing any existing
         * attributes. Handles nested Dictionary / Array values (e.g. Canary-style nested
         * <attribute> elements such as `abilities`).
         *
         * Used by clone() (Duplicate flow) and PASTE_ATTRIBUTES handler.
         */
        public function copyXmlAttributesFrom(source:ServerItem):void
        {
            if (!source)
                return;

            var srcAttrs:Dictionary = source.getXmlAttributes();
            if (!srcAttrs)
            {
                _xmlAttributes = null;
                return;
            }

            _xmlAttributes = new Dictionary();
            for (var key:String in srcAttrs)
            {
                _xmlAttributes[key] = deepCopyAttributeValue(srcAttrs[key]);
            }
        }

        /**
         * Recursively copies an XML attribute value. Dictionary and Array containers
         * are duplicated (no shared references); primitives are passed by value.
         */
        private static function deepCopyAttributeValue(value:*):*
        {
            if (value is Dictionary)
            {
                var dictCopy:Dictionary = new Dictionary();
                for (var k:String in value)
                    dictCopy[k] = deepCopyAttributeValue(value[k]);
                return dictCopy;
            }
            if (value is Array)
            {
                var arr:Array = value as Array;
                var arrCopy:Array = new Array(arr.length);
                for (var i:int = 0; i < arr.length; i++)
                    arrCopy[i] = deepCopyAttributeValue(arr[i]);
                return arrCopy;
            }
            // Primitives (String/Number/int/uint/Boolean) — by value
            return value;
        }

        /**
         * Gets the display name - prefers nameXml over name from OTB
         */
        public function getDisplayName():String
        {
            if (nameXml && nameXml.length > 0)
                return nameXml;
            return name;
        }
    }
}
