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
# MIILewYJKoZIhvcNAQcCoIILbDCCC2gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUswfLiBJ/zroQ9ZZUdmre8DFQ
# x5qgggjdMIIEKDCCAxCgAwIBAgILBAAAAAABL07hNVwwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0xOTA0MTMxMDAwMDBaMFExCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxTaWduIENvZGVTaWdu
# aW5nIENBIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCyTxTn
# EL7XJnKrNpfvU79ChF5Y0Yoo/ENGb34oRFALdV0A1zwKRJ4gaqT3RUo3YKNuPxL6
# bfq2RsNqo7gMJygCVyjRUPdhOVW4w+ElhlI8vwUd17Oa+JokMUnVoqni05GrPjxz
# 7/Yp8cg10DB7f06SpQaPh+LO9cFjZqwYaSrBXrta6G6V/zuAYp2Zx8cvZtX9YhqC
# VVrG+kB3jskwPBvw8jW4bFmc/enWyrRAHvcEytFnqXTjpQhU2YM1O46MIwx1tt6G
# Sp4aPgpQSTic0qiQv5j6yIwrJxF+KvvO3qmuOJMi+qbs+1xhdsNE1swMfi9tBoCi
# dEC7tx/0O9dzVB/zAgMBAAGjgfowgfcwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFAhu2Lacir/tPtfDdF3MgB+oL1B6MEcGA1Ud
# IARAMD4wPAYEVR0gADA0MDIGCCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxz
# aWduLmNvbS9yZXBvc2l0b3J5LzAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24ubmV0L3Jvb3QuY3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB8G
# A1UdIwQYMBaAFGB7ZhpFDZfKiVAvfQTNNKj//P1LMA0GCSqGSIb3DQEBBQUAA4IB
# AQAiXMXdPfQLcNjj9efFjgkBu7GWNlxaB63HqERJUSV6rg2kGTuSnM+5Qia7O2yX
# 58fOEW1okdqNbfFTTVQ4jGHzyIJ2ab6BMgsxw2zJniAKWC/wSP5+SAeq10NYlHNU
# BDGpeA07jLBwwT1+170vKsPi9Y8MkNxrpci+aF5dbfh40r5JlR4VeAiR+zTIvoSt
# vODG3Rjb88rwe8IUPBi4A7qVPiEeP2Bpen9qA56NSvnwKCwwhF7sJnJCsW3LZMMS
# jNaES2dBfLEDF3gJ462otpYtpH6AA0+I98FrWkYVzSwZi9hwnOUtSYhgcqikGVJw
# Q17a1kYDsGgOJO9K9gslJO8kMIIErTCCA5WgAwIBAgISESFgd9/aXcgt4FtCBtsr
# p6UyMA0GCSqGSIb3DQEBBQUAMFExCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i
# YWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxTaWduIENvZGVTaWduaW5nIENB
# IC0gRzIwHhcNMTIwNjA4MDcyNDExWhcNMTUwNzEyMTAzNDA0WjB6MQswCQYDVQQG
# EwJERTEbMBkGA1UECBMSU2NobGVzd2lnLUhvbHN0ZWluMRAwDgYDVQQHEwdJdHpl
# aG9lMR0wGwYDVQQKDBRkLWZlbnMgR21iSCAmIENvLiBLRzEdMBsGA1UEAwwUZC1m
# ZW5zIEdtYkggJiBDby4gS0cwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDTG4okWyOURuYYwTbGGokj+lvBgo0dwNYJe7HZ9wrDUUB+MsPTTZL82O2INMHp
# Q8/QEMs87aalzHz2wtYN1dUIBUaedV7TZVme4ycjCfi5rlL+p44/vhNVnd1IbF/p
# xu7yOwkAwn/iR+FWbfAyFoCThJYk9agPV0CzzFFBLcEtErPJIvrHq94tbRJTqH9s
# ypQfrEToe5kBWkDYfid7U0rUkH/mbff/Tv87fd0mJkCfOL6H7/qCiYF20R23Kyw7
# D2f2hy9zTcdgzKVSPw41WTsQtB3i05qwEZ3QCgunKfDSCtldL7HTdW+cfXQ2IHIt
# N6zHpUAYxWwoyWLOcWcS69InAgMBAAGjggFUMIIBUDAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzA+BgNVHR8ENzA1MDOgMaAvhi1odHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25nMi5jcmwwUAYIKwYBBQUHAQEERDBCMEAG
# CCsGAQUFBzAChjRodHRwOi8vc2VjdXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9n
# c2NvZGVzaWduZzIuY3J0MB0GA1UdDgQWBBTwJ4K6WNfB5ea1nIQDH5+tzfFAujAf
# BgNVHSMEGDAWgBQIbti2nIq/7T7Xw3RdzIAfqC9QejANBgkqhkiG9w0BAQUFAAOC
# AQEAB3ZotjKh87o7xxzmXjgiYxHl+L9tmF9nuj/SSXfDEXmnhGzkl1fHREpyXSVg
# BHZAXqPKnlmAMAWj0+Tm5yATKvV682HlCQi+nZjG3tIhuTUbLdu35bss50U44zND
# qr+4wEPwzuFMUnYF2hFbYzxZMEAXVlnaj+CqtMF6P/SZNxFvaAgnEY1QvIXI2pYV
# z3RhD4VdDPmMFv0P9iQ+npC1pmNLmCaG7zpffUFvZDuX6xUlzvOi0nrTo9M5F2w7
# LbWSzZXedam6DMG0nR1Xcx0qy9wYnq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0S
# CjyVwk92xgNxYFwITJuNQIto4zGCAggwggIEAgEBMGcwUTELMAkGA1UEBhMCQkUx
# GTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExJzAlBgNVBAMTHkdsb2JhbFNpZ24g
# Q29kZVNpZ25pbmcgQ0EgLSBHMgISESFgd9/aXcgt4FtCBtsrp6UyMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBTz//IgZLBGKpUT4hYz9h5kMOEM9jANBgkqhkiG9w0BAQEFAASCAQBd
# Cht+5MD9KG0sV6+PIcI3lrNMEw5AKYmLpYzY3GkrHeo0eTmWA5j7v5eIB6GsRDmo
# CfO08FIAaxDoLs9iIQVoJuoWwLYDhKda1ZNYFPLlcUUkW56CbXVzvBWpkucWffia
# M58kf1odkq6bSBUBW7V9KQwFjtRaoiu6N6sUaOwnz21WC6hDodWzzhn+1O0kWe5f
# x3XNAU1ChNv+fVD67SXjYbzROKRHL5ixeHLtOxWTFRwx21cQK2LotI+HuB0/6P6g
# 3RE1ZHlCPfR73mj1/DbCzgcvT+3BNmvNe/NqRbDIDBvjulsFU8z9rFf/6TlCVMXs
# jNhRQIDJnksJaYHxLXKt
# SIG # End signature block
