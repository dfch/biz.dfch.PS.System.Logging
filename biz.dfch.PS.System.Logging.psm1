Set-Variable MODULE_NAME -Option 'Constant' -Value 'biz.dfch.PS.System.Logging';
Set-Variable MODULE_VARIABLE -Option 'Constant' -Value $($MODULE_NAME.Replace('.', '_'));
Set-Variable MODULE_URI_BASE -Option 'Constant' -Value 'http://dfch.biz/biz/dfch/PS/System/Logging/';

Set-Variable gotoSuccess -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoSuccess';
Set-Variable gotoError -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoError';
Set-Variable gotoFailure -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoFailure';
Set-Variable gotoNotFound -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoNotFound';

[string] $ModuleConfigFile = '{0}.xml' -f (Get-Item $PSCommandPath).BaseName;
[string] $ModuleConfigurationPathAndFile = Join-Path -Path $PSScriptRoot -ChildPath $ModuleConfigFile;
$mvar = $ModuleConfigFile.Replace('.xml', '').Replace('.', '_');
if($true -eq (Test-Path -Path $ModuleConfigurationPathAndFile)) {
	if($true -ne (Test-Path variable:$($mvar))) {
		Set-Variable -Name $mvar -Value (Import-Clixml -Path $ModuleConfigurationPathAndFile);
	} # if()
} # if()
if($true -ne (Test-Path variable:$($mvar))) {
	Write-Error "Could not find module configuration file '$ModuleConfigFile' in 'ENV:PSModulePath'.`nAborting module import...";
	break; # Aborts loading module.
} # if()
Export-ModuleMember -Variable $mvar;

# $mvar.Log4NetPathAndFileFile = Join-Path -Path $ModuleDirectoryBase -ChildPath "log4net.dll";
# Add-Type -Path $mvar.Log4NetPathAndFileFile;
# $mvar.Log4NetConfigurationFile = Join-Path -Path $ModuleDirectoryBase -ChildPath $mvar.Log4NetConfigurationFile;
[log4net.GlobalContext]::Properties["DirectoryBase"] = (Get-Variable -Name $mvar).Value.DirectoryBase
$datNow = [datetime]::Now;
[log4net.GlobalContext]::Properties["FileFormat"] = $datNow.ToString((Get-Variable -Name $mvar).Value.DirectoryFormat);
if( !(Test-Path ((Get-Variable -Name $mvar).Value.Log4NetConfigurationFile)) )
{
	(Get-Variable -Name $mvar).Value.Log4NetConfigurationFile = Join-Path $PSScriptRoot -ChildPath (Get-Variable -Name $mvar).Value.Log4NetConfigurationFile;
}
[log4net.Config.XmlConfigurator]::ConfigureAndWatch((Get-Variable -Name $mvar).Value.Log4NetConfigurationFile);
(Get-Variable -Name $mvar).Value.Logger = [log4net.LogManager]::GetLogger((Get-Variable -Name $mvar).Value.Log4NetLogger);
(Get-Variable -Name $mvar).Value.Esacalated = [log4net.LogManager]::GetLogger("Escalated");

Set-Variable -Name LOGGING_LOCK_PREFIX -Option 'Constant' -Value 'Global\biz-dfch-file-';

Set-Variable -Name SysLogSeverity_EMERGENCY -Value 0;
Set-Variable -Name SysLogSeverity_ALERT -Value 1;
Set-Variable -Name SysLogSeverity_CRITICAL -Value 2;
Set-Variable -Name SysLogSeverity_ERROR -Value 3;
Set-Variable -Name SysLogSeverity_ERR -Value 3;
Set-Variable -Name SysLogSeverity_WARNING -Value 4;
Set-Variable -Name SysLogSeverity_WARN -Value 4;
Set-Variable -Name SysLogSeverity_NOTICE -Value 5;
Set-Variable -Name SysLogSeverity_INFORMATIONAL -Value 6;
Set-Variable -Name SysLogSeverity_INFO -Value 6;
Set-Variable -Name SysLogSeverity_DEBUG -Value 7;
Set-Variable -Name SysLogSeverity_DBG -Value 7;

[string[]] $aSeverity = @('EMERGENCY', 'ALERT', 'CRITICAL', 'ERROR', 'WARNING', 'NOTICE', 'INFO', 'DEBUG');

[string[]] $aFacility = @('NONE', 'Startup and Initialisation', 'Cleanup and Termination', 'Exception and Error Handling', 'AUTH', 'SYSLOG', 'LPR', 'NEWS', 'UUCP', 'CRON', 'AUTHPRIV', 'FTP', 'NTP', 'AUDIT', 'ALERT', 'CLOCK', 'LOCAL0', 'LOCAL1', 'LOCAL2', 'LOCAL3', 'LOCAL4', 'LOCAL5', 'LOCAL6', 'LOCAL7');
