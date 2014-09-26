Set-Variable MODULE_NAME -Option 'Constant' -Value 'biz.dfch.PS.System.Logging';
Set-Variable MODULE_VARIABLE -Option 'Constant' -Value $($MODULE_NAME.Replace('.', '_'));
Set-Variable MODULE_URI_BASE -Option 'Constant' -Value 'http://dfch.biz/PS/System/Logging/';

Set-Variable gotoSuccess -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoSuccess';
Set-Variable gotoFailure -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoFailure';

# Load module configuration file
# As (Get-Module $MODULE_NAME).ModuleBase does not return the module path during 
# module load we resort to searching the whole PSModulePath. Configuration file 
# is loaded on a first match basis.
foreach($s in $ENV:PSModulePath.Split(';')) {
	[string] $ModuleDirectoryBase = Join-Path -Path $s -ChildPath $MODULE_NAME;
	[string] $ModuleConfigFile = [string]::Format('{0}.xml', $MODULE_NAME);
	[string] $ModuleConfigurationPathAndFile = Join-Path -Path $ModuleDirectoryBase -ChildPath $ModuleConfigFile;
	if((Test-Path -Path $ModuleConfigurationPathAndFile)) {
		if(!(Test-Path variable:$MODULE_VARIABLE)) {
			$mvar = Import-Clixml -Path $ModuleConfigurationPathAndFile;
			Set-Variable -Name $MODULE_VARIABLE -Value $mvar -Description "The array contains the public configuration properties of the module '$MODULE_NAME'.`n$MODULE_URI_BASE" ;
			break;
		} # if()
	} # if()
} # foreach
if($true -ne (Test-Path variable:$MODULE_VARIABLE)) {
	Write-Error "Could not find module configuration file '$ModuleConfigFile' in 'ENV:PSModulePath'.`nAborting module import...";
	break; # Aborts loading module.
} # if()
Export-ModuleMember -Variable $MODULE_VARIABLE;

$mvar.Log4NetPathAndFileFile = Join-Path -Path $ModuleDirectoryBase -ChildPath "log4net.dll";
Add-Type -Path $mvar.Log4NetPathAndFileFile;
$mvar.Log4NetConfigurationFile = Join-Path -Path $ModuleDirectoryBase -ChildPath $mvar.Log4NetConfigurationFile;
[log4net.GlobalContext]::Properties["DirectoryBase"] = $mvar.DirectoryBase;
$datNow = [datetime]::Now;
[log4net.GlobalContext]::Properties["FileFormat"] = $datNow.ToString($mvar.DirectoryFormat);
[log4net.Config.XmlConfigurator]::ConfigureAndWatch($mvar.Log4NetConfigurationFile);
$mvar.Logger = [log4net.LogManager]::GetLogger($mvar.Log4NetLogger);
$mvar.Esacalated = [log4net.LogManager]::GetLogger("Escalated");


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

