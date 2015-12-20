$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Set-Variable gotoSuccess -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoSuccess';
Set-Variable gotoError -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoError';
Set-Variable gotoFailure -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoFailure';

function Write-Warning {
	return;
}

function Test-TrapSkeletonStringBuilder {
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

Describe -Tags "Test-TrapSkeleton" "Test-TrapSkeleton" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Assert-IsTrue.ps1"
	. "$here\Out-MessageException.ps1"
	
	BeforeEach {
		# N/A
	}

	Context "Test-TrapSkeleton" {
	
		# Context wide constants
		# N/A

		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Test-TrapSkeletonExceptionInBeginShouldThrow" -Test {
			# Arrange
			$ThrowExceptionIn = 'Begin';
			
			# Act
			{ $result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn; } | Should Throw "Exception in $ThrowExceptionIn";

			# Assert
			$result | Should Be $null;
		}

		It "Test-TrapSkeletonExceptionInProcessShouldThrow" -Test {
			# Arrange
			$ThrowExceptionIn = 'Process';
			
			# Act
			{ $result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn; } | Should Throw "Exception in $ThrowExceptionIn";

			# Assert
			$result | Should Be $null;
		}

		It "Test-TrapSkeletonExceptionInEndShouldThrow" -Test {
			# Arrange
			$ThrowExceptionIn = 'End';
			
			# Act
			{ $result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn; } | Should Throw "Exception in $ThrowExceptionIn";

			# Assert
			$result | Should Be $null;
		}

		It "Test-TrapSkeletonExceptionInNoneShouldReturnTrue" -Test {
			# Arrange
			$ThrowExceptionIn = 'None';

			# Act
			$result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn;

			# Assert
			$result | Should Be $true;
		}

		It "Test-TrapSkeletonWithContractRequiresShouldThrow" -Test {
			# Arrange
			$ThrowExceptionIn = 'ContractRequires';

			# Act
			{ $result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn ; } | Should Throw 'Precondition failed';
			{ $result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn -TestParameterForContractRequires 5; } | Should Throw 'Precondition failed';
			{ $result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn -TestParameterForContractRequires "  "; } | Should Throw 'Precondition failed';
			{ $result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn -TestParameterForContractRequires "string-with-too-many-characters"; } | Should Throw 'Precondition failed';

			# Assert
			$result | Should Be $null;
		}

		It "Test-TrapSkeletonWithContractAssertShouldThrow" -Test {
			# Arrange
			$ThrowExceptionIn = 'ContractAssert';

			# Act
			{ $result = Test-TrapSkeleton -ThrowExceptionIn $ThrowExceptionIn; } | Should Throw 'Assertion failed';

			# Assert
			$result | Should Be $null;
		}
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
