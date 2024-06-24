function Explain-LastError {
    # Check if there is any error in the session
    if ($Error.Count -eq 0) {
        Write-Output "No errors found in the current session."
        return
    }

    # Get the latest error
    $latestError = $Error[0]

    # Output the basic error information
    Write-Host "Latest Error:"
    Write-Host "Message: $($latestError.Exception.Message)" -ForegroundColor Red
    Write-Host "Category: $($latestError.CategoryInfo.Category)" -ForegroundColor Blue
    Write-Host "Target: $($latestError.TargetObject)" -ForegroundColor Blue
    Write-Host "Script Line: $($latestError.InvocationInfo.ScriptLineNumber)" -ForegroundColor Blue
    Write-Host "Position: $($latestError.InvocationInfo.OffsetInLine)" -ForegroundColor Blue
    Write-Host ""
    
    # Provide a more detailed explanation of common errors
    switch ($latestError.CategoryInfo.Category) {
        "ParserError" {
            Write-Output "Explanation: There is a syntax error in the script. Please check for missing or misplaced characters."
        }
        "ObjectNotFound" {
            Write-Output "Explanation: An attempt was made to access a resource or object that does not exist. Verify the names and availability of the resources."
        }
        "PermissionDenied" {
            Write-Output "Explanation: A security or permission issue occurred. Ensure you have the necessary permissions to perform the action."
        }
        "InvalidOperation" {
            Write-Output "Explanation: The command or operation is not valid in the current context. The operation might be illegal at run-time."
        }
        "NotSpecified" {
            Write-Output "Explanation: An unspecified error occurred. The details may be in additional information or inner exceptions."
        }
        default {
            Write-Output "Explanation: An error occurred. Review the error message and stack trace for more details."
        }
    }

    # If available, provide additional details
    if ($latestError.Exception.InnerException) {
        Write-Output "Additional Details: $($latestError.Exception.InnerException.Message)"
    }
}
