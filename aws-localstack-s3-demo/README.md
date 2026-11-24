# Demonstrație Amazon S3 cu LocalStack

Acest proiect emulează local Amazon S3 cu LocalStack și Docker. Nu este necesar niciun cont AWS și nu se instalează AWS CLI pe calculatorul gazdă.

## Cerințe

- Docker Desktop cu Docker Compose
- Windows PowerShell

## Pornire

Deschide PowerShell în folderul proiectului și rulează:

```powershell
docker compose up -d
```

Verifică starea serviciului:

```powershell
Invoke-RestMethod http://localhost:4566/_localstack/health
```

## Operațiuni S3

Comenzile folosite mai jos sunt executate prin utilitarul `awslocal` inclus în containerul LocalStack.

### Creare bucket

```powershell
docker compose exec -T localstack awslocal s3 mb s3://demo-bucket-aws --region eu-central-1
```

### Încărcare fișier

```powershell
docker compose cp test.txt localstack:/tmp/test.txt
docker compose exec -T localstack awslocal s3 cp /tmp/test.txt s3://demo-bucket-aws/test.txt
```

### Listare obiecte

```powershell
docker compose exec -T localstack awslocal s3 ls s3://demo-bucket-aws/
```

### Citire conținut

```powershell
docker compose exec -T localstack awslocal s3 cp s3://demo-bucket-aws/test.txt -
```

### Ștergere obiect și bucket

```powershell
docker compose exec -T localstack awslocal s3 rm s3://demo-bucket-aws/test.txt
docker compose exec -T localstack awslocal s3 rb s3://demo-bucket-aws
```

## Script demonstrativ complet

Pornește LocalStack, execută operațiunile S3 de mai sus și curăță resursele:

```powershell
powershell -ExecutionPolicy Bypass -File .\demo.ps1
```

Scriptul pornește LocalStack, creează bucket-ul, încarcă și afișează fișierul, apoi șterge obiectul și bucket-ul. Containerul LocalStack rămâne pornit până la comanda de oprire de mai jos.

## Ce prezint

1. Arată Docker Desktop pornit și containerul `localstack` în stare `Running`.
2. Deschide PowerShell în folderul proiectului și rulează scriptul demonstrativ de mai sus.
3. Explică pe scurt rezultatele: bucket creat, fișier încărcat și listat, conținut citit, apoi obiectul și bucket-ul șterse.
4. Menționează că toate operațiunile sunt locale, prin LocalStack, și nu folosesc un cont AWS real.

## Oprire

```powershell
docker compose down
```

Pentru ștergerea completă a containerului și a volumelor LocalStack:

```powershell
docker compose down --volumes
```
