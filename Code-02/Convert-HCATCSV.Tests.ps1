<#
    .DESCRIPTION
    Tested on:
        - PowerShell 5.1
        - Pester 4.9.0
        - Windows 10 1803

    .NOTES
        Author : Heinz Ramos
        Github : https://github.com/hramos05/hcat/tree/production/Code-02
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Convert-HCATCSV" {
    # Name of the powershell command
    [Bool]$FunctionLoaded = [Bool](Get-Command -Name Convert-HCATCSV -ErrorAction SilentlyContinue) 

    Context "Function Loaded" {
        It "Convert-HCATCSV command should be available" {
            $FunctionLoaded | Should -Be $true
        }
    }

    # Only run the rest of the tests if the function is loaded
    If ($FunctionLoaded) {
        Context "Parameter Validations" {
            It "CSV parameter should exist" {
                { [Bool]((Get-Command -Name Convert-HCATCSV).Parameters['CSV']) } | Should -Be $True
            }

            It "CSV parameter not passed should throw an error" {
                { Convert-HCATCSV -ErrorAction Stop } | Should -Throw -ExpectedMessage "CSV file is required. Please enter using -CSV parameter"
            }

            It "CSV parameter passed empty or null should throw an error" {
                { Convert-HCATCSV -CSV '' -ErrorAction Stop } | Should -Throw -ExpectedMessage "The argument is null or empty"
            }
        }

        # Create a random test file on a TestDrive
        $RandomFileName = [System.IO.Path]::GetRandomFileName()
        $TDrivePath = "TestDrive:\$RandomFileName"

        Context "Data Validations" {
            # Create a clean skeleton test csv file
            'Name,Age' | Out-File $TDrivePath
            
            It "CSV file not found should throw an error" {
                # Use a fake drive
                { Convert-HCATCSV -CSV FAKE:\$RandomFileName -ErrorAction Stop } | Should -Throw -ExpectedMessage "FAKE:\$RandomFileName was not found, or access denied"
            }

            It "CSV file with no entries to parse should throw an error" {
                { Convert-HCATCSV -CSV $TDrivePath -ErrorAction Stop } | Should -Throw -ExpectedMessage "No entry found, or CSV is invalid. Please check the CSV file [$TDrivePath]"
            }

            It "CSV file import with good data should be successful" {
                # Add "good" data
                'Heinz Robles Ramos,21' | Add-Content -Path $TDrivePath
                { Convert-HCATCSV -CSV $TDrivePath -ErrorAction Stop } | Should -Not -Throw 
            }

            It "CSV file import with bad data should throw an error" {
                # Add "bad" data
                # Single "name" cannot be parsed, as such should fail
                'Heinz,21' | Add-Content -Path $TDrivePath

                { Convert-HCATCSV -CSV $TDrivePath -ErrorAction Stop } | Should -Throw -ExpectedMessage "Entry not recorded"
            }
        }

        Context "Output & Value Validations" {
            # Create a clean test csv file with "good" data
            'Name,Age' | Out-File $TDrivePath
            'Heinz Robles Ramos,21' | Add-Content -Path $TDrivePath
            'Ruby Lirio,22' | Add-Content -Path $TDrivePath
            'Ms. Xyz Lirio Ramos,5' | Add-Content -Path $TDrivePath

            # Test best effort sanization
            'Dr. Mu&lti #Na*me $Test Last,1.0' | Add-Content -Path $TDrivePath

            # Get the output values
            $Output = (Convert-HCATCSV -CSV $TDrivePath -ErrorAction SilentlyContinue)

            It "Output should exist" {
                $Output | Should -Not -BeNullorEmpty
            }

            # Only run the rest of the test if there is output
            If (!([string]::IsNullOrEmpty($Output))){
                It "Output should have last name" {
                    [Bool]($Output | Get-Member -Name 'Last Name') | Should -Be $True
                }

                It "Output should have first name" {
                    [Bool]($Output | Get-Member -Name 'First Name') | Should -Be $True
                }

                It "Output should have middle initial" {
                    [Bool]($Output | Get-Member -Name 'Middle Initial') | Should -Be $True
                }

                It "Output should have age" {
                    [Bool]($Output | Get-Member -Name 'Age') | Should -Be $True
                }

                # All values should match expected results before we consider it a success
                It "Output last name should return correct values" {            
                    ($Output.'Last Name')[0] | Should -Be 'Ramos'
                    ($Output.'Last Name')[1] | Should -Be 'Lirio'
                    ($Output.'Last Name')[2] | Should -Be 'Ramos'
                    ($Output.'Last Name')[3] | Should -Be 'Last'
                }

                It "Output first name should return correct values" {            
                    ($Output.'First Name')[0] | Should -Be 'Heinz'
                    ($Output.'First Name')[1] | Should -Be 'Ruby'
                    ($Output.'First Name')[2] | Should -Be 'Xyz'
                    ($Output.'First Name')[3] | Should -Be 'Multi Name'
                }

                It "Output middle initial should return correct values" {            
                    ($Output.'Middle Initial')[0] | Should -Be 'R'
                    ($Output.'Middle Initial')[1] | Should -BeNullorEmpty
                    ($Output.'Middle Initial')[2] | Should -Be 'L'
                    ($Output.'Middle Initial')[3] | Should -Be 'T'
                }

                It "Output age should return correct values" {
                    ($Output.Age)[0] | Should -Be '21'
                    ($Output.Age)[1] | Should -Be '22'
                    ($Output.Age)[2] | Should -Be '5'
                    ($Output.Age)[3] | Should -Be '10'
                }
            }
        }
    }
}
