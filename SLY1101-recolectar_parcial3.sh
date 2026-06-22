#!/bin/bash
# =============================================================================
# SLY1101 — Recolector de evidencias Parcial 3 (EA3)
# Captura comandos de NFS/autofs, arranque/firewalld/SELinux y Podman
# Uso: bash SLY1101-recolectar_parcial3.sh
# =============================================================================

set -euo pipefail

ALUMNO="${USER:-Bryan_Painemilla}"
FECHA=$(date +%Y%m%d_%H%M%S)
OUTDIR="/tmp/evidencias_parcial3_${ALUMNO}"
ZIPFILE="/tmp/SLY1101_EP3_${ALUMNO}_${FECHA}.zip"

echo "=== SLY1101 — Recolector de evidencias Parcial 3 ==="
echo "  Usuario : $ALUMNO"
echo "  Destino : $OUTDIR"
echo ""

mkdir -p "$OUTDIR"

run() {
    local label="$1"; shift
    local outfile="$OUTDIR/${label}.txt"
    echo "  [+] $label"
    {
        echo "### COMANDO: $*"
        echo "### FECHA:   $(date)"
        echo ""
        "$@" 2>&1 || true
    } > "$outfile"
}

# ── SECCIÓN 1 — NFS y autofs ─────────────────────────────────────────
echo "--- Sección 1: NFS y autofs ---"

run "s1_paquetes_nfs"     bash -c 'rpm -q nfs-utils autofs 2>/dev/null || dnf list installed nfs-utils autofs 2>/dev/null || echo "(paquetes no encontrados)"'
run "s1_mount_nfs"        bash -c 'mount -t nfs || echo "(sin montajes NFS activos)"'
run "s1_fstab_nfs"        bash -c 'echo "--- grep NFS/autofs ---"; grep -E "nfs|autofs" /etc/fstab || echo "(sin entradas NFS en fstab)"; echo "--- tail -5 /etc/fstab ---"; tail -5 /etc/fstab'
run "s1_autofs_master"    find /etc/auto.master.d/ -type f -exec echo "=== {} ===" \; -exec cat {} \; 2>/dev/null || echo "(sin mapas maestros)"
run "s1_autofs_maps"      find /etc -name 'auto.*' -not -name 'auto.master' -exec echo "=== {} ===" \; -exec cat {} \; 2>/dev/null || true
run "s1_autofs_status"    systemctl status autofs --no-pager 2>/dev/null || echo "(autofs no instalado)"
run "s1_mount_autofs"     bash -c 'mount | grep -E "nfs|autofs" || echo "(sin montajes NFS/autofs activos)"'
run "s1_autofs_ls"        bash -c 'echo "--- ls /shares/data (dispara montaje autofs) ---"; ls /shares/data 2>/dev/null || echo "(no se pudo listar /shares/data — verifique que autofs esté activo)"'
run "s1_showmount"        showmount --exports serverb.lab.example.com 2>/dev/null || echo "(showmount no disponible)"

# ── SECCIÓN 2 — Arranque, firewalld, SELinux ─────────────────────────
echo "--- Sección 2: Arranque, firewalld y SELinux ---"

run "s2_default_target"   systemctl get-default
run "s2_targets_activos"  systemctl list-units --type=target --no-pager
run "s2_grub_cmdline"     cat /proc/cmdline
run "s2_firewall_list"    firewall-cmd --list-all 2>/dev/null || echo "(firewalld no activo)"
run "s2_firewall_ports"   firewall-cmd --list-ports 2>/dev/null || true
run "s2_selinux_status"   sestatus
run "s2_semanage_http"    semanage port -l 2>/dev/null | grep -E 'http|8080' || echo "(sin puertos http en semanage)"
run "s2_httpd_status"     systemctl status httpd --no-pager 2>/dev/null || echo "(httpd no instalado)"
run "s2_httpd_port"       grep -E '^Listen' /etc/httpd/conf/httpd.conf 2>/dev/null || echo "(httpd.conf no encontrado)"
run "s2_audit_avc"        ausearch -m avc --start today 2>/dev/null | tail -20 || echo "(sin AVCs hoy)"
run "s2_curl_8080"        curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "(sin respuesta en 8080)"

