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
