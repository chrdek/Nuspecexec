using System;
using System.IO;
using System.Xml;
using System.Xml.Linq;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Data;
using System.Linq;

namespace testlinqfrm
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            XmlWriterSettings writerSetup = new XmlWriterSettings();
            writerSetup.NamespaceHandling = NamespaceHandling.OmitDuplicates;
            writerSetup.ConformanceLevel = ConformanceLevel.Document;
            writerSetup.Indent = true;

            string mainsolution = $"{this.GetType().ToString().Split('.')[0]}";
            string projectdir = (Environment.CurrentDirectory.ToString()).Replace($"\\{mainsolution}\\bin\\Debug", "\\");

            IEnumerable<string> dirs = Directory.Exists($"{projectdir}\\packages") ? Directory.EnumerateDirectories($"{projectdir}\\packages")
                                                                                   : new List<string> {""}.AsEnumerable();

            var dirpath = dirs.Select(d => d.Split('\\').Last());
            IDictionary<string, string> directoryVersion = new Dictionary<string, string>();

            foreach (var dir in dirpath) {
                var pkgver = Regex.Match(dir, "[0-9].+(.){1}").Value; //package name.
                var pkgname = Regex.Replace(dir, "[0-9].+(.){1}|[0-9].+(.){1,}|(.)[0-9].+", ""); //package version.
                
                directoryVersion.Add(pkgname, pkgver);
            }


            var initElements = directoryVersion.Select( d => new XElement("dependency", 
                new XAttribute("id", d.Key),
                new XAttribute("version", d.Value)//,
                //new XAttribute("targetFramework", $"net{System.Environment.Version.Major}{System.Environment.Version.Minor}")
                ) );

            XDocument xdoc = new XDocument();
            using (XmlWriter xmlwrite = XmlWriter.Create($"{projectdir}\\.nuspec", writerSetup))
            {
                int lic = 0; //no eula option switched on by default

                //Setting main header and ns.
                xdoc.Declaration = new XDeclaration("1.0", "utf-8", string.Empty);
                XNamespace xns = "http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd";
                XElement mainwithAttrib = new XElement(xns + "package");

                XElement numetadata = new XElement("metadata",
                    new XElement("id", new XText(Guid.NewGuid().ToString())),
                    new XElement("version", $"{System.Environment.Version.Major}.{System.Environment.Version.Minor}.{System.Environment.Version.Build}"),
                    new XElement("title", "Project Title"),
                    new XElement("authors", System.Environment.UserName),
                    new XElement("owners", System.Environment.MachineName),
                    new XElement("licenseUrl", "https://api.github.com/licences/unlicense/"),
                    new XElement("projectUrl", "http://www.google.com/"),
                    new XElement("iconUrl", $"{System.Environment.CurrentDirectory}\\favicon.ico"),
                    new XElement("requireLicenseAcceptance", (lic > 1) ? false : true),
                    new XElement("description", "Default description"),
                    new XElement("releaseNotes", "Sample Notes"),
                    new XElement("copyright", $"Copyright © {System.DateTime.Now.Year.ToString()}"),
                    new XElement("tags", System.AppContext.BaseDirectory.Replace(System.Environment.GetLogicalDrives()[0], "").Replace('\\', ',')),
                    new XElement("dependencies", initElements),
                    new XElement("summary", "Initial project's summary here..")
                     );
                XElement nufilesection = new XElement("files", new XElement("file", new XAttribute("src", "README.md"), new XAttribute("target", $"{projectdir}") ));

                xdoc.Add(mainwithAttrib);
                mainwithAttrib.Add(numetadata);
                mainwithAttrib.Add(nufilesection);
                xdoc.Save(xmlwrite);
            }
        }
    }
}