# ── SECCIÓN 3 — Podman ───────────────────────────────────────────────
echo "--- Sección 3: Podman ---"

run "s3_podman_version"   podman version 2>/dev/null || echo "(podman no instalado)"
run "s3_podman_images"    podman images 2>/dev/null
run "s3_podman_ps_all"    podman ps -a 2>/dev/null
run "s3_podman_info"      podman info --format '{{.Store.GraphRoot}}' 2>/dev/null || true
run "s3_podman_auth"      bash -c 'cat ~/.config/containers/auth.json 2>/dev/null || echo "(sin credenciales guardadas en auth.json)"'
run "s3_containerfile"    cat /home/student/myimage/Containerfile 2>/dev/null || \
                          cat /home/"$ALUMNO"/myimage/Containerfile 2>/dev/null || \
                          echo "(Containerfile no encontrado)"
run "s3_index_html"       cat /home/student/myimage/index.html 2>/dev/null || \
                          cat /home/"$ALUMNO"/myimage/index.html 2>/dev/null || \
                          echo "(index.html no encontrado)"
run "s3_curl_web"         curl -s http://localhost:8080 2>/dev/null | head -5 || \
                          curl -s http://localhost:80 2>/dev/null | head -5 || \
                          echo "(sin respuesta HTTP)"

# ── Información del sistema ───────────────────────────────────────────
echo "--- Info del sistema ---"
run "sistema_info"        uname -a
run "sistema_hostname"    hostname -f
run "sistema_fecha"       date

