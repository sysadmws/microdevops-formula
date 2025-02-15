{% if pillar["salt"] is defined and "minion" in pillar["salt"] %}

  {%- for host in pillar["salt"]["minion"]["hosts"] %}
salt_master_hosts_{{ loop.index }}:
  host.present:
    - clean: True
    - ip: {{ host["ip"] }}
    - names:
        - {{ host["name"] }}
  {%- endfor %}

  {%- if grains["os"] in ["Windows"] %}
    {%- if pillar["salt"]["minion"]["version"]|string == "3001" %}
      {%- set minion_src = 'https://archive.repo.saltproject.io/windows/Salt-Minion-' ~ pillar["salt"]["minion"]["version"]|string ~ '-Py3-AMD64-Setup.exe' -%}
    # This block should be updated each time new minor version comes
    {%- elif pillar["salt"]["minion"]["version"]|string == "3004" %}
      {%- set minion_src = 'https://repo.saltstack.com/windows/Salt-Minion-' ~ pillar["salt"]["minion"]["version"]|string ~ '.1-Py3-AMD64-Setup.exe' -%}
    {%- else %}
      {%- set minion_src = 'https://repo.saltstack.com/windows/Salt-Minion-' ~ pillar["salt"]["minion"]["version"]|string ~ '.1-Py3-AMD64-Setup.exe' -%}
    {%- endif %}
    {%- set minion_exe = 'Salt-Minion-' ~ pillar["salt"]["minion"]["version"]|string ~ '-Py3-AMD64-Setup.exe' -%}

    {%- if 
           pillar["salt"]["minion"]["version"]|string != grains["saltversioninfo"][0]|string
           or
           (pillar["salt"]["minion"]["release"] is defined and pillar["salt"]["minion"]["release"] != grains["saltversioninfo"][0]|string + "." + grains["saltversioninfo"][1]|string)
    %}
minion_installer_exe:
  file.managed:
    - name: 'C:\Windows\{{ minion_exe }}' # DO NOT USE "" here - slash \ is treated as escape inside
    - source: '{{ minion_src }}'
    - source_hash: '{{ minion_src }}.sha256'

minion_install_silent_cmd:
  cmd.run:
    - name: |
        START /B C:\Windows\{{ minion_exe }} /S /master={{ pillar["salt"]["minion"]["config"]["master"]|join(",") }} /minion-name={{ grains["id"] }} /start-minion=1
    {%- endif %}

    {%- if pillar["salt"]["minion"]["grains_file_rm"] is defined and pillar["salt"]["minion"]["grains_file_rm"] %}
salt_minion_grains_file_rm:
  file.absent:
    - name: 'C:\salt\conf\grains'
    {%- endif %}

salt_minion_id:
  file.managed:
    - name: 'C:\salt\conf\minion_id'
    - contents: |
        {{ grains["id"] }}

salt_minion_config:
  file.serialize:
    - name: 'C:\salt\conf\minion'
    - show_changes: True
    - create: True
    - merge_if_exists: False
    - formatter: yaml
    - dataset: {{ pillar["salt"]["minion"]["config"] }}

salt_minion_config_restart:
  module.run:
    - name: service.restart
    - m_name: salt-minion
    - onchanges:
        - file: 'C:\salt\conf\minion'
        - file: 'C:\salt\conf\grains'
        - file: 'C:\salt\conf\minion_id'

  {%- elif grains["os"] in ["Ubuntu", "Debian", "CentOS"] %}

    # If install_root is set use it as a prefix in all paths
    {%- if "install_root" in pillar["salt"]["minion"] %}
      {% set install_root = pillar["salt"]["minion"]["install_root"] %}
      # Add root_dir to pillar["salt"]["minion"]["config"]
      {%- do pillar["salt"]["minion"]["config"].update({"root_dir": install_root}) %}
    {%- else %}
      {% set install_root = "" %}
    {%- endif %}

salt_minion_dirs_1:
  file.directory:
    - names:
      - {{ install_root }}/etc/salt
      - {{ install_root }}/etc/salt/pki
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

salt_minion_dirs_2:
  file.directory:
    - names:
      - {{ install_root }}/etc/salt/pki/minion
    - user: root
    - group: root
    - mode: 700

    {%- if pillar["salt"]["minion"]["grains_file_rm"] is defined and pillar["salt"]["minion"]["grains_file_rm"] %}
salt_minion_grains_file_rm:
  file.absent:
    - name: {{ install_root }}/etc/salt/grains
    {%- endif %}

salt_minion_id:
  file.managed:
    - name: {{ install_root }}/etc/salt/minion_id
    - contents: |
        {{ grains["id"] }}

