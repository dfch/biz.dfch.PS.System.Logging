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
	if($Message)
	{
		$msg = [string]::Concat($msg, "; ", $Message);
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
