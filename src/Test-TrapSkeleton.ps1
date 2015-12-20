function Test-TrapSkeleton {
<#
.SYNOPSIS
This function defines a skeleton with TRAP statements as a generic exception handler.
#>
PARAM
(
	# magic input parameter to select where to throw exception
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateSet('Begin', 'Process', 'End', 'ContractRequires', 'ContractAssert', 'None')]
	[string] $ThrowExceptionIn
	,
	[Object] $TestParameterForContractRequires
)

Begin
{
	trap { Out-MessageException $_; break; };
	
	$fReturn = $false;
	$OutputParameter = $null;

	# Do-Something

	if($ThrowExceptionIn -eq 'Begin')
	{
		throw New-Object System.Exception("Exception in $ThrowExceptionIn");
	}
}

Process
{
	trap { Out-MessageException $_; break; };

	if($ThrowExceptionIn -eq 'Process')
	{
		throw (New-Object System.Exception("Exception in $ThrowExceptionIn"));
	}
	
	# Do-Something

	if($ThrowExceptionIn -eq 'ContractAssert')
	{
		$a = 1;
		$b = 4;
		Contract-Assert ($a -eq $b);
	}
	
	if($ThrowExceptionIn -eq 'ContractRequires')
	{
		Contract-Requires ($null -ne $TestParameterForContractRequires);
		Contract-Requires ($TestParameterForContractRequires -is [string]);
		Contract-Requires (![string]::IsNullOrWhitespace($TestParameterForContractRequires));
		Contract-Requires (5 -lt $TestParameterForContractRequires.Count);
	}
	
	$fReturn = $true;
}

End
{
	trap { Out-MessageException $_; break; };

	# Do-Something

	if($ThrowExceptionIn -eq 'End')
	{
		throw (New-Object System.Exception("Exception in $ThrowExceptionIn"));
	}
	
	$OutputParameter = $fReturn;
	return $OutputParameter;
}

} # function