# ── Empaquetar ────────────────────────────────────────────────────────
echo ""
echo "  Empaquetando evidencias..."
zip -qj "$ZIPFILE" "$OUTDIR"/*.txt

echo ""
echo "=== Listo ==="
echo "  Archivo ZIP: $ZIPFILE"
echo "  Tamaño     : $(du -h "$ZIPFILE" | cut -f1)"
echo ""
echo "  Sube este archivo en la tarea del AVA (Blackboard)."
echo "  Nombre esperado: SLY1101_EP3_${ALUMNO}_<fecha>.zip"#!/bin/bash
# =============================================================================
# SLY1101 — Recolector de evidencias Parcial 3 (EA3)
# Captura comandos de NFS/autofs, arranque/firewalld/SELinux y Podman
# Uso: bash SLY1101-recolectar_parcial3.sh
# =============================================================================

set -euo pipefail

ALUMNO="${USER:-student}"
FECHA=$(date +%Y%m%d_%H%M%S)
OUTDIR="/tmp/evidencias_parcial3_${ALUMNO}"
ZIPFILE="/tmp/SLY1101_EP3_${ALUMNO}_${FECHA}.zip"

echo "=== SLY1101 — Recolector de evidencias Parcial 3 ==="
echo "  Usuario : $ALUMNO"
echo "  Destino : $OUTDIR"
echo ""

mkdir -p "$OUTDIR"

run() {
    local label="$1"; shift
    local outfile="$OUTDIR/${label}.txt"
    echo "  [+] $label"
    {
        echo "### COMANDO: $*"
        echo "### FECHA:   $(date)"
        echo ""
        "$@" 2>&1 || true
    } > "$outfile"
}

# ── SECCIÓN 1 — NFS y autofs ─────────────────────────────────────────
echo "--- Sección 1: NFS y autofs ---"

run "s1_paquetes_nfs"     bash -c 'rpm -q nfs-utils autofs 2>/dev/null || dnf list installed nfs-utils autofs 2>/dev/null || echo "(paquetes no encontrados)"'
run "s1_mount_nfs"        bash -c 'mount -t nfs || echo "(sin montajes NFS activos)"'
run "s1_fstab_nfs"        bash -c 'echo "--- grep NFS/autofs ---"; grep -E "nfs|autofs" /etc/fstab || echo "(sin entradas NFS en fstab)"; echo "--- tail -5 /etc/fstab ---"; tail -5 /etc/fstab'
run "s1_autofs_master"    find /etc/auto.master.d/ -type f -exec echo "=== {} ===" \; -exec cat {} \; 2>/dev/null || echo "(sin mapas maestros)"
run "s1_autofs_maps"      find /etc -name 'auto.*' -not -name 'auto.master' -exec echo "=== {} ===" \; -exec cat {} \; 2>/dev/null || true
run "s1_autofs_status"    systemctl status autofs --no-pager 2>/dev/null || echo "(autofs no instalado)"
run "s1_mount_autofs"     bash -c 'mount | grep -E "nfs|autofs" || echo "(sin montajes NFS/autofs activos)"'
run "s1_autofs_ls"        bash -c 'echo "--- ls /shares/data (dispara montaje autofs) ---"; ls /shares/data 2>/dev/null || echo "(no se pudo listar /shares/data — verifique que autofs esté activo)"'
run "s1_showmount"        showmount --exports serverb.lab.example.com 2>/dev/null || echo "(showmount no disponible)"

# ── SECCIÓN 2 — Arranque, firewalld, SELinux ─────────────────────────
echo "--- Sección 2: Arranque, firewalld y SELinux ---"

run "s2_default_target"   systemctl get-default
run "s2_targets_activos"  systemctl list-units --type=target --no-pager
run "s2_grub_cmdline"     cat /proc/cmdline
run "s2_firewall_list"    firewall-cmd --list-all 2>/dev/null || echo "(firewalld no activo)"
run "s2_firewall_ports"   firewall-cmd --list-ports 2>/dev/null || true
run "s2_selinux_status"   sestatus
run "s2_semanage_http"    semanage port -l 2>/dev/null | grep -E 'http|8080' || echo "(sin puertos http en semanage)"
run "s2_httpd_status"     systemctl status httpd --no-pager 2>/dev/null || echo "(httpd no instalado)"
run "s2_httpd_port"       grep -E '^Listen' /etc/httpd/conf/httpd.conf 2>/dev/null || echo "(httpd.conf no encontrado)"
run "s2_audit_avc"        ausearch -m avc --start today 2>/dev/null | tail -20 || echo "(sin AVCs hoy)"
run "s2_curl_8080"        curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "(sin respuesta en 8080)"

# ── SECCIÓN 3 — Podman ───────────────────────────────────────────────
echo "--- Sección 3: Podman ---"

run "s3_podman_version"   podman version 2>/dev/null || echo "(podman no instalado)"
run "s3_podman_images"    podman images 2>/dev/null
run "s3_podman_ps_all"    podman ps -a 2>/dev/null
run "s3_podman_info"      podman info --format '{{.Store.GraphRoot}}' 2>/dev/null || true
run "s3_podman_auth"      bash -c 'cat ~/.config/containers/auth.json 2>/dev/null || echo "(sin credenciales guardadas en auth.json)"'
run "s3_containerfile"    cat /home/student/myimage/Containerfile 2>/dev/null || \
                          cat /home/"$ALUMNO"/myimage/Containerfile 2>/dev/null || \
                          echo "(Containerfile no encontrado)"
run "s3_index_html"       cat /home/student/myimage/index.html 2>/dev/null || \
                          cat /home/"$ALUMNO"/myimage/index.html 2>/dev/null || \
                          echo "(index.html no encontrado)"
run "s3_curl_web"         curl -s http://localhost:8080 2>/dev/null | head -5 || \
                          curl -s http://localhost:80 2>/dev/null | head -5 || \
                          echo "(sin respuesta HTTP)"

# ── Información del sistema ───────────────────────────────────────────
echo "--- Info del sistema ---"
run "sistema_info"        uname -a
run "sistema_hostname"    hostname -f
run "sistema_fecha"       date

# ── Empaquetar ────────────────────────────────────────────────────────
echo ""
echo "  Empaquetando evidencias..."
zip -qj "$ZIPFILE" "$OUTDIR"/*.txt

echo ""
echo "=== Listo ==="
echo "  Archivo ZIP: $ZIPFILE"
echo "  Tamaño     : $(du -h "$ZIPFILE" | cut -f1)"
echo ""
echo "  Sube este archivo en la tarea del AVA (Blackboard)."
echo "  Nombre esperado: SLY1101_EP3_${ALUMNO}_<fecha>.zip"
