<<<<<<< HEAD
# Migración Teams 

Scripts para la migración y gestión de telefonía en Microsoft Teams.

## Estructura
```
Migracion-Teams/
├── datos/           # Archivos de configuración
│   ├── ETSIN-TEST.csv
│   └── test.csv
├── logs/           # Registros de operaciones
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
upn;tel;iderloc
usuario@upm.es;+34910671234;12345
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
# Scripts PowerShell UPM 🚀

[![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Teams](https://img.shields.io/badge/Microsoft_Teams-6264A7?style=for-the-badge&logo=microsoft-teams&logoColor=white)](https://www.microsoft.com/microsoft-teams)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

Colección de scripts PowerShell para la administración y automatización de tareas en la Universidad Politécnica de Madrid.

## 📂 Estructura del Repositorio

```
Proyectos-PS-UPM/
├── Actualizar-hora/               # Sincronización hora NTP
│   ├── detectar-hora.ps1
│   └── actualizar-hora.ps1
├── Auditoria-Certificados/        # Certificados Windows
│   └── auditoria-certificados.ps1
├── Borrar-perfiles-WIFI/          # Gestión perfiles WiFi
│   └── borrar-perfiles-wifi.ps1
├── Conexion-Webdav/              # Mapeo WebDAV
│   └── conexion-webdav.ps1
├── Configurador-Impresoras/       # Gestión impresoras
│   ├── csv/
│   │   └── impresoras.csv
│   ├── instalar-impresora.ps1
│   └── readme.md
├── Crear-TAP/                    # Pases Azure AD
│   └── crear-tap.ps1
├── Migracion-Teams/              # Migración Teams
│   ├── datos/
│   ├── logs/
│   └── src/
├── Set-NombrePC/                # Nombrado PCs
│   └── set-nombre-pc.ps1
├── Set-WOL-Windows/             # Wake-on-LAN
│   └── set-wol-windows.ps1
└── Win-Users/                   # Gestión usuarios
    └── win-users.ps1
```

> 🔑 **Importante**: Algunos scripts requieren permisos de administrador o configuraciones específicas. Revisa los requisitos de cada script antes de ejecutarlo.

## 📂 Estructura del Repositorio

### 🛠️ Herramientas de Administración

| Carpeta | Script Principal | Descripción | Requisitos |
|---------|-----------------|-------------|------------|
| `Actualizar-hora/` | `actualizar-hora.ps1` | Sincronización con servidores NTP | Admin local |
| `Auditoria-Certificados/` | `auditoria-certificados.ps1` | Inventario de certificados instalados | - |
| `Borrar-perfiles-WIFI/` | `borrar-perfiles-wifi.ps1` | Limpieza de perfiles WiFi | Admin local |
| `Conexion-Webdav/` | `conexion-webdav.ps1` | Mapeo de recursos WebDAV | - |
| `Configurador-Impresoras/` | `instalar-impresora.ps1` | Instalación masiva de impresoras | Admin local |
| `Set-NombrePC/` | `set-nombre-pc.ps1` | Nombrado automático por número de serie | Admin local |
| `Set-WOL-Windows/` | `set-wol-windows.ps1` | Configuración Wake-on-LAN | Admin local |
| `Crear-TAP/` | `crear-tap.ps1` | Gestión de Pases de Acceso Temporal | Azure AD Admin |
| `Win-Users/` | `win-users.ps1` | Auditoría de usuarios y grupos locales | - |
| `Migracion-Teams/` | Ver carpeta `src/` | Scripts de migración telefonía Teams | Teams Admin |



## 🚀 Inicio Rápido

### Requisitos Generales
- Windows PowerShell 7+
- Permisos según el script (ver tabla arriba)
- Git (opcional, para clonar el repo)

### Instalación
```powershell
# Clonar repositorio
git clone https://github.com/joseantoniovilar/proyectos-ps-upm.git
cd proyectos-ps-upm

# Ejemplo: Configurar hora
cd Actualizar-hora
./update-hora.ps1
```



## 📋 Documentación Detallada

### Actualizar-hora
- `detectar-update-hora.ps1`: Verifica sincronización NTP
- `update-hora.ps1`: Configura servidor horario

### Configurador_Impresoras
- Acepta CSV con formato: `nombre,ip,ubicacion,driver`
- Instala drivers y configura colas de impresión

### Set-NombrePC
- Nombra PCs según número de serie del hardware
- Útil para inventario y gestión de activos

### Crear-TAP
- Genera Pases de Acceso Temporal para Azure AD
- Requiere módulo AzureAD y permisos de administrador

## 📊 Logs y Monitorización

- Cada script genera logs detallados
- Ubicación: `/logs` en cada carpeta de proyecto
- Formato: `yyyy-MM-dd HH:mm:ss [NIVEL] Mensaje`

## 🔒 Seguridad

- Scripts firmados digitalmente
- Validación de parámetros
- Manejo seguro de credenciales
- Logs de auditoría

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/mejora`)
3. Commit cambios (`git commit -am "Añadir nueva funcionalidad"`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

## 📄 Licencia

[MIT](LICENSE.md) © [Jose Antonio Vilar](mailto:joseantonio.vilar@upm.es)

## 📬 Contacto

- **Autor**: Jose Antonio Vilar
- **Email**: [joseantonio.vilar@upm.es](mailto:joseantonio.vilar@upm.es)
- **Organización**: Universidad Politécnica de Madrid
>>>>>>> 5168b0a32d527901f2acb1f6542f9222bc31d1b2
