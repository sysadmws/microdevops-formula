{% if (pillar['php-fpm'] is defined) and (pillar['php-fpm'] is not none) %}
  {%- if (pillar['php-fpm']['enabled'] is defined) and (pillar['php-fpm']['enabled'] is not none) and (pillar['php-fpm']['enabled']) %}
    {%- if (pillar['php-fpm']['version_5_5'] is defined) and (pillar['php-fpm']['version_5_5'] is not none) and (pillar['php-fpm']['version_5_5']) %}
php-fpm_5_5_installed:
  pkg.installed:
    - pkgs:
      - php5-cli
      - php5-fpm

      {%- if (pillar['php-fpm']['modules'] is defined) and (pillar['php-fpm']['modules'] is not none) %}
        {%- if (pillar['php-fpm']['modules']['php5_5'] is defined) and (pillar['php-fpm']['modules']['php5_5'] is not none) %}
php-fpm_5_5_modules_installed:
  pkg.installed:
    - pkgs:
          {%- for pkg_name in pillar['php-fpm']['modules']['php5_5'] %}
            {%- if (pkg_name != 'php5-ioncube') %}
      - {{ pkg_name }}
            {%- endif %}
          {%- endfor %}

          {%- for pkg_name in pillar['php-fpm']['modules']['php5_5'] %}
            {%- if (pkg_name == 'php5-ioncube') %}
php-fpm_5_5_modules_ioncube_1:
  file.managed:
    - name: '/usr/lib/php5/20121212/ioncube_loader_lin_5.5.so'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube_loader_lin_5.5.so'

php-fpm_5_5_modules_ioncube_2:
  file.managed:
    - name: '/etc/php5/mods-available/ioncube.ini'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube.ini'
    - template: jinja
    - defaults:
        path: '/usr/lib/php5/20121212/ioncube_loader_lin_5.5.so'

php-fpm_5_5_modules_ioncube_3:
  file.symlink:
    - name: '/etc/php5/fpm/conf.d/00-ioncube.ini'
    - target: '/etc/php5/mods-available/ioncube.ini'
            {%- endif %}
          {%- endfor %}
        {%- endif %}
      {%- endif %}
    {%- endif %}

    {%- if (pillar['php-fpm']['version_5_6'] is defined) and (pillar['php-fpm']['version_5_6'] is not none) and (pillar['php-fpm']['version_5_6']) %}
