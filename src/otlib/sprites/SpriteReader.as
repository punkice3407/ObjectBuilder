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

package otlib.sprites
{
    import flash.filesystem.FileStream;
    import flash.utils.Endian;

    public class SpriteReader extends FileStream implements ISpriteReader
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_extended:Boolean;
        private var m_transparency:Boolean;
        private var m_headerSize:uint;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function SpriteReader(extended:Boolean, transparency:Boolean)
        {
            m_extended = extended;
            m_transparency = transparency;
            m_headerSize = extended ? SpriteFileSize.HEADER_U32 : SpriteFileSize.HEADER_U16;

            endian = Endian.LITTLE_ENDIAN;
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function readSignature():uint
        {
            position = SpriteFilePosition.SIGNATURE;
            return readUnsignedInt();
        }

        public function readSpriteCount():uint
        {
            position = SpriteFilePosition.LENGTH;
            return m_extended ? readUnsignedInt() : readUnsignedShort();
        }

        public function readSprite(id:uint):Sprite
        {
            position = ((id - 1) * SpriteFileSize.ADDRESS) + m_headerSize;

            var address:uint  = readUnsignedInt();
            if (address == 0)
                return null;

            position = address;
            readUnsignedByte(); // skip red color
            readUnsignedByte(); // skip green color
            readUnsignedByte(); // skip blue color

            var sprite:Sprite = new Sprite(id, m_transparency);
            var length:uint = readUnsignedShort();

            if (length != 0)
                readBytes(sprite.compressedPixels, 0, length);

            return sprite;
        }

        public function isEmptySprite(id:uint):Boolean
        {
            position = ((id - 1) * SpriteFileSize.ADDRESS) + m_headerSize;

            var address:uint = readUnsignedInt();
            if (address == 0)
                return true;

            position = address;
            readUnsignedByte(); // skip red color
            readUnsignedByte(); // skip green color
            readUnsignedByte(); // skip blue color

            return readUnsignedShort() == 0;
        }
    }
}
