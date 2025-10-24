
# Migración Teams 

Scripts para la migración y gestión de telefonía en Microsoft Teams.

## Estructura
```
Migracion-Teams/
├── datos/         # Archivos de csv con lo datos de migracion
├── logs/          # Registros de operaciones
└── src/           # Scripts PowerShell
    ├── aplicar-politicas.ps1
    ├── join-centros.ps1
    ├── set-telefono.ps1
    └── ver-politicas.ps1
```

## Scripts Principales

### `aplicar-politicas.ps1`
Aplica políticas de Teams a usuarios.
```powershell
.\aplicar-politicas.ps1 -CsvPath "..\datos\usuarios.csv"
```

### `set-telefono.ps1`
Configura números de teléfono para usuarios.
```powershell
.\set-telefono.ps1 -CsvPath "..\datos\usuarios.csv"
```

### `ver-politicas.ps1`
Muestra políticas aplicadas a usuarios.
```powershell
.\ver-politicas.ps1


### `join-centros.ps1`
Une varios csv que contienen los usuarios de los centros en unico csv
```powershell
.\join-centros.ps1
```

## Formato CSV
```csv
upn;tel;idlocalizacion
usuario@upm.es;+34000000000;kdwpoiew02398230
```

## Requisitos
- Windows PowerShell 7+
- Módulo MicrosoftTeams
- Permisos de administrador Teams
- Licencias Teams Phone System

## Logs
Los logs se generan en la carpeta `logs/` con:
- Timestamp de operaciones
- Resultados de cada acción
- Errores y advertencias
- Estado de las políticas

## Notas
- Ejecutar scripts en orden recomendado
- Verificar permisos antes de ejecutar
- Hacer backup antes de cambios masivos
=======

## Licencia

[MIT](LICENSE.md) © [Jose Antonio Vilar](mailto:joseantonio.vilar@upm.es)

## 📬 Contacto

- **Autor**: Jose Antonio Vilar
- **Email**: [joseantonio.vilar@upm.es](mailto:joseantonio.vilar@upm.es)
- **Organización**: Universidad Politécnica de Madrid
>>>>>>> 5168b0a32d527901f2acb1f6542f9222bc31d1b2
