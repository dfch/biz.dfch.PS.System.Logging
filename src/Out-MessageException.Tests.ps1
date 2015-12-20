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
