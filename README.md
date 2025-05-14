# Proyecto11BRS

## Enlace a la Presentación
[https://docs.google.com/presentation/d/14us_Vl1NZeJZtKF4o7TGqDhAyhQ7QDM79LDL0PZeBd8/edit?hl=es&slide=id.p#slide=id.p](https://docs.google.com/presentation/d/14us_Vl1NZeJZtKF4o7TGqDhAyhQ7QDM79LDL0PZeBd8/edit?hl=es&slide=id.p#slide=id.p)

## Funcionamiento de los scripts

Este proyecto forma parte de la asignatura **Bastionado de Redes y Sistemas**, y tiene como objetivo principal asegurar una máquina Ubuntu Server 18.04. Se utilizan herramientas de automatización y verificación como **Ansible** para aplicar configuraciones de seguridad, **InSpec** para comprobar el cumplimiento de dichas configuraciones, y **Terraform** de forma demostrativa.

### Infraestructura del Escenario

La topología de red para este proyecto se compone de:

-   **Cortafuegos (Firewall):** pfSense (ejecutándose en una máquina virtual).
    -   Interfaz **WAN:** `192.168.1.134` (conectada a la red doméstica/principal).
    -   Interfaz **LAN:** `192.168.50.1` (actúa como gateway para la red interna).

-   **Máquina Víctima (Objetivo del Bastionado):** Ubuntu Server 18.04.
    -   **IP:** `192.168.50.100` (en la red interna gestionada por pfSense).
    -   **Gateway:** `192.168.50.1` (la IP de la interfaz LAN de pfSense).

-   **Máquina de Gestión/Control:** Ubuntu Desktop.
    -   **IP:** `192.168.50.101` (en la misma red interna que la máquina víctima).
    -   Desde esta máquina se ejecutan los playbooks de Ansible y los perfiles de InSpec contra la máquina víctima.

---

### Componentes de Automatización y Verificación

#### 1. Terraform (Demostrativo)

**Ubicación en el repositorio:** `terraform/`

Se incluye código Terraform de ejemplo que define la infraestructura para desplegar una instancia EC2 con Ubuntu 18.04 en Amazon Web Services (AWS).

> **Nota:** Para este proyecto específico, la infraestructura se ha desplegado localmente utilizando VirtualBox para las máquinas virtuales y pfSense como cortafuegos. El código de Terraform se proporciona únicamente para demostrar competencia en la definición de Infraestructura como Código (IaC), cumpliendo con los requisitos de la asignatura, aunque no se aplique directamente en el entorno de pruebas final.

---

#### 2. Ansible – Bastionado Automático del Sistema

**Ubicación en el repositorio:** `ansible/`

Se utiliza Ansible para automatizar el proceso de endurecimiento (bastionado) de la máquina víctima (Ubuntu Server 18.04). Las tareas principales incluyen:

-   Actualización completa del sistema operativo y sus paquetes.
-   Instalación de herramientas de seguridad esenciales:
    -   `ufw` (Uncomplicated Firewall) para la gestión del cortafuegos a nivel de host.
    -   `auditd` para la auditoría detallada de eventos del sistema.
    -   `fail2ban` para la protección contra ataques de fuerza bruta, especialmente en SSH.
-   Configuración segura del servicio SSH (`sshd`):
    -   Deshabilitar el login como root.
    -   Forzar el uso de autenticación basada en claves SSH.
    -   Cambiar el puerto SSH por defecto (opcional, pero implementado).
-   Establecimiento de políticas de firewall con `ufw`:
    -   Política por defecto de denegar todas las conexiones entrantes.
    -   Permitir explícitamente solo las conexiones SSH entrantes desde la IP de la máquina de gestión.
-   Desactivación de servicios considerados inseguros o innecesarios (ej: `telnet`).
-   Creación de un usuario de gestión con privilegios `sudo` y configuración segura.
-   Implementación de políticas básicas de complejidad y expiración de contraseñas.

**Inventario:**
El inventario de Ansible, que define el host objetivo, se encuentra en `ansible/inventory.ini`.

**Ejecución del Playbook de Ansible:**
Para aplicar la configuración de bastionado, desde el directorio raíz del proyecto:

```bash
cd ansible/
ansible-playbook -i inventory.ini playbook.yml
```

---

#### 3. InSpec – Verificación de Cumplimiento y Seguridad

**Ubicación en el repositorio:** `inspec/bastion-profile`

Se utiliza InSpec para verificar que las configuraciones aplicadas por Ansible cumplen con las políticas de seguridad definidas. El perfil de InSpec incluye controles para asegurar, entre otros:

-   Que los paquetes de seguridad necesarios (`ufw`, `fail2ban`, `auditd`) están instalados.
-   Que el servicio SSH está configurado de acuerdo a las mejores prácticas de seguridad (no root login, autenticación por clave, puerto correcto).
-   Que no hay servicios inseguros o innecesarios activos y escuchando en la red.
-   Que las reglas del cortafuegos (`ufw`) permiten correctamente solo las conexiones SSH desde la IP de la máquina de gestión y bloquean el resto.
-   La correcta configuración del usuario de gestión y políticas de contraseñas.

**Ejecución de la Verificación con InSpec:**
Para ejecutar los tests de InSpec contra la máquina víctima, desde el directorio raíz del proyecto:

```bash
cd inspec/bastion-profile/
inspec exec . -t ssh://ubuntu@192.168.50.100 --key-files ~/.ssh/id_rsa
```
*(Ajustar el usuario `ubuntu` y la ruta a la clave SSH `--key-files` si es necesario. Si el puerto SSH fue cambiado por Ansible, añadir la opción `-p PUERTO_SSH`)*.