function Out-Message {
<#

.SYNOPSIS

Logs a message to default message log file.



.DESCRIPTION

Logs a message in SYSLOG format to a predefined autoselected log file in a synchronous way.



.OUTPUTS

This Cmdlet does not return a parameter.



.PARAMETER path

A SYSLOG severity. Default Informational (16).



.PARAMETER facility 

A SYSLOG facility. Default $biz_dfch_PS_System_Logging.Facility.LOCAL0 (16).



.EXAMPLE

Logs a message to with facility := LOCAL0 and severity := Info

Out-Message $biz_dfch_PS_System_Logging.Facility.LOCAL0 $biz_dfch_PS_System_Logging.Severity.INFO "function-name" "Message string"



.EXAMPLE

Logs a message to with facility := LOCAL0 and severity := Info

Out-Message 16 6 "function-name" "Message string"



.EXAMPLE 

Logs a message to with facility := LOCAL0 and severity := Informational. Full parameter names are specified.

Out-Message -Facility 16 -Severity 6 -FunctionName "function-name" -Message "Message string"



.LINK

http://dfch.biz/PS/System/Logging/Out-Message/



.NOTES

Reimplements the logging functionality from VCO.

#>
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-Message/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("sev")]
			[ValidateRange(0,7)]
			[int] $Severity = $(throw("You must specify a severity level.")), 
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[ValidateRange(0,23)]
			[int] $Facility = 0
		) # Param
    PROCESS {
				try {
					# Translate input parameters to strings
					[string] $FacilityString = $aFacility[$Facility];
					[string] $SeverityString = $aSeverity[$Severity];

					# Return if file logging option is not set
					if($true -ne $biz_dfch_PS_System_Logging.FileLogging) {
						return;
					} # if()
			
					[string] $sFileMessageFormat = "{0}|{1}|{2}|{3}|{4}";
					switch($Severity) {
					$SysLogSeverity_EMERGENCY {
						# $biz_dfch_PS_System_Logging.Logger.FatalFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
						$biz_dfch_PS_System_Logging.Esacalated.FatalFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					$SysLogSeverity_CRITICAL {
						# $biz_dfch_PS_System_Logging.Logger.FatalFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
						$biz_dfch_PS_System_Logging.Esacalated.FatalFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					$SysLogSeverity_ALERT {
						# $biz_dfch_PS_System_Logging.Logger.FatalFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
						$biz_dfch_PS_System_Logging.Esacalated.FatalFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					$SysLogSeverity_ERROR {
						$biz_dfch_PS_System_Logging.Logger.ErrorFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					$SysLogSeverity_WARN {
						$biz_dfch_PS_System_Logging.Logger.WarnFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					$SysLogSeverity_NOTICE {
						$biz_dfch_PS_System_Logging.Logger.InfoFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					$SysLogSeverity_INFO {
						$biz_dfch_PS_System_Logging.Logger.DebugFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					$SysLogSeverity_DEBUG {
						$biz_dfch_PS_System_Logging.Logger.DebugFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					default {
						$biz_dfch_PS_System_Logging.Logger.DebugFormat($sFileMessageFormat, $SeverityString, $Host.InstanceId, $biz_dfch_PS_System_Logging.EventSource, $FacilityString, $FunctionName, $Message);
					}
					} # switch
				} # try
				catch {
					Write-Verbose "catch ALL";
					Write-Verbose $_.Exception.Message;
					$error
				} # catch
				finally {
					# N/A
				} # finally
    } # PROCESS
} # function
Export-ModuleMember -Function Out-Message;

function Out-MessageEmergency() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-MessageEmergency/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[int] $Facility = 0 
		) # Param
		Out-Message -Facility $Facility -Severity $SysLogSeverity_EMERGENCY -FunctionName $FunctionName -Message $Message;
	} # function
Set-Alias -Name Log-Emergency -Value Out-MessageEmergency;
Export-ModuleMember -Function Out-MessageEmergency -Alias Log-Emergency;

function Out-MessageCritical() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-MessageCritical/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[int] $Facility = 0 
		) # Param
		Out-Message -Facility $Facility -Severity $SysLogSeverity_CRITICAL -FunctionName $FunctionName -Message $Message;
	} # function
Set-Alias -Name Log-Critical -Value Out-MessageCritical;
Export-ModuleMember -Function Out-MessageCritical -Alias Log-Critical;

function Out-MessageAlert() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-MessageAlert/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[int] $Facility = 0 
		) # Param
		Out-Message -Facility $Facility -Severity $SysLogSeverity_ALERT -FunctionName $FunctionName -Message $Message;
	} # function
Set-Alias -Name Log-Alert -Value Out-MessageAlert;
Export-ModuleMember -Function Out-MessageAlert -Alias Log-Alert;

function Out-MessageError() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-MessageError/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[int] $Facility = 0 
		) # Param
		Out-Message -Facility $Facility -Severity $SysLogSeverity_ERROR -FunctionName $FunctionName -Message $Message;
	} # function
Set-Alias -Name Log-Error -Value Out-MessageError;
Set-Alias -Name Log-Err -Value Out-MessageError;
Export-ModuleMember -Function Out-MessageError -Alias Log-Error, Log-Err;

function Out-MessageWarning() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-MessageWarning/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[int] $Facility = 0 
		) # Param
		Out-Message -Facility $Facility -Severity $SysLogSeverity_WARNING -FunctionName $FunctionName -Message $Message;
	} # function
