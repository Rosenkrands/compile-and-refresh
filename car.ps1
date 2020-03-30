$filename = 'main.tex'
$pdfname = 'main.pdf'
$filepath = Join-Path $PSScriptRoot $filename

$Editor = 'Notepad++'
$Viewer = 'Firefox'

$ChangeOld = 0
$ChangeNew = 1

while ($true) {
$ChangeNew = (get-item $PSScriptRoot\$filename).LastWriteTime.ToString()
    if ($ChangeOld -ne $ChangeNew) {
    $EditiorIsRunning = (get-process | where-object {$_.Name -eq $Editor}).Count
    $ViewerIsRunning = (get-process | where-object {$_.Name -eq $Viewer}).Count

    $shell = New-Object -ComObject wscript.shell

    if (!(test-path $filepath)) {
        Write-Warning "$filename does not exist, are you even trying?"
    } else {
        if ($EditiorIsRunning) {
            $shell.AppActivate('Notepad++')
            $shell.SendKeys("^s")
        } else {
            Write-Warning "$Editor is not open, opening $Editor"
            sleep 1
            Start-Process $PSScriptRoot\$filename
            $shell.AppActivate('Notepad++')
            $shell.SendKeys("^s")
        }
        pdflatex $PSScriptRoot\main.tex
    }

    if ($ViewerIsRunning) {
        $shell.AppActivate('Firefox')
        $shell.SendKeys("{F5}")
    } else {
        Write-Warning "$Viewer is not open, opening $Viewer"
        sleep 1
        Start-Process $PSScriptRoot\$pdfname
        $shell.AppActivate('Firefox')
        $shell.SendKeys("{F5}")
    }

    Write-host "Congratulations, $filename was compiled!"

    sleep 1

    $DelimiterPosition = $filename.IndexOf(".")
    $filenameWOextension = $filename.Substring(0, $DelimiterPosition)
    $auxfilepath = join-path $PSScriptRoot "$filenameWOextension.aux"
    $logfilepath = join-path $PSScriptRoot "$filenameWOextension.log"

    if ((test-path $auxfilepath)) {
        Remove-Item $auxfilepath
        Write-Warning "Removed the disgusting $filenameWOExtension.aux file"
    }
    if ((test-path $logfilepath)) {
        Remove-Item $logfilepath
        Write-Warning "$filenameWOExtension.log is gone, and you are never seeing it again!"
    }
} else {
    write-host 'nothing to see here'
}
$ChangeOld = (get-item $PSScriptRoot\$filename).LastWriteTime.ToString()
sleep -Milliseconds 500
}