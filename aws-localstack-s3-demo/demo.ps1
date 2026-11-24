$ErrorActionPreference = "Stop"

$bucket = "demo-bucket-aws"
$region = "eu-central-1"

function Invoke-DockerCompose {
    param([string[]]$Arguments)

    & docker compose @Arguments
    if ($LASTEXITCODE -ne 0) {
        $exitCode = $LASTEXITCODE
        throw "docker compose $($Arguments -join ' ') failed with exit code $exitCode."
    }
}

Write-Host "Starting LocalStack..."
Invoke-DockerCompose -Arguments @("up", "-d")

Write-Host "Waiting for LocalStack..."
$ready = $false
for ($i = 0; $i -lt 90; $i++) {
    try {
        $health = Invoke-RestMethod -Uri "http://127.0.0.1:4566/_localstack/health" -TimeoutSec 2
        if ($health.services.s3 -in @("available", "running")) {
            $ready = $true
            break
        }
    } catch {
    }
    Start-Sleep -Seconds 1
}
if (-not $ready) {
    throw "LocalStack S3 did not become ready within 90 seconds. Check Docker Desktop with 'docker compose logs'."
}

Invoke-DockerCompose -Arguments @("cp", "test.txt", "localstack:/tmp/test.txt")
Invoke-DockerCompose -Arguments @("exec", "-T", "localstack", "awslocal", "s3", "mb", "s3://$bucket", "--region", $region)
Invoke-DockerCompose -Arguments @("exec", "-T", "localstack", "awslocal", "s3", "cp", "/tmp/test.txt", "s3://$bucket/test.txt")
Invoke-DockerCompose -Arguments @("exec", "-T", "localstack", "awslocal", "s3", "ls", "s3://$bucket/")
Write-Host "Downloaded object content:"
Invoke-DockerCompose -Arguments @("exec", "-T", "localstack", "awslocal", "s3", "cp", "s3://$bucket/test.txt", "-")

Invoke-DockerCompose -Arguments @("exec", "-T", "localstack", "awslocal", "s3", "rm", "s3://$bucket/test.txt")
Invoke-DockerCompose -Arguments @("exec", "-T", "localstack", "awslocal", "s3", "rb", "s3://$bucket")
Write-Host "S3 CRUD demonstration completed."