Set-Alias -Name Log-Warning -Value Out-MessageWarning;
Set-Alias -Name Log-Warn -Value Out-MessageWarning;
Export-ModuleMember -Function Out-MessageWarning -Alias Log-Warning, Log-Warn;

function Out-MessageNotice() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-MessageNotice/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[int] $Facility = 0 
		) # Param
		Out-Message -Facility $Facility -Severity $SysLogSeverity_NOTICE -FunctionName $FunctionName -Message $Message;
} # function
Set-Alias -Name Log-Notice -Value Out-MessageNotice;
Export-ModuleMember -Function Out-MessageNotice -Alias Log-Notice;

function Out-MessageInformational() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-MessageInformational/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[int] $Facility = 0 
		) # Param
		Out-Message -Facility $Facility -Severity $SysLogSeverity_INFO -FunctionName $FunctionName -Message $Message;
} # function
Set-Alias -Name Log-Informational -Value Out-MessageInformational;
Set-Alias -Name Log-Info -Value Out-MessageInformational;
Export-ModuleMember -Function Out-MessageInformational -Alias Log-Informational, Log-Info;

function Out-MessageDebug() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Logging/Out-MessageDebug/'
    )]
    Param (
			[Parameter(Mandatory = $true)]
			[alias("fn")]
			[string] $FunctionName = $(throw("You must specify a function name for logging.")), 
			[Parameter(Mandatory = $true)]
			[alias("msg")]
			[string] $Message = $(throw("You must specify a message string for logging.")), 
			[Parameter(Mandatory = $false)]
			[alias("fac")]
			[int] $Facility = 0 
		) # Param
		Out-Message -Facility $Facility -Severity $SysLogSeverity_DEBUG -FunctionName $FunctionName -Message $Message;
} # function
Set-Alias -Name Log-Debug -Value Out-MessageDebug;
Set-Alias -Name Log-Dbg -Value Out-MessageDebug;
Export-ModuleMember -Function Out-MessageDebug -Alias Log-Debug, Log-Dbg;

