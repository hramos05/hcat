Assumptions
------------
1. PowerShell 3.0+ is installed
2. Pester 4.9.0+ is installed
3. Only 1 CSV file needs to be loaded at a time
4. CSV inputs are sanitized (no letters on the age column, special characters, etc)
5. CSV is formatted with headers as [Name],[Age]
6. Name will have a minimum of First and Last Name
7. Name is formatted as "[First Name(s)] [Middle Name/Initial (optional)] [Last Name]"
8. Name is only english alphabet
9. Middle names need to be converted to middle initials, and those without middle names/initials can be left empty
10. Honorifics are not needed, and will be removed
11.  Script does not need to be signed
12. Parse all entries in the CSV. Parsing error for 1 entry (or more) should be reported, but not stop the whole process
