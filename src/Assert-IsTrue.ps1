function Assert-IsTrue {
<#
.SYNOPSIS
Checks if the given expression or value is true and throws an exception if false.

.OUTPUTS
The Cmdlet returns `$null`.

.DESCRIPTION
Checks if the given expression or value is true and throws an exception if false.

The Cmdlet has two aliases which should only be used (instead of the real Cmdlet name):

* Contract-Requires

  Use 'Contract-Requires' only at the beginning of a function to check input parameters and perform input validation (though technically you can use the Cmdlet anywhere in your code). The reason behind this is, that the resulting error message will show that an input error to a method has been encountered. It furthermore helps to add input requirements for a Cmdlet to the internal help of a Cmdlet.

* Contract-Assert

  Use 'Contract-Assert' anywhere in your code where you want to assert a given condition, such as the string length of a return value from a called Cmdlet or method.

These names are derived from the method names of the Code Contracts library in the .NET framework (see https://msdn.microsoft.com/en-us/library/dd264808 for details). The Cmdlet checks if the result of the condition or expression evaluates to true and throws an exception if the result is false. It will then call `Out-MessageException` to log the error to the defined log destination and additionally output a warning to the Console via `Write-Warning` (though technically an error occurred).

The `FullQualifiedErrorId` will be set to 'Contract-Requires' or 'Contract-Assert' respectively, to facilitate parsing of these exceptions. In addition, the 'ErrorCategory' will be set to 'InvaidArgument' for precondition failures and 'InvalidResult' for assertion failures. See the example section for examples of error messages.

In contrast to .NET code contracts this exception can be caught. However, you are encouraged not to catch these exceptions as they indicate an error in the script (which might be caused by erroneous input).

.EXAMPLE
This example uses the 'Contract-Assert' alias to indicate a runtime condition that is expected to be met. In this example we add an input to an internal variable and require the result to be smaller or equal to $resultMax.

function Funcadelic($InputObject)
{
	# Input validation
	# ...

	# main function code goes here ...
	$a = 3;
	$resultMax = 32;
	$result = $a + $InputObject;
	Contract-Assert ($result -le $resultMax);
}

An error resulting of this assertion failure will be shown on the console like this:

> WARNING: Funcadelic: Assertion failed: ($result -le $resultMax)

The log will then contain an error like this (along with a stack strace and the line number where the error occurred):

> |Funcadelic|[Contract-Assert] 'Assertion failed: ($result -le $resultMax)' [System.Management.Automation.RuntimeException]

.EXAMPLE
This example uses the 'Contract-Requires' alias to indicate a precondition to one of its input parameters. In this example we require $InputObject not to be $null or empty, be coercible to type string and not be a larger than 5 characters.

function Funcenstein($InputObject)
{
	# Input validation
	Contract-Requires ($null -ne $InputObject);
	Contract-Requires (![string]::IsNullOrWhiteSpace($InputObject));
	Contract-Requires ($InputObject -is [string]);
	Contract-Requires (5 -lt $InputObject.Count);
	
	# main function code goes here ...
}

An error resulting of this precondition failure will be shown on the console like this:

> WARNING: Funcenstein: Precondition failed: ($null -ne $InputObject)
> WARNING: Funcenstein: Precondition failed: ($InputObject -is [string])
> WARNING: Funcenstein: Precondition failed: (![string]::IsNullOrWhitespace($InputObject))
> WARNING: Funcenstein: Precondition failed: (5 -lt $InputObject.Count)

The log will then contain an error like this (along with a stack strace and the line number where the error occurred):

> |Funcenstein|[Contract-Requires] 'Precondition failed: ($null -ne $InputObject)' [System.Management.Automation.RuntimeException]
> |Funcenstein|[Contract-Requires] 'Precondition failed: ($InputObject -is [string])' [System.Management.Automation.RuntimeException]
> |Funcenstein|[Contract-Requires] 'Precondition failed: (![string]::IsNullOrWhitespace($InputObject))' [System.Management.Automation.RuntimeException]
> |Funcenstein|[Contract-Requires] 'Precondition failed: (5 -lt $InputObject.Count)' [System.Management.Automation.RuntimeException]

.EXAMPLE
This exmample uses 'Contract-Requires' to validate the input length of a parameter and supplies a custom message that will be additionally written to the log if the precondition fails.

function FuncNFurter($InputObject)
{
	# Input validation
	Contract-Requires (15 -lt $Computername.Count) "A computer name must be longer than 15 characters";
	
	# main function code goes here ...
}

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/System/Logging/Assert-IsTrue/

.NOTES
See module manifest for dependencies and further requirements.

#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Logging/Assert-IsTrue/'
)]
PARAM
(
	# The conditional expression to test
	[Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
	[AllowNull()]
	[System.Object]
	$Condition
	,
	# A message to display if the condition is not met
	[Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 1)]
	[AllowNull()]
	[string] $Message 
)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) 
	{
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $failed = !(($Condition -is [System.Boolean]) -and $Condition);
	if(!$failed)
	{
		return;
	}

	$callStack = Get-PSCallStack;
	$InvocationName = $callStack[0].InvocationInfo.InvocationName;
	if($InvocationName -eq 'Contract-Assert')
	{
		$msg = $callStack[0].InvocationInfo.Line.Replace($InvocationName, 'Assertion failed:').Trim().TrimEnd(';');
		$category = 'InvalidResult';
	}
	elseif($InvocationName -eq 'Contract-Requires')
	{
		$msg = $callStack[0].InvocationInfo.Line.Replace($InvocationName, 'Precondition failed:').Trim().TrimEnd(';');
		$category = 'InvalidArgument';
	}
	else
	{
		Write-Warning "Use 'Contract-Requires' or 'Contract-Assert' instead of real Cmdlet name.";
		$msg = $callStack[0].InvocationInfo.Line.Replace($InvocationName, 'Condition failed:').Trim().TrimEnd(';');
		$category = 'NotSpecified';
	}
	
	Write-Warning ('{0}: {1}' -f $callStack[1].InvocationInfo.InvocationName, $msg);
	$errorRecord = New-CustomErrorRecord -msg $msg -cat $category -o $callStack[0].InvocationInfo.Line -id $InvocationName;
	throw $errorRecord;
}

Set-Alias Contract-Assert Assert-IsTrue
Set-Alias Contract-Requires Assert-IsTrue
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Assert-IsTrue -Alias @('Contract-Requires', 'Contract-Assert'); } 

#
# Copyright 2015 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqksthgrNZpundppGxeR11aoT
# xOmgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAzMDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAgDLcB40coJydPCroPSGLWaFN
# fsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4
# A11P2RwumODpiObs1wV+Vip79xZbo62PlyUShBuyXGNKCtLvEFRHgoQ1aSicDOQf
# FBYk+nXcdHJuTsrjakOvz302SNG96QaRLC+myHH9z73YnSGY/K/b3iKMr6fzd++d
# 3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUHCya9vm0CXrG4sFhshToN9v9aJwzF3lPn
# VDxWTMlOTDD28lz7GozCgr6tWZH2G01Ve89bAdz9etNvI1wyR5sB88FRFEaKmzCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQKB+mKxL6BYvO/
# FWUMjAakjVPU7DANBgkqhkiG9w0BAQEFAASCAQC8kVjdXwzinvRr0j9fCduZfY7m
# xyomTajL5nDTxAeqPVlA2ygvhZ1bzzDddwVPZh2qHc/Ej0cbjRHvfDtUv2+C68of
# wjMEuyNqvJTqVBM18bDpRL1ep5h3BgbsdO1tfFfCpTLl9l5+N5LZRFJJQtftDESR
# SgBJFXi7vDj/FTN6j6U4Bv4yjRfbSYIQGhfchf6eE/smNUvc3jQzES1LNqWsSJWi
# cnCZWOjcXy6GR2iaayANyBK61tTAvs6CdRD+hYhoI6k2xwhgkV/9c+7D1mnI+2+h
# ZO4nR5QpAtFTlnX+qerk4/trfOcRaOWiGw0VXkPLpk8pI04EROxE+ztMFbl5oYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTIyMDE0MzU0MFowIwYJKoZIhvcNAQkEMRYEFJaj30dYk4KrUsADVGz3twSDtyYA
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQAj6mYQFO+AC2baKaqC
# eM13p6tJoYw2wwzB9HBVU100o7NBTHdu9VDJhbHe3spruKkVR7sv9opS7ZQhYPbq
# /dUJLOEtnUjx/7lLoljdXRBFhE4iA8NReSFGRtHxJJR2AP/4VUmP/gwTZPrjI+1V
# Q+e015QVkZ2lqpECa/aQYMvpX4GY4csPC743kaOfLbN+LGhFPISFYxlzo8RLYoGc
# tnY3gticukTUhJQCAlZwlaxqj4QRFHBYjUnrXrjbJC273Zg2uR/ni10TOpzoqaCy
# KwDTSs13AFCQ8rxpAomivG1MMPI5VHRXywOHsthbl3cXTx77hrEV4ma/hxerh0YO
# vfrC
# SIG # End signature block
