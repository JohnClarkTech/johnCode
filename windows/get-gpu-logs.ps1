Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ProviderName = 'nvlddmkm'
    Level = 1, 2, 3
} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, Message | Format-Table -Wrap