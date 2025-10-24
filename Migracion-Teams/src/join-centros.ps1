# Definir la ruta de datos
$dataPath = "..\datos"
$outputFile = Join-Path $dataPath "centros-all.csv"

# Verificar que el directorio existe
if (-not (Test-Path $dataPath)) {
    Write-Error "El directorio $dataPath no existe."
    exit 1
}

# Inicializar array para almacenar todos los datos
$allData = [System.Collections.ArrayList]@()

# Obtener todos los archivos CSV
$csvFiles = Get-ChildItem -Path $dataPath -Filter "*.csv" -Recurse | Where-Object { $_.Name -ne "centros-all.csv" }

Write-Host "Encontrados $($csvFiles.Count) archivos CSV para procesar" -ForegroundColor Yellow

foreach ($file in $csvFiles) {
    try {
        Write-Host "Procesando archivo: $($file.Name)..." -ForegroundColor Cyan
        
        # Leer el contenido del archivo
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        if ([string]::IsNullOrEmpty($content)) {
            Write-Warning "Archivo vacío: $($file.Name)"
            continue
        }
        
        # Obtener el nombre del archivo sin extensión
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        
        # Procesar cada línea del archivo
        $content.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object {
            $line = $_.Trim()
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                $datosArray = $line.Split(';')
                if ($datosArray.Count -ge 3) {
                    $obj = [PSCustomObject]@{
                        Email = $datosArray[0]
                        Telefono = $datosArray[1]
                        ID = $datosArray[2]
                        Centro = $fileName
                    }
                    [void]$allData.Add($obj)
                }
            }
        }
        
        Write-Host "Procesado: $($file.Name) -> Total acumulado: $($allData.Count)" -ForegroundColor Green
    }
    catch {
        Write-Error "Error procesando $($file.Name): $_"
        Write-Error $_.Exception.Message
        continue
    }
}

# Exportar todos los datos combinados
try {
    $allData | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
    Write-Host "Archivo final generado: $outputFile con $($allData.Count) registros totales" -ForegroundColor Green
}
catch {
    Write-Error "Error al exportar el archivo final: $_"
    exit 1
}