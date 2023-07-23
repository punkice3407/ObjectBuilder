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

package otlib.otml
{
    import flash.utils.Dictionary;

    import mx.utils.StringUtil;

    public class OTMLParser
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------

        private var m_currentPosition:uint;
        private var m_currentLine:uint;
        private var m_currentDepth:uint;
        private var m_currentParent:OTMLNode;
        private var m_document:OTMLDocument;
        private var m_text:String;
        private var m_length:uint;
        private var m_parentMap:Dictionary;
        private var m_previousNode:OTMLNode;

        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function OTMLParser(document:OTMLDocument)
        {
            m_document = document;
            m_text = m_document.text;
            m_length = m_text.length;
            m_currentLine = 0;
            m_currentParent = document;
            m_parentMap = new Dictionary(true);
        }

        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------

        //--------------------------------------
        // Public
        //--------------------------------------

        public function parse():void
        {
            var line:String = getNextLine();

            while (line != null)
            {
                parseLine(line);
                line = getNextLine();
            }
        }

        //--------------------------------------
        // Private
        //--------------------------------------

        private function getNextLine():String
        {
            if (m_currentPosition >= m_length)
            {
                return null;
            }

            for (var i:uint = m_currentPosition; i < m_length; i++)
            {
                if (m_text.charAt(i) == "\n")
                {
                    m_currentLine++;
                    break;
                }
            }

            var line:String = m_text.substring(m_currentPosition, i);
            m_currentPosition = (i + 1);
            return line;
        }

        private function getLineDepth(line:String, multilining:Boolean = false):int
        {
            var spaces:uint = 0;

            // count number of spaces at the line beginning
            while (line.charAt(spaces) == " ")
            {
                spaces++;
            }

            // pre calculate depth
            var depth:int = spaces / 2;

            if(!multilining || depth <= m_currentDepth)
            {
                // check the next character is a tab
                if (line.charAt(spaces) == "\t")
                {
                    throw new OTMLError(m_document, "indentation with tabs are not allowed", m_currentLine);
                }

                // must indent every 2 spaces
                if(spaces % 2 != 0)
                {
                    throw new OTMLError(m_document, "must indent every 2 spaces", m_currentLine);
                }
            }

            return depth;
        }

        private function parseLine(line:String):void
        {
            var depth:int = getLineDepth(line);
            if(depth == -1)
            {
                return;
            }

            // remove line sides spaces
            line = StringUtil.trim(line);

            // skip empty lines
            if(line.length == 0)
            {
                return;
            }

            // skip comments
            if(line.indexOf("//") == 0)
            {
                return;
            }

            // a depth above, change current parent to the previous added node
            if(depth == m_currentDepth + 1)
            {
                m_currentParent = m_previousNode;
            }
            // a depth below, change parent to previous parent
            else if(depth < m_currentDepth)
            {
                for(var i:int = 0; i < m_currentDepth - depth; i++)
                {
                    m_currentParent = m_parentMap[m_currentParent];
                }
            }
            // if it isn't the current depth, it's a syntax error
            else if(depth != m_currentDepth)
            {
                throw new OTMLError(m_document, "invalid indentation depth, are you indenting correctly?", m_currentLine);
            }

            // sets current depth
            m_currentDepth = depth;

            // alright, new depth is set, the line is not empty and it isn't a comment
            // then it must be a node, so we parse it
            parseNode(line);
        }

        private function parseNode(data:String):void
        {
            var tag:String;
            var value:String;
            var dotsPos:int = data.indexOf(":");
            var nodeLine:uint = m_currentLine;

            // node that has no tag and may have a value
            if(data.length != 0 && data.charAt(0) == '-')
            {
                value = StringUtil.trim(data.substr(1));
            }
            // node that has tag and possible a value
            else if(dotsPos != -1)
            {
                tag = data.substr(0, dotsPos);
                if(data.length > dotsPos + 1)
                {
                    value = data.substr(dotsPos + 1);
                }
            }
            // node that has only a tag
            else
            {
                tag = data;
            }

            tag = StringUtil.trim(tag);
            value = StringUtil.trim(value);

            // TODO missing script

            // create the node
            var node:OTMLNode = OTMLNode.create(tag);
            node.isUnique = (dotsPos != -1);
            node.source = m_document.source + ":" + nodeLine;

            // ~ is considered the null value
            if(value == "~")
            {
                node.isNull = true;
            }
            else
            {
                if ((value.charAt(0) == "[") && (value.charAt(value.length - 1) == "]"))
                {
                    var tmp:String = value.substr(1, value.length - 2);
                    var tokens:Array = tmp.split(",");
                    var length:uint = tokens.length;

                    for (var i:uint = 0; i < length; i++)
                    {
                        node.writeIn(StringUtil.trim(tokens[i]));
                    }
                }
                else
                {
                    node.value = value;
                }
            }

            m_currentParent.addChild(node);
            m_parentMap[node] = m_currentParent;
            m_previousNode = node;
        }
    }
}
