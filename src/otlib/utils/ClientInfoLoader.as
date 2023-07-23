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

package otlib.utils
{
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Endian;

    import nail.errors.NullArgumentError;
    import nail.utils.FileUtil;

    import otlib.core.Version;
    import otlib.core.VersionStorage;
    import otlib.resources.Resources;

    [Event(name="complete", type="flash.events.Event")]
    [Event(name="progress", type="flash.events.ProgressEvent")]
    [Event(name="error", type="flash.events.ErrorEvent")]

    [ResourceBundle("strings")]

    public class ClientInfoLoader extends EventDispatcher
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_otfi:File;
        private var m_dat:File;
        private var m_spr:File;
        private var m_clientInfo:ClientInfo;
        private var m_total:uint;
        private var m_loaded:uint;

        //--------------------------------------
        // Getters / Setters
        //--------------------------------------

        public function get clientInfo():ClientInfo { return m_clientInfo; }

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function ClientInfoLoader()
        {
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function load(dat:File, spr:File, extended:Boolean):void
        {
            if (!dat)
                throw new NullArgumentError("dat");

            if (!spr)
                throw new NullArgumentError("spr");

            if (!dat.exists)
                dispatchEvent(createErrorEvent(Resources.getString("datFileNotFound")));

            if (!spr.exists)
                dispatchEvent(createErrorEvent(Resources.getString("sprFileNotFound")));

            // Seachs for otfi file
            var result:Vector.<File> = FileUtil.findExtension(dat, "otfi");
            if (result.length != 0)
                m_otfi = result[0];

            m_dat = dat;
            m_spr = spr;
            m_clientInfo = new ClientInfo();
            m_clientInfo.extended = extended;
            m_total = 3;

            loadNext();
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function loadNext():void
        {
            m_loaded++;

            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, m_loaded, m_total));

            if (m_loaded == 1)
                loadOTFI();
            if (m_loaded == 2)
                loadDat();
            else if (m_loaded == 3)
                loadSpr();
            else
                dispatchEvent(new Event(Event.COMPLETE));
        }

        private function loadOTFI():void
        {
            if (m_otfi)
            {
                var otfi:OTFI = new OTFI();
                if (otfi.load(m_otfi))
                {
                    m_clientInfo.extended = otfi.extended;
                    m_clientInfo.transparency = otfi.transparency;
                    m_clientInfo.improvedAnimations = otfi.improvedAnimations;
                    m_clientInfo.frameGroups = otfi.frameGroups;
                    m_clientInfo.spriteSize = otfi.spriteSize;
                    m_clientInfo.spriteDataSize = otfi.spriteDataSize;
                }
            }

            loadNext();
        }

        private function loadDat():void
        {
            var stream:FileStream = new FileStream();
            stream.endian = Endian.LITTLE_ENDIAN;
            stream.addEventListener(ProgressEvent.PROGRESS, metadataProgressHandler);
            stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            stream.openAsync(m_dat, FileMode.READ);
        }

        private function loadSpr():void
        {
            var stream:FileStream = new FileStream();
            stream.endian = Endian.LITTLE_ENDIAN;
            stream.addEventListener(ProgressEvent.PROGRESS, spritesProgressHandler);
            stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            stream.openAsync(m_spr, FileMode.READ);
        }

        //--------------------------------------
        // Event Handlers
        //--------------------------------------

        private function readMetadaInfo(stream:FileStream):void
        {
            m_clientInfo.datSignature = stream.readUnsignedInt();
            m_clientInfo.maxItemId = stream.readUnsignedShort();
            m_clientInfo.maxOutfitId = stream.readUnsignedShort();
            m_clientInfo.maxEffectId = stream.readUnsignedShort();
            m_clientInfo.maxMissileId = stream.readUnsignedShort();

            loadNext();
        }

        private function readSpritesInfo(stream:FileStream):void
        {
            m_clientInfo.sprSignature = stream.readUnsignedInt();

            var version:Version = VersionStorage.getInstance().getBySignatures(
                m_clientInfo.datSignature,
                m_clientInfo.sprSignature);

            if (!version)
            {
                m_clientInfo.maxItemId = 0;
                m_clientInfo.maxOutfitId = 0;
                m_clientInfo.maxEffectId = 0;
                m_clientInfo.maxMissileId = 0;
                m_clientInfo.maxSpriteId = 0;

                dispatchEvent(new Event(Event.COMPLETE));
                dispatchEvent( createErrorEvent( Resources.getString("unsupportedVersion") ) );
                return;
            }

            m_clientInfo.clientVersion = version.value;
            m_clientInfo.clientVersionStr = version.valueStr;

            if (m_clientInfo.extended || version.value >= 960)
            {
                m_clientInfo.maxSpriteId = stream.readUnsignedInt();
                m_clientInfo.extended = true;
            }
            else
                m_clientInfo.maxSpriteId = stream.readUnsignedShort();

            loadNext();
        }

        private function metadataProgressHandler(event:ProgressEvent):void
        {
            var stream:FileStream = event.target as FileStream;
            if (stream.bytesAvailable >= 12)
                readMetadaInfo(stream);

            stream.removeEventListener(ProgressEvent.PROGRESS, metadataProgressHandler);
            stream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            stream.close();
        }

        private function spritesProgressHandler(event:ProgressEvent):void
        {
            var stream:FileStream = event.target as FileStream;
            if (stream.bytesAvailable >= 8)
                readSpritesInfo(stream);

            stream.removeEventListener(ProgressEvent.PROGRESS, spritesProgressHandler);
            stream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            stream.close();
        }

        private function ioErrorHandler(event:IOErrorEvent):void
        {
            m_clientInfo = null;
            dispatchEvent( createErrorEvent(event.text, event.errorID) );
        }

        private function createErrorEvent(text:String, id:uint = 0):ErrorEvent
        {
            return new ErrorEvent(ErrorEvent.ERROR, false, false, text, id);
        }
    }
}
