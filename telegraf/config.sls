include:
  - telegraf

telegraf-config:
  file.managed:
    {% if grains.kernel == "Windows" %}
    - name: C:/telegraf/telegraf.conf
    {% else %}
    - name: /etc/telegraf/telegraf.conf
    {% endif %}
    - source: salt://telegraf/conf/telegraf.jinja
    - template: jinja
    - makedirs: True

{% if grains.kernel == 'Linux' %}

telegraf:
  service.running:
    - name: telegraf
    - enable: True
    - watch:
      - pkg: install-telegraf
      - file: telegraf-config

{% else %}

{% set nssm_bin = "C:/telegraf/nssm-2.24/win64/nssm.exe" %}

reload-telegraf:
    cmd.wait:
      {% if grains.kernel == "Darwin" %}
      - name: launchctl unload -w /Library/LaunchAgents/com.influxdb.telegraf.plist; launchctl load -w /Library/LaunchAgents/com.influxdb.telegraf.plist
      {% elif grains.kernel == "Windows" %}
      - name: {{ nssm_bin }} restart telegraf
      {% endif %}
      - watch:
        {% if grains.kernel == "Darwin" %}
        - file: telegraf-plist
        {% endif %}
        - file: telegraf-config

{% endif %}