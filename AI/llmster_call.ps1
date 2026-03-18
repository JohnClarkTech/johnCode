$body = @{
    model = "local-model"
    messages = @(
        @{ role = "system"; content = "You are a helpful assistant." }
        @{ role = "user"; content = "In the long dark video game, what is the best central main base to store your heavy gear?" }
    )
    temperature = 0.7
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://10.10.10.136:1234/v1/chat/completions" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body