$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function XmlEsc($s) {
  return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;')
}

function Para($style, $text) {
  $t = XmlEsc $text
  if ($style) {
    return "<w:p><w:pPr><w:pStyle w:val=`"$style`"/></w:pPr><w:r><w:t xml:space=`"preserve`">$t</w:t></w:r></w:p>"
  } else {
    return "<w:p><w:r><w:t xml:space=`"preserve`">$t</w:t></w:r></w:p>"
  }
}

function BuildBody($blocks) {
  $sb = New-Object System.Text.StringBuilder
  foreach ($b in $blocks) {
    switch ($b.type) {
      'h1'     { [void]$sb.Append((Para 'Heading1' $b.text)) }
      'h2'     { [void]$sb.Append((Para 'Heading2' $b.text)) }
      'h3'     { [void]$sb.Append((Para 'Heading3' $b.text)) }
      'p'      { [void]$sb.Append((Para $null     $b.text)) }
      'bullet' { [void]$sb.Append((Para 'ListBullet' $b.text)) }
      'num'    { [void]$sb.Append((Para 'ListNumber' $b.text)) }
    }
  }
  return $sb.ToString()
}

$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
'@

$rels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'@

$docRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
'@

$styles = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
        <w:sz w:val="22"/>
        <w:szCs w:val="22"/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        <w:spacing w:after="160" w:line="259" w:lineRule="auto"/>
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:keepNext/>
      <w:spacing w:before="360" w:after="120"/>
      <w:outlineLvl w:val="0"/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Calibri Light" w:hAnsi="Calibri Light"/>
      <w:b/>
      <w:color w:val="2E74B5"/>
      <w:sz w:val="40"/>
      <w:szCs w:val="40"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:keepNext/>
      <w:spacing w:before="280" w:after="100"/>
      <w:outlineLvl w:val="1"/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Calibri Light" w:hAnsi="Calibri Light"/>
      <w:b/>
      <w:color w:val="2E74B5"/>
      <w:sz w:val="30"/>
      <w:szCs w:val="30"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:keepNext/>
      <w:spacing w:before="240" w:after="80"/>
      <w:outlineLvl w:val="2"/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Calibri Light" w:hAnsi="Calibri Light"/>
      <w:b/>
      <w:color w:val="1F4E79"/>
      <w:sz w:val="26"/>
      <w:szCs w:val="26"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="ListBullet">
    <w:name w:val="List Bullet"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:numPr>
        <w:ilvl w:val="0"/>
        <w:numId w:val="1"/>
      </w:numPr>
      <w:spacing w:after="80"/>
      <w:contextualSpacing/>
    </w:pPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="ListNumber">
    <w:name w:val="List Number"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:numPr>
        <w:ilvl w:val="0"/>
        <w:numId w:val="2"/>
      </w:numPr>
      <w:spacing w:after="80"/>
      <w:contextualSpacing/>
    </w:pPr>
  </w:style>
</w:styles>
'@

function BuildDocXml($bodyXml) {
  return @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
$bodyXml
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>
"@
}

function Write-Docx($outPath, $blocks) {
  if (Test-Path $outPath) { Remove-Item $outPath -Force }
  $bodyXml = BuildBody $blocks
  $docXml  = BuildDocXml $bodyXml

  $zip = [System.IO.Compression.ZipFile]::Open($outPath, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    function AddEntry($z, $name, $content) {
      $entry = $z.CreateEntry($name, [System.IO.Compression.CompressionLevel]::Optimal)
      $stream = $entry.Open()
      $writer = New-Object System.IO.StreamWriter($stream, [System.Text.UTF8Encoding]::new($false))
      $writer.Write($content)
      $writer.Flush()
      $writer.Dispose()
    }
    AddEntry $zip '[Content_Types].xml' $contentTypes
    AddEntry $zip '_rels/.rels'         $rels
    AddEntry $zip 'word/_rels/document.xml.rels' $docRels
    AddEntry $zip 'word/styles.xml'     $styles
    AddEntry $zip 'word/document.xml'   $docXml
  } finally {
    $zip.Dispose()
  }
}

$employee = @(
  @{type='h1'; text='Altitude Timesheet - Employee Guide'},
  @{type='p';  text='App URL: https://altitudeco.netlify.app/'},
  @{type='h2'; text='First-Time Setup'},
  @{type='p';  text='Your administrator will create an account for you and give you a 4-digit PIN. You will need this PIN every time you sign in.'},
  @{type='h2'; text='Install on Your Phone'},
  @{type='bullet'; text='iPhone: Open the URL in Safari, tap Share, then Add to Home Screen'},
  @{type='bullet'; text='Android: Open the URL in Chrome, tap menu, then Install app'},
  @{type='h2'; text='Sign In'},
  @{type='num'; text='Open the app'},
  @{type='num'; text='Pick your name from the list'},
  @{type='num'; text='Enter your 4-digit PIN'},
  @{type='num'; text='Tap Sign In'},
  @{type='p';  text='If you forget your PIN, ask your administrator to reset it.'},
  @{type='h2'; text='Fill Out Your Timesheet'},
  @{type='num'; text='Use the arrows to pick the correct week'},
  @{type='num'; text='For each workday: pick the Job from the dropdown, enter Start and End times, add Lunch minutes if you took a break'},
  @{type='num'; text='Hours are calculated automatically'},
  @{type='h3'; text='Shortcuts'},
  @{type='bullet'; text='Copy - copies last weeks pattern into this week (looks back up to 4 weeks if last week is empty)'},
  @{type='bullet'; text='Quick Fill - fills Mon-Fri with 8h on a single job'},
  @{type='h2'; text='Submit Your Timesheet'},
  @{type='p';  text='When the week is done, tap Submit Week at the top.'},
  @{type='bullet'; text='The app checks for problems first (hours with no job, empty week, etc.)'},
  @{type='bullet'; text='Once submitted, the week is locked - you cannot change it'},
  @{type='bullet'; text='The banner turns green and shows when you submitted'},
  @{type='p';  text='If you need to change a submitted week, ask your admin to Reopen it.'},
  @{type='h2'; text='My History'},
  @{type='p';  text='Tap My History to see every week you have ever submitted, with status badges and an XLSX download for each one.'},
  @{type='h2'; text='Other Buttons'},
  @{type='bullet'; text='Email - opens your email app with the timesheet attached'},
  @{type='bullet'; text='XLSX - downloads this week as an Excel file'},
  @{type='bullet'; text='PDF - opens print dialog (choose Save as PDF)'},
  @{type='h2'; text='Tips'},
  @{type='bullet'; text='Your work is saved automatically - no save button'},
  @{type='bullet'; text='Works offline - fill it in anywhere; it will upload when you are back online'},
  @{type='bullet'; text='One timesheet per week, switch weeks with the arrows'},
  @{type='bullet'; text='Tap your name in the header to sign out'}
)

$admin = @(
  @{type='h1'; text='Altitude Timesheet - Admin Guide'},
  @{type='p';  text='Admin URL: https://altitudeco.netlify.app/?admin=1234'},
  @{type='p';  text='(Bookmark this - keep it private)'},
  @{type='h2'; text='Access'},
  @{type='bullet'; text='Open the admin URL and you are in'},
  @{type='bullet'; text='The badge at the top shows ADMIN'},
  @{type='h2'; text='Setup: Create Employee Accounts'},
  @{type='p';  text='Before anyone can sign in, you need to add employees:'},
  @{type='num'; text='Open Admin -> Employees tab'},
  @{type='num'; text='Type their full name and a 4-digit PIN (or leave PIN blank to auto-generate)'},
  @{type='num'; text='Click + Add'},
  @{type='num'; text='Tell each person their PIN - they will need it to sign in'},
  @{type='num'; text='Open the Projects tab and click Publish Updates so all devices receive the new accounts'},
  @{type='p';  text='You can later Archive anyone who leaves (keeps their history but blocks login) or Reset PIN if they forget it.'},
  @{type='h2'; text='The Admin Tabs'},
  @{type='h3'; text='Dashboard'},
  @{type='bullet'; text='This week at a glance - who submitted, who is outstanding, total hours'},
  @{type='bullet'; text='4-week trend chart'},
  @{type='bullet'; text='Per-employee status list (NOT STARTED / DRAFT / SUBMITTED / APPROVED)'},
  @{type='h3'; text='Employees'},
  @{type='bullet'; text='Add, archive, rename, reset PIN, delete'},
  @{type='bullet'; text='After changes click Publish in Projects tab'},
  @{type='h3'; text='Projects'},
  @{type='bullet'; text='Add new jobs employees can pick from'},
  @{type='bullet'; text='Set per-job budgets, total project hours, start dates and deadlines'},
  @{type='bullet'; text='Archive old jobs (hides them from employees, keeps history)'},
  @{type='bullet'; text='Publish pushes everything to the cloud - every device auto-syncs'},
  @{type='h3'; text='Report'},
  @{type='bullet'; text='Pick a week to see all hours by employee/job'},
  @{type='bullet'; text='Download as Excel'},
  @{type='h3'; text='Project Dashboard'},
  @{type='bullet'; text='Cumulative hours per project across all weeks'},
  @{type='bullet'; text='Burn rate, weeks remaining, projected finish date'},
  @{type='h3'; text='History'},
  @{type='bullet'; text='Every timesheet ever submitted, pulled live from the cloud'},
  @{type='bullet'; text='Filter by employee, project, status, date range'},
  @{type='bullet'; text='Approve submitted weeks - locks them permanently'},
  @{type='bullet'; text='Reopen any week so the employee can edit it again'},
  @{type='bullet'; text='Download single weeks or Bulk XLSX of everything filtered'},
  @{type='bullet'; text='Delete records (admin only - employees cannot delete)'},
  @{type='h3'; text='Audit'},
  @{type='bullet'; text='Every action recorded on this device (submit, approve, reopen, employee changes, etc.)'},
  @{type='bullet'; text='Export as Excel, clear when needed'},
  @{type='h3'; text='Settings'},
  @{type='bullet'; text='Change the admin PIN'},
  @{type='bullet'; text='Set default work hours / start times'},
  @{type='bullet'; text='Set the email timesheets go to'},
  @{type='bullet'; text='Bulk Export by Date Range - pull all weeks between two dates as one workbook'},
  @{type='bullet'; text='Cloud Backup - download a JSON snapshot of every employee, project, timesheet, audit entry. Keep it safe.'},
  @{type='h2'; text='Daily Workflow'},
  @{type='num'; text='Employees fill in their timesheets during the week'},
  @{type='num'; text='End of week, open Dashboard to see who is outstanding'},
  @{type='num'; text='Open History, review submitted weeks, click Approve'},
  @{type='num'; text='Use Report or Bulk Export for payroll'},
  @{type='h2'; text='Security Notes'},
  @{type='bullet'; text='Never share the admin URL with employees'},
  @{type='bullet'; text='Employees using the plain URL cannot see or access admin tools'},
  @{type='bullet'; text='PINs are stored on each device after sync - acceptable for a small team but means anyone with the app installed has access to all PINs. Only install the app on trusted devices.'},
  @{type='bullet'; text='Run Cloud Backup in Settings periodically - it is your only safety net if the cloud is ever lost'}
)

Write-Docx (Join-Path $root 'Employee-Guide.docx') $employee
Write-Host 'Created Employee-Guide.docx'
Write-Docx (Join-Path $root 'Admin-Guide.docx') $admin
Write-Host 'Created Admin-Guide.docx'
