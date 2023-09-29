#credit due primarily to chatGPT4.
#script tested and confirmed working.
#Import the Group Policy Module
import-module grouppolicy

# Define the source directory where the GPO backups are stored
$sourceDirectory = "C:\path_to_directory_containing_backedup_gpo"

# Define the target domain where the GPOs should be imported
$targetDomain = "your_AD_domain_goes_here.local"

# Get the list of GPO backup folders in the source directory
$gpoBackupFolders = Get-ChildItem -Path $sourceDirectory

# Regex pattern to match GPO display name
$regexPattern = '<DisplayName><!\[CDATA\[(.*?)\]\]><\/DisplayName>'

# Loop through each GPO backup folder and import the GPO
foreach ($folder in $gpoBackupFolders) {
    # Read the GPO information from the backup
    $gpoInfo = Get-Content -Path (Join-Path -Path $folder.FullName -ChildPath "Backup.xml") -Raw
    
    # Use regex to extract the GPO display name
    if ($gpoInfo -match $regexPattern) {
        $gpoDisplayName = $matches[1]
    } else {
        Write-Host "Could not extract GPO Display Name"
        continue
    }
    
    # Debugging output
    Write-Host "Folder Name: $($folder.Name)"
    Write-Host "GPO Display Name: $gpoDisplayName"
    
    # Remove curly brackets from BackupId
    $backupIdWithoutBrackets = $folder.Name -replace '[{}]',''
    
    # Import the GPO into the target domain
    Import-GPO -BackupId $backupIdWithoutBrackets -Path $sourceDirectory -TargetName $gpoDisplayName -Domain $targetDomain -CreateIfNeeded
}
