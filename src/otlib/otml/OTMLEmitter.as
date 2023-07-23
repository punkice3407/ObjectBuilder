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
    import com.mignari.errors.AbstractClassError;

    public class OTMLEmitter
    {
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------

        public function OTMLEmitter()
        {
            throw new AbstractClassError(OTMLEmitter);
        }

        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------

        static public function emitNode(node:OTMLNode, currentDepth:int = -1):String
        {
            var text:String = "";

            // emit nodes
            if(currentDepth >= 0)
            {
                // fill spaces for current depth
                for(var i:int = 0; i < currentDepth; i++)
                {
                    text += "  ";
                }

                // emit node tag
                if(node.hasTag)
                {
                    text += node.tag;

                    // add ':' to if the node is unique or has value
                    if(node.hasValue || node.isUnique || node.isNull)
                    {
                        text += ":";
                    }
                }
                else
                {
                    text += "-";
                }

                // emit node value
                if(node.isNull)
                {
                    text += " ~";
                }
                else if(node.hasValue)
                {
                    text += " ";

                    var value:String = node.value;

                    // emit multiline values
                    if(value.indexOf("\n") != -1)
                    {
                        if(value[value.length -1] == '\n' && value[value.length - 2] == '\n')
                        {
                            text += "|+";
                        }
                        else if(value[value.length - 1] == '\n')
                        {
                            text += "|";
                        }
                        else
                        {
                            text += "|-";
                        }

                        //  multilines
                        for(var pos:int = 0; pos < value.length; pos++)
                        {
                            text += "\n";

                            // fill spaces for multiline depth
                            for(i = 0; i < currentDepth + 1; i++)
                            {
                                text += "  ";
                            }

                            // fill until a new line
                            while(pos < value.length)
                            {
                                if(value[pos] == '\n')
                                {
                                    break;
                                }

                                text += value[pos++];
                            }
                        }
                    } // emit inline values
                    else
                    {
                        text += value;
                    }
                }
                else
                {
                    text = currentDepth == 0 ? text : "\n" + text;
                }
            }

            // emit children
            for(i = 0; i < node.length ; i++)
            {
                if(currentDepth >= 0 || i != 0)
                {
                    text += "\n";
                }

                text += emitNode(node.getChildAt(i), currentDepth + 1);
            }

            return text;
        }
    }
}