# SIG # Begin signature block
# MIIcVwYJKoZIhvcNAQcCoIIcSDCCHEQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjxlpFxfzQJE7fAOgWgsJ1IFM
# Mq2gghcbMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCgwggMQoAMCAQICCwQAAAAAAS9O4TVcMA0GCSqGSIb3DQEBBQUAMFcxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290
# IENBMRswGQYDVQQDExJHbG9iYWxTaWduIFJvb3QgQ0EwHhcNMTEwNDEzMTAwMDAw
# WhcNMTkwNDEzMTAwMDAwWjBRMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTEnMCUGA1UEAxMeR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAt
# IEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsk8U5xC+1yZyqzaX
# 71O/QoReWNGKKPxDRm9+KERQC3VdANc8CkSeIGqk90VKN2Cjbj8S+m36tkbDaqO4
# DCcoAlco0VD3YTlVuMPhJYZSPL8FHdezmviaJDFJ1aKp4tORqz48c+/2KfHINdAw
# e39OkqUGj4fizvXBY2asGGkqwV67Wuhulf87gGKdmcfHL2bV/WIaglVaxvpAd47J
# MDwb8PI1uGxZnP3p1sq0QB73BMrRZ6l046UIVNmDNTuOjCMMdbbehkqeGj4KUEk4
# nNKokL+Y+siMKycRfir7zt6prjiTIvqm7PtcYXbDRNbMDH4vbQaAonRAu7cf9DvX
# c1Qf8wIDAQABo4H6MIH3MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/
# AgEAMB0GA1UdDgQWBBQIbti2nIq/7T7Xw3RdzIAfqC9QejBHBgNVHSAEQDA+MDwG
# BFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20v
# cmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2NybC5nbG9iYWxz
# aWduLm5ldC9yb290LmNybDATBgNVHSUEDDAKBggrBgEFBQcDAzAfBgNVHSMEGDAW
# gBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEAIlzF3T30
# C3DY4/XnxY4JAbuxljZcWgetx6hESVEleq4NpBk7kpzPuUImuztsl+fHzhFtaJHa
# jW3xU01UOIxh88iCdmm+gTILMcNsyZ4gClgv8Ej+fkgHqtdDWJRzVAQxqXgNO4yw
# cME9fte9LyrD4vWPDJDca6XIvmheXW34eNK+SZUeFXgIkfs0yL6Erbzgxt0Y2/PK
# 8HvCFDwYuAO6lT4hHj9gaXp/agOejUr58CgsMIRe7CZyQrFty2TDEozWhEtnQXyx
# Axd4CeOtqLaWLaR+gANPiPfBa1pGFc0sGYvYcJzlLUmIYHKopBlScENe2tZGA7Bo
# DiTvSvYLJSTvJDCCBJ8wggOHoAMCAQICEhEhQFwfDtJYiCvlTYaGuhHqRTANBgkq
# hkiG9w0BAQUFADBSMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBu
# di1zYTEoMCYGA1UEAxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAe
# Fw0xMzA4MjMwMDAwMDBaFw0yNDA5MjMwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8w
# HQYDVQQKExZHTU8gR2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxT
# aWduIFRTQSBmb3IgTVMgQXV0aGVudGljb2RlIC0gRzEwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal
# +oTDYUDFRrVZUjtCoi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1A
# cjzyCXenSZKX1GyQoHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFF
# WbIub2Jd4NkZrItXnKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7sp
# Tj1Tk7Om+o/SWJMVTLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5
# crCpGTkqUPqp0Dw6yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAO
# BgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEF
# BQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYD
# VR0TBAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAz
# hjFodHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIu
# Y3JsMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5n
# bG9iYWxzaWduLmNvbS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0O
# BBYEFNSihEo4Whh/uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0
# hZuw3WrWFKnBMA0GCSqGSIb3DQEBBQUAA4IBAQACMRQuWFdkQYXorxJ1PIgcw17s
# LOmhPPW6qlMdudEpY9xDZ4bUOdrexsn/vkWF9KTXwVHqGO5AWF7me8yiQSkTOMjq
# IRaczpCmLvumytmU30Ad+QIYK772XU+f/5pI28UFCcqAzqD53EvDI+YDj7S0r1tx
# KWGRGBprevL9DdHNfV6Y67pwXuX06kPeNT3FFIGK2z4QXrty+qGgk6sDHMFlPJET
# iwRdK8S5FhvMVcUM6KvnQ8mygyilUxNHqzlkuRzqNDCxdgCVIfHUPaj9oAAy126Y
# PKacOwuDvsu4uyomjFm4ua6vJqziNKLcIQ2BCzgT90Wj49vErKFtG7flYVzXMIIE
# rTCCA5WgAwIBAgISESFgd9/aXcgt4FtCBtsrp6UyMA0GCSqGSIb3DQEBBQUAMFEx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQD
# Ex5HbG9iYWxTaWduIENvZGVTaWduaW5nIENBIC0gRzIwHhcNMTIwNjA4MDcyNDEx
# WhcNMTUwNzEyMTAzNDA0WjB6MQswCQYDVQQGEwJERTEbMBkGA1UECBMSU2NobGVz
# d2lnLUhvbHN0ZWluMRAwDgYDVQQHEwdJdHplaG9lMR0wGwYDVQQKDBRkLWZlbnMg
# R21iSCAmIENvLiBLRzEdMBsGA1UEAwwUZC1mZW5zIEdtYkggJiBDby4gS0cwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDTG4okWyOURuYYwTbGGokj+lvB
# go0dwNYJe7HZ9wrDUUB+MsPTTZL82O2INMHpQ8/QEMs87aalzHz2wtYN1dUIBUae
# dV7TZVme4ycjCfi5rlL+p44/vhNVnd1IbF/pxu7yOwkAwn/iR+FWbfAyFoCThJYk
# 9agPV0CzzFFBLcEtErPJIvrHq94tbRJTqH9sypQfrEToe5kBWkDYfid7U0rUkH/m
# bff/Tv87fd0mJkCfOL6H7/qCiYF20R23Kyw7D2f2hy9zTcdgzKVSPw41WTsQtB3i
# 05qwEZ3QCgunKfDSCtldL7HTdW+cfXQ2IHItN6zHpUAYxWwoyWLOcWcS69InAgMB
# AAGjggFUMIIBUDAOBgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAy
# ATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVw
# b3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzA+BgNVHR8E
# NzA1MDOgMaAvhi1odHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzY29kZXNp
# Z25nMi5jcmwwUAYIKwYBBQUHAQEERDBCMEAGCCsGAQUFBzAChjRodHRwOi8vc2Vj
# dXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9nc2NvZGVzaWduZzIuY3J0MB0GA1Ud
# DgQWBBTwJ4K6WNfB5ea1nIQDH5+tzfFAujAfBgNVHSMEGDAWgBQIbti2nIq/7T7X
# w3RdzIAfqC9QejANBgkqhkiG9w0BAQUFAAOCAQEAB3ZotjKh87o7xxzmXjgiYxHl
# +L9tmF9nuj/SSXfDEXmnhGzkl1fHREpyXSVgBHZAXqPKnlmAMAWj0+Tm5yATKvV6
# 82HlCQi+nZjG3tIhuTUbLdu35bss50U44zNDqr+4wEPwzuFMUnYF2hFbYzxZMEAX
# Vlnaj+CqtMF6P/SZNxFvaAgnEY1QvIXI2pYVz3RhD4VdDPmMFv0P9iQ+npC1pmNL
# mCaG7zpffUFvZDuX6xUlzvOi0nrTo9M5F2w7LbWSzZXedam6DMG0nR1Xcx0qy9wY
# nq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0SCjyVwk92xgNxYFwITJuNQIto4zCC
# BX8wggNnoAMCAQICCmELf2sAAAAAABkwDQYJKoZIhvcNAQEFBQAwfzELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcGA1UEAxMgTWljcm9zb2Z0
# IENvZGUgVmVyaWZpY2F0aW9uIFJvb3QwHhcNMDYwNTIzMTcwMDUxWhcNMTYwNTIz
# MTcxMDUxWjBXMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1z
# YTEQMA4GA1UECxMHUm9vdCBDQTEbMBkGA1UEAxMSR2xvYmFsU2lnbiBSb290IENB
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2g7mmY3Oo+NPin778YuD
# JWvqSB/xKrC5lREEvfBj0eJnZs8c3c8bSCvujYmOmq8pgGWr6cctEsurHExwB6E9
# CjDNFY1P+N3UjFAVHO9Q7sQu9/zpUvKRfeBt1TUwjl5Dc/JB6dVq47KJOlY5OG8G
# PIhpWypNxadUuGyJzJv5PMrl/Yn1EjySeJbW3HRuk0Rh0Y3HRrJ1DoboGYrVbWzV
# eBaVounICjjr8iQTT3NUkxOFOhu8HjS1iwWMuXeLsdsfIJGrCVNukM57N3S5cEeR
# IlFjFnmusa5BJgjIGSvRRqpI1mQq14M0/ywqwWwZQ0oHhefTfPYhaO/q8lKff5OQ
# zwIDAQABo4IBIzCCAR8wEQYDVR0gBAowCDAGBgRVHSAAMDYGCSsGAQQBgjcVBwQp
# MCcGHysGAQQBgjcVCI3g0YlOhNecwweGpob7HI/Tv6YVARkCAW4CAQAwCwYDVR0P
# BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFGB7ZhpFDZfKiVAvfQTN
# NKj//P1LMB0GCSsGAQQBgjcUAgQQHg4AQwByAG8AcwBzAEMAQTAfBgNVHSMEGDAW
# gBRi+wohW39DbhHaCVRQa/XSlnHxnjBVBgNVHR8ETjBMMEqgSKBGhkRodHRwOi8v
# Y3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNyb3NvZnRDb2Rl
# VmVyaWZSb290LmNybDANBgkqhkiG9w0BAQUFAAOCAgEAE8VsXgd/PFf/mzFfP72V
# VCXGefksMQNNZGlLVtlbl2988/DQJGV1OGOYE3AWE/enAfHGI+CFhmwL8ICUWnXo
# fOQekrRzv8Gzp7AL0xiEy8wJo1ycTz6wOpwtG8QE75c3lm/l7LqsarPU4jzfiyXn
# rLxiRTHdpApy5Bv4eEMBzLo5FN5dkK7YWs9eykaBUTPVpg5YZ9PYZliIFpvusRrK
# rZEThCHamm4g79oAdCi6yV/zTV3D2iVpJVTqRLzDmykzHNY8lh+HgcVT1yonM9Qu
# GXwIWG3bThmZqepf85qdjFE6Wly9L6kINZtUp9s1GlIWMzQ6o4AEav20g4ytkM8M
# OmWW7DNOGCa4SbvrgZL/E00ySyPHM+e2cWsV9pyA5ry3bL5B1QM6cTMVAFB0Ow5d
# +Zaq7ZA+qxNMgJkmvDil6wI2iR22IL6DqxD4GZ7XY3nUrrEvYTb5SkuoM8cOckH5
# 8bGQfq5G7945e3WgQRRZBB1CvEeIuBMOBfod8ICN/3DGd9hL3EYOIxpy1b/e/qqu
# aVg8/FxG5NWBmotuZVl3GjKlkKa2ZJNk/QdTyaDeKK0qbMY40YHOmPVAGeksF0Ok
# Jl/TRDBT5B0CuqQKLxbdemAnUkK7rZg3KJfkuNJ5EeMQjEjVMF0KDFLe9YjqjRot
# Z8n0gBSEt4UM0WYopcZvJGExggSmMIIEogIBATBnMFExCzAJBgNVBAYTAkJFMRkw
# FwYDVQQKExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxTaWduIENv
# ZGVTaWduaW5nIENBIC0gRzICEhEhYHff2l3ILeBbQgbbK6elMjAJBgUrDgMCGgUA
# oHAwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJEO
# HV3tRxitnR1pfkxFqo5HT0zOMA0GCSqGSIb3DQEBAQUABIIBAJP9wroEAxKMDTUs
# nWPcMfIX6eNaPSXFjL4Y+7ZnKHl8mZeoSspDDNdxAZKbQVJ/v3YWTJFdPsli3mWL
# 7NkUsMYfX2S+12eqPL6QtwdXWlFgLeIfNQSU5ZmuMoV410/AcDgcXun0IRVSOKvr
# KrW0eTbz+fuCm89/OT8t2oFi1swyf5LdPGXLRwYbpZpHnMczozKqPFKmnqWzyKKY
# HlcWaQRkKapOn8GDGwcJFUeCIMKVLZQHwJ+CzGz0vzf/ZrVxFVPwaod+Qu8AqE1g
# IrOMqC0UQm8xQCHP4MG90g5qQCgzaeb1wuI/mmBCtqn13KhudH9DBNAqqjlW8B/x
# JpaMqhyhggKiMIICngYJKoZIhvcNAQkGMYICjzCCAosCAQEwaDBSMQswCQYDVQQG
# EwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UEAxMfR2xvYmFs
# U2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMgISESFAXB8O0liIK+VNhoa6EepFMAkG
# BSsOAwIaBQCggf0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
# CQUxDxcNMTQwNzI1MDgyMjAwWjAjBgkqhkiG9w0BCQQxFgQUebRmku2ehRX8pm7y
# 0bFidsCbSpswgZ0GCyqGSIb3DQEJEAIMMYGNMIGKMIGHMIGEBBSM5p9QEuHRqPs5
# Xi4x4rQr3js0OzBsMFakVDBSMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTEoMCYGA1UEAxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0Eg
# LSBHMgISESFAXB8O0liIK+VNhoa6EepFMA0GCSqGSIb3DQEBAQUABIIBAAylJhot
# qSc0eCQLYbSaCpZYepEREs95kNOy9oQegnQHQsolHBUKG2zGRVJo11irVtPJ47EY
# 9i0cGOqkSpHG5Q+a17dnCUlGyoRb2W2FzQ+W8IDzkqgziZ4ABe02abRLXC2ddaiH
# CbixQTIelspoHQeecs34lwnqaAeHdBJ9n12ca2A9CJJdc5rBNJQ1jPcRCLxv5IMF
# GG6sboEXzOKLHMOb/T4lAdCdirgwXNAUvO+hvxJfPWTI31w01SRhwp2xcLzZJ1Na
# QIr643ueZ46JoxlPEa19PxA8gaQpKBL1UJNIdeT9CWoAWsFycvvd3HwyNsTFRbdh
# 40D2A241iLAFRCA=
# SIG # End signature block
