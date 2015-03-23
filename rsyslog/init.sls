{% from "rsyslog/map.jinja" import rsyslog with context %}

package_{{ rsyslog.package }}:
  pkg:
    - name: {{ rsyslog.package }}
    - installed

service_{{ rsyslog.service }}:
  service.running:
    - name: {{ rsyslog.service }}
    - enable: True
    - require:
      - pkg: package_{{ rsyslog.package }}
    - watch:
      - file: config_{{ rsyslog.config }}

config_{{ rsyslog.config }}:
  file.managed:
    - name: /etc/rsyslog.conf
    - template: jinja
    - source: salt://rsyslog/files/rsyslog.conf.jinja
    - context:
      config: {{ salt['pillar.get']('rsyslog', {}) }}

{% for filename in salt['pillar.get']('rsyslog:custom', {}) %}
rsyslog_custom_{{filename}}:
  file.managed:
    - source: salt://rsyslog/files/{{ filename }}
    {% if filename.endswith('.jinja') %}
    - template: jinja
    - name: {{ rsyslog.custom_config_path }}/{{ filename|replace(".jinja", "") }}
    {% else %}
    - name: {{ rsyslog.custom_config_path }}/{{ filename }}
    {% endif %}
    - watch_in: 
      - service: {{ rsyslog.service }}
{% endfor %}
