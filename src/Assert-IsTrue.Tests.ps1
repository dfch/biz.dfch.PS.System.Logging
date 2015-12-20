$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Write-Warning {
	return;
}

Describe -Tags "Assert-IsTrue" "Assert-IsTrue" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	
	BeforeEach {
		# N/A
	}

	Context "Assert-IsTrue" {
	
		# Context wide constants
		# N/A

		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Contract-AssertWithInvalidConditionShouldThrow" -Test {
			# Arrange
			
			# Act
			{ Contract-Assert ( ![string]::IsNullOrWhiteSpace("    ") ); } | Should Throw 'Assertion failed';
			
			# Assert
		}

		It "Contract-AssertWithInvalidConditionAndMessageShouldThrow" -Test {
			# Arrange
			
			# Act
			{ Contract-Assert ( ![string]::IsNullOrWhiteSpace("    ") ) "abitrary-message"; } | Should Throw 'Assertion failed';
			
			# Assert
		}

		It "Contract-AssertWithValidConditionShouldReturn" -Test {
			# Arrange
			
			# Act
			{ Contract-Assert ( ![string]::IsNullOrWhiteSpace("arbitrary-string") ); } | Should Not Throw;
			
			# Assert
		}

		It "Contract-RequiresWithInvalidConditionShouldThrow" -Test {
			# Arrange
			
			# Act
			{ Contract-Requires ( ![string]::IsNullOrWhiteSpace("    ") ); } | Should Throw 'Precondition failed';
			
			# Assert
		}

		It "Contract-RequiresWithInvalidConditionAndMessageShouldThrow" -Test {
			# Arrange
			
			# Act
			{ Contract-Requires ( ![string]::IsNullOrWhiteSpace("    ") ) "abitrary-message"; } | Should Throw 'Precondition failed';
			
			# Assert
		}

		It "Contract-RequiresWithValidConditionShouldReturn" -Test {
			# Arrange
			
			# Act
			{ Contract-Requires ( ![string]::IsNullOrWhiteSpace("arbitrary-string") ); } | Should Not Throw;
			
			# Assert
		}

		It "Assert-ItTrueShouldReturnButShouldNotBeUsedDirectly" -Test {
			# Arrange
			Mock Write-Warning -Verifiable;
			
			# Act
			{ $result = Assert-IsTrue (3 -eq 5); } | Should Throw 'Condition failed';
			
			# Assert
			Assert-MockCalled Write-Warning -Times 2;
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