salt_minion_config:
  file.serialize:
    - name: {{ install_root }}/etc/salt/minion
    - user: root
    - group: root
    - mode: 644
    - show_changes: True
    - create: True
    - merge_if_exists: False
    - formatter: yaml
    - dataset: {{ pillar["salt"]["minion"]["config"] }}

    {%- if "pki" in pillar["salt"]["minion"] and "minion" in pillar["salt"]["minion"]["pki"] %}
salt_minion_pki_minion_pem:
  file.managed:
    - name: {{ install_root }}/etc/salt/pki/minion/minion.pem
    - user: root
    - group: root
    - mode: 400
    - contents: {{ pillar["salt"]["minion"]["pki"]["minion"]["pem"] | yaml_encode }}

salt_minion_pki_minion_pub:
  file.managed:
    - name: {{ install_root }}/etc/salt/pki/minion/minion.pub
    - user: root
    - group: root
    - mode: 644
    - contents: {{ pillar["salt"]["minion"]["pki"]["minion"]["pub"] | yaml_encode }}

salt_minion_pki_master_sign_pub:
  file.managed:
    - name: {{ install_root }}/etc/salt/pki/minion/master_sign.pub
    - user: root
    - group: root
    - mode: 644
    - contents: {{ pillar["salt"]["minion"]["pki"]["master_sign"] | yaml_encode }}

      {%- if "minion_master" in pillar["salt"]["minion"]["pki"] %}
salt_minion_pki_minion_master_pub:
  file.managed:
    - name: {{ install_root }}/etc/salt/pki/minion/minion_master.pub
    - user: root
    - group: root
    - mode: 644
    - contents: {{ pillar["salt"]["minion"]["pki"]["minion_master"] | yaml_encode }}

      {%- endif %}
    {%- endif %}

    {%- if grains["oscodename"] in ["xenial", "bionic", "focal", "jammy", "buster"] %}
      # There are only 3001 and 3002 packages for xenial
      {%- if grains["oscodename"] in ["xenial"] and pillar["salt"]["minion"]["version"]|int > 3002 %}
        {%- set salt_minion_version = "3002" %}
      {%- else %}
        {%- set salt_minion_version = pillar["salt"]["minion"]["version"]|string %}
      {%- endif %}
      # TODO there are no packages for jammy yet
      {%- if grains["osrelease"]|string in ["22.04"] %}
        {%- set repo_osrelease = "20.04" %}
      {%- else %}
        {%- set repo_osrelease = grains["osrelease"]|string %}
      {%- endif %}
      {%- if grains["oscodename"] in ["jammy"] %}
        {%- set repo_oscodename = "focal" %}
      {%- else %}
        {%- set repo_oscodename = grains["oscodename"] %}
      {%- endif %}
salt_minion_repo:
  pkgrepo.managed:
    - humanname: SaltStack Repository
      # 3001 is in archive only
      # xenial packages are in archive only
      {%- if salt_minion_version == "3001" or repo_oscodename in ["xenial"] %}
        {%- if grains["osarch"] == "arm64" %}
    - name: 'deb [arch=amd64] https://archive.repo.saltproject.io/py3/{{ grains["os"]|lower }}/{{ repo_osrelease }}/amd64/{{ salt_minion_version }} {{ repo_oscodename }} main'
        {%- else %}
    - name: 'deb https://archive.repo.saltproject.io/py3/{{ grains["os"]|lower }}/{{ repo_osrelease }}/{{ grains["osarch"] }}/{{ salt_minion_version }} {{ repo_oscodename }} main'
        {%- endif %}
    - file: /etc/apt/sources.list.d/saltstack.list
        {%- if grains["osarch"] == "arm64" %}
    - key_url: https://archive.repo.saltproject.io/py3/{{ grains["os"]|lower }}/{{ repo_osrelease }}/amd64/{{ salt_minion_version }}/SALTSTACK-GPG-KEY.pub
        {%- else %}
    - key_url: https://archive.repo.saltproject.io/py3/{{ grains["os"]|lower }}/{{ repo_osrelease }}/{{ grains["osarch"] }}/{{ salt_minion_version }}/SALTSTACK-GPG-KEY.pub
        {%- endif %}
      {%- else %}
        {%- if grains["osarch"] == "arm64" %}
    - name: 'deb [arch=amd64] https://repo.saltstack.com/py3/{{ grains["os"]|lower }}/{{ repo_osrelease }}/amd64/{{ salt_minion_version }} {{ repo_oscodename }} main'
        {%- else %}
    - name: 'deb https://repo.saltstack.com/py3/{{ grains["os"]|lower }}/{{ repo_osrelease }}/{{ grains["osarch"] }}/{{ salt_minion_version }} {{ repo_oscodename }} main'
        {%- endif %}
    - file: /etc/apt/sources.list.d/saltstack.list
        {%- if grains["osarch"] == "arm64" %}
    - key_url: https://repo.saltstack.com/py3/{{ grains["os"]|lower }}/{{ repo_osrelease }}/amd64/{{ salt_minion_version }}/SALTSTACK-GPG-KEY.pub
        {%- else %}
    - key_url: https://repo.saltstack.com/py3/{{ grains["os"]|lower }}/{{ repo_osrelease }}/{{ grains["osarch"] }}/{{ salt_minion_version }}/SALTSTACK-GPG-KEY.pub
        {%- endif %}
      {%- endif %}
    - clean_file: True
    - refresh: True

      # Check systemd_unit_name
      {%- if "systemd_unit_name" in pillar["salt"]["minion"] %}
        {%- set systemd_unit_name = pillar["salt"]["minion"]["systemd_unit_name"] %}
        {%- set salt_call_args = "-c " ~ install_root ~ "/etc/salt" %}
      {%- else %}
        {%- set systemd_unit_name = "salt-minion" %}
        {%- set salt_call_args = "" %}
      {%- endif %}

      # Create systemd unit file if non-default systemd_unit_name
      {%- if "systemd_unit_name" in pillar["salt"]["minion"] %}
