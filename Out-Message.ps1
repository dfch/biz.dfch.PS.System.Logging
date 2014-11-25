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
<#
.SYNOPSIS

Logs a DEBUG message to the default logger.


.EXAMPLE

Log-Debug "funcenstein" ("DateTime now '{0}'" -f [DateTime]::Now)

Logs a DEBUG message for function "funcenstein" to the default logger, if enabled for this log level.


#>
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

# SIG # Begin signature block
# MIIW3AYJKoZIhvcNAQcCoIIWzTCCFskCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUswfLiBJ/zroQ9ZZUdmre8DFQ
# x5qgghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# nq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0SCjyVwk92xgNxYFwITJuNQIto4zGC
# BK4wggSqAgEBMGcwUTELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExJzAlBgNVBAMTHkdsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBHMgIS
# ESFgd9/aXcgt4FtCBtsrp6UyMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTz//IgZLBGKpUT4hYz
# 9h5kMOEM9jANBgkqhkiG9w0BAQEFAASCAQBdCht+5MD9KG0sV6+PIcI3lrNMEw5A
# KYmLpYzY3GkrHeo0eTmWA5j7v5eIB6GsRDmoCfO08FIAaxDoLs9iIQVoJuoWwLYD
# hKda1ZNYFPLlcUUkW56CbXVzvBWpkucWffiaM58kf1odkq6bSBUBW7V9KQwFjtRa
# oiu6N6sUaOwnz21WC6hDodWzzhn+1O0kWe5fx3XNAU1ChNv+fVD67SXjYbzROKRH
# L5ixeHLtOxWTFRwx21cQK2LotI+HuB0/6P6g3RE1ZHlCPfR73mj1/DbCzgcvT+3B
# NmvNe/NqRbDIDBvjulsFU8z9rFf/6TlCVMXsjNhRQIDJnksJaYHxLXKtoYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhQFwfDtJYiCvlTYaGuhHqRTAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE0MTEy
# NTE2MjU1MVowIwYJKoZIhvcNAQkEMRYEFOmuax13AdDkROxbETtw94RTNi0bMIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUjOafUBLh0aj7OV4uMeK0K947NDsw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhQFwf
# DtJYiCvlTYaGuhHqRTANBgkqhkiG9w0BAQEFAASCAQBgEbxBrCrBWv7pFyQs9EuN
# Nv4aZ+JccKMK8mhsoXVMyklgWjeYwe1FlD8wdoI4vu9nA+0neRx3ztvSEx0Aq9eC
# EDrL/uJTTmqb6uML483qOoqZhZW/v+jHn0HXXU5MHFtdxwUFO1qCkU6ryJkXpL2Z
# qNjFxTSnGhu0dPkn6hdx1sOQcn7xiAWSbAPcy/zl0SypK0maQP4BpSkIBDOvxLLL
# DnP8XsGlpHvZjckj3dEO+EnHCdX87y2lzAKpUq3U6BRtAoAx3r5tWY0iXCamXdh3
# pJAxfJQdT99eKmXYk7P4abC3ZiNriPCzYC1VGde2HA4yX3O5jGxN40jiFWTbgrXY
# SIG # End signature block
