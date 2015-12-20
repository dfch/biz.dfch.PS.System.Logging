function Out-MessageException {
<#
.SYNOPSIS
Writes an error record to a log target.

.DESCRIPTION
Writes an error record to a log target.

This Cmdlet writes a complete ErrorRecord to a log target including the actual ErrorRecord, the exception and a stack trace. If the exception contains inner exceptions they will be written to the log target as well. Normally this Cmdlet will not be called directly but only inside a `trap` or `catch` block.

.OUTPUTS
The Cmdlet returns set `$fReturn` to `$true` and returns its value if the exception message of the ErrorRecord equals `$gotoSuccess`. No message is logged in this case. Otherwise the Cmdlet set `$fReturn` to `$false`, set `$OutputParameter` to `$null` and returns its value. If the exception message of the ErrorRecord equals `$gotoError` a terminating error is also generated.

.EXAMPLE
This example calls a method with a try/catch block. Upon exception a custom error record is created and written to the log via `Out-MessageException`.

function Funcy($InputObject)
{
	# main function code goes here ...
	
	try
	{
		$result = Some-ArbitraryHelperCmdlet;
	}
	catch
	{
		$er = New-CustomErrorRecord -msg "arbitrary-message" -cat NotSpecified -o "arbitrary-object";
		Out-MessageException $er;
	}
	
	# some more processing ...
}

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageException/

.NOTES
See module manifest for dependencies and further requirements.

#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Logging/Out-MessageException/'
)]
PARAM
(
	[Parameter(Mandatory = $true, Position = 0)]
	[System.Management.Automation.ErrorRecord] $ErrorRecord
)

	if($gotoSuccess -eq $ErrorRecord.Exception.Message) 
	{
		$fReturn = $true;
		return $fReturn;
	} 

	$callStack = Get-PSCallStack;
	$fn = $callStack[1].Command;
	$sb = New-Object System.Text.StringBuilder;
	$null = $sb.Append(("[{0}] '{1}' [{2}]" -f $ErrorRecord.FullyQualifiedErrorId, $ErrorRecord.Exception.Message, $ErrorRecord.Exception.GetType()));
	$null = $sb.Append((Out-String -InputObject (fl -Property * -Force -InputObject $ErrorRecord.Exception)));
	$null = $sb.Append((Out-String -InputObject (Format-Table -AutoSize -Property Location,Command,Arguments -InputObject (Get-PSCallStack))));

	$innerEx = $ErrorRecord.Exception.InnerException;
	while($innerEx)
	{
		$null = $sb.Append(("`r`n[###InnerException###] '{0}' [{1}]" -f $innerEx.Message, $innerEx.GetType()));
		$null = $sb.Append((Out-String -InputObject (fl -Property * -Force -InputObject $innerEx)));
	}
	
	[string] $ErrorText = $sb.ToString();
	$sb.Clear();
	$sb = $null;
	
	Log-Error $fn $ErrorText -fac 3;

	$fReturn = $false;
	$OutputParameter = $null;

	if($gotoError -eq $ErrorRecord.Exception.Message) 
	{
		$PSCmdlet.ThrowTerminatingError($ErrorRecord);
	} 
	
	return $fReturn;
}

Set-Alias -Name Log-Exception -Value Out-MessageException;
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Out-MessageException -Alias 'Log-Exception'; } 

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
