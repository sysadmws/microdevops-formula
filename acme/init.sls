{% if pillar["acme"] is defined %}
acme_dirs:
  file.directory:
    - names:
      - /opt/acme
      - /opt/acme/cert
      - /opt/acme/git
      - /opt/acme/home
      - /opt/acme/config

  {%- for acme_acc, acme_params in pillar["acme"].items() %}
acme_acc_dirs_{{ loop.index }}:
  file.directory:
    - names:
      - /opt/acme/git/{{ acme_acc }}
      - /opt/acme/home/{{ acme_acc }}
      - /opt/acme/config/{{ acme_acc }}

acme_git_{{ loop.index }}:
  git.latest:
    - name: https://github.com/acmesh-official/acme.sh.git
    - target: /opt/acme/git/{{ acme_acc }}
    - force_reset: True
    - force_fetch: True
    - rev: {{ acme_params.get("rev", "master") }}

acme_install_{{ loop.index }}:
  cmd.run:
    - name: /opt/acme/git/{{ acme_acc }}/acme.sh --home /opt/acme/home/{{ acme_acc }} --cert-home /opt/acme/cert --config-home /opt/acme/config/{{ acme_acc }} --install
    - cwd: /opt/acme/git/{{ acme_acc }}

acme_set_ca_server_{{ loop.index }}:
  cmd.run:
    - name: /opt/acme/git/{{ acme_acc }}/acme.sh --home /opt/acme/home/{{ acme_acc }} --cert-home /opt/acme/cert --config-home /opt/acme/config/{{ acme_acc }} --set-default-ca --server {{ acme_params.get("ca_server","letsencrypt") }}
    - cwd: /opt/acme/git/{{ acme_acc }}

    {%- if "post_install_cmd" in acme_params %}
acme_post_install_cmd_{{ loop.index }}:
  cmd.run:
    - name: /opt/acme/git/{{ acme_acc }}/acme.sh --home /opt/acme/home/{{ acme_acc }} --cert-home /opt/acme/cert --config-home /opt/acme/config/{{ acme_acc }} {{ acme_params["post_install_cmd"] }}
    - cwd: /opt/acme/git/{{ acme_acc }}

    {%- endif %}

acme_local_{{ loop.index }}:
  file.managed:
    - name: /opt/acme/home/{{ acme_acc }}/acme_local.sh
    - mode: 0700
    - contents: |
        #!/bin/bash
    {%- if "vars" in acme_params %}
      {%- for var_key, var_val in acme_params["vars"].items() %}
        export {{ var_key }}="{{ var_val }}"
      {%- endfor %}
    {%- endif %}
        /opt/acme/home/{{ acme_acc }}/acme.sh --home /opt/acme/home/{{ acme_acc }} --cert-home /opt/acme/cert --config-home /opt/acme/config/{{ acme_acc }} {{ acme_params["args"]|default("") }} "$@"

acme_verify_and_issue_{{ loop.index }}:
  file.managed:
    - name: /opt/acme/home/{{ acme_acc }}/verify_and_issue.sh
    - mode: 0700
    - contents: |
        #!/bin/bash
        if [[ "$1" == "" ]]; then
          echo -e >&2 "ERROR: Use verify_and_issue.sh APP DOMAIN"
          exit 1
        fi
        ACME_LOCAL_APP="$1"
        ACME_LOCAL_DOMAIN="$2"
        SAN=""
        if [[ "$#" > "2" ]]; then
          shift
          shift
          while [ -n "$1" ]; do
            SAN="${SAN}-d ${1} "
            shift
          done
        fi
        if openssl verify -CAfile /opt/acme/cert/${ACME_LOCAL_APP}_${ACME_LOCAL_DOMAIN}_ca.cer /opt/acme/cert/${ACME_LOCAL_APP}_${ACME_LOCAL_DOMAIN}_fullchain.cer 2>&1 | grep -q -i -e error -e cannot; then
          /opt/acme/home/{{ acme_acc }}/acme_local.sh \
            --cert-file /opt/acme/cert/${ACME_LOCAL_APP}_${ACME_LOCAL_DOMAIN}_cert.cer \
            --key-file /opt/acme/cert/${ACME_LOCAL_APP}_${ACME_LOCAL_DOMAIN}_key.key \
            --ca-file /opt/acme/cert/${ACME_LOCAL_APP}_${ACME_LOCAL_DOMAIN}_ca.cer \
            --fullchain-file /opt/acme/cert/${ACME_LOCAL_APP}_${ACME_LOCAL_DOMAIN}_fullchain.cer \
            --issue -d ${ACME_LOCAL_DOMAIN} $SAN
        else
          echo openssl verify OK
        fi

    {%- set a_loop = loop %}
    {%- for var_key, var_val in acme_params["vars"].items() %}
acme_acc_setenv_{{ a_loop.index }}_{{ loop.index }}:
  environ.setenv:
    - name: {{ var_key }}
    - value: "{{ var_val }}"
    - update_minion: True

    {%- endfor %}

    {%- if "chown" in acme_params %}
acme_chown_{{ loop.index }}:
  cmd.run:
    - name: chown -R {{ acme_params["chown"] }} /opt/acme

    {%- endif %}

  {%- endfor %}
{% endif %}
