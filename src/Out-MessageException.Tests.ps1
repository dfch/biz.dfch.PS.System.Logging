Set-Variable gotoSuccess -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoSuccess';
Set-Variable gotoError -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoError';
Set-Variable gotoFailure -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoFailure';

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

# this function exists only for performance reasons
# it corresponds to the test 'Out-MessageExceptionStringBuilderStatic'
Set-Variable sb -Option 'Constant' -Value (New-Object System.Text.StringBuilder);
function Out-MessageExceptionStringBuilderStatic {
PARAM
(
	[System.Management.Automation.ErrorRecord] $ErrorRecord
)

	if($gotoSuccess -eq $ErrorRecord.Exception.Message) 
	{
		$fReturn = $true;
	} 
	else 
	{
		
		$callStack = Get-PSCallStack;
		$fn = $callStack[1].Command;
		$sb.Clear();
		$null = $sb.Append(("[{0}] '{1}' [{2}]" -f $ErrorRecord.FullyQualifiedErrorId, $ErrorRecord.Exception.Message, $ErrorRecord.Exception.GetType()));
		$null = $sb.Append((Out-String -InputObject (fl -Property * -Force -InputObject $ErrorRecord.Exception)));
		$null = $sb.Append((Out-String -InputObject (Format-Table -AutoSize -Property Location,Command,Arguments -InputObject (Get-PSCallStack))));
		[string] $ErrorText = $sb.ToString();
		
		if($ErrorRecord.Exception -is [System.Net.WebException]) 
		{
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $ErrorRecord.Exception.Status, $ErrorRecord);
			Log-Debug $fn $ErrorText -fac 3;
		} 
		else 
		{
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $ErrorRecord.Exception.Message) 
			{
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} 
			elseif($gotoFailure -ne $ErrorRecord.Exception.Message) 
			{ 
				Write-Verbose ("$fn`n$ErrorText"); 
			} 
			else 
			{
				# N/A
			}
		} 
		$fReturn = $false;
		$OutputParameter = $null;
	} 
}

function Out-MessageExceptionStringBuilder {
PARAM
(
	[System.Management.Automation.ErrorRecord] $ErrorRecord
)

	if($gotoSuccess -eq $ErrorRecord.Exception.Message) 
	{
		$fReturn = $true;
	} 
	else 
	{
		
		$callStack = Get-PSCallStack;
		$fn = $callStack[1].Command;
		$sb = New-Object System.Text.StringBuilder;
		$null = $sb.Append(("[{0}] '{1}' [{2}]" -f $ErrorRecord.FullyQualifiedErrorId, $ErrorRecord.Exception.Message, $ErrorRecord.Exception.GetType()));
		$null = $sb.Append((Out-String -InputObject (fl -Property * -Force -InputObject $ErrorRecord.Exception)));
		$null = $sb.Append((Out-String -InputObject (Format-Table -AutoSize -Property Location,Command,Arguments -InputObject (Get-PSCallStack))));
		[string] $ErrorText = $sb.ToString();
		$sb.Clear();
		$sb = $null;
		
		if($ErrorRecord.Exception -is [System.Net.WebException]) 
		{
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $ErrorRecord.Exception.Status, $ErrorRecord);
			Log-Debug $fn $ErrorText -fac 3;
		} 
		else 
		{
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $ErrorRecord.Exception.Message) 
			{
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} 
			elseif($gotoFailure -ne $ErrorRecord.Exception.Message) 
			{ 
				Write-Verbose ("$fn`n$ErrorText"); 
			} 
			else 
			{
				# N/A
			}
		} 
		$fReturn = $false;
		$OutputParameter = $null;
	} 
}