php-fpm_repo_deb_5_6:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/ondrej/php/ubuntu {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/ondrej-ubuntu-php-{{ grains['oscodename'] }}.list
    - keyserver: keyserver.ubuntu.com
    - keyid: E5267A6C
    - refresh: True

php-fpm_5_6_installed:
  pkg.installed:
    - pkgs:
      - php5.6-cli
      - php5.6-fpm

      {%- if (pillar['php-fpm']['modules'] is defined) and (pillar['php-fpm']['modules'] is not none) %}
        {%- if (pillar['php-fpm']['modules']['php5_6'] is defined) and (pillar['php-fpm']['modules']['php5_6'] is not none) %}
php-fpm_5_6_modules_installed:
  pkg.installed:
    - pkgs:
          {%- for pkg_name in pillar['php-fpm']['modules']['php5_6'] %}
            {%- if (pkg_name != 'php5.6-ioncube') %}
      - {{ pkg_name }}
            {%- endif %}
          {%- endfor %}

          {%- for pkg_name in pillar['php-fpm']['modules']['php5_6'] %}
            {%- if (pkg_name == 'php5.6-ioncube') %}
php-fpm_5_6_modules_ioncube_1:
  file.managed:
    - name: '/usr/lib/php/20131226/ioncube_loader_lin_5.6.so'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube_loader_lin_5.6.so'

php-fpm_5_6_modules_ioncube_2:
  file.managed:
    - name: '/etc/php/5.6/mods-available/ioncube.ini'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube.ini'
    - template: jinja
    - defaults:
        path: '/usr/lib/php/20131226/ioncube_loader_lin_5.6.so'

php-fpm_5_6_modules_ioncube_3:
  file.symlink:
    - name: '/etc/php/5.6/fpm/conf.d/00-ioncube.ini'
    - target: '/etc/php/5.6/mods-available/ioncube.ini'
            {%- endif %}
          {%- endfor %}
        {%- endif %}
      {%- endif %}
    {%- endif %}

    {%- if (pillar['php-fpm']['version_7_0'] is defined) and (pillar['php-fpm']['version_7_0'] is not none) and (pillar['php-fpm']['version_7_0']) %}
php-fpm_repo_deb_7_0:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/ondrej/php/ubuntu {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/ondrej-ubuntu-php-{{ grains['oscodename'] }}.list
    - keyserver: keyserver.ubuntu.com
    - keyid: E5267A6C
    - refresh: True

php-fpm_7_0_installed:
  pkg.installed:
    - pkgs:
      - php7.0-cli
      - php7.0-fpm

      {%- if (pillar['php-fpm']['modules'] is defined) and (pillar['php-fpm']['modules'] is not none) %}
        {%- if (pillar['php-fpm']['modules']['php7_0'] is defined) and (pillar['php-fpm']['modules']['php7_0'] is not none) %}
php-fpm_7_0_modules_installed:
  pkg.installed:
    - pkgs:
          {%- for pkg_name in pillar['php-fpm']['modules']['php7_0'] %}
            {%- if (pkg_name != 'php7.0-ioncube') %}
      - {{ pkg_name }}
            {%- endif %}
          {%- endfor %}

          {%- for pkg_name in pillar['php-fpm']['modules']['php7_0'] %}
            {%- if (pkg_name == 'php7.0-ioncube') %}
php-fpm_7_0_modules_ioncube_1:
  file.managed:
    - name: '/usr/lib/php/20151012/ioncube_loader_lin_7.0.so'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube_loader_lin_7.0.so'

php-fpm_7_0_modules_ioncube_2:
  file.managed:
    - name: '/etc/php/7.0/mods-available/ioncube.ini'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube.ini'
    - template: jinja
    - defaults:
        path: '/usr/lib/php/20151012/ioncube_loader_lin_7.0.so'

php-fpm_7_0_modules_ioncube_3:
  file.symlink:
    - name: '/etc/php/7.0/fpm/conf.d/00-ioncube.ini'
    - target: '/etc/php/7.0/mods-available/ioncube.ini'

            {%- endif %}
          {%- endfor %}
        {%- endif %}
      {%- endif %}
    {%- endif %}
    {%- if (pillar['php-fpm']['version_7_1'] is defined) and (pillar['php-fpm']['version_7_1'] is not none) and (pillar['php-fpm']['version_7_1']) %}
php-fpm_repo_deb_7_1:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/ondrej/php/ubuntu {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/ondrej-ubuntu-php-{{ grains['oscodename'] }}.list
    - keyserver: keyserver.ubuntu.com
    - keyid: E5267A6C
    - refresh: True

php-fpm_7_1_installed:
  pkg.installed:
    - pkgs:
      - php7.1-cli
      - php7.1-fpm

      {%- if (pillar['php-fpm']['modules'] is defined) and (pillar['php-fpm']['modules'] is not none) %}
        {%- if (pillar['php-fpm']['modules']['php7_1'] is defined) and (pillar['php-fpm']['modules']['php7_1'] is not none) %}
php-fpm_7_1_modules_installed:
  pkg.installed:
    - pkgs:
          {%- for pkg_name in pillar['php-fpm']['modules']['php7_1'] %}
            {%- if (pkg_name != 'php7.1-ioncube') %}
      - {{ pkg_name }}
            {%- endif %}
          {%- endfor %}

          {%- for pkg_name in pillar['php-fpm']['modules']['php7_1'] %}
            {%- if (pkg_name == 'php7.1-ioncube') %}
php-fpm_7_1_modules_ioncube_1:
  file.managed:
    - name: '/usr/lib/php/20160505/ioncube_loader_lin_7.1.so'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube_loader_lin_7.1.so'

php-fpm_7_1_modules_ioncube_2:
  file.managed:
    - name: '/etc/php/7.1/mods-available/ioncube.ini'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube.ini'
    - template: jinja
    - defaults:
        path: '/usr/lib/php/20160505/ioncube_loader_lin_7.1.so'

php-fpm_7_1_modules_ioncube_3:
  file.symlink:
    - name: '/etc/php/7.1/fpm/conf.d/00-ioncube.ini'
    - target: '/etc/php/7.1/mods-available/ioncube.ini'

            {%- endif %}
          {%- endfor %}
        {%- endif %}
      {%- endif %}
    {%- endif %}
    {%- if (pillar['php-fpm']['version_7_2'] is defined) and (pillar['php-fpm']['version_7_2'] is not none) and (pillar['php-fpm']['version_7_2']) %}
php-fpm_repo_deb_7_2:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/ondrej/php/ubuntu {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/ondrej-ubuntu-php-{{ grains['oscodename'] }}.list
    - keyserver: keyserver.ubuntu.com
    - keyid: E5267A6C
    - refresh: True

php-fpm_7_2_installed:
  pkg.installed:
    - pkgs:
      - php7.2-cli
      - php7.2-fpm

      {%- if (pillar['php-fpm']['modules'] is defined) and (pillar['php-fpm']['modules'] is not none) %}
        {%- if (pillar['php-fpm']['modules']['php7_2'] is defined) and (pillar['php-fpm']['modules']['php7_2'] is not none) %}
php-fpm_7_2_modules_installed:
  pkg.installed:
    - pkgs:
          {%- for pkg_name in pillar['php-fpm']['modules']['php7_2'] %}
            {%- if (pkg_name != 'php7.2-ioncube') %}
      - {{ pkg_name }}
            {%- endif %}
          {%- endfor %}

          {%- for pkg_name in pillar['php-fpm']['modules']['php7_2'] %}
            {%- if (pkg_name == 'php7.2-ioncube') %}
php-fpm_7_2_modules_ioncube_1:
  file.managed:
    - name: '/usr/lib/php/20160505/ioncube_loader_lin_7.2.so'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube_loader_lin_7.2.so'

php-fpm_7_2_modules_ioncube_2:
  file.managed:
    - name: '/etc/php/7.2/mods-available/ioncube.ini'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube.ini'
    - template: jinja
    - defaults:
        path: '/usr/lib/php/20160505/ioncube_loader_lin_7.2.so'

php-fpm_7_2_modules_ioncube_3:
  file.symlink:
    - name: '/etc/php/7.2/fpm/conf.d/00-ioncube.ini'
    - target: '/etc/php/7.2/mods-available/ioncube.ini'

            {%- endif %}
          {%- endfor %}
        {%- endif %}
      {%- endif %}
    {%- endif %}

    {%- if (pillar['php-fpm']['version_7_3'] is defined) and (pillar['php-fpm']['version_7_3'] is not none) and (pillar['php-fpm']['version_7_3']) %}
php-fpm_repo_deb_7_3:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/ondrej/php/ubuntu {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/ondrej-ubuntu-php-{{ grains['oscodename'] }}.list
    - keyserver: keyserver.ubuntu.com
    - keyid: E5267A6C
    - refresh: True

php-fpm_7_3_installed:
  pkg.installed:
    - pkgs:
      - php7.3-cli
      - php7.3-fpm

      {%- if (pillar['php-fpm']['modules'] is defined) and (pillar['php-fpm']['modules'] is not none) %}
        {%- if (pillar['php-fpm']['modules']['php7_3'] is defined) and (pillar['php-fpm']['modules']['php7_3'] is not none) %}
php-fpm_7_3_modules_installed:
  pkg.installed:
    - pkgs:
          {%- for pkg_name in pillar['php-fpm']['modules']['php7_3'] %}
            {%- if (pkg_name != 'php7.3-ioncube') %}
      - {{ pkg_name }}
            {%- endif %}
          {%- endfor %}

          {%- for pkg_name in pillar['php-fpm']['modules']['php7_3'] %}
            {%- if (pkg_name == 'php7.3-ioncube') %}
php-fpm_7_3_modules_ioncube_1:
  file.managed:
    - name: '/usr/lib/php/20180731/ioncube_loader_lin_7.3.so'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube_loader_lin_7.3.so'

php-fpm_7_3_modules_ioncube_2:
  file.managed:
    - name: '/etc/php/7.3/mods-available/ioncube.ini'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube.ini'
    - template: jinja
    - defaults:
        path: '/usr/lib/php/20180731/ioncube_loader_lin_7.3.so'

php-fpm_7_3_modules_ioncube_3:
  file.symlink:
    - name: '/etc/php/7.3/fpm/conf.d/00-ioncube.ini'
    - target: '/etc/php/7.3/mods-available/ioncube.ini'

            {%- endif %}
          {%- endfor %}
        {%- endif %}
      {%- endif %}
    {%- endif %}
    
    {%- if (pillar['php-fpm']['version_7_4'] is defined) and (pillar['php-fpm']['version_7_4'] is not none) and (pillar['php-fpm']['version_7_4']) %}
php-fpm_repo_deb_7_4:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/ondrej/php/ubuntu {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/ondrej-ubuntu-php-{{ grains['oscodename'] }}.list
    - keyserver: keyserver.ubuntu.com
    - keyid: E5267A6C
    - refresh: True

php-fpm_7_4_installed:
  pkg.installed:
    - pkgs:
      - php7.4-cli
      - php7.4-fpm

      {%- if (pillar['php-fpm']['modules'] is defined) and (pillar['php-fpm']['modules'] is not none) %}
        {%- if (pillar['php-fpm']['modules']['php7_4'] is defined) and (pillar['php-fpm']['modules']['php7_4'] is not none) %}
php-fpm_7_4_modules_installed:
  pkg.installed:
    - pkgs:
          {%- for pkg_name in pillar['php-fpm']['modules']['php7_4'] %}
            {%- if (pkg_name != 'php7.4-ioncube') %}
      - {{ pkg_name }}
            {%- endif %}
          {%- endfor %}

          {%- for pkg_name in pillar['php-fpm']['modules']['php7_4'] %}
            {%- if (pkg_name == 'php7.4-ioncube') %}
php-fpm_7_4_modules_ioncube_1:
  file.managed:
    - name: '/usr/lib/php/20180731/ioncube_loader_lin_7.4.so'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube_loader_lin_7.4.so'

php-fpm_7_4_modules_ioncube_2:
  file.managed:
    - name: '/etc/php/7.4/mods-available/ioncube.ini'
    - user: root
    - group: root
    - source: 'salt://php-fpm/files/ioncube/ioncube.ini'
    - template: jinja
    - defaults:
        path: '/usr/lib/php/20180731/ioncube_loader_lin_7.4.so'

php-fpm_7_4_modules_ioncube_3:
  file.symlink:
    - name: '/etc/php/7.4/fpm/conf.d/00-ioncube.ini'
    - target: '/etc/php/7.4/mods-available/ioncube.ini'

            {%- endif %}
          {%- endfor %}
        {%- endif %}
      {%- endif %}
    {%- endif %}

    {%- if (pillar['php-fpm']['tz'] is defined  and pillar['php-fpm']['tz'] is not none) %}
      {%- for k, v in pillar['php-fpm']['tz'].iteritems() %}
        {%- set phpversion = k.replace('_','.').split('php')[1] %}
        {%- set timezone = v %}

        {%- for type in ['cli','fpm'] %}
php-fpm_{{ k }}_timezone_{{ type }}:
  ini.options_present:
          {%- if phpversion == '5.5' %}
    - name: '/etc/php5/{{ type }}/php.ini'
          {%- else %}
    - name: '/etc/php/{{ phpversion }}/{{ type }}/php.ini'
          {%- endif %}
    - separator: '='
    - sections:
        Date:
          date.timezone: {{ timezone }}
        {%- endfor %}

      {%- endfor %}
    {%- endif %}

  {%- endif %}
{% endif %}
