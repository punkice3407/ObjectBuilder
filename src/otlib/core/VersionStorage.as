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

package otlib.core
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Dictionary;

    import nail.errors.FileNotFoundError;
    import nail.errors.NullArgumentError;
    import nail.errors.SingletonClassError;
    import nail.utils.isNullOrEmpty;

    import otlib.utils.ClientInfo;
    import otlib.utils.OTFormat;

    [Event(name="change", type="flash.events.Event")]

    public class VersionStorage extends EventDispatcher implements IVersionStorage
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var _file:File;
        private var _versions:Dictionary;
        private var _changed:Boolean;
        private var _loaded:Boolean;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get file():File { return _file; }
        public function get changed():Boolean { return _changed; }
        public function get loaded():Boolean { return _loaded; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function VersionStorage()
        {
            if (_instance)
                throw new SingletonClassError(VersionStorage);

            _instance = this;
            _versions = new Dictionary();
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function load(file:File):Boolean
        {
            if (!file)
                throw new NullArgumentError("file");

            if (!file.exists)
                throw new FileNotFoundError(file);

            if (this.loaded)
                unload();

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            var xml:XML = XML( stream.readUTFBytes(stream.bytesAvailable) );
            stream.close();

            if (xml.localName() != "versions")
                throw new Error("Invalid versions XML.");

            for each (var versionXML:XML in xml.version) {

                var version:Version = new Version();
                version.unserialize(versionXML);

                _versions[version.valueStr] = version;
            }

            _file = file;
            _changed = false;
            _loaded = true;
            dispatchEvent(new Event(Event.COMPLETE));

            return _loaded;
        }

        public function addVersion(value:uint, dat:uint, spr:uint, otb:uint):Version
        {
            if (value == 0)
                throw new ArgumentError("VersionStorage.addVersion: Invalid value.");

            if (dat == 0)
                throw new ArgumentError("VersionStorage.addVersion: Invalid dat.");

            if (spr == 0)
                throw new ArgumentError("VersionStorage.addVersion: Invalid spr.");

            var version:Version = getBySignatures(dat, spr) as Version;

            // Se a versão do cliente já existe, apenas atualizar a versão do otb.
            if (version && version.value == value) {
                if (version.otbVersion !== otb) {
                    version.otbVersion = otb;
                    _changed = true;

                    if (hasEventListener(Event.CHANGE))
                        dispatchEvent(new Event(Event.CHANGE));
                }

                return version;
            }

            var vstr:String = int(value / 100) + "." + (value % 100);
            var index:uint = 1;
            var valueStr:String = vstr;

            for each (version in _versions) {

                if (version.valueStr === valueStr) {
                    index++;
                    valueStr = vstr + " v" + index;
                }
            }

            version = new Version();
            version.value = value;
            version.valueStr = valueStr;
            version.datSignature = dat;
            version.sprSignature = spr;
            version.otbVersion = otb;

            _versions[valueStr] = version;
            _changed = true;

            if (hasEventListener(Event.CHANGE))
                dispatchEvent(new Event(Event.CHANGE));

            return version;
        }

        public function removeVersion(version:Version):Version
        {
            if (!version)
                throw new NullArgumentError("version");

            for each (var v:Version in _versions) {
                if (v === version) {
                    delete _versions[v.valueStr];

                    _changed = true;

                    if (hasEventListener(Event.CHANGE))
                        dispatchEvent(new Event(Event.CHANGE));

                    return v;
                }
            }

            return null;
        }

        public function save(file:File):void
        {
            if (!file)
                throw new NullArgumentError("file");

            if (file.extension !== OTFormat.XML)
                throw new Error("VersionStorage.save: Invalid extension");

            if (!_changed) return;

            var xml:XML = <versions/>;
            var list:Array = getList();
            var length:uint = list.length;

            for (var i:uint = 0; i < length; i++)
                xml.appendChild( list[i].serialize() );

            var xmlStr:String = '<?xml version="1.0" encoding="utf-8"?>' +
                File.lineEnding +
                xml.toXMLString();

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.WRITE);
            stream.writeUTFBytes(xmlStr);
            stream.close();

            _changed = false;
        }

        public function getList():Array
        {
            var list:Array = [];

            for each (var version:Version in _versions)
            list[list.length] = version;

            if (list.length > 1)
                list.sortOn("value", Array.NUMERIC | Array.DESCENDING);

            return list;
        }

        public function getFromClientInfo(info:ClientInfo):Version
        {
            for each (var version:Version in _versions) {
                if (version.value == info.clientVersion &&
                    version.datSignature == info.datSignature &&
                    version.sprSignature == info.sprSignature)
                    return version;
            }
            return null;
        }

        public function getByValue(value:uint):Vector.<Version>
        {
            var list:Vector.<Version> = new Vector.<Version>();

            for each (var version:Version in _versions) {
                if (version.value == value)
                    list[list.length] = version;
            }
            return list;
        }

        public function getByValueString(value:String):Version
        {
            if (!isNullOrEmpty(value)) {
                if (_versions[value] !== undefined)
                    return _versions[value];
            }
            return null;
        }

        public function getBySignatures(datSignature:uint, sprSignature:uint):Version
        {
            for each (var version:Version in _versions) {
                if (version.sprSignature == sprSignature &&
                    version.datSignature == datSignature)
                    return version;
            }
            return null;
        }

        public function getByOtbVersion(otb:uint):Vector.<Version>
        {
            var list:Vector.<Version> = new Vector.<Version>();

            for each (var version:Version in _versions) {
                if (version.otbVersion == otb)
                    list[list.length] = version;
            }
            return list;
        }

        public function unload():void
        {
            _file = null;
            _versions = new Dictionary();
            _changed = false;
            _loaded = false;
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        private static var _instance:IVersionStorage;
        public static function getInstance():IVersionStorage
        {
            if (!_instance)
                new VersionStorage();

            return _instance;
        }
    }
}

