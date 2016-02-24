include:
  - telegraf

telegraf-config:
  file.managed:
    - name: /etc/telegraf/telegraf.conf
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

{% elif grains.kernel == 'Darwin' %}

reload-telegraf:
    cmd.wait:
      - name: launchctl unload -w /Library/LaunchAgents/com.influxdb.telegraf.plist; launchctl load -w /Library/LaunchAgents/com.influxdb.telegraf.plist
      - watch:
        - file: telegraf-plist
        - file: telegraf-config

{% endif %}