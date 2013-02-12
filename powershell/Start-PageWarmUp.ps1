#
# Site WarmUp Script Using Sitemap.xml
#

# Start Script
$start = Get-Date

# Specify location of sitemap.xml
# Use remote site/sitemap file
$file = 'http://www.domain.local/sitemap.xml'
# Use local site/sitemap file
#$file = 'D:\Dump\Warmup\sitemap.xml'

# Get credentials for auth sites
$cred = [System.Net.CredentialCache]::DefaultCredentials
#$cred = new-object System.Net.NetworkCredential("username","password","domain")

# Get-WebPage function to retrieve page content 
function Get-WebPage([string]$url,[System.Net.NetworkCredential]$cred=$null)
{
  $wc = New-Object Net.WebClient
  if($cred -eq $null)
  {
    $cred = [System.Net.CredentialCache]::DefaultCredentials
  }
  $wc.Credentials = $cred
  return $wc.DownloadString($url)
}

# Create Data Table
$table = New-Object System.Data.DataTable "Sites"
# Create Columns
$col1 = New-Object system.Data.DataColumn Page,([int])
$col2 = New-Object system.Data.DataColumn Url,([string])
# Add the Columns
$table.Columns.Add($col1)
$table.Columns.Add($col2)

# Site map file
# Use local sitemap file
#$sitemap = [xml](Get-Content $file)
# Use remote sitemap file
$sitemap = [xml](Get-WebPage -url $file)  
# Parse in nodes
$nodelist = $sitemap.urlset.url

# Counter for pages
$i = 0
foreach ($node in $nodelist) {
  $i++
  
  # Write output to host  
  Write-Host -ForegroundColor DarkCyan "[$($i.ToString())/$($nodelist.Count)] " -NoNewline
  Write-Host -ForegroundColor White "Warming => " -NoNewline
  Write-Host -ForegroundColor Cyan "$($node.loc)" -NoNewline
  $html = Get-WebPage -url $node.loc -cred $cred  
  Write-Host -ForegroundColor White " :: " -NoNewline
  if ($html -eq $null)
  {
      Write-Host -ForegroundColor Red "Error"
  }
  else {
      Write-Host -ForegroundColor Green "Succcess"
  }

  # Add into table
  $row = $table.NewRow()
  $row.Page = $i
  $row.Url = $node.loc  
  $table.Rows.Add($row) 

}
$end = Get-Date

# Time taken
$taken = $end - $start
Write-Host
Write-Host -ForegroundColor DarkCyan "It took " -NoNewline
Write-Host -ForegroundColor Green $($taken.Minutes) -NoNewline
Write-Host -ForegroundColor DarkCyan " minutes and " -NoNewline
Write-Host -ForegroundColor Green $($taken.Seconds) -NoNewline
Write-Host -ForegroundColor DarkCyan " seconds to warm up " -NoNewline
Write-Host -ForegroundColor White $($nodelist.Count) -NoNewline
Write-Host -ForegroundColor DarkCyan " pages!"

# Insert table to mail message
$tableSites = $table | Format-Table -AutoSize | Out-String
# Send email containing large lists
# SMTP Server
$smtpServer = "smtp.domain.local"
# Net Mail Object
$msg = New-Object Net.Mail.MailMessage
# SMTP Server Object
$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
# Email
$msg.From = "WarmUp@domain.local"
$msg.ReplyTo = "WarmUp@domain.local"
$msg.To.Add("KKowalski@domain.local")
#$msg.CC.Add("Some.User@domain.local")    
$msg.Subject = "[INFO] Warmed up $($nodelist.Count) pages in $($taken.Minutes) minute and $($taken.Seconds) seconds"
$msg.Body = 
"Greetings,

The following pages have been warmed up;

$tableSites
Regards,`n

--
WarmUp AutoBot
"    
# Send Message
$smtp.Send($msg)
$msg.Dispose()
#$smtp.Dispose()

# Clear and Dispose Table
#$table
$table.Clear()
$table.Dispose()