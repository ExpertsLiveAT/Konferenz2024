function Get-OAIAssistantAnswer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Question,

        [Parameter(Mandatory=$true)]
        [string]$AssistantName
    )

    begin {
        $thread = New-OAIThread
        $null = New-OAIMessage -ThreadId $thread.id -Role user -Content $Question        
        $assistant = get-OAIAssistant -Name $AssistantName
    }

    process {
        $run = New-OAIRun $thread.id -AssistantId $assistant.id
        $status = $run.$status
        
        #Wait until finished
        while ($status -ne 'completed') {
            Write-Host "[$(Get-Date)] Waiting for run to complete..."
            $run = Get-OAIRun -threadId $thread.id
            $status = $run.data[0].status
            Start-Sleep -Seconds 1
        }    
        $messages = Get-OAIMessage -threadId $thread.id -Order asc

    }

    end {
        Write-Host -ForegroundColor Yellow "Messages:"    
        return $messages.data.content.text.value 
    }    
    
}