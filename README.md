### Nuspec manifest generator via linq to xml for nuget v5.* (.NET 4+)

- Adds default content and unlicense with nuspec namespaces.
- Includes all \bin\ *.dlls in project file and project name by default.
- Runs from *.*proj folder and adds an image.
<br/>
<br/>

- Executable available.

CommandLine usage (Creates .nuspec file for nuget): 
```
C:\Users\>Nuspec.exe

C:\Users\>nuget.exe setApikey %GENGUID% -NonInteractive

C:\Users\>nuget.exe pack .nuspec -IncludeReferencedProjects -properties Configuration=Release -Force

C:\Users\>nuget.exe push *.nupkg -Source https://www.nuget.org/api/v2/package
``` 
&nbsp;
&nbsp;
<br/><br/>
