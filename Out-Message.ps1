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

http://dfch.biz/biz/dfch/PS/System/Logging/Out-Message/



.NOTES

Reimplements the logging functionality from VCO.

#>
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-Message/'
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
			
					[string] $sFileMessageFormat = "{0}|{1}|{2}|{3}|{4}|{5}";
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-Message; }

function Out-MessageEmergency() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageEmergency/'
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageEmergency -Alias Log-Emergency; }

function Out-MessageCritical() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageCritical/'
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageCritical -Alias Log-Critical; }

function Out-MessageAlert() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageAlert/'
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageAlert -Alias Log-Alert; }

function Out-MessageError() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageError/'
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageError -Alias Log-Error, Log-Err; }

function Out-MessageWarning() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageWarning/'
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageWarning -Alias Log-Warning, Log-Warn; }

function Out-MessageNotice() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageNotice/'
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageNotice -Alias Log-Notice; }

function Out-MessageInformational() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageInformational/'
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageInformational -Alias Log-Informational, Log-Info; }

function Out-MessageDebug() {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageDebug/'
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
Set-Alias -Name Log-Debug -Value 'Out-MessageDebug';
Set-Alias -Name Log-Dbg -Value 'Out-MessageDebug';
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageDebug -Alias Log-Debug, Log-Dbg; } 
