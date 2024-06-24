# Make Thinks work

Install-PSResource psai
$env:OpenAIKey = (Get-Secret -Name ChatGptAPI|ConvertFrom-SecureString -AsPlainText)

# Explore possibilities

Get-Command -Module PSAI |Group-Object verb
Get-Command -Module PSAI -verb get

# using AI (Invoke-OAIChat)
'how can i add a value to a hashtable in powershell ?' | ai
'and in an array ?'|ai
# AI has no history - is not a real "dialouge"

# CHAT Completion
$messages0 = @(
        @{
            'role' = 'user'
            'content' = 'How can i get the user of the current powershell session'
        }
)
$chatComp0 = Invoke-OAIChatCompletion -Messages $messages0 -Model 'gpt-4o'
$chatComp0.choices.message.content

$messages1 = @(
        @{
            'role' = 'user'
            'content' = 'How can i get the user of the current powershell session'
        },
        @{
            'role' = 'assistant'
            'content' = 
@'
In PowerShell, you can get the user of the current session by using the `Get-Whoami` command or by querying environment variables. Here are a few methods to accomplish this:

1. **Using `whoami` Command:**
   ```powershell
   whoami
   ```

2. **Using Environment Variables:**
   ```powershell
   $env:USERNAME
   ```

3. **Using the .NET Framework:**
   ```powershell
   [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
   ```

4. **Using the `Get-WmiObject` cmdlet:**
   ```powershell
   (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
   ```
All these methods will return the username of the user who is currently running the PowerShell session.
'@
        },
        @{
            'role' = 'user'
            'content' = 'and on a mac ?'
        }
)
$chatComp1 = Invoke-OAIChatCompletion -Messages $messages1 -Model 'gpt-4o'
$chatComp1.choices.message.content

$messages2 = @(
        @{
            'role' = 'user'
            'content' = 'How can i get the user of the current powershell session'
        },
        @{
            'role' = 'assistant'
            'content' = 
@'
In PowerShell, you can get the user of the current session by using the `Get-Whoami` command or by querying environment variables. Here are a few methods to accomplish this:

1. **Using `whoami` Command:**
   ```powershell
   whoami
   ```

2. **Using Environment Variables:**
   ```powershell
   $env:USERNAME
   ```

3. **Using the .NET Framework:**
   ```powershell
   [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
   ```

4. **Using the `Get-WmiObject` cmdlet:**
   ```powershell
   (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
   ```
All these methods will return the username of the user who is currently running the PowerShell session.
'@
        },
        @{
            'role' = 'user'
            'content' = 'and on a mac ?'
        },
        @{
            'role' = 'assistant'
            'content' = 
@'
On a Mac, if you want to get the username of the current user in a PowerShell session, you can utilize a few different methods. Here are some options:

1. **Using `whoami` Command:**
   ```powershell
   whoami
   ```

2. **Using Environment Variables:**
   ```powershell
   $env:USER
   ```

3. **Using the .NET Framework:**
   ```powershell
   [System.Environment]::UserName
   ```

4. **Using `id` Command:**
   ```powershell
   id -un
   ```

These commands should help you retrieve the username of the current user when running PowerShell on a macOS system.
'@
        },
        @{
            'role' = 'user'
            'content' = 'can i see more than the username ?'
        }
)
$chatComp2 = Invoke-OAIChatCompletion -Messages $messages2 -Model 'gpt-4o'
$chatComp2.choices.message.content

# too complicated for the desert ==> maybe write a function for this ;-)

# Using instructions

Invoke-OAIChat -UserInput 'Show me all running programs on my computer using Powershell' -Instructions 'Use examples as output only, no surrounding text'

# Differences in Models
Invoke-OAIChat -UserInput 'Show me all running programs on my computer using Powershell' -Instructions 'Use examples as output only, no surrounding text' -model 'gpt-3.5-turbo'

## Code only
Invoke-OAIChat -UserInput 'Show me all running programs on my computer using Powershell' -Instructions 'Use examples as output only, no surrounding text or code prefix so i can execute the code directly' -model 'gpt-4o'

## Installed Software Inventory
$inv1 = Invoke-OAIChat -UserInput 'Show me all installed Software on my computer using Powershell' -Instructions 'Use examples as output only, no surrounding text or code prefix so i can execute the code directly' -model 'gpt-4o'

$error[0] | ai

# Something "special" - create an Error helper
"Write a PowerSHell function that takes the latest error from my PowerShell session and explains is to me" | ai | Set-content -Path 'errorhelper.ps1'



# Assistants

## create a PowerSHell on macOS assistant

$PSAssistant = @{
    Name = 'PS-Platform'
    Instructions = "You are an expert on PowerShell $($PSVersiontable.PSEdition), running on the platform $($PSVersionTable.Platform) with the Operating System $($PSVersionTable.OS). You answer questions short and precise. If you generate code as an example, your output will be the code only. Explanations will be in the code, marked as comments. You will provide deep PowerShell knowledge. If Powershell is not sufficient for the requetes task, use command line tools of the platform and integrate them into PowerShell. If you create code, the output shall be PowerShell objects."
    Description  = 'PowerShell on current OS expert'
    Model = 'gpt-4o'
    Temperature = 0.5 #between 0 and 2, the higher the more random, the lower more deterministic
} 
$pa = New-OAIAssistant @PSAssistant
Show-OAIAssistantWebPage -assistantId $pa.id

# Use the assistant

## We want to get a system report 
$Question = 'Make a system report showing installed hard and software on the current machine'
$thread = New-OAIThread
New-OAIMessage -ThreadId $thread.id -Role user -Content $Question

$run = New-OAIRun $thread.id -AssistantId $pa.id
$status = $run.$status

#Wait until finished
while ($status -ne 'completed') {
    Write-Host "[$(Get-Date)] Waiting for run to complete..."
    $run = Get-OAIRun -threadId $thread.id
    $status = $run.data[0].status
    Start-Sleep -Seconds 1
}

$PAmessages = Get-OAIMessage -threadId $thread.id -Order asc
Write-Host -ForegroundColor Yellow "Messages:"
$PAmessages.data.content.text.value 


## Build function with Assistants
. ./assistantfunction.ps1
Get-OAIAssistantAnswer -Question 'Show me the most memory consuming processes on my machine' -AssistantName 'PS-Platform'

###################################################################################################################################


# DIDNT WorkUpload Files for analysis

$prompt = "What is the main content of those documents ?"
# Get all PDF files in the script's directory and upload them
$files = Get-ChildItem ./PSFiles/*.txt | Invoke-OAIUploadFile
# Define parameters for the assistant
$params = @{
    Name         = "PS1 Assistant"  # Name of the assistant
    Instructions = 'You are an expert assistant in summarizing and analyzing documents. They are attached TXT files containing PowerShell code.'  # Instructions for the assistant
    Model        = "gpt-4-turbo-preview"  # Model to use for the assistant
    FileIds      = $files.id  # Files for the assistant to analyze
    Tools        = Enable-OAIFileSearchTool  # Enable the retrieval tool
}

# Create a new assistant with the defined parameters
$assistant = New-OAIAssistant @params

# Create a new query for the assistant with the defined prompt
$query = New-OAIThreadQuery -Assistant $assistant -UserInput $prompt

# Output a message indicating that the assistant is processing
Write-Host "Waiting for the assistant to finish..." -foregroundcolor "yellow"

# Wait for the assistant to finish processing
$null = Wait-OAIOnRun -Run $query.Run -Thread $query.Thread

# Get the message from the assistant
$message = Get-OAIMessage -ThreadId $query.Thread.id 

# Output the content of the message
$message.data.content.text.value