salt_minion_systemd_unit:
  file.managed:
    - name: /etc/systemd/system/{{ systemd_unit_name }}.service
    - contents: |
        [Unit]
        Description=The Salt Minion Additional Service
        After=network.target

        [Service]
        Type=notify
        NotifyAccess=all
        LimitNOFILE=8192
        ExecStart=/usr/bin/salt-minion -c {{ install_root }}/etc/salt
        TimeoutStopSec=3
        StandardOutput=null

        [Install]
        WantedBy=multi-user.target

salt_minion_systemd_enable:
  service.running:
    - name: {{ systemd_unit_name }}
    - enable: True
    - full_restart: True
    - watch:
      - file: /etc/systemd/system/{{ systemd_unit_name }}.service

      {%- endif %}

      # We don't check salt version in grains as in salt-ssh it equals version of salt-ssh, and we need to know installed package version
      {%- set installed_ver = salt["cmd.shell"]("dpkg -s salt-minion 2>/dev/null | grep Version | sed -e 's/^Version: //' -e 's/\..*$//' | grep " + salt_minion_version) %}
      # Also check if salt-minion is upgradable
      {%- set minion_upgradable = salt["cmd.shell"]("apt-get upgrade --dry-run 2>/dev/null | grep 'Inst salt-minion' | sed -e 's/ .*//'") %}
      {%- if salt_minion_version|string != installed_ver|string or minion_upgradable == "Inst" %}
salt_minion_update_restart:
  cmd.run:
    - name: |
        exec 0>&- # close stdin
        exec 1>&- # close stdout
        exec 2>&- # close stderr
        nohup /bin/sh -c 'apt-get update; apt-get -qy -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install --allow-downgrades salt-common={{ salt_minion_version }}* salt-minion={{ salt_minion_version }}* && salt-call {{ salt_call_args }} --local service.restart {{ systemd_unit_name }}' &
      {%- endif %}

    {%- endif %}

salt_minion_config_restart:
  cmd.run:
    - name: |
        exec 0>&- # close stdin
        exec 1>&- # close stdout
        exec 2>&- # close stderr
        nohup /bin/sh -c 'salt-call {{ salt_call_args }} --local service.restart {{ systemd_unit_name }}' &
    - onchanges:
        - file: {{ install_root }}/etc/salt/minion
        - file: {{ install_root }}/etc/salt/grains
        - file: {{ install_root }}/etc/salt/minion_id
        - file: {{ install_root }}/etc/salt/pki/minion/minion.pem
        - file: {{ install_root }}/etc/salt/pki/minion/minion.pub
        - file: {{ install_root }}/etc/salt/pki/minion/master_sign.pub
    {%- if "minion_master" in pillar["salt"]["minion"]["pki"] %}
        - file: {{ install_root }}/etc/salt/pki/minion/minion_master.pub
    {%- endif %}

  {%- endif %}

{% else %}
salt_minion_nothing_done_info:
  test.configurable_test_state:
    - name: nothing_done
    - changes: False
    - result: True
    - comment: |
        INFO: This state was not configured, so nothing has been done. But it is OK.

{% endif %}
