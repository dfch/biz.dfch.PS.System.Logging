biz.dfch.PS.System.Logging
==========================

[![License](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://github.com/dfch/biz.dfch.PS.System.Logging/blob/master/LICENSE)
![Version](https://img.shields.io/nuget/v/biz.dfch.PS.System.Logging.svg)


Modules: biz.dfch.PS.System.Logging

d-fens GmbH, General-Guisan-Strasse 6, CH-6300 Zug, Switzerland

This PowerShell module contains Cmdlets that allow to perform logging from your PowerShell functions and code via the Apache Log4Net library.

* You can also download this module via [NuGet](http://nuget.org) with [Install-Package biz.dfch.PS.System.Logging](https://www.nuget.org/packages/biz.dfch.PS.System.Logging/). 

* After downloading the package to a directory of your choice (_NOT_ the actual module directory) run the `install.ps1` script in the downloaded folder to copy the files to a directory inside `$ENV:PSModulePath`).

* In case you already have a previous version of this module ( < 1.0.5) in a different module directory you have to remove that module manually.

* In case you update the module in the same directory and the `log4net.dll` is still loaded you might have to restart all the PowerShell sessions to be able to overwrite the file.

* In case you changed the log settings in `biz.dfch.PS.System.Logging.xml`, `Log4netConfiguration.xml` or `log4net.xml` you have to restore the changes as they will get overwritten.

See http://d-fens.ch/2013/01/16/module-biz-dfch-ps-system-logging/ and the [Wiki](https://github.com/dfch/biz.dfch.PS.System.Logging/wiki) for more information.
