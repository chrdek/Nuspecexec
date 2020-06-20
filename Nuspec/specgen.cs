using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Xml;
using System.Xml.Linq;
using System.Text.RegularExpressions;

namespace Nuspec
{
    public class specgen
    {
        public void NuspecCreate()
        {
            XmlWriterSettings writerSetup = new XmlWriterSettings();
            writerSetup.NamespaceHandling = NamespaceHandling.OmitDuplicates;
            writerSetup.ConformanceLevel = ConformanceLevel.Document;
            writerSetup.Indent = true;


            var projectname = Directory.EnumerateFiles(Environment.CurrentDirectory, "*.*proj").Select(project => project.Split('\\').Last().Split('.')[0]).First();
            string projectdir = (Environment.CurrentDirectory.Replace($"\\{projectname}\\{projectname}", $"\\{projectname}"));

            //Including additional local files for pre-build/deploy operations..
            IEnumerable<string> dlls = Directory.Exists($"{Environment.CurrentDirectory.ToString()}\\bin\\Debug") ? Directory.EnumerateFiles($"{Environment.CurrentDirectory.ToString()}\\bin\\Debug", "*.dll")
                                                                                                                  : new List<string> { "" }.AsEnumerable();

            IEnumerable<string> dirs = Directory.Exists($"{projectdir}\\packages") ? Directory.EnumerateDirectories($"{projectdir}\\packages")
                                                                                   : new List<string> { "" }.AsEnumerable();

            var dirpath = dirs.Select(d => d.Split('\\').Last()); var dllfiles = dlls.Select(dll => new XElement("file", new XAttribute("src", $"bin\\Debug\\{dll.Split('\\').Last()}"),
                                                                                                                         new XAttribute("target", @"~\")));
            IDictionary<string, string> directoryVersion = new Dictionary<string, string>();

            foreach (var dir in dirpath)
            {
                var pkgver = Regex.Match(dir, "[0-9].+(.){1}").Value; //package name.
                var pkgname = Regex.Replace(dir, "[0-9].+(.){1}|[0-9].+(.){1,}|(.)[0-9].+", ""); //package version.

                directoryVersion.Add(pkgname, pkgver);
            }

            var initElements = directoryVersion.Select(d => new XElement("dependency",
               new XAttribute("id", d.Key),
               new XAttribute("version", d.Value)
               ));

            XDocument xdoc = new XDocument();
            using (XmlWriter xmlwrite = XmlWriter.Create($"{Environment.CurrentDirectory}\\.nuspec", writerSetup))
            {
                //Setting main header and ns.
                xdoc.Declaration = new XDeclaration("1.0", "utf-8", string.Empty);
                XNamespace xns = "http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd";
                XElement mainwithAttrib = new XElement(xns + "package");

                XElement numetadata = new XElement("metadata",
                    new XElement("id", new XText((projectname == null || projectname == string.Empty) ? Guid.NewGuid().ToString() : projectname)),
                    new XElement("version", $"{System.Environment.Version.Major}.{System.Environment.Version.Minor}.{System.Environment.Version.Build}"),
                    new XElement("title", "Project Title"),
                    new XElement("authors", System.Environment.UserName),
                    new XElement("owners", System.Environment.MachineName),
                    new XElement("license", "Unlicense", new XAttribute("type", "expression")),        // licensing defs @ https://sdpx.org/licenses/, unlicense info @ https://api.github.com/licences/unlicense/
                    new XElement("projectUrl", "http://www.google.com/"),                              // default project url is set. change according to repo/web source
                    new XElement("icon", ".\\favicon.png"),                                            // recommended image type=png, dimens=128px
                    new XElement("requireLicenseAcceptance", (System.Environment.Version.Major <= 4)), // eula option switched off for net versions greater than 4
                    new XElement("description", "Default description"),
                    new XElement("releaseNotes", "Sample Notes"),
                    new XElement("copyright", $"Copyright © {System.DateTime.Now.Year.ToString()}"),
                    new XElement("tags", System.AppContext.BaseDirectory.Replace(System.Environment.GetLogicalDrives()[0], "").Replace('\\', ' ')),
                    new XElement("dependencies", initElements),
                    new XElement("summary", "Initial project's summary here..")
                    );
                XElement nufilesection = new XElement("files", new XElement("file", new XAttribute("src", "readme.*"),
                                                                                    new XAttribute("target", @".\")), dllfiles,
                                                               new XElement("file", new XAttribute("src", "favicon.png"),
                                                                                    new XAttribute("target", @".\"))
                                                               );

                xdoc.Add(mainwithAttrib);
                mainwithAttrib.Add(numetadata);
                mainwithAttrib.Add(nufilesection);
                xdoc.Save(xmlwrite);
            }
        }
    }
}
