# Initial namespaces definitions
[System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq") | Out-Null;
[System.Reflection.Assembly]::LoadWithPartialName("System.Xml") | Out-Null;

# XML writer settings.
[System.Xml.XmlWriterSettings]$writerconfig = [System.Xml.XmlWriterSettings]::new();
$writerconfig.NamespaceHandling = [System.Xml.NamespaceHandling]::OmitDuplicates;
$writerconfig.ConformanceLevel = [System.Xml.ConformanceLevel]::Document;
$writerconfig.Indent = $true;


[string] $solFolder = "$(Split-Path "." -Leaf)";
[string] $projectName = (Get-ChildItem -Path "." -Filter "*.*proj").Name.Split('.')[0];
[string] $projectFolder = [System.Environment]::CurrentDirectory -ireplace "$solFolder\bin\Debug", "";
[string[]] $alldir=$null; [string[]] $alldll;
$path = $(Resolve-Path .).Path;

if (Test-Path "$($path)\bin\Debug") {
   $alldll += [System.IO.Directory]::EnumerateFiles("${path}\bin\Debug","*.dll");
}
else {
   $alldll = @("");
}

if (Test-Path "${projectFolder}\${solFolder}\packages") {
   $alldir += [System.IO.Directory]::EnumerateDirectories("${projectFolder}\${solFolder}\packages");
}
else {
   $alldir = @("");
}

$leafpaths += $alldir | %{ if(-not([System.IO.Directory]::Exists($_))) {return};$(Split-Path $_ -Leaf) }
$Dirpkgs = New-Object System.Collections.Hashtable;

$leafpaths | %{
## Key r-part.  ## Name l-part.
 $Dirpkgs.Add([Regex]::Replace("$($_)", "[0-9].+(\.){1}|[0-9].+(\.){1,}|(\.)[0-9].+",""),[Regex]::Match("$($_)", "[0-9].+(.){1}").Value);
}


$xmlmaindoc = [System.Xml.Linq.XDocument]::new();
[System.Xml.XmlWriter]$writeXml = [System.Xml.XmlWriter]::Create("$(Resolve-Path '.')\.nuspec", $writerconfig);
                                             
$versions = @(); $versions += $Dirpkgs.Values[0];
$l=0;
# Main xml namespaces and declaration.
$xmlmaindoc.Declaration = [System.Xml.Linq.XDeclaration]::new("1.0","utf-8",[string]::Empty);
[System.Xml.Linq.XNamespace]$ns = "http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd";
[System.Xml.Linq.XElement]$mainattribs = [System.Xml.Linq.XElement]::new($ns + "package");

$Name=$null;
if ($projectName -eq $null -or $projectName -eq [string]::Empty) { $Name = [Guid]::NewGuid().ToString();} else {$Name = $projectName; }

[System.Xml.Linq.XElement]$pkgmetadata = [System.Xml.Linq.XElement]::new("metadata",
                                         [System.Xml.Linq.XElement]::new("id",[System.Xml.Linq.XText]::new($Name)),
                                         [System.Xml.Linq.XElement]::new("version","$([System.Environment]::Version.Major).$([System.Environment]::Version.Minor).$([System.Environment]::Version.Build)"),
                                         [System.Xml.Linq.XElement]::new("title","Project Title"),
                                         [System.Xml.Linq.XElement]::new("authors",[System.Environment]::UserName),
                                         [System.Xml.Linq.XElement]::new("owners",[System.Environment]::MachineName),
                                         [System.Xml.Linq.XElement]::new("license","Unlicense", [System.Xml.Linq.XAttribute]::new("type","expression")),
                                         [System.Xml.Linq.XElement]::new("projectUrl","http://www.google.com/"),
                                         [System.Xml.Linq.XElement]::new("icon",".\favicon.png"),
                                         [System.Xml.Linq.XElement]::new("requireLicenseAcceptance",($([System.Environment]::Version.Major) -le 4)),
                                         [System.Xml.Linq.XElement]::new("description","Default Description"),
                                         [System.Xml.Linq.XElement]::new("releaseNotes","Sample Notes"),
                                         [System.Xml.Linq.XElement]::new("copyright","Copyright $(169 -as [char]) $([System.DateTime]::now.Year.ToString())"),
                                         [System.Xml.Linq.XElement]::new("tags",[System.AppContext]::BaseDirectory.Replace("$([System.Environment]::GetLogicalDrives()[0])","").Replace("\"," ")),
                                         [System.Xml.Linq.XElement]::new("dependencies", ($Dirpkgs.Keys | %{ [System.Xml.Linq.XElement]::new("dependency", [System.Xml.Linq.XAttribute]::new("id",($_)),
                                                                                                                                                           [System.Xml.Linq.XAttribute]::new("version",($versions[$l])));$l++
                                         })),
                                         [System.Xml.Linq.XElement]::new("summary","Initial summary here")
                                         );
[System.Xml.Linq.XElement]$pkgfiles = [System.Xml.Linq.XElement]::new("files", [System.Xml.Linq.XElement]::new("file",
                                                                               [System.Xml.Linq.XAttribute]::new("src","readme.txt"),
                                                                               [System.Xml.Linq.XAttribute]::new("target",".\")), ($alldll | %{[System.Xml.Linq.XElement]::new("file", [System.Xml.Linq.XAttribute]::new("src", "bin\Debug\$($_.Split('\')[$_.Split('\').Length-1])"),
                                                                                                                                                                                       [System.Xml.Linq.XAttribute]::new("target","~\"))
                                                                               }),
                                                                               
                                                                               [System.Xml.Linq.XElement]::new("file",
                                                                               [System.Xml.Linq.XAttribute]::new("src","favicon.png"),
                                                                               [System.Xml.Linq.XAttribute]::new("target",".\"))
                                                                               );

$xmlmaindoc.Add($mainattribs);
$mainattribs.Add($pkgmetadata);
$mainattribs.Add($pkgfiles);
$xmlmaindoc.Save($writeXml);
$writeXml.Close(); # or.. $xmlmaindoc.Declaration.ToString() | Add-Content ".\.nuspec";$xmlmaindoc.ToString() | Add-Content ".\.nuspec";