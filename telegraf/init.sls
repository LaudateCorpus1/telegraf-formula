{% if grains.kernel == 'Linux' %}

install-telegraf:
  pkg.installed:
    - sources:
        - telegraf: http://get.influxdb.org/telegraf/telegraf_0.10.3-1_amd64.deb

{% endif %}

{% if grains.kernel == 'Darwin' %}

go:
  macpackage.installed:
    - name: https://storage.googleapis.com/golang/go1.6.darwin-amd64.pkg
    - unless: which go

install-telegraf:
  cmd.run:
    - name: export GOPATH=/usr/local/golang && export PATH=$GOPATH/bin:/usr/local/go/bin/:$PATH && go get github.com/influxdata/telegraf && cd $GOPATH/src/github.com/influxdata/telegraf && make
    - python_shell: True
    - unless: test -e /usr/local/golang/bin/telegraf
    - require:
      - macpackage: go

telegraf-plist:
    file.managed:
      - name: /Library/LaunchAgents/com.influxdb.telegraf.plist
      - source: salt://telegraf/conf/com.influxdb.telegraf.plist

/etc/newsyslog.d/telegraf.conf:
  file.managed:
    - source: salt://telegraf/conf/newsyslog_telegraf.conf
    - makedirs: True

{% endif %}


{% if grains.kernel == 'Windows' %}

{% set nssm_bin = "C:/telegraf/nssm-2.24/win64/nssm.exe" %}
{% set telegraf_bin = "C:/telegraf/telegraf.exe" %}

telegraf:
  archive.extracted:
    - name: C:\telegraf\
    - source: http://get.influxdb.org/telegraf/telegraf-0.10.4-1_windows_amd64.zip
    - archive_format: zip
    - if_missing: "{{ telegraf_bin }}"
    - source_hash: md5=ad9daa8f6c75714851bd5a67627a0d9d

nssm:
  archive.extracted:
    - name: C:\telegraf\
    - source: https://nssm.cc/release/nssm-2.24.zip
    - if_missing: "{{ nssm_bin }}"
    - archive_format: zip
    - source_hash: md5=b2edd0e4a7a7be9d157c0da0ef65b1bc

install-service:
    cmd.wait:
      - name: {{ nssm_bin }} install telegraf "{{ telegraf_bin }}" -config C:\telegraf\telegraf.conf & {{ nssm_bin }} start telegraf
      - watch:
        - archive: telegraf
      - require:
        - archive: nssm
{% endif %}