function Out-MessageExceptionStringAppend {
PARAM
(
	[System.Management.Automation.ErrorRecord] $ErrorRecord
)

	if($gotoSuccess -eq $ErrorRecord.Exception.Message) 
	{
		$fReturn = $true;
	} 
	else 
	{
		
		$callStack = Get-PSCallStack;
		$fn = $callStack[1].Command;
		[string] $ErrorText = ("[{0}] '{1}' [{2}]" -f $ErrorRecord.FullyQualifiedErrorId, $ErrorRecord.Exception.Message, $ErrorRecord.Exception.GetType());
		$ErrorText += (Out-String -InputObject (fl -Property * -Force -InputObject $ErrorRecord.Exception));
		$ErrorText += (Out-String -InputObject (Format-Table -AutoSize -Property Location,Command,Arguments -InputObject (Get-PSCallStack)));
		
		if($ErrorRecord.Exception -is [System.Net.WebException]) 
		{
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $ErrorRecord.Exception.Status, $ErrorRecord);
			Log-Debug $fn $ErrorText -fac 3;
		} 
		else 
		{
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $ErrorRecord.Exception.Message) 
			{
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} 
			elseif($gotoFailure -ne $ErrorRecord.Exception.Message) 
			{ 
				Write-Verbose ("$fn`n$ErrorText"); 
			} 
			else 
			{
				# N/A
			}
		} 
		$fReturn = $false;
		$OutputParameter = $null;
	} 
}

function Out-MessageError {
	return;
}

