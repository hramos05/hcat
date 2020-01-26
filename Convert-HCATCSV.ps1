Function Convert-HCATCSV {
    #Requires -Version 3.0
    <# 
    .SYNOPSIS
        Convert a CSV file with Name and Age to an output of:
        Last Name, First Name, Middle Initial, Age

    .DESCRIPTION
        Requirements:
        Write a PowerShell script to convert the below csv to the following format: 
        Last Name, First Name, Middle Initial, Age. 

        Include appropriate Pester tests.  List all assumptions made. 

        Assumptions
        - PowerShell 3.0+ is installed
        - Pester 4.9.0+ is installed
        - Only 1 CSV file needs to be loaded at a time
        - CSV inputs are sanitized (no letters on the age column, special characters, etc)
        - CSV is formatted with headers as [Name],[Age]
        - Name will have a minimum of First and Last Name
        - Name is formatted as "[First Name(s)] [Middle Name/Initial (optional)] [Last Name]"
        - Name is only english alphabet
        - Middle names need to be converted to middle initials, and those without middle names/initials can be left empty
        - Honorifics are not needed, and will be removed
        - Script does not need to be signed
        - Parse all entries in the CSV. Parsing error for 1 entry (or more) should be reported, but not stop the whole process

    .PARAMETER CSV
        Pass the full path of the csv file
        
    .EXAMPLE
        Output as stdout
            Convert-HCATCSV -CSV "C:\HCAT.csv"
            "C:\HCAT.csv" | Convert-HCATCSV 

    .EXAMPLE
        Export output as CSV
            Convert-HCATCSV -CSV "C:\HCAT.csv" | Export-Csv -Path "C:\HCAT_Converted.csv" -NoTypeInformation
    
    .EXAMPLE
        Output as JSON
            Convert-HCATCSV -CSV "C:\HCAT.csv" | ConvertTo-Json

    .EXAMPLE
        Output as XML
            Convert-HCATCSV -CSV "C:\HCAT.csv" | ConvertTo-XML

    .NOTES
        Author : Heinz Ramos
        Github : https://github.com/hramos05/hcat/tree/master/Code%20%232
    #>

    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [String]$CSV = $(Throw "CSV file is required. Please enter using -CSV parameter.")
    )
    
    Begin {
        # Load the CSV
        If (Test-Path $CSV){
            Write-Verbose -Message "Loading $CSV"
            $CSV_Loaded = Import-Csv -Path $CSV
        } Else {
            Throw "$CSV was not found, or access denied."
        }
    }

    Process {
        # Check if we need to do anything,
        # Throw an exception if no entry to parse
        If ($CSV_Loaded.Count -eq 0){
            Throw "No entry found, or CSV is invalid. Please check the CSV file [$CSV]."
        } Else {
            
            # Initialize an array to store our outputs
            [Array]$ValArray =@()

            Write-Verbose -Message "Processing $($CSV_Loaded.Count) row(s)"

            # Start a counter to track which line we're on
            [Int]$LineNumber = 1

            # Loop through each entry, and parse the full name
            $CSV_Loaded | ForEach-Object {
                Try {
                    # While we assumed the data are sanitized, we're going to do best effort sanitization
                    # For the Name, leave ".", we're going to use it to detect honorifics
                    [String]$Name = $_.Name -Replace '[^a-zA-Z\s.]',''
                    [Int]$Age = $_.Age -Replace '[^0-9]',''
                    $LineNumber++

                    # Remove the honorifics from the name, as we do not need it (RegEx)
                    $Name = ([Regex]::Match($Name,"(\w+)\s(.+)")).Value

                    # Check if Name variable is empty, if it is, throw an exception to skip the line
                    # For example, this can trigger when there is only 1 "name" on the Name field
                    If ([string]::IsNullOrEmpty($Name)){
                        Throw "Name cannot be parsed. Input was [$($_.Name)]"
                    }

                    Write-Verbose -Message "[$LineNumber] Full Name: $Name"

                    # Split the name so we can group them
                    $Name_Split = $Name.Split(' ')
                    
                    # Get the last name
                    $Name_Last = $Name_Split[-1]
                    Write-Verbose -Message "--- Last Name: $Name_Last"

                    # Check if there is a middle name
                    If ($Name_Split.Count -gt 2){
                        # Get the first name(s), and skip the middle and last name
                        $Name_First = ($Name_Split | Select-Object -SkipLast 2) -Join ' '
                        Write-Verbose -Message "--- First Name: $Name_First"

                        # Get the middle initial
                        $Name_MI = $Name_Split[-2].SubString(0,1) # Get the first character
                        Write-Verbose -Message "--- Middle Name: $($Name_Split[-2]) ($Name_MI)"

                    } Else {
                        # Get the first name(s), and skip the last name
                        $Name_First = ($Name_Split | Select-Object -SkipLast 1) -Join ' '
                        Write-Verbose -Message "--- First Name: $Name_First"

                        # No middle name
                        $Name_MI = $null
                        Write-Verbose -Message "--- Middle Name: N/A"
                    }

                    # Verbose: Print Age
                    Write-Verbose -Message "--- Age: $Age"

                    # Create an object, and store it the main output ValArray
                    $obj = [PSCustomObject] @{
                        'Last Name'         = $Name_Last
                        'First Name'        = $Name_First
                        'Middle Initial'    = $Name_MI
                        Age                 = $Age
                    }
                    
                    $ValArray += $obj


                } Catch {
                    # Display an error, but continue with the list (Non-Terminating)
                    Write-Error "Failed on line $LineNumber. Entry not recorded. Error message: [$_]"
                }
            }

            # Display our results as an array
            $ValArray
        }
    }

    End {}
}