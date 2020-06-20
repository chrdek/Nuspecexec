using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using System.Text.RegularExpressions;
using System.Data;

namespace Nuspec
{
     class Program
    {
        static void Main(string[] args) {
            specgen genNuspec = new specgen();
            genNuspec.NuspecCreate();
        }
    }
}