Describe -Tags "Out-MessageException" "Out-MessageException" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	
	BeforeEach {
		# N/A
	}

	Context "Out-MessageException" {
	
		# Context wide constants
		# N/A

		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Out-MessageException" -Test {
		
			# Arrange
			Mock Out-MessageError { } -Verifiable;
			$errorRecord = New-CustomErrorRecord -msg "arbitrary-message" -cat NotSpecified -o "arbitrary-object";

			Out-MessageException $errorRecord;
			
			# Assert
			Assert-MockCalled Out-MessageError -Times 1
		}
		
		It "Out-MessageExceptionWithGotoError" -Test {
		
			# Arrange
			$Error.Clear();
			try 
			{ 
				throw $gotoError; 
			} 
			catch 
			{ 
				# N/A
			}
			$Error.Count | Should Be 1;
			
			# Act
			$errorRecord = $Error[0];
			
			{ Out-MessageException $errorRecord } | Should Throw $gotoError;
			
			# Assert
		}
		
		It "Out-MessageExceptionWithGotoFailure" -Test {
		
			# Arrange
			$Error.Clear();
			try 
			{ 
				throw $gotoFailure; 
			} 
			catch 
			{ 
				# N/A
			}
			$Error.Count | Should Be 1;
			
			# Act
			$errorRecord = $Error[0];
			
			{ Out-MessageException $errorRecord } | Should Not Throw;
			
			# Assert
		}
	}
	
	Context "Out-MessageExceptionWithInnerException" {
	
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Out-MessageExceptionWithInnerException" -Test {
		
			# Arrange
			Mock Out-MessageError { } -Verifiable;
			try
			{
				$exInner = New-Object System.Exception("arbitrary-inner-exception");
				$ex = New-Object System.Exception("arbitrary-main-exception", $exInner);
				throw $ex;
			}
			catch
			{
				$errorRecord = $_;
				Out-MessageException $errorRecord;
			}
			
			# Assert
			Assert-MockCalled Out-MessageError -Times 1;
		}
	}

	Context "Out-MessageExceptionWithGotoSuccess" {
	
		# Context wide constants
		# N/A

		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Out-MessageExceptionWithGotoSuccess" -Test {
		
			# Arrange
			Mock Out-MessageError { } -Verifiable;
			$Error.Clear();
			try 
			{ 
				throw $gotoSuccess; 
			} 
			catch 
			{ 
				# N/A
			}
			$Error.Count | Should Be 1;
			
			# Act
			$errorRecord = $Error[0];
			
			{ Out-MessageException $errorRecord } | Should Not Throw;
			
			# Assert
			Assert-MockCalled Out-MessageError -Times 0;
		}
	}
	
	Context "PerformanceTests" {
	
		# Context wide constants
		# N/A

		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		# test for performance measurement
		# [+] Out-MessageExceptionStringAppend 155.46s
		# we compare a single string concatenation vs a new StringBuilder instance on every invocation
		# It "Out-MessageExceptionStringAppend" -Test {
			# # Arrange
			# $msg = "my message";
			# $e = New-CustomErrorRecord -msg $msg -cat InvalidResult -o $msg -id $msg;
			
			# $cStart = 1000000;
			# $cMax = $cStart + 10000;
			# for($c = $cStart; $c -le $cMax; $c++)
			# {
				# Out-MessageExceptionStringAppend $e;
			# }
		# }

		# test for performance measurement
		# we compare a single StringBuilder vs a new instance on every invocation
		# [+] Out-MessageExceptionStringBuilder 143.68s
		# It "Out-MessageExceptionStringBuilder" -Test {
			# # Arrange
			# $msg = "my message";
			# $e = New-CustomErrorRecord -msg $msg -cat InvalidResult -o $msg -id $msg;
			
			# $cStart = 1000000;
			# $cMax = $cStart + 10000;
			# for($c = $cStart; $c -le $cMax; $c++)
			# {
				# Out-MessageExceptionStringBuilder $e;
			# }
		# }

		# test for performance measurement
		# we compare a single StringBuilder vs a new instance on every invocation
		# [+] Out-MessageExceptionStringBuilderStatic 143.64s
		# It "Out-MessageExceptionStringBuilderStatic" -Test {
			# # Arrange
			# $msg = "my message";
			# $e = New-CustomErrorRecord -msg $msg -cat InvalidResult -o $msg -id $msg;
			
			# $cStart = 1000000;
			# $cMax = $cStart + 10000;
			# for($c = $cStart; $c -le $cMax; $c++)
			# {
				# Out-MessageExceptionStringBuilderStatic $e;
			# }
		# }
	}
}

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIB3cJvLfp3NGJDM/Q9aIOPKM
# GzygghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTZjCandtHnLD9U
# 37abhgOyxpU9+zANBgkqhkiG9w0BAQEFAASCAQBq28vtpzmz2SOGxgLPvgonIIjs
# niipFFBJKQfZaKwrUybs7Fb+8cHwhLE44GB/OpnTeQUgOhc7/O0kLks2je20ZuDR
# kxAo7omzUFiPJV9/wX1PPxBPej+TBIzJZlVAdCzuU4Ffvb2Ar1xSlFZD0+Td/YWl
# MMq60HtDAHIZFm5nAhUr8XoowlorYr/ZRMfxqg+bl473Z9UGpWB/Xvuwx+eXAelW
# zY32BThikVW/66cGVl4gS7P+M3VnQZPju/ooTuKxrPWpGj4UjB+Xwy3r2uAMxIGg
# 7imyC4eZ8Hr2wjcPIOZ/2RFuT3xCVhWWVuzS7yqkCzMDQMlI1idqSwM7QYLHoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTIyMDE0MzYxNFowIwYJKoZIhvcNAQkEMRYEFKOs/UvlpGiRg3vcY1t3KN/XMmwj
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQA7C3LU1ORlYq17pwb7
# 2dpU3HudmWGcaoDCAR8uaaRscmpUAtA36VCVltefDVSkAVGD5CqRoV32Fu4G6xtL
# v0Rky9XDIwxhqYjol5MW+Qyq1WuOihGqetGQaiGAjdOKI57tGJuU5X1+5LyDqt8G
# 9u6tG8PVwEbyYZL001jNDagqTV9V2DteJJlKThOnN6ObX19Rv0kyxBRCpYwZFoSw
# MKaK1XGPyuntKbKeNFRRI9UUjHTWrtoET68wgQSHCDqapYP99+HS/eFqltiZpIHR
# sHW22T/tjWizGIi96/WURcv85pERvP5RsOXrJJfAAQMnHcvXVzQdxN0U9B3ne9BY
# Hn2f
# SIG # End signature